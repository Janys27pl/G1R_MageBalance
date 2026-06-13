# Nexus Mods — release text

## Title
**Mage Balance** *(recommended)* — alt: *Mage Balance — Spell Rebalance (Early Access)*

## Short description (plain text, 339 / 350 chars)
Early rebalance of Gothic 1 Remake mage spells. Released early on purpose to gather feedback, so expect frequent changes and a long to-do list. The big fixes are already in: a devastating Fire Rain (bigger area and more damage) and a stronger Fireball, plus Death Breath, Ice Arrow, Pyrokinesis and more. Feedback and contributors welcome!

---

# Description page (per Nexus field)

## Description
[b]Mage Balance rebalances Gothic 1 Remake's mage spells so casting stays viable.[/b] In the original, several spells fall off hard and feel laughably weak by mid/late game. This mod boosts their damage (and a few other stats) at runtime — [b]no game files are modified[/b], it's fully save-safe, and every spell is configurable in one tidy file.

[b]⚠ Early version.[/b] This is released early on purpose to gather feedback, so expect frequent changes and a long to-do list. But the most important fixes are already in — a properly devastating Fire Rain and a stronger Fireball. Tell me what feels off and it'll get tuned.

## Installation instructions
[list=1]
[*]Install [b]UE4SS[/b] for Gothic 1 Remake (if you don't have it yet).
[*]Extract the download so you end up with:
[i]...\Gothic 1 Remake\G1R\Binaries\Win64\Mods\G1R_MageBalance\[/i] (containing [i]enabled.txt[/i] and [i]Scripts\[/i]).
[*]Start the game — the included [i]enabled.txt[/i] activates the mod.
[/list]
Want different numbers? Edit [i]Scripts\config.lua[/i] — one readable block per spell. No code knowledge needed.

## Main features
[list]
[*][b]Per-spell damage rebalance[/b] — a simple multiplier, or exact per-magic-circle values.
[*][b]Handles chargeable spells[/b] (all charge levels) and AoE spells.
[*][b]Optional stat tweaks[/b] beyond damage (AoE area, etc.).
[*][b]Runtime-only & save-safe[/b] — nothing on disk is touched; reverts on game close; never stacks.
[*][b]Easy config[/b] — one block per spell; add or retune a spell in seconds.
[/list]
[b]Current buffs:[/b] Fire Rain (+150% & bigger area), Fireball (+100%, all charge levels), Ice Arrow (raised to Firebolt parity), Death Breath (+100%), Pyrokinesis (+150%). Firebolt and Ball Lightning are left at vanilla. More to come — see the to-do list.

## Requirements
[list]
[*][b]UE4SS[/b] (3.x) — required.
[*][b]ConsoleEnablerMod[/b] — optional, only for the in-game [i]mb_*[/i] helper/diagnostic commands.
[/list]

## Shout outs
[list]
[*][b]DaddyKickem[/b] — for the detailed, spell-by-spell balance feedback that started this whole project.
[*]The [b]Gothic 1 Remake modding community[/b] and the [b]UE4SS[/b] team.
[*]Everyone who tests, reports, and helps tune the numbers — this is a community work in progress.
[/list]
