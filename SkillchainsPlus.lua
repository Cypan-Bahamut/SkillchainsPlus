
-- Windower bootstrap (some environments don't expose windower as a global until required)
do
    if not windower then
        local ok, w = pcall(require, 'windower')
        if ok and w then windower = w end
    end
    if not windower then
        -- Last-resort: try raw global table
        windower = rawget(_G, 'windower')
    end
end

-- skillchainsplus.lua (DNC preaction v11)
-- linecount_check: 2612
--[[
Copyright © 2017, Ivaar
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.
* Neither the name of SkillChains nor the
  names of its contributors may be used to endorse or promote products
  derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL IVAAR BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
_addon.author = 'Ivaar; Modified by Cypan (Bahamut)'
_addon.command = 'sc'
_addon.name = 'skillchainsplus'
_addon.version = '2.3'

require('luau')
require('pack')
require('actions')

file  = require('files')
nukes = require('nukes')
texts = require('texts')
skills = require('skills')
res = require('resources')

local nuke_clear_preburst_state
local nuke_handle_step2_rise

_static = S{'WAR','MNK','WHM','BLM','RDM','THF','PLD','DRK','BST','BRD','RNG','SAM','NIN','DRG','SMN','BLU','COR','PUP','DNC','SCH','GEO','RUN'}
ignoretp = S{}

---------------------------------------------------------------------------
-- BST Pet Ready Skillchain Properties
---------------------------------------------------------------------------
-- BST pet (Monster-type) abilities don't carry skillchain_a/b/c in the
-- resource files the way SMN Blood Pacts do.  This table fills that gap.
--
-- Each entry maps the English ability name → list of SC properties.
-- Empty tables {} = non-damage / buff / debuff move (no SC contribution).
--
-- The addon auto-injects these into skills.job_abilities (for display) and
-- skills.monster_abilities (for action-packet detection) at load time.
--
-- To add / correct an entry, just edit this table and //sc reload.
---------------------------------------------------------------------------
bst_pet_sc_data = {
    -- ===== Lizard family =====
    ["Foot Kick"]          = {"Liquefaction"},
    ["Dust Cloud"]         = {"Detonation"},
    ["Whirl Claws"]        = {"Scission", "Reverberation"},
    -- ===== Mandragora / Sapling family =====
    ["Head Butt"]          = {"Induration"},
    ["Dream Flower"]       = {},
    ["Wild Oats"]          = {"Transfixion"},
    ["Leaf Dagger"]        = {"Scission"},
    ["Scream"]             = {},
    -- ===== Tiger / Coeurl family =====
    ["Roar"]               = {},
    ["Razor Fang"]         = {"Impaction"},
    ["Claw Cyclone"]       = {"Scission", "Detonation"},
    ["Tail Blow"]          = {"Detonation"},
    -- ===== Raptor family =====
    ["Fireball"]           = {"Liquefaction", "Impaction"},
    ["Blockhead"]          = {"Reverberation"},
    ["Brain Crush"]        = {"Induration"},
    ["Infrasonics"]        = {},
    ["Secretion"]          = {},
    -- ===== Sheep / Ram family =====
    ["Lamb Chop"]          = {"Impaction"},
    ["Rage"]               = {},
    ["Sheep Charge"]       = {"Scission"},
    ["Sheep Song"]         = {},
    -- ===== Crab family =====
    ["Bubble Shower"]      = {"Scission"},
    ["Bubble Curtain"]     = {},
    ["Big Scissors"]       = {"Compression"},
    ["Scissor Guard"]      = {},
    ["Metallic Body"]      = {},
    -- ===== Cactuar family =====
    ["Needleshot"]         = {"Transfixion"},
    ["??? Needles"]        = {"Liquefaction", "Detonation"},
    -- ===== Toad family =====
    ["Frogkick"]           = {"Compression"},
    ["Spore"]              = {},
    -- ===== Funguar family =====
    ["Queasyshroom"]       = {},
    ["Numbshroom"]         = {},
    ["Shakeshroom"]        = {},
    ["Silence Gas"]        = {},
    ["Dark Spore"]         = {},
    -- ===== Beetle family =====
    ["Power Attack"]       = {"Reverberation"},
    ["Hi-Freq Field"]      = {"Induration"},
    ["Rhino Attack"]       = {"Detonation"},
    ["Rhino Guard"]        = {},
    ["Spoil"]              = {},
    -- ===== Scorpion family =====
    ["Cursed Sphere"]      = {"Compression"},
    ["Venom"]              = {},
    -- ===== Antlion family =====
    ["Sandblast"]          = {},
    ["Sandpit"]            = {},
    ["Venom Spray"]        = {},
    ["Mandibular Bite"]    = {"Induration"},
    -- ===== Fly / Crawler family =====
    ["Soporific"]          = {},
    ["Gloeosuccus"]        = {},
    ["Palsy Pollen"]       = {},
    ["Geist Wall"]         = {},
    ["Numbing Noise"]      = {},
    -- ===== Lizard/Raptor (Wivre) =====
    ["Nimble Snap"]        = {"Impaction"},
    ["Cyclotail"]          = {"Detonation", "Impaction"},
    ["Toxic Spit"]         = {},
    -- ===== Crab (Hermit Crab) =====
    ["Double Claw"]        = {"Scission"},
    ["Grapple"]            = {"Reverberation"},
    -- ===== Spider family =====
    ["Spinning Top"]       = {"Impaction"},
    ["Filamented Hold"]    = {},
    -- ===== Basilisk / Gaze family =====
    ["Chaotic Eye"]        = {},
    ["Blaster"]            = {},
    -- ===== Leech family =====
    ["Suction"]            = {"Compression"},
    ["Drainkiss"]          = {"Compression"},
    ["TP Drainkiss"]       = {},
    -- ===== Rabbit family =====
    ["Snow Cloud"]         = {"Induration"},
    ["Wild Carrot"]        = {},
    ["Sudden Lunge"]       = {"Impaction"},
    -- ===== Snail family =====
    ["Spiral Spin"]        = {"Transfixion"},
    ["Noisome Powder"]     = {},
    -- ===== Slug family =====
    ["Acid Mist"]          = {},
    -- ===== Manticore family =====
    ["Scythe Tail"]        = {"Detonation"},
    ["Ripper Fang"]        = {"Liquefaction"},
    ["Chomp Rush"]         = {"Reverberation", "Induration"},
    ["Charged Whisker"]    = {"Impaction", "Liquefaction"},
    -- ===== Slime / Leech family =====
    ["Purulent Ooze"]      = {"Compression"},
    ["Corrosive Ooze"]     = {"Scission", "Compression"},
    -- ===== Dhalmel / Horse family =====
    ["Back Heel"]          = {"Liquefaction"},
    ["Jettatura"]          = {},
    ["Choke Breath"]       = {},
    ["Fantod"]             = {},
    -- ===== Adamantoise / Turtle family =====
    ["Tortoise Stomp"]     = {"Reverberation"},
    ["Harden Shell"]       = {},
    ["Aqua Breath"]        = {"Reverberation", "Induration"},
    -- ===== Bird family =====
    ["Wing Slap"]          = {"Detonation", "Scission"},
    ["Beak Lunge"]         = {"Transfixion"},
    ["Intimidate"]         = {},
    ["Recoil Dive"]        = {"Impaction"},
    ["Water Wall"]         = {},
    -- ===== Chapuli / Vermin (Naakual) family =====
    ["Sensilla Blades"]    = {"Scission", "Detonation"},
    ["Tegmina Buffet"]     = {"Distortion"},
    ["Molting Plumage"]    = {},
    -- ===== Tulfaire / Raaz (Naakual) family =====
    ["Swooping Frenzy"]    = {"Fragmentation"},
    ["Sweeping Gouge"]     = {"Detonation"},
    ["Zealous Snort"]      = {},
    ["Pentapeck"]          = {"Distortion"},
    -- ===== Snapweed / Acuex (Naakual) family =====
    ["Tickling Tendrils"]  = {},
    ["Stink Bomb"]         = {},
    ["Nectarous Deluge"]   = {},
    ["Nepenthic Plunge"]   = {},
    -- ===== Bunny / Hip.  family =====
    ["Somersault"]         = {"Compression"},
    ["Foul Waters"]        = {},
    ["Pestilent Plume"]    = {},
    -- ===== Colibri / Apkallu family =====
    ["Pecking Flurry"]     = {"Fragmentation"},
    ["Sickle Slash"]       = {"Scission"},
    ["Acid Spray"]         = {},
    ["Spider Web"]         = {},
    -- ===== Leech / Worm family =====
    ["Infected Leech"]     = {},
    ["Gloom Spray"]        = {},
    -- ===== Wamoura / Amoeban family =====
    ["Disembowel"]         = {"Transfixion", "Scission"},
    ["Extirpating Salvo"]  = {"Impaction", "Detonation"},
    ["Venom Shower"]       = {},
    ["Mega Scissors"]      = {"Compression", "Reverberation"},
    -- ===== Behemoth / Buffalo family =====
    ["Frenzied Rage"]      = {},
    ["Rhinowrecker"]       = {"Liquefaction", "Detonation"},
    -- ===== Slime family =====
    ["Fluid Toss"]         = {"Scission"},
    ["Fluid Spread"]       = {"Compression", "Reverberation"},
    ["Digest"]             = {},
    -- ===== Pugil family =====
    ["Crossthrash"]        = {"Reverberation"},
    ["Predatory Glare"]    = {},
    ["Hoof Volley"]        = {"Reverberation", "Impaction"},
    ["Nihility Song"]      = {},
}

---------------------------------------------------------------------------
-- Inject BST pet SC data into the skills module at load time.
--
-- This populates:
--   skills.job_abilities[ja_id]   → used by add_skills / check_results
--   skills.monster_abilities[ma_id] → used by action_handler
--
-- Also builds a reverse-lookup: bst_ma_id_by_name[name] → monster_ability id
---------------------------------------------------------------------------
bst_ma_id_by_name = {}  -- "Foot Kick" → 257   (monster_abilities key)
bst_ja_id_by_name = {}  -- "Foot Kick" → 672   (job_abilities key)

local function bst_inject_pet_sc_data()
    if not skills then return end
    if not res then return end

    -- Ensure sub-tables exist
    skills.job_abilities     = skills.job_abilities     or {}
    skills.monster_abilities = skills.monster_abilities or {}

    -- 1) Index job_abilities Monster-type entries by name
    if res.job_abilities then
        for id, entry in pairs(res.job_abilities) do
            if entry.type == 'Monster' then
                local name = entry.en or entry.name
                if name then bst_ja_id_by_name[name] = id end
            end
        end
    end

    -- 2) Index monster_abilities by name, preferring entries that carry
    --    skillchain_a data (the higher-ID entries in res have the real SC
    --    properties while the lower-ID duplicates often don't).
    if res.monster_abilities then
        for id, entry in pairs(res.monster_abilities) do
            local name = entry.en or entry.name
            if name then
                local existing_id = bst_ma_id_by_name[name]
                if not existing_id then
                    bst_ma_id_by_name[name] = id
                elseif entry.skillchain_a and entry.skillchain_a ~= '' then
                    bst_ma_id_by_name[name] = id
                end
            end
        end
    end

    -- 3) For every BST pet ability we know about (via job_abilities), build
    --    SC properties from res.monster_abilities first (authoritative), then
    --    fall back to the hand-built bst_pet_sc_data table.
    for name, ja_id in pairs(bst_ja_id_by_name) do
        local props = nil

        -- Try resource file first
        local ma_id = bst_ma_id_by_name[name]
        if ma_id then
            local ma = res.monster_abilities[ma_id]
            if ma and ma.skillchain_a and ma.skillchain_a ~= '' then
                props = {}
                props[#props+1] = ma.skillchain_a
                if ma.skillchain_b and ma.skillchain_b ~= '' then
                    props[#props+1] = ma.skillchain_b
                end
                if ma.skillchain_c and ma.skillchain_c ~= '' then
                    props[#props+1] = ma.skillchain_c
                end
            end
        end

        -- Fall back to hand-built table
        if (not props or #props == 0) and bst_pet_sc_data[name] then
            props = bst_pet_sc_data[name]
        end

        -- Update bst_pet_sc_data to reflect the authoritative props
        -- (so bst_pet_has_sc_props uses correct data everywhere)
        if props and #props > 0 then
            bst_pet_sc_data[name] = props
            local sc_entry = { skillchain = props, delay = 3 }

            -- job_abilities side (display & petsc selection)
            if not skills.job_abilities[ja_id] then
                skills.job_abilities[ja_id] = sc_entry
            end

            -- monster_abilities side (action handler detection)
            if ma_id and not skills.monster_abilities[ma_id] then
                skills.monster_abilities[ma_id] = sc_entry
            end
        end
    end
end

-- Run injection immediately (skills & res are already loaded by this point)
bst_inject_pet_sc_data()

---------------------------------------------------------------------------
-- BST Ready charge helpers
---------------------------------------------------------------------------
-- Ready recast ID (modern BST).  Old Sic was 102; Ready is 255.
local BST_READY_RECAST_ID  = 102
-- Fall back if the user config doesn't set bstrecast (seconds per charge).
local BST_DEFAULT_RECAST   = 30

-- Return the number of Ready charges currently available (0-3+).
local function bst_ready_charges_available()
    local recast = windower.ffxi.get_ability_recasts()
    if not recast then return 0 end
    local timer = recast[BST_READY_RECAST_ID] or 0
    if timer <= 0 then return 3 end  -- all charges ready
    local per_charge = tonumber(bstrecast) or BST_DEFAULT_RECAST
    if per_charge <= 0 then per_charge = BST_DEFAULT_RECAST end
    -- charges_on_cd = ceil(timer / per_charge)
    local on_cd = math.ceil(timer / per_charge)
    local avail = 3 - on_cd
    if avail < 0 then avail = 0 end
    return avail
end

-- Can the BST pet use an ability that costs `charge_cost` charges?
local function bst_can_ready(charge_cost)
    charge_cost = tonumber(charge_cost) or 1
    return bst_ready_charges_available() >= charge_cost
end

---------------------------------------------------------------------------
-- Helper: is the given mob ID our pet?
---------------------------------------------------------------------------
local function is_my_pet(mob_id)
    if not mob_id then return false end
    local pet = windower.ffxi.get_mob_by_target('pet')
    return pet and pet.id == mob_id
end

---------------------------------------------------------------------------
-- BST Pet-as-Opener helpers  (defaultws integration)
--
-- Lets the user place BST pet Ready abilities inside the defaultws list.
-- When iterating defaultws the addon will recognise pet ability names and,
-- if the ability is Ready-able and carries SC properties, treat it as the
-- opening move instead of a weapon skill.
---------------------------------------------------------------------------

-- Maximum yalm distance from player to pet for /pet commands to succeed.
local BST_PET_CMD_RANGE = 20

---------------------------------------------------------------------------
-- BST Pet Buff Tracking
--
-- Pet self-buff abilities (Frenzied Rage, Zealous Snort, etc.) grant a
-- buff to the pet.  Since pet buffs aren't directly queryable, we track
-- when the pet successfully uses a buff ability (via action packet) and
-- apply a cooldown so the addon won't waste charges re-applying it.
-- Tracker clears when pet dies, despawns, or zone changes.
---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- BST Pet Buff Tracking
--
-- Pet self-buff abilities (Rage, Zealous Snort, etc.) grant a buff to
-- the master. Instead of timers, we check the player's actual active
-- buffs via windower.ffxi.get_player().buffs.
--
-- Buff IDs from res/buffs.lua:
--   33=Haste, 37=Stoneskin, 41=Shell, 56=Berserk,
--   91/549=Attack Boost, 92/554=Evasion Boost, 93/550=Defense Boost
--   580=Haste (alternate)
---------------------------------------------------------------------------
bst_pet_buff_to_player_buffs = {
    -- Pet ability name → list of buff IDs it grants on master.
    -- Both standard (91-93) and alternate (549-554) IDs checked.
    ["Rage"]            = {56},           -- Berserk (confirmed)
    ["Frenzied Rage"]   = {91, 549},      -- Attack Boost
    ["Secretion"]       = {92, 554},      -- Evasion Boost
    ["Scissor Guard"]   = {93, 550},      -- Defense Boost
    ["Water Wall"]      = {93, 550},      -- Defense Boost
    ["Harden Shell"]    = {93, 550},      -- Defense Boost
    ["Metallic Body"]   = {37},           -- Stoneskin
    ["Bubble Curtain"]  = {41},           -- Shell
    ["Zealous Snort"]   = {33, 580},      -- Haste
}

--- Is `name` a pet self-buff ability that grants a checkable player buff?
local function bst_is_pet_buff(name)
    return name and bst_pet_buff_to_player_buffs[name] ~= nil
end

--- Is the buff from pet ability `name` currently active on the player?
--- Checks the player's actual buff list, not timers.
local function bst_pet_buff_active(name)
    if not bst_is_pet_buff(name) then return false end
    local p = windower.ffxi.get_player()
    if not p or not p.buffs then return false end
    local check_ids = bst_pet_buff_to_player_buffs[name]
    for _, buff_id in ipairs(p.buffs) do
        for _, check in ipairs(check_ids) do
            if buff_id == check then return true end
        end
    end
    return false
end

--- Stub: kept for compatibility but no longer needed for the
--- buff-ID approach. Action handler still calls this.
local function bst_pet_buff_record(name)
end

--- Stub: kept for compatibility (called in varclean / bst_pet_ready_ok).
local function bst_pet_buff_clear()
end

--- Is the BST pet alive, engaged, and within command range?
--- Returns true only when it is safe to issue a /pet Ready command.
local function bst_pet_ready_ok()
    local pet = windower.ffxi.get_mob_by_target('pet')
    if not pet then bst_pet_buff_clear(); return false end
    -- Pet must be alive
    if (pet.hpp or 0) <= 0 then bst_pet_buff_clear(); return false end
    -- Pet must be engaged (status 1); idle pets have nothing to use
    -- the ability on since we target <me>.
    if (pet.status or 0) ~= 1 then return false end
    -- Player must be within command range of pet
    local me = windower.ffxi.get_mob_by_target('me')
    if not me then return false end
    local dx = pet.x - me.x
    local dy = pet.y - me.y
    local dist = math.sqrt(dx * dx + dy * dy)
    if dist > BST_PET_CMD_RANGE then return false end
    return true
end

--- Is `name` a BST pet Ready ability we know about?
local function bst_is_pet_ability(name)
    if not name then return false end
    return bst_ja_id_by_name[name] ~= nil
end

--- Does the BST pet ability carry at least one SC property?
--- (Empty {} entries in bst_pet_sc_data are buffs/debuffs with no SC use.)
local function bst_pet_has_sc_props(name)
    if not name then return false end
    local props = bst_pet_sc_data[name]
    return props ~= nil and #props > 0
end

--- Full viability check: is pet ability, has SC props, Ready charges
--- available, and pet alive + engaged + in range.
local function bst_pet_opener_viable(name)
    if not bst_is_pet_ability(name) then return false end
    if not bst_pet_has_sc_props(name) then return false end
    local ja = res.job_abilities:with('en', name)
    local charge_cost = ja and ja.mp_cost or 1
    if not bst_can_ready(charge_cost) then return false end
    return bst_pet_ready_ok()
end


-- DNC pre-WS automation (used by spam/autosc)
dnc_ws_context = nil -- 'spam' | 'auto_open' | 'auto_close' | nil
dnc_step_rotation_mode = false
dnc_step_index = 0
dnc_prews_last = dnc_prews_last or 0

-- DNC flourish mapping for pre-WS automation (edit this list)
local dnc_flourish_map = {
    ["Rudra's Storm"] = 'Climactic Flourish',
    ['Savage Blade']   = 'Climactic Flourish',
    ['Shark Bite']   = 'Climactic Flourish',
    ['Pyrrhic Kleos']  = 'Striking Flourish',
    ['Fast Blade II']  = 'Striking Flourish',
}



-- DNC spam opener state (per-target)
dnc_spam_opener_target = dnc_spam_opener_target or nil
dnc_spam_opener_done = dnc_spam_opener_done or false
-- Buff helpers
local function has_buff_name(buff_name)
    local p = windower.ffxi.get_player()
    if not p or not p.buffs then return false end
    for _, bid in ipairs(p.buffs) do
        local b = res.buffs[bid]
        if b and b.name == buff_name then
            return true
        end
    end
    return false
end


local function sc_spamsc_end_window_seconds()
    local t = tonumber(bursttime)
    if not t or t <= 0 then return 1.0 end
    return t
end

local sc_chain_allowed

local function sc_spamws_chain_result(ws_name, reson)
    if not ws_name or not reson or reson.closed or not reson.active then return nil end
    local ws = res and res.weapon_skills and (res.weapon_skills:with('en', ws_name) or res.weapon_skills:with('name', ws_name)) or nil
    local wsid = ws and tonumber(ws.id) or nil
    if not wsid then return nil end
    local ability = skills and skills.weapon_skills and skills.weapon_skills[wsid] or nil
    if not ability then return nil end

    local _, prop = check_props(reson.active, aeonic_prop(ability, info and info.player or nil))
    if not prop then return nil end
    if not sc_chain_allowed(prop) then return nil end
    return prop
end

local function sc_spamsc_should_fire(ws_name, req_tp, cur_tp, reson, now)
    if spamsc ~= 1 then
        return (cur_tp >= req_tp), false, nil
    end

    local prop = sc_spamws_chain_result(ws_name, reson)

    if burst == 1 and reson and not reson.closed then
        local timer = reson.times and (reson.times - now) or 0
        if timer > 0 and (reson.step or 0) >= 2 then
            if prop then
                if cur_tp >= 1000 and timer <= sc_spamsc_end_window_seconds() then
                    return true, false, prop
                end
                return false, true, prop
            elseif autonuke == 1 then
                return false, true, nil
            end
        end
    end

    if not prop then
        return (cur_tp >= req_tp), false, nil
    end

    local delay_until = reson and reson.delay or 0
    if now <= delay_until then
        return false, true, prop
    end

    local timer = reson and ((reson.times or 0) - now) or 0

    if cur_tp >= req_tp then
        return true, false, prop
    end

    if cur_tp >= 1000 and timer > 0 and timer <= sc_spamsc_end_window_seconds() then
        return true, false, prop
    end

    return false, true, prop
end
-- Finishing Move count (0..6 where 6 represents 6+)
local function dnc_finishing_moves()
    local p = windower.ffxi.get_player()
    if not p or not p.buffs then return 0 end
    local fm = 0
    for _, bid in ipairs(p.buffs) do
        if bid == 588 then
            fm = math.max(fm, 6)
        elseif bid >= 381 and bid <= 385 then
            fm = math.max(fm, bid - 380)
        end
    end
    return fm
end

local function dnc_next_step_name()
    if not dnc_step_rotation_mode then
        return 'Box Step'
    end

    local steps = {'Box Step','Quickstep','Feather Step'}
    local name = steps[(dnc_step_index % #steps) + 1]
    dnc_step_index = (dnc_step_index + 1) % #steps
    return name
end

local function dnc_ja_ready(ja_name)
    local rec = windower.ffxi.get_ability_recasts()
    if not rec then return false end
    local ja = res and res.job_abilities and res.job_abilities:with('en', ja_name) or nil
    if not ja or not ja.recast_id then return false end
    return (rec[ja.recast_id] or 999) < 1
end


local function sc_player_has_ja(ja_name)
    local abil = windower.ffxi.get_abilities()
    if not abil or not abil.job_abilities then return false end
    local ja = res and res.job_abilities and res.job_abilities:with('en', ja_name) or nil
    if not ja or not ja.id then return false end
    for _, learned_id in ipairs(abil.job_abilities) do
        if learned_id == ja.id then
            return true
        end
    end
    return false
end

local function sc_dark_arts_active()
    return has_buff_name('Dark Arts') or has_buff_name('Addendum: Black')
end

local function dnc_sc_seconds_remaining()
    if not targ_id or not resonating then return nil end
    local r = resonating[targ_id]
    if not r or not r.times then return nil end
    local rem = r.times - os.clock()
    if rem and rem > 0 then return rem end
    return nil
end

-- Window budgeting rules (only when a resonance window is active):
-- rem < 2.0  => skip all pre-actions
-- 3.0 <= rem < 4.0 => allow 1 JA
-- rem >= 4.0 => allow 2 JAs
local function dnc_max_prejas_for_window(rem)
    if not rem then return nil end
    if rem < 2.0 then return 0 end
    if rem < 3.0 then return 0 end
    if rem < 4.0 then return 1 end
    return 2
end

-- Build flourish + optional step pre-WS command string.
-- include_step: whether we're allowed to attempt a step rotation in this context
-- max_prejas: 0/1/2 when resonance window is active; nil means no window budget
local function dnc_build_flourish_cmd(ws_name, include_step, max_prejas)
    if max_prejas == 0 then return nil end

    local cmd = {}
    local used = 0

    -- Finishing moves gate: don't attempt flourishes if we don't have FMs.
    -- Flourish III consumes 1 FM; Building Flourish consumes remaining FMs.
    local fm = dnc_finishing_moves()

    -- Flourish selection rules (DNC spam/auto):
    --   1) Rudra's Storm or Savage Blade => Climactic before
    --   2) Pyrrhic Kleos or Fast Blade II => Striking before
    --   3) Everything else => Building before
    local flourish3_name = dnc_flourish_map[ws_name]


    -- If a Flourish III is selected for this WS, attempt it (consumes 1 FM)
    if flourish3_name and (fm >= 1) and dnc_ja_ready(flourish3_name) then
        cmd[#cmd+1] = 'input /ja "'..flourish3_name..'" <me>'
        cmd[#cmd+1] = 'wait 1'
        used = used + 1
        fm = fm - 1
        if max_prejas and used >= max_prejas then
            return table.concat(cmd, ';')
        end
    end

    -- Otherwise, attempt Building Flourish (consumes remaining FMs)
    if (not flourish3_name) and (fm >= 1) and dnc_ja_ready('Building Flourish') then
        cmd[#cmd+1] = 'input /ja "Building Flourish" <me>'
        cmd[#cmd+1] = 'wait 1'
        used = used + 1
        fm = 0
        if max_prejas and used >= max_prejas then
            return table.concat(cmd, ';')
        end
    end

    -- Optional step (only when allowed, TP-safe, and we have the step recast bucket ready)
    local p = windower.ffxi.get_player()
    local cur_tp = (p and p.vitals and p.vitals.tp) or (p and p.tp) or 0
    local tp_ok_for_step = (cur_tp >= 1100)

    if include_step and tp_ok_for_step and dnc_ja_ready('Box Step') then
        local step_name = dnc_next_step_name()
        cmd[#cmd+1] = 'input /ja "' .. step_name .. '" <t>'
        cmd[#cmd+1] = 'wait 1'
        used = used + 1
        if max_prejas and used >= max_prejas then
            return table.concat(cmd, ';')
        end
    end

    return #cmd > 0 and table.concat(cmd, ';') or nil
end

local function dnc_build_presto_box_cmd(ws_name)
    local p = windower.ffxi.get_player()
    local cur_tp = (p and p.vitals and p.vitals.tp) or (p and p.tp) or 0

    -- AM mode gating:
    -- If AM toggle is on, suppress Presto/Box until AM3 is already active (preserve TP to reach 3000 for the first Kleos).
    -- Also suppress any step setup if we are about to do a 3000+ Pyrrhic Kleos (avoid dropping below AM3 tier).
    if (am == 1) and (not has_buff_name('Aftermath: Lv.3')) then
        return nil
    end
    if (am == 1) and (ws_name == 'Pyrrhic Kleos') and (cur_tp >= 3000) then
        return nil
    end

    -- Avoid stepping below 1100 TP (step costs 100 and WS needs 1000)
    if cur_tp < 1100 then
        return nil
    end

    -- Don't bother with Presto if Box Step isn't ready
    if not dnc_ja_ready('Box Step') then
        return nil
    end

    local step_name = dnc_next_step_name()

    local cmd = {}
    if has_buff_name('Presto') or (not dnc_ja_ready('Presto')) then
        cmd[#cmd+1] = 'input /ja "' .. step_name .. '" <t>'
        cmd[#cmd+1] = 'wait 1'
    else
        cmd[#cmd+1] = 'input /ja "Presto" <me>'
        cmd[#cmd+1] = 'wait 1'
        cmd[#cmd+1] = 'input /ja "' .. step_name .. '" <t>'
        cmd[#cmd+1] = 'wait 1'
    end
    return table.concat(cmd, ';')
end



-- Reverse Flourish standalone (AM mode helper):
-- When AM toggle is on, AM3 is down, TP < 2000, Reverse Flourish is ready, and we have finishing moves,
-- fire Reverse Flourish on TP change to accelerate reaching 3000 TP. Not tied to any WS.
reverse_flourish_last = reverse_flourish_last or 0
local function dnc_try_reverse_flourish_on_tp_change(new_tp, old_tp)
    local p = windower.ffxi.get_player()
    if not p or p.main_job ~= 'DNC' then return end
    if am ~= 1 then return end
    if has_buff_name('Aftermath: Lv.3') then return end

    local tp = tonumber(new_tp) or ((p.vitals and p.vitals.tp) or p.tp or 0)
    if tp >= 2000 then return end

    -- Only react to real TP changes (avoid calling on identical values).
    if old_tp ~= nil and tonumber(old_tp) == tp then return end

    -- Don't interrupt an in-flight WS/JA chain.
    if ws_inflight == 1 or wsdelay ~= 0 then return end

    -- Engage-only (prevents firing in town / idle).
    if p.status ~= 1 then return end

    -- Recast gate for Reverse Flourish (required in both paths).
    if not dnc_ja_ready('Reverse Flourish') then return end

    -- Throttle to avoid spamming around packet jitter / rapid TP updates.
    if (os.clock() - reverse_flourish_last) < 2.5 then return end
    reverse_flourish_last = os.clock()

    local fm = dnc_finishing_moves()

    -- Desired behavior:
    --   FM >= 5: Reverse Flourish
    --   FM <= 4: No Foot Rise, then Reverse Flourish
    if fm >= 5 then
        windower.send_command('input /ja "Reverse Flourish" <me>')
        ws_delay(1.0)
        return
    end

    -- Need No Foot Rise to reach 5+ before reversing.
    if not dnc_ja_ready('No Foot Rise') then
        return
    end

    -- Chain No Foot Rise into Reverse Flourish.
    windower.send_command('input /ja "No Foot Rise" <me>;wait 1;input /ja "Reverse Flourish" <me>')
    ws_delay(2.0)
end

-- Reverse Flourish is handled via the 'tp change' event (standalone), not as a pre-WS chain.


local function dnc_estimate_chain_delay(cmd)
    if not cmd or cmd == '' then return 1 end
    local total = 0
    -- Sum explicit wait values in the chained command string.
    for w in cmd:gmatch('wait%s+([%d%.]+)') do
        total = total + (tonumber(w) or 0)
    end
    -- Add a small buffer for JA animation lock and packet latency.
    if total < 1 then total = 1 end
    return total + 0.5
end


-- Runtime WS list overrides (per job, per list)
-- This lets you view and modify the WS preference arrays in-game without editing your character lua.
ws_overrides = ws_overrides or {}

local function ws_norm(s)
    if not s then return '' end
    return tostring(s):lower():gsub('^%s+',''):gsub('%s+$','')
end

local function ws_get_job()
    return info and info.job or (windower.ffxi.get_player() and windower.ffxi.get_player().main_job) or nil
end

local function ws_get_list_by_name(listname)
    if listname == 'defaultws' then return defaultws
    elseif listname == 'tpws' then return tpws
    elseif listname == 'spamws' then return spamws
    elseif listname == 'starterws' then return starterws
    elseif listname == 'preferws' then return preferws
    elseif listname == 'avoidws' then return avoidws
    elseif listname == 'petws' then return petws
    elseif listname == 'amws' then return amws
    elseif listname == 'rotatews' then return rotatews
    end
    return nil
end

local function ws_set_list_by_name(listname, value)
    if listname == 'defaultws' then defaultws = value
    elseif listname == 'tpws' then tpws = value
    elseif listname == 'spamws' then spamws = value
    elseif listname == 'starterws' then starterws = value
    elseif listname == 'preferws' then preferws = value
    elseif listname == 'avoidws' then avoidws = value
    elseif listname == 'petws' then petws = value
    elseif listname == 'amws' then amws = value
    elseif listname == 'rotatews' then rotatews = value
    end
end

local function ws_copy_array(t)
    local out = {}
    if type(t) == 'table' then
        for i=1,#t do out[i] = t[i] end
    end
    return out
end

local add_to_chat = windower.add_to_chat

function apply_ws_overrides(job)
    job = job or ws_get_job()
    if not job then return end
    if not ws_overrides[job] then return end

    for listname, v in pairs(ws_overrides[job]) do
        if listname == 'amws' then
            ws_set_list_by_name(listname, v)
        else
            ws_set_list_by_name(listname, ws_copy_array(v))
        end
    end
end

local function ws_ensure_override(job, listname)
    ws_overrides[job] = ws_overrides[job] or {}
    if ws_overrides[job][listname] == nil then
        local cur = ws_get_list_by_name(listname)
        if listname == 'amws' then
            ws_overrides[job][listname] = cur
        else
            ws_overrides[job][listname] = ws_copy_array(cur)
        end
    end
end

local function ws_list_to_string(t)
    if type(t) ~= 'table' then return tostring(t or '') end
    if #t == 0 then return '' end
    local parts = {}
    for i=1,#t do parts[#parts+1] = tostring(t[i]) end
    return table.concat(parts, ', ')
end

local function ws_print_current()
    local job = ws_get_job()
    if not job then
        add_to_chat(123, 'wslist: unable to determine current job.')
        return
    end

    add_to_chat(207, 'WS lists for ' .. job .. ':')
    local lists = {'defaultws','tpws','spamws','starterws','preferws','avoidws','petws','amws','rotatews'}
    for _, name in ipairs(lists) do
        local v = ws_get_list_by_name(name)
        if v ~= nil then
            add_to_chat(207, '  ' .. name .. ': ' .. ws_list_to_string(v))
        end
    end
end

local function ws_add_front(listname, wsname)
    local job = ws_get_job()
    if not job then
        add_to_chat(123, 'wsadd: unable to determine current job.')
        return
    end
    listname = ws_norm(listname)
    wsname = tostring(wsname or ''):gsub('^%s+',''):gsub('%s+$','')
    if wsname == '' then
        add_to_chat(123, 'wsadd: missing weaponskill name.')
        return
    end

    if listname == 'amws' then
        ws_ensure_override(job, 'amws')
        ws_overrides[job]['amws'] = wsname
        ws_set_list_by_name('amws', wsname)
        add_to_chat(207, 'amws set to: ' .. wsname .. ' (' .. job .. ')')
        return
    end

    local cur = ws_get_list_by_name(listname)
    if type(cur) ~= 'table' then
        add_to_chat(123, 'wsadd: invalid list: ' .. tostring(listname))
        return
    end

    ws_ensure_override(job, listname)
    local t = ws_overrides[job][listname]

    local n = ws_norm(wsname)
    for i=1,#t do
        if ws_norm(t[i]) == n then
            table.remove(t, i)
            break
        end
    end

    table.insert(t, 1, wsname)
    ws_set_list_by_name(listname, ws_copy_array(t))

    add_to_chat(207, 'Added to front of ' .. listname .. ' (' .. job .. '): ' .. wsname)
end

local function ws_remove(listname, wsname)
    local job = ws_get_job()
    if not job then
        add_to_chat(123, 'wsrm: unable to determine current job.')
        return
    end
    listname = ws_norm(listname)
    wsname = tostring(wsname or ''):gsub('^%s+',''):gsub('%s+$','')
    if wsname == '' then
        add_to_chat(123, 'wsrm: missing weaponskill name.')
        return
    end

    if listname == 'amws' then
        ws_ensure_override(job, 'amws')
        if ws_norm(ws_overrides[job]['amws']) == ws_norm(wsname) then
            ws_overrides[job]['amws'] = ''
            ws_set_list_by_name('amws', '')
            add_to_chat(207, 'Cleared amws (' .. job .. ')')
        else
            add_to_chat(123, 'wsrm: amws is not set to: ' .. wsname)
        end
        return
    end

    local cur = ws_get_list_by_name(listname)
    if type(cur) ~= 'table' then
        add_to_chat(123, 'wsrm: invalid list: ' .. tostring(listname))
        return
    end

    ws_ensure_override(job, listname)
    local t = ws_overrides[job][listname]

    local n = ws_norm(wsname)
    local removed = 0
    for i=#t,1,-1 do
        if ws_norm(t[i]) == n then
            table.remove(t, i)
            removed = removed + 1
        end
    end

    ws_set_list_by_name(listname, ws_copy_array(t))

    if removed > 0 then
        add_to_chat(207, 'Removed from ' .. listname .. ' (' .. job .. '): ' .. wsname)
    else
        add_to_chat(123, 'wsrm: not found in ' .. listname .. ' (' .. job .. '): ' .. wsname)
    end
end

local function ws_reset(listname)
    local job = ws_get_job()
    if not job then
        return
    end
    listname = ws_norm(listname)
    if not ws_overrides[job] then
        return
    end

    if listname == 'all' then
        ws_overrides[job] = nil
        jobvar()
        if rotatews == nil then rotatews = {} end
        apply_ws_overrides()
        apply_ws_overrides(job)
        add_to_chat(207, 'Cleared all WS overrides for ' .. job)
        return
    end

    if ws_overrides[job][listname] == nil then
        return
    end

    ws_overrides[job][listname] = nil
    jobvar()
    if rotatews == nil then rotatews = {} end
    apply_ws_overrides()
    apply_ws_overrides(job)
    add_to_chat(207, 'Cleared WS override for ' .. listname .. ' (' .. job .. ')')
end

function varclean()

    auto = 0
    burst = 0
    disabled = 0
    am = 0
    melee = 0
    meleeskill = 0
    petskill = 0
    petopenmp = 0
    amthree = 0
    buddy = 0
    tagin = 0
    autonuke = 0
    nuking = 0
    steps = 0
    -- Nuke retry state (for "Unable to cast spells at this time." lockouts)
    nuke_retry_enabled = 1
    nuke_retry_base_delay = 0.25  -- seconds
    nuke_retry_backoff = 1      -- multiplier per attempt
    nuke_retry_max_attempts = 30
    nuke_retry_pending = 0
    nuke_retry_attempts = 0
    nuke_retry_window_start = 0
    nuke_last_spell = nil
    nuke_last_is_ja = false
    nuke_last_delay = 0
    nuke_last_mb = false
    nuke_last_stamp = 0
    nuke_last_res_step = 0
    nuke_last_res_step = 0
    -- Global cast lock pacing to avoid client lockups during resonance step transitions
    nuke_global_lock_until = 0
    nuke_res_step_seen = 0
    nuke_retry_timer = nil
    nuke_retry_used_raw = 0
    nuke_retry_next_allowed = 0

    -- Packet-based action lockouts (JA=1s, WS=2s, Magic=3s from cast begin)
    nuke_busy_until = 0
    nuke_spell_lead = 0.25
    nuke_spell_incast = 0
    nuke_spell_cast_start = 0
    nuke_spell_cast_time = 0
    nuke_desired_mb = nil
    nuke_last_sent_spell = nil
    nuke_last_sent_stamp = 0
    nuke_last_begin_stamp = 0

    nuke_preburst_first_attempt_at = 0
    nuke_preburst_probe_until = 0
    nuke_preburst_ja_name = nil
    nuke_preburst_ja_sent_at = 0
    sc_ebul_mode = 0
    sc_alac_mode = 0
    sc_cascade_mode = 0

    -- NIN Wheel (San spam) state
    wheel = 0
    wheel_idx = 1
    wheel_target_id = nil
    wheel_last_spell = nil
    wheel_last_sent_spell = nil
    wheel_last_choices = nil
    wheel_last_delay = 0
    wheel_cast_lock_until = 0


    -- Wheel inflight tracking (prevents re-sending the same spell before server confirms)
    wheel_inflight = 0
    wheel_inflight_spell = nil
    wheel_inflight_base = nil
    wheel_inflight_until = 0
    wheel_last_target_id = 0
    wheel_send_time = 0
    wheel_send_spell = nil

    wheel_last_advance_spell = nil
    wheel_last_advance_stamp = 0
    wheel_retry_enabled = 1
    wheel_retry_base_delay = 0.34 -- seconds
    wheel_retry_max_attempts = 30
    wheel_retry_pending = 0
    wheel_retry_attempts = 0

    wheel_retry_window_start = 0
    wheel_retry_timer = nil
    wheel_retry_next_allowed = 0
    wheel_lead_time = 0.34 -- seconds (start attempts before expected window)
    casting_spell = false
    last_swing_front = "Steady"
    last_swing_behind = "Steady"
    last_swing_face = "Steady"
    last_swing_petface = "Steady"
    ws_attempt_lock = 0
    ws_attempt_time = 0
    ws_attempt_min = 0.34     -- minimum spacing between WS command sends
    ws_inflight = 0
    ws_inflight_time = 0
    ws_retry_after = 0.34     -- how long to wait before retrying if no WS finish packet
    spam = 0
    spamsc = 0
    spamtp = 1000
    rotate = 0
    rotate_index = 1
    rotate_usable = {}
    strict = 0
    prefer = 0
    endless = 0
    cleave = 0
    nosteps = 0
    nopet = 0
    mob_last_target = {}
    ranged = 0
    starter = 0
    started = 0
    wsdelay = 0
    petdelay = 0
    sicdelay = 0
    bpdelay = 0
    tpdelay = 0
    ongo = 0
    innin = 0
    yonin = 0
    face = 0
    petmode = 0
    petface = 0
    rear = 0
    lockon_mob_id = 0
    last_status_for_release = 0
    -- Face forward-walk assist (only used in Face Mode)
    face_forward_down = 0
    face_strafe_left_down = 0
    face_strafe_right_down = 0
    face_last_targ_id = 0
    face_last_dist = nil
    face_stable_since = 0

    face_trend_last_dist = nil
    face_dist_sample_time = 0
    face_increasing_since = 0
    face_lockon_last_time = 0
    face_ta_last_time = 0


    face_last_target_key = nil
    face_probe_until = 0
    face_probe_start_dist = nil
    face_probe_start_time = 0
    face_last_unable_to_see_time = 0
    face_force_approach_until = 0
    face_force_lockon_until = 0
    face_last_out_of_range = 0
    face_approach_active = 0
    face_edge_tap_until = 0
    face_new_target_tap_until = 0
    face_new_target_backtap_until = 0
    face_walk_hold_start = 0
    face_walk_hold_start_dist = nil
    face_walk_force_stop_until = 0
    innin_last_target_key = nil
    yonin_last_target_key = nil
    innin_new_target_backtap_until = 0
    yonin_new_target_backtap_until = 0
    petmode_last_target_key = nil
    petmode_new_target_backtap_until = 0
    face_force_step_until = 0
    face_back_down = 0
    faw = 0
    open = 0
    close = 0
    light = 0
    dark = 0
    sc_force_element = nil
    ultimate = 0
    w_casting = 0
    w_readies = 0

    tagtime = os.clock()

    openws = nil
    petopen = nil
    bst_pet_opener = nil
    bst_pet_opener_pending = false    -- true = waiting for pet action packet
    bst_pet_opener_sent_at = 0        -- os.clock() when /pet command sent
    bst_pet_opener_timeout = 5        -- safeguard: seconds before giving up
    bst_spam_pet_sent_at = 0          -- os.clock() when spam pre-WS pet fired
    bst_spam_pet_delay = 1.0          -- seconds to hold WS after pet Ready
    bst_pet_buff_clear()              -- pet buffs gone on zone/job change
    initws = nil
    overws = nil
    zergws = nil
    aoews = nil
    automb = nil

    jobvar()
    if rotatews == nil then rotatews = {} end
    apply_ws_overrides()

    if nukes and nukes.set_recastmod then
        nukes.set_recastmod(recastmod)
    end

end

local function clean_ws_name(name)
    if not name then return nil end
    return string.gsub(name, '[ \t]+%f[\r\n%z]', '')
end

local function is_avoided_ws(ws_name)
    ws_name = clean_ws_name(ws_name)
    if not ws_name or not avoidws then
        return false
    end

    -- If avoidws is a Windower set (S{}), it has :contains()
    if type(avoidws) == 'table' and avoidws.contains then
        return avoidws:contains(ws_name)
    end

    -- Otherwise treat as a normal Lua array/list: {'WS1','WS2',...}
    if type(avoidws) == 'table' then
        for i = 1, #avoidws do
            if clean_ws_name(avoidws[i]) == ws_name then
                return true
            end
        end
    end

    return false
end

function check_conf()

    if not windower.ffxi.get_info().logged_in then
        print('You have to be logged in to use this addon.')
        return false
    end

    local conf_path = 'data/'
    local char_name = windower.ffxi.get_player().name
    local conf_file = file.new('\\'..char_name..'.lua')
    if not conf_file:exists() then
        conf_file:create()
        local conf_base = file.read(conf_path..'\\auto.lua')
        conf_file:write(conf_base)
    end

    require(char_name)

end

function check_sc()

    if not windower.ffxi.get_info().logged_in then
        print('You have to be logged in to use this addon.')
        return false
    end

    openws = nil
    petopen = nil
    bst_pet_opener = nil
    initws = nil
    overws = nil
    zergws = nil
    aoews = nil
    rotate_usable = {}
    initws = nil

    local abilities = windower.ffxi.get_abilities().weapon_skills
    local pet = windower.ffxi.get_abilities().job_abilities

    if ranged == 1 then
        for i = 1,#defaultws,+1 do
            if skills.is_ranged_ws(defaultws[i]) then
                for s = 1,#abilities,+1 do
                    if openws == nil then
                        local wsid = res.weapon_skills:with('en',defaultws[i]).id
                        local wsid = tonumber(wsid)
                        if abilities[s] == wsid then
                            openws = defaultws[i]
                        end
                    end
                end
            end
        end
        if openws == nil then
            windower.add_to_chat(167,'SkillchainsPlus: Ranged mode enabled but no ranged WS found in defaultws.')
            return
        end
        for i = 1,#tpws,+1 do
            for s = 1,#abilities,+1 do
                if overws == nil then
                    if skills.is_ranged_ws(tpws[i]) then
                        local wsid = res.weapon_skills:with('en',tpws[i]).id
                        local wsid = tonumber(wsid)
                        if abilities[s] == wsid then
                            overws = tpws[i]
                        end
                    end
                end
            end
        end
        for i = 1,#spamws,+1 do
            if skills.is_ranged_ws(spamws[i]) then
                for s = 1,#abilities,+1 do
                    if zergws == nil then
                        local wsid =  res.weapon_skills:with('en',spamws[i]).id
                        local wsid = tonumber(wsid)
                        if abilities[s] == wsid then
                            zergws = spamws[i]
                        end
                    end
                end
            end
        end
        for i = 1,#rotatews,+1 do
            if skills.is_ranged_ws(rotatews[i]) then
                for s = 1,#abilities,+1 do
                    local ws_res = res.weapon_skills:with('en',rotatews[i])
                    if ws_res then
                        local wsid = tonumber(ws_res.id)
                        if abilities[s] == wsid then
                            rotate_usable[#rotate_usable+1] = rotatews[i]
                            break
                        end
                    end
                end
            end
        end
        for i = 1,#starterws,+1 do
            if skills.is_ranged_ws(starterws[i]) then
                for s = 1,#abilities,+1 do
                    if initws == nil then
                        local wsid =  res.weapon_skills:with('en',starterws[i]).id
                        local wsid = tonumber(wsid)
                        if abilities[s] == wsid then
                            initws = starterws[i]
                        end
                    end
                end
            end
        end
    else
        for i = 1,#defaultws,+1 do
            for s = 1,#abilities,+1 do
                if openws == nil then
                    local ws_res = res.weapon_skills:with('en',defaultws[i])
                    if ws_res then
                        local wsid = tonumber(ws_res.id)
                        if abilities[s] == wsid then
                            openws = defaultws[i]
                        end
                    end
                end
            end
        end
        for i = 1,#tpws,+1 do
            for s = 1,#abilities,+1 do
                if overws == nil then
                    local wsid =  res.weapon_skills:with('en',tpws[i]).id
                    local wsid = tonumber(wsid)
                    if abilities[s] == wsid then
                        overws = tpws[i]
                    end
                end
            end
        end
        for i = 1,#spamws,+1 do
            for s = 1,#abilities,+1 do
                if zergws == nil then
                    local wsid =  res.weapon_skills:with('en',spamws[i]).id
                    local wsid = tonumber(wsid)
                    if abilities[s] == wsid then
                        zergws = spamws[i]
                    end
                end
            end
        end
        for i = 1,#rotatews,+1 do
            for s = 1,#abilities,+1 do
                local ws_res = res.weapon_skills:with('en',rotatews[i])
                if ws_res then
                    local wsid = tonumber(ws_res.id)
                    if abilities[s] == wsid then
                        rotate_usable[#rotate_usable+1] = rotatews[i]
                        break
                    end
                end
            end
        end
        -- Auto-detect a cleave WS from learned weapon skills (pick highest ID)
        local best_cleave_id = nil
        for s = 1, #abilities do
            local wsid = abilities[s]
            local sc = skills.weapon_skills and skills.weapon_skills[wsid]
            if sc and sc.cleave then
                if (best_cleave_id == nil) or (wsid > best_cleave_id) then
                    best_cleave_id = wsid
                end
            end
        end
        if best_cleave_id then
            aoews = res.weapon_skills:with('id', best_cleave_id).name
        end
        for i = 1,#starterws,+1 do
            for s = 1,#abilities,+1 do
                if initws == nil then
                    local wsid =  res.weapon_skills:with('en',starterws[i]).id
                    local wsid = tonumber(wsid)
                    if abilities[s] == wsid then
                        initws = starterws[i]
                    end
                end
            end
        end
        if petws ~= nil then
            for i = 1,#petws,+1 do
                local ja_entry = res.job_abilities:with('en',petws[i])
                if ja_entry then
                    local wsid = tonumber(ja_entry.id)
                    for p = 1,#pet,+1 do
                        if pet[p] == wsid then
                            -- Skip this ability if it's a buff and the
                            -- corresponding player buff is already active.
                            local buff_up = bst_pet_buff_active(petws[i])
                            -- First available petws entry becomes petopen
                            -- (skips if buff already active)
                            if petopen == nil and not buff_up then
                                petopen = petws[i]
                            end
                            -- First available petws entry WITH SC properties
                            -- becomes the pet opener for skillchaining
                            -- (skips if buff already active)
                            if bst_pet_opener == nil and not buff_up and bst_pet_has_sc_props(petws[i]) then
                                bst_pet_opener = petws[i]
                            end
                            break
                        end
                    end
                end
            end
        end
    end

end

function ws_delay(duration)

  local d = tonumber(duration) or 1
  -- wsdelay/tpdelay are treated as flags elsewhere (0/1). Keep them as flags and store durations separately.
  wsdelay = 1
  tpdelay = 1
  wsdelay_time = d
  tpdelay_time = d
  wstime = os.clock()

end


local function ws_attempt_throttle()
    ws_attempt_lock = 1
    ws_attempt_time = os.clock()
end

local function ws_can_send_attempt()
    local now = os.clock()

    -- post-WS cooldown (set by weaponskill_finish)
    if wsdelay == 1 then
        return false
    end

    -- hard throttle
    if ws_attempt_lock == 1 then
        local t = ws_attempt_min or 0.34
        if (now - (ws_attempt_time or 0)) < t then
            return false
        else
            ws_attempt_lock = 0
        end
    end

    -- if a WS was accepted, we'll see weaponskill_finish soon.
    -- only retry if we've waited long enough with no finish packet.
    if ws_inflight == 1 then
        local retry = ws_retry_after or 0.34
        if (now - (ws_inflight_time or 0)) < retry then
            return false
        end
        -- allow retry attempt now
    end

    return true
end

local function ws_mark_inflight()
    ws_inflight = 1
    ws_inflight_time = os.clock()
end

local function ws_clear_inflight()
    ws_inflight = 0
    ws_inflight_time = 0
end


function pet_delay()

  petdelay = 1
  pettime = os.clock()

end


default = {}
default.Show = {burst=_static, bst=S{'BST','SMN'}, props=_static, spell=S{'SCH','BLU'}, step=_static, timer=_static, weapon=_static}
default.UpdateFrequency = 0.1
default.aeonic = false
default.color = false
default.dnc_steps = false
default.display = {text={size=12,font='Consolas'},pos={x=0,y=0},bg={visible=true}}

settings = config.load(default)
settings.dnc_steps = false
skill_props = texts.new('',settings.display,settings)
message_ids = S{110,185,187,317,802}
skillchain_ids = S{288,289,290,291,292,293,294,295,296,297,298,299,300,301,385,386,387,388,389,390,391,392,393,394,395,396,397,767,768,769,770}
buff_dur = {[163]=40,[164]=30,[470]=60}
info = {}
resonating = {}
buffs = {}
check_conf()
varclean()
check_sc()

colors = {}            -- Color codes by Sammeh
colors.Light =         '\\cs(255,255,255)'
colors.Dark =          '\\cs(0,0,204)'
colors.Ice =           '\\cs(0,255,255)'
colors.Water =         '\\cs(0,0,255)'
colors.Earth =         '\\cs(153,76,0)'
colors.Wind =          '\\cs(102,255,102)'
colors.Fire =          '\\cs(255,0,0)'
colors.Lightning =     '\\cs(255,0,255)'
colors.Gravitation =   '\\cs(102,51,0)'
colors.Fragmentation = '\\cs(250,156,247)'
colors.Fusion =        '\\cs(255,102,102)'
colors.Distortion =    '\\cs(51,153,255)'
colors.Darkness =      colors.Dark
colors.Umbra =         colors.Dark
colors.Compression =   colors.Dark
colors.Radiance =      colors.Light
colors.Transfixion =   colors.Light
colors.Induration =    colors.Ice
colors.Reverberation = colors.Water
colors.Scission =      colors.Earth
colors.Detonation =    colors.Wind
colors.Liquefaction =  colors.Fire
colors.Impaction =     colors.Lightning

skillchains = {'Light','Darkness','Gravitation','Fragmentation','Distortion','Fusion','Compression','Liquefaction','Induration','Reverberation','Transfixion','Scission','Detonation','Impaction','Radiance','Umbra'}
lightchains = S{'Light','Fragmentation','Fusion','Liquefaction','Transfixion','Detonation','Impaction','Radiance'}
darkchains = S{'Darkness','Gravitation','Distortion','Compression','Induration','Reverberation','Scission','Umbra'}

local sc_element_aliases = {
    stone = 'earth',
    earth = 'earth',
    lightning = 'thunder',
    thunder = 'thunder',
    aero = 'wind',
    wind = 'wind',
    fire = 'fire',
    ice = 'ice',
    blizzard = 'ice',
    water = 'water',
    holy = 'holy',
}

local sc_element_chains = {
    fire = S{'Liquefaction','Fusion','Light','Radiance'},
    ice = S{'Induration','Distortion','Darkness','Umbra'},
    wind = S{'Detonation','Fragmentation','Light','Radiance'},
    earth = S{'Scission','Gravitation','Darkness','Umbra'},
    thunder = S{'Impaction','Fragmentation','Light','Radiance'},
    water = S{'Reverberation','Distortion','Darkness','Umbra'},
    holy = S{'Transfixion','Fusion','Light','Radiance'},
}

local function normalize_sc_force_element(ele)
    if not ele then return nil end
    ele = tostring(ele):lower()
    return sc_element_aliases[ele]
end

sc_chain_allowed = function(chain_name)
    if not chain_name then return false end
    chain_name = tostring(chain_name)

    if light == 1 then
        return lightchains:contains(chain_name)
    end

    if dark == 1 then
        return darkchains:contains(chain_name)
    end

    if sc_force_element ~= nil then
        local allowed = sc_element_chains[sc_force_element]
        return allowed and allowed:contains(chain_name) or false
    end

    return true
end

sc_info = {
    Radiance = {'Fire','Wind','Lightning','Light', lvl=4},
    Umbra = {'Earth','Ice','Water','Dark', lvl=4},
    Light = {'Fire','Wind','Lightning','Light', Light={4,'Light','Radiance'}, lvl=3},
    Darkness = {'Earth','Ice','Water','Dark', Darkness={4,'Darkness','Umbra'}, lvl=3},
    Gravitation = {'Earth','Dark', Distortion={3,'Darkness'}, Fragmentation={2,'Fragmentation'}, lvl=2},
    Fragmentation = {'Wind','Lightning', Fusion={3,'Light'}, Distortion={2,'Distortion'}, lvl=2},
    Distortion = {'Ice','Water', Gravitation={3,'Darkness'}, Fusion={2,'Fusion'}, lvl=2},
    Fusion = {'Fire','Light', Fragmentation={3,'Light'}, Gravitation={2,'Gravitation'}, lvl=2},
    Compression = {'Darkness', Transfixion={1,'Transfixion'}, Detonation={1,'Detonation'}, lvl=1},
    Liquefaction = {'Fire', Impaction={2,'Fusion'}, Scission={1,'Scission'}, lvl=1},
    Induration = {'Ice', Reverberation={2,'Fragmentation'}, Compression={1,'Compression'}, Impaction={1,'Impaction'}, lvl=1},
    Reverberation = {'Water', Induration={1,'Induration'}, Impaction={1,'Impaction'}, lvl=1},
    Transfixion = {'Light', Scission={2,'Distortion'}, Reverberation={1,'Reverberation'}, Compression={1,'Compression'}, lvl=1},
    Scission = {'Earth', Liquefaction={1,'Liquefaction'}, Reverberation={1,'Reverberation'}, Detonation={1,'Detonation'}, lvl=1},
    Detonation = {'Wind', Compression={2,'Gravitation'}, Scission={1,'Scission'}, lvl=1},
    Impaction = {'Lightning', Liquefaction={1,'Liquefaction'}, Detonation={1,'Detonation'}, lvl=1},
}

chainbound = {}
chainbound[1] = L{'Compression','Liquefaction','Induration','Reverberation','Scission'}
chainbound[2] = L{'Gravitation','Fragmentation','Distortion'} + chainbound[1]
chainbound[3] = L{'Light','Darkness'} + chainbound[2]

local aeonic_weapon = {
    [20515] = 'Godhands',
    [20594] = 'Aeneas',
    [20695] = 'Sequence',
    [20843] = 'Chango',
    [20890] = 'Anguta',
    [20935] = 'Trishula',
    [20977] = 'Heishi Shorinken',
    [21025] = 'Dojikiri Yasutsuna',
    [21082] = 'Tishtrya',
    [21147] = 'Khatvanga',
    [21485] = 'Fomalhaut',
    [21694] = 'Lionheart',
    [21753] = 'Tri-edge',
    [22117] = 'Fail-Not',
    [22131] = 'Fail-Not',
    [22143] = 'Fomalhaut'
}

initialize = function(text, settings)
    if not windower.ffxi.get_info().logged_in then
        return
    end
    if not info.job then
        player = windower.ffxi.get_player()
        info.job = player.main_job
        info.player = player.id
    end
    local properties = L{}
    if settings.Show.timer[info.job] then
        properties:append('${timer}')
    end
    if settings.Show.step[info.job] then
        properties:append('Step: ${step} → ${name}')
    end
    if settings.Show.props[info.job] then
        properties:append('[${props}] ${elements}')
    elseif settings.Show.burst[info.job] then
        properties:append('${elements}')
    end
    properties:append('${disp_info}')
    text:clear()
    text:append(properties:concat('\n'))
    jobvar()
    if rotatews == nil then rotatews = {} end
    apply_ws_overrides()
end
skill_props:register_event('reload', initialize)

function update_weapon()
    if not settings.Show.weapon[info.job] then
        return
    end
    local main_weapon = windower.ffxi.get_items(info.main_bag, info.main_weapon).id
    if main_weapon ~= 0 then
        info.aeonic = aeonic_weapon[main_weapon] or info.range and aeonic_weapon[windower.ffxi.get_items(info.range_bag, info.range).id]
        return
    end
    if not check_weapon or coroutine.status(check_weapon) ~= 'suspended' then
        check_weapon = coroutine.schedule(update_weapon, 10)
    end
end

function aeonic_am(step)
    for x=270,272 do
        if buffs[info.player][x] then
            return 272-x < step
        end
    end
    return false
end

function aeonic_prop(ability, actor)
    if ability.aeonic and (ability.weapon == info.aeonic and actor == info.player or settings.aeonic and info.player ~= actor) then
        return {ability.skillchain[1], ability.skillchain[2], ability.aeonic}
    end
    return ability.skillchain
end

function check_props(old, new)
    for k = 1, #old do
        local first = old[k]
        local combo = sc_info[first]
        for i = 1, #new do
            local second = new[i]
            local result = combo[second]
            if result then
                return unpack(result)
            end
            if #old > 3 and combo.lvl == sc_info[second].lvl then
                break
            end
        end
    end
end

function add_skills(t, abilities, active, resource, AM)
    local tt = {{},{},{},{}}
    for k=1,#abilities do
        local ability_id = abilities[k]
        local skillchain = skills[resource][ability_id]

        -- Hide cleave WS unless cleave mode is on
        if skillchain and resource == 'weapon_skills' and skillchain.cleave and cleave ~= 1 then
            skillchain = nil
        end

        -- Job-based avoid list:
        -- hide avoided WS EXCEPT allow cleave WS when cleave mode is on
        if skillchain and resource == 'weapon_skills' then
            local wsname = res.weapon_skills[ability_id].name
            if is_avoided_ws(wsname) then
                if not (cleave == 1 and skillchain.cleave) then
                    skillchain = nil
                end
            end
        end

        if skillchain then
            local lv, prop, aeonic = check_props(active, aeonic_prop(skillchain, info.player))
            if prop then
                prop = AM and aeonic or prop
                tt[lv][#tt[lv]+1] = settings.color and
                    '%-16s → Lv.%d %s%-14s\\cr':format(res[resource][ability_id].name, lv, colors[prop], prop) or
                    '%-16s → Lv.%d %-14s':format(res[resource][ability_id].name, lv, prop)
            end
        end
    end
    for x=4,1,-1 do
        for k=#tt[x],1,-1 do
            t[#t+1] = tt[x][k]
        end
    end

    return t
end

function check_results(reson)
    local t = {}
    if settings.Show.spell[info.job] and info.job == 'SCH' then
        t = add_skills(t, {0,1,2,3,4,5,6,7}, reson.active, 'elements')
    elseif settings.Show.spell[info.job] and info.job == 'BLU' then
        t = add_skills(t, windower.ffxi.get_mjob_data().spells, reson.active, 'spells')
    elseif settings.Show.bst[info.job] and windower.ffxi.get_mob_by_target('pet') then
        t = add_skills(t, windower.ffxi.get_abilities().job_abilities, reson.active, 'job_abilities')
    end
    if settings.Show.weapon[info.job] then
        t = add_skills(t, windower.ffxi.get_abilities().weapon_skills, reson.active, 'weapon_skills', info.aeonic and aeonic_am(reson.step))
    end

    petsc = nil
    autosc = nil

    local player = windower.ffxi.get_player()
    local pet = windower.ffxi.get_abilities().job_abilities

    local chain = {}
    local chainonews = nil
    local chaintwows = nil
    if t[1] ~= nil then
        for i = 1,#t,+1 do
            if chaintwows == nil then
                chain[1] = t[i]:match("([%a\\'\\:%s]+)()(.+)")
                chain[2] = t[i]:match("Lv.%d")
                chain[3] = t[i]:match("%d%s%a+")
                if player.main_job == 'BST' or player.main_job == 'SMN' then
                    for p = 1,#pet,+1 do
                        local petclean = string.gsub(chain[1], '[ \t]+%f[\r\n%z]', '')
                        if petclean == res.job_abilities:with('id',pet[p]).name then
                            local petmp = res.job_abilities:with('en', petclean).mp_cost
                            if player.main_job == 'SMN' then
                                if (windower.ffxi.get_ability_recasts()[173] < 1) then
                                    petsc = petclean
                                    petskill = 1
                                else
                                    petskill = 1
                                end
                            elseif player.main_job == 'BST' then
                                if bst_can_ready(petmp) and bst_pet_ready_ok() then
                                    petsc = petclean
                                    petskill = 1
                                else
                                    petskill = 1
                                end
                            end
                        else
                            petskill = 0
                        end
                    end
                end
                if petskill == 0 then
                    if melee == 1 then
                        if skills.is_ranged_ws(chain[1]) then
                            meleeskill = 1
                        else
                            meleeskill = 0
                        end
                    end
                    if meleeskill == 0 then
                        local chainoneele = string.gsub(chain[3], '%d%s', '')
                        if sc_chain_allowed(chainoneele) then
                            if chainonews == nil then
                                chainonelvl = chain[2]
                                chainonews = chain[1]
                            elseif chaintwows == nil then
                                chaintwolvl = chain[2]
                                chaintwows = chain[1]
                            end
                        end
                    end
                end
            end
        end
    elseif close == 0 then
        chainonews = openws
    end

    local endlesssc = nil
    if endless == 1 then
        for i = 1,#t,+1 do
            if endlesssc == nil then
                local endlesschk = {}
                endlesschk[1] = t[i]:match("([%a\\'\\:%s]+)()(.+)")
                endlesscln = string.gsub(endlesschk[1], '[ \t]+%f[\r\n%z]', '')
                endlesschk[2] = t[i]:match("Lv.%d")
                endlesslvl = endlesschk[2]
                endlesschk[3] = t[i]:match("%d%s%a+")
                local endlessele = string.gsub(endlesschk[3], '%d%s', '')
                if endlesssc == nil then
                    if endlesslvl == "Lv.2" or endlesslvl == "Lv.1" then
                        if ranged == 1 then
                            if skills.is_ranged_ws(endlesscln) then
                                if sc_chain_allowed(endlessele) then
                                    endlesssc = endlesscln
                                end
                            end
                        else
                            if sc_chain_allowed(endlessele) then
                                endlesssc = endlesscln
                            end
                        end
                    end
                end
            end
        end
    end

    local prefersc = nil
    if (prefer == 1 or strict == 1) and ranged == 0 then
        for p = 1,#preferws,+1 do
            for i = 1,#t,+1 do
                if prefersc == nil then
                    local preferchk = {}
                    preferchk[1] = t[i]:match("([%a\\'\\:%s]+)()(.+)")
                    preferchkcln = string.gsub(preferchk[1], '[ \t]+%f[\r\n%z]', '')
                    preferchk[2] = t[i]:match("Lv.%d")
                    preferlvl = preferchk[2]
                    preferchk[3] = t[i]:match("%d%s%a+")
                    preferele = string.gsub(preferchk[3], '%d%s', '')
                    if preferws[p] == preferchkcln then
                        if sc_chain_allowed(preferele) and prefersc == nil then
                            prefersc = preferchkcln
                        end
                    end
                end
            end
        end
    end

    local rangedwsone = nil
    local rangedwstwo = nil
    if ranged == 1 then
        if (prefer == 1 or strict == 1) then
            for p = 1,#preferws,+1 do
                if skills.is_ranged_ws(preferws[p]) then
                    for i = 1,#t,+1 do
                        if prefersc == nil then
                            local preferchk = {}
                            preferchk[1] = t[i]:match("([%a\\'\\:%s]+)()(.+)")
                            preferchkcln = string.gsub(preferchk[1], '[ \t]+%f[\r\n%z]', '')
                            preferchk[2] = t[i]:match("Lv.%d")
                            preferlvl = preferchk[2]
                            preferchk[3] = t[i]:match("%d%s%a+")
                            preferele = string.gsub(preferchk[3], '%d%s', '')
                            if preferws[p] == preferchkcln then
                                if sc_chain_allowed(preferele) and prefersc == nil then
                                    prefersc = preferchkcln
                                end
                            end
                        end
                    end
                end
            end
        end
        if prefer == 0 or prefersc == nil then
            for i = 1,#t,+1 do
                local rangedchk = {}
                rangedchk[1] = t[i]:match("([%a\\'\\:%s]+)()(.+)")
                rangedchkcln = string.gsub(rangedchk[1], '[ \t]+%f[\r\n%z]', '')
                rangedchk[2] = t[i]:match("Lv.%d")
                rangedchk[3] = t[i]:match("%d%s%a+")
                rangedele = string.gsub(rangedchk[3], '%d%s', '')
                if skills.is_ranged_ws(rangedchkcln) then
                    if rangedwsone == nil then
                        if sc_chain_allowed(rangedele) then
                            rangedwsone = rangedchkcln
                            rangedlvlone = rangedchk[2]
                        end
                    elseif rangedwstwo == nil then
                        if sc_chain_allowed(rangedele) then
                            rangedwstwo = rangedchkcln
                            rangedlvltwo = rangedchk[2]
                        end
                    end
                end
            end
        end
    end

    if ranged == 1 then
        if prefersc ~= nil then
            if ultimate == 1 then
                if preferlvl == "Lv.4" then
                    autosc = prefersc
                end
            else
                autosc = prefersc
            end
        elseif strict == 1 and prefersc == nil then
            autosc = nil
        elseif endlesssc ~= nil then
            autosc = endlesssc
        else
            if rangedlvlone == "Lv.4" and ultimate == 1 then
                autosc = rangedwsone
            elseif ultimate == 0 then
                if rangedwstwo == nil then
                    autosc = rangedwsone
                elseif rangedlvlone == "Lv.4" then
                    autosc = rangedwstwo
                else
                    autosc = rangedwsone
                end
            end
        end
    else
        if prefersc ~= nil then
            if ultimate == 1 then
                if preferlvl == "Lv.4" then
                    autosc = prefersc
                end
            else
                autosc = prefersc
            end
        elseif strict == 1 and prefersc == nil then
            autosc = nil
        elseif endlesssc ~= nil then
            autosc = endlesssc
        else
            if chainonelvl == "Lv.4" and ultimate == 1 then
                autosc = chainonews
            elseif ultimate == 0 then
                if chaintwows == nil then
                    autosc = chainonews
                elseif chainonelvl == "Lv.4" then
                    autosc = chaintwows
                else
                    autosc = chainonews
                end
            end
        end
    end

    return _raw.table.concat(t, '\n')
end

function colorize(t)
    local temp
    if settings.color then
        temp = {}
        for k=1,#t do
            temp[k] = '%s%s\\cr':format(colors[t[k]], t[k])
        end
    end
    return _raw.table.concat(temp or t, ',')
end

local next_frame = os.clock()

-- Frame pacing defaults (prevents nil arithmetic if not defined elsewhere)
current_frame = current_frame or os.clock()
interval = interval or 0.1

windower.register_event('target change', function()

    if starter == 1 then
        started = 0
    end

end)


function precast(spell)
    if spell and spell.action_type == 'Magic' then
        casting_spell = true
    end
end

function aftercast(spell)
    if spell and spell.action_type == 'Magic' then
        casting_spell = false
    end
end

function spell_interrupt(spell)
    if spell and spell.action_type == 'Magic' then
        casting_spell = false
    end
end

local function stop_strafe()
    if face_strafe_left_down == 1 then
        windower.send_command('setkey numpad4 up')
        face_strafe_left_down = 0
    end
    if face_strafe_right_down == 1 then
        windower.send_command('setkey numpad6 up')
        face_strafe_right_down = 0
    end
end

local function set_strafe(dir)
    if dir == 'left' then
        if face_strafe_right_down == 1 then
            windower.send_command('setkey numpad6 up')
            face_strafe_right_down = 0
        end
        if face_strafe_left_down == 0 then
            windower.send_command('setkey numpad4 down')
            face_strafe_left_down = 1
        end
    elseif dir == 'right' then
        if face_strafe_left_down == 1 then
            windower.send_command('setkey numpad4 up')
            face_strafe_left_down = 0
        end
        if face_strafe_right_down == 0 then
            windower.send_command('setkey numpad6 down')
            face_strafe_right_down = 1
        end
    else
        stop_strafe()
    end
end

local function stop_forward(force)
    if force or face_forward_down == 1 then
        windower.send_command('setkey numpad8 up')
        face_forward_down = 0
    end
end

local function stop_back(force)
    if force or face_back_down == 1 then
        windower.send_command('setkey numpad2 up')
        face_back_down = 0
    end
end

local function set_forward(down)
    if down then
        stop_back(false)
        if face_forward_down == 0 then
            windower.send_command('setkey numpad8 down')
            face_forward_down = 1
        end
    else
        stop_forward(false)
    end
end

local function set_back(down)
    if down then
        stop_forward(false)
        if face_back_down == 0 then
            windower.send_command('setkey numpad2 down')
            face_back_down = 1
        end
    else
        stop_back(false)
    end
end

local function force_stop_movement()
    windower.send_command('setkey numpad8 up;setkey numpad2 up;setkey numpad4 up;setkey numpad6 up')
    face_forward_down = 0
    face_back_down = 0
    face_strafe_left_down = 0
    face_strafe_right_down = 0
    face_approach_active = 0
end


-- Face Mode lockon state helpers
local face_lockon_warned = 0

local function get_lockon_state()
    local p = windower.ffxi.get_player()
    if not p then return nil end

    -- Different Windower/Windower4 builds have exposed different field names over time.
    -- We try a few common ones. If none exist, return nil (unknown).
    if p.target_locked ~= nil then return p.target_locked end
    if p.locked_on ~= nil then return p.locked_on end
    if p.locked ~= nil then return p.locked end
    if p.lockon ~= nil then return p.lockon end
    if p.is_locked ~= nil then return p.is_locked end
    return nil
end

local function face_try_lockon(now, reason)
    if face ~= 1 then return end

    local state = get_lockon_state()

    -- If we cannot read lock state, do not toggle /lockon at all.
    -- /lockon is a toggle, so guessing would reintroduce the flip-flop bug.
    if state == nil then
        if face_lockon_warned == 0 then
            windower.add_to_chat(207, '%s: Face Mode: lock state is not readable (unknown). Lockon enforcement is disabled to avoid toggling it OFF by mistake.':format(_addon.name))
            face_lockon_warned = 1
        end
        return
    end

    -- Only toggle /lockon when we believe lock is OFF.
    if state == true or state == 1 then
        return
    end

    local cd = 0.90
    if reason == 'stuck' then cd = 2.20 end
    if reason == 'probe' then cd = 2.20 end
    if reason == 'force' then cd = 2.00 end
    if reason == 'unable_to_see' then cd = 2.20 end

    if (now - (face_lockon_last_time or 0)) >= cd then
        windower.send_command('input /lockon')
        face_lockon_last_time = now
    end
end


-- Tier-1 Nuke Spam (separate from existing //sc autonuke MB mode)
nukespam = 0
nukespam_force_ele = nil
nukespam_next_allowed = 0

nukespam_debug = 0

local nukespam_day_map = {
    Firesday = 'fire',
    Earthsday = 'stone',
    Watersday = 'water',
    Windsday = 'aero',
    Iceday = 'blizzard',
    Lightningday = 'thunder',
    Lightsday = 'fire', -- default Fire on Light day
    Darksday = 'fire',  -- default Fire on Dark day
}

-- True burst element per command. Used for both the burst force (nukes.set_force_mb)
-- and the nukespam force; nukespam coerces dark/holy to fire (no tier-1 dark/holy nuke).
local nukespam_mb_map = {
    thundermb = 'thunder',
    icemb = 'blizzard',
    blizzardmb = 'blizzard',
    firemb = 'fire',
    windmb = 'aero',
    aeromb = 'aero',
    watermb = 'water',
    stonemb = 'stone',
    earthmb = 'stone',
    darkmb = 'dark',
    lightmb = 'holy',
    holymb = 'holy',
}

local function nukespam_ele_for(true_ele)
    if true_ele == 'dark' or true_ele == 'holy' then return 'fire' end
    return true_ele
end

local function nukespam_spell_for_element(ele, main_job)
    if main_job == 'NIN' then
        if ele == 'fire' then return 'Katon: Ichi' end
        if ele == 'blizzard' then return 'Hyoton: Ichi' end
        if ele == 'aero' then return 'Huton: Ichi' end
        if ele == 'stone' then return 'Doton: Ichi' end
        if ele == 'water' then return 'Suiton: Ichi' end
        if ele == 'thunder' then return 'Raiton: Ichi' end
        return nil
    end
    if ele == 'fire' then return 'Fire' end
    if ele == 'blizzard' then return 'Blizzard' end
    if ele == 'aero' then return 'Aero' end
    if ele == 'stone' then return 'Stone' end
    if ele == 'water' then return 'Water' end
    if ele == 'thunder' then return 'Thunder' end
    return nil
end

local function nukespam_party_claim_ok(mob)
    if not mob or not mob.claim_id then return false end
    local cid = mob.claim_id
    if cid == 0 then return false end
    local party = windower.ffxi.get_party()
    if not party then return false end

    -- collect all known party/alliance ids (claim_id is a player/monster id)
    local function id_ok(entry)
        if not entry then return false end
        if entry.mob and entry.mob.id and entry.mob.id == cid then return true end
        if entry.id and entry.id == cid then return true end
        return false
    end

    -- player
    if id_ok(party.p0) then return true end

    -- party slots p0..p5
    for i = 0, 5 do
        local key = 'p'..tostring(i)
        if id_ok(party[key]) then return true end
    end
    -- alliance a10..a15, a20..a25
    for i = 10, 25 do
        local key = 'a'..tostring(i)
        if id_ok(party[key]) then return true end
    end
    return false
end

-- Fallback preference when weather/day elements are excluded via //sc no<ele>.
-- Order is a documented default (roughly descending tier-1 utility), not derived
-- from game state; reorder here if desired.
local nukespam_fallback_order = { 'thunder', 'blizzard', 'fire', 'aero', 'water', 'stone' }

local function nukespam_resolve_element()
    -- 1) manual force via //sc <element>mb
    local excluded_hit = false
    local ele = nukespam_force_ele
    if ele and (ele == 'light' or ele == 'dark' or ele == 'holy') then ele = 'fire' end
    -- Forced element that is also excluded -> no cast (matches burst behavior).
    if ele and nukes.is_excluded(ele) then return nil end

    -- 2) weather (natural or storm)
    if not ele then
        local info = windower.ffxi.get_info()
        if info and info.weather and res and res.weather and res.weather[info.weather] then
            ele = res.weather[info.weather].element
            -- res.weather[x].element can be a string or a numeric element id depending on resources version
            if type(ele) == 'number' then
                local id_map = { [0]='fire', [1]='blizzard', [2]='aero', [3]='stone', [4]='thunder', [5]='water', [6]='light', [7]='dark' }
                ele = id_map[ele] or ele
            end
            if type(ele) == 'string' then ele = ele:lower() end
            -- normalize synonyms to internal element keys
            if ele == 'ice' then ele = 'blizzard' end
            if ele == 'wind' then ele = 'aero' end
            if ele == 'earth' then ele = 'stone' end
            if ele == 'lightning' then ele = 'thunder' end
            if ele == 'light' or ele == 'dark' or ele == 'holy' then ele = nil end
            -- Excluded weather element: fall through to day resolution.
            if ele and nukes.is_excluded(ele) then ele = nil; excluded_hit = true end
        end
    end

    -- 3) day
    if not ele then
        local info = windower.ffxi.get_info()
        if info and info.day then
            local daykey = info.day
            if type(daykey) == 'number' and res and res.days and res.days[daykey] and res.days[daykey].en then
                daykey = res.days[daykey].en
            end
            if type(daykey) == 'string' then
                ele = nukespam_day_map[daykey]
            end
            -- Excluded day element: fall through to the fixed fallback order.
            if ele and nukes.is_excluded(ele) then ele = nil; excluded_hit = true end
        end
    end

    -- 4) fallback: first non-excluded element in the documented order.
    -- Only reached when an exclusion caused the miss, so baseline behavior is
    -- unchanged when no exclusions are set.
    if not ele and excluded_hit then
        for _, cand in ipairs(nukespam_fallback_order) do
            if not nukes.is_excluded(cand) then
                ele = cand
                break
            end
        end
    end

    return ele
end

local function nukespam_tick(now)
    if nukespam ~= 1 then return end

    local function dbg(msg)
        if nukespam_debug == 1 then
            windower.add_to_chat(8, ('%s: nukespam dbg: %s'):format(_addon.name, msg))
        end
    end

    local player = windower.ffxi.get_player()
    if not player then dbg('no player'); return end

    -- On NIN main, nukespam is just an alias for //sc wheel (toggled in the
    -- command handler). The actual rotation is handled by wheel_tick. Bail out
    -- here so we never double-cast even if state somehow desyncs.
    if player.main_job == 'NIN' then dbg('nin: handled by wheel'); return end

    if casting_spell then dbg('casting_spell'); return end
    if wsdelay ~= 0 then dbg('wsdelay '..tostring(wsdelay)); return end
    if disabled == 1 then dbg('disabled'); return end
    if (nukespam_next_allowed or 0) > now then dbg('throttle '..tostring((nukespam_next_allowed or 0) - now)); return end

    local targ = windower.ffxi.get_mob_by_target('t')
    if not targ then dbg('no target'); return end
    if not targ.is_npc then dbg('target not npc'); return end
    if not targ.hpp then dbg('no hpp'); return end
    if targ.hpp <= 0 or targ.hpp >= 100 then dbg('hpp gate '..tostring(targ.hpp)); return end

    if not nukespam_party_claim_ok(targ) then
        dbg('claim gate claim_id='..tostring(targ.claim_id))
        return
    end

    if autonuke == 1 and resonating and targ and targ.id then
        local r = resonating[targ.id]
        if r then
            local timer = 0
            if r.times then
                timer = (r.times - now) or 0
            end
            if timer > 0 and (r.step or 0) >= 1 then
                dbg('autonuke resonance gate step='..tostring(r.step)..' timer='..tostring(timer))
                return
            end
        end
    end

    local ele = nukespam_resolve_element()
    if not ele then dbg('no element (weather/day/force)'); return end

    local spell = nukespam_spell_for_element(ele, player.main_job)
    if not spell then dbg('no spell for ele='..tostring(ele)..' job='..tostring(player.main_job)); return end

    local delay = 2.4
    local sp = res and res.spells and res.spells:with('en', spell)
    if sp and sp.cast_time then
        local fc = fastcast or 0
        if fc < 0 then fc = 0 end
        if fc > 0.8 then fc = 0.8 end
        delay = (sp.cast_time * (1 - fc)) + 2.1
    else
        delay = 2.1
    end

    nukespam_next_allowed = now + delay
    dbg('cast '..spell..' ele='..tostring(ele)..' next='..tostring(delay))
    windower.send_command('input /ma "' .. spell .. '" <t>')
end

windower.register_event('prerender', function()

    if not windower.ffxi.get_player() then return end

    local p = windower.ffxi.get_player()
    if not p then return end

    local stmob = windower.ffxi.get_mob_by_target('st')
    local st_active = (stmob ~= nil)
    if p.status == 4 then return end

    -- Subtarget (items, menu actions, etc.) can temporarily switch 'st' to yourself.
    -- During Face/Yonin/Innin movement automation, treat any active subtarget as a hard pause
    -- to prevent unintended strafing/forward movement while you are using items like food.
    if st_active and (face == 1 or yonin == 1 or innin == 1 or petmode == 1 or petface == 1 or rear == 1) then
        stop_strafe()
        stop_forward()
        face_approach_active = 0
        return
    end

    local now = os.clock()

    if now < next_frame then
        return
    end

    next_frame = now + 0.1

    if ws_attempt_lock == 1 then
        local t = ws_attempt_min or 0.34
        if (now - (ws_attempt_time or 0)) >= t then
            ws_attempt_lock = 0
        end
    end

    if now > current_frame + interval then
        current_frame = now

        for k, v in pairs(resonating) do
            if v.times - now + 10 < 0 then
                resonating[k] = nil
            end
        end

        local player = windower.ffxi.get_player()
        local tp = player.vitals.tp
        local status = player.status
        -- Movement key safety: on disengage, force-release movement keys immediately and again 1s later.
        if last_status_for_release == 1 and status ~= 1 then
            force_stop_movement()
            windower.send_command('wait 1;setkey numpad8 up;setkey numpad4 up;setkey numpad6 up')
        end
        last_status_for_release = status

        local buffs = L(player.buffs)

        if buffs:contains(2) or
        buffs:contains(7) or
        buffs:contains(10) or
        buffs:contains(14) or
        buffs:contains(16) or
        buffs:contains(17) or
        buffs:contains(19) or
        buffs:contains(28) or
        buffs:contains(156) then
            disabled = 1
        else
            disabled = 0
        end

        if am == 1 then
            if buffs:contains(272) then
                amthree = 0
            else
                amthree = 1
            end
        elseif am == 0 then
            amthree = 0
        end

        local party = windower.ffxi.get_party()
        if party.p1 ~= nil then
            player1 = windower.ffxi.get_mob_by_name(party.p1.name)
        end
        if player1 == nil or party.p1 == nil then
            p1tp = 0
            p1st = 0
        elseif player1.is_npc or ignoretp:contains(party.p1.name) then
            p1tp = 0
            p1st = 0
        else
            p1tp = party.p1.tp
            p1st = player1.status
        end
        if party.p2 ~= nil then
            player2 = windower.ffxi.get_mob_by_name(party.p2.name)
        end
        if player2 == nil or party.p2 == nil then
            p2tp = 0
            p2st = 0
        elseif player2.is_npc or ignoretp:contains(party.p2.name) then
            p2tp = 0
            p2st = 0
        else
            p2tp = party.p2.tp
            p2st = player2.status
        end
        if party.p3 ~= nil then
            player3 = windower.ffxi.get_mob_by_name(party.p3.name)
        end
        if player3 == nil or party.p3 == nil then
            p3tp = 0
            p3st = 0
        elseif player3.is_npc or ignoretp:contains(party.p3.name) then
            p3tp = 0
            p3st = 0
        else
            p3tp = party.p3.tp
            p3st = player3.status
        end
        if party.p4 ~= nil then
            player4 = windower.ffxi.get_mob_by_name(party.p4.name)
        end
        if player4 == nil or party.p4 == nil then
            p4tp = 0
            p4st = 0
        elseif player4.is_npc or ignoretp:contains(party.p4.name) then
            p4tp = 0
            p4st = 0
        else
            p4tp = party.p4.tp
            p4st = player4.status
        end
        if party.p5 ~= nil then
            player5 = windower.ffxi.get_mob_by_name(party.p5.name)
        end
        if player5 == nil or party.p5 == nil then
            p5tp = 0
            p5st = 0
        elseif player5.is_npc or ignoretp:contains(party.p5.name) then
            p5tp = 0
            p5st = 0
        else
            p5tp = party.p5.tp
            p5st = player5.status
        end

        if buddy == 1 then
            if (tp > p1tp or p1tp < 1000 or (tp == 3000 and p1tp == 3000) or p1st ~= 1) and
            (tp > p2tp or p2tp < 1000 or (tp == 3000 and p2tp == 3000) or p2st ~= 1) and
            (tp > p3tp or p3tp < 1000 or (tp == 3000 and p3tp == 3000) or p3st ~= 1) and
            (tp > p4tp or p4tp < 1000 or (tp == 3000 and p4tp == 3000) or p4st ~= 1) and
            (tp > p5tp or p5tp < 1000 or (tp == 3000 and p5tp == 3000) or p5st ~= 1) then
                if os.clock() - tagtime > tagdelay then
                    tagin = 0
                end
            else
                tagin = 1
                tagtime = os.clock()
            end
        end

        if wsdelay == 1 then
            local t = (wsdelay_time or 2.0)
            if os.clock() - wstime > t then
                wsdelay = 0
                wsdelay_time = nil
            end
        end

        if tpdelay == 1 then
            local t = (tpdelay_time or 0.5)
            if os.clock() - wstime > t then
                tpdelay = 0
                tpdelay_time = nil
            end
        end

        if petdelay == 1 then
            if os.clock() - pettime > 1.25 then
                petdelay = 0
            end
        end

        if player.main_job == 'BST' then
            -- sicdelay = charges currently on cooldown (0-3).
            -- bst_ready_charges_available() returns available charges;
            -- invert to get the legacy sicdelay value other code expects.
            sicdelay = 3 - bst_ready_charges_available()
        end

        if player.main_job == 'SMN' then
            if (windower.ffxi.get_ability_recasts()[173] > 0) then
                bpdelay = 1
            else
                bpdelay = 0
            end
        end

        if autosc ~= nil and info.job ~= 'SMN' and info.job ~= 'BST' and info.job ~= 'SCH' then
            wsclean = string.gsub(autosc, '[ \t]+%f[\r\n%z]', '')
            wsrange = res.weapon_skills:with('en',wsclean).range
        elseif openws ~= nil then
            wsrange = res.weapon_skills:with('en',openws).range
        else
            wsrange = 0
        end

        if windower.ffxi.get_player().target_index ~= nil then
            local targetmob = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().target_index)
            local mobsize = targetmob.model_size
            local mobscale = targetmob.model_scale
            mobdist = targetmob.distance:sqrt()
            if ranged == 1 then
                wsdist = 21
            else
                wsdist = mobsize + wsrange + (0.21 + (0.21 * mobsize))
            end
        else
            mobdist = 50
            wsdist = 0
        end

        if wsdist < 3.5 then
            wsdist = 3.5
        end

        if innin == 1 and status == 1 then
            local lm = windower.ffxi.get_mob_by_target('t') or windower.ffxi.get_mob_by_target('st')

            -- No valid target or target is dead: release movement keys and do nothing
            if not (lm and lm.id and lm.hpp and lm.hpp > 0) then
                stop_strafe()
                stop_forward()
                stop_back()
                innin_last_target_key = nil
                innin_new_target_backtap_until = 0
            elseif casting_spell then
                stop_strafe()
                stop_forward()
                stop_back()
                innin_new_target_backtap_until = 0
            else
                local lock_state = get_lockon_state()
                if lock_state ~= nil and (lock_state == false or lock_state == 0) then
                    -- When lockon is OFF, pause Innin/Yonin positional strafing so you can intentionally run away.
                    stop_strafe()
                    stop_forward()
                    stop_back()
                    innin_new_target_backtap_until = 0
                else
                    -- New/switch target re-face tap: a tiny back step to force the client to face the new mob.
                    do
                        local key = tostring(lm.id)..':'..tostring(lm.index)
                        if key ~= innin_last_target_key then
                            innin_last_target_key = key
                            innin_new_target_backtap_until = 0

                            if mobdist <= (wsdist + 0.5) then
                                stop_strafe()
                                set_back(true)
                                innin_new_target_backtap_until = now + 0.04
                            end
                        end
                    end

                    if innin_new_target_backtap_until ~= 0 and now < innin_new_target_backtap_until then
                        stop_strafe()
                        set_back(true)
                    else
                        if innin_new_target_backtap_until ~= 0 then
                            innin_new_target_backtap_until = 0
                            stop_back(false)
                        end

                        if (mobdist < wsdist) then
                            if player.main_job == 'NIN' then
                                if faw == 0 then
                                    behind()
                                end
                            else
                                behind()
                            end
                        else
                            -- Out of range: never keep movement keys held
                            stop_strafe()
                            stop_forward()
                            stop_back()
                        end
                    end
                end
            end


        elseif yonin == 1 and status == 1 then
            local lm = windower.ffxi.get_mob_by_target('t') or windower.ffxi.get_mob_by_target('st')

            -- No valid target or target is dead: release movement keys and do nothing
            if not (lm and lm.id and lm.hpp and lm.hpp > 0) then
                stop_strafe()
                stop_forward()
                stop_back()
                yonin_last_target_key = nil
                yonin_new_target_backtap_until = 0
            elseif casting_spell then
                stop_strafe()
                stop_forward()
                stop_back()
                yonin_new_target_backtap_until = 0
            else
                local lock_state = get_lockon_state()
                if lock_state ~= nil and (lock_state == false or lock_state == 0) then
                    -- When lockon is OFF, pause Innin/Yonin positional strafing so you can intentionally run away.
                    stop_strafe()
                    stop_forward()
                    stop_back()
                    yonin_new_target_backtap_until = 0
                else
                    -- New/switch target re-face tap: a tiny back step to force the client to face the new mob.
                    do
                        local key = tostring(lm.id)..':'..tostring(lm.index)
                        if key ~= yonin_last_target_key then
                            yonin_last_target_key = key
                            yonin_new_target_backtap_until = 0

                            if mobdist <= (wsdist + 0.5) then
                                stop_strafe()
                                set_back(true)
                                yonin_new_target_backtap_until = now + 0.04
                            end
                        end
                    end

                    if yonin_new_target_backtap_until ~= 0 and now < yonin_new_target_backtap_until then
                        stop_strafe()
                        set_back(true)
                    else
                        if yonin_new_target_backtap_until ~= 0 then
                            yonin_new_target_backtap_until = 0
                            stop_back(false)
                        end

                        if (mobdist < wsdist) then
                            front()
                        else
                            -- Out of range: never keep movement keys held
                            stop_strafe()
                            stop_forward()
                            stop_back()
                        end
                    end
                end
            end


        elseif (face == 1 or rear == 1 or petface == 1) and status == 1 then
            -- Select the positioning function based on active mode
            local face_position_fn = face_front
            if rear == 1 then face_position_fn = behind end
            if petface == 1 then face_position_fn = pet_side end

            local targ = windower.ffxi.get_mob_by_target('t')
            local st = windower.ffxi.get_mob_by_target('st')
            local lm = targ or st

            -- petface requires a live pet; fall back to idle if pet is gone
            if petface == 1 and not windower.ffxi.get_mob_by_target('pet') then
                stop_strafe()
                stop_forward()
                stop_back()
                face_approach_active = 0
                face_walk_hold_start = 0
                face_walk_hold_start_dist = nil
                face_walk_force_stop_until = 0
            elseif not (lm and lm.id and lm.hpp and lm.hpp > 0) then
                stop_strafe()
                stop_forward()
                stop_back()
                face_approach_active = 0
                face_last_target_key = nil
                face_probe_until = 0
                face_probe_start_dist = nil
                face_probe_start_time = 0
                face_new_target_tap_until = 0
                face_new_target_backtap_until = 0
                face_force_step_until = 0
                face_walk_hold_start = 0
                face_walk_hold_start_dist = nil
                face_walk_force_stop_until = 0

                if (now - (face_ta_last_time or 0)) >= 1.0 then
                    windower.send_command('input /ta <bt>')
                    face_ta_last_time = now
                end
            else
                -- If we only have a subtarget but no true target, try to acquire the battle target once in a while.
                if not targ then
                    if (now - (face_ta_last_time or 0)) >= 1.0 then
                        windower.send_command('input /ta <bt>')
                        face_ta_last_time = now
                    end
                end

                -- Never move while casting or while mid-action
                if casting_spell then
                    stop_forward()
                    stop_back()
                    stop_strafe()
                    face_approach_active = 0
                    face_walk_hold_start = 0
                    face_walk_hold_start_dist = nil
                    face_walk_force_stop_until = 0
                else
                    local lock_state = get_lockon_state()

                    -- If lockon is currently OFF, do not keep pushing movement. Re-enable lock first,
                    -- then let normal Face movement resume on later ticks.
                    if lock_state ~= nil and (lock_state == false or lock_state == 0) then
                        stop_forward()
                        stop_back()
                        stop_strafe()
                        face_approach_active = 0
                        face_walk_hold_start = 0
                        face_walk_hold_start_dist = nil
                        face_walk_force_stop_until = 0
                        if targ and targ.id and targ.hpp and targ.hpp > 0 then
                            face_try_lockon(now, 'ensure')
                        end
                    else
                        -- Keep lockon enabled in Face Mode.
                        -- /lockon is a toggle, so we ONLY send it when we can read lock state and believe it is OFF.
                        -- If lock state is not readable, enforcement falls back to the conservative recovery calls.
                        if targ and targ.id and targ.hpp and targ.hpp > 0 then
                            face_try_lockon(now, 'ensure')
                        end

                    -- Face Mode: new-target probe while engaged (no movement outside engaged).
                    -- If a new target is acquired while already engaged, do a very short forward tap to confirm we're actually closing distance.
                    -- If distance does not decrease as expected, do a rare /lockon toggle to recover.
                    do
                        local key = tostring(lm.id)..':'..tostring(lm.index)
                        if key ~= face_last_target_key then
                            face_last_target_key = key
                            face_probe_start_dist = mobdist
                            face_probe_start_time = now
                            face_probe_until = 0
                            face_edge_tap_until = 0
                            face_force_step_until = 0
                            face_walk_hold_start = 0
                            face_walk_hold_start_dist = nil
                            face_walk_force_stop_until = 0

                            -- Immediate acquire behavior on any newly engaged / newly swapped live target.
                            -- If we are outside WS distance, do the normal short forward walk-up.
                            -- If we are already inside WS distance, do a tiny back tap instead so the client
                            -- re-faces the new mob without walking deeper into hitbox range.
                            if mobdist > wsdist then
                                stop_strafe()
                                set_forward(true)
                                face_new_target_backtap_until = 0

                                if mobdist > (wsdist + 1.5) then
                                    face_new_target_tap_until = now + 0.08
                                elseif mobdist > (wsdist + 0.6) then
                                    face_new_target_tap_until = now + 0.10
                                else
                                    face_new_target_tap_until = now + 0.06
                                end
                            else
                                stop_strafe()
                                set_back(true)
                                face_new_target_tap_until = 0

                                if mobdist <= 0.7 then
                                    face_new_target_backtap_until = now + 0.03
                                else
                                    face_new_target_backtap_until = now + 0.04
                                end
                            end
                        end

                        -- If we recently got an "unable to see" message while engaged and in melee range, force a lockon recovery once.
                        if face_last_unable_to_see_time ~= 0 and (now - face_last_unable_to_see_time) <= 1.0 and mobdist <= (wsdist + 0.5) then
                            face_try_lockon(now, 'unable_to_see')
                            face_last_unable_to_see_time = 0
                        end
                    end

                    -- Hysteresis prevents twitching at the edge of WS range
                    -- Rear mode: target 1 yalm closer to stay reliably in range while strafing
                    local target_dist = wsdist
                    if rear == 1 then target_dist = math.max(1.0, wsdist - 1.0) end

                    local startdist = target_dist + 0.6
                    local stopdist = math.max(0.5, target_dist - 0.1)

                    -- New-target probe: brief forward tap, then verify distance is closing; otherwise try a rare /lockon recovery.
                    if face_probe_until ~= 0 then
                        if now < face_probe_until then
                            stop_strafe()
                            set_forward(true)
                            face_approach_active = 1
                        else
                            -- Probe window ended: if we did not get closer, attempt lockon once.
                            if face_probe_start_dist ~= nil then
                                -- Only attempt a recovery lockon if we clearly did not close distance during the probe.
                                -- This avoids lockon toggle spam when mobs are stacked and shuffling.
                                if mobdist >= (face_probe_start_dist - 0.15) then
                                    face_try_lockon(now, 'probe')
                                end
                            end
                            face_probe_until = 0
                            face_probe_start_dist = nil
                            face_probe_start_time = 0
                        end
                    end

                    -- If we're probing, skip the rest of the movement decision this tick.
                    if face_probe_until ~= 0 and now < face_probe_until then
                        -- do nothing else this tick
                    else
                        -- Message-triggered recovery step takes priority over the tiny new-target backtap.
                        -- This fixes the case where we are visually in front of the mob at WS distance,
                        -- get an out-of-range message, but a residual backtap would otherwise block the walk-up nudge.
                        if face_force_step_until ~= 0 and now < face_force_step_until then
                            stop_strafe()
                            stop_back()
                            set_forward(true)
                            face_approach_active = 1

                            if face_force_lockon_until ~= 0 and now < face_force_lockon_until then
                                face_try_lockon(now, 'force_step')
                                face_force_lockon_until = 0
                            end

                        elseif face_new_target_backtap_until ~= 0 and now < face_new_target_backtap_until then
                            stop_strafe()
                            set_back(true)
                            face_approach_active = 0

                        -- Forced approach window (triggered by out-of-range text while still outside WS distance).
                        elseif face_force_approach_until ~= 0 and now < face_force_approach_until then
                            if mobdist > target_dist then
                                stop_strafe()
                                set_forward(true)
                                face_approach_active = 1
                            else
                                stop_forward()
                                stop_back()
                                face_approach_active = 0
                                face_force_approach_until = 0
                            end

                            -- Nudge lockon once when the forced window begins (helps when facing/target state is desynced)
                            if face_force_lockon_until ~= 0 and now < face_force_lockon_until then
                                face_try_lockon(now, 'force')
                                face_force_lockon_until = 0
                            end

                        else
                        if mobdist <= stopdist then
                        stop_forward()
                        stop_back()
                        face_approach_active = 0
                        face_increasing_since = 0
                        face_trend_last_dist = nil
                        face_walk_hold_start = 0
                        face_walk_hold_start_dist = nil
                        face_walk_force_stop_until = 0
                        face_position_fn()
                    elseif mobdist <= target_dist then
                        stop_forward()
                        stop_back()
                        face_approach_active = 0
                        face_increasing_since = 0
                        face_trend_last_dist = nil
                        face_walk_hold_start = 0
                        face_walk_hold_start_dist = nil
                        face_walk_force_stop_until = 0
                        face_position_fn()
                    else
                        -- Out of range: continuous walk-up. Hold forward until we reach WS distance.
                        -- set_forward(true) is idempotent (only sends keydown if not already down),
                        -- so calling it every tick is safe. A stuck-detector watchdog below force-stops
                        -- if forward has been held without distance decreasing, restoring the safety
                        -- the previous tap pattern provided.

                        -- Force-stop window from the watchdog: if active, do nothing else this tick.
                        -- After the window expires, the next tick falls through and resumes walking.
                        if face_walk_force_stop_until ~= 0 and now < face_walk_force_stop_until then
                            stop_strafe()
                            stop_back()
                            stop_forward()
                            face_approach_active = 0
                        else
                            if face_walk_force_stop_until ~= 0 then
                                face_walk_force_stop_until = 0
                            end

                            stop_strafe()
                            stop_back()
                            set_forward(true)
                            face_approach_active = 1
                            face_edge_tap_until = 0  -- legacy var kept zeroed for compatibility

                            -- Begin watchdog window the first tick we start holding forward.
                            if (face_walk_hold_start or 0) == 0 then
                                face_walk_hold_start = now
                                face_walk_hold_start_dist = mobdist
                            end

                        -- If we're holding forward but not getting closer, do a rare lockon toggle.
                        -- This avoids constant /lockon spam (toggle bug) while still recovering when approach isn't actually closing distance.
                        if face_forward_down == 1 then
                            if (now - (face_dist_sample_time or 0)) >= 0.20 then
                                if face_trend_last_dist ~= nil then
                                    local last = face_trend_last_dist
                                    local cur = mobdist
                                    local getting_closer = (cur <= (last - 0.05))
                                    local getting_farther = (cur >= (last + 0.12))
                                    local stuckish = (not getting_closer)

                                    if stuckish then
                                        if (face_increasing_since or 0) == 0 then
                                            face_increasing_since = now
                                        end
                                    else
                                        face_increasing_since = 0
                                    end

                                    -- When mobs are stacked and shuffling, distance can fluctuate upward briefly even while we are properly moving.
                                    -- If we are already holding forward, require a longer sustained "not getting closer" window before toggling lockon.
                                    local relock_wait = 0.60
                                    if face_forward_down == 1 then
                                        relock_wait = 1.50
                                    end
                                    if face_force_approach_until ~= 0 and now < face_force_approach_until then
                                        relock_wait = 2.00
                                    end

                                    if (face_increasing_since or 0) ~= 0 and (now - face_increasing_since) >= relock_wait then
                                        -- Additional guard: only relock if we're not clearly closing and we have had enough cooldown.
                                        local cd = 2.20
                                        if getting_farther then cd = 1.50 end
                                        if (now - (face_lockon_last_time or 0)) >= cd then
                                            face_try_lockon(now, 'stuck')
                                        end
                                        face_increasing_since = 0
                                    end
                                end
                                face_trend_last_dist = mobdist
                                face_dist_sample_time = now
                            end
                        else
                            face_increasing_since = 0
                        end
                        end



                        -- Stuck-detector watchdog: if we've been holding forward for over 2.0s
                        -- and have not closed any meaningful distance, force a brief stop. This
                        -- replaces the safety the old tap pattern provided when target/lock state
                        -- desyncs and autorun would otherwise keep firing into a wall.
                        if (face_walk_hold_start or 0) ~= 0 and (now - face_walk_hold_start) >= 2.0 then
                            local closed = (face_walk_hold_start_dist or mobdist) - mobdist
                            if closed < 0.5 then
                                stop_forward()
                                face_approach_active = 0
                                face_walk_force_stop_until = now + 0.30
                            end
                            face_walk_hold_start = 0
                            face_walk_hold_start_dist = nil
                        end
                        end


                        if face_new_target_tap_until ~= 0 and now >= face_new_target_tap_until then
                            stop_forward()
                            face_new_target_tap_until = 0
                        end

                        if face_new_target_backtap_until ~= 0 and now >= face_new_target_backtap_until then
                            stop_back()
                            face_new_target_backtap_until = 0
                        end

                        if face_force_step_until ~= 0 and now >= face_force_step_until then
                            stop_forward()
                            face_approach_active = 0
                            face_force_step_until = 0
                        end

                        if face_force_approach_until ~= 0 and now >= face_force_approach_until then
                            stop_forward()
                            stop_back()
                            face_approach_active = 0
                            face_force_approach_until = 0
                        end
                    end
                    end
                end
                end
            end

        elseif petmode == 1 and status == 1 then
            local lm = windower.ffxi.get_mob_by_target('t') or windower.ffxi.get_mob_by_target('st')
            local pet = windower.ffxi.get_mob_by_target('pet')

            -- No valid target, target dead, or no pet: release movement keys
            if not (lm and lm.id and lm.hpp and lm.hpp > 0 and pet) then
                stop_strafe()
                stop_forward()
                stop_back()
                petmode_last_target_key = nil
                petmode_new_target_backtap_until = 0
            elseif casting_spell then
                stop_strafe()
                stop_forward()
                stop_back()
                petmode_new_target_backtap_until = 0
            else
                local lock_state = get_lockon_state()
                if lock_state ~= nil and (lock_state == false or lock_state == 0) then
                    stop_strafe()
                    stop_forward()
                    stop_back()
                    petmode_new_target_backtap_until = 0
                else
                    -- New/switch target re-face tap
                    do
                        local key = tostring(lm.id)..':'..tostring(lm.index)
                        if key ~= petmode_last_target_key then
                            petmode_last_target_key = key
                            petmode_new_target_backtap_until = 0

                            if mobdist <= (wsdist + 0.5) then
                                stop_strafe()
                                set_back(true)
                                petmode_new_target_backtap_until = now + 0.04
                            end
                        end
                    end

                    if petmode_new_target_backtap_until ~= 0 and now < petmode_new_target_backtap_until then
                        stop_strafe()
                        set_back(true)
                    else
                        if petmode_new_target_backtap_until ~= 0 then
                            petmode_new_target_backtap_until = 0
                            stop_back(false)
                        end

                        if (mobdist < wsdist) then
                            pet_side()
                        else
                            stop_strafe()
                            stop_forward()
                            stop_back()
                        end
                    end
                end
            end
        end

        -- Trust-style face target: ensure player always faces mob when
        -- any positioning mode is active and engaged, regardless of
        -- lock-on state or strafe activity.
        if status == 1 and (face == 1 or rear == 1 or petface == 1 or yonin == 1 or innin == 1 or petmode == 1) then
            local face_me  = windower.ffxi.get_mob_by_target('me')
            local face_mob = windower.ffxi.get_mob_by_target('st') or windower.ffxi.get_mob_by_target('t')
            if face_me and face_mob and (face_mob.hpp or 0) > 0 and not casting_spell then
                sc_face_mob(face_me, face_mob)
            end
        end

        -- Safety: never leave forward key held unless a full-face variant is actively controlling it
        if (face ~= 1 and rear ~= 1 and petface ~= 1) or status ~= 1 then
            stop_forward(true)
            face_approach_active = 0
        end

        -- Safety: never leave back key held unless a movement mode is actively controlling it
        if (face ~= 1 and rear ~= 1 and petface ~= 1 and yonin ~= 1 and innin ~= 1 and petmode ~= 1) or status ~= 1 then
            stop_back(true)
        end

        -- Safety: never leave strafe keys held unless a movement mode is actively controlling them
        if (face ~= 1 and rear ~= 1 and petface ~= 1 and yonin ~= 1 and innin ~= 1 and petmode ~= 1) or status ~= 1 then
            stop_strafe()
        end

        -- Hard safety: if none of the movement modes are active, force-release movement keys in case
        -- Windower/game key state got desynced while a movement key was being held.
        if (face ~= 1 and rear ~= 1 and petface ~= 1 and yonin ~= 1 and innin ~= 1 and petmode ~= 1) then
            force_stop_movement()
        end

        if st_active then
            return
        end

        local targ = windower.ffxi.get_mob_by_target('t', 'bt')
        targ_id = targ and targ.id
        targ_key = targ and (tostring(targ.id)..':'..tostring(targ.index))
        -- DNC spam opener reset: target change or disengage clears the opener
        local p = windower.ffxi.get_player()
        local engaged = p and p.status == 1
        if (not engaged) or (not targ_key) then
            dnc_spam_opener_target = nil
            dnc_spam_opener_done = false
        elseif dnc_spam_opener_target ~= targ_key then
            dnc_spam_opener_target = targ_key
            dnc_spam_opener_done = false
        end

        local reson = resonating[targ_id]
        local timer = reson and (reson.times - now) or 0
        local tname = targ and targ.name

        if targ and targ.hpp > 0 and timer > 0 then
            if not reson.closed then
                reson.disp_info = reson.disp_info or check_results(reson)
                delay = reson.delay
                if auto == 1 and status == 1 and disabled == 0 and tagin == 0 and mobdist < wsdist and nuking == 0 and open == 0 then
                    if now > delay then
                        if burst == 0 then
                            if amthree == 0 then
                                if autosc ~= nil and tp > 999 then
    								                dnc_ws_context = 'auto_close'
        								            perform_ws(autosc)
                                elseif petsc ~= nil and tp < 1000 then
                                    perform_pet(petsc)
                                elseif close == 0 then
                                    if strict == 1 and autosc == nil and burst == 0 then
                                        -- wait out the window
                                    else
                                        if tp > 2000 and overws ~= nil then
                                            dnc_ws_context = 'auto_open'
                                            perform_ws(overws)
                                        elseif openws ~= nil and ultimate == 0 and tp > 999 then
        									                  dnc_ws_context = 'auto_open'
        									                  perform_ws(openws)
                                        elseif petopen ~= nil then
                                            perform_pet(petopen)
                                        end
                                    end
                                end
                            elseif amthree == 1 and tp == 3000 then
                                if amws ~= nil then
    								                dnc_ws_context = 'spam'
                                    perform_ws(amws)
                                end
                            end
                        elseif burst == 1 then
                            if timer < bursttime or reson.step == 1 then
                                if amthree == 0 then
                                    if autosc ~= nil and tp > 999 then
        								                perform_ws(autosc)
                                    elseif petsc ~= nil and tp < 1000 then
                                        perform_pet(petsc)
                                    end
                                elseif amthree == 1 and tp == 3000 then
                                    if autosc ~= nil then
                                        if amws ~= nil then
    										                    perform_ws(amws)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                reson.timer = now < delay and
                    '\\cs(255,0,0)Wait  %.1f\\cr':format(delay - now) or
                    '\\cs(0,255,0)Go!   %.1f\\cr':format(timer)
            elseif settings.Show.burst[info.job] then
                reson.disp_info = ''
                reson.timer = 'Burst %d':format(timer)
                autosc = nil
                petsc = nil
                if targ and targ.hpp > 0 and targ.hpp < 100 and auto == 1 and burst == 0 and status == 1 and disabled == 0 and tagin == 0 and mobdist < wsdist and nuking == 0 and close == 0 then
                    if amthree == 0 then
                        if tp > 2000 and overws ~= nil then
                            dnc_ws_context = 'auto_open'
                            perform_ws(overws)
                        elseif tp > 999 and openws ~= nil then
                            dnc_ws_context = 'auto_open'
    									                  perform_ws(openws)
                        elseif petopen ~= nil then
                            perform_pet(petopen)
                        end
                    elseif tp == 3000 and amthree == 1 then
                        if amws ~= nil then
    						            perform_ws(amws)
                        end
                    end
                end
            else
                resonating[targ_id] = nil
                return
            end
            if ((timer > 0 and ((delay - now) < 1)) or reson.step > 1) and autonuke == 1 then
                faw = 1
            else
                faw = 0
            end
            reson.name = res[reson.res][reson.id].name
            reson.props = reson.props or not reson.bound and colorize(reson.active) or 'Chainbound Lv.%d':format(reson.bound)
            reson.elements = reson.elements or reson.step > 1 and settings.Show.burst[info.job] and '(%s)':format(colorize(sc_info[reson.active[1]])) or ''
            skill_props:update(reson)
            skill_props:show()

            -- Nuke pacing: when resonance step changes (e.g., 2 -> 3), briefly pause retry spam
            do
                local cur = reson.step or 0
                local prev = nuke_res_step_seen or 0
                if cur ~= prev then
                    if cur > prev and autonuke == 1 then
                        local until_t = now + 0.34
                        if (nuke_global_lock_until or 0) < until_t then
                            nuke_global_lock_until = until_t
                        end
                        if nuke_retry_clear then nuke_retry_clear() end
                    end
                    nuke_res_step_seen = cur
                    if cur >= 2 and prev < 2 then
                        nuke_step2_rise_pending = 1
                    end
                end
            end

            -- GearSwap mode sync for BLM (only on state changes)
            if info.job == 'BLM' or info.job == 'NIN' then
                local want = (reson.step > 1) and 'burst' or 'free'
                if want == 'free' and nuke_spell_incast == 1 then
                    -- Never downgrade the current in-flight burst cast.
                elseif reson.gs_mode ~= want then
                    reson.gs_mode = want
                    if want == 'burst' then
                        windower.send_command('input //gs c burst')
                    else
                        windower.send_command('input //gs c freenuke')
                    end
                end
            end
            if reson.step > 1 and timer > 1.5 then
                if ongo == 0 then
                    if reson.props == 'Light' or reson.props == 'Radiance' then
                        perform_spell('light')
                        automb = 'light'
                    elseif reson.props == 'Darkness' or reson.props == 'Umbra' then
                        perform_spell('darkness')
                        automb = 'darkness'
                    elseif reson.props == 'Gravitation' then
                        perform_spell('grav')
                        automb = 'grav'
                    elseif reson.props == 'Fragmentation' then
                        perform_spell('frag')
                        automb = 'frag'
                    elseif reson.props == 'Distortion' then
                        perform_spell('disto')
                        automb = 'disto'
                    elseif reson.props == 'Fusion' then
                        perform_spell('fusion')
                        automb = 'fusion'
                    elseif reson.props == 'Compression' then
                        perform_spell('dark')
                        automb = 'dark'
                    elseif reson.props == 'Liquefaction' then
                        perform_spell('fire')
                        automb = 'fire'
                    elseif reson.props == 'Induration' then
                        perform_spell('blizzard')
                        automb = 'blizzard'
                    elseif reson.props == 'Reverberation' then
                        perform_spell('water')
                        automb = 'water'
                    elseif reson.props == 'Transfixion' then
                        perform_spell('holy')
                        automb = 'holy'
                    elseif reson.props == 'Scission' then
                        perform_spell('stone')
                        automb = 'stone'
                    elseif reson.props == 'Detonation' then
                        perform_spell('aero')
                        automb = 'aero'
                    elseif reson.props == 'Impaction' then
                        perform_spell('thunder')
                        automb = 'thunder'
                    end
                elseif ongo == 1 then
                    if reson.props == 'Scission' or reson.props == 'Gravitation' or reson.props == 'Darkness' or reson.props == 'Umbra' then
                        perform_spell('ongo')
                        automb = 'ongo'
                    end
                end

                if nuke_step2_rise_pending == 1 then
                    nuke_handle_step2_rise(now)
                end
            end
        elseif not visible then
            petsc = nil
            autosc = nil
            automb = nil
            faw = 0
            skill_props:hide()
            if targ and targ.hpp > 0 and targ.hpp < 100 and auto == 1 and status == 1 and disabled == 0 and tagin == 0 and mobdist < wsdist and nuking == 0 and close == 0 then
                if amthree == 0 then
                    if starter == 0 or started == 1 then
                        -- BST pet-as-opener: wait for the action packet confirming
                        -- the pet used the ability before allowing any WS.
                        if bst_pet_opener_pending then
                            if (now - bst_pet_opener_sent_at) >= bst_pet_opener_timeout then
                                -- Safeguard: packet likely dropped, release hold
                                bst_pet_opener_pending = false
                                bst_pet_opener_sent_at = 0
                            end
                            -- Still pending (or just cleared) → skip WS this tick
                        elseif bst_pet_opener ~= nil and tp > 999 and nopet == 0 and bst_pet_opener_viable(bst_pet_opener) then
                            perform_pet(bst_pet_opener)
                            bst_pet_opener_pending = true
                            bst_pet_opener_sent_at = now
                        elseif tp > 2000 and overws ~= nil then
                            dnc_ws_context = 'auto_open'
                            perform_ws(overws)
                        elseif tp > 999 and openws ~= nil then
                            dnc_ws_context = 'auto_open'
    									      perform_ws(openws)
                        elseif petopen ~= nil then
                            perform_pet(petopen)
                        end
                    elseif starter == 1 and started == 0 then
                        if tp > 999 and initws ~= nil then
                            dnc_ws_context = 'auto_open'
                            perform_ws(initws)
                            started = 1
                        end
                    end
                elseif tp == 3000 and amthree == 1 then
                    if amws ~= nil then
    					          perform_ws(amws)
                    end
                end
            end
        end
        if targ and targ.hpp > 0 and targ.hpp < 100 and spam == 1 and status == 1 and disabled == 0 and mobdist < wsdist then
            -- BST spam pet hold cleanup: if the hold is stale (>3s), clear it
            if bst_spam_pet_sent_at > 0 and (now - bst_spam_pet_sent_at) >= 3.0 then
                bst_spam_pet_sent_at = 0
            end
            if ((w_casting == 1 or w_readies == 1) and wstrigger == 0) or (w_casting == 0 and w_readies == 0) then
                if amthree == 0 then
                    local ws_to_use = nil
                    if cleave == 1 and aoews ~= nil then
                        ws_to_use = aoews
                    elseif rotate == 1 and #rotate_usable > 0 and (starter == 0 or started == 1) then
                        if rotate_index > #rotate_usable then rotate_index = 1 end
                        ws_to_use = rotate_usable[rotate_index]
                    elseif (starter == 0 or started == 1) then
                        ws_to_use = zergws
                    elseif starter == 1 and started == 0 then
                        ws_to_use = initws
                    end

                    local req_tp = spamtp
                    local should_fire = false
                    local holding_for_sc = false

                    if ws_to_use ~= nil then
                        should_fire, holding_for_sc = sc_spamsc_should_fire(ws_to_use, req_tp, tp, reson, now)
                    end

                    if should_fire then
                        if ws_to_use ~= nil then
                            -- BST pre-WS pet Ready: fire a petws ability before
                            -- the spam WS, like DNC fires a step before WS.
                            -- Only on BST, only if petopen is set, pet is alive
                            -- + engaged + in range, and Ready charges available.
                            local bst_pre_ws = false
                            local player_mj = windower.ffxi.get_player() and windower.ffxi.get_player().main_job or nil
                            if player_mj == 'BST' and nopet == 0 and petopen ~= nil and bst_pet_ready_ok() then
                                if not bst_pet_buff_active(petopen) then
                                    local ja = res.job_abilities:with('en', petopen)
                                    local cost = ja and ja.mp_cost or 1
                                    if bst_can_ready(cost) then
                                        bst_pre_ws = true
                                    end
                                end
                            end

                            if bst_pre_ws and bst_spam_pet_sent_at == 0 then
                                -- Fire the pet ability and start the hold
                                perform_pet(petopen)
                                bst_spam_pet_sent_at = now
                            elseif bst_spam_pet_sent_at > 0 and (now - bst_spam_pet_sent_at) < bst_spam_pet_delay then
                                -- Holding: wait for the JA delay before WS
                            else
                                -- Either no pet pre-WS needed, or delay has elapsed
                                bst_spam_pet_sent_at = 0
                                dnc_ws_context = 'spam'
                                local pre_ws_inflight = ws_inflight_time or 0
                                perform_ws(ws_to_use)
                                if rotate == 1 and #rotate_usable > 0 and (ws_inflight_time or 0) ~= pre_ws_inflight then
                                    rotate_index = (rotate_index % #rotate_usable) + 1
                                end
                                if ws_to_use == zergws then
                                    wstrigger = 1
                                elseif ws_to_use == initws then
                                    started = 1
                                    wstrigger = 1
                                elseif rotate == 1 then
                                    wstrigger = 1
                                end
                            end
                        end
                    elseif petopen ~= nil and not holding_for_sc then
                        -- BST: pet Ready is handled as a pre-WS action (above),
                        -- so don't spam it freely here. SMN still uses this path.
                        local player_mj = windower.ffxi.get_player() and windower.ffxi.get_player().main_job or nil
                        if player_mj ~= 'BST' then
                            perform_pet(petopen)
                        end
                    end
                elseif tp == 3000 and amthree == 1 then
                    if amws ~= nil then
        				        perform_ws(amws)
                        wstrigger = 1
                    end
                end
            end
        end
        nukespam_tick(now)
        if nuke_mb_attempt then nuke_mb_attempt(now) end

    end
end)



-- Forward declarations for retry helpers (used by incoming text handler)
local nuke_retry_clear
local nuke_retry_schedule

-- Forward declarations for wheel helpers (used by incoming text handler)
local wheel_delay_for_spell
local wheel_idx_for_spell
local wheel_bases

windower.register_event(
    "incoming text",
    function(original, modified, mode)

    local tmob = windower.ffxi.get_mob_by_target('t')
    local tname = tmob and tmob.name

    -- Face Mode: if the game reports out-of-range while engaged, force a short approach window
    do
        local msg = (modified or original or ''):lower()
        local p = windower.ffxi.get_player()
        local st = p and p.status or 0
        if (face == 1 or rear == 1) and st == 1 and (msg:find('out of range') or msg:find('too far away') or msg:find('unable to see')) then
            local now = os.clock()
            face_last_out_of_range = now
            face_force_lockon_until = now + 0.3

            local step_only = false
            if tmob and tmob.distance ~= nil then
                local curdist = tmob.distance:sqrt()
                local cur_wsdist = wsdist or 0
                -- Be more forgiving at the melee edge. Distance snapshots and mob movement can leave us
                -- functionally in front of the target while still failing melee swings.
                if cur_wsdist > 0 and curdist <= (cur_wsdist + 0.50) then
                    step_only = true
                end
            end

            if step_only then
                face_force_approach_until = 0
                face_force_step_until = now + 0.14
            else
                face_force_step_until = 0
                face_force_approach_until = now + 1.0
            end

            if msg:find('unable to see') then
                face_last_unable_to_see_time = now
            end
        end
    end

    if tname ~= nil then
        if original:contains(tname) then
            if w_readies == 1 then
                if original:contains(tname.." readies") then
                    wstrigger = 0
                end
            elseif w_casting == 1 then
                if original:contains(tname.." starts casting") then
                    wstrigger = 0
                end
            end
        end
    end
    local player = windower.ffxi.get_player()
    local pname = player and player.name or nil

    -- Wheel: if we use a weaponskill, allow the next wheel cast attempts to begin after the 2s WS forced delay window
    -- (wheel still relies on retry to bridge latency and any remaining action lockouts).
    if wheel == 1 and pname then
        if original:contains(pname .. " uses ") or original:contains("You use ") then
            local now = os.clock()
            -- start attempts slightly early; retry loop will handle exact readiness
            wheel_cast_lock_until = now + 1.8
            wheel_retry_clear()
        end
    end


    -- Stop any pending nuke retry spam as soon as we actually begin casting something.
    if pname and (nuke_retry_pending == 1 or (nuke_retry_attempts or 0) > 0) then
        if original:contains(pname .. " starts casting") then
            nuke_retry_clear()
        end
    end


    -- Stop wheel retry spam as soon as we actually begin casting the wheel spell.
    if wheel == 1 and pname and (wheel_retry_pending == 1 or (wheel_retry_attempts or 0) > 0) then
        if original:contains(pname .. " starts casting") then
            local matched = false
            if wheel_last_sent_spell and original:contains(wheel_last_sent_spell) then
                matched = true
            elseif wheel_last_choices then
                for _, nm in ipairs(wheel_last_choices) do
                    if original:contains(nm) then
                        wheel_last_sent_spell = nm
                        wheel_last_spell = nm
                        wheel_last_delay = wheel_delay_for_spell(nm)
                        matched = true
                        break
                    end
                end
            end

            if matched then
                local now2 = os.clock()
                local adv_spell = wheel_last_sent_spell or wheel_last_spell

                -- "starts casting" is intent, not completion — we don't advance the wheel
                -- here. Real advance happens on action-packet, "casts" line, or damage-line
                -- confirmation. We deliberately do NOT touch wheel_last_advance_spell or
                -- wheel_last_advance_stamp so the 1.0s guard on those completion paths
                -- isn't preemptively triggered by an event that didn't actually advance.
                if adv_spell then
                    wheel_retry_clear()

                    -- Respect the cast lock window for the spell we just started
                    local d = wheel_last_delay or 0
                    if d > 0 then
                        wheel_cast_lock_until = now2 + d
                    end
                end
            end
        end
    end

    -- If we missed "starts casting" (chat filtered/scroll), still advance on successful completion.
    if wheel == 1 and pname then
        if original:contains(pname .. " casts ") then
            local now2 = os.clock()
            for i = 1, 6 do
                local base = wheel_bases[i]
                if base then
                    local tier = nil
                    if original:contains(base .. ': San') then
                        tier = 'San'
                    elseif original:contains(base .. ': Ni') then
                        tier = 'Ni'
                    elseif original:contains(base .. ': Ichi') then
                        tier = 'Ichi'
                    end

                    if tier then
                        local spell = base .. ': ' .. tier

                        -- Guard: avoid double-advancing when we already advanced on "starts casting"
                        if not (wheel_last_advance_spell == spell and (now2 - (wheel_last_advance_stamp or 0)) < 1.0) then
                            wheel_last_advance_spell = spell
                            wheel_last_advance_stamp = now2

                            wheel_retry_clear()

                            wheel_last_sent_spell = spell
                            wheel_last_spell = spell
                            wheel_last_delay = wheel_delay_for_spell(spell)

                            -- Advance wheel_idx as a fallback for when the action packet was
                            -- missed. Skip when force-element pin is active (matches the action
                            -- handler's behavior at line 3866/3877).
                            local mi = wheel_idx_for_spell(spell)
                            if mi and not nukespam_force_ele then
                                wheel_idx = (mi % 6) + 1
                            end

                            -- Clear inflight since the cast unambiguously completed.
                            wheel_inflight = 0
                            wheel_inflight_spell = nil
                            wheel_inflight_base = nil
                            wheel_inflight_until = 0

                            -- Clear send-time tracking so the damage-line fallback doesn't
                            -- fire redundantly on the same cast's damage line.
                            wheel_send_time = 0
                            wheel_send_spell = nil

                            local d = wheel_last_delay or 0
                            if d > 0 then
                                wheel_cast_lock_until = now2 + d
                            end
                        end
                        break
                    end
                end
            end
        end
    end

    -- Damage-line fallback: if both the action packet AND the "casts" line dropped,
    -- but the mob took damage from our recent wheel cast, treat that as confirmation.
    -- The 1.0s double-advance guard prevents this from firing redundantly when the
    -- primary paths succeed.
    --
    -- Sentinel is wheel_send_spell being non-nil; both wheel_send_time and
    -- wheel_send_spell are set/cleared together at all advance + send sites.
    if wheel == 1 and wheel_send_spell then
        local now2 = os.clock()
        -- 3.5s window: long enough to cover normal cast + lag + small buffer,
        -- short enough that an unrelated DoT tick is unlikely to land here.
        if (now2 - (wheel_send_time or 0)) <= 3.5 then
            -- FFXI spell-damage line format: "<target> takes X points of damage."
            -- Reject "Additional effect" lines: those are enspell/AM3/en-debuff
            -- procs on melee swings, which use the same "takes X points of damage"
            -- suffix and would false-trigger every melee hit while wheel is active.
            -- Melee/ranged hits use "<actor> hits X for Y points of damage" (no
            -- " takes "), so the " takes " requirement already filters those.
            local is_spell_dmg = original:contains(' takes ')
                                 and original:contains(' points of damage')
                                 and not original:contains('Additional effect')
            if is_spell_dmg then
                local spell = wheel_send_spell
                if not (wheel_last_advance_spell == spell and (now2 - (wheel_last_advance_stamp or 0)) < 1.0) then
                    wheel_last_advance_spell = spell
                    wheel_last_advance_stamp = now2

                    wheel_retry_clear()

                    -- Advance wheel_idx; honor force-element pin gate.
                    local mi = wheel_idx_for_spell(spell)
                    if mi and not nukespam_force_ele then
                        wheel_idx = (mi % 6) + 1
                    end

                    -- Clear inflight; cast clearly resolved with damage.
                    wheel_inflight = 0
                    wheel_inflight_spell = nil
                    wheel_inflight_base = nil
                    wheel_inflight_until = 0

                    -- Clear send-time so we don't re-trigger on the next damage line.
                    wheel_send_time = 0
                    wheel_send_spell = nil
                end
            end
        else
            -- Send-time window expired; clear so old state doesn't linger and
            -- accidentally apply to a future unrelated damage line.
            wheel_send_time = 0
            wheel_send_spell = nil
        end
    end

    -- If we hit the common midaction lockout, re-attempt the last nuke shortly after.
    if original:contains('Unable to cast spells at this time.') or original:contains('Unable to cast a spell at this time.') then
        local now = os.clock()
        local until_t = now + 0.6
        if (nuke_global_lock_until or 0) < until_t then
            nuke_global_lock_until = until_t
        end
        nuke_retry_schedule()
    end
    return modified, mode


end)

-- nuke_mb_text_fallback: if spell_begin packets are missing/delayed, use log lines as a secondary signal.
windower.register_event('incoming text', function(original, modified, mode)
    if not original then return end
    -- Detect: "<Player> starts casting <Spell> on ..."

    local me = windower.ffxi.get_player()
    if not me or not me.name then return end
    local pname = me.name

    -- Some chat lines include control bytes; normalize for robust matching.
    local clean = original
    clean = clean:gsub('[%z\1-\31\127\128-\255]', '')
    local lclean = clean:lower()
    local lpname = pname:lower()

    -- Text fallback: spell cast begin
    if lclean:find(lpname .. ' starts casting ', 1, true) then
        local now = os.clock()
        nuke_spell_incast = 1
        nuke_spell_cast_start = now
        nuke_busy_until = now + 2.75
        nuke_clear_preburst_state()
        if nuke_retry_clear then nuke_retry_clear() end
        return
    end

    -- Text fallback: spell finished (or at least action resolved)
    if lclean:find(lpname .. " casts ", 1, true) then
        nuke_spell_incast = 0
        nuke_spell_cast_start = 0
        nuke_spell_cast_time = 0
        nuke_clear_preburst_state()
        return
    end

    -- Text fallback: interruption
    if lclean:find("'s casting is interrupted", 1, true) or lclean:find('casting is interrupted', 1, true) then
        local now = os.clock()
        nuke_spell_incast = 0
        nuke_spell_cast_start = 0
        nuke_spell_cast_time = 0
        nuke_clear_preburst_state()
        nuke_busy_until = now + 0.5
        return
    end

end)


-- Wheel: advance using action packets (server-confirmed), not chat text
windower.register_event('action', function(act)
    if wheel ~= 1 then return end
    local p = windower.ffxi.get_player()
    if not p or not p.id then return end
    if not act or act.actor_id ~= p.id then return end

    -- Only handle spell completion actions.
    if act.category and act.category ~= 4 then return end

    -- Only care about magic actions; depending on Windower build, the spell id is commonly in act.param or in target.actions[].param.
    local function handle_spell_id(spell_id, msg_id)
        if not spell_id then return end
        local s = res.spells[spell_id]
        local en = s and s.en
        if not en then return end
        local base = en:match('^(%a+):')
        if not base then return end
        local idx = wheel_idx_for_spell and wheel_idx_for_spell(en) or nil
        if not idx or idx < 1 or idx > 6 then return end

        -- Confirmed wheel spell action: clear retry/inflight and advance to next element.
        -- Note: msg_id 85 (resisted) is treated as completion, not interruption — resisted
        -- spells still consume MP and start the recast. Real interruptions arrive as
        -- category 8 packets (param 28787) and are filtered out at the category check above.
        wheel_inflight = 0
        wheel_inflight_spell = nil
        wheel_inflight_base = nil
        wheel_inflight_until = 0
        if wheel_retry_clear then wheel_retry_clear() end

        local now = os.clock()
        -- Anti-double-advance guard (packet can include multiple entries)
        if wheel_last_advance_stamp and (now - wheel_last_advance_stamp) < 0.2 and wheel_last_advance_spell == en then
            return
        end
        wheel_last_advance_spell = en
        wheel_last_advance_stamp = now

        -- Skip auto-advance when a //sc <element>mb force is active so the
        -- wheel stays pinned to that single element. Without force, advance
        -- to the next slot in the rotation as normal.
        if not nukespam_force_ele then
            wheel_idx = (idx % 6) + 1
        end

        -- Clear send-time tracking so the damage-line fallback doesn't fire
        -- redundantly on the same cast's damage line.
        wheel_send_time = 0
        wheel_send_spell = nil
    end

    if act.param then
        handle_spell_id(act.param, nil)
    end

    if act.targets then
        for _, t in ipairs(act.targets) do
            if t.actions then
                for _, a in ipairs(t.actions) do
                    if a.param then
                        handle_spell_id(a.param, a.message)
                    end
                end
            end
        end
    end
end)


windower.register_event('chat message', function(message,sender,mode,gm)

    if buddy == 1 then

        if message:contains('Aftermath Down') or message:contains('WS Disabled') then
            windower.send_command('input //sc ignore '..sender..'')
        end

        if message:contains('Aftermath Up') or message:contains('WS Enabled') then
            windower.send_command('input //sc watch '..sender..'')
        end

    end

end)



windower.register_event('gain buff', function(id)

    if buddy == 1 then

        if am == 1 then
            local buff_name = res.buffs[id].name
            if buff_name == "Aftermath: Lv.3" then
                windower.send_command('input /p Aftermath Up')
            end
        end

        if id == 2 or
        id == 7 or
        id == 10 or
        id == 14 or
        id == 16 or
        id == 17 or
        id == 19 or
        id == 28 or
        id == 156 then
            windower.send_command('input /p WS Disabled')
        end

    end

end)

windower.register_event('lose buff', function(id)

    local player = windower.ffxi.get_player()
    local buffs = L(player.buffs)

    if buddy == 1 then

        if am == 1 then
            local buff_name = res.buffs[id].name
            if buff_name == "Aftermath: Lv.3" then
                windower.send_command('input /p Aftermath Down')
            end
        end

        if L{2,7,10,14,16,17,19,28,156}:contains(id) then
            if not buffs:contains(L{2,7,10,14,16,17,19,28,156}) then
                windower.send_command('input /p WS Enabled')
            end
        end

    end

end)


function check_buff(t, i)
    if t[i] == true or t[i] - os.time() > 0 then
        return true
    end
    t[i] = nil
end

function chain_buff(t)
    local i = t[164] and 164 or t[470] and 470
    if i and check_buff(t, i) then
        t[i] = nil
        return true
    end
    return t[163] and check_buff(t, 163)
end

function perform_pet(petws_name)
    local player = windower.ffxi.get_player()
    if not player then return end
    petws_name = string.gsub(petws_name, '[ \t]+%f[\r\n%z]', '')

    -- Look up the ability's charge cost (mp_cost field for Monster-type abilities)
    local ja = res.job_abilities:with('en', petws_name)
    local charge_cost = ja and ja.mp_cost or 1

    if petdelay == 0 then
        if player.main_job == 'BST' then
            if nopet == 1 then return end
            -- Skip if this is a self-buff ability and buff is still active
            if bst_pet_buff_active(petws_name) then return end
            if bst_can_ready(charge_cost) and bst_pet_ready_ok() then
                -- BST Ready commands target <me>; the pet uses the
                -- ability on whatever it is currently engaged to.
                windower.send_command('input /pet "'..petws_name..'" <me>')
                pet_delay()
            end
        elseif player.main_job == 'SMN' then
            if bpdelay < 1 then
                windower.send_command('input /pet "'..petws_name..'" <t>')
                pet_delay()
            end
        end
    end
end


function perform_ws(ws_name)
    ws_name = string.gsub(ws_name, '[ \t]+%f[\n%z]', '')
    if not ws_can_send_attempt() then return end

    local player = windower.ffxi.get_player()
    if not player then return end

    -- Prevent long chained command strings from stacking and locking input
    if (os.clock() - dnc_prews_last) < 0.6 then
        windower.send_command('input /ws '..ws_name..' <t>')
        ws_mark_inflight()
        ws_attempt_throttle()
        dnc_ws_context = nil
        return
    end

    if player.main_job == 'DNC' then
        local cur_tp = (player.vitals and player.vitals.tp) or player.tp or 0
        local am_mode = (am == 1)
        local am3_active = has_buff_name('Aftermath: Lv.3')
        local preserve_3k_pk = (am_mode and ws_name == 'Pyrrhic Kleos' and cur_tp >= 3000)
        local am_kleos_build = (am_mode and ws_name == 'Pyrrhic Kleos' and (not am3_active))
        local allow_steps = (not am_mode) or am3_active
        if preserve_3k_pk then allow_steps = false end
        if nosteps == 1 then allow_steps = false end


        local allow_opener = allow_steps

        -- Block Foot Rise during automation unless we already have 5+ Finishing Moves.
        -- This only affects automated chains that go through perform_ws().
        if ws_name and dnc_ws_context and dnc_ws_context ~= nil then
            local fm = dnc_finishing_moves()
            if fm <= 4 then
        -- If any later logic tries to include Foot Rise, it must be gated elsewhere.
        -- (No-op here unless your file actually sends Foot Rise in this path.)
            end
        end

        -- spam: step rotation + flourish III (striking/climactic) + flourish II (building)
        if dnc_ws_context == 'spam' then
            -- When AM mode is on, do NOT step (steps cost TP and can drop you below exact AM tiers).
            -- Flourishes are still allowed.
            local rem = dnc_sc_seconds_remaining()
            local max_prejas = dnc_max_prejas_for_window(rem)
            local pre = nil

            if am_kleos_build then
                -- AM3-building Pyrrhic Kleos while AM toggle is on and AM3 is down: straight WS only.
                windower.send_command('input /ws '..ws_name..' <t>')
                ws_mark_inflight()
                ws_attempt_throttle()
                dnc_ws_context = nil
                return
            end

            -- Spam opener (per target): Presto (if ready and not active) > Box Step, then WS in the same chained command.
            -- Do not consume opener (and do not WS) if steps are currently blocked.
            if (not dnc_spam_opener_done) and (dnc_spam_opener_target == targ_key) and nosteps == 0 then
                local opener = allow_opener and dnc_build_presto_box_cmd(ws_name) or nil
                if opener then
                    local needed = opener:find('Presto') and 2 or 1
                    if max_prejas == nil or max_prejas >= needed then
                        dnc_prews_last = os.clock()
                        windower.send_command(opener .. ';input /ws '..ws_name..' <t>')
                        ws_mark_inflight()
                        ws_attempt_throttle()
                        dnc_spam_opener_done = true
                        dnc_ws_context = nil
                        return
                    end
                end
                -- Opener pending but blocked by gating; retry later without advancing step rotation.
                dnc_ws_context = nil
                return
            end

            pre = dnc_build_flourish_cmd(ws_name, allow_steps, max_prejas)
            if pre then
                dnc_prews_last = os.clock()
                windower.send_command(pre .. ';input /ws '..ws_name..' <t>')
                ws_mark_inflight()
                ws_attempt_throttle()
                dnc_ws_context = nil
                return
            end
        end

        -- autosc open: Presto > Box Step before WS (no step rotation)
        if dnc_ws_context == 'auto_open' then
            local rem = dnc_sc_seconds_remaining()
            local max_prejas = dnc_max_prejas_for_window(rem)
            if am_kleos_build then
                -- AM3-building Pyrrhic Kleos: straight WS only (Reverse Flourish handled separately on TP change).
                windower.send_command('input /ws '..ws_name..' <t>')
                ws_mark_inflight()
                ws_attempt_throttle()
                dnc_ws_context = nil
                return
            end
-- Opener: always try Presto + Box Step when there is no active resonance window.
            -- Safety: if AM mode is on and TP is 3000+, do not step (avoid dropping below exact AM3 tier).
            local allow_opener = allow_steps

            local allow_step = allow_opener
            local pre = allow_step and dnc_build_presto_box_cmd(ws_name) or nil
            if pre then
                dnc_prews_last = os.clock()
                windower.send_command(pre .. ';input /ws '..ws_name..' <t>')
                ws_mark_inflight()
                ws_attempt_throttle()
                dnc_ws_context = nil
                return
            end
        end

        -- autosc close: flourish III/II before WS (no step rotation)
        if dnc_ws_context == 'auto_close' then
            local rem = dnc_sc_seconds_remaining()
            local max_prejas = dnc_max_prejas_for_window(rem)
            local pre = nil
            if am_kleos_build then
                -- AM3-building Pyrrhic Kleos during a window: straight WS only (Reverse Flourish handled separately on TP change).
                windower.send_command('input /ws '..ws_name..' <t>')
                ws_mark_inflight()
                ws_attempt_throttle()
                dnc_ws_context = nil
                return
            end
            pre = dnc_build_flourish_cmd(ws_name, false, max_prejas)
            if pre then
                dnc_prews_last = os.clock()
                windower.send_command(pre .. ';input /ws '..ws_name..' <t>')
                ws_mark_inflight()
                ws_attempt_throttle()
                dnc_ws_context = nil
                return
            end
        end
    end

    if ws_name == 'Myrkr' then
        windower.send_command('input /ws '..ws_name..' <me>')
    else
        windower.send_command('input /ws '..ws_name..' <t>')
    end
    ws_mark_inflight()
    ws_attempt_throttle()
    dnc_ws_context = nil
end


-- Nuke retry helpers
nuke_retry_clear = function()
    nuke_retry_pending = 0
    nuke_retry_attempts = 0
    nuke_last_spell = nil
    nuke_last_is_ja = false
    nuke_last_delay = 0
    nuke_last_mb = false
    nuke_last_stamp = 0
    if nuke_retry_timer and coroutine.status(nuke_retry_timer) == 'suspended' then
        coroutine.close(nuke_retry_timer)
    end
    nuke_retry_timer = nil
    nuke_retry_used_raw = 0
    nuke_retry_next_allowed = 0
end


-- NIN Wheel helpers
wheel_bases = {
    [1] = 'Hyoton', -- Ice
    [2] = 'Katon',  -- Fire
    [3] = 'Suiton', -- Water
    [4] = 'Raiton', -- Thunder
    [5] = 'Doton',  -- Earth
    [6] = 'Huton',  -- Wind
}

local wheel_spell_id_cache = {}

local function wheel_get_spell_id(name)
    if wheel_spell_id_cache[name] then return wheel_spell_id_cache[name] end
    if not res or not res.spells then return nil end
    local s = res.spells:with('en', name)
    local id = s and s.id or nil
    wheel_spell_id_cache[name] = id
    return id
end

local function wheel_candidates_for_idx(idx)
    local base = wheel_bases[idx] or wheel_bases[2]
    return {
        base .. ': San',
        base .. ': Ni',
        base .. ': Ichi',
    }
end


wheel_idx_for_spell = function(spell_name)
    if type(spell_name) ~= 'string' then return nil end
    for i = 1, 6 do
        local base = wheel_bases[i]
        if base and spell_name:find(base, 1, true) then
            return i
        end
    end
    return nil
end

-- Map nukespam_force_ele (set by //sc firemb / icemb / etc.) to wheel idx.
-- Returns nil if no force is set or if the value isn't a recognized element.
-- Used by wheel_tick to pin the wheel to a single element instead of rotating
-- when the user has chosen one via //sc <element>mb on NIN main job.
local wheel_force_ele_to_idx = {
    blizzard = 1, -- Hyoton
    fire     = 2, -- Katon
    water    = 3, -- Suiton
    thunder  = 4, -- Raiton
    stone    = 5, -- Doton
    aero     = 6, -- Huton
}

-- Reverse map for exclusion checks (//sc no<ele> support in the wheel).
local wheel_idx_to_ele = {
    [1] = 'blizzard', -- Hyoton
    [2] = 'fire',     -- Katon
    [3] = 'water',    -- Suiton
    [4] = 'thunder',  -- Raiton
    [5] = 'stone',    -- Doton
    [6] = 'aero',     -- Huton
}

-- First non-excluded wheel index at or after idx (wrapping). nil if all six
-- elements are excluded.
local function wheel_next_allowed_idx(idx)
    for step = 0, 5 do
        local i = (((idx or 1) - 1 + step) % 6) + 1
        if not nukes.is_excluded(wheel_idx_to_ele[i]) then
            return i
        end
    end
    return nil
end

local function wheel_force_idx()
    if not nukespam_force_ele then return nil end
    return wheel_force_ele_to_idx[nukespam_force_ele]
end


local function wheel_pick_ready_spell(idx)
    local recasts = windower.ffxi.get_spell_recasts()
    if not recasts then return nil end

    local cands = wheel_candidates_for_idx(idx)
    -- Priority San -> Ni -> Ichi
    for _, name in ipairs(cands) do
        local id = wheel_get_spell_id(name)
        if id and recasts[id] and ((recasts[id] * 0.66) < 1) then
            return name
        end
    end
    return nil
end
local wheel_day_to_ele = {
    Firesday = 'fire',
    Earthsday = 'earth',
    Watersday = 'water',
    Windsday = 'wind',
    Iceday = 'ice',
    Lightningday = 'thunder',
    Lightsday = 'light',
    Darksday = 'dark',
}

local function wheel_ele_from_weather_id(weather_id)
    if not weather_id or not res or not res.weather then return nil end
    local w = res.weather[weather_id]
    if not w then return nil end
    local e = w.element
    if type(e) == 'number' then
        if res.elements and res.elements[e] and res.elements[e].en then
            e = res.elements[e].en
        else
            return nil
        end
    end
    if type(e) ~= 'string' then return nil end
    return e:lower()
end

local function wheel_normalize_ele(e)
    if not e then return nil end
    if type(e) ~= 'string' then return nil end
    e = e:lower()
    if e == 'lightning' then e = 'thunder' end
    if e == 'lightsday' then e = 'light' end
    if e == 'darksday' then e = 'dark' end
    if e == 'light' or e == 'dark' then
        return 'fire' -- fallback for tier wheel start
    end
    if e == 'fire' or e == 'ice' or e == 'water' or e == 'thunder' or e == 'earth' or e == 'wind' then
        return e
    end
    return nil
end

local function wheel_start_index()
    local info = windower.ffxi.get_info()

    -- Priority: day then weather (per your requirement)
    local d = nil
    if info and info.day and wheel_day_to_ele[info.day] then
        d = wheel_normalize_ele(wheel_day_to_ele[info.day])
    end
    if d then
        if d == 'ice' then return 1 end
        if d == 'fire' then return 2 end
        if d == 'water' then return 3 end
        if d == 'thunder' then return 4 end
        if d == 'earth' then return 5 end
        if d == 'wind' then return 6 end
    end

    local w = nil
    if info and info.weather then
        w = wheel_normalize_ele(wheel_ele_from_weather_id(info.weather))
    end
    if w then
        if w == 'ice' then return 1 end
        if w == 'fire' then return 2 end
        if w == 'water' then return 3 end
        if w == 'thunder' then return 4 end
        if w == 'earth' then return 5 end
        if w == 'wind' then return 6 end
    end

    return 2 -- default to fire
end

local function wheel_party_claim_ok(mob)
    if not mob or not mob.claim_id or mob.claim_id == 0 then return false end
    local claim_id = mob.claim_id
    local p = windower.ffxi.get_player()
    if not p then return false end
    if claim_id == p.id then return true end

    local party = windower.ffxi.get_party()
    if not party then return false end
    for _, v in pairs(party) do
        if type(v) == 'table' and v.mob and v.mob.id and v.mob.id == claim_id then
            return true
        end
    end
    return false
end

wheel_retry_clear = function()
wheel_retry_pending = 0
    wheel_retry_attempts = 0
    wheel_retry_window_start = 0
    if wheel_retry_timer and coroutine.status(wheel_retry_timer) == 'suspended' then
        coroutine.close(wheel_retry_timer)
    end
    wheel_retry_timer = nil
    wheel_retry_next_allowed = 0
end

wheel_delay_for_spell = function(spell_name)
    if not res or not res.spells then return 3.0 end
    local s = res.spells:with('en', spell_name)
    if not s or not s.cast_time then return 3.0 end
    local fc = fastcast or 0
    if fc < 0 then fc = 0 end
    if fc > 0.8 then fc = 0.8 end
    return (s.cast_time * (1 - fc)) + 2.1
end

local function wheel_send_cast()
    -- Pick the best available tier for the current wheel index.
    local spell = wheel_pick_ready_spell(wheel_idx)
    if not spell then
        return
    end
    local now = os.clock()

    wheel_last_sent_spell = spell
    wheel_last_spell = spell
    wheel_last_delay = wheel_delay_for_spell(spell)

    -- Mark as inflight; action packet will confirm and advance the wheel.
    wheel_inflight = 1
    wheel_inflight_spell = spell
    wheel_inflight_base = spell:match('^(%a+):') or spell
    wheel_inflight_until = now
    wheel_send_time = now
    wheel_send_spell = spell

    windower.send_command('input /ma "' .. spell .. '" <t>')
end


local function wheel_schedule_retry()
    if wheel_retry_enabled ~= 1 then return end
    local now = os.clock()
    if (wheel_retry_next_allowed or 0) > now then return end
    wheel_retry_next_allowed = now + (wheel_retry_base_delay or 0.34)

    if wheel_retry_pending == 1 then return end
    wheel_retry_pending = 1
    wheel_retry_attempts = 0
    if (wheel_retry_window_start or 0) == 0 then
        wheel_retry_window_start = now
    end

    local function wheel_retry_attempt()
        if wheel ~= 1 then wheel_retry_clear() return end
        if wheel_retry_pending ~= 1 then return end
        if (os.clock() - (wheel_retry_window_start or 0)) > 3.0 then
            wheel_retry_clear()
            return
        end
        local attempt = (wheel_retry_attempts or 0) + 1
        wheel_retry_attempts = attempt
        if attempt > (wheel_retry_max_attempts or 30) then
            wheel_retry_clear()
            return
        end
        if casting_spell then
            wheel_retry_timer = coroutine.schedule(wheel_retry_attempt, (wheel_retry_base_delay or 0.34))
            return
        end
        wheel_send_cast()
        wheel_retry_timer = coroutine.schedule(wheel_retry_attempt, (wheel_retry_base_delay or 0.34))
    end

    wheel_retry_timer = coroutine.schedule(wheel_retry_attempt, (wheel_retry_base_delay or 0.34))
end

local function wheel_tick(now)
    if wheel ~= 1 then return end

    local player = windower.ffxi.get_player()
    if not player or player.main_job ~= 'NIN' then return end

    local targ = windower.ffxi.get_mob_by_target('t')
    if not targ or targ.is_npc ~= true then return end
    if not targ.hpp or targ.hpp >= 100 or targ.hpp <= 0 then return end
    if not wheel_party_claim_ok(targ) then return end

    -- Reset wheel start point on new mob
    if wheel_target_id ~= targ.id then
        wheel_target_id = targ.id
        wheel_idx = wheel_start_index()
        wheel_last_spell = nil
        wheel_last_sent_spell = nil
        wheel_last_choices = nil
        wheel_last_delay = 0
        wheel_cast_lock_until = 0
        wheel_retry_clear()
    end

    -- If a //sc <element>mb force is active, pin the wheel to that single
    -- element instead of rotating. wheel_pick_ready_spell still picks
    -- San > Ni > Ichi for that base. Auto-advance is skipped in the action
    -- handler when force is set, so this assignment isn't fighting itself.
    -- Exclusions (//sc no<ele>): a forced-but-excluded element casts nothing
    -- (matches burst behavior); otherwise the wheel skips excluded elements.
    -- Normalizing here covers the start index, the post-advance index, and
    -- mid-fight exclusion toggles, since every cast cycle passes through.
    do
        local fidx = wheel_force_idx()
        if fidx then
            if nukes.is_excluded(wheel_idx_to_ele[fidx]) then return end
            wheel_idx = fidx
        else
            local ai = wheel_next_allowed_idx(wheel_idx)
            if not ai then return end
            wheel_idx = ai
        end
    end

    -- If we're still within the cast lock window, wait until lead time before starting retry attempts
    local lead = wheel_lead_time or 0.34
    if (wheel_cast_lock_until or 0) > 0 then
        if now < ((wheel_cast_lock_until or 0) - lead) then
            return
        end
    end

    -- If we're already trying, let the retry loop run
    if wheel_retry_pending == 1 then
        wheel_schedule_retry()
        return
    end
    -- Prepare next element (spell tier is chosen at send time: San -> Ni -> Ichi)
    wheel_last_choices = wheel_candidates_for_idx(wheel_idx)
    wheel_last_sent_spell = nil
    wheel_last_spell = nil

    -- Start retry window (we attempt a little early, then retry every base_delay)
    wheel_retry_window_start = now

    -- Estimate a cast lock window based on San; the exact delay is set when we actually send a spell.
    local est = wheel_last_choices and wheel_last_choices[1] or nil
    wheel_last_delay = wheel_delay_for_spell(est or 'Katon: San')
    wheel_cast_lock_until = now + (wheel_last_delay or 0)

    wheel_schedule_retry()
end



-- Wheel prerender loop (separate from main loop to avoid touching existing flow)
windower.register_event('prerender', function()
    if wheel ~= 1 then return end
    local now = os.clock()
    -- basic pacing
    wheel_prerender_next = wheel_prerender_next or 0
    if now < wheel_prerender_next then return end
    wheel_prerender_next = now + 0.1
    wheel_tick(now)
end)


local function nuke_current_res_step()
    local targ = windower.ffxi.get_mob_by_target('t')
    if not targ or not targ.id then
        return 0
    end
    if not resonating then
        return 0
    end
    local r = resonating[targ.id]
    if not r then
        return 0
    end
    -- Treat expired resonance windows as inactive even if the table entry lingers briefly.
    local now = os.clock()
    if r.times and now > r.times then
        return 0
    end
    return (r.step) or 0
end


local function nuke_issue(spell_name, is_ja, delay_seconds, magic_burst)
    -- Record intent only. Actual lockouts are tracked via action packets.
    nuke_last_spell = spell_name
    nuke_last_is_ja = is_ja and true or false
    nuke_last_delay = delay_seconds or 0
    nuke_last_mb = magic_burst and true or false
    nuke_last_stamp = os.clock()
    nuke_last_res_step = nuke_current_res_step()

    nuke_last_sent_spell = spell_name
    nuke_last_sent_stamp = nuke_last_stamp

    if autonuke == 1 then
        windower.send_command('' .. nukeswap .. '')
    end

    if is_ja then
        windower.send_command('input /ja "' .. spell_name .. '" <t>')
    else
        windower.send_command('input /ma "' .. spell_name .. '" <t>')
    end
end

nuke_retry_attempt = function()

    -- Disabled: autoburst now uses a fixed interval tick, not a retry scheduler.
    return
end

nuke_retry_attempt_now = function()
    return
end

nuke_retry_schedule = function()
    return
end

-- Autoburst interval tick settings
nuke_mb_interval = nuke_mb_interval or 0.25
nuke_mb_last_tick = nuke_mb_last_tick or 0
local function nuke_mb_can_attempt(now)
    if autonuke ~= 1 then return false end

    local step = (nuke_current_res_step() or 0)
    if step < 2 then
        -- No active step 2+ window: clear desired element so we do not keep casting after the chain ends.
        nuke_desired_mb = nil
        nuke_clear_preburst_state()
        return false
    end
    if not nuke_desired_mb then return false end

    -- After a pre-burst JA, start spell attempts 0.1s after the JA command and
    -- keep probing through the JA lock window until a real spell begin is confirmed.
    local first_at = nuke_preburst_first_attempt_at or 0
    if first_at > 0 then
        if now < first_at then return false end
        return true
    end
    if (nuke_preburst_probe_until or 0) > now then
        return true
    end

    -- Wait until busy lockout expires, then attempt every 0.25s tick.
    local lock_until = nuke_busy_until or 0
    if (nuke_global_lock_until or 0) > lock_until then lock_until = nuke_global_lock_until end
    if now < lock_until then return false end

    return true
end


-- MP-aware downgrade for autoburst spell selection.
local function sc_player_mp()
    local p = windower.ffxi.get_player()
    return (p and p.vitals and p.vitals.mp) or 0
end

local function sc_spell_mp_cost(name)
    if not name or not res or not res.spells then return nil end
    local s = res.spells:with('en', name)
    if not s then return nil end
    return s.mp_cost or s.mp or s.mp_cost_ or nil
end

local function sc_spell_ready(name)
    if not name then return false end
    if not res or not res.spells then return false end
    local s = res.spells:with('en', name)
    if not s or not s.id then return false end
    local recasts = windower.ffxi.get_spell_recasts()
    if not recasts or not recasts[s.id] then return false end
    return ((recasts[s.id] * 0.66) < 1)
end

local function sc_downgrade_list_for_spell(name)
    if type(name) ~= 'string' then return nil end

    -- Ninjutsu: Base: San -> Ni -> Ichi
    local base = name:match('^(.-):%s*(San)$') or name:match('^(.-):%s*(Ni)$') or name:match('^(.-):%s*(Ichi)$')
    if base then
        return { base .. ': San', base .. ': Ni', base .. ': Ichi' }
    end

    -- Elemental magic: VI -> V -> IV -> III -> II -> I (no numeral)
    local n, roman = name:match('^(.-)%s+(VI)$')
    if not n then n, roman = name:match('^(.-)%s+(V)$') end
    if not n then n, roman = name:match('^(.-)%s+(IV)$') end
    if not n then n, roman = name:match('^(.-)%s+(III)$') end
    if not n then n, roman = name:match('^(.-)%s+(II)$') end
    if not n then
        -- Tier I has no numeral (e.g. "Thunder")
        return { name }
    end
    return { n .. ' VI', n .. ' V', n .. ' IV', n .. ' III', n .. ' II', n }
end

local function sc_pick_spell_with_mp(best_spell_name)
    if not best_spell_name then return nil end
    if not res or not res.spells then return best_spell_name end

    local mp = sc_player_mp()
    local best_cost = sc_spell_mp_cost(best_spell_name)
    if not best_cost or mp >= best_cost then
        return best_spell_name
    end

    local list = sc_downgrade_list_for_spell(best_spell_name)
    if not list then
        return nil
    end

    -- Start from the tier that nukes.lua selected, then walk down.
    local start_idx = 1
    for i, s in ipairs(list) do
        if s == best_spell_name then
            start_idx = i
            break
        end
    end

    for i = start_idx, #list do
        local cand = list[i]
        if sc_spell_ready(cand) then
            local cost = sc_spell_mp_cost(cand)
            if (not cost) or (mp >= cost) then
                return cand
            end
        end
    end

    return nil
end

nuke_clear_preburst_state = function()
    nuke_preburst_first_attempt_at = 0
    nuke_preburst_probe_until = 0
    nuke_preburst_ja_name = nil
    nuke_preburst_ja_sent_at = 0
end

local function sc_select_preburst_ja()
    local p = windower.ffxi.get_player()
    if not p then return nil end

    if sc_cascade_mode == 1 and p.main_job == 'BLM' and sc_player_has_ja('Cascade') and dnc_ja_ready('Cascade') then
        return 'Cascade'
    end

    if sc_ebul_mode == 1 and sc_dark_arts_active() and sc_player_has_ja('Ebullience') and dnc_ja_ready('Ebullience') then
        return 'Ebullience'
    end

    if sc_alac_mode == 1 and sc_dark_arts_active() and sc_player_has_ja('Alacrity') and dnc_ja_ready('Alacrity') then
        return 'Alacrity'
    end

    return nil
end

nuke_handle_step2_rise = function(now)
    nuke_step2_rise_pending = 0

    if autonuke ~= 1 then
        nuke_clear_preburst_state()
        return
    end

    local ja_name = sc_select_preburst_ja()
    if ja_name then
        windower.send_command('input /ja "' .. ja_name .. '" <me>')
        nuke_preburst_ja_name = ja_name
        nuke_preburst_ja_sent_at = now
        nuke_preburst_first_attempt_at = now + 0.1
        nuke_preburst_probe_until = now + 1.35
        nuke_mb_last_tick = 0
        return
    end

    nuke_clear_preburst_state()
    if nuke_mb_attempt then
        nuke_mb_last_tick = 0
        nuke_mb_attempt(now)
    end
end

function nuke_mb_attempt(now)
    local forced_first = false
    local first_at = nuke_preburst_first_attempt_at or 0
    if first_at > 0 then
        if now < first_at then
            return
        end
        forced_first = true
        nuke_preburst_first_attempt_at = 0
    end

    -- Throttle to a fixed interval of checks/attempts (not "retrying" a specific spell).
    if not forced_first and (nuke_mb_last_tick or 0) > 0 and (now - nuke_mb_last_tick) < (nuke_mb_interval or 0.25) then
        return
    end
    nuke_mb_last_tick = now

    if not nuke_mb_can_attempt(now) then
        return
    end

    -- Re-evaluate best spell every interval for the current desired burst element.
    local desired = nuke_desired_mb
    local nuke = nukes.get_nuke(desired)
    nuke = sc_pick_spell_with_mp(nuke)
    if not nuke then
        return
    end

    if res.spells:with('en', nuke) then
        nuke_issue(nuke, false, 0, desired)
    elseif res.job_abilities:with('en', nuke) then
        nuke_issue(nuke, true, 0, desired)
    else
        return
    end
end

function perform_spell(magic_burst)
    -- Do not attempt to cast here. Just set the desired burst element/property.
    -- Actual casting is done by nuke_mb_attempt() on a 0.25 interval while resonance is step 2+.
    nuke_desired_mb = magic_burst
end

function ignore_player(player_name)
    if not ignoretp:contains(player_name) and player_name then
        ignoretp:add(player_name)
        windower.add_to_chat(207, '%s: Added %s to ignore list':format(_addon.name, player_name))
    end
end

function watch_player(player_name)
    if ignoretp:contains(player_name) and player_name then
        ignoretp:remove(player_name)
        windower.add_to_chat(207, '%s: Removed %s to ignore list':format(_addon.name, player_name))
    end
end

local function positional_arc_swing(me, mob, desired_angle, deadzone, fallback_swing)
  if not (me and mob and me.facing ~= nil and mob.facing ~= nil) then
      return fallback_swing or "Steady"
  end

  local pi = math.pi
  local tau = 2 * pi

  local function norm(a)
      a = a % tau
      if a < 0 then a = a + tau end
      return a
  end

  local function shortest_delta(from, to)
      return (to - from + pi) % (2 * pi) - pi
  end

  local function atan2(y, x)
      if math.atan2 then
          return math.atan2(y, x)
      end
      if x > 0 then
          return math.atan(y / x)
      elseif x < 0 and y >= 0 then
          return math.atan(y / x) + pi
      elseif x < 0 and y < 0 then
          return math.atan(y / x) - pi
      elseif x == 0 and y > 0 then
          return pi / 2
      elseif x == 0 and y < 0 then
          return -pi / 2
      end
      return 0
  end

  local rel_angle = nil
  if me.x ~= nil and me.y ~= nil and mob.x ~= nil and mob.y ~= nil then
      rel_angle = norm(atan2(me.y - mob.y, me.x - mob.x))
  elseif me.x ~= nil and me.z ~= nil and mob.x ~= nil and mob.z ~= nil then
      rel_angle = norm(atan2(me.z - mob.z, me.x - mob.x))
  end

  if rel_angle == nil then
      rel_angle = norm(me.facing)
  end

  local d = shortest_delta(rel_angle, norm(desired_angle))

  if math.abs(d) <= deadzone then
      return "Steady"
  elseif d > 0 then
      return "Left"
  else
      return "Right"
  end
end

---------------------------------------------------------------------------
-- Face target helper (from Trust's player_util.face approach).
-- Directly sets player heading via windower.ffxi.turn() packet.
-- Works regardless of lock-on state.
---------------------------------------------------------------------------
function sc_face_mob(me, mob)
    if not (me and mob) then return end
    if (me.hpp or 0) <= 0 then return end
    -- FFXI heading = -atan2(dy, dx)  (Trust convention)
    local heading = -math.atan2(mob.y - me.y, mob.x - me.x)
    windower.ffxi.turn(heading)
end

local function facing_arc_swing(me, mob, desired_angle, deadzone, fallback_swing)
  if not (me and mob and me.facing ~= nil and mob.facing ~= nil) then
      return fallback_swing or "Steady"
  end

  local pi = math.pi
  local tau = 2 * pi

  local function norm(a)
      a = a % tau
      if a < 0 then a = a + tau end
      return a
  end

  local function shortest_delta(from, to)
      return (to - from + pi) % (2 * pi) - pi
  end

  local mydir = norm(me.facing)
  local desired = norm(desired_angle)
  local d = shortest_delta(mydir, desired)

  if math.abs(d) <= deadzone then
      return "Steady"
  elseif d > 0 then
      return "Left"
  else
      return "Right"
  end
end

function front()
  if casting_spell then stop_strafe(); return end

  local swing = last_swing_front
  local me = windower.ffxi.get_mob_by_target('me')
  local mob = windower.ffxi.get_mob_by_target('st') or windower.ffxi.get_mob_by_target('t')
  if not (me and mob) then stop_strafe(); return end

  local desired = (mob.facing or 0) + math.pi
  swing = facing_arc_swing(me, mob, desired, 0.3, swing)

  if swing == "Right" then
      set_strafe('right')
  elseif swing == "Left" then
      set_strafe('left')
  else
      stop_strafe()
  end
  sc_face_mob(me, mob)

  last_swing_front = swing
end

function face_front()
  if casting_spell then stop_strafe(); return end

  local swing = last_swing_face
  local me = windower.ffxi.get_mob_by_target('me')
  local mob = windower.ffxi.get_mob_by_target('st') or windower.ffxi.get_mob_by_target('t')
  if not (me and mob) then stop_strafe(); return end

  local desired = (mob.facing or 0) + math.pi
  swing = facing_arc_swing(me, mob, desired, 0.3, swing)

  if swing == "Right" then
      set_strafe('right')
  elseif swing == "Left" then
      set_strafe('left')
  else
      stop_strafe()
  end
  sc_face_mob(me, mob)

  last_swing_face = swing
end


function behind()
  if casting_spell then stop_strafe(); return end

  local swing = last_swing_behind
  local me = windower.ffxi.get_mob_by_target('me')
  local mob = windower.ffxi.get_mob_by_target('st') or windower.ffxi.get_mob_by_target('t')
  if not (me and mob) then stop_strafe(); return end

  if info and info.player and mob_last_target and mob_last_target[mob.id] == info.player then
      stop_strafe()
      return
  end

  local desired = (mob.facing or 0)
  swing = facing_arc_swing(me, mob, desired, 0.3, swing)

  if swing == "Right" then
      set_strafe('right')
  elseif swing == "Left" then
      set_strafe('left')
  else
      stop_strafe()
  end
  sc_face_mob(me, mob)

  last_swing_behind = swing
end

---------------------------------------------------------------------------
-- Pet-side positioning (BST petmode / petface)
--
-- Strafes the player around the locked-on mob to stand on the same side
-- as the pet.  The desired orbit angle is the pet→mob direction converted
-- to FFXI heading convention (-atan2) so it matches me.facing.
---------------------------------------------------------------------------
function pet_side()
    if casting_spell then stop_strafe(); return end

    local swing = last_swing_petface
    local me  = windower.ffxi.get_mob_by_target('me')
    local mob = windower.ffxi.get_mob_by_target('st') or windower.ffxi.get_mob_by_target('t')
    local pet = windower.ffxi.get_mob_by_target('pet')
    if not (me and mob and pet) then stop_strafe(); return end

    -- Direction from pet to mob in FFXI heading convention.
    -- FFXI heading = -atan2(dy, dx)  (Trust convention).
    -- me.facing when locked on = -atan2(mob.y - me.y, mob.x - me.x).
    -- When the player stands on the pet, me→mob == pet→mob, so
    -- me.facing will equal this desired angle.
    local desired = -math.atan2(mob.y - pet.y, mob.x - pet.x)

    swing = facing_arc_swing(me, mob, desired, 0.3, swing)

    if swing == "Right" then
        set_strafe('right')
    elseif swing == "Left" then
        set_strafe('left')
    else
        stop_strafe()
    end
    sc_face_mob(me, mob)

    last_swing_petface = swing
end

categories = S{
    'weaponskill_finish',
    'spell_finish',
    'job_ability',
    'mob_tp_finish',
    'avatar_tp_finish',
    'job_ability_unblinkable',
}

function apply_properties(target, resource, action_id, properties, delay, step, closed, bound)
    local clock = os.clock()
    local prev = resonating[target]

    resonating[target] = {
        res=resource,
        id=action_id,
        active=properties,
        delay=clock+delay,
        times=clock+delay+8-step,
        step=step,
        closed=closed,
        bound=bound,

        -- Preserve per-target state across updates
        gs_mode = prev and prev.gs_mode or nil,
        burst_sent = prev and prev.burst_sent or 0,
    }

    if target == targ_id then
        next_frame = clock
    end

    -- Immediate GearSwap burst push when SC reaches step 2+.
    -- This is specifically to allow midcast regear (GearSwap force_midcast_regear) to swap into MB sets
    -- without waiting for the normal 1.5s nuke window.
    if target == targ_id and step and step > 1 and info and info.job == 'BLM' then
        if resonating[target].burst_sent ~= 1 then
            resonating[target].burst_sent = 1
            resonating[target].gs_mode = 'burst'
            windower.send_command('input //gs c burst')
        end
    end
end

function action_handler(act)
    local actionpacket = ActionPacket.new(act)
    local category = actionpacket:get_category_string()
    local actor = actionpacket:get_id()
    local now = os.clock()

    -- Packet-based lockouts for the local player
    if info and info.player and actor == info.player then
        local target = actionpacket:get_targets()()
        local action = target and target:get_actions()() or nil
        local param, resource, action_id, interruption, conclusion = action and action:get_spell() or nil
        local spell = (resource == 'spells') and res.spells[action_id] or nil
        local cast_time = spell and spell.cast_time or 0

        if category == 'spell_begin' or category == 'spell_start' then
            nuke_spell_incast = 1
            nuke_spell_cast_start = now
            nuke_spell_cast_time = cast_time
            nuke_busy_until = now + 2.75
            nuke_clear_preburst_state()

            -- If this was the spell we just attempted, stop retry spam until the spell finishes.
            if spell and nuke_last_sent_spell and spell.en == nuke_last_sent_spell then
                nuke_last_begin_stamp = now
                if nuke_retry_clear then nuke_retry_clear() end
            end
        elseif category == 'spell_finish' then
            nuke_spell_incast = 0
            nuke_spell_cast_start = 0
            nuke_spell_cast_time = 0
            nuke_clear_preburst_state()

        elseif category == 'job_ability' or category == 'job_ability_unblinkable' then
            if (nuke_busy_until or 0) < (now + 1.0) then
                nuke_busy_until = now + 1.0
            end
        elseif category == 'weaponskill_finish' then
            if (nuke_busy_until or 0) < (now + 2.0) then
                nuke_busy_until = now + 2.0
            end
        end
    end

    if info and info.player and actor ~= info.player and act.targets and act.targets[1] then
        mob_last_target[actor] = act.targets[1].id
    end

    if not categories:contains(category) or act.param == 0 then
        return
    end

local target = actionpacket:get_targets()()
    local action = target:get_actions()()
    local message_id = action:get_message_id()
    local add_effect = action:get_add_effect()
    --local basic_info = action:get_basic_info()
    local param, resource, action_id, interruption, conclusion = action:get_spell()
    local ability = skills[resource] and skills[resource][action_id]

    -- BST/SMN pet TP moves: the actor is the pet mob, not the player.
    -- Ensure we recognise our own pet's moves even if the message_id
    -- differs from the standard weapon-skill set.
    local pet_action = false
    if not ability and (category == 'mob_tp_finish' or category == 'avatar_tp_finish') then
        -- Try monster_abilities lookup for BST pets
        if resource == 'monster_abilities' and skills.monster_abilities then
            ability = skills.monster_abilities[action_id]
        end
        -- Fallback: try job_abilities (SMN blood pacts come through here)
        if not ability and skills.job_abilities then
            ability = skills.job_abilities[action_id]
        end
    end
    if ability and (category == 'mob_tp_finish' or category == 'avatar_tp_finish') and is_my_pet(actor) then
        pet_action = true
        -- Detect pet miss / no effect (188 = miss, 189 = no effect)
        local pet_missed = (message_id == 188 or message_id == 189)
        if pet_missed then
            pet_action = false   -- don't create resonation from a miss
        else
            -- Pet ability landed: if it's a self-buff, record the timestamp
            -- so we don't waste charges re-applying while it's still active.
            local pet_ability_name = nil
            if resource == 'monster_abilities' and res.monster_abilities[action_id] then
                pet_ability_name = res.monster_abilities[action_id].en
            elseif resource == 'job_abilities' and res.job_abilities[action_id] then
                pet_ability_name = res.job_abilities[action_id].en
            end
            if pet_ability_name then
                bst_pet_buff_record(pet_ability_name)
            end
        end
        -- BST pet-as-opener: clear the pending hold regardless of hit/miss
        -- so the addon isn't stuck waiting. If the pet missed, no resonation
        -- will be created and the no-reson branch will re-evaluate next tick.
        if bst_pet_opener_pending then
            bst_pet_opener_pending = false
            bst_pet_opener_sent_at = 0
        end
    end

        -- Post-WS nuke buffer
    if category == 'weaponskill_finish' and actor == info.player then
        ws_clear_inflight()
        ws_delay(2.0)  -- success cooldown only
    end


-- If you were manual-casting (pre-nuke) and an autonuke got locked out, retry immediately on spell finish.
if category == 'spell_finish' and actor == info.player then
    nuke_retry_attempt_now()
end

    if add_effect and conclusion and skillchain_ids:contains(add_effect.message_id) then
        local skillchain = add_effect.animation:ucfirst()
        local level = sc_info[skillchain].lvl
        local reson = resonating[target.id]
        local delay = ability and ability.delay or 3
        local step = (reson and reson.step or 1) + 1

        if level == 3 and reson and ability then
            level = check_props(reson.active, aeonic_prop(ability, actor))
        end

        local closed = level == 4

        apply_properties(target.id, resource, action_id, {skillchain}, delay, step, closed)
    elseif ability and (pet_action or message_ids:contains(message_id) or message_id == 2 and buffs[actor] and chain_buff(buffs[actor])) then
        apply_properties(target.id, resource, action_id, aeonic_prop(ability, actor), ability.delay or 3, 1)
    elseif message_id == 529 then
        apply_properties(target.id, resource, action_id, chainbound[param], 2, 1, false, param)
    elseif message_id == 100 and buff_dur[param] then
        buffs[actor] = buffs[actor] or {}
        buffs[actor][param] = buff_dur[param] + os.time()
    end
end

ActionPacket.open_listener(action_handler)

windower.register_event('incoming chunk', function(id, data)
    -- Ensure buff table exists before indexing
    if info and info.player then
        buffs[info.player] = buffs[info.player] or {}
    end
    if id == 0x29 and data:unpack('H', 25) == 206 and data:unpack('I', 9) == info.player then
        buffs[info.player][data:unpack('H', 13)] = nil
    elseif id == 0x50 and data:byte(6) == 0 then
        info.main_weapon = data:byte(5)
        info.main_bag = data:byte(7)
        update_weapon()
    elseif id == 0x50 and data:byte(6) == 2 then
        info.range = data:byte(5)
        info.range_bag = data:byte(7)
        update_weapon()
    elseif id == 0x63 and data:byte(5) == 9 then
        local set_buff = {}
        for n=1,32 do
            local buff = data:unpack('H', n*2+7)
            if buff_dur[buff] or buff > 269 and buff < 273 then
                set_buff[buff] = true
            end
        end
        buffs[info.player] = set_buff
    end
end)

windower.register_event('addon command', function(cmd, ...)
    cmd = cmd and cmd:lower()

    if cmd == 'wslist' then
        ws_print_current()
        return
    elseif cmd == 'wsadd' then
        local listname = ...
        local wsname = table.concat({...}, ' ', 2)
        ws_add_front(listname, wsname)
        return
    elseif cmd == 'wsrm' or cmd == 'wsremove' then
        local listname = ...
        local wsname = table.concat({...}, ' ', 2)
        ws_remove(listname, wsname)
        return
    end

    if cmd == 'move' then
        visible = not visible
        if visible and not skill_props:visible() then
            skill_props:update({disp_info='     --- SkillChains ---\n\n\n\nClick and drag to move display.'})
            skill_props:show()
        elseif not visible then
            skill_props:hide()
        end
    elseif cmd == 'save' then
        local arg = ... and ...:lower() == 'all' and 'all'
        config.save(settings, arg)
        windower.add_to_chat(207, '%s: settings saved to %s character%s.':format(_addon.name, arg or 'current', arg and 's' or ''))
    elseif default.Show[cmd] then
        if not default.Show[cmd][info.job] then
            return error('unable to set %s on %s.':format(cmd, info.job))
        end
        local key = settings.Show[cmd][info.job]
        if not key then
            settings.Show[cmd]:add(info.job)
        else
            settings.Show[cmd]:remove(info.job)
        end
        config.save(settings)
        config.reload(settings)
        settings.dnc_steps = false
        windower.add_to_chat(207, '%s: %s info will no%s be displayed on %s.':format(_addon.name, cmd, key and ' longer' or 'w', info.job))--'t' or 'w'
    elseif type(default[cmd]) == 'boolean' then
        settings[cmd] = not settings[cmd]
        windower.add_to_chat(207, '%s: %s %s':format(_addon.name, cmd, settings[cmd] and 'on' or 'off'))
    elseif cmd == 'eval' then
        assert(loadstring(table.concat({...}, ' ')))()
    elseif cmd == 'auto' then
        if auto == 0 then
            auto = 1
            spam = 0
            cleave = 0
            rotate = 0
            windower.add_to_chat(207, '%s: Auto Skillchain Mode: On':format(_addon.name))
        else
            auto = 0
            windower.add_to_chat(207, '%s: Auto Skillchain Mode: Off':format(_addon.name))
        end
    elseif cmd == 'mb' then
        if burst == 0 then
            burst = 1
            windower.add_to_chat(207, '%s: MB Skillchain Mode: On':format(_addon.name))
        else
            burst = 0
            windower.add_to_chat(207, '%s: MB Skillchain Mode: Off':format(_addon.name))
        end
        elseif cmd == 'steps' then
        dnc_step_rotation_mode = not dnc_step_rotation_mode
        if dnc_step_rotation_mode then
            dnc_step_index = 0
            windower.add_to_chat(207, '%s: DNC step rotation: On':format(_addon.name))
        else
            windower.add_to_chat(207, '%s: DNC step rotation: Off':format(_addon.name))
        end
    elseif cmd == 'nosteps' then
        if nosteps == 0 then
            nosteps = 1
            windower.add_to_chat(207, '%s: DNC Steps Off (flourishes still active)':format(_addon.name))
        else
            nosteps = 0
            windower.add_to_chat(207, '%s: DNC Steps On':format(_addon.name))
        end
    elseif cmd == 'nopet' then
        if nopet == 0 then
            nopet = 1
            windower.add_to_chat(207, '%s: BST Pet Automation Off':format(_addon.name))
        else
            nopet = 0
            windower.add_to_chat(207, '%s: BST Pet Automation On':format(_addon.name))
        end
elseif cmd == 'am' then
        if am == 0 then
            am = 1
            windower.add_to_chat(207, '%s: Aftermath Skillchain Mode: On':format(_addon.name))
        else
            am = 0
            windower.add_to_chat(207, '%s: Aftermath Skillchain Mode: Off':format(_addon.name))
        end
    elseif cmd == 'prefer' then
        if prefer == 0 then
            prefer = 1
            windower.add_to_chat(207, '%s: Preferred Skillchain Mode: On':format(_addon.name))
        else
            prefer = 0
            windower.add_to_chat(207, '%s: Preferred Skillchain Mode: Off':format(_addon.name))
        end
    elseif cmd == 'ranged' then
        if ranged == 0 then
            ranged = 1
            melee = 0
            windower.add_to_chat(207, '%s: Ranged Skillchain Mode: On':format(_addon.name))
        else
            ranged = 0
            windower.add_to_chat(207, '%s: Ranged Skillchain Mode: Off':format(_addon.name))
        end
    elseif cmd == 'melee' then
        if melee == 0 then
            ranged = 0
            melee = 1
            windower.add_to_chat(207, '%s: Melee Skillchain Mode: On':format(_addon.name))
        else
            melee = 0
            windower.add_to_chat(207, '%s: Melee Skillchain Mode: Off':format(_addon.name))
        end
    elseif cmd == 'endless' then
        if endless == 0 then
            endless = 1
            windower.add_to_chat(207, '%s: Endless Skillchain Mode: On':format(_addon.name))
        else
            endless = 0
            windower.add_to_chat(207, '%s: Endless Skillchain Mode: Off':format(_addon.name))
        end
    elseif cmd == 'open' then
        if open == 0 then
            open = 1
            close = 0
            windower.add_to_chat(207, '%s: Open Skillchain Mode: On':format(_addon.name))
        else
            open = 0
            windower.add_to_chat(207, '%s: Open Skillchain Mode: Off':format(_addon.name))
        end
    elseif cmd == 'close' then
        if close == 0 then
            close = 1
            open = 0
            windower.add_to_chat(207, '%s: Close Skillchain Mode: On':format(_addon.name))
        else
            close = 0
            windower.add_to_chat(207, '%s: Close Skillchain Mode: Off':format(_addon.name))
        end
    elseif cmd == 'spam' then
        if spam == 0 or spamsc == 1 or rotate == 1 then
            spam = 1
            spamsc = 0
            auto = 0
            open = 0
            close = 0
            cleave = 0
            rotate = 0
            windower.add_to_chat(207, '%s: Spam Weaponskill Mode: On':format(_addon.name))
        else
            spam = 0
            spamsc = 0
            windower.add_to_chat(207, '%s: Spam Weaponskill Mode: Off':format(_addon.name))
        end
    elseif cmd == 'spamsc' then
        if spamsc == 0 then
            spamsc = 1
            spam = 1
            auto = 0
            open = 0
            close = 0
            cleave = 0
            rotate = 0
            windower.add_to_chat(207, '%s: Spam Skillchain Mode: On':format(_addon.name))
        else
            spamsc = 0
            spam = 0
            windower.add_to_chat(207, '%s: Spam Skillchain Mode: Off':format(_addon.name))
        end
    elseif cmd == 'rotate' then
        if rotate == 0 then
            if #rotate_usable == 0 then
                windower.add_to_chat(167, '%s: No usable weaponskills in rotatews for current weapon.':format(_addon.name))
            else
                rotate = 1
                rotate_index = 1
                spam = 1
                spamsc = 0
                auto = 0
                open = 0
                close = 0
                cleave = 0
                windower.add_to_chat(207, '%s: Rotate Weaponskill Mode: On (%d WS)':format(_addon.name, #rotate_usable))
                for i = 1, #rotate_usable do
                    windower.add_to_chat(207, '  %d: %s':format(i, rotate_usable[i]))
                end
            end
        else
            rotate = 0
            rotate_index = 1
            spam = 0
            windower.add_to_chat(207, '%s: Rotate Weaponskill Mode: Off':format(_addon.name))
        end
    elseif cmd == 'spamtp' then
        local val = tonumber((...))
        if val and val >= 1000 and val <= 3000 then
            spamtp = val
            windower.add_to_chat(207, '%s: Spam TP threshold set to %d':format(_addon.name, spamtp))
        else
            windower.add_to_chat(207, '%s: Spam TP threshold is %d (usage: //sc spamtp <1000-3000>)':format(_addon.name, spamtp))
        end
    elseif cmd == 'cleave' then
        if cleave == 0 then
            spamsc = 0
            rotate = 0
            if spam == 0 then
                spam = 1
                auto = 0
                open = 0
                close = 0
                cleave = 1
            else
                cleave = 1
            end
            windower.add_to_chat(207, '%s: Cleave Weaponskill Mode: On':format(_addon.name))
        else
            cleave = 0
            windower.add_to_chat(207, '%s: Cleave Weaponskill Mode: Off':format(_addon.name))
        end
    elseif cmd == 'starter' then
        if starter == 0 then
            starter = 1
            windower.add_to_chat(207, '%s: Starter Weaponskill Mode: On':format(_addon.name))
        else
            starter = 0
            windower.add_to_chat(207, '%s: Starter Weaponskill Mode: Off':format(_addon.name))
        end
    elseif cmd == 'strict' then
        if strict == 0 then
            strict = 1
            windower.add_to_chat(207, '%s: Strict Weaponskill Mode: On':format(_addon.name))
        else
            strict = 0
            windower.add_to_chat(207, '%s: Strict Weaponskill Mode: Off':format(_addon.name))
        end
    elseif cmd == 'buddy' then
        if buddy == 0 then
            buddy = 1
            windower.add_to_chat(207, '%s: Buddy Skillchain Mode: On':format(_addon.name))
        else
            buddy = 0
            tagin = 0
            windower.add_to_chat(207, '%s: Buddy Skillchain Mode: Off':format(_addon.name))
        end
    elseif cmd == 'autonuke' then
        if autonuke == 0 then
            autonuke = 1
            windower.add_to_chat(207, '%s: Autonuke Magicburst Mode: On':format(_addon.name))
        else
            autonuke = 0
            nuking = 0
            windower.add_to_chat(207, '%s: Autonuke Magicburst Mode: Off':format(_addon.name))
        end
    elseif cmd == 'ebul' or cmd == 'ebullience' then
        if sc_ebul_mode == 0 then
            sc_ebul_mode = 1
            windower.add_to_chat(207, '%s: Preburst Ebullience Mode: On':format(_addon.name))
        else
            sc_ebul_mode = 0
            windower.add_to_chat(207, '%s: Preburst Ebullience Mode: Off':format(_addon.name))
        end
    elseif cmd == 'alac' or cmd == 'alacrity' then
        if sc_alac_mode == 0 then
            sc_alac_mode = 1
            windower.add_to_chat(207, '%s: Preburst Alacrity Mode: On':format(_addon.name))
        else
            sc_alac_mode = 0
            windower.add_to_chat(207, '%s: Preburst Alacrity Mode: Off':format(_addon.name))
        end
    elseif cmd == 'cascade' then
        if sc_cascade_mode == 0 then
            sc_cascade_mode = 1
            windower.add_to_chat(207, '%s: Preburst Cascade Mode: On':format(_addon.name))
        else
            sc_cascade_mode = 0
            windower.add_to_chat(207, '%s: Preburst Cascade Mode: Off':format(_addon.name))
        end

elseif cmd == 'nukespam' or cmd == 'tierspam' then
    -- On NIN main, nukespam is a transparent alias for //sc wheel.
    -- On any other job, it toggles the normal single-element nuke spam.
    local p = windower.ffxi.get_player()
    if p and p.main_job == 'NIN' then
        -- Force nukespam off as a guard so a stale BLM-era nukespam=1 can't
        -- coexist with wheel=1 after a job change.
        nukespam = 0
        if wheel == 0 then
            wheel = 1
            wheel_target_id = nil
            wheel_idx = wheel_start_index()
            wheel_last_spell = nil
            wheel_last_delay = 0
            wheel_cast_lock_until = 0
            wheel_retry_clear()
            windower.add_to_chat(207, '%s: Wheel (San) Mode: On':format(_addon.name))
        else
            wheel = 0
            wheel_target_id = nil
            wheel_last_spell = nil
            wheel_last_delay = 0
            wheel_cast_lock_until = 0
            wheel_retry_clear()
            windower.add_to_chat(207, '%s: Wheel (San) Mode: Off':format(_addon.name))
        end
    else
        if nukespam == 0 then
            nukespam = 1
            windower.add_to_chat(207, '%s: Nuke Spam: On':format(_addon.name))
        else
            nukespam = 0
            windower.add_to_chat(207, '%s: Nuke Spam: Off':format(_addon.name))
        end
    end

elseif cmd == 'nukedebug' then
    if nukespam_debug == 0 then
        nukespam_debug = 1
        windower.add_to_chat(207, '%s: Nukespam Debug: On':format(_addon.name))
    else
        nukespam_debug = 0
        windower.add_to_chat(207, '%s: Nukespam Debug: Off':format(_addon.name))
    end
elseif nukespam_mb_map[cmd] then
    -- Sole authority for the burst force. nukes.lua's handler no longer toggles
    -- force_mb for <ele>mb commands (both handlers receive every //sc command).
    local wanted = nukespam_mb_map[cmd]
    if nukes.get_force_mb() == wanted then
        nukes.set_force_mb(nil)
        nukespam_force_ele = nil
        windower.add_to_chat(207, '%s: Burst element force: Auto':format(_addon.name))
    else
        nukes.set_force_mb(wanted)
        nukespam_force_ele = nukespam_ele_for(wanted)
        windower.add_to_chat(207, '%s: Burst element force: %s (nukespam: %s)':format(_addon.name, wanted, nukespam_force_ele))
    end
elseif cmd == 'nomb' or cmd == 'mboff' or cmd == 'mbclear' then
    -- nukes.lua's handler clears force_mb for these; clear the nukespam side here.
    nukespam_force_ele = nil
elseif cmd == 'mana' then
    nukespam_force_ele = nil
    nukes.reset()
    windower.add_to_chat(207, '%s: Burst element control reset: force off, all elements enabled.':format(_addon.name))

    -- //sc wheel cmd disabled: //sc nukespam now toggles wheel on NIN main job.
    -- This block left in place (commented) so it can be easily restored if needed.
    -- elseif cmd == 'wheel' then
    --     local p = windower.ffxi.get_player()
    --     if not p or p.main_job ~= 'NIN' then
    --         windower.add_to_chat(207, '%s: Wheel Mode requires NIN main job.':format(_addon.name))
    --         return
    --     end
    --     if wheel == 0 then
    --         wheel = 1
    --         wheel_target_id = nil
    --         wheel_idx = wheel_start_index()
    --         wheel_last_spell = nil
    --         wheel_last_delay = 0
    --         wheel_cast_lock_until = 0
    --         wheel_retry_clear()
    --         windower.add_to_chat(207, '%s: Wheel (San) Mode: On':format(_addon.name))
    --     else
    --         wheel = 0
    --         wheel_target_id = nil
    --         wheel_last_spell = nil
    --         wheel_last_delay = 0
    --         wheel_cast_lock_until = 0
    --         wheel_retry_clear()
    --         windower.add_to_chat(207, '%s: Wheel (San) Mode: Off':format(_addon.name))
    --     end
elseif cmd == 'party' then
        if buddy == 0 then
            buddy = 1
            windower.add_to_chat(207, '%s: Buddy Skillchain Mode: On':format(_addon.name))
        end
        if auto == 0 then
            auto = 1
            spam = 0
            spamsc = 0
            rotate = 0
            windower.add_to_chat(207, '%s: Auto Skillchain Mode: On':format(_addon.name))
        end
    elseif cmd == 'partyam' then
        if buddy == 0 then
            buddy = 1
            windower.add_to_chat(207, '%s: Buddy Skillchain Mode: On':format(_addon.name))
        end
        if auto == 0 then
            auto = 1
            spam = 0
            spamsc = 0
            rotate = 0
            windower.add_to_chat(207, '%s: Auto Skillchain Mode: On':format(_addon.name))
        end
        if am == 0 then
            am = 1
            windower.add_to_chat(207, '%s: Aftermath Skillchain Mode: On':format(_addon.name))
        end
      elseif cmd == 'partymb' then
          if buddy == 0 then
              buddy = 1
              windower.add_to_chat(207, '%s: Buddy Skillchain Mode: On':format(_addon.name))
          end
          if auto == 0 then
              auto = 1
              spam = 0
              spamsc = 0
              rotate = 0
              windower.add_to_chat(207, '%s: Auto Skillchain Mode: On':format(_addon.name))
          end
          if burst == 0 then
              burst = 1
              windower.add_to_chat(207, '%s: MB Skillchain Mode: On':format(_addon.name))
          end
    elseif cmd == 'light' then
        if light == 0 then
            light = 1
            dark = 0
            sc_force_element = nil
            windower.add_to_chat(207, '%s: Light Skillchain Mode: On':format(_addon.name))
        else
            light = 0
            windower.add_to_chat(207, '%s: Light Skillchain Mode: Off':format(_addon.name))
        end
    elseif cmd == 'dark' then
        if dark == 0 then
            dark = 1
            light = 0
            sc_force_element = nil
            windower.add_to_chat(207, '%s: Dark Skillchain Mode: On':format(_addon.name))
        else
            dark = 0
            windower.add_to_chat(207, '%s: Dark Skillchain Mode: Off':format(_addon.name))
        end
    elseif normalize_sc_force_element(cmd) ~= nil then
        local wanted = normalize_sc_force_element(cmd)
        if sc_force_element == wanted then
            sc_force_element = nil
            windower.add_to_chat(207, '%s: Element Skillchain Filter: Auto':format(_addon.name))
        else
            sc_force_element = wanted
            light = 0
            dark = 0
            windower.add_to_chat(207, '%s: Element Skillchain Filter: %s':format(_addon.name, wanted))
        end
    elseif cmd == 'nuking' then
        if nuking == 1 then
            nuking = 0
        end
    elseif cmd == 'ongo' then
      if ongo == 0 then
        ongo = 1
        windower.add_to_chat(207, '%s: Ongo Mode: On':format(_addon.name))
      else
        ongo = 0
        windower.add_to_chat(207, '%s: Ongo Mode: Off':format(_addon.name))
      end
    elseif cmd == 'ignore' then
        ignore_player(unpack({...}))
    elseif cmd == 'watch' then
        watch_player(unpack({...}))
    elseif cmd == 'status' then
        if auto == 1 then
            windower.send_command('input /echo Auto Skillchain Mode')
        end
        if burst == 1 then
            windower.send_command('input /echo MB Skillchain Mode')
        end
        if ultimate == 1 then
            windower.send_command('input /echo Ultimate Skillchain Mode')
        end
        if am == 1 then
            windower.send_command('input /echo AM Skillchain Mode')
        end
        if prefer == 1 then
            windower.send_command('input /echo Preferred Skillchain Mode')
        end
        if endless == 1 then
            windower.send_command('input /echo Endless Skillchain Mode')
        end
        if buddy == 1 then
            windower.send_command('input /echo Buddy Skillchain Mode')
        end
        if spam == 1 then
            windower.send_command('input /echo Spam Weaponskill Mode')
            windower.send_command('input /echo Spam TP Threshold: ' .. spamtp)
        end
        if spamsc == 1 then
            windower.send_command('input /echo Spam Skillchain Mode')
        end
        if rotate == 1 then
            windower.send_command('input /echo Rotate Weaponskill Mode (' .. #rotate_usable .. ' WS)')
            if #rotate_usable > 0 then
                if rotate_index > #rotate_usable then rotate_index = 1 end
                windower.send_command('input /echo Next: ' .. (rotate_usable[rotate_index] or '?'))
            end
        end
        if cleave == 1 then
            windower.send_command('input /echo Cleave Weaponskill Mode')
        end
        if starter == 1 then
            windower.send_command('input /echo Starter Weaponskill Mode')
        end
        if nosteps == 1 then
            windower.send_command('input /echo DNC Steps Off')
        end
        if nopet == 1 then
            windower.send_command('input /echo BST Pet Automation Off')
        end
        if ranged == 1 then
            windower.send_command('input /echo Ranged Weaponskill Mode')
        end
        if melee == 1 then
            windower.send_command('input /echo Melee Weaponskill Mode')
        end
        if autonuke == 1 then
            windower.send_command('input /echo Autonuke Magicburst Mode')
        end
        if sc_ebul_mode == 1 then
            windower.send_command('input /echo Preburst Ebullience Mode')
        end
        if sc_alac_mode == 1 then
            windower.send_command('input /echo Preburst Alacrity Mode')
        end
        if sc_cascade_mode == 1 then
            windower.send_command('input /echo Preburst Cascade Mode')
        end
        if open == 1 then
		        windower.send_command('input /echo Open Skillchain Mode')
        end
        if close == 1 then
		        windower.send_command('input /echo Close Skillchain Mode')
        end
        if innin == 1 then
		        windower.send_command('input /echo Innin Mode')
        end
        if yonin == 1 then
            windower.send_command('input /echo Yonin Mode')
        end
        if petface == 1 then
            windower.send_command('input /echo Pet Face Mode')
        end
        if petmode == 1 then
            windower.send_command('input /echo Pet Mode')
        end
        if rear == 1 then
            windower.send_command('input /echo Rear Face Mode')
        end
        if strict == 1 then
            windower.send_command('input /echo Strict Mode')
        end
        if w_readies == 1 then
            windower.send_command('input /echo While Readying Mode')
        end
        if w_casting == 1 then
            windower.send_command('input /echo While Casting Mode')
        end
        if light == 1 then
            windower.send_command('input /echo Light Skillchain Mode')
        end
        if dark == 1 then
            windower.send_command('input /echo Dark Skillchain Mode')
        end
        if sc_force_element ~= nil then
            windower.send_command('input /echo Element Skillchain Filter: '..sc_force_element)
        end
        if bst_pet_opener ~= nil then
            windower.send_command('input /echo BST Pet Opener: '..bst_pet_opener)
        end
    elseif cmd == 'reload' then
        windower.send_command('input //st off')
        windower.send_command('lua reload skillchainsplus')
    elseif cmd == 'help' or cmd == '?' then
        windower.add_to_chat(207, _addon.name..' commands:')

        windower.add_to_chat(207, ' General:')
        windower.add_to_chat(207, '  status | reload')

        windower.add_to_chat(207, ' Combat modes:')
        windower.add_to_chat(207, '  auto | melee | ranged | endless')

        windower.add_to_chat(207, ' Skillchains / WS control:')
        windower.add_to_chat(207, '  spam | spamsc | spamtp <1000-3000> | rotate | cleave | starter | prefer | buddy')
        windower.add_to_chat(207, '  strict (only close with preferws) | ultimate (only close level 4)')
        windower.add_to_chat(207, '  party | partymb | partyam (combo shortcuts: auto+buddy [+mb/+am])')
        windower.add_to_chat(207, '  whilecasting | whilereadies (allow spam during casting/readying)')
        windower.add_to_chat(207, '  steps (toggle DNC step rotation: Box Step > Quickstep > Feather Step)')
        windower.add_to_chat(207, '  nosteps (toggle DNC steps off, flourishes still active)')
        windower.add_to_chat(207, '  nopet (toggle BST pet automation off)')
        windower.add_to_chat(207, '  weapon | bst | aeonic')

        windower.add_to_chat(207, ' Magic / Burst control:')
        windower.add_to_chat(207, '  mb | burst | am | autonuke | ebul(lience) | alac(rity) | cascade | nukespam | tierspam')
        windower.add_to_chat(207, '  wheel (NIN elemental wheel) | nukedebug (nukespam debug output)')
        windower.add_to_chat(207, '  nomb | mboff | mbclear (clear forced burst element)')
        windower.add_to_chat(207, '  <ele>mb (force burst element only, e.g. watermb/icemb/firemb/darkmb; repeat to clear)')
        windower.add_to_chat(207, '  no<ele> (exclude element from bursting, e.g. nowater/noice/nofire; repeat to re-enable)')
        windower.add_to_chat(207, '  mana (reset burst element control: force off, all exclusions cleared)')

        windower.add_to_chat(207, ' Lists / Filters:')
        windower.add_to_chat(207, '  ignore <name> | watch <name> | open | close | save | move | ongo')
        windower.add_to_chat(207, '  light | dark | fire | ice | wind | earth | stone | thunder | lightning | water | holy')

        windower.add_to_chat(207, ' Positioning:')
        windower.add_to_chat(207, '  innin | yonin (simple strafe)')
        windower.add_to_chat(207, '  pet | petface (pet side / pet side + approach)')
        windower.add_to_chat(207, '  face | rear (front + approach / behind + approach)')

        windower.add_to_chat(207, ' Utility / Display:')
        windower.add_to_chat(207, '  props | step | timer | color')

        windower.add_to_chat(207, ' Runtime WS editing:')
        windower.add_to_chat(207, '  wslist')
        windower.add_to_chat(207, '  wsadd <list> <weaponskill>')
        windower.add_to_chat(207, '  wsrm | wsremove <list> <weaponskill>')
        windower.add_to_chat(207, '  (runtime only, use //sc reload to reset)')

        windower.add_to_chat(207, ' Macro triggers (/console sc ...):')
        windower.add_to_chat(207, '  autoskill (close SC with selected WS) | spamskill (use zergws) | autoburst')
    elseif cmd == 'autoskill' then
        if autosc ~= nil then
            windower.send_command('input /ws '..autosc..' <t>')
        else
            windower.send_command('input /ws '..openws..' <t>')
        end
    elseif cmd == 'autoburst' then
        if automb ~= nil then
            windower.send_command('sc '..automb..'')
        end
    elseif cmd == 'spamskill' then
        if zergws ~= nil then
            windower.send_command('input /ws '..zergws..' <t>')
        end
    elseif cmd == 'ultimate' then
        if ultimate == 1 then
            ultimate = 0
    			  windower.add_to_chat(207, '%s: Ultimate Mode: Off':format(_addon.name))
        else
            ultimate = 1
    			  windower.add_to_chat(207, '%s: Ultimate Mode: On':format(_addon.name))
        end
    elseif cmd == 'innin' then
        if innin == 1 then
            innin = 0
            force_stop_movement()
    			  windower.add_to_chat(207, '%s: Innin Mode: Off':format(_addon.name))
        else
            innin = 1
            yonin = 0
            face = 0
            petmode = 0
            petface = 0
            rear = 0
            force_stop_movement()
    			  windower.add_to_chat(207, '%s: Innin Mode: On':format(_addon.name))
        end
    elseif cmd == 'yonin' then
        if yonin == 1 then
            yonin = 0
            force_stop_movement()
            windower.add_to_chat(207, '%s: Yonin Mode: Off':format(_addon.name))
        else
            yonin = 1
            innin = 0
            face = 0
            petmode = 0
            petface = 0
            rear = 0
            force_stop_movement()
            windower.add_to_chat(207, '%s: Yonin Mode: On':format(_addon.name))
        end
    elseif cmd == 'face' then
        if face == 1 then
            face = 0
            force_stop_movement()
            windower.send_command('wait 0.2;setkey numpad8 up;setkey numpad4 up;setkey numpad6 up')
            windower.add_to_chat(207, '%s: Face Mode: Off':format(_addon.name))
        else
            face = 1
            innin = 0
            yonin = 0
            petmode = 0
            petface = 0
            rear = 0
            force_stop_movement()
            windower.add_to_chat(207, '%s: Face Mode: On':format(_addon.name))
        end

    elseif cmd == 'pet' then
        if petmode == 1 then
            petmode = 0
            force_stop_movement()
            windower.add_to_chat(207, '%s: Pet Mode: Off':format(_addon.name))
        else
            petmode = 1
            innin = 0
            yonin = 0
            face = 0
            petface = 0
            rear = 0
            force_stop_movement()
            windower.add_to_chat(207, '%s: Pet Mode: On':format(_addon.name))
        end

    elseif cmd == 'petface' then
        if petface == 1 then
            petface = 0
            force_stop_movement()
            windower.send_command('wait 0.2;setkey numpad8 up;setkey numpad4 up;setkey numpad6 up')
            windower.add_to_chat(207, '%s: Pet Face Mode: Off':format(_addon.name))
        else
            petface = 1
            innin = 0
            yonin = 0
            face = 0
            petmode = 0
            rear = 0
            force_stop_movement()
            windower.add_to_chat(207, '%s: Pet Face Mode: On':format(_addon.name))
        end

    elseif cmd == 'rear' then
        if rear == 1 then
            rear = 0
            force_stop_movement()
            windower.send_command('wait 0.2;setkey numpad8 up;setkey numpad4 up;setkey numpad6 up')
            windower.add_to_chat(207, '%s: Rear Face Mode: Off':format(_addon.name))
        else
            rear = 1
            innin = 0
            yonin = 0
            face = 0
            petmode = 0
            petface = 0
            force_stop_movement()
            windower.add_to_chat(207, '%s: Rear Face Mode: On':format(_addon.name))
        end

    elseif cmd == 'whilecasting' then
        if w_casting == 1 then
            w_casting = 0
            windower.add_to_chat(207, '%s: While Casting Mode: Off':format(_addon.name))
        else
            w_casting = 1
            wstrigger = 1
            spam = 1
            spamsc = 0
            rotate = 0
            auto = 0
            open = 0
            close = 0
            windower.add_to_chat(207, '%s: While Casting Mode: On':format(_addon.name))
        end
    elseif cmd == 'whilereadies' then
        if w_readies == 1 then
            w_readies = 0
            windower.add_to_chat(207, '%s: While Readying Mode: Off':format(_addon.name))
        else
            w_readies = 1
            wstrigger = 1
            spam = 1
            spamsc = 0
            rotate = 0
            auto = 0
            open = 0
            close = 0
            windower.add_to_chat(207, '%s: While Readying Mode: On':format(_addon.name))
        end
    end
end)

windower.register_event('tp change',function(new,old)

    dnc_try_reverse_flourish_on_tp_change(new, old)
    check_sc()

end)

windower.register_event('job change', function(job, lvl)
    job = res.jobs:with('id', job).english_short
    if job ~= info.job then
        info.job = job
        config.reload(settings)
        settings.dnc_steps = false
        varclean()
        check_sc()
    end
end)

windower.register_event('zone change', function()

    varclean()

end)

windower.register_event('load', function()
    if windower.ffxi.get_info().logged_in then
        local equip = windower.ffxi.get_items('equipment')
        info.main_weapon = equip.main
        info.main_bag = equip.main_bag
        info.range = equip.range
        info.range_bag = equip.range_bag
        update_weapon()
        buffs[info.player] = {}
    end
end)

windower.register_event('unload', function()
    if check_weapon then
        coroutine.close(check_weapon)
    end
end)

windower.register_event('logout', function()
    if check_weapon then
        coroutine.close(check_weapon)
    end
    check_weapon = nil
    info = {}
    resonating = {}
    buffs = {}
end)
