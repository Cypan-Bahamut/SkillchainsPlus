local nukes = {}
local ele = {}

local rmod = 0.85

_libs = _libs or {}
_libs.nukes = nukes

_raw = _raw or {}

-- Element Variables & Functions

Earth = 0
Water = 0
Wind = 0
Fire = 0
Ice = 0
Thunder = 0
dark = 0
light = 0

-- Dedicated burst-exclusion flags for dark/holy. The lowercase dark/light
-- globals above are shared with skillchainsplus.lua's Light/Dark Skillchain Mode
-- and must NOT be used as nuke exclusion gates.
XDark = 0
XHoly = 0

-- Force Magic Burst element (nil = disabled)
local force_mb = nil

local function normalize_ele(v)
    if not v then return nil end
    v = tostring(v):lower()
    if v == 'thunder' or v == 'thun' then return 'thunder' end
    if v == 'blizzard' or v == 'ice' or v == 'bliz' then return 'blizzard' end
    if v == 'fire' then return 'fire' end
    if v == 'aero' or v == 'wind' then return 'aero' end
    if v == 'water' then return 'water' end
    if v == 'stone' or v == 'earth' then return 'stone' end
    if v == 'dark' or v == 'darkness' then return 'dark' end
    if v == 'holy' or v == 'light' then return 'holy' end
    return nil
end

function nukes.set_force_mb(v)
    force_mb = normalize_ele(v)
end

function nukes.get_force_mb()
    return force_mb
end


function nukes.set_recastmod(v)
    rmod = tonumber(v) or rmod
end

function ele.earth()

  if Earth == 0 then
    Earth = 1
    windower.add_to_chat(207, '%s: Disabled Earth Spells':format(_addon.name))
  else
    Earth = 0
    windower.add_to_chat(207, '%s: Enabled Earth Spells':format(_addon.name))
  end

end

function ele.water()

  if Water == 0 then
    Water = 1
    windower.add_to_chat(207, '%s: Disabled Water Spells':format(_addon.name))
  else
    Water = 0
    windower.add_to_chat(207, '%s: Enabled Water Spells':format(_addon.name))
  end

end

function ele.wind()

  if Wind == 0 then
    Wind = 1
    windower.add_to_chat(207, '%s: Disabled Wind Spells':format(_addon.name))
  else
    Wind = 0
    windower.add_to_chat(207, '%s: Enabled Wind Spells':format(_addon.name))
  end

end

function ele.fire()

  if Fire == 0 then
    Fire = 1
    windower.add_to_chat(207, '%s: Disabled Fire Spells':format(_addon.name))
  else
    Fire = 0
    windower.add_to_chat(207, '%s: Enabled Fire Spells':format(_addon.name))
  end

end

function ele.ice()

  if Ice == 0 then
    Ice = 1
    windower.add_to_chat(207, '%s: Disabled Ice Spells':format(_addon.name))
  else
    Ice = 0
    windower.add_to_chat(207, '%s: Enabled Ice Spells':format(_addon.name))
  end

end

function ele.thunder()

  if Thunder == 0 then
    Thunder = 1
    windower.add_to_chat(207, '%s: Disabled Thunder Spells':format(_addon.name))
  else
    Thunder = 0
    windower.add_to_chat(207, '%s: Enabled Thunder Spells':format(_addon.name))
  end

end

function ele.dark()

  if XDark == 0 then
    XDark = 1
    windower.add_to_chat(207, '%s: Disabled Dark Spells':format(_addon.name))
  else
    XDark = 0
    windower.add_to_chat(207, '%s: Enabled Dark Spells':format(_addon.name))
  end

end

function ele.light()

  if XHoly == 0 then
    XHoly = 1
    windower.add_to_chat(207, '%s: Disabled Light/Holy Spells':format(_addon.name))
  else
    XHoly = 0
    windower.add_to_chat(207, '%s: Enabled Light/Holy Spells':format(_addon.name))
  end

end

-- Reset all burst element control to defaults: no forced element, no exclusions.
function nukes.reset()
    force_mb = nil
    Earth, Water, Wind, Fire, Ice, Thunder = 0, 0, 0, 0, 0, 0
    XDark, XHoly = 0, 0
end

-- Query the exclusion state for a normalized element (accepts synonyms via
-- normalize_ele). Used by skillchainsplus.lua so nukespam and the NIN wheel honor
-- the same no<ele> exclusions as burst selection.
function nukes.is_excluded(v)
    local e = normalize_ele(v)
    if e == 'thunder' then return Thunder == 1 end
    if e == 'blizzard' then return Ice == 1 end
    if e == 'fire' then return Fire == 1 end
    if e == 'aero' then return Wind == 1 end
    if e == 'water' then return Water == 1 end
    if e == 'stone' then return Earth == 1 end
    if e == 'dark' then return XDark == 1 end
    if e == 'holy' then return XHoly == 1 end
    return false
end



-- Nuke Functions

function nukes.dark()

  if XDark == 1 then return nil end

  if (nukes.blm() and (windower.ffxi.get_spell_recasts()[219] * rmod) < 1) then
   return "Comet"
  elseif (nukes.blm() and (windower.ffxi.get_spell_recasts()[881] * rmod) < 1) then
   return "Aspir III"
  elseif nukes.blm() or nukes.sch() or nukes.geo() or nukes.rdm() or nukes.whm() or nukes.drk() then
    if ((windower.ffxi.get_spell_recasts()[248] * rmod) < 1) then
       return "Aspir II"
    elseif ((windower.ffxi.get_spell_recasts()[247] * rmod) < 1) then
       return "Aspir"
    else
       return nil
    end
  end

  if nukes.nin() then
    return nil
  end

