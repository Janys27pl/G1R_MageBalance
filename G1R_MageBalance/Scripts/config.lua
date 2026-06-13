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
    Version = "0.3.0-dev",
    Enabled = true,

    Spells = {
        -- name           class (definition)                damage / fields
        Feuerpfeil = { class = "FireBoltProjectileDefinition", damage = 1.0 },           -- Circle-1 starter; fine in vanilla
        Feuerball  = { class = "FireBallProjectileDefinition", damage = 1.5 },           -- chargeable _Lvl1/2/3; endgame too weak
        Kugelblitz = { class = "BallLightningDefinition",      damage = 1.0 },           -- okay per feedback
        Feuerregen = { class = "FireRainDefinition",           damage = 2.5,             -- AoE, flat damage (no circle scaling)
                       fields = { m_XOffset = 1600, m_YOffset = 1600 } },                -- bigger rain area (vanilla 800/800)
        Eispfeil   = { class = "IceBoltProjectileDefinition",  damage = { base = 35, c2 = 40, c4 = 50, c6 = 65 } }, -- Firebolt parity (vanilla 20/30/40/50)
        -- Blitz    = { class = "???",                         damage = 2.5 },           -- "lachhaft" — capture its class first
        -- Absolute-value example (instead of a factor):
        -- Beispiel = { class = "SomeProjectileDefinition", damage = { base = 80, c2 = 95, c4 = 115, c6 = 150 } },
    },

    -- ---- diagnostics ----------------------------------------------------------
    Verbose    = true,   -- log each spell's class + base damage on first cast ([SPELL] lines)
    DebugSteps = false,  -- DEV: [DBG] breadcrumbs before risky calls (crash tracing)
}
