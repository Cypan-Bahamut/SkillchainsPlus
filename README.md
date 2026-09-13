# Requirements

All files including the data folder, nukes, skills, and skillchainsplus are required to function correctly.

Upon initial load, a new character.lua file will be generated to allow character specific weaponskill settings.

# SkillChains (original addon)

Active battle skillchain display.

Displays a text object containing skillchain elements resonating on current target, timer for the skillchain window,
and a list of weapon skills that can skillchain based on the weapon you have currently equipped.

General

    //sc help
    //sc status
    //sc reload

Display placement and saving

    //sc move
    //sc save
    //sc save all

Display toggles (saved per job)

    //sc weapon   (weapon skills)
    //sc spell    (SCH Immanence and BLU spells)
    //sc pet      (SMN and BST pet skills)
    //sc burst    (magic burst elements)
    //sc props    (skillchain properties on target)
    //sc timer    (skillchain window timer)
    //sc step     (current weaponskill step information)

Display options (global)

    //sc color    (colorize properties and elements)
    //sc aeonic   (enable Aeonic aftermath checks, if supported by your setup)

More settings related to the text object can be found within the settings.xml generated on addon load.

# SkillChains Plus (Cypan modifications)

Active battle skillchain automation, structured as CORE MODES plus OVERLAYS.

## Core modes

Exactly one core mode drives weaponskills (or none = manual, display only).
Turning a core on turns the other core off AND disarms the other core's
overlays, so each mode starts clean. `//sc status` always leads with the
active core.

    //sc spam        Core: fires the picked weaponskill at the TP threshold (default 1000).
    //sc auto        Core: opens and closes skillchains on window timing using defaultws/tpws.

## Overlays

Overlays are armed and disarmed independently and never turn a core on.
An overlay armed while its core is off sits dormant (the chat line says so)
and wakes when its core turns on.

Spam-scoped overlays (cleared when auto turns on)

    //sc spamsc      Hold the spam WS to CLOSE a skillchain at the end of the window.
    //sc nosc        Hold the spam WS whenever it WOULD form a skillchain - spam without
                     ever chaining. Suspended while spamsc is armed (spamsc wins); fires
                     freely during the pre-window delay and after the window expires.
    //sc rotate      Pick the spam WS from your rotatews list in order. Advances only when
                     the WS actually goes off (a rejected send never skips a slot).
                     Mutually exclusive with cleave.
    //sc cleave      Pick the AoE cleave WS instead of spamws. Mutually exclusive with rotate.
    //sc starter     Use starterws once per battle to open.
    //sc spamtp <1000-3000>   TP threshold for spam (parameter, not a toggle).
    //sc whilecasting | whilereadies   Allow spam to trigger during casting/readying.

Auto-scoped overlays (cleared when spam turns on)

    //sc open        Only open skillchains, never close.
    //sc close       Only close skillchains, never open.
    //sc prefer      Prioritize preferws if a closing option exists.
    //sc strict      Only close skillchains if preferws is available.
    //sc ultimate    Only close if it can make a level 4 skillchain.
    //sc buddy       Wait for the engaged party member with highest TP to weaponskill.

Cross-scope overlays (read by both cores; survive core switches)

    //sc mb          Wait to skillchain until the end of the current window (burst setups).
    //sc am          Maintain Aftermath 3 and prioritize it if not active.
    //sc autonuke    Auto magic burst during the skillchain burst window.
    //sc light | dark | <element>   Restrict which skillchains the automation will make.

Global modifiers

    //sc melee       Force only melee weaponskills.
    //sc ranged      Force only ranged weaponskills.
    //sc endless     Force a level 1/2 skillchain if available.
    //sc steps | nosteps | nopet    DNC step and BST pet automation toggles.

## Combination shortcuts

    //sc party       auto core + buddy
    //sc partymb     auto core + buddy + mb
    //sc partyam     auto core + buddy + am

These are auto core entries: they disarm all spam-scoped overlays like //sc auto does.

## Weaponskill lists (runtime editing)

    //sc wslist                       Show all lists for the current job.
    //sc wsadd <list> <weaponskill>   Add to the front of a list.
    //sc wsrm <list> <weaponskill>    Remove from a list (alias: wsremove).

Lists: defaultws, tpws, spamws, starterws, preferws, avoidws, petws, amws, rotatews.
rotatews feeds //sc rotate; entries must match the weaponskill's exact English name.
Runtime edits last until //sc reload.

## Positioning

    //sc innin | yonin           Behind / in front of the mob (simple strafe).
    //sc face | rear             Front / behind with approach.
    //sc pet | petface           Pet side, without / with approach.

## Party targeting helpers

    //sc ignore <name>   Add a party member to the ignore list for buddy logic.
    //sc watch <name>    Remove a party member from the ignore list.

## Manual trigger macros

    /console sc autoskill    Close the current skillchain with the selected weaponskill.
    /console sc spamskill    Use the zergws weaponskill, if defined.
    /console sc autoburst    Attempt a magic burst using the current burst mode.

# Nukes addon (separate)

If you use the nukes addon directly, these are its addon commands:

Elemental selections

    //nukes thunder
    //nukes blizzard
    //nukes fire
    //nukes aero
    //nukes water
    //nukes stone

Skillchain based selections

    //nukes grav
    //nukes disto
    //nukes frag
    //nukes fusion
    //nukes light
    //nukes darkness
    //nukes dark
    //nukes holy

Element toggles (exclude an element from selection)

    //nukes nostone
    //nukes nowater
    //nukes nowind
    //nukes nofire
    //nukes noice
    //nukes nothunder
    //nukes nodark
    //nukes nolight