end


function nukes.holy()

  if XHoly == 1 then return nil end

  if nukes.whm() then
   if (windower.ffxi.get_spell_recasts()[22] * rmod) < 1 then
    return "Holy II"
   elseif nukes.blm() or nukes.sch() or nukes.geo() or nukes.rdm() or nukes.whm() then
    if ((windower.ffxi.get_spell_recasts()[21] * rmod) < 1) then
       return "Holy"
    else
       return nil
    end
   end
  end

  if nukes.nin() then
    return nil
  end

end


function nukes.thunder()

  if Thunder == 1 then return nil end

  if (nukes.blm() and (windower.ffxi.get_spell_recasts()[853] * rmod) < 1) then
   return "Thunder VI"
  elseif nukes.blm() or nukes.sch() or nukes.geo() or nukes.rdm() then
    if ((windower.ffxi.get_spell_recasts()[168] * rmod) < 1) then
       return "Thunder V"
    elseif ((windower.ffxi.get_spell_recasts()[167] * rmod) < 1) then
       return "Thunder IV"
    end
  end

  if nukes.blm() or nukes.sch() or nukes.geo() or nukes.rdm() or nukes.drk() then
    if ((windower.ffxi.get_spell_recasts()[166] * rmod) < 1) then
       return "Thunder III"
    elseif ((windower.ffxi.get_spell_recasts()[165] * rmod) < 1) then
       return "Thunder II"
    else
       return nil
    end
  end

  if nukes.nin() then
    if nukes.futae() then
      if ((windower.ffxi.get_spell_recasts()[334] * rmod) < 1) then
        return "Raiton: San"
      elseif ((windower.ffxi.get_spell_recasts()[333] * rmod) < 1) then
        return "Raiton: Ni"
      elseif ((windower.ffxi.get_spell_recasts()[332] * rmod) < 1) then
        return "Raiton: Ichi"
      else
         return nil
      end
    else
      if ((windower.ffxi.get_spell_recasts()[333] * rmod) < 1) then
        return "Raiton: Ni"
      elseif ((windower.ffxi.get_spell_recasts()[334] * rmod) < 1) then
        return "Raiton: San"
      elseif ((windower.ffxi.get_spell_recasts()[332] * rmod) < 1) then
        return "Raiton: Ichi"
      else
         return nil
      end
    end
  end

end


function nukes.blizzard()

  if Ice == 1 then return nil end

  if (nukes.blm() and (windower.ffxi.get_spell_recasts()[850] * rmod) < 1) then
	 return "Blizzard VI"
  elseif nukes.blm() or nukes.sch() or nukes.geo() or nukes.rdm() then
    if ((windower.ffxi.get_spell_recasts()[153] * rmod) < 1) then
       return "Blizzard V"
    elseif ((windower.ffxi.get_spell_recasts()[152] * rmod) < 1) then
       return "Blizzard IV"
    end
  end

  if nukes.blm() or nukes.sch() or nukes.geo() or nukes.rdm() or nukes.drk() then
    if ((windower.ffxi.get_spell_recasts()[151] * rmod) < 1) then
       return "Blizzard III"
    elseif ((windower.ffxi.get_spell_recasts()[150] * rmod) < 1) then
       return "Blizzard II"
    else
       return nil
    end
  end

  if nukes.nin() then
    if nukes.futae() then
      if ((windower.ffxi.get_spell_recasts()[325] * rmod) < 1) then
        return "Hyoton: San"
      elseif ((windower.ffxi.get_spell_recasts()[324] * rmod) < 1) then
        return "Hyoton: Ni"
      elseif ((windower.ffxi.get_spell_recasts()[323] * rmod) < 1) then
        return "Hyoton: Ichi"
      else
         return nil
      end
    else
      if ((windower.ffxi.get_spell_recasts()[324] * rmod) < 1) then
        return "Hyoton: Ni"
      elseif ((windower.ffxi.get_spell_recasts()[325] * rmod) < 1) then
        return "Hyoton: San"
      elseif ((windower.ffxi.get_spell_recasts()[323] * rmod) < 1) then
        return "Hyoton: Ichi"
      else
         return nil
      end
    end
  end

end


function nukes.fire()

  if Fire == 1 then return nil end

  if (nukes.blm() and (windower.ffxi.get_spell_recasts()[849] * rmod) < 1) then
	 return "Fire VI"
  elseif nukes.blm() or nukes.sch() or nukes.geo() or nukes.rdm() then
    if ((windower.ffxi.get_spell_recasts()[148] * rmod) < 1) then
       return "Fire V"
    elseif ((windower.ffxi.get_spell_recasts()[147] * rmod) < 1) then
       return "Fire IV"
    end
  end

  if nukes.blm() or nukes.sch() or nukes.geo() or nukes.rdm() or nukes.drk() then
    if ((windower.ffxi.get_spell_recasts()[146] * rmod) < 1) then
       return "Fire III"
    elseif ((windower.ffxi.get_spell_recasts()[145] * rmod) < 1) then
       return "Fire II"
    else
       return nil
    end
  end

  if nukes.nin() then
    if nukes.futae() then
      if ((windower.ffxi.get_spell_recasts()[322] * rmod) < 1) then
        return "Katon: San"
      elseif ((windower.ffxi.get_spell_recasts()[321] * rmod) < 1) then
        return "Katon: Ni"
      elseif ((windower.ffxi.get_spell_recasts()[320] * rmod) < 1) then
        return "Katon: Ichi"
      else
         return nil
      end
    else
      if ((windower.ffxi.get_spell_recasts()[321] * rmod) < 1) then
        return "Katon: Ni"
      elseif ((windower.ffxi.get_spell_recasts()[322] * rmod) < 1) then
        return "Katon: San"
      elseif ((windower.ffxi.get_spell_recasts()[320] * rmod) < 1) then
        return "Katon: Ichi"
      else
         return nil
      end
    end
  end

