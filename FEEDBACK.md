# Community Feedback — G1R Mage Balance

Gesammeltes Feedback aus **Nexus-Kommentaren** (Stand 14 Jun 2026, mods-Seite) und dem
**Discord-Thread** (PawlikRole / DaddyKickem u.a.). Sortiert nach Thema, mit Usernamen,
ehrlichem Machbarkeits-Verdict und To-do. Unten ein fertiger Text zum öffentlichen Posten.

**Machbarkeits-Legende**
- ✅ **EASY** — reiner Config-Wert, unser Kerngeschäft (Schaden, manche `fields`). Sofort.
- 🔧 **NEW FEATURE** — technisch erreichbar, muss aber gebaut werden (Mana/Castzeit via `USpellConfig`; Stun via `m_SuperArmorDamageBase`).
- ⚠️ **HARD/RISKY** — evtl. möglich, aber komplex/riskant (Bewegen beim Casten, Projektil-Durchschlag, Gegner-Resistenzen pro Typ).
- ❌ **NOT FEASIBLE** — außerhalb Scope eines Lua-Laufzeit-Mods oder Engine-limitiert.

---

## 1. Schaden-Anpassungen — ✅ EASY (unser Kern)

| Thema | Wer | Verdict |
|---|---|---|
| Pyrokinese macht 0 Schaden → buffen | nightseen, Pig01, (DC: zuřivost) | ✅ haben wir (×2.5); ggf. nachjustieren |
| Fire Storm denerf (nicht auf 1.0-OP) | Guurzak, Kerathras, Sharod1337 | ✅ haben wir (×1.2 / 240) |
| Eis-Zauber zu schwach (außer Ice Wave) | Sharod1337, nightseen | ✅ Eispfeil schon auf Firebolt-Parität |
| 6th-Circle / Endgame-Zauber schwächer als OG | Sharod1337 | ✅ Todeshauch ×2, Feuerregen ×2.5 |
| Firebolt zu stark / überstrahlt früh alles | Pig01 (DC: Pawlik) | ✅ K1 35→30; per-Circle weiter dämpfbar |
| Rain of Fire mehr Schaden | Pig01 | ✅ haben wir |
| Wind-Zauber Schaden auf Niveau (etwas drunter, da CC) | Giorotto | ✅ sobald Klassennamen erfasst (Sturmfaust/Windfaust) |

**To-do:** konkrete Zielzahlen finalisieren; Sturmfaust/Windfaust-Klassennamen erfassen.

## 2. Per-Circle-Werte für ALLE Zauber im Config — ✅ EASY (schon unterstützt)

| Thema | Wer | Verdict |
|---|---|---|
| Per-Circle-Breakdown für jeden Zauber (`{base,c2,c4,c6}`) | **CycloLocke** (zitiert unsere config-Syntax!) | ✅ System kann das bereits — nur mehr Zauber-Blöcke freischalten |
| Zauber sollen +X% pro Circle skalieren | reyevan, Azzinoth224 | ✅ Vanilla skaliert schon an C2/C4/C6; wir skalieren jeden Breakpoint |
| Niedrige Circles spät nutzlos werden lassen (Variety) | Pig01 | ✅ exakt unsere „pro Kapitel mehr"-Philosophie: Firebolt/Eispfeil per-Circle absenken |

**To-do:** alle abgedeckten Zauber als per-Circle-Block in `config.lua` ausstellen (nicht nur Faktor), damit User selbst pro Circle tunen können — direkt von CycloLocke gewünscht.

## 3. Manakosten & Castzeit — 🔧 NEW FEATURE (`USpellConfig`)

| Thema | Wer | Verdict |
|---|---|---|
| Castzeit für Zauber änderbar? | **DarkSedd**, Kaskur, loikm | 🔧 `USpellConfig.m_SpellLevels.CastTime` — erreichbar, noch nicht gebaut |
| Voll-aufgeladenen Cast ~halbieren | Kaskur | 🔧 dito |
| Charge-Animation Fireball schneller | loikm | 🔧 dito |
| Mana/sec, Kanalzeit-Formeln | sweetpoison11 | 🔧 Mana = `CastManaCost` im selben Objekt |
| „buff aber teurer", Mana als Balance-Hebel | (DC: Pawlik — Stormfist 3→15, Ice Wave →20, Ice block →5) | 🔧 Mana-Editing |

