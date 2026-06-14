# G1R Mage Balance — TODO & Ideas

Living list of open work and ideas. Shipped changes are in [CHANGELOG.md](CHANGELOG.md);
the current mechanism, data model and known spell classes are in [STATUS.md](STATUS.md).

---

## Open TODOs

### ✅ Blitz (ChainLightning) — SOLVED (no longer deferred)
The old "ray spell, damage only in a GameplayEffect" assumption was **wrong**. Blitz
*does* have a damage definition: `LightningRayDefinition_Base` / `_WithParalysis` /
`_WithoutParalysis` (vanilla 10/25). Editing `m_DamageBase` there scales the in-game
damage **1:1** — confirmed by a cast test (a 3× test value one-shot a normal enemy).
Now balanced like any other spell via `config.Spells` (currently 60/90). `def_variants`
was extended with `_Base/_WithParalysis/_WithoutParalysis` so one config entry covers all
three player CDOs (the `_Orc` enemy variants are intentionally skipped).

### Other spells — all definitions now mapped (via `mb_scanall`)
- **Windfaust** (`WindFistDefinition`) **DOES** have a damage def (old "ability-only"
  note was wrong) — covered (×2.0). **Sturmfaust** (`StormFistDefinition`, SuperArmor 250),
  **Eiswelle** (`IceWaveProjectileDefinition`), **Eisblock** (`IceBlockProjectileDefinition`)
  all have `m_DamageBase` and sit ready (commented) in `config.Spells`; left vanilla for now.
- **Kugelblitz** (`BallLightningDefinition_Lvl1..4`) and **Pyrokinesis base** carry damage
  in `_LvlN` / concrete classes; the `_Base` holder is empty (that's normal).

---

## Ideas / wishlist

### ✅ Cast time + mana cost — DONE (v0.6 dev)
Both are editable via the new `spellConfig` / `cast` / `mana` config keys (writes the
spell's `USpellConfig.m_SpellLevels[].CastTime / .CastManaCost`). Verified in-game.
- **Still open:** the *charge/hold* duration of chargeable spells (Feuerball, Kugelblitz)
  — the `CastTime` field is small for everything, so the "endless cast" feeling is the
  charge-up, which lives elsewhere (likely the ability's montage play rate /
  `UGameplayAbilityMagicBase`, or a charge-duration field). Not located yet.
- Idea: scale cast/mana *per magic circle* (we only do per spell-level today).

### 💡 Light (Licht) — novice tier + available early
Make `UItAr_Rune_Light` learnable/castable at **novice** tier and buyable from chapter 1.
Very nice early-game QoL for a mage start.
- Directly mirrors **NoviceWaterMage** (does exactly this for IceBolt): zero the rune's
  `m_RequiredStats` cast gate (+ `RequiredMagicCircleLevel` tooltip) and add it to a
  trader's live `m_Items` (TraderManager, same as Rich Merchants).
- **Difficulty: medium-easy** — technique known & proven. Class = `ItAr_Rune_Light`.

### ✅ Lower cost to learn magic circles — DONE
Config key `CircleCost` (number = flat, or per-circle table) writes
`GE_Skill_Mage_Circle_<N>.SPCost`. Default `{ 10, 12, 15, 18, 20, 25 }` = 100 LP
(vanilla 135). Mechanism found by Janys27pl (PR #1), extended to per-circle.
- **Still open / idea:** make it **per-trainer** (e.g. Swamp Camp pricier) — the
  SPCost lives on the GE, so this would need a different lever (per-trainer config).

### 🧙 Mage progression overhaul (rank 0 → 3 feels instant)
Bigger picture: vanilla mage progression is thin — you jump from rank 0 to rank 3 almost
immediately, which feels jarring. A gentler curve would be nicer.
- **Reality check (per the user):** probably **very hard / maybe not feasible** with Lua
  mods alone (deep level-up/progression logic). Parked as a long-term wish.

---

Anything balanceable can be added in seconds via `config.lua → Spells` — see
[README.md](README.md#configuration).
