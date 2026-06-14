# Community Feedback — G1R Mage Balance

Collected player feedback from **Nexus comments** (as of 14 Jun 2026) and the **Discord
thread**. Grouped by topic, with usernames, an honest feasibility verdict, and a to-do per
item. A ready-to-post public statement is at the bottom.

**Feasibility legend**
- ✅ **EASY** — pure config value, our core (damage, some `fields`). Available now.
- 🔧 **NEW FEATURE** — technically reachable, but has to be built (mana / cast time via `USpellConfig`; stun via `m_SuperArmorDamageBase`).
- ⚠️ **HARD/RISKY** — maybe possible, but complex/risky (moving while casting, projectile pierce, per-enemy resistances).
- ❌ **NOT FEASIBLE** — out of scope for a runtime Lua mod, or engine-limited.

---

## 1. Damage tuning — ✅ EASY (our core)

| Topic | Who | Verdict |
|---|---|---|
| Pyrokinesis deals ~0 damage → buff | nightseen, Pig01, (DC) | ✅ done (×2.5); can tune further |
| Fire Storm de-nerf (not back to 1.0 OP) | Guurzak, Kerathras, Sharod1337 | ✅ done (×1.2 / 240) |
| Ice spells too weak (except Ice Wave) | Sharod1337, nightseen | ✅ Ice Arrow now at Firebolt parity |
| 6th-circle / endgame spells weaker than OG | Sharod1337 | ✅ Death Breath ×2, Fire Rain ×2.5 |
| Firebolt too strong / overshadows everything early | Pig01, (DC) | ✅ Circle-1 35→30; can dampen per-circle further |
| Rain of Fire more damage | Pig01 | ✅ done |
| Wind spells damage up to par (a bit lower, since CC) | Giorotto | ✅ once class names are captured (Storm Fist / Fist of Wind) |

**To-do:** finalize target numbers; capture Storm Fist / Fist of Wind class names.

## 2. Per-circle values for ALL spells in config — ✅ EASY (already supported)

| Topic | Who | Verdict |
|---|---|---|
| Per-circle breakdown for every spell (`{base,c2,c4,c6}`) | **CycloLocke** (quoted our config syntax!) | ✅ system already supports it — just expose more spell blocks |
| Spells should scale +X% per circle | reyevan, Azzinoth224 | ✅ vanilla already scales at C2/C4/C6; the mod scales each breakpoint |
| Make low circles fall off late-game (variety) | Pig01 | ✅ exactly our "newer chapters hit harder" philosophy: lower Firebolt/Ice Arrow per-circle |

**To-do:** expose every covered spell as a per-circle block in `config.lua` (not just a factor) so users can tune per circle — directly requested by CycloLocke.

## 3. Mana cost & cast time — 🔧 NEW FEATURE (`USpellConfig`)

| Topic | Who | Verdict |
|---|---|---|
| Can cast time be changed? | **DarkSedd**, Kaskur, loikm | 🔧 `USpellConfig.m_SpellLevels.CastTime` — reachable, not built yet |
| Halve fully-charged cast time | Kaskur | 🔧 same |
| Speed up Fireball charge animation | loikm | 🔧 same |
| Mana/sec, channel-time formulas | sweetpoison11 | 🔧 mana = `CastManaCost`, same object |
| "buff but pricier", mana as a balance lever | (DC: Storm Fist 3→15, Ice Wave →20, Ice block →5) | 🔧 mana editing |

**To-do (top-priority feature):** build `USpellConfig` support → **mana + cast time** per spell/level. Unlocks ~half the feedback. Best ROI.

## 4. Moving while casting / camera lock — ⚠️ HARD/RISKY

| Topic | Who | Verdict |
|---|---|---|
| Move while casting (Fireball, Pyro, stationary spells) | **Pig01, HardmodeFan, loikm, Metafomus**, (DC) | ⚠️ movement lock lives in the ability logic; toggling on/off maybe doable, "walk at C4 / run at C5" very fiddly |
| Remove camera lock while casting | loikm | ⚠️ same |
| Move speed on par with bow while casting | HardmodeFan | ⚠️ same |

**To-do:** flag as a recon spike — check whether a simple "root/lock off" per spell is enough. If risky, communicate honestly that it's not a pure number tweak.

## 5. Spell interactions / synergies — ❌ mostly NOT FEASIBLE

| Topic | Who | Verdict |
|---|---|---|
| Shatter frozen enemies with wind for massive damage | Azzinoth224 | ⚠️ maybe — a blunt-vs-frozen mechanic already exists (confirmed by CycloLocke); hanging wind off it is the honest attempt |
| Pyrokinesis on burning enemies → bonus dmg / armor pen | Azzinoth224 | ❌ no "bonus vs burning" / armor-reduction mechanic in the game (CycloLocke) |
| Lightning stuns longer / more damage vs wet enemies | Azzinoth224 | ❌ no "wet" mechanic exists |

**Note:** CycloLocke (a modder) and nightseen say themselves this goes beyond number tuning. **Communicate honestly:** where a mechanic already exists (frozen-shatter) it's worth a try; where it doesn't (burning/wet), it's realistically not doable.

## 6. Projectile behavior / AoE — ⚠️ mixed

