# skillchainsplus

Active battle skillchain display and automation for Windower.

Original addon: SkillChains by Ivaar. Modified by Cypan (Bahamut) and renamed
skillchainsplus for distribution.

## Installation

Place the `skillchainsplus` folder in `Windower/addons/` and load with
`//lua load skillchainsplus`. All files — `skillchainsplus.lua`, `skills.lua`,
`nukes.lua`, and the `data` folder — are required to function correctly.

Upon initial load, a new `<CharacterName>.lua` file is generated in the addon
folder (copied from `data/auto.lua`) to allow character-specific weaponskill
settings.

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

Active battle skillchains automation.

Primary automation and utility commands

    //sc spam        Spams defined spamws at 1000 TP.
    //sc auto        Auto skillchaining using defaultws and tpws openers when no skillchain is available.
    //sc autonuke    Auto magic bursts during the skillchain burst window.
    //sc status      Displays active automation modes.
    //sc reload      Reloads the addon and resets commands.

Party targeting helpers

    //sc buddy           Waits for the engaged party member with highest TP to weaponskill.
    //sc ignore <name>   Adds a party member to the ignore list for buddy logic.
    //sc watch <name>    Removes a party member from the ignore list (inverse of ignore).

Skillchain behavior modifiers

    //sc prefer      Prioritizes preferws if a closing option exists.
    //sc strict      Only closes skillchains if preferws is available.
    //sc open        Only opens skillchains with defaultws and does not close.
    //sc close       Only closes skillchains and does not open.
    //sc endless     Forces using a level 2 or level 1 skillchain if available.
    //sc spamsc      Spams defined spamws at 1000 TP but waits if spamws can close current skillchain.
    //sc ultimate    Only closes if it can make a level 4 skillchain.
    //sc starter     Uses starterws once per battle to open.
    //sc melee       Forces only melee weaponskills for skillchains.
    //sc ranged      Forces only ranged weaponskills for skillchains.
    //sc cleave      Spam mode using cleavews instead of spamws.
    //sc am          Maintains Aftermath 3 and prioritizes if not active.
    //sc mb          Waits to skillchain until the end of the current skillchain window.
    //sc innin       Maintains behind the mob position when not actively skillchaining.
    //sc yonin       Maintains in front of the mob position when not actively skillchaining.
    //sc light       Forces closing light based skillchains when available.
    //sc dark        Forces closing dark based skillchains when available.
    //sc whilecasting    Allows spam to trigger during casting.
    //sc whilereadies    Allows spam to trigger during readying.
    //sc ongo       Toggles Ongo mode (special case behavior in this addon).
    //sc nomb | mboff | mbclear    Clears any forced magic burst element.
    //sc <ele>mb     Forces bursting only the given element (e.g. watermb, icemb, firemb, darkmb); repeat to clear.
    //sc no<ele>     Excludes an element from bursting (e.g. nowater, noice, nofire); repeat to re-enable.
    //sc mana        Resets burst element control entirely (force off, exclusions cleared).
    //sc ebul(lience) //sc alac(rity)    Toggle preburst Ebullience / Alacrity (SCH).
    //sc cascade     Toggles Cascade mode.
    //sc nukespam    Toggles single-element nuke spam (NIN main: transparent alias for wheel).
    //sc tierspam    Toggles tiered nuke spam.
    //sc wheel       Toggles the NIN elemental wheel.
    //sc nukedebug   Toggles nukespam debug output.

DNC / BST specific

    //sc steps       Toggles DNC step rotation (Box Step > Quickstep > Feather Step).
    //sc nosteps     Toggles DNC steps off (flourishes still active).
    //sc nopet       Toggles BST pet automation off.
    //sc bst         Toggles BST mode.

Positioning

    //sc innin | yonin      Simple strafe (behind / in front).
    //sc face | rear        Front + approach / behind + approach.
    //sc pet | petface      Pet side / pet side + approach.

Runtime WS list editing

    //sc wslist                       Lists the current WS lists.
    //sc wsadd <list> <weaponskill>   Adds a WS to a list (runtime only).
    //sc wsrm  <list> <weaponskill>   Removes a WS from a list (runtime only; wsremove also works).
                                      Use //sc reload to reset to the saved configuration.

Combination mode shortcuts

    //sc party       auto + buddy
    //sc partymb     auto + buddy + mb
    //sc partyam     auto + buddy + am

Manual trigger macros

    /console sc autoskill    Closes the current skillchain with the selected weaponskill.
    /console sc spamskill    Uses the zergws weaponskill, if defined.
    /console sc autoburst    Attempts to magic burst using the currently selected burst mode.

Internal utility

    //sc nuking    Resets the internal autonuke lockout flag (used by autonuke timing).
    //sc eval      Runs a Lua expression (developer use).

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
