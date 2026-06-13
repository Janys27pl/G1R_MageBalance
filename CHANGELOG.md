# Changelog

All notable changes to **G1R Mage Balance** are documented here.

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
