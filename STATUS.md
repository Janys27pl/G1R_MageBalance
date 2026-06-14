# Mage Balance — dev notes / status (2026-06-13)

## Current mechanism (works, v0.3.0)
Spell damage is edited directly on each spell's **definition CDO**:

```lua
local cdo = StaticFindObject("/Script/Angelscript.Default__" .. defName)  -- Default__ = the CDO
-- base damage: a TMap keyed by damage-type tag; iterate, write via v:set(x)
cdo.m_DamageBase:ForEach(function(_, v) v:set(x) end)
-- per-circle progression: Map -> { m_DamageByMagicCircle: Array of { m_CircleTag, m_Damage } }
cdo.m_DamageMagicCircleProgression:ForEach(function(_, v)
    v:get().m_DamageByMagicCircle:ForEach(function(idx, e) e:get().m_Damage = x end)  -- idx 1=c2,2=c4,3=c6
end)
-- non-damage fields are plain scalars: cdo.m_Field = value
```

Vanilla is snapshotted once (`_G.__MB_vanilla`); target = `vanilla × factor` (or absolute
values from config). Applied via a startup retry loop + re-applied ~4s after each
`ClientRestart`. Idempotent.

**Crash rules (uncatchable C++ — pcall can't catch):**
- NEVER read/`:get()`/`:ToString()` the map **KEY** (FGameplayTag) → instant crash. Only use values.
- NEVER `unwrap()`/`:get()` a directly-read object field — only hook params. Read fields directly + pcall.
- A spell can match a non-definition object (rune/ability) whose `m_DamageBase` iteration crashes →
  that's why `mb_try`/`mb_fields` are read-only and `mb_fields` never iterates maps.

## Config
`Scripts/config.lua → Spells` — one block per spell: `{ class, damage, fields?, enabled? }`.
`damage` = number (factor) or `{ base, c2, c4, c6 }` (absolute). `_Lvl1/2/3` covered automatically.

## Known spell definition classes
| Spell | class | vanilla base | notes |
|---|---|---|---|
| Feuerpfeil | `FireBoltProjectileDefinition` | 35 (c2/4/6 40/50/65) | not chargeable |
| Feuerball | `FireBallProjectileDefinition` | 60/90/120 (`_Lvl1/2/3`) | chargeable |
| Kugelblitz | `BallLightningDefinition` | 50/70/90 (`_Lvl1/2/3`; `_Base` empty) | chargeable |
| Eispfeil | `IceBoltProjectileDefinition` | 20 (c2/4/6 30/40/50) | |
| Feuerregen | `FireRainDefinition` | 45 (flat, NO circle progression) | AoE; `m_XOffset/m_YOffset` = rain area, `m_LifeTime`, `m_Probability` |

Discover more: cast the spell → `[SPELL] <class>` in UE4SS.log, or `mb_try <name>` / `mb_fields <name>`.

## Open / next
- **Blitz** ("lachhaft") — capture its class, then add (likely a projectile).
- **Non-projectile spells**: Todeshauch (breath cone), Windfaust/Sturmfaust (fist), Eiswelle.
  They don't use a `*ProjectileDefinition` with `m_DamageBase` → separate path (find their
  damage source). Todeshauch also wants a damage-type fix (counts as wind) — deferred.
- **Cast time / mana**: in `USpellConfig.m_SpellLevels` (FSpellLevelRange) — different object, not done.
- FireRain rain-pattern fields (`m_Probability` 2, `m_Min/Max` 0/100, `m_Key/Key2` 2/4) —
  effect not yet visually confirmed; `m_Key/Key2` look like circle breakpoints (leave alone).

## Test loop
Edit `G1R_MageBalance/Scripts/*` → copy to `…\Win64\ue4ss\Mods\G1R_MageBalance\Scripts\` →
restart (hot-reload off) → cast / `mb_status` → read `…\Win64\ue4ss\UE4SS.log`. Install path:
`C:\Program Files (x86)\Steam\steamapps\common\Gothic 1 Remake\G1R\Binaries\Win64`.
(Recent UE4SS uses the `ue4ss\` subfolder; older builds were flat: `…\Win64\Mods\` + `…\Win64\UE4SS.log`.)