| Topic | Who | Verdict |
|---|---|---|
| Remove Ball Lightning collision → pass through enemies | Pig01 | ⚠️ maybe via a collision flag; needs testing, risky |
| Bigger AoE range/area (Rain, Ice Wave, Fist) | Pig01 | ✅/⚠️ area works for some (`m_XOffset/m_YOffset`, as on Fire Rain); check per spell |
| Tune stun/knockback (Storm Fist / Ice Wave stunlock) | (DC) | 🔧 `m_SuperArmorDamageBase` (Storm Fist = 250!) is editable |
| Enemies just stand up instead of dying (no finisher) | Sharod1337, (DC) | ⚠️ stagger/death logic; partly solvable via damage, a real "finisher" is hard |

## 7. Chain Lightning (Blitz) — ⚠️ HARD (deferred)

| Topic | Who | Verdict |
|---|---|---|
| Chain Lightning "atrocious", hurts you more than the enemy | **Kerathras**, Giorotto, (DC) | ⚠️ it's a ray, no projectile def; damage lives in a `GameplayEffect` (nested, crash-prone) — deferred in `TODO.md` |

**To-do:** stays deferred until `USpellConfig`/GE editing exists. Very frequently requested → prioritize medium-term.

## 8. Enemy resistances — ⚠️ HARD/RISKY

| Topic | Who | Verdict |
|---|---|---|
| Skeletons resist fire (Rain of Fire weak in the temple) | (DC) | ⚠️ resistance is on the enemy side; per enemy type is costly & risky |
| "Destroy undead should destroy undead" (no resistance) | (DC) | ⚠️ same |
| Make bosses stun-immune | (DC) | ⚠️ per-target logic, hard |

## 9. Out of scope — ❌ (a different / much bigger mod)

| Topic | Who | Verdict |
|---|---|---|
| Speed up healing-rune tick (5→10/tick) | nightseen | 🔧/❌ *maybe* its own def — worth checking, but not a damage topic |
| Bring back the Guru class | Wulcy | ❌ content/progression |
| Staffs for mages + ability to wield them | wiktor917 | ❌ item/content mod |
| Mage outfit armor values, level-up bonuses (glass cannon) | sweetpoison11 | ❌ a robe mod exists; progression deferred |
| Guild-gated magic / who-teaches-which-circle / replace Firebolt with Fist of Wind | (DC) | ❌ deep dialogue/quest/progression logic — a separate, far bigger mod, not a Lua damage mod |
| Self-forged weapon smithing bonus | (DC) | ❌ a completely different system |

## 10. FAQ (recurring questions)

| Question | Answer |
|---|---|
| Install path `\Mods\` vs `\ue4ss\Mods\`? | Depends on the UE4SS version — put it where your other UE4SS mods already live. |
| Conflict with NoviceWaterMage? | Set `FixDamage=false` in `NoviceWaterMage.ini` — or wait, the two mods may be merged. |

---

## Prioritized roadmap (proposal)

1. **Now (✅ EASY):** damage/stun fine-tuning from the feedback; expose every covered spell as a **per-circle block** in config (CycloLocke's ask).
2. **Next feature (🔧):** **`USpellConfig` → mana + cast time.** Biggest lever, covers #3 fully + parts of #6.
3. **Recon spike (⚠️):** check "movement lock off" per spell (#4) — if doable, a huge felt improvement.
4. **Medium-term:** Chain Lightning (GE editing), per-spell AoE areas, the frozen-shatter attempt.
5. **Document as "not planned":** guild/progression overhaul, staffs, Guru, smithing.

---

## 📣 Public statement (copy-paste, e.g. Nexus sticky / pinned comment)

> **Thanks for all the feedback — here's what's realistic and what isn't.** I'm keeping this honest so nobody's expectations get set wrong. This is a runtime Lua mod: I can re-tune *values* the game already has; I can't add brand-new mechanics.
>
> **✅ Can do now (value tuning):** per-spell damage, and **per-circle** values for every spell (so you can make low circles fall off late — exactly what several of you asked for). Pyrokinesis, Fire Storm, Chain Lightning damage, Ice spells, Wind spells, Rain of Fire — all tunable. The config already supports `{ base, c2, c4, c6 }` per spell (thanks CycloLocke for spelling it out).
>
> **🔧 Coming (being built):** **mana cost and cast/charge time** per spell — this unlocks a lot of your requests (DarkSedd, Kaskur, loikm, and the "raise mana / lower damage" balance asks). Plus stun/knockback tuning (Storm Fist & Ice Wave stunlock).
>
> **⚠️ Maybe / experimental:** **moving while casting** (Pig01, HardmodeFan, Metafomus) — this isn't a simple number, it lives in the ability logic, so no promises, but I'll investigate. Same for ball-lightning pierce and bigger AoE areas. Chain Lightning is on the list but sits in a trickier place than the other spells.
>
> **❌ Realistically not possible in this kind of mod:** brand-new **spell interactions** the game has no mechanic for (e.g. bonus damage vs *burning* or *wet* enemies) — though the frozen-shatter case *might* work since that mechanic already exists. Also out of scope: the **Guru class**, **mage staffs**, **guild-gated magic / progression redesign**, mage armor & level-up overhauls, and smithing — each would be a separate, much bigger mod, not a spell-balance tweak.
>
> The whole point is that **you can tune it yourself** — one readable block per spell in `config.lua`. PRs and suggestions welcome on GitHub. Keep it coming! 🔥🧙