end


function nukes.aero()

  if Wind == 1 then return nil end

  if (nukes.blm() and (windower.ffxi.get_spell_recasts()[851] * rmod) < 1) then
     return "Aero VI"
  elseif nukes.blm() or nukes.sch() or nukes.geo() or nukes.rdm() then
    if ((windower.ffxi.get_spell_recasts()[158] * rmod) < 1) then
       return "Aero V"
    elseif ((windower.ffxi.get_spell_recasts()[157] * rmod) < 1) then
       return "Aero IV"
    end
  end

  if nukes.blm() or nukes.sch() or nukes.geo() or nukes.rdm() or nukes.drk() then
    if ((windower.ffxi.get_spell_recasts()[156] * rmod) < 1) then
       return "Aero III"
    elseif ((windower.ffxi.get_spell_recasts()[155] * rmod) < 1) then
       return "Aero II"
    else
       return nil
    end
  end

  if nukes.nin() then
    if nukes.futae() then
      if ((windower.ffxi.get_spell_recasts()[328] * rmod) < 1) then
        return "Huton: San"
      elseif ((windower.ffxi.get_spell_recasts()[327] * rmod) < 1) then
        return "Huton: Ni"
      elseif ((windower.ffxi.get_spell_recasts()[326] * rmod) < 1) then
        return "Huton: Ichi"
      else
         return nil
      end
    else
      if ((windower.ffxi.get_spell_recasts()[327] * rmod) < 1) then
        return "Huton: Ni"
      elseif ((windower.ffxi.get_spell_recasts()[328] * rmod) < 1) then
        return "Huton: San"
      elseif ((windower.ffxi.get_spell_recasts()[326] * rmod) < 1) then
        return "Huton: Ichi"
      else
         return nil
      end
    end
  end

end


function nukes.water()

  if Water == 1 then return nil end

  if (nukes.blm() and (windower.ffxi.get_spell_recasts()[854] * rmod) < 1) then
	 return "Water VI"
  elseif nukes.blm() or nukes.sch() or nukes.geo() or nukes.rdm() then
    if ((windower.ffxi.get_spell_recasts()[173] * rmod) < 1) then
       return "Water V"
    elseif ((windower.ffxi.get_spell_recasts()[172] * rmod) < 1) then
       return "Water IV"
    end
  end

  if nukes.blm() or nukes.sch() or nukes.geo() or nukes.rdm() or nukes.drk() then
    if ((windower.ffxi.get_spell_recasts()[171] * rmod) < 1) then
       return "Water III"
    elseif ((windower.ffxi.get_spell_recasts()[170] * rmod) < 1) then
  	 return "Water II"
    else
     return nil
    end
  end

  if nukes.nin() then
    if nukes.futae() then
      if ((windower.ffxi.get_spell_recasts()[337] * rmod) < 1) then
        return "Suiton: San"
      elseif ((windower.ffxi.get_spell_recasts()[336] * rmod) < 1) then
        return "Suiton: Ni"
      elseif ((windower.ffxi.get_spell_recasts()[335] * rmod) < 1) then
        return "Suiton: Ichi"
      else
         return nil
      end
    else
      if ((windower.ffxi.get_spell_recasts()[336] * rmod) < 1) then
        return "Suiton: Ni"
      elseif ((windower.ffxi.get_spell_recasts()[337] * rmod) < 1) then
        return "Suiton: San"
      elseif ((windower.ffxi.get_spell_recasts()[335] * rmod) < 1) then
        return "Suiton: Ichi"
      else
         return nil
      end
    end
  end

end


function nukes.stone()

  if Earth == 1 then return nil end

  if (nukes.blm() and (windower.ffxi.get_spell_recasts()[852] * rmod) < 1) then
	 return "Stone VI"
  elseif nukes.blm() or nukes.sch() or nukes.geo() or nukes.rdm() then
    if ((windower.ffxi.get_spell_recasts()[163] * rmod) < 1) then
  	 return "Stone V"
    elseif ((windower.ffxi.get_spell_recasts()[162] * rmod) < 1) then
  	 return "Stone IV"
    end
  end

  if nukes.blm() or nukes.sch() or nukes.geo() or nukes.rdm() or nukes.drk() then
    if ((windower.ffxi.get_spell_recasts()[161] * rmod) < 1) then
  	 return "Stone III"
    elseif ((windower.ffxi.get_spell_recasts()[160] * rmod) < 1) then
  	 return "Stone II"
    else
     return nil
    end
  end

  if nukes.nin() then
    if nukes.futae() then
      if ((windower.ffxi.get_spell_recasts()[331] * rmod) < 1) then
        return "Doton: San"
      elseif ((windower.ffxi.get_spell_recasts()[330] * rmod) < 1) then
        return "Doton: Ni"
      elseif ((windower.ffxi.get_spell_recasts()[329] * rmod) < 1) then
        return "Doton: Ichi"
      else
         return nil
      end
    else
      if ((windower.ffxi.get_spell_recasts()[330] * rmod) < 1) then
        return "Doton: Ni"
      elseif ((windower.ffxi.get_spell_recasts()[331] * rmod) < 1) then
        return "Doton: San"
      elseif ((windower.ffxi.get_spell_recasts()[329] * rmod) < 1) then
        return "Doton: Ichi"
      else
         return nil
      end
    end
  end

