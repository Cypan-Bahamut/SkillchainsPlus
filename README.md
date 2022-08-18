# Requirements

All files including the data folder, nukes, skills, and skillchainsplus are required to function correctly.

Upon initial load - a new character.lua file will be generated to allow character specific weaponskill settings.


# SkillChains - Original Addon
### Active Battle Skillchain Display.

Displays a text object containing skillchain elements resonating on current target, timer for skillchain window,
along with a list of weapon skills that can skillchain based on the weapon you have currently equipped.

    //sc color    -- colorize properties and elements

    //sc move     -- displays text box click and drag it to desired location.

    //sc save     -- save settings to current character.

    //sc save all -- save settings to all characters.

The following commands toggle the display information and are saved on a per job basis.

    //sc spell    -- sch immanence and blue magic spells.

    //sc pet      -- smn and bst pet skills.

    //sc weapon   -- weapon skills.

    //sc burst    -- magic burst elements.

    //sc props    -- skillchain properties currently active on target.

    //sc timer    -- skillchain window timer.

    //sc step     -- current weaponskill step information.

More settings related to text object can be found within the settings.xml, generated on addon load


# SkillChains Plus - Cypan Modifications
### Active Battle Skillchains Automation.

Primary automation and utility commands to utilize the defined skillchain display elements for automating weaponskills and magic bursts.

      //sc spam     -- spams defined "spamws" at 1k tp
      //sc auto     -- auto skillchaining using defined "defaultws" and
                    -- "tpws" as openers when no skillchain is available
      //sc autonuke -- auto magic bursts during skillchain burst window
      //sc ignore   -- ignores party member when 'buddy' is activated
                    -- define party member with //sc ignore <name>
      //sc status   -- displays active automation commands
      //sc reload   -- reloads addon and resets commands

Secondary automation commands that allow for augmenting the primary commands for combinations to work with party members for a desired outcome.

      //sc buddy    -- waits for the engaged party member w/ highest tp to
                    -- weaponskill; use the 'ignore' command to omit members
      //sc prefer   -- prioritizes "preferws" if a skillchain closing option
      //sc strict   -- will only close skillchain if "preferws" is available
      //sc open     -- will only open skillchains w/ "defaultws" and not close
      //sc close    -- will only close skillchains and not open a skillchain
      //sc endless  -- forces using a Lv.2 or Lv.1 skillchain if available
      //sc ultimate -- will only close a skillchain if it's a Lv.4 skillchain
      //sc starter  -- uses the defined "starterws" once per battle to open
      //sc melee    -- forces only using melee weaponskills for skillchains
      //sc ranged   -- forces only using ranged weaponskills for skillchains
      //sc cleave   -- spam mode using defined "cleavews" instead of "spamws"
      //sc am       -- will maintain aftermath 3 and prioritize if not active
      //sc mb       -- will force waiting to skillchain until end of sc window
      //sc innin    -- will force maintaining position behind mob if no sc
      //sc yonin    -- will force maintaining position in front of mob if no sc
      //sc light    -- will force closing light based skillchains if available
      //sc dark     -- will force closing dark based skillchains if available
      //sc whilecasting -- activates spam command to trigger during casting
      //sc whilereadies -- activates spam command to trigger during readying

Combination automation commands to provide easier access to common modes

      //sc party    -- 'auto' + 'buddy'
      //sc partymb  -- 'auto' + 'buddy' + 'mb'
      //sc partyam  -- 'auto' + 'buddy' + 'am'

In game macro support for activating automation triggers manually

      /console sc autoskill -- activates the weaponskill to close skillchain
      /console sc autoburst -- activates the nuke to magic burst skillchain
