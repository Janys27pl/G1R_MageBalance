-- G1R Mage Balance — RECON HARNESS (does not modify the game yet)
-- =============================================================================
-- Goal of v1: rebalance under-performing mage spell damage at runtime, using the
-- same idempotent, save-safe, no-files-touched approach as Rich Merchants.
--
-- BUT FIRST we must find out WHERE Gothic 1 Remake keeps spell damage. This file
-- is a read-only discovery tool. It NEVER writes a game value. It lets us:
--   * probe candidate classes (FindAllOf) and list their live instances, and
--   * dump every property name + numeric value of an object via UE4SS reflection,
-- so we can identify the damage field(s) and wire up the real balance pass later.
--
-- WORKFLOW (see RECON.md):
--   1. In-game, generate UE4SS_ObjectDump.txt and grep it for spell/magic/rune
--      class names. Put the promising short class names into config.ReconClasses.
--   2. Cast each spell once (so transient spell/projectile objects exist), then
--      run the console command  mb_scan  to list instances of those classes.
--   3. Run  mb_dump <ShortClassName>  to print all properties + values of the
--      first live instance — look for the damage field(s).
--   4. Send the log slice back; we then build the apply pass.
--
-- SAFE BY CONSTRUCTION: only FindAllOf on *named* classes (no global object-array
-- scans, which can crash this UE4SS build), everything pcall-guarded, read-only.
-- =============================================================================

local config = require("config")
local log = require("lib.log")

-- ---- DEV step logging -----------------------------------------------------
-- Hard C++ crashes can't be caught by pcall, so the only way to localise the
-- offending line is to log a breadcrumb right BEFORE each risky engine call: the
-- last [DBG] line in UE4SS.log before a crash points straight at the culprit.
-- Toggle with config.DebugSteps (turn off for release). dbg() is cheap and never
-- throws. Use dbg("area: about to <do risky thing> <context>") generously around
-- field reads on unknown objects, FindAllOf, reflection, and attribute writes.
local function dbg(msg)
    if config.DebugSteps == true then
        log.info("[DBG] " .. tostring(msg))
    end
end

-- ---- small safe helpers (same idioms as Rich Merchants) -------------------
local function run_on_game_thread(fn)
    if type(ExecuteInGameThread) == "function" then ExecuteInGameThread(fn) else fn() end
end
local function valid(o)
    if o == nil then return false end
    local ok, r = pcall(function() return o:IsValid() end)
    return ok and r == true
end
-- UE4SS passes hook args / map entries as RemoteUnrealParam wrappers; unwrap to the object.
local function unwrap(p)
    if p == nil then return nil end
    local ok, o = pcall(function() return p:get() end)
    if ok and o ~= nil then return o end
    return p
end
local function full_name(o)
    local ok, n = pcall(function() return o:GetFullName() end)
    return (ok and type(n) == "string") and n or "<unknown>"
end
local function class_name(o)
    local ok, c = pcall(function() return o:GetClass():GetFName():ToString() end)
    return (ok and type(c) == "string") and c or "?"
end