end


function nukes.ongo()

  if force_mb and force_mb ~= 'stone' then return nil end
  if Earth == 1 then return nil end

  if nukes.blm() then
    if ((windower.ffxi.get_spell_recasts()[852] * rmod) < 1) then
     return "Stone VI"
    elseif ((windower.ffxi.get_spell_recasts()[499] * rmod) < 1) then
     return "Stoneja"
    elseif ((windower.ffxi.get_spell_recasts()[163] * rmod) < 1) then
  	 return "Stone V"
    elseif ((windower.ffxi.get_spell_recasts()[162] * rmod) < 1) then
  	 return "Stone IV"
    elseif ((windower.ffxi.get_spell_recasts()[191] * rmod) < 1) then
     return "Stonega III"
   elseif ((windower.ffxi.get_spell_recasts()[211] * rmod) < 1) then
     return "Quake II"
    elseif ((windower.ffxi.get_spell_recasts()[161] * rmod) < 1) then
  	 return "Stone III"
    elseif ((windower.ffxi.get_spell_recasts()[190] * rmod) < 1) then
      return "Stonega II"
    elseif ((windower.ffxi.get_spell_recasts()[210] * rmod) < 1) then
     return "Quake"
    elseif ((windower.ffxi.get_spell_recasts()[160] * rmod) < 1) then
  	 return "Stone II"
    else
     return nil
    end
  end

  if nukes.nin() then
    if nukes.futae() then
      if ((windower.ffxi.get_spell_recasts()[331] * rmod) < 1) then
        return "Doton: San"
      elseif ((windower.ffxi.get_spell_recasts()[330] * rmod) < 1) then
        return "Doton: Ni"
      elseif ((windower.ffxi.get_spell_recasts()[329] * rmod) < 1) then
        return "Doton: Ichi"
      else
         return nil
      end
    else
      if ((windower.ffxi.get_spell_recasts()[330] * rmod) < 1) then
        return "Doton: Ni"
      elseif ((windower.ffxi.get_spell_recasts()[331] * rmod) < 1) then
        return "Doton: San"
      elseif ((windower.ffxi.get_spell_recasts()[329] * rmod) < 1) then
        return "Doton: Ichi"
      else
         return nil
      end
    end
  end

end


function nukes.fusion()

  if force_mb then
    if force_mb == 'fire' then return nukes.fire() end
    if force_mb == 'holy' then return nukes.holy() end
    return nil
  end

  if Fire == 1 then return nil end

  if (nukes.blm() and (windower.ffxi.get_spell_recasts()[849] * rmod) < 1) then
	 return "Fire VI"
  elseif nukes.blm() or nukes.sch() or nukes.geo() or nukes.rdm() then
    if ((windower.ffxi.get_spell_recasts()[148] * rmod) < 1) then
  	 return "Fire V"
    elseif ((windower.ffxi.get_spell_recasts()[147] * rmod) < 1) then
  	 return "Fire IV"
    end
  end

  if nukes.blm() or nukes.sch() or nukes.geo() or nukes.rdm() or nukes.drk() then
    if ((windower.ffxi.get_spell_recasts()[146] * rmod) < 1) then
  	 return "Fire III"
    elseif ((windower.ffxi.get_spell_recasts()[145] * rmod) < 1) then
  	 return "Fire II"
    else
     return nil
    end
  end

  if nukes.nin() then
    if nukes.futae() then
      if ((windower.ffxi.get_spell_recasts()[322] * rmod) < 1) then
        return "Katon: San"
      elseif ((windower.ffxi.get_spell_recasts()[321] * rmod) < 1) then
        return "Katon: Ni"
      elseif ((windower.ffxi.get_spell_recasts()[320] * rmod) < 1) then
        return "Katon: Ichi"
      else
         return nil
      end
    else
      if ((windower.ffxi.get_spell_recasts()[321] * rmod) < 1) then
        return "Katon: Ni"
      elseif ((windower.ffxi.get_spell_recasts()[322] * rmod) < 1) then
        return "Katon: San"
      elseif ((windower.ffxi.get_spell_recasts()[320] * rmod) < 1) then
        return "Katon: Ichi"
      else
         return nil
      end
    end
  end

end


