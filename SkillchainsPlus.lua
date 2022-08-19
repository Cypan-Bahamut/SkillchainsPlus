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
_addon.name = 'SkillchainsPlus'
_addon.version = '2.3'

require('luau')
require('pack')
require('actions')

file  = require('files')
nukes = require('nukes')
texts = require('texts')
skills = require('skills')
res = require('resources')

_static = S{'WAR','MNK','WHM','BLM','RDM','THF','PLD','DRK','BST','BRD','RNG','SAM','NIN','DRG','SMN','BLU','COR','PUP','DNC','SCH','GEO','RUN'}
rangedws = S{'Flaming Arrow','Piercing Arrow','Dulling Arrow','Sidewinder','Blast Arrow','Arching Arrow','Empyreal Arrow','Refulgent Arrow','Apex Arrow','Namas Arrow','Jishnu\'s Radiance','Hot Shot','Split Shot','Sniper Shot','Slug Shot','Blast Shot','Heavy Shot','Detonator','Numbing Shot','Last Stand','Coronach	Wildfire','Trueflight','Leaden Salute'}
ignoretp = S{''}

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
    spam = 0
    strict = 0
    prefer = 0
    endless = 0
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
    faw = 0
    open = 0
    close = 0
    light = 0
    dark = 0
    ultimate = 0
    w_casting = 0
    w_readies = 0

    tagtime = os.clock()

    openws = nil
    petopen = nil
    initws = nil
    overws = nil
    zergws = nil
    aoews = nil
    automb = nil

    jobvar()

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
    initws = nil
    overws = nil
    zergws = nil
    aoews = nil
    initws = nil

    local abilities = windower.ffxi.get_abilities().weapon_skills
    local pet = windower.ffxi.get_abilities().job_abilities

    if ranged == 1 then
        for i = 1,#defaultws,+1 do
            if rangedws:contains(defaultws[i]) then
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
        for i = 1,#tpws,+1 do
            for s = 1,#abilities,+1 do
                if overws == nil then
                    if rangedws:contains(defaultws[i]) then
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
            if rangedws:contains(spamws[i]) then
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
        for i = 1,#starterws,+1 do
            if rangedws:contains(starterws[i]) then
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
                    local wsid =  res.weapon_skills:with('en',defaultws[i]).id
                    local wsid = tonumber(wsid)
                    if abilities[s] == wsid then
                        openws = defaultws[i]
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
        for i = 1,#cleavews,+1 do
            for s = 1,#abilities,+1 do
                if aoews == nil then
                    local wsid =  res.weapon_skills:with('en',cleavews[i]).id
                    local wsid = tonumber(wsid)
                    if abilities[s] == wsid then
                        aoews = cleavews[i]
                    end
                end
            end
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
                for p = 1,#pet,+1 do
                    if petopen == nil then
                        local wsid =  res.job_abilities:with('en',petws[i]).id
                        local wsid = tonumber(wsid)
                        if pet[p] == wsid then
                            petopen = petws[i]
                        end
                    end
                end
            end
        end
    end

end

function ws_delay()

  wsdelay = 1
  tpdelay = 1
  wstime = os.clock()

end


function pet_delay()

  petdelay = 1
  pettime = os.clock()

end


default = {}
default.Show = {burst=_static, pet=S{'BST','SMN'}, props=_static, spell=S{'SCH','BLU'}, step=_static, timer=_static, weapon=_static}
default.UpdateFrequency = 0.2
default.aeonic = false
default.color = false
default.display = {text={size=12,font='Consolas'},pos={x=0,y=0},bg={visible=true}}