-- Split a "A B,C" config string into a list of short class names.
local function parse_classes(s)
    local out = {}
    if type(s) ~= "string" then return out end
    for tok in s:gmatch("[^%s,]+") do out[#out + 1] = tok end
    return out
end

-- Enumerate every property of an object's class chain. For numeric properties we
-- read and print the value; for object/struct/name properties we print the type
-- (and, for objects, the referenced full name). This is how we spot damage fields.
local NUMERIC = {
    FloatProperty = true, DoubleProperty = true, IntProperty = true,
    Int8Property = true, Int16Property = true, Int64Property = true,
    UInt16Property = true, UInt32Property = true, UInt64Property = true,
    ByteProperty = true, BoolProperty = true,
}

local function dump_object(obj, label)
    if not valid(obj) then log.warn("dump: invalid object for " .. tostring(label)); return end
    log.info(string.format("---- DUMP %s ----", tostring(label)))
    log.info("  fullname: " .. full_name(obj))
    log.info("  class:    " .. class_name(obj))

    local cls
    if not pcall(function() cls = obj:GetClass() end) or not valid(cls) then
        log.warn("  (could not get class for reflection)")
        return
    end

    local seen = {}
    local struct = cls
    local guard = 0
    while valid(struct) and guard < 40 do
        guard = guard + 1
        pcall(function()
            struct:ForEachProperty(function(prop)
                local pname
                if not pcall(function() pname = prop:GetFName():ToString() end) or not pname then return end
                if seen[pname] then return end
                seen[pname] = true

                local ptype = "?"
                pcall(function() ptype = prop:GetClass():GetFName():ToString() end)

                if config.DumpValues and NUMERIC[ptype] then
                    local val
                    local okv = pcall(function() val = obj[pname] end)
                    if okv then
                        log.info(string.format("  %-34s %-16s = %s", pname, ptype, tostring(val)))
                    else
                        log.info(string.format("  %-34s %-16s = <unreadable>", pname, ptype))
                    end
                elseif ptype == "ObjectProperty" then
                    local ref
                    pcall(function() ref = obj[pname] end)
                    log.info(string.format("  %-34s %-16s -> %s", pname, ptype,
                        (ref ~= nil and full_name(ref) or "nil")))
                else
                    log.info(string.format("  %-34s %-16s", pname, ptype))
                end
            end)
        end)
        -- walk up to the parent class so we also see inherited fields
        local parent
        if not pcall(function() parent = struct:GetSuperStruct() end) then break end
        struct = parent
    end
    log.info("---- END DUMP ----")
end

-- List live instances of a named class.
local function scan_class(short, dump_first)
    if type(FindAllOf) ~= "function" then log.warn("FindAllOf unavailable.") return end
    local list
    local ok = pcall(function() list = FindAllOf(short) end)
    if not ok or list == nil then
        log.info(string.format("scan %-28s : (no instances / unknown class)", short))
        return
    end
    local n, first = 0, nil
    pcall(function()
        for _, o in ipairs(list) do
            if valid(o) then
                n = n + 1
                if not first then first = o end
                if n <= 8 then log.info(string.format("  [%s] %s", short, full_name(o))) end
            end
        end
    end)
    log.info(string.format("scan %-28s : %d live instance(s)", short, n))
    if dump_first and first then dump_object(first, short .. "#1") end
end

-- ---- spell-damage specific reader ----------------------------------------
-- Reads USpellProjectileDefinition.m_DamageMagicCircleProgression, a
--   TMap< FGameplayTag (damage type) , FDamageProgressionMagicCircle >
-- where FDamageProgressionMagicCircle.m_DamageByMagicCircle is a
--   TArray< { FGameplayTag m_CircleTag ; float m_Damage } >.
-- Logs spell-name -> (damageType, circle, damage) so we can map each spell and
-- compute the rebalanced numbers. READ-ONLY.
-- NOTE: map keys/values and array elements here are STRUCTS (FGameplayTag,
-- FDamageProgressionMagicCircle, FDamageByMagicCircle). Do NOT call :get()/unwrap
-- on them — that only works for object pointers and raises an *uncatchable* C++
-- error on structs. Index their members directly instead.
local function tag_str(t)
    if t == nil then return "?" end
    local s
    if pcall(function() s = t.TagName:ToString() end) and type(s) == "string" then return s end
    return "?"
end

-- Read a named TMap on the object and log its numeric values. Keys are skipped
-- (FGameplayTag struct keys raise uncatchable errors). Map values may be a plain
-- float, or a struct holding a float — we probe common field names.
local STRUCT_FLOAT_FIELDS = { "m_Damage", "Damage", "m_Value", "Value", "m_BaseDamage", "BaseDamage", "m_Amount", "Amount" }
local function dump_named_map(obj, field, label)
    local map
    if not pcall(function() map = obj[field] end) or map == nil then
        log.info(string.format("      %s : (absent)", field)); return 0
    end
    local n = 0
    pcall(function()
        map:ForEach(function(_, v)
            n = n + 1
            if type(v) == "number" then
                log.info(string.format("      %-26s key#%d  value=%s", field, n, tostring(v)))
            else
                local shown = false
                for _, f in ipairs(STRUCT_FLOAT_FIELDS) do
                    local val
                    if pcall(function() val = v[f] end) and type(val) == "number" then
                        log.info(string.format("      %-26s key#%d  .%s=%s", field, n, f, tostring(val)))
                        shown = true; break
                    end
                end
                if not shown then log.info(string.format("      %-26s key#%d  (struct value: no known float field)", field, n)) end
            end
        end)
    end)
    if n == 0 then log.info(string.format("      %s : (empty)", field)) end
    return n
end

local function dump_spell_damage(obj, label)
    if not valid(obj) then return end
    log.info(string.format("  SPELL %s  (%s)", full_name(obj), label))
    -- m_DamageBase is where the live damage actually lives (AngelScript-injected);
    -- m_DamageMagicCircleProgression is the empty C++ field. Read both + key stats.
    dump_named_map(obj, "m_DamageBase", label)
    for _, f in ipairs({ "m_SuperArmorDamageBase", "m_CriticalMultiplier", "m_Value" }) do
        local val
        if pcall(function() val = obj[f] end) and type(val) == "number" then
            log.info(string.format("      %-26s = %s", f, tostring(val)))
        end
    end
    local map
    if not pcall(function() map = obj.m_DamageMagicCircleProgression end) or map == nil then
        return
    end
    -- We DELIBERATELY do not read the FGameplayTag keys/m_CircleTag here: calling
    -- :ToString()/:get() on those structs raises an *uncatchable* C++ error that
    -- aborts the whole callback. For a damage multiply we only need m_Damage, so
    -- we read just the float (the tag is irrelevant for an in-place rescale).
    local any, ki = false, 0
    pcall(function()
        map:ForEach(function(_, v)
            ki = ki + 1
            local arr
            if pcall(function() arr = v.m_DamageByMagicCircle end) and arr ~= nil then
                pcall(function()
                    arr:ForEach(function(idx, e)
                        local dmg
                        local ok = pcall(function() dmg = e.m_Damage end)
                        any = true
                        log.info(string.format("      key#%d  entry[%s]  m_Damage=%s",
                            ki, tostring(idx), ok and tostring(dmg) or "<unreadable>"))
                    end)
                end)
            else
                log.info(string.format("      key#%d  (no m_DamageByMagicCircle array)", ki))
            end
        end)
    end)
    if not any and ki == 0 then log.info("      (map present but empty / unreadable)") end
end


-- Probe several related classes and report per-class instance counts. Note:
-- FindAllOf skips Class-Default-Objects, so spell damage that lives on a CDO
-- (the common case for data-definition objects) won't show up here — the hook
-- below is the reliable capture path.
local function scan_spell_damage()
    if type(FindAllOf) ~= "function" then log.warn("FindAllOf unavailable.") return end
    log.info("==== SPELL DAMAGE DUMP (FindAllOf probe) ====")
    local found = 0
    local probes = {
        "SpellProjectileDefinition", "ProjectileDefinition", "BreakableProjectileDefinition",
        "SpellProjectileVisual", "ProjectileVisual", "SpellVisual",
    }
    for _, cls in ipairs(probes) do
        local list, n = nil, 0
        if pcall(function() list = FindAllOf(cls) end) and list ~= nil then
            pcall(function()
                for _, o in ipairs(list) do
                    if valid(o) then
                        n = n + 1
                        if cls:find("Definition") then found = found + 1; dump_spell_damage(o, cls) end
                    end
                end
            end)
        end
        log.info(string.format("  probe %-30s : %d instance(s)", cls, n))
    end
    log.info(string.format("==== END PROBE : %d definition(s) dumped ====", found))
    if found == 0 then
        log.warn("No definitions via FindAllOf (data likely on CDO). Use the HOOK: cast the spell AT an enemy and HIT it, then check the log for [HOOK] lines.")
    end
end

local function scan_all(dump_first)
    local classes = parse_classes(config.ReconClasses)
    if #classes == 0 then
        log.warn("config.ReconClasses is empty — fill it from the ObjectDump grep (see RECON.md).")
        return
    end
    log.info(string.format("scanning %d candidate class(es)...", #classes))
    for _, c in ipairs(classes) do scan_class(c, dump_first) end
end

-- ---- wiring ---------------------------------------------------------------
print(string.format("[%s v%s] RECON harness loaded (read-only)\n", config.ModName, config.Version))
log.info("read-only discovery mode. Console: mb_spells (spell damage), mb_scan, mb_dumpfirst, mb_dump <Class>, mb_find <Class>")
log.info("ReconClasses = '" .. tostring(config.ReconClasses) .. "'")

-- mb_scan : list live instances of every class in config.ReconClasses
pcall(RegisterConsoleCommandHandler, "mb_scan", function(_, _, ar)
    run_on_game_thread(function() scan_all(false) end)
    if ar then ar:Log("[Mage Balance] scan -> UE4SS.log") end
    return true
end)

-- mb_spells : read live spell damage maps from all SpellProjectileDefinitions
pcall(RegisterConsoleCommandHandler, "mb_spells", function(_, _, ar)
    run_on_game_thread(function() scan_spell_damage() end)
    if ar then ar:Log("[Mage Balance] spell damage -> UE4SS.log") end
    return true
end)

-- mb_dumpfirst : scan + dump the first live instance of each candidate class
pcall(RegisterConsoleCommandHandler, "mb_dumpfirst", function(_, _, ar)
    run_on_game_thread(function() scan_all(true) end)
    if ar then ar:Log("[Mage Balance] dumpfirst -> UE4SS.log") end
    return true
end)

-- mb_dump <ShortClass> : dump the first live instance of one class by name
pcall(RegisterConsoleCommandHandler, "mb_dump", function(_, cmd, ar)
    local arg = type(cmd) == "string" and cmd:match("^%s*mb_dump%s+(%S+)") or nil
    run_on_game_thread(function()
        if not arg then log.warn("usage: mb_dump <ShortClassName>") return end
        scan_class(arg, true)
    end)
    if ar then ar:Log("[Mage Balance] dump -> UE4SS.log") end
    return true
end)

-- mb_find <ShortClass> : just list instances of one class (no property dump)
pcall(RegisterConsoleCommandHandler, "mb_find", function(_, cmd, ar)
    local arg = type(cmd) == "string" and cmd:match("^%s*mb_find%s+(%S+)") or nil
    run_on_game_thread(function()
        if not arg then log.warn("usage: mb_find <ShortClassName>") return end
        scan_class(arg, false)
    end)
    if ar then ar:Log("[Mage Balance] find -> UE4SS.log") end
    return true
end)

-- ---- live capture via hooks ----------------------------------------------
-- Spell damage usually lives on the CDO of a USpellProjectileDefinition, which
-- FindAllOf won't return. So we hook the engine functions that receive the real
-- definition object as `self` (or that fire on cast) and dump it once each.
local dumped = _G.__MB_dumped or {}
_G.__MB_dumped = dumped

-- Capture the spell projectile definition when a spell is cast and log its name +
-- m_DamageBase once. This is the "recon" step you use to DISCOVER a new spell's
-- class name (it prints "SPELL <Name>ProjectileDefinition") so you can add it to
-- config.SpellDamageByClass. It changes nothing — actual scaling is at hit time.
local function on_definition_self(self, who)
    local obj = unwrap(self)
    if not valid(obj) then return end
    local key = full_name(obj)
    if dumped[key] then return end
    dumped[key] = true
    if config.Verbose == true then
        log.info(string.format("[HOOK] %s -> captured definition object:", tostring(who)))
        dump_spell_damage(obj, "hook:" .. tostring(who))
    end
end

local function try_hook(fnpath, label, handler)
    if type(RegisterHook) ~= "function" then return end
    local ok = pcall(RegisterHook, fnpath, handler)
    if ok then log.info("hook OK   : " .. fnpath)
    else log.warn("hook FAIL : " .. fnpath) end
end

-- Spell-name discovery: fires on cast/launch (no hit needed) and receives the
-- USpellProjectileDefinition as its 3rd argument:
--   IsAccesible_Scriptable(Character, LocationToSpawn, ProjectileDefinition, TargetLocation, OutHitResult)
-- RegisterHook passes (self, arg1, arg2, arg3, ...), so arg3 == ProjectileDefinition.
-- Used (with Verbose) to log a spell's class name so you can add it to config.
try_hook("/Script/G1R.GameplayAbilitySpellCommonProjectile:IsAccesible_Scriptable",
    "IsAccesible_Scriptable(param3)",
    function(self, a1, a2, a3) on_definition_self(a3, "IsAccesible_Scriptable.ProjectileDefinition") end)

-- =============================================================================
-- WEG B — per-spell damage scaling at projectile hit.
-- Spell damage lives in the definition's m_DamageBase (a TMap we can't write).
-- So instead we scale the FINAL damage via the TARGET's AttributeSet_Health
-- DamageMultiplier: on hit, set the hit enemy's DamageMultiplier to
-- vanilla x spellFactor, then restore it shortly after so only this hit scales.
-- =============================================================================

-- Read a GAS attribute (struct with BaseValue/CurrentValue, or a plain number).
local function attr_read_pair(obj, field)
    dbg("attr_read: before obj[" .. field .. "]")
    local raw
    if not pcall(function() raw = obj[field] end) or raw == nil then dbg("attr_read: nil"); return nil end
    if type(raw) == "number" then return raw, raw, "plain", raw end
    dbg("attr_read: before raw.CurrentValue/BaseValue")
    local base, cur
    pcall(function() cur = raw.CurrentValue end)
    pcall(function() base = raw.BaseValue end)
    dbg("attr_read: base=" .. tostring(base) .. " cur=" .. tostring(cur))
    if type(cur) == "number" then
        return (type(base) == "number" and base or cur), cur, "struct", raw
    end
    return nil
end

-- Write a GAS attribute: direct struct fields + verify, else Reflection ImportText.
local function attr_write_pair(obj, field, base, cur)
    local _b, _c, kind, raw = attr_read_pair(obj, field)
    if not kind then return false, "unreadable" end
    if kind == "plain" then
        local ok = pcall(function() obj[field] = cur end)
        return ok, ok and "plain" or "fail"
    end
    -- struct: try direct field write first
    dbg("attr_write: before direct BaseValue/CurrentValue write")
    if pcall(function() raw.BaseValue = base; raw.CurrentValue = cur end) then
        local _, vc = attr_read_pair(obj, field)
        if type(vc) == "number" and math.abs(vc - cur) < 0.001 then dbg("attr_write: struct ok"); return true, "struct" end
    end
    -- fallback: reflection ImportText (this is what works for AttributeSet structs)
    dbg("attr_write: before Reflection/ImportText")
    local ok = pcall(function()
        local prop = obj:Reflection():GetProperty(field)
        prop:ImportText(string.format("(BaseValue=%.6f,CurrentValue=%.6f)", base, cur),
            prop:ContainerPtrToValuePtr(obj), 0, obj)
    end)
    dbg("attr_write: ImportText returned ok=" .. tostring(ok))
    if ok then
        local _, vc = attr_read_pair(obj, field)
        if type(vc) == "number" and math.abs(vc - cur) < 0.001 then return true, "importtext" end
    end
    return false, "verify-failed"
end

local function state_key_of(fullname)
    return tostring(fullname or ""):match("(State_[%w_]+_%d+)")
end

-- Find the AttributeSet_Health whose name carries the same State_..._NNN key.
local mb_holder_cache = _G.__MB_holder_cache or {}
_G.__MB_holder_cache = mb_holder_cache
local function find_health_holder(key)
    if not key then return nil end
    local cached = mb_holder_cache[key]
    if valid(cached) then dbg("find_health_holder: cache hit"); return cached end
    dbg("find_health_holder: before FindAllOf(AttributeSet_Health)")
    local list
    if not pcall(function() list = FindAllOf("AttributeSet_Health") end) or list == nil then
        dbg("find_health_holder: FindAllOf failed/nil"); return nil
    end
    dbg("find_health_holder: FindAllOf ok, iterating")
    local found
    pcall(function()
        for _, h in ipairs(list) do
            if valid(h) and full_name(h):find(key, 1, true) then found = h; break end
        end
    end)
    dbg("find_health_holder: done, found=" .. tostring(found ~= nil))
    if found then mb_holder_cache[key] = found end
    return found
end

-- Read an object-valued field and return its full name. NEVER unwrap()/:get() a
-- directly-read object field — that triggers an uncatchable C++ crash on this
-- build. Reading the field then GetFullName (both pcall-guarded) is safe.
local function field_fullname(obj, field)
    dbg("field_fullname: before read ." .. tostring(field))
    local v, n = nil, ""
    pcall(function() v = obj[field] end)
    if v ~= nil then pcall(function() n = full_name(v) end) end
    dbg("field_fullname: ." .. tostring(field) .. " = " .. n)
    return n or ""
end

-- projectile -> (multiplier, label) from its m_ProjectileDefinition class name.
local function spell_factor(projectile)
    local dn = field_fullname(projectile, "m_ProjectileDefinition")
    for sub, mult in pairs(config.SpellDamageByClass or {}) do
        if dn:find(sub, 1, true) then return tonumber(mult) or 1.0, sub end
    end
    return 1.0, dn
end

local function is_player_projectile(projectile)
    local n = field_fullname(projectile, "Instigator")
    if n:find("PlayerCharacter", 1, true) or n:find("State_PC", 1, true) then return true end
    n = field_fullname(projectile, "Owner")
    return n:find("PlayerCharacter", 1, true) ~= nil
end

-- DamageMultiplier set/restore state, keyed by holder name.
local mb_dm = _G.__MB_dm or {}
_G.__MB_dm = mb_dm
local function restore_dm(hkey, gen)
    local st = mb_dm[hkey]
    if not st or st.gen ~= gen then return end
    mb_dm[hkey] = nil
    -- The holder may be gone if the enemy died after the hit; valid() guards the
    -- common case and the pcall mops up the rest.
    if valid(st.holder) then
        pcall(function() attr_write_pair(st.holder, "DamageMultiplier", st.base, st.cur) end)
    end
end

local function step(msg) dbg("scale: " .. msg) end

-- Safe boolean field read (no :get(), pcall-guarded).
local function field_bool(obj, field)
    local v
    pcall(function() v = obj[field] end)
    return v == true
end

local function scale_spell_hit(projectile, enemy)
    step("enter")
    -- Guard: a projectile hits anything with collision — decorations, barrels,
    -- world props (e.g. AlkimiaLightweightDecorationActor). Those have no
    -- m_CharacterState, and reading that field on them crashes HARD (uncatchable).
    -- So only proceed for actual characters (NPCs/monsters/player all carry
    -- "Character" in their class name: AIAgentCharacter_*, PlayerCharacterBP_*).
    if not valid(enemy) then step("skip: enemy invalid"); return end
    local ecls = class_name(enemy)
    step("enemy class=" .. ecls)
    if not ecls:find("Character", 1, true) then step("skip: not a character (" .. ecls .. ")"); return end
    if field_bool(enemy, "bActorIsBeingDestroyed") then step("skip: actor being destroyed"); return end

    local mult, label = spell_factor(projectile)
    step("spell=" .. tostring(label) .. " mult=" .. tostring(mult))
    if mult == 1.0 then return end

    if not valid(enemy) then step("skip: enemy invalid pre-state"); return end
    local key = state_key_of(field_fullname(enemy, "m_CharacterState"))
    if not key then key = state_key_of(field_fullname(enemy, "PlayerState")) end
    if not key then log.warn("[SCALE] no State key for target"); return end
    step("statekey=" .. key)

    step("before FindAllOf(AttributeSet_Health)")
    local holder = find_health_holder(key)
    step("after FindAllOf; holder=" .. (valid(holder) and "found" or "nil"))
    if not valid(holder) then log.warn("[SCALE] no AttributeSet_Health for " .. key); return end

    local hkey = full_name(holder)
    local st = mb_dm[hkey]
    if not st then
        step("before read DamageMultiplier")
        local base, cur = attr_read_pair(holder, "DamageMultiplier")
        step("after read: base=" .. tostring(base) .. " cur=" .. tostring(cur))
        if type(cur) ~= "number" then log.warn("[SCALE] DamageMultiplier unreadable"); return end
        st = { holder = holder, base = base, cur = cur, gen = 0 }
        mb_dm[hkey] = st
    end
    st.gen = st.gen + 1
    local target = (st.cur or 1.0) * mult

    if config.ScaleDryRun == true then
        step(string.format("DRY-RUN: would set DamageMultiplier %s -> %s (no write)",
            tostring(st.cur), tostring(target)))
        return
    end

    step("before write DamageMultiplier -> " .. tostring(target))
    local ok, how = attr_write_pair(holder, "DamageMultiplier", target, target)
    log.info(string.format("[SCALE] %s x%.2f  DamageMultiplier %s->%s (%s) on %s",
        tostring(label), mult, tostring(st.cur), tostring(target), tostring(how), key))
    if ok then
        local gen = st.gen
        if type(ExecuteWithDelay) == "function" then
            ExecuteWithDelay(600, function() pcall(function() restore_dm(hkey, gen) end) end)
        end
    end
end

local function on_projectile_hit(self, ...)
    if config.EnableSpellScaling ~= true then return end
    dbg("hit: entry")
    local obj = unwrap(self)
    if not valid(obj) then dbg("hit: self invalid"); return end
    dbg("hit: proj=" .. class_name(obj))
    local args = { ... }
    local enemy = unwrap(args[2])
    dbg("hit: enemy valid=" .. tostring(valid(enemy)))
    if not valid(enemy) then return end
    dbg("hit: before is_player_projectile")
    local pp = is_player_projectile(obj)
    dbg("hit: player_proj=" .. tostring(pp))
    if pp then
        pcall(function() scale_spell_hit(obj, enemy) end)
        dbg("hit: after scale_spell_hit")
    end
end
try_hook("/Script/G1R.ProjectileVisual:OnHitServer", "OnHitServer",
    function(self, ...) on_projectile_hit(self, ...) end)

log.info(string.format("ready. EnableSpellScaling=%s. Cast a spell at an enemy -> [SCALE] lines.",
    tostring(config.EnableSpellScaling)))