function nukes.disto()

  if force_mb then
    if force_mb == 'blizzard' then return nukes.blizzard() end
    if force_mb == 'water' then return nukes.water() end
    return nil
  end

  if (nukes.blm() and (windower.ffxi.get_spell_recasts()[850] * rmod) < 1) and Ice == 0 then
	 return "Blizzard VI"
  elseif (nukes.blm() and (windower.ffxi.get_spell_recasts()[854] * rmod) < 1) and Water == 0 then
    return "Water VI"
  elseif nukes.blm() or nukes.sch() or nukes.geo() or nukes.rdm() then
    if ((windower.ffxi.get_spell_recasts()[153] * rmod) < 1) and Ice == 0 then
       return "Blizzard V"
    elseif ((windower.ffxi.get_spell_recasts()[173] * rmod) < 1) and Water == 0 then
       return "Water V"
    elseif ((windower.ffxi.get_spell_recasts()[152] * rmod) < 1) and Ice == 0 then
       return "Blizzard IV"
    elseif ((windower.ffxi.get_spell_recasts()[172] * rmod) < 1) and Water == 0 then
       return "Water IV"
    end
  end

  if nukes.blm() or nukes.sch() or nukes.geo() or nukes.rdm() or nukes.drk() then
    if ((windower.ffxi.get_spell_recasts()[151] * rmod) < 1) and Ice == 0 then
       return "Blizzard III"
    elseif ((windower.ffxi.get_spell_recasts()[171] * rmod) < 1) and Water == 0 then
       return "Water III"
    elseif ((windower.ffxi.get_spell_recasts()[150] * rmod) < 1) and Ice == 0 then
       return "Blizzard II"
    elseif ((windower.ffxi.get_spell_recasts()[170] * rmod) < 1) and Water == 0 then
       return "Water II"
    else
       return nil
    end
  end

  if nukes.nin() then
    if ((windower.ffxi.get_spell_recasts()[325] * rmod) < 1) and Ice == 0 then
      return "Hyoton: San"
    elseif ((windower.ffxi.get_spell_recasts()[337] * rmod) < 1) and Water == 0 then
      return "Suiton: San"
    elseif ((windower.ffxi.get_spell_recasts()[324] * rmod) < 1) and Ice == 0 then
      return "Hyoton: Ni"
    elseif ((windower.ffxi.get_spell_recasts()[336] * rmod) < 1) and Water == 0 then
      return "Suiton: Ni"
    elseif ((windower.ffxi.get_spell_recasts()[323] * rmod) < 1) and Ice == 0 then
      return "Hyoton: Ichi"
    elseif ((windower.ffxi.get_spell_recasts()[335] * rmod) < 1) and Water == 0 then
      return "Suiton: Ichi"
    else
       return nil
    end
  end

    if nukes.smn() then
        if (windower.ffxi.get_ability_recasts()[173] < 1) and Ice == 0 then
            return "Heavenly Strike"
        else
            return nil
        end
    end

end


function nukes.grav()
  if force_mb then
    if force_mb == 'dark' then return nukes.dark() end
    if force_mb == 'stone' then return nukes.stone() end
    return nil
  end


  if (nukes.blm() and (windower.ffxi.get_spell_recasts()[219] * rmod) < 1) and XDark == 0 then
    return "Comet"
  elseif (nukes.blm() and (windower.ffxi.get_spell_recasts()[852] * rmod) < 1) and Earth == 0 then
	  return "Stone VI"
  elseif nukes.drk() and ((windower.ffxi.get_spell_recasts()[880] * rmod) < 1 and windower.ffxi.get_player().vitals.hp < 4000) and XDark == 0 then
    return "Drain III"
  elseif nukes.blm() or nukes.sch() or nukes.geo() or nukes.rdm() then
    if ((windower.ffxi.get_spell_recasts()[163] * rmod) < 1) and Earth == 0 then
       return "Stone V"
    elseif ((windower.ffxi.get_spell_recasts()[162] * rmod) < 1) and Earth == 0 then
       return "Stone IV"
    end
  end

  if nukes.blm() or nukes.sch() or nukes.geo() or nukes.rdm() or nukes.drk() then
    if ((windower.ffxi.get_spell_recasts()[161] * rmod) < 1) and Earth == 0 then
       return "Stone III"
    elseif ((windower.ffxi.get_spell_recasts()[160] * rmod) < 1) and Earth == 0 then
       return "Stone II"
    else
       return nil
    end
  end

  if nukes.nin() then
    if nukes.futae() then
      if ((windower.ffxi.get_spell_recasts()[331] * rmod) < 1) and Earth == 0 then
        return "Doton: San"
      elseif ((windower.ffxi.get_spell_recasts()[330] * rmod) < 1) and Earth == 0 then
        return "Doton: Ni"
      elseif ((windower.ffxi.get_spell_recasts()[329] * rmod) < 1) and Earth == 0 then
        return "Doton: Ichi"
      else
        return nil
      end
    else
      if ((windower.ffxi.get_spell_recasts()[330] * rmod) < 1) and Earth == 0 then
        return "Doton: Ni"
      elseif ((windower.ffxi.get_spell_recasts()[331] * rmod) < 1) and Earth == 0 then
        return "Doton: San"
      elseif ((windower.ffxi.get_spell_recasts()[329] * rmod) < 1) and Earth == 0 then
        return "Doton: Ichi"
      else
        return nil
      end
    end
  end

end


