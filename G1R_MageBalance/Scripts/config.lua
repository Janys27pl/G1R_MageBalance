-- G1R Mage Balance — configuration
-- =============================================================================
-- Edit the Spells table below. One readable block per spell — that's all you ever
-- touch. Runtime-only; reverts on game close. No game files are modified.
--
-- Each spell block:
--   class   = the spell's definition class name (without "Default__"). Per-level
--             chargeable spells are covered automatically (_Lvl1/_Lvl2/_Lvl3).
--             Discover a class name by casting the spell -> see "[SPELL] <name>"
--             in UE4SS.log, or probe with the  mb_try <name>  console command.
--   damage  = how to change damage. Two forms:
--               • a NUMBER  = multiplier on vanilla base + per-circle values
--                             (1.0 = unchanged). Easiest; scales uniformly.
--               • a TABLE   = ABSOLUTE values: { base=, c2=, c4=, c6= }
--                             (any omitted entry keeps vanilla). For precise
--                             per-magic-circle control.
--   fields  = OPTIONAL absolute overrides for non-damage stats (AoE area,
--             duration, speed, stagger, ...). Field names come from  mb_fields.
--   enabled = OPTIONAL false to skip this spell entirely.
--
-- To leave a spell vanilla: damage = 1.0 and no fields (or just comment it out).
-- =============================================================================

return {
    ModName = "G1R Mage Balance",
    Version = "0.5.0-dev",
    Enabled = true,

    Spells = {
        -- name           class (definition)                damage / fields
        Feuerpfeil = { class = "FireBoltProjectileDefinition", damage = { base = 30, c2 = 40, c4 = 50, c6 = 65 } }, -- Circle-1 nerf (35->30), rest vanilla
        Feuerball  = { class = "FireBallProjectileDefinition", damage = 1.75 },          -- chargeable _Lvl1/2/3; +75% (was +100%)
        Kugelblitz = { class = "BallLightningDefinition",      damage = 1.0 },           -- okay per feedback
        Feuerregen = { class = "FireRainDefinition",           damage = 2.5,             -- AoE, flat damage (no circle scaling)
                       fields = { m_XOffset = 1600, m_YOffset = 1600 } },                -- bigger rain area (vanilla 800/800)
        Eispfeil   = { class = "IceBoltProjectileDefinition",  damage = { base = 35, c2 = 40, c4 = 50, c6 = 65 } }, -- Firebolt parity (vanilla 20/30/40/50)
        Todeshauch = { class = "BreathOfDeathDefinition",      damage = 2.0 },           -- "total schwach" -> buff (breath/AoE)
        Pyrokinese = { class = "PyrokinesisProjectileDefinition", damage = 2.5 },        -- projectile
        Feuersturm = { class = "StormOfFireDefinition",        damage = 1.2 },           -- Firestorm: 200->240 (must stay below Firerain's total)
        Uriziel    = { class = "UrizielWaveOfDeathVisualDefinition", damage = { base = 200 } }, -- 6th-circle finale (vanilla 90 flat)
        Blitz      = { class = "LightningRayDefinition",        damage = { base = 70, c2 = 100 } }, -- Chain Lightning (vanilla 10/25); hits _Base/_WithParalysis/_WithoutParalysis. TEST: may be GameplayEffect-driven
        Windfaust  = { class = "WindFistDefinition",            damage = 2.0 },           -- Fist of Wind: 20/30/40/50 -> 40/60/80/100 (CC spell, modest buff)
        UntoteVernichten = { class = "DeathToTheUndeadDefinition", damage = { base = 999 } }, -- Destroy Undead, Gothic-2-style (vanilla 500 flat)

        -- Left vanilla on purpose (uncomment + tune if wanted; vanilla values from mb_scanall):
        -- Sturmfaust = { class = "StormFistDefinition",        damage = 1.0 },           -- 120/160, SuperArmor 250 (stun); feedback: too strong for its mana
        -- Eiswelle   = { class = "IceWaveProjectileDefinition", damage = 1.0 },          -- 120/150; feedback: stunlock too strong (stun, not base dmg)
        -- Eisblock   = { class = "IceBlockProjectileDefinition", damage = 1.0 },         -- 60/80 freeze utility
        -- Absolute-value example: Beispiel = { class = "X", damage = { base = 80, c2 = 95, c4 = 115, c6 = 150 } },
    },

    -- ---- diagnostics ----------------------------------------------------------
    Verbose    = true,   -- log each spell's class + base damage on first cast ([SPELL] lines)
    DebugSteps = false,  -- DEV: [DBG] breadcrumbs before risky calls (crash tracing)
}
