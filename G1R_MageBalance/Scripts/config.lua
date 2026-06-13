-- G1R Mage Balance — configuration
--
-- Rebalances mage spell damage at runtime (no game files touched). When a player
-- spell projectile hits an enemy, the enemy's incoming-damage multiplier is
-- briefly scaled by that spell's factor, then restored — so only that hit is
-- affected. Per-spell factors live in SpellDamageByClass below; editing them is
-- all you ever need to do.
--
-- Balance intent (YouTuber DaddyKickem) — wired up per spell as class names are
-- discovered (see "Adding a spell" in README.md):
--   Blitz ......... "lachhaft"        -> strong buff (~2.5x)
--   Todeshauch .... very weak         -> buff (~2.0x)  [non-projectile, separate path TBD]
--   Feuerregen .... too weak          -> buff (~1.8x)
--   Eispfeil ...... endgame too weak  -> buff (~1.5x)
--   Feuerball ..... endgame too weak  -> buff (~1.5x)
--   Kugelblitz .... okay              -> leave ~1.0
--   Eiswelle / Windfaust / Sturmfaust -> fine, leave 1.0

return {
    ModName = "G1R Mage Balance",
    Version = "0.1.0-alpha",

    -- ======================================================================
    -- MAIN SETTING — per-spell damage factors.
    -- Key   = any substring of the spell's projectile-definition class name
    --         (shown in UE4SS.log when you cast it: "SPELL <Name>ProjectileDefinition").
    -- Value = damage multiplier for that spell (1.0 = vanilla / untouched).
    -- To add a spell: cast it once, read the class name from the log, add a line.
    -- ======================================================================
    EnableSpellScaling = true,
    SpellDamageByClass = {
        FireBolt      = 1.0,  -- Feuerpfeil (Circle 1; fine in vanilla — set higher to taste)
        BallLightning = 1.0,  -- Kugelblitz (DaddyKickem: okay)
        -- Add once captured (cast the spell, copy its class-name substring):
        -- Fireball   = 1.5,  -- Feuerball
        -- IceArrow   = 1.5,  -- Eispfeil   (real class substring TBD)
        -- Lightning  = 2.5,  -- Blitz      (real class substring TBD)
        -- FireRain   = 1.8,  -- Feuerregen (real class substring TBD)
    },

    -- ---- Diagnostics / dev ----------------------------------------------------
    -- Dry run: resolve the target and read its DamageMultiplier but do NOT write
    -- (useful to debug target resolution without changing damage). Default off.
    ScaleDryRun = false,

    -- DEV ONLY: [DBG] breadcrumbs logged right before each risky engine call, so a
    -- hard C++ crash can be traced to the exact line (last [DBG] line = culprit).
    -- Keep OFF for normal play; turn on only when diagnosing a crash.
    DebugSteps = false,

    -- Verbose capture logging (logs each spell's m_DamageBase when first cast —
    -- this is how you discover a new spell's class name). Harmless to leave on.
    Verbose = true,

    -- Short class names probed by the mb_scan / mb_dumpfirst console commands.
    ReconClasses = "SpellProjectileDefinition ProjectileDefinition USpellContainer",
    DumpValues = true,
}