function nukes.frag()

  if force_mb then
    if force_mb == 'thunder' then return nukes.thunder() end
    if force_mb == 'aero' then return nukes.aero() end
    return nil
  end

  if (nukes.blm() and (windower.ffxi.get_spell_recasts()[853] * rmod) < 1) and Thunder == 0 then
	 return "Thunder VI"
  elseif (nukes.blm() and (windower.ffxi.get_spell_recasts()[851] * rmod) < 1) and Wind == 0 then
     return "Aero VI"
  elseif nukes.blm() or nukes.sch() or nukes.geo() or nukes.rdm() then
    if ((windower.ffxi.get_spell_recasts()[168] * rmod) < 1) and Thunder == 0 then
       return "Thunder V"
    elseif ((windower.ffxi.get_spell_recasts()[158] * rmod) < 1) and Wind == 0 then
       return "Aero V"
    elseif ((windower.ffxi.get_spell_recasts()[167] * rmod) < 1) and Thunder == 0 then
       return "Thunder IV"
    elseif ((windower.ffxi.get_spell_recasts()[157] * rmod) < 1) and Wind == 0 then
       return "Aero IV"
    end
  end

  if nukes.blm() or nukes.sch() or nukes.geo() or nukes.rdm() or nukes.drk() then
    if ((windower.ffxi.get_spell_recasts()[166] * rmod) < 1) and Thunder == 0 then
      return "Thunder III"
    elseif ((windower.ffxi.get_spell_recasts()[156] * rmod) < 1) and Wind == 0 then
      return "Aero III"
    elseif ((windower.ffxi.get_spell_recasts()[165] * rmod) < 1) and Thunder == 0 then
      return "Thunder II"
    elseif ((windower.ffxi.get_spell_recasts()[155] * rmod) < 1) and Wind == 0 then
      return "Aero II"
    else
       return nil
    end
  elseif nukes.smn() then
      if (windower.ffxi.get_ability_recasts()[173] < 1) and Thunder == 0 then
          return "Thunderstorm"
      else
          return nil
      end
  end

  if nukes.nin() then
    if ((windower.ffxi.get_spell_recasts()[334] * rmod) < 1) and Thunder == 0 then
      return "Raiton: San"
    elseif ((windower.ffxi.get_spell_recasts()[328] * rmod) < 1) and Wind == 0 then
      return "Huton: San"
    elseif ((windower.ffxi.get_spell_recasts()[333] * rmod) < 1) and Thunder == 0 then
      return "Raiton: Ni"
    elseif ((windower.ffxi.get_spell_recasts()[327] * rmod) < 1) and Wind == 0 then
      return "Huton: Ni"
    elseif ((windower.ffxi.get_spell_recasts()[332] * rmod) < 1) and Thunder == 0 then
      return "Raiton: Ichi"
    elseif ((windower.ffxi.get_spell_recasts()[326] * rmod) < 1) and Wind == 0 then
      return "Huton: Ichi"
    else
       return nil
    end
  end

end


function nukes.light()
  if force_mb then
    if force_mb == 'thunder' then return nukes.thunder() end
    if force_mb == 'fire' then return nukes.fire() end
    if force_mb == 'aero' then return nukes.aero() end
    if force_mb == 'holy' then return nukes.holy() end
    return nil
  end


  if (nukes.blm() and (windower.ffxi.get_spell_recasts()[853] * rmod) < 1) and Thunder == 0 then
  	 return "Thunder VI"
  elseif (nukes.blm() and (windower.ffxi.get_spell_recasts()[849] * rmod) < 1) and Fire == 0 then
     return "Fire VI"
  elseif (nukes.blm() and (windower.ffxi.get_spell_recasts()[851] * rmod) < 1) and Wind == 0 then
     return "Aero VI"
  elseif nukes.blm() or nukes.sch() or nukes.geo() or nukes.rdm() then
    if ((windower.ffxi.get_spell_recasts()[168] * rmod) < 1) and Thunder == 0 then
       return "Thunder V"
    elseif ((windower.ffxi.get_spell_recasts()[148] * rmod) < 1) and Fire == 0 then
       return "Fire V"
    elseif ((windower.ffxi.get_spell_recasts()[158] * rmod) < 1) and Wind == 0 then
       return "Aero V"
    elseif ((windower.ffxi.get_spell_recasts()[167] * rmod) < 1) and Thunder == 0 then
       return "Thunder IV"
    elseif ((windower.ffxi.get_spell_recasts()[147] * rmod) < 1) and Fire == 0 then
       return "Fire IV"
    elseif ((windower.ffxi.get_spell_recasts()[157] * rmod) < 1) and Wind == 0 then
       return "Aero IV"
    end
  end

  if nukes.blm() or nukes.sch() or nukes.geo() or nukes.rdm() or nukes.drk() then
    if ((windower.ffxi.get_spell_recasts()[166] * rmod) < 1) and Thunder == 0 then
       return "Thunder III"
    elseif ((windower.ffxi.get_spell_recasts()[146] * rmod) < 1) and Fire == 0 then
       return "Fire III"
    elseif ((windower.ffxi.get_spell_recasts()[156] * rmod) < 1) and Wind == 0 then
       return "Aero III"
    elseif ((windower.ffxi.get_spell_recasts()[165] * rmod) < 1) and Thunder == 0 then
       return "Thunder II"
    elseif ((windower.ffxi.get_spell_recasts()[145] * rmod) < 1) and Fire == 0 then
       return "Fire II"
    elseif ((windower.ffxi.get_spell_recasts()[155] * rmod) < 1) and Wind == 0 then
       return "Aero II"
    else
       return nil
    end
  elseif nukes.whm() then
      if ((windower.ffxi.get_spell_recasts()[23] * rmod) < 1) and XHoly == 0 then
          return "Holy II"
      elseif ((windower.ffxi.get_spell_recasts()[22] * rmod) < 1) and XHoly == 0 then
          return "Holy"
      else
          return nil
      end
  elseif nukes.smn() then
      if (windower.ffxi.get_ability_recasts()[173] < 1) and Fire == 0 then
          return "Meteor Strike"
      else
          return nil
      end
  end

  if nukes.nin() then
    if ((windower.ffxi.get_spell_recasts()[334] * rmod) < 1) and Thunder == 0 then
      return "Raiton: San"
    elseif ((windower.ffxi.get_spell_recasts()[322] * rmod) < 1) and Fire == 0 then
      return "Katon: San"
    elseif ((windower.ffxi.get_spell_recasts()[328] * rmod) < 1) and Wind == 0 then
      return "Huton: San"
    elseif ((windower.ffxi.get_spell_recasts()[333] * rmod) < 1) and Thunder == 0 then
      return "Raiton: Ni"
    elseif ((windower.ffxi.get_spell_recasts()[321] * rmod) < 1) and Fire == 0 then
      return "Katon: Ni"
    elseif ((windower.ffxi.get_spell_recasts()[327] * rmod) < 1) and Wind == 0 then
      return "Huton: Ni"
    elseif ((windower.ffxi.get_spell_recasts()[332] * rmod) < 1) and Thunder == 0 then
      return "Raiton: Ichi"
    elseif ((windower.ffxi.get_spell_recasts()[320] * rmod) < 1) and Fire == 0 then
      return "Katon: Ichi"
    elseif ((windower.ffxi.get_spell_recasts()[326] * rmod) < 1) and Wind == 0 then
      return "Huton: Ichi"
    else
       return nil
    end
  end

