# Mage Balance — Zwischenstand / Handoff (Stand: 2026-06-13)

## TL;DR — die Mechanik funktioniert ✅
FireBolt (Feuerpfeil) macht in-game skalierten Schaden, **stabil, kein Crash**.
Der Schreib-Weg über die Zauber-Definition (`m_DamageBase`) ging nicht; der
funktionierende Weg ist **Ziel-`DamageMultiplier` beim Treffer**.

## Wie es funktioniert (final)
Beim Treffer eines Spieler-Spell-Projektils:
1. Hook **`/Script/G1R.ProjectileVisual:OnHitServer`** feuert. `self` = Projektil-Actor
   (`BP_Firebolt_C`). Dessen Felder: `m_ProjectileDefinition` (→ Zauber erkennen),
   `Instigator`/`Owner` (→ „vom Spieler" prüfen).
2. **arg #2** des Hooks = der getroffene Actor (Gegner).
3. Nur fortfahren wenn Klassenname „Character" enthält (sonst Treffer auf Deko/Props
   wie `AlkimiaLightweightDecorationActor` → `m_CharacterState`-Read crasht hart).
4. Gegner → `m_CharacterState` (GothicNPCState) → Key `State_..._NNN` extrahieren →
   `FindAllOf("AttributeSet_Health")`, passenden Holder per Key finden (gecacht).
5. Dessen **`DamageMultiplier`** (GAS-Attribut, Struct mit `BaseValue`/`CurrentValue`)
   auf `vanilla × Faktor` setzen (direkter Struct-Write + Readback-Verify — kein
   ImportText nötig), nach **600 ms** via `ExecuteWithDelay` zurücksetzen.
   → nur dieser eine Treffer ist skaliert.

Code: `Scripts/main.lua`, Abschnitt „WEG B". Faktoren: `Scripts/config.lua` →
`SpellDamageByClass` (Klassenname-Substring → Multiplikator).

## Harte Crash-Regeln (gelernt — pcall fängt C++-Crashes NICHT)
1. **Nie `unwrap()`/`:get()` auf einem direkt gelesenen Objekt-Feld** — nur auf
   Hook-Parametern (self, varargs). Felder direkt lesen + `GetFullName` in pcall
   (`field_fullname`).
2. Ein Projektil trifft **alles** mit Kollision (Deko, Fässer). `m_CharacterState`
   auf Nicht-Charakter = harter Crash → erst `class_name:find("Character")` prüfen.
3. Dev-Hilfe: `config.DebugSteps=true` schaltet `[DBG]`-Breadcrumbs vor jeden
   riskanten Engine-Call → letzte `[DBG]`-Zeile vor dem Crash = die Schuld-Zeile.

## So fügst du einen Zauber hinzu
1. `config.lua`: `Verbose=true` (Standard). In-game den Zauber **einmal casten**.
2. `UE4SS.log`: Zeile `SPELL <Name>ProjectileDefinition /Script/Angelscript...` →
   den markanten Namens-Teil nehmen (z. B. `Fireball`, `IceArrow`).
3. In `SpellDamageByClass` eine Zeile ergänzen: `Fireball = 1.5,`. Fertig
   (Substring-Match auf den Klassennamen, case-sensitiv).

## Bekannte Zauber-Klassen (bisher)
- `FireBolt` → Feuerpfeil (m_DamageBase m_Damage = 35; in vanilla ok)
- `BallLightning` → Kugelblitz (m_DamageBase LEER — Schaden woanders; OnHitServer-
  Skalierung greift evtl. trotzdem, sobald BallLightning wirklich trifft → testen)

## Was noch offen ist
- **Andere Zauber erfassen**: Blitz, Feuerball, Eispfeil, Feuerregen … Klassennamen
  fehlen (brauchen die Runen im Save). Werte dann nach DaddyKickem eintragen.
- **Nicht-Projektil-Zauber** (Todeshauch = Atem-Kegel, Sturm-/Windfaust): feuern
  `OnHitServer` vermutlich nicht → eigener Hook/Pfad. Separates Thema.
- **Kugelblitz**: `m_DamageBase` leer — prüfen ob OnHitServer beim echten Treffer
  greift; falls nicht, Schadenspfad gesondert finden.
- **Release-Putz**: `DebugSteps=false` (erledigt), tote Recon-Funktionen entfernt
  (erledigt). Ggf. Konsolenbefehle (`mb_*`) behalten — harmlos, nützlich.
- **AoE/Mehrfachtreffer**: DamageMultiplier wirkt im 600-ms-Fenster auf ALLE
  eingehenden Quellen des Ziels (minimaler Nebeneffekt; akzeptabel).

## Test-Loop & Pfade
Edit `G1R_MageBalance/G1R_MageBalance/Scripts/*` → nach
`…\Gothic 1 Remake\G1R\Binaries\Win64\Mods\G1R_MageBalance\Scripts\` kopieren →
**Spiel neu starten** (Hot-Reload aus) → casten/treffen → `…\Win64\UE4SS.log`.
Konsole (ConsoleEnablerMod): `mb_spells`, `mb_dumpfirst`, `mb_dump <Klasse>`.
