# G1R Mage Balance — Gothic 1 Remake (UE4SS Lua Mod)

Rebalances **mage spell damage** (and other spell stats) at runtime. **No game files are
modified** — values are changed in memory at load and revert when you close the game.
Everything is configured in one readable table: **one block per spell**.

> **Status: working (dev, v0.3.0).** Balances projectile spells (incl. chargeable ones like
> Fireball) and AoE/special spells whose definition exposes a damage map — **Fire Rain and
> Death Breath included**. A couple of spells use a different damage path (see
> [Limitations](#limitations)); planned work is tracked in [TODO.md](TODO.md).

---

## Features

- **Per-spell damage scaling** — a simple multiplier, or absolute per-magic-circle values.
- **Per-magic-circle aware** — vanilla scales damage at the 2nd / 4th / 6th circle; the mod
  scales each breakpoint, so buffs hold across all circles.
- **Chargeable spells handled** — spells with per-charge-level definitions (`_Lvl1/2/3`,
  e.g. Feuerball, Kugelblitz) are all covered by a single config entry.
- **Field overrides** — optionally set any plain stat on a spell (AoE area, duration,
  speed, stagger, …), not just damage.
- **Idempotent & save-safe** — vanilla values are snapshotted once and the target is always
  `vanilla × factor` (or your absolute values); re-applied after each level/chapter load,
  never stacks.
- **Runtime-only** — touches nothing on disk.

## Requirements

- Gothic 1 Remake (UE4SS-moddable build)
- **UE4SS 3.x** (tested on `3.0.1-326-g940af53`)
- *(optional)* **ConsoleEnablerMod** — only for the `mb_*` console commands

## Installation

Copy the `G1R_MageBalance` folder into `…\Gothic 1 Remake\G1R\Binaries\Win64\Mods\`.
The empty `enabled.txt` activates it. Restart the game.

---

## Configuration

Everything lives in **`Scripts/config.lua` → `Spells`**. One readable block per spell:

```lua
Spells = {
    Feuerpfeil = { class = "FireBoltProjectileDefinition",    damage = 1.0 },         -- vanilla
    Feuerball  = { class = "FireBallProjectileDefinition",    damage = 2.0 },         -- chargeable; x2
    Kugelblitz = { class = "BallLightningDefinition",         damage = 1.0 },
    Feuerregen = { class = "FireRainDefinition",              damage = 2.5,           -- AoE, flat dmg
                   fields = { m_XOffset = 1600, m_YOffset = 1600 } },                 -- + bigger area
    Eispfeil   = { class = "IceBoltProjectileDefinition",     damage = { base = 35, c2 = 40, c4 = 50, c6 = 65 } }, -- absolute (Firebolt parity)
    Todeshauch = { class = "BreathOfDeathDefinition",         damage = 2.0 },         -- breath/AoE
    Pyrokinese = { class = "PyrokinesisProjectileDefinition", damage = 2.5 },
}
```

Each block:

| key | meaning |
|---|---|
| `class` | the spell's definition class name (without `Default__`). Per-charge-level variants `_Lvl1/_Lvl2/_Lvl3` are covered automatically. |
| `damage` | **number** = multiplier on vanilla base + per-circle values (`1.0` = unchanged), **or table** `{ base=, c2=, c4=, c6= }` = absolute values (omitted entries keep vanilla). |
| `fields` | *(optional)* absolute overrides for non-damage stats (field names from `mb_fields`). |
| `enabled` | *(optional)* `false` to skip the spell. |

Leave a spell vanilla with `damage = 1.0` and no `fields` (or comment the block out).

### Adding a spell

1. Cast it once in-game. `UE4SS.log` logs `[SPELL] <Name>Definition base=…`.
2. Add a block using that class name. Done.

(Or probe a guessed name with `mb_try <name>`, and list a definition's tunable fields with
`mb_fields <name>`.)

### Absolute / per-circle example

```lua
Blitz = { class = "…", damage = { base = 80, c2 = 95, c4 = 115, c6 = 150 } },
```

---

## How it works

Spell damage is stored on the spell's **definition CDO** (e.g.
`/Script/Angelscript.Default__FireBallProjectileDefinition`), reached with
`StaticFindObject`. There the mod edits:

- **`m_DamageBase`** — base damage (a map keyed by damage-type tag), and
- **`m_DamageMagicCircleProgression`** — the per-circle breakpoints (2nd/4th/6th).

It snapshots the vanilla values once, then writes `vanilla × factor` (or your absolute
values), and re-applies ~4 s after each `ClientRestart` (level/chapter load). Field
overrides assign plain numeric properties directly. Chargeable spells keep one definition
per charge level (`_Lvl1/2/3`); one config entry covers them all.

## Console commands

Require **ConsoleEnablerMod**.

| command | effect |
|---|---|
| `mb_status` | dump every configured spell's current base + per-circle damage |
| `mb_apply` | re-apply the config now |
| `mb_try <name>` | safely probe whether `Default__<name>…` definitions exist |
| `mb_fields <name>` | list a definition's properties (to find tunable fields) |

## Limitations

- Covers spells whose definition exposes `m_DamageBase` — projectiles, charge spells, and
  AoE/breath spells like **Fire Rain** and **Death Breath**.
- **Not yet covered:** **Lightning / Blitz** (a beam — its damage lives in a *GameplayEffect*,
  not a projectile definition) and **Windfaust / Fist of Wind** (no damage definition found).
  Tracked in [TODO.md](TODO.md).
- **Cast time / mana cost** live in a separate `USpellConfig` object (not the damage
  definition) and aren't changed yet — also on the to-do list.

## Building / dev notes

See [STATUS.md](STATUS.md) for the reverse-engineering notes, the data model, the
hard-won UE4SS crash rules, and what's still open. `DebugSteps = true` in `config.lua`
enables `[DBG]` breadcrumbs before each risky engine call (crash tracing).

## License

MIT — see [LICENSE](LICENSE).
