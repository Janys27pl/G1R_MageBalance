# Changelog

All notable changes to **G1R Mage Balance** are documented here.

## [0.4.0] — 2026-06-14

Balance pass driven by the first wave of player feedback (Nexus + Discord).

### Added
- **Fire Storm** (`StormOfFireDefinition`) is now balanced — denerfed after the 1.01
  hotfix left it weak (+20%, 200 → 240), kept below Fire Rain so chapter progression holds.
- **Pyrokinesis** (`PyrokinesisProjectileDefinition`) now buffed (×2.5) — was dealing
  near-zero damage.
- **Death Breath** (`BreathOfDeathDefinition`) buffed (×2.0).

### Changed (balance)
- **Firebolt** nerfed at **Circle 1 only** (35 → 30); Circles 2/4/6 stay vanilla
  (40/50/65). Addresses "Firebolt outshines everything early".
- **Fireball** retuned from ×2.0 to **×1.75** (was overtuned per feedback).
- **Ice Arrow** kept at Firebolt parity (35/40/50/65).
- **Fire Rain** ×2.5 + larger area; **Ball Lightning** left vanilla.

### Notes
- Community feedback collected and triaged in `FEEDBACK.md` (what's feasible vs not).
- Next up: mana cost / cast time (`USpellConfig`) and stun/knockback tuning.

## [0.3.0-dev] — 2026-06-13

Reworked the whole damage approach and the config schema.

### Changed
- **New damage mechanism: direct definition-CDO editing.** Replaced the previous
  hit-time `DamageMultiplier` hook with editing each spell's definition CDO directly
  (`StaticFindObject("…Default__<Name>")` → write `m_DamageBase` + the per-magic-circle
  progression). Cleaner, per-spell **and** per-circle, applied once at load (re-applied on
  level/chapter change), idempotent via a vanilla snapshot.
- **New config schema — one readable block per spell** (`config.lua → Spells`):
  `{ class, damage, fields?, enabled? }`. `damage` is a multiplier **or** an absolute
  `{ base, c2, c4, c6 }` table.

### Added
- **Per-charge-level coverage** — chargeable spells (`…_Lvl1/2/3`, e.g. Feuerball,
  Kugelblitz) are all balanced by a single config entry.
- **Field overrides** (`fields = { … }`) — set any plain stat absolutely (AoE area,
  duration, speed, …), e.g. Feuerregen's rain area.
- Console commands `mb_status`, `mb_apply`, `mb_try <name>`, `mb_fields <name>`.
- Spell-name discovery: casting a spell logs `[SPELL] <class> base=…`.

### Balance (defaults)
- Feuerball ×1.5 · Feuerregen ×2.5 (+ area 1600) · Eispfeil ×1.2 ·
  Feuerpfeil / Kugelblitz left vanilla.

### Known gaps
- Non-projectile fist/breath spells (Todeshauch, Windfaust, Sturmfaust, Eiswelle) use a
  different damage path and aren't covered. Cast time / mana cost live in `USpellConfig`
  (not touched).

## [0.1.0-alpha] — 2026-06-13

First alpha. The per-spell damage-scaling mechanism works and is stable in-game.

### Added
- Per-spell damage scaling for player **spell projectiles**, configured in
  `config.lua` → `SpellDamageByClass` (class-name substring → multiplier;
  `1.0` = vanilla). Adding a spell is a one-line edit.
- `EnableSpellScaling` master switch; `ScaleDryRun` (resolve + read, no write)
  and `DebugSteps` ([DBG] breadcrumbs) for development.
- Spell-name discovery: with `Verbose`, casting a spell logs its
  `…ProjectileDefinition` class name so you can add it to the config.
- Read-only recon console commands `mb_spells`, `mb_dumpfirst`, `mb_dump`,
  `mb_find`, `mb_scan` (require ConsoleEnablerMod).

### How it works
- Hooks `/Script/G1R.ProjectileVisual:OnHitServer`; identifies the spell from the
  projectile's `m_ProjectileDefinition` and confirms the player is the caster.
- On a valid enemy hit, resolves the target's `AttributeSet_Health` and scales its
  `DamageMultiplier` to `vanilla × factor` for that hit, restoring it ~600 ms later.
- **Runtime-only:** no game files are modified. The boost lands after the game's
  armour/resistance calculation.

### Fixed / hardened
- No `:get()`/unwrap on directly-read object fields (hard crash) — only on hook
  params; object fields read via `field_fullname`.
- Skips non-character hits (props/decorations like
  `AlkimiaLightweightDecorationActor`) so a projectile hitting scenery can't crash.
- Restore guarded against targets that died after the hit.

### Known limitations / next
- Only **projectile spells** are covered. Non-projectile spells (e.g. Todeshauch /
  cone & fist spells) don't fire `OnHitServer` and need a separate path.
- Most spells' class names are not mapped yet (need the runes in a save to cast and
  capture them); only FireBolt/BallLightning are known so far.
- During the ~600 ms restore window, all incoming damage to the hit target is
  scaled (minor side effect).

### Notes
- Developed against UE4SS `3.0.1-326-g940af53` on Gothic 1 Remake
  (UE 5.4.3, build 168781). See `README.md` and `STATUS.md` for details.
