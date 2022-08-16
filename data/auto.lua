function jobvar()

    if info.job == nil then
        player = windower.ffxi.get_player()
        info.job = player.main_job
        info.player = player.id
    end

-- Modify the weaponskills below to define for each job and each mode
-- Multiple weaponskills can be defined for different weapon types

-- defaultws: default weaponskill used to open new skillchains
-- tpws:      default weaponskill used if tp is over 2000
-- spamws:    defined weaponskill used repeatedly during spam
-- starterws: initial weaponskill used at the start of a fight
-- preferws:  preferred weaponskill used to close a skillchain
-- amws:      mythic weaponskill used for keeping AM3 buff up


-- DRAGOON

    if info.job == 'DRG' then
        defaultws = {'Stardiver',"Savage Blade","Retribution"}
        tpws = {}
        spamws = {'Stardiver',"Savage Blade","Retribution"}
        cleavews = {}
        starterws = {'Stardiver',"Savage Blade","Retribution"}
        preferws = {'Stardiver',"Savage Blade","Retribution"}
        amws = 'Drakesbane'
    end


-- MONK

    if info.job == 'MNK' then
        defaultws = {'Tornado Kick'}
        tpws = {'Howling Fist'}
        spamws = {}
        cleavews = {}
        starterws = {'Tornado Kick'}
        preferws = {'Tornado Kick'}
        amws = 'Ascetic\'s Fury'
    end


-- PUPPET MASTER

    if info.job == 'PUP' then
        defaultws = {'Shijin Spiral'}
        tpws = {'Howling Fist'}
        spamws = {}
        cleavews = {}
        starterws = {'Shijin Spiral'}
        preferws = {'Shijin Spiral'}
        amws = 'Stringing Pummel'
    end


-- DANCER

    if info.job == 'DNC' then
        defaultws = {'Pyrrhic Kleos'}
        tpws = {'Rudra\'s Storm'}
        spamws = {'Rudra\'s Storm'}
        cleavews = {}
        starterws = {'Shark Bite'}
        preferws = {'Rudra\'s Storm'}
        amws = 'Pyrrhic Kleos'
    end


-- RUNE FENCER

    if info.job == 'RUN' then
        defaultws = {'Dimidiation'}
        tpws = {}
        spamws = {}
        cleavews = {}
        starterws = {'Dimidiation'}
        preferws = {'Dimidiation'}
        amws = 'Dimidiation'
    end


-- THIEF

    if info.job == 'THF' then
        defaultws = {'Evisceration'}
        tpws = {}
        spamws = {'Rudra\'s Storm','Savage Blade'}
        cleavews = {}
        starterws = {'Evisceration'}
        preferws = {'Evisceration'}
        amws = 'Mandalic Stab'
    end


-- DARK KNIGHT

    if info.job == 'DRK' then
        defaultws = {'Torcleaver','Catastrophe','Cross Reaper'}
        tpws = {}
        spamws = {'Torcleaver','Catastrophe','Cross Reaper'}
        cleavews = {}
        starterws = {'Torcleaver','Catastrophe','Cross Reaper'}
        preferws = {'Torcleaver','Catastrophe','Cross Reaper'}
        amws = 'Insurgency'
    end


-- BLACK MAGE

    if info.job == 'BLM' then
        defaultws = {'Vidohunir'}
        tpws = {'Full Swing'}
        spamws = {'Vidohunir'}
        cleavews = {}
        starterws = {'Vidohunir'}
        preferws = {'Vidohunir'}
        amws = 'Vidohunir'
    end


-- CORSAIR

    if info.job == 'COR' then
        defaultws = {'Leaden Salute'}
        tpws = {}
        spamws = {}
        cleavews = {}
        starterws = {'Leaden Salute'}
        preferws = {'Leaden Salute'}
        amws = 'Leaden Salute'
    end


-- SAMURAI

    if info.job == 'SAM' then
        defaultws = {'Tachi: Fudo'}
        tpws = {'Tachi: Fudo'}
        spamws = {'Tachi: Fudo'}
        cleavews = {}
        starterws = {'Tachi: Shoha'}
        preferws = {'Tachi: Shoha'}
        amws = 'Tachi: Rana'
    end


