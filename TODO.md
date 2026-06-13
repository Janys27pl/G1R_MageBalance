# G1R Mage Balance — TODO & Ideas

Living list of open work and ideas. Shipped changes are in [CHANGELOG.md](CHANGELOG.md);
the current mechanism, data model and known spell classes are in [STATUS.md](STATUS.md).

---

## Open TODOs

### ⚡ Blitz (ChainLightning) damage buff — deferred (hard)
Blitz is a **ray** spell (`ALightningRayVisual`), **not** a projectile, so it has no
`*ProjectileDefinition` / `m_DamageBase`. Its damage lives in a **GameplayEffect**:
`Default__GE_ChainLightning_WithoutParalysis_Damage` (and `_WithParalysis_…`). Fields:
`Modifiers` (array) → `ModifierMagnitude` → likely `ScalableFloatMagnitude.Value`.
- **Approach:** traverse `cdo.Modifiers` (TArray of FGameplayModifierInfo), find the
  damage modifier, scale its magnitude — deep nested-struct traversal (crash-prone).
- **Risk:** the magnitude may be **SetByCaller** (set at runtime by the ability per
  circle). If so the GE can't be edited → need another lever (hook the ability, or the
  target-`DamageMultiplier` approach we used in v0.1).
- **First step:** dump `Modifiers[0].ModifierMagnitude` to learn the magnitude type.

### Non-projectile / other spells not covered yet
- **Windfaust** (`FistOfWind`) — only an ability CDO, no `*Definition` found → damage
  source unknown (probably a GameplayEffect like Blitz).
- **Eiswelle / Eisblock / Sturmfaust / Untote vernichten / Feuersturm** — these DO have
  a definition with `m_DamageBase` (verified), so they're balanceable any time. Left
  vanilla because DaddyKickem rated them "fine/okay"; add to `config.Spells` when wanted.

---

## Ideas / wishlist

### ⏩ Faster cast/charge animation at higher magic circles
Reward progression: charging spells (Feuerball, Kugelblitz, …) should charge/cast faster
as the mage's circle rises.
- Cast time lives in **`USpellConfig.m_SpellLevels`** → `FSpellLevelRange.CastTime`
  (also `CastManaCost`) — a **separate object per spell**, not the projectile definition.
- Charge/cast animation speed: anim-rate scale on the magic ability
  (`UGameplayAbilityMagicBase` / cast montage play rate).
- **Difficulty: medium.** Find each spell's `USpellConfig` CDO and set per-level
  `CastTime`, and/or the montage rate. Same technique (StaticFindObject + field set).

### 💡 Light (Licht) — novice tier + available early
Make `UItAr_Rune_Light` learnable/castable at **novice** tier and buyable from chapter 1.
Very nice early-game QoL for a mage start.
- Directly mirrors **NoviceWaterMage** (does exactly this for IceBolt): zero the rune's
  `m_RequiredStats` cast gate (+ `RequiredMagicCircleLevel` tooltip) and add it to a
  trader's live `m_Items` (TraderManager, same as Rich Merchants).
- **Difficulty: medium-easy** — technique known & proven. Class = `ItAr_Rune_Light`.

### 💰 Lower cost to learn magic circles
Reduce the requirement/cost to learn the magic circles, to smooth mage progression.
- **Where:** likely a progression/difficulty-settings object or the teacher's learn cost
  (cf. trainer ore costs handled by EconomyTweaks). Needs recon.
- **Difficulty: medium** — locate the learn-cost field(s).

### 🧙 Mage progression overhaul (rank 0 → 3 feels instant)
Bigger picture: vanilla mage progression is thin — you jump from rank 0 to rank 3 almost
immediately, which feels jarring. A gentler curve would be nicer.
- **Reality check (per the user):** probably **very hard / maybe not feasible** with Lua
  mods alone (deep level-up/progression logic). Parked as a long-term wish.

---

Anything balanceable can be added in seconds via `config.lua → Spells` — see
[README.md](README.md#configuration).