end


function nukes.darkness()
  if force_mb then
    if force_mb == 'blizzard' then return nukes.blizzard() end
    if force_mb == 'water' then return nukes.water() end
    if force_mb == 'stone' then return nukes.stone() end
    if force_mb == 'dark' then return nukes.dark() end
    return nil
  end


  if (nukes.blm() and (windower.ffxi.get_spell_recasts()[850] * rmod) < 1) and Ice == 0 then
     return "Blizzard VI"
  elseif (nukes.blm() and (windower.ffxi.get_spell_recasts()[854] * rmod) < 1) and Water == 0 then
     return "Water VI"
  elseif (nukes.blm() and (windower.ffxi.get_spell_recasts()[852] * rmod) < 1) and Earth == 0 then
     return "Stone VI"
  elseif (nukes.blm() and (windower.ffxi.get_spell_recasts()[219] * rmod) < 1) and XDark == 0 then
     return "Comet"
  elseif nukes.drk() and ((windower.ffxi.get_spell_recasts()[880] * rmod) < 1 and windower.ffxi.get_player().vitals.hp < 4000) and XDark == 0 then
      return "Drain III"
  elseif nukes.blm() or nukes.sch() or nukes.geo() or nukes.rdm() then
    if ((windower.ffxi.get_spell_recasts()[153] * rmod) < 1) and Ice == 0 then
       return "Blizzard V"
    elseif ((windower.ffxi.get_spell_recasts()[173] * rmod) < 1) and Water == 0 then
       return "Water V"
    elseif ((windower.ffxi.get_spell_recasts()[163] * rmod) < 1) and Earth == 0 then
       return "Stone V"
    elseif ((windower.ffxi.get_spell_recasts()[152] * rmod) < 1) and Ice == 0 then
       return "Blizzard IV"
    elseif ((windower.ffxi.get_spell_recasts()[172] * rmod) < 1) and Water == 0 then
       return "Water IV"
    elseif ((windower.ffxi.get_spell_recasts()[162] * rmod) < 1) and Earth == 0 then
       return "Stone IV"
    end
   end

   if nukes.blm() or nukes.sch() or nukes.geo() or nukes.rdm() or nukes.drk() then
    if ((windower.ffxi.get_spell_recasts()[151] * rmod) < 1) and Ice == 0 then
       return "Blizzard III"
    elseif ((windower.ffxi.get_spell_recasts()[171] * rmod) < 1) and Water == 0 then
       return "Water III"
    elseif ((windower.ffxi.get_spell_recasts()[161] * rmod) < 1) and Earth == 0 then
       return "Stone III"
    elseif ((windower.ffxi.get_spell_recasts()[150] * rmod) < 1) and Ice == 0 then
       return "Blizzard II"
    elseif ((windower.ffxi.get_spell_recasts()[170] * rmod) < 1) and Water == 0 then
       return "Water II"
    elseif ((windower.ffxi.get_spell_recasts()[160] * rmod) < 1) and Earth == 0 then
       return "Stone II"
    else
       return nil
    end
  end

  if nukes.nin() then
    if ((windower.ffxi.get_spell_recasts()[325] * rmod) < 1) and Ice == 0 then
      return "Hyoton: San"
    elseif ((windower.ffxi.get_spell_recasts()[337] * rmod) < 1) and Water == 0 then
      return "Suiton: San"
    elseif ((windower.ffxi.get_spell_recasts()[331] * rmod) < 1) and Earth == 0 then
      return "Doton: San"
    elseif ((windower.ffxi.get_spell_recasts()[324] * rmod) < 1) and Ice == 0 then
      return "Hyoton: Ni"
    elseif ((windower.ffxi.get_spell_recasts()[336] * rmod) < 1) and Water == 0 then
      return "Suiton: Ni"
    elseif ((windower.ffxi.get_spell_recasts()[330] * rmod) < 1) and Earth == 0 then
      return "Doton: Ni"
    elseif ((windower.ffxi.get_spell_recasts()[323] * rmod) < 1) and Ice == 0 then
      return "Hyoton: Ichi"
    elseif ((windower.ffxi.get_spell_recasts()[335] * rmod) < 1) and Water == 0 then
      return "Suiton: Ichi"
    elseif ((windower.ffxi.get_spell_recasts()[329] * rmod) < 1) and Earth == 0 then
      return "Doton: Ichi"
    else
       return nil
    end
  end

    if nukes.smn() then
        if (windower.ffxi.get_ability_recasts()[173] < 1) and Ice == 0 then
            return "Heavenly Strike"
        else
            return nil
        end
    end