-- BARD

    if info.job == 'BRD' then
        defaultws = {'Savage Blade','Rudra\'s Storm'}
        tpws = {}
        spamws = {'Savage Blade','Rudra\'s Storm'}
        cleavews = {}
        starterws = {'Savage Blade','Rudra\'s Storm'}
        preferws = {'Savage Blade','Rudra\'s Storm'}
        amws = 'Mordant Rime'
    end


-- BLUE MAGE

    if info.job == 'BLU' then
        defaultws = {}
        tpws = {}
        spamws = {}
        cleavews = {}
        starterws = {}
        preferws = {}
        amws = 'Expiacion'
    end


-- WARRIOR

    if info.job == 'WAR' then
        defaultws = {'Upheaval','Savage Blade','Full Break'}
        tpws = {}
        spamws = {'Upheaval'}
        cleavews = {}
        starterws = {'Upheaval','Savage Blade','Full Break'}
        preferws = {'Upheaval','Savage Blade','Full Break'}
        amws = 'King\'s Justice'
    end


-- WHITE MAGE

    if info.job == 'WHM' then
        defaultws = {'Black Halo'}
        tpws = {}
        spamws = {'Black Halo'}
        cleavews = {}
        starterws = {'Black Halo'}
        preferws = {'Black Halo'}
        amws = 'Mystic Boon'
    end


-- RED MAGE

    if info.job == 'RDM' then
        defaultws = {'Death Blossom','Savage Blade'}
        tpws = {}
        spamws = {'Savage Blade'}
        cleavews = {}
        starterws = {'Death Blossom','Savage Blade'}
        preferws = {'Death Blossom','Savage Blade'}
        amws = 'Death Blossom'
    end


-- PALADIN

    if info.job == 'PLD' then
        defaultws = {'Red Lotus Blade'}
        tpws = {}
        spamws = {'Savage Blade'}
        cleavews = {}
        starterws = {'Red Lotus Blade'}
        preferws = {'Red Lotus Blade'}
        amws = 'Atonement'
    end


-- NINJA

    if info.job == 'NIN' then
        defaultws = {'Blade: Shun'}
        tpws = {}
        spamws = {'Blade: Hi'}
        cleavews = {}
        starterws = {'Blade: Shun'}
        preferws = {'Blade: Ku'}
        amws = 'Blade: Kamu'
    end


-- GEOMANCER

    if info.job == 'GEO' then
        defaultws = {}
        tpws = {}
        spamws = {}
        cleavews = {}
        starterws = {}
        preferws = {}
        amws = 'Exudation'
    end


-- RANGER

    if info.job == 'RNG' then
        defaultws = {}
        tpws = {}
        spamws = {}
        cleavews = {}
        starterws = {}
        preferws = {}
        amws = 'Trueflight'
    end


-- BEAST MASTER

    if info.job == 'BST' then
        defaultws = {}
        tpws = {}
        spamws = {}
        cleavews = {}
        starterws = {}
        preferws = {}
        amws = 'Primal Rend'
        petws = {}
    end


-- SCHOLAR

    if info.job == 'SCH' then
        defaultws = {'Black Halo'}
        tpws = {}
        spamws = {'Black Halo'}
        cleavews = {}
        starterws = {'Black Halo'}
        preferws = {'Black Halo'}
        amws = 'Omniscience'
    end


-- SUMMONER

    if info.job == 'SMN' then
        defaultws = {'Garland of Bliss'}
        tpws = {}
        spamws = {'Garland of Bliss'}
        cleavews = {}
        starterws = {'Garland of Bliss'}
        preferws = {'Garland of Bliss'}
        amws = 'Garland of Bliss'
        petws = {}
    end


-- Defined total fast cast for autonuke for each job
    if info.job == 'BLM' then
      fastcast = 0.80
    elseif info.job == 'NIN' then
      fastcast = 0.80
    elseif info.job == 'SCH' then
      fastcast = 0.80
    else
      fastcast = 0
    end

-- Delay for 'mb' mode and 'buddy' mode; edit for lag
    bursttime = 1.5
    tagdelay = 0.5

-- Interval definitions to adjust for system resource lag
    current_frame = 0
    interval = 0.1

-- Beast Master and Summoner ability recast timers
    bstrecast = 10
    smnrecast = 30

-- Autonuking command to call gearswap magic burst mode
    if info.job == 'BLM' then
      nukeswap = ''
    elseif info.job == 'SCH' then
      nukeswap = ''
    else
      nukeswap = ''
    end

end
