# Balance Sheet — G1R Mage Balance

Every change the mod makes, vanilla → modded, at a glance. Values are applied at
runtime (no game files touched). **Vanilla = patch 1.01.** Damage is shown as
`base / 2nd / 4th / 6th circle` where a spell scales per circle, or a single flat
number otherwise.

**Legend:** 🔼 buff · 🔽 nerf · ⚙️ utility/other · `=` unchanged

| Circle | Spell | Damage (vanilla → mod) | Mana (v → mod) | Cast / Charge (v → mod) | What changed |
|:--:|---|---|---|---|---|
| 1 | **Firebolt** | 35/40/50/65 → **30**/40/50/65 | `=` 1 | `=` 0.1s | 🔽 1st-circle toned down (too strong early) |
| 1 | **Ice Arrow** | 20/30/40/50 → **35/40/50/65** | `=` 1 | `=` 0.1s | 🔼 raised to Firebolt parity |
| 2 | **Fist of Wind** | 20/30/40/50 → **40/60/80/100** | `=` 2 | `=` instant | 🔼 ×2 damage (CC spell) |
| 3 | **Fireball** *(charge)* | 60/90/120 → **105/158/210** | ×1.25 | **×0.7 (faster)** | 🔼 +75% dmg · ⚙️ faster charge · 🔽 +mana |
| 3 | **Ball Lightning** *(charge)* | `=` 50/70/90/120 | ×1.25 | **×0.7 (faster)** | ⚙️ projectile speed 300-450 → **800** · faster charge · 🔽 +mana |
| 3 | **Pyrokinesis** | 20 → **50** | `=` 5 | `=` 0.5s | 🔼 ×2.5 (dealt ~0 damage) |
| 3 | **Ice Block** | `=` 60/80 | `=` 3 | `=` 0.2s | `=` untouched |
| 4 | **Storm of Fire** | 200/250 → **240/300** | 35 → **30** | `=` 0.5s | 🔼 +20% dmg · 🔽 slightly cheaper |
| 4 | **Storm Fist** | `=` 120/160 | 3 → **15** | `=` 0.5s | 🔽 mana fixed (3 mana for an AoE + stun was absurd) |
| 4 | **Chain Lightning** | 10/25 → **60/90** | `=` 5 | `=` 0.5s | 🔼 fixed — was laughably weak |
| 5 | **Fire Rain** | 45 → **112.5** | 20 → **30** | `=` 0.1s | 🔼 ×2.5 dmg · ⚙️ bigger area (800 → 1600) · 🔽 +mana |
| 5 | **Ice Wave** | `=` 120/150 | 8 → **20** | `=` 0.2s | 🔽 mana fixed (stunlock was too cheap) |
| 5 | **Destroy Undead** | 500 → **999** | 25 → **30** | `=` 0.5s | 🔼 Gothic-2-style 999 |
| 6 | **Uriziel** | 90 → **300** | `=` 40 | `=` 0.3s | 🔼 endgame finale now hits hardest |
| 6 | **Breath of Death** | 150 → **300** | 5 → **40** | `=` 0.5s | 🔼 ×2 dmg · 🔽 now appropriately expensive |

### Notes

- **Damage models differ — don't read the raw number as power.** AoE / damage-over-time /
  channel / cone spells hit **multiple times and/or multiple targets**, so their real output
  is far above the single number. *Fire Rain* (112.5 per tick) rains over a large area many
  times → it is the strongest AoE despite the low per-hit number. *Storm of Fire*, *Ice Wave*,
  *Storm Fist*, *Breath of Death* are AoE/cone; *Chain Lightning* and *Pyrokinesis* channel.
- **Charge spells** (Fireball, Ball Lightning) list mana/charge as a multiplier because the
  value differs per charge level. "×0.7 charge" = each charge stage fills ~30% faster.
- **Firebolt / Ice Arrow are intentionally left cheap and efficient** — they're the bread-and-
  butter early spells. Later spells win through area, burst, range and crowd control, not raw
  mana-efficiency.
- **Chapter progression goal:** newer-circle spells out-perform older ones, and the 6th-circle
  finales (Uriziel, Breath of Death) top the chart — fixing vanilla's "Firebolt until the end".
- Mana values are tuned conservatively and may still change with player feedback — a too-cheap
  spell is easier to fix than a too-expensive one.

*Want different numbers? Everything here is one readable block per spell in
[`Scripts/config.lua`](G1R_MageBalance/Scripts/config.lua). Use the `mb_scanall` and
`mb_spellcfg` console commands to see every spell's live values.*