**To-do (Top-Prio Feature):** `USpellConfig`-Support bauen → **Mana + Castzeit** pro Zauber/Level. Schaltet ~halbes Feedback frei. Bestes ROI.

## 4. Bewegen beim Casten / Kamera-Lock — ⚠️ HARD/RISKY

| Thema | Wer | Verdict |
|---|---|---|
| Beim Casten laufen (Fireball, Pyro, stationäre Zauber) | **Pig01, HardmodeFan, loikm, Metafomus** (DC: Pawlik) | ⚠️ Movement-Lock liegt in Ability-Logik; an/aus evtl. machbar, „gehen ab K4 / rennen ab K5" sehr fummelig |
| Kamera-Lock beim Casten entfernen | loikm | ⚠️ wie oben |
| Bewegungsspeed auf Bogen-Niveau beim Casten | HardmodeFan | ⚠️ wie oben |

**To-do:** als Recon-Spike markieren — prüfen ob ein simples „Root/Lock aus" pro Zauber reicht. Wenn riskant: ehrlich kommunizieren, dass es kein reiner Zahlen-Mod-Fix ist.

## 5. Spell-Interaktionen / Synergien — ❌ meist NOT FEASIBLE

| Thema | Wer | Verdict |
|---|---|---|
| Gefrorene mit Wind „shattern" für Massiv-Schaden | Azzinoth224 | ⚠️ evtl. — Blunt-vs-Frozen-Mechanik existiert schon (CycloLocke bestätigt); Wind dranzuhängen wäre der ehrlichste Versuch |
| Pyrokinese auf brennende Gegner → Bonus/Rüstungsdurchschlag | Azzinoth224 | ❌ keine „Bonus vs burning"-/Armor-Reduktions-Mechanik im Spiel (CycloLocke) |
| Blitz stunt länger / mehr Schaden vs nasse Gegner | Azzinoth224 | ❌ keine „wet"-Mechanik vorhanden |

**Hinweis:** CycloLocke (Modder) und nightseen sagen selbst, das geht über reines Zahlen-Tuning hinaus. **Ehrlich kommunizieren:** wo eine Mechanik schon existiert (Frozen-Shatter) lohnt ein Versuch; wo nicht (burning/wet), ist es realistisch nicht machbar.

## 6. Projektil-Verhalten / AoE — ⚠️ gemischt

| Thema | Wer | Verdict |
|---|---|---|
| Kugelblitz Kollision entfernen → durch mehrere Gegner | Pig01 | ⚠️ evtl. via Kollisions-Flag; testen, riskant |
| AoE-Reichweite/Fläche größer (Rain, Ice Wave, Fist) | Pig01 | ✅/⚠️ Fläche geht für manche (`m_XOffset/m_YOffset`, machen wir bei Feuerregen); pro Zauber prüfen |
| Stun/Knockback austarieren (Stormfist/Ice Wave Stunlock) | (DC: Pawlik) | 🔧 `m_SuperArmorDamageBase` (Stormfist = 250!) editierbar |
| Gegner stehen nur auf statt zu sterben (kein Finisher) | Sharod1337 (DC: zuřivost, Pawlik) | ⚠️ Stagger/Tod-Logik; teils über Schaden lösbar, „richtiger Finisher" hart |

## 7. Chain Lightning (Blitz) — ⚠️ HARD (zurückgestellt)

| Thema | Wer | Verdict |
|---|---|---|
| Blitz „atrocious", macht mehr Schaden an dir selbst | **Kerathras**, Giorotto, (DC: zuřivost) | ⚠️ Strahl, kein Projektil-Def; Schaden steckt in einem `GameplayEffect` (verschachtelt, crash-anfällig) — in `TODO.md` zurückgestellt |

**To-do:** bleibt deferred bis `USpellConfig`/GE-Editing steht. Sehr häufig gewünscht → mittelfristig priorisieren.

## 8. Gegner-Resistenzen — ⚠️ HARD/RISKY

| Thema | Wer | Verdict |
|---|---|---|
| Skelette resistent gegen Feuer (Rain of Fire mau im Tempel) | (DC: Pawlik) | ⚠️ Resistenz liegt gegnerseitig; pro Gegner-Typ aufwendig & riskant |
| „Destroy undead should destroy undead" (keine Resistenz) | AbyssianOne (DC) | ⚠️ wie oben |
| Bosse stun-immun machen | (DC: Pawlik) | ⚠️ pro-Ziel-Logik, schwer |

## 9. Außerhalb Scope — ❌ (andere/größere Mod)

