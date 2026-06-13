# Mage Balance — Recon

Ziel: Zauberschaden zur Laufzeit idempotent & save-safe patchen (Rich-Merchants-Muster).
Diese Phase **ändert nichts** — sie liest nur und schreibt in `UE4SS.log`.

## ✅ Phase 1 (erledigt) — Schadensmodell identifiziert
Aus dem CXX-Header-Dump (2026-06-12):
- **Projektil-Zauber** (Blitz, Feuerball, Eispfeil, Feuerregen, Kugelblitz):
  Klasse **`USpellProjectileDefinition`**, Feld
  `m_DamageMagicCircleProgression` = `TMap<DamageTypeTag, { CircleTag -> float m_Damage }>`.
  Setter vorhanden: `AddDamageForMagicCircle(DamageTag, MagicCircleTag, DamageValue)`.
- **Pro Rune**: `FRuneStats { DamageByLevel[], DamageType(Tag), ... }` — `DamageType`
  ist das Feld für den späteren Todeshauch-Wind-Fix.

Offen: die echten **Zahlenwerte** + Zuordnung Definition→Zauber. → Phase 2.

## Phase 2 — Live-Werte auslesen
1. Ordner `G1R_MageBalance` nach
   `…\Gothic 1 Remake\G1R\Binaries\Win64\Mods\` kopieren (neben `RichMerchants`).
   Die leere `enabled.txt` aktiviert die Mod. **ConsoleEnablerMod** muss aktiv sein.
2. Spiel starten, **Magier-Save laden**, in der offenen Welt stehen.
3. **Jeden Zauber einmal wirken** (Blitz, Feuerball, Eispfeil, Feuerregen, Kugelblitz,
   Todeshauch …), damit die Definition-Objekte im Speicher sind.
4. Konsole öffnen und ausführen:
   - **`mb_spells`** — Hauptbefehl: liest alle `SpellProjectileDefinition`-Schadensmaps
     und loggt pro Zauber `dmgType / circle / damage`.
   - `mb_dumpfirst` — Backup: dumpt alle Properties der Kandidatenklassen.
   - `mb_dump <Klasse>` / `mb_find <Klasse>` — gezielt eine Klasse.
5. `UE4SS.log` liegt in `…\Win64\` — sag „fertig", ich lese sie direkt aus.

## Phase 3 — Apply-Pass bauen
Aus den Live-Werten: Multiplikator auf Vanilla-Default pro (Zauber, Kreis), nur erhöhen,
idempotent über Saves/Kapitelwechsel. Vermutlich via `AddDamageForMagicCircle`-Aufruf
oder direktem Map-Write — entscheidet sich nach den Werten aus Phase 2.

Geplante Multiplikatoren (DaddyKickem-Feedback, in `config.lua`):
Blitz 2.5× · Todeshauch 2.0× · Feuerregen 1.8× · Eispfeil/Feuerball 1.5× ·
Kugelblitz +10 flat · Eiswelle/Windfaust/Sturmfaust unangetastet.
