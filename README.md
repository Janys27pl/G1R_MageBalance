# G1R Mage Balance — Gothic 1 Remake (UE4SS Lua Mod)

Rebalances under-performing **mage spell damage** in Gothic 1 Remake. Runtime-only:
**no original game files are modified** — damage is adjusted in memory at load time,
idempotently and save-safe, following the same pattern as our *Rich Merchants* mod.

> **Status: WORKING (dev).** The per-spell damage scaling mechanism is implemented and
> confirmed in-game (stable, no crash). Spell damage is scaled at projectile-hit time
> via the target's `DamageMultiplier` attribute — see **[How it works](#how-it-works)**
> and **[Adding a spell](#configuring--adding-a-spell)**. Per-spell factors live in
> `Scripts/config.lua`. Remaining work (more spell class names, non-projectile spells)
> is tracked in **[STATUS.md](STATUS.md)**. Older reverse-engineering notes below are
> kept for reference; the data-write approach they describe was a dead end (see STATUS).

---

## Table of contents
- [Target balance (YouTuber feedback)](#target-balance-youtuber-feedback)
- [How spell damage is stored (reverse-engineering notes)](#how-spell-damage-is-stored-reverse-engineering-notes)
- [Key classes, structs & fields](#key-classes-structs--fields)
- [Recon workflow & tooling](#recon-workflow--tooling)
- [File locations on disk](#file-locations-on-disk)
- [Console commands](#console-commands)
- [How it works](#how-it-works)
- [Configuring / Adding a spell](#configuring--adding-a-spell)
- [Requirements](#requirements)

---

## Target balance (YouTuber feedback)

Per-spell feedback from **DaddyKickem** (Discord, 2026-06-12) — the v1 target:

| Spell | Assessment | Direction |
|---|---|---|
| Blitz (Lightning) | "lachhaft" | strong buff (≈2.5×) |
| Todeshauch (Death Breath) | very weak; wrongly counts as wind damage | buff (≈2.0×); damage-type fix **deferred** |
| Feuerregen (Fire Rain) | too weak | buff (≈1.8×) |
| Eispfeil (Ice Arrow) | endgame too weak | buff (≈1.5×) |
| Feuerball (Fireball) | endgame too weak | buff (≈1.5×) |
| Circle-6 spells (general) | too weak | buff |
| Kugelblitz (Ball Lightning) | okay | +10 dmg (flat, minimal) |
| Untote vernichten (Destroy Undead) | okay, long cast time | maybe cast-time ↓ later |
| Eiswelle / Windfaust / Sturmfaust | fine | **leave untouched** |

**v1 scope = spell damage balancing only.** Deferred: mana-potion % healing,
Todeshauch damage-type fix, early Torrez fire-rune, robe values (a robe mod exists).

---

> ⚠️ **Update (live recon 2026-06-12):** the section below was derived from the
> static CXX dump and is partly superseded. **Live testing showed `m_DamageMagicCircleProgression`
> is empty/unused** for these spells; the real damage value lives in an
> AngelScript-injected field **`m_DamageBase`** (a `TMap<DamageTypeTag, {m_Damage}>`)
> on the spell definition CDO. Feuerpfeil = `35`. See **[STATUS.md](STATUS.md)** for the
> confirmed model, what works/doesn't, and the open write-mechanism question.

## How spell damage is stored (reverse-engineering notes)

Gothic 1 Remake (Alkimia Interactive) is built on **Unreal Engine 5** and uses the
**Gameplay Ability System (GAS)** plus an embedded **AngelScript** layer
(`Angelscript`, `AngelscriptCode`, `AngelscriptGAS` modules). Spells are
`UGameplayAbilitySpell*` abilities — but the **damage numbers do not live on the
ability**. They live on the spell's **projectile definition**, keyed **per magic
circle** (which is exactly why the feedback talks about "Circle-6 spells").

The game's own module in the CXX dump is **`G1R.hpp`** (~4.4 MB, ~24.9k lines).

### Damage flow (projectile spells)
```
USpellContainer (UItemDefinition, = the rune item)
   └─ m_SpellConfig : TSubclassOf<USpellConfig>
USpellConfig (UGothicBaseConfig)
   ├─ m_SpellLevels : TArray<FSpellLevelRange>   (CastTime, CastManaCost, ManaCostSc, SpellClass)
   ├─ m_SpellCategoryTag : FGameplayTag          (identifies the spell)
   └─ m_AreaRange / m_AreaAngle                  (for area spells)
USpellProjectileDefinition (UProjectileDefinition → UWeaponDefinition)
   └─ m_DamageMagicCircleProgression : TMap<DamageTypeTag, FDamageProgressionMagicCircle>
                                       ^^^^^ THIS holds the damage numbers
```

`FSpellLevelRange` notably has **no** damage field (only cast time / mana) — confirming
damage comes from the projectile definition's per-circle map, not the per-level config.
The `FRuneStats.DamageByLevel[]` seen in the code is only used to **display** values in
tooltip structs (`FItemTooltipInfo`, `FTooltipInfoRecipe`); it is not the source of truth.

---

## Key classes, structs & fields

All names below are verbatim from the CXX header dump (`G1R.hpp` unless noted).

### `USpellProjectileDefinition` — primary damage source
```cpp
class USpellProjectileDefinition : public UProjectileDefinition {
    float m_DefaultTargetDistance;        // 0x0448
    float m_Speed;                        // 0x044C
    float m_Gravity;                      // 0x0450
    float m_SteeringFactor;               // 0x0454
    float m_LifeTime;                     // 0x0458
    TSoftClassPtr<AActor> m_ExplosionPath;// 0x0460
    TMap<FGameplayTag, FDamageProgressionMagicCircle> m_DamageMagicCircleProgression; // 0x0488
    // --- functions ---
    float GetDamageByCharacterMagicCircle(AGothicCharacter* Character, FGameplayTag DamageTag);
    void  AddDamageForMagicCircle(FGameplayTag DamageTag, FGameplayTag MagicCircleTag, float DamageValue); // ← write lever
};
```

### Damage value structs
```cpp
struct FDamageByMagicCircle {            // Size 0xC
    FGameplayTag m_CircleTag;            // 0x0000  (which magic circle)
    float        m_Damage;              // 0x0008  (the damage number)
};
struct FDamageProgressionMagicCircle {   // Size 0x10
    TArray<FDamageByMagicCircle> m_DamageByMagicCircle; // 0x0000
};
```

### `FRuneStats` — per-rune stat block (tooltip/source; holds DamageType tag)
```cpp
struct FRuneStats {                      // Size 0x58
    int32        SpellLevels;            // 0x0000
    TArray<float> ManaCostScByLevel;     // 0x0008
    TArray<float> ManaCostByLevel;       // 0x0018
    TArray<float> CastTimeByLevel;       // 0x0028
    TArray<float> DamageByLevel;         // 0x0038
    FGameplayTag DamageType;             // 0x0048  ← Todeshauch wind-fix target (deferred)
    ESpellTargetType SpellTargetType;    // 0x0050
    ESpellManaUsage  SpellManaUsage;     // 0x0051
};
```

### Spell config / container classes
```cpp
class USpellConfig : public UGothicBaseConfig {
    TArray<FSpellLevelRange> m_SpellLevels;   // 0x0040  (no damage field here)
    float m_AreaRange;                        // 0x0054
    float m_AreaAngle;                        // 0x0058
    FGameplayTag m_SpellCategoryTag;          // 0x00C8  (identifies the spell)
};
class USpellContainer : public UItemDefinition {
    TSubclassOf<USpellConfig> m_SpellConfig;  // 0x0320  (the rune item -> its config)
};
class USpellConfigurationContainer : public UObject {
    TSubclassOf<USpellConfig> m_SpellConfigClass; // 0x0050
    FGameplayTag m_SpellTag;                       // 0x0058
};
struct FSpellLevelRange {                 // Size 0x20  (NO damage field)
    float CastTime; float CastManaCost; float ManaCostSc;
    TSubclassOf<UScriptGameplayAbility> m_SpellClass;
    TSubclassOf<USpellConfigLevelData> m_SpellConfigLevelData;
};
```

### Related ability / actor classes (for orientation)
- Spell abilities: `UGameplayAbilityCastSpell`, `UGameplayAbilityMagicBase`,
  `UGameplayAbilitySpellBasic`, `UGameplayAbilitySpellCommonProjectile`,
  `UGameplayAbilitySpellTargetable[WithDebuff]`, `UGameplayAbilityStormOfFire`,
  `UGameplayAbilitySpellSummon`, `UGameplayAbilitySpellTransform`,
  `UGameplayAblilitySpellDamageNotify` (note the engine's typo "Ablility").
- Tasks: `UAbilityTask_CastSpell`, `UAbilityTask_LaunchSpell`.
- Visuals / cues: `ASpellProjectileVisual`, `ASpellVisual`, `AStormOfFireVisual`,
  `GC_Firebolt_Actor`, `GC_Firebolt_Pool`, `BP_ItWr_Scroll_BallLightning_World`.
- Enums of interest: `ESpellTargetType`, `ESpellManaUsage`, `E_SpellInteractionType`.
- Base projectile `UProjectileDefinition` holds only movement (`m_Radius`, `m_ArcParam`,
  aiming) — **no** damage; `UBreakableProjectileDefinition` is a sibling subclass.

---

## Recon workflow & tooling

How the model above was obtained (UE4SS **3.0.1** build `v3-0-1-326-g940af53`):

1. **Enable the UE4SS debug GUI** (it was off by default). In `UE4SS-settings.ini`
   under `[Debug]`: `ConsoleEnabled = 1`, `GuiConsoleEnabled = 1`,
   `GuiConsoleVisible = 1`. Restart the game → a separate debug window appears.
2. This build's **Dumpers** tab has **no** "Dump all objects" button. The useful ones:
   - **Dump CXX header** → writes a `CXXHeaderDump\` folder (1024 `*.hpp` files) with
     every class's full field layout + offsets. This is the main artifact — grep it.
   - **Dump all actors to file** → `<id>-ue4ss_actor_data.csv` (live actor instances;
     mostly world meshes — spell *definitions* are UObjects, not actors, so they are
     **not** in this CSV; use the live `mb_spells` Lua reader instead).
3. Grep `CXXHeaderDump\G1R.hpp` for `Spell|Magic|Rune|Damage|Cast|Projectile`.
4. **Phase 2 (live values):** install this mod, be in-world, cast each spell once, run
   `mb_spells` to read the actual `m_Damage` numbers per spell/circle from
   `UE4SS.log`. (Static dumps give structure, not current values.)

> ⚠️ This UE4SS build can crash on global object-array scans. Use only class-targeted
> `FindFirstOf` / `FindAllOf`. (`bUseUObjectArrayCache = false` is set in settings.)

---

## File locations on disk

| What | Path |
|---|---|
| Game / UE4SS install | `C:\Program Files (x86)\Steam\steamapps\common\Gothic 1 Remake\G1R\Binaries\Win64\` |
| UE4SS settings | `…\Win64\UE4SS-settings.ini` |
| Mods folder | `…\Win64\Mods\` (drop `G1R_MageBalance` here) |
| Runtime log | `…\Win64\UE4SS.log` |
| CXX header dump | `…\Win64\CXXHeaderDump\*.hpp` (game module = `G1R.hpp`) |
| Actor CSV dump | `…\Win64\<id>-ue4ss_actor_data.csv` |

---

## Console commands

Require **ConsoleEnablerMod**. All are **read-only** in the current build.

| Command | Effect |
|---|---|
| `mb_spells` | Read every `SpellProjectileDefinition`'s damage map → log per spell: `dmgType / circle / damage` |
| `mb_dumpfirst` | Dump all properties+values of the first instance of each `ReconClasses` entry |
| `mb_dump <ShortClass>` | Dump the first live instance of one class |
| `mb_find <ShortClass>` | List live instances of one class (no property dump) |
| `mb_scan` | List live instances of every `ReconClasses` entry |

`ReconClasses` (in `config.lua`): `SpellProjectileDefinition ProjectileDefinition
USpellConfig USpellContainer SpellConfigurationContainer`.

---

## How it works

Spell base damage lives in each projectile spell's `m_DamageBase` map, but that map
**cannot be written** from UE4SS Lua on this build (the `FGameplayTag` struct keys can't
be pushed back via `Add`, and `ExportText` isn't exposed). So instead of editing the
spell, the mod scales the **final damage at hit time**:

1. Hook `/Script/G1R.ProjectileVisual:OnHitServer` (fires for spell projectiles too).
   `self` is the projectile actor; its `m_ProjectileDefinition` identifies the spell and
   `Instigator`/`Owner` confirm the player cast it.
2. The hit actor (the enemy) is hook arg #2. The mod only proceeds if it's a character
   (class name contains `Character`) — projectiles also hit props/decorations, and
   reading character fields on those crashes hard.
3. Resolve the enemy → `m_CharacterState` → `State_…_NNN` key → its `AttributeSet_Health`
   (`FindAllOf`, cached by key).
4. Set that holder's `DamageMultiplier` (a GAS attribute, `BaseValue`/`CurrentValue`
   struct) to `vanilla × factor`, then restore it ~600 ms later, so only that hit scales.

Because it scales the target's incoming-damage multiplier, the boost lands **after** the
game's armour/resistance calc. Full notes & remaining work: [STATUS.md](STATUS.md).

> ⚠️ **Crash rules (hard, uncatchable):** never `:get()`/unwrap a directly-read object
> field (only hook params); never touch character fields on a non-character hit; use the
> `[DBG]` breadcrumbs (`DebugSteps`) to localise a crash to the exact line.

## Configuring / Adding a spell

All balance lives in `Scripts/config.lua` → **`SpellDamageByClass`**: a table mapping a
**substring of the spell's projectile-definition class name** to a damage **factor**
(`1.0` = vanilla). No code editing needed.

```lua
SpellDamageByClass = {
    FireBolt   = 1.0,   -- Feuerpfeil (fine in vanilla)
    Fireball   = 1.5,   -- Feuerball
    Lightning  = 2.5,   -- Blitz
}
```

To add a spell whose class name you don't know yet:
1. Keep `Verbose = true` (default) and cast the spell once in-game.
2. In `…\Win64\UE4SS.log` find the line `SPELL <Name>ProjectileDefinition /Script/…`.
3. Add `"<Name>" = <factor>,` to `SpellDamageByClass` (the match is a case-sensitive
   substring of the full class name).

Other settings: `EnableSpellScaling` (master on/off), `ScaleDryRun` (resolve+read but
don't write — debugging), `DebugSteps` (per-call breadcrumbs — dev only, keep off).

---

## Requirements

- Gothic 1 Remake (UE4SS-moddable build).
- **UE4SS 3.x** (tested on `v3-0-1-326-g940af53`).
- **ConsoleEnablerMod** (only needed for the optional `mb_*` recon console commands).