| Thema | Wer | Verdict |
|---|---|---|
| Heilungs-Rune Tick beschleunigen (5→10/Tick) | nightseen | 🔧/❌ *evtl.* eigener Def — prüfenswert, aber kein Schaden-Thema |
| Guru-Klasse zurückbringen | Wulcy | ❌ Content/Progression |
| Stäbe für Magier + führbar machen | wiktor917 | ❌ Item/Content-Mod |
| Mage-Outfit Rüstungswerte, Level-up-Boni (Glass Cannon) | sweetpoison11 | ❌ Robe-Mod existiert; Progression deferred |
| Gilden-gebundene Magie / wer lehrt welchen Circle / Firebolt durch Windfaust ersetzen | (DC: Pawlik) | ❌ tiefe Dialog-/Quest-/Progressions-Logik — separate, viel größere Mod, kein Lua-Damage-Mod |
| Schmiede-Bonus für selbstgeschmiedete Waffen | (DC: zuřivost) | ❌ komplett anderes System |

## 10. Support-Fragen (FAQ-Material, schon beantwortet)

| Frage | Wer | Antwort |
|---|---|---|
| Pfad `\Mods\` vs `\ue4ss\Mods\`? | Uneasyboosh | hängt von UE4SS-Version ab — wo deine anderen Mods liegen, dort hin (opogode/tailwindtom) |
| Konflikt mit NoviceWaterMage? | oldfarmer | `FixDamage=false` in NoviceWaterMage.ini — *oder* warten, die Mods werden ggf. gemerged (CycloLocke/tailwindtom) |

---

## Priorisierter Fahrplan (Vorschlag)

1. **Jetzt (✅ EASY):** Schaden-/Stun-Feintuning aus dem Feedback; alle abgedeckten Zauber als **per-Circle-Block** im Config ausstellen (CycloLocke-Wunsch).
2. **Nächstes Feature (🔧):** **`USpellConfig` → Mana + Castzeit.** Größter Hebel, deckt #3 komplett + Teile von #6 ab.
3. **Recon-Spike (⚠️):** „Movement-Lock aus" pro Zauber prüfen (#4) — wenn machbar, riesiger gefühlter Gewinn.
4. **Mittelfristig:** Chain Lightning (GE-Editing), AoE-Flächen pro Zauber, Frozen-Shatter-Versuch.
5. **Dokumentieren als „nicht geplant":** Gilden-/Progressions-Umbau, Stäbe, Guru, Schmiede.

---

## 📣 Öffentliches Statement (copy-paste, EN — z.B. Nexus Sticky / Pinned Comment)

> **Thanks for all the feedback — here's what's realistic and what isn't.** I'm keeping this honest so nobody's expectations get set wrong. This is a runtime Lua mod: I can re-tune *values* the game already has; I can't add brand-new mechanics.
>
> **✅ Can do now (value tuning):** per-spell damage, and **per-circle** values for every spell (so you can make low circles fall off late — exactly what several of you asked for). Pyrokinesis, Fire Storm, Chain Lightning damage, Ice spells, Wind spells, Rain of Fire — all tunable. The config already supports `{ base, c2, c4, c6 }` per spell (thanks CycloLocke for spelling it out).
>
> **🔧 Coming (being built):** **mana cost and cast/charge time** per spell — this unlocks a lot of your requests (DarkSedd, Kaskur, loikm, and the "raise mana / lower damage" balance asks). Also stun/knockback tuning (Storm Fist & Ice Wave stunlock).
>
> **⚠️ Maybe / experimental:** **moving while casting** (Pig01, HardmodeFan, Metafomus) — this isn't a simple number, it lives in the ability logic, so no promises, but I'll investigate. Same for ball-lightning pierce and bigger AoE areas. **Chain Lightning** is on the list but lives in a trickier place than the other spells.
>
> **❌ Realistically not possible in this kind of mod:** brand-new **spell interactions** that the game has no mechanic for (e.g. bonus damage vs *burning* enemies, "wet" enemies) — the frozen-shatter case *might* work since that mechanic already exists. Also out of scope: the **Guru class**, **mage staffs**, **guild-gated magic / who-teaches-what / progression redesign**, mage armor/level-up overhauls, and smithing — those would each be a separate, much bigger mod, not a spell-balance tweak.
>
> The whole point is that **you can tune it yourself** — one readable block per spell in `config.lua`. PRs and suggestions welcome on GitHub. Keep it coming! 🔥🧙