settings = config.load(default)
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
    elseif settings.Show.pet[info.job] and windower.ffxi.get_mob_by_target('pet') then
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
                                if ((sicdelay + petmp) < 4) then
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
                        if rangedws:contains(chain[1]) then
                            meleeskill = 1
                        else
                            meleeskill = 0
                        end
                    end
                    if meleeskill == 0 then
                        local chainoneele = string.gsub(chain[3], '%d%s', '')
                        if light == 1 then
                            if lightchains:contains(''..chainoneele..'') then
                                if chainonews == nil then
                                    chainonelvl = chain[2]
                                    chainonews = chain[1]
                                elseif chaintwows == nil then
                                    chaintwolvl = chain[2]
                                    chaintwows = chain[1]
                                end
                            end
                        elseif dark == 1 then
                            if darkchains:contains(''..chainoneele..'') then
                                if chainonews == nil then
                                    chainonelvl = chain[2]
                                    chainonews = chain[1]
                                elseif chaintwows == nil then
                                    chaintwolvl = chain[2]
                                    chaintwows = chain[1]
                                end
                            end
                        else
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
                            if rangedws:contains(endlesscln) then
                                if light == 1 then
                                    if lightchains:contains(''..endlessele..'') then
                                        endlesssc = endlesscln
                                    end
                                elseif dark == 1 then
                                    if darkchains:contains(''..endlessele..'') then
                                        endlesssc = endlesscln
                                    end
                                else
                                    endlesssc = endlesscln
                                end
                            end
                        else
                            if light == 1 then
                                if lightchains:contains(''..endlessele..'') then
                                    endlesssc = endlesscln
                                end
                            elseif dark == 1 then
                                if darkchains:contains(''..endlessele..'') then
                                    endlesssc = endlesscln
                                end
                            else
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
                        if light == 1 then
                            if lightchains:contains(''..preferele..'') then
                                prefersc = preferchkcln
                            end
                        elseif dark == 1 then
                            if darkchains:contains(''..preferele..'') then
                                prefersc = preferchkcln
                            end
                        elseif prefersc == nil then
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
                if rangedws:contains(preferws[p]) then
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
                                if light == 1 then
                                    if lightchains:contains(''..preferele..'') then
                                        prefersc = preferchkcln
                                    end
                                elseif dark == 1 then
                                    if darkchains:contains(''..preferele..'') then
                                        prefersc = preferchkcln
                                    end
                                elseif prefersc == nil then
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
                if rangedws:contains(rangedchkcln) then
                    if rangedwsone == nil then
                        if light == 1 then
                            if lightchains:contains(''..rangedele..'') then
                                rangedwsone = rangedchkcln
                                rangedlvlone = rangedchk[2]
                            end
                        elseif dark == 1 then
                            if darkchains:contains(''..rangedele..'') then
                                rangedwsone = rangedchkcln
                                rangedlvlone = rangedchk[2]
                            end
                        else
                            rangedwsone = rangedchkcln
                            rangedlvlone = rangedchk[2]
                        end
                    elseif rangedwstwo == nil then
                        if light == 1 then
                            if lightchains:contains(''..rangedele..'') then
                                rangedwstwo = rangedchkcln
                                rangedlvltwo = rangedchk[2]
                            end
                        elseif dark == 1 then
                            if darkchains:contains(''..rangedele..'') then
                                rangedwstwo = rangedchkcln
                                rangedlvltwo = rangedchk[2]
                            end
                        else
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


windower.register_event('target change', function()

    if starter == 1 then
        started = 0
    end

end)