end

function nukes.get_nuke(cmd)
    -- If force_mb is set, only allow matching elemental nukes (and constrain multi-element SC nukes below).
    if force_mb and type(cmd) == 'string' then
        local c = cmd:lower()
        local elemental = {
            thunder=true, blizzard=true, fire=true, aero=true, water=true, stone=true, dark=true, holy=true
        }
        if elemental[c] and c ~= force_mb then
            return nil
        end
    end

    if cmd == 'thunder' then
        return nukes.thunder()
    elseif cmd == 'blizzard' then
        return nukes.blizzard()
    elseif cmd == 'fire' then
        return nukes.fire()
    elseif cmd == 'aero' then
        return nukes.aero()
    elseif cmd == 'water' then
        return nukes.water()
    elseif cmd == 'stone' then
        return nukes.stone()
    elseif cmd == 'grav' then
        return nukes.grav()
    elseif cmd == 'disto' then
        return nukes.disto()
    elseif cmd == 'frag' then
        return nukes.frag()
    elseif cmd == 'fusion' then
        return nukes.fusion()
    elseif cmd == 'light' then
        return nukes.light()
    elseif cmd == 'darkness' then
        return nukes.darkness()
    elseif cmd == 'dark' then
        return nukes.dark()
    elseif cmd == 'holy' then
        return nukes.holy()
    elseif cmd == 'ongo' then
        return nukes.ongo()
    else
        return nil
    end
end

function nukes.blm()
	return windower.ffxi.get_player().main_job == 'BLM'
end

function nukes.sch()
  return windower.ffxi.get_player().main_job == 'SCH'
end

function nukes.geo()
  return windower.ffxi.get_player().main_job == 'GEO'
end

function nukes.rdm()
  return windower.ffxi.get_player().main_job == 'RDM'
end

function nukes.nin()
	return windower.ffxi.get_player().main_job == 'NIN'
end

function nukes.futae()
    local p = windower.ffxi.get_player()
    if not p or not p.buffs then return false end
    for _, bid in ipairs(p.buffs) do
        local b = res.buffs[bid]
        if b and b.name == 'Futae' then return true end
    end
    return false
end

function nukes.whm()
    return windower.ffxi.get_player().main_job == 'WHM'
end

function nukes.smn()
    return windower.ffxi.get_player().main_job == 'SMN'
end

function nukes.drk()
    return windower.ffxi.get_player().main_job == 'DRK'
end

windower.register_event('addon command', function(cmd, ...)

  local spell = nil

  -- Force MB element (toggle). Examples:
  --   //nukes firemb
  --   //nukes thundermb
  --   //nukes blizzardmb
  --   //nukes aeromb
  --   //nukes watermb
  --   //nukes stonemb
  --   //nukes darkmb
  --   //nukes lightmb
  -- Clear:
  --   //nukes nomb   (also accepts: mboff, mbclear)
  if cmd == 'nomb' or cmd == 'mboff' or cmd == 'mbclear' then
      force_mb = nil
      windower.add_to_chat(207, '%s: Force MB element: off':format(_addon.name))
      return
  end

  -- <ele>mb force commands are handled by skillchainsplus.lua's command handler,
  -- which calls nukes.set_force_mb(). Handling them here as well would double-
  -- toggle force_mb (both handlers receive every //sc command).

  if cmd == 'thunder' then
    spell = nukes.thunder()
  elseif cmd == 'blizzard' then
    spell = nukes.blizzard()
  elseif cmd == 'fire' then
    spell = nukes.fire()
  elseif cmd == 'aero' then
    spell = nukes.aero()
  elseif cmd == 'water' then
    spell = nukes.water()
  elseif cmd == 'stone' then
    spell = nukes.stone()
  elseif cmd == 'grav' then
    spell = nukes.grav()
  elseif cmd == 'disto' then
    spell = nukes.disto()
  elseif cmd == 'frag' then
    spell = nukes.frag()
  elseif cmd == 'fusion' then
    spell = nukes.fusion()
  elseif cmd == 'light' then
    spell = nukes.light()
  elseif cmd == 'darkness' then
    spell = nukes.darkness()
  elseif cmd == 'dark' then
    spell = nukes.dark()
  elseif cmd == 'holy' then
    spell = nukes.holy()
  end

  if cmd == 'nostone' or cmd == 'noearth' then
      ele.earth()
  elseif cmd == 'nowater' then
      ele.water()
  elseif cmd == 'nowind' or cmd == 'noaero' then
      ele.wind()
  elseif cmd == 'nofire' then
      ele.fire()
  elseif cmd == 'noice' or cmd == 'noblizzard' then
      ele.ice()
  elseif cmd == 'nothunder' then
      ele.thunder()
  elseif cmd == 'nodark' then
      ele.dark()
  elseif cmd == 'nolight' or cmd == 'noholy' then
      ele.light()
  end

  if spell then
	 windower.send_command('input /ma "'..spell..'" <t>')
  end

end)

return nukes