windower.register_event('prerender', function()

    if not windower.ffxi.get_player() then return end

    local now = os.clock()

    if now < next_frame then
        return
    end

    next_frame = now + 0.1

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
            if os.clock() - wstime > 2.75 then
                wsdelay = 0
            end
        end

        if tpdelay == 1 then
            if os.clock() - wstime > 0.5 then
                tpdelay = 0
            end
        end

        if petdelay == 1 then
            if os.clock() - pettime > 1.25 then
                petdelay = 0
            end
        end

        if player.main_job == 'BST' then
            if (windower.ffxi.get_ability_recasts()[102] > 0) then
                if (windower.ffxi.get_ability_recasts()[102] > (bstrecast * 2)) then
                    sicdelay = 3
                elseif (windower.ffxi.get_ability_recasts()[102] > (bstrecast * 1)) then
                    sicdelay = 2
                else
                    sicdelay = 1
                end
            else
                sicdelay = 0
            end
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
            if (mobdist < wsdist) then
                if player.main_job == 'NIN' then
                    if faw == 0 then
                        behind()
                    end
                else
                    behind()
                end
            else
                windower.send_command('setkey numpad4 up')
                windower.send_command('setkey numpad6 up')
            end
        else
            windower.send_command('setkey numpad4 up')
            windower.send_command('setkey numpad6 up')
        end

        if yonin == 1 and status == 1 then
            if (mobdist < wsdist) then
                front()
            else
                windower.send_command('setkey numpad4 up')
                windower.send_command('setkey numpad6 up')
            end
        else
            windower.send_command('setkey numpad4 up')
            windower.send_command('setkey numpad6 up')
        end

        local targ = windower.ffxi.get_mob_by_target('t', 'bt')
        targ_id = targ and targ.id
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
    								                perform_ws(autosc)
                                elseif petsc ~= nil and tp < 1000 then
                                    perform_pet(petsc)
                                elseif close == 0 then
                                    if tp > 2000 and overws ~= nil then
                                        perform_ws(overws)
                                    elseif openws ~= nil and ultimate == 0 and tp > 999 then
    									                  perform_ws(openws)
                                    elseif petopen ~= nil then
                                        perform_pet(petopen)
                                    end
                                end
                            elseif amthree == 1 and tp == 3000 then
                                if amws ~= nil then
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
                            perform_ws(overws)
                        elseif tp > 999 and openws ~= nil then
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
            if reson.step > 1 and timer > 1.5 then
                if ongo == 0 then
                    if reson.props == 'Light' or reson.props == 'Radiance' then
        				        perform_spell('lightmb')
                        automb = "lightmb"
                    elseif reson.props == 'Darkness' or reson.props == 'Umbra' then
        			          perform_spell('darknessmb')
                        automb = "darknessmb"
                    elseif reson.props == 'Gravitation' then
        				        perform_spell('gravmb')
                        automb = "gravmb"
                    elseif reson.props == 'Fragmentation' then
        				        perform_spell('fragmb')
                        automb = "fragmb"
                    elseif reson.props == 'Distortion' then
        				        perform_spell('distomb')
                        automb = "distomb"
                    elseif reson.props == 'Fusion' then
        				        perform_spell('fusionmb')
                        automb = "fusionmb"
                    elseif reson.props == 'Compression' then
                        perform_spell('darkmb')
                        automb = "darkmb"
                    elseif reson.props == 'Liquefaction' then
        				        perform_spell('firemb')
                        automb = "firemb"
                    elseif reson.props == 'Induration' then
        				        perform_spell('blizzardmb')
                        automb = "blizzardmb"
                    elseif reson.props == 'Reverberation' then
        				        perform_spell('watermb')
                        automb = "watermb"
                    elseif reson.props == 'Transfixion' then
                        perform_spell('holymb')
                        automb = "holymb"
                    elseif reson.props == 'Scission' then
        				        perform_spell('stonemb')
                        automb = "stonemb"
                    elseif reson.props == 'Detonation' then
        				        perform_spell('aeromb')
                        automb = "aeromb"
                    elseif reson.props == 'Impaction' then
        				        perform_spell('thundermb')
                        automb = "thundermb"
                    end
                elseif ongo == 1 then
                    if reson.props == 'Scission' or reson.props == 'Gravitation' or reson.props == 'Darkness' or reson.props == 'Umbra' then
                        perform_spell('ongomb')
                        automb = "ongomb"
                    end
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
                        if tp > 2000 and overws ~= nil then
                            perform_ws(overws)
                        elseif tp > 999 and openws ~= nil then
                            perform_ws(openws)
                        elseif petopen ~= nil then
                            perform_pet(petopen)
                        end
                    elseif starter == 1 and started == 0 then
                        if tp > 999 and initws ~= nil then
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
            if ((w_casting == 1 or w_readies == 1) and wstrigger == 0) or (w_casting == 0 and w_readies == 0) then
                if amthree == 0 then
                    if tp > 999 and cleave == 1 then
                        if aoews ~= nil then
                            perform_ws(aoews)
                        end
                    elseif tp > 999 and starter == 0 or started == 1 then
                        if zergws ~= nil then
            				        perform_ws(zergws)
                            wstrigger = 1
                        end
                    elseif tp > 999 and starter == 1 and started == 0 then
                        if initws ~= nil then
                            perform_ws(initws)
                            started = 1
                            wstrigger = 1
                        end
                    elseif petopen ~= nil then
                        perform_pet(petopen)
                    end
                elseif tp == 3000 and amthree == 1 then
                    if amws ~= nil then
        				        perform_ws(amws)
                        wstrigger = 1
                    end
                end
            end
        end
    end
end)


windower.register_event(
    "incoming text",
    function(original, modified, mode)

    local tmob = windower.ffxi.get_mob_by_target('t')
    local tname = tmob and tmob.name

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
    local pname = player.name

    return modified, mode
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
    player = windower.ffxi.get_player()
  	petws_name = string.gsub(petws_name, '[ \t]+%f[\r\n%z]', '')
    petws_mp = res.job_abilities:with('en', petws_name).mp_cost
    if petdelay == 0 then
        if player.main_job == 'BST' then
            if (sicdelay + petws_mp) < 4 then
                windower.send_command('input /pet '..petws_name..' <me>')
            end
        elseif player.main_job == 'SMN' then
            if bpdelay < 1 then
                windower.send_command('input /pet '..petws_name..' <t>')
            end
        end
    pet_delay()
    end
end

function perform_ws(ws_name)
	ws_name = string.gsub(ws_name, '[ \t]+%f[\r\n%z]', '')
  if tpdelay == 0 then
  	windower.send_command('input /ws '..ws_name..' <t>')
    ws_delay()
  end
end

function perform_spell(magic_burst)
    local nuke = nukes.get_nuke(magic_burst)

    if autonuke == 1 then
        windower.send_command('' .. nukeswap .. '')
    end

    if nuke ~= nil then
        if res.spells:with('en', nuke) then
            local nukedelay = (res.spells:with('en', nuke).cast_time * (1 - fastcast)) + 3.275
            if autonuke == 1 and nuking == 0 and wsdelay == 0 then
                windower.send_command('input /ma \"' .. nuke .. '\" <t>;wait ' .. nukedelay .. ';input //sc nuking')
                nuking = 1
            end
        elseif res.job_abilities:with('en', nuke) then
            local nukedelay = 1
            if autonuke == 1 and nuking == 0 and wsdelay == 0 then
                windower.send_command('input /ja \"' .. nuke .. '\" <t>;wait ' .. nukedelay .. ';input //sc nuking')
                nuking = 1
            end
        end
    end
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

function front()

  local pi = math.pi
  local atan = math.atan

  local me = windower.ffxi.get_mob_by_target('me')
  local mob = windower.ffxi.get_mob_by_target('st') or windower.ffxi.get_mob_by_target('t')

  if mob ~= nil then
      if mob.hpp < 100 then
          local mydir = me.facing
          if mydir < 0 then
              mydir = -mydir
          else
              mydir = 2*pi-mydir
          end

          local mobdir = mob.facing
          if mobdir < 0 then
              mobdir = -mobdir
          else
              mobdir = 2*pi-mobdir
          end

          if mydir > mobdir then
            swing = left
          elseif mydir < mobdir then
            swing = right
          end

          ddir = mydir - mobdir

          if ddir < pi-0.3 then
            swing = "Right"
          elseif ddir > pi+0.3 then
            swing = "Left"
          else
            swing = "Steady"
          end

          if swing == "Right" then
            windower.send_command('setkey numpad6 down')
            windower.send_command('setkey numpad4 up')
          elseif swing == "Left" then
            windower.send_command('setkey numpad4 down')
            windower.send_command('setkey numpad6 up')
          elseif swing == "Steady" then
            windower.send_command('setkey numpad4 up')
            windower.send_command('setkey numpad6 up')
          end
      end
  end

end

function behind()

  local pi = math.pi
  local atan = math.atan

  local me = windower.ffxi.get_mob_by_target('me')
  local mob = windower.ffxi.get_mob_by_target('st') or windower.ffxi.get_mob_by_target('t')

  if mob ~= nil then
      if mob.hpp < 100 then
          local mydir = me.facing
          if mydir < 0 then
              mydir = -mydir
          else
              mydir = 2*pi-mydir
          end

          local mobdir = mob.facing
          if mobdir < 0 then
              mobdir = -mobdir
          else
              mobdir = 2*pi-mobdir
          end

          if mydir > mobdir then
            swing = left
          elseif mydir < mobdir then
            swing = right
          end

          ddir = mydir - mobdir
          if ddir < -0.3 then
            swing = "Right"
          elseif ddir > 0.3 then
            swing = "Left"
          else
            swing = "Steady"
          end

          if swing == "Right" then
            windower.send_command('setkey numpad6 down')
            windower.send_command('setkey numpad4 up')
          elseif swing == "Left" then
            windower.send_command('setkey numpad4 down')
            windower.send_command('setkey numpad6 up')
          elseif swing == "Steady" then
            windower.send_command('setkey numpad4 up')
            windower.send_command('setkey numpad6 up')
          end
      end
  end

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
    resonating[target] = {
        res=resource,
        id=action_id,
        active=properties,
        delay=clock+delay,
        times=clock+delay+8-step,
        step=step,
        closed=closed,
        bound=bound
    }
    if target == targ_id then
        next_frame = clock
    end
end

function action_handler(act)
    local actionpacket = ActionPacket.new(act)
    local category = actionpacket:get_category_string()

    if not categories:contains(category) or act.param == 0 then
        return
    end

    local actor = actionpacket:get_id()
    local target = actionpacket:get_targets()()
    local action = target:get_actions()()
    local message_id = action:get_message_id()
    local add_effect = action:get_add_effect()
    --local basic_info = action:get_basic_info()
    local param, resource, action_id, interruption, conclusion = action:get_spell()
    local ability = skills[resource] and skills[resource][action_id]

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
    elseif ability and (message_ids:contains(message_id) or message_id == 2 and buffs[actor] and chain_buff(buffs[actor])) then
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
    elseif cmd == 'ranged' then
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
        if spam == 0 then
            spam = 1
            auto = 0
            open = 0
            close = 0
            windower.add_to_chat(207, '%s: Spam Weaponskill Mode: On':format(_addon.name))
        else
            spam = 0
            windower.add_to_chat(207, '%s: Spam Weaponskill Mode: Off':format(_addon.name))
        end
    elseif cmd == 'cleave' then
        if cleave == 0 then
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
    elseif cmd == 'party' then
        if buddy == 0 then
            buddy = 1
            windower.add_to_chat(207, '%s: Buddy Skillchain Mode: On':format(_addon.name))
        end
        if auto == 0 then
            auto = 1
            spam = 0
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
            windower.add_to_chat(207, '%s: Light Skillchain Mode: On':format(_addon.name))
        else
            light = 0
            windower.add_to_chat(207, '%s: Light Skillchain Mode: Off':format(_addon.name))
        end
    elseif cmd == 'dark' then
        if dark == 0 then
            dark = 1
            light = 0
            windower.add_to_chat(207, '%s: Dark Skillchain Mode: On':format(_addon.name))
        else
            dark = 0
            windower.add_to_chat(207, '%s: Dark Skillchain Mode: Off':format(_addon.name))
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
        end
        if cleave == 1 then
            windower.send_command('input /echo Cleave Weaponskill Mode')
        end
        if starter == 1 then
            windower.send_command('input /echo Starter Weaponskill Mode')
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
    elseif cmd == 'reload' then
        windower.send_command('lua reload skillchains')
    elseif cmd == 'help' or cmd == '?' then
        windower.add_to_chat(207, '%s: valid commands [ status | auto | mb | am | buddy | prefer | endless | melee | ranged | autonuke | spam | cleave | starter | ignore | open | close | save | move | burst | weapon | spell | pet | props | step | timer | color | aeonic | reload ]':format(_addon.name))
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
    			  windower.add_to_chat(207, '%s: Innin Mode: Off':format(_addon.name))
        else
            innin = 1
    			  windower.add_to_chat(207, '%s: Innin Mode: On':format(_addon.name))
        end
    elseif cmd == 'yonin' then
        if yonin == 1 then
            yonin = 0
            windower.add_to_chat(207, '%s: Yonin Mode: Off':format(_addon.name))
        else
            yonin = 1
            windower.add_to_chat(207, '%s: Yonin Mode: On':format(_addon.name))
        end
    elseif cmd == 'whilecasting' then
        if w_casting == 1 then
            w_casting = 0
            windower.add_to_chat(207, '%s: While Casting Mode: Off':format(_addon.name))
        else
            w_casting = 1
            wstrigger = 1
            spam = 1
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
            auto = 0
            open = 0
            close = 0
            windower.add_to_chat(207, '%s: While Readying Mode: On':format(_addon.name))
        end
    end
end)

windower.register_event('tp change',function(new,old)

    check_sc()

end)

windower.register_event('job change', function(job, lvl)
    job = res.jobs:with('id', job).english_short
    if job ~= info.job then
        info.job = job
        config.reload(settings)
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
    coroutine.close(check_weapon)
end)

windower.register_event('logout', function()
    coroutine.close(check_weapon)
    check_weapon = nil
    info = {}
    resonating = {}
    buffs = {}
end)
