-- GENERATED FILE — do not edit by hand.
-- Source: content/midnight-s2/kings-rest.yaml   (regenerate with tools/generate.py)
local _, ns = ...

ns.RegisterDungeon({
  ["dungeon"] = "King's Rest",
  ["slug"] = "kings-rest",
  ["season"] = "midnight-s2",
  ["patch"] = "12.1.0",
  ["sourceVersion"] = "0.8",
  ["instanceID"] = nil,
  ["mdtRoutes"] = {
    {
      ["name"] = "Tactyks PUG Friendly - Method/wago.io (Aug 2026)",
      ["string"] = "!~MDT2~XZTNbxtFGMY767XznearzSZNy/ARpRIR0FqkBKkkUFqUKqKRCi1HZndm1hOPZ5zd2WRd9ZCxUpHAAdETHMLBdqnUMxIS9JBTQvMHJIrggIRUBBekEAcVC4R2k7Z2b6v3N8/7PO+rmb3n5DArZ6hHSEZyDJhN3IBxJlwgHhcvSyYI3nMChrMYT+fHPspmx1+fxoqESn2AHFXI+nDmw/fgJY8RgXmBzCMekLskH3Du3y6DYsI0llNNwDCbkwniSC49SmmaUFpJaNPUILnU1JwChySqj5OKcauzpbW9zdRGspg061RpUkrpp4fHCaXlTg2OPqlRSu00+aZFg9YlYJiJtsX2xY7Fuu5pUmnToF2DjjpN1KncpEGzrg9Caamr7tC4nSaVbg2swZVUNE5LMtFkDReB8UQST9WtDWtwubOru7WtveOoNVw0H4+NzkRO5R4NrFMN5pTe6S0Co69omMeKSdMa0Y37uNOrE8eKRqq/mExZI9poWEilT4PjGvTXB4n2ctc6oYE1pIF1UgPrBQ2sFzWwXnpmUxWwaFkaWM83WKZJxRrQwHpOAws+sydXEZJjwq0yn3DiKCaF7sk6gecRoWYCznuyHqPqCqU+Uf7KfmnwiBHslFBYm1xonR2eeTSHCrW1QqXv9Nrn30Xs55jN76/f8JYmI5ZfXt8d/1vslyOKD5TN1rlfVp2Y7vDRzcpnEfspZje3ht7fvX8uYjc+dkN1bfNp14XU+mv9N1djx8zGr2tdEw153mT/TFSNmC71jc1/caouz1/Hy5tXVmLHH873ZieCA+VBnrDrjVe+Xz0SUfdE8uGlxIM6z/OP/nzw+0bEwn9rL580X6237Ju9aAzFgfKXe99+eH2vTti6/tXeRhALv/3xdG37tjxc69XA5mSecDB3WHg3EC6RYgqH3a60Z4mj/GIJ4Vu1yU9GdrczW/dra3NbOxe//PotUA3hdOArGD1IeHYUnhUY2tL3RyFHvoo/kageiJfGtn8b2MrX1haI/V/4x6egGl6/gATEHnIPGpyBTCgJVYZAT8ocRAJDR+ZsJghcYCoTEz+PFgTBUHnIz0AqPYigTZQiHrS5lJgHvkKiyhyPIEXwO4UyFihH3MP/CfEI4jl2VUkv5yGXZByOfH8Kh22zmFHKnICrQudsDrOLAtmc4D2OMJbiGvF8JsWAkc/HF3YG8ch0SlBZ4ihQ8kJUja6ubOA4NP8H",
    },
  },
  ["quicksheet"] = {
    ["trash"] = {
      ["TANK"] = "Risen Hexer — [Hex Volley]: Interrupt; dangerous group curse, the must-stop cast.; Queen Wasi — [Bind Soul]: Interrupt; dangerous mind control.; Seneschal M'bara — [Unholy Mending]: Interrupt or purge the heal.; Half-Finished Mummy — [Wretched Discharge]: Interrupt every cast; heavy group disease.; Phantom Hex Priest — [Hex]: Interrupt the long control effect.; Zanazal the Wise — [Poison Nova]: Interrupt Zanazal's cast; heavy group poison.; Reban — [Deathly Roar]: Interrupt; group-wide fear.",
      ["HEALER"] = "Risen Hexer — [Hex Volley]: Interrupt; dangerous group curse, the must-stop cast.; Queen Wasi — [Bind Soul]: Interrupt; dangerous mind control.; Seneschal M'bara — [Unholy Mending]: Interrupt or purge the heal.; Half-Finished Mummy — [Wretched Discharge]: Interrupt every cast; heavy group disease.; Phantom Hex Priest — [Hex]: Interrupt the long control effect.; Zanazal the Wise — [Poison Nova]: Interrupt Zanazal's cast; heavy group poison.; Reban — [Deathly Roar]: Interrupt; group-wide fear.",
      ["DPS"] = "Risen Hexer — [Hex Volley]: Interrupt; dangerous group curse, the must-stop cast.; Queen Wasi — [Bind Soul]: Interrupt; dangerous mind control.; Seneschal M'bara — [Unholy Mending]: Interrupt or purge the heal.; Half-Finished Mummy — [Wretched Discharge]: Interrupt every cast; heavy group disease.; Phantom Hex Priest — [Hex]: Interrupt the long control effect.; Zanazal the Wise — [Poison Nova]: Interrupt Zanazal's cast; heavy group poison.; Reban — [Deathly Roar]: Interrupt; group-wide fear.",
    },
  },
  ["overview"] = {
    ["interrupts"] = {
      {
        ["spell"] = "Hex Volley",
        ["note"] = "Risen Hexer's dangerous group curse — the must-stop cast",
      },
      {
        ["spell"] = "Bind Soul",
        ["note"] = "Queen Wasi's dangerous mind control",
      },
      {
        ["spell"] = "Unholy Mending",
        ["note"] = "heals an enemy (Seneschal M'bara)",
      },
      {
        ["spell"] = "Wretched Discharge",
        ["note"] = "Half-Finished Mummy's cast — heavy group disease",
      },
      {
        ["spell"] = "Hex",
        ["note"] = "Phantom Hex Priest's dangerous crowd control",
      },
      {
        ["spell"] = "Poison Nova",
        ["note"] = "Zanazal the Wise's heavy group poison",
      },
      {
        ["spell"] = "Deathly Roar",
        ["note"] = "Reban's group-wide fear",
      },
    },
    ["killPriority"] = {
      "[Explosive Totem]",
      "[Healing Tide Totem]",
      "Animated Gold",
    },
    ["tank"] = {
      ["damage"] = {
        "Royal Berserker — [Bloodthirsty Axe]: plan mitigation for heavy physical pressure.",
        "Shadow of Zul — [Shadow Barrage]: sustained tank magic damage.",
      },
      ["pullWarnings"] = {
        "Plan stops, soothes and pulls before the key.",
        "Danger windows: Royal Berserkers, Shadow of Zul, [Debilitating Backhand] and [Blade Combo].",
        "Shadow-Borne Champion — [Released Inhibitors]: soothe the Haste enrage.",
        "Shadow of Zul — [Dark Revelation]: two targets move 20+ yards away; this now comes before [Pool of Darkness].",
      },
    },
    ["healer"] = {
      ["dispels"] = {
        "Confirm poison and disease coverage before the key.",
      },
      ["pressure"] = {
        "[Spit Gold] — the Golden Serpent's main targeted damage.",
        "[Awakening Slam] — Mchimba's group damage; watch for mechanic overlaps.",
        "Council overlaps — soak, axes and totems overlapping create heavy raid damage.",
        "[Gilded Destruction] — Dazar's group hit plus a 15-second Fire DoT.",
      },
      ["pullWarnings"] = {
        "Confirm poison and disease coverage before the key.",
        "Danger windows: Berserkers, [Spit Gold], [Awakening Slam], Council overlaps and [Gilded Destruction].",
      },
    },
    ["dps"] = {
      ["purges"] = {
        "[Unholy Mending] — interrupt or purge the heal (Seneschal M'bara).",
        "[Bound by Shadow] — purge, then control Fixate (Minion of Zul).",
      },
      ["defensives"] = {
        "Personal if [Spit Gold] overlaps Gust or add pressure.",
        "Personal for [Drain Fluids] or [Awakening Slam].",
        "Personal for [Severing Axe] or a bad overlap.",
        "Personal for [Gilded Destruction] and its DoT.",
      },
      ["pullWarnings"] = {
        "Animated Guardian — [Suppression Slam]: Dodge the aimed frontal and stun.",
        "Guard Captain Atu — [Axe Barrage]: Stop the channel.",
        "King Timalji — [Bladestorm]: Run out; do not drag it through allies.",
        "Purification Construct — [Purification Beam]: Follow the rotating beam.",
        "Honored Raptor — [Hunting Leap]: Leave the landing cleave.",
        "Shadow of Zul — [Dark Revelation]: two targets move 20+ yards away; this now comes before Pool.",
        "Shadow of Zul — [Pool of Darkness]: Use the assigned soak after [Dark Revelation].",
      },
    },
    ["tip"] = {
      "Version 0.8, live Season 2 rebuild for Reference Standard 1.7, verified 12 September 2026 against Blizzard, Wowhead, Method and Icy Veins. Biggest change: Shadow-Borne Witch Doctor is renamed Risen Hexer and casts [Shadow Bolt] where Blizzard replaced its old Shadowfrost Bolt cast, and the priority-interrupt list grew from four calls to seven.",
      "Timer: 33 minutes. The dungeon is linear; current guidance says every required enemy must be defeated.",
      "Seasonal: Lindormi's Guidance highlights a learning route at +2 to +5; weekly Bargains begin at +5.",
      "Assign interrupts, gold placement and the first [Pool of Darkness] before starting.",
      "Requires live verification: final Enemy Forces count.",
      "Next review: 26 September 2026, or after the next King's Rest hotfix, per the officer's document.",
    },
  },
  ["trashSegments"] = {
    {
      ["name"] = "Opening trash — before The Golden Serpent",
      ["after"] = nil,
      ["npcs"] = {
        {
          ["name"] = "Risen Hexer",
          ["npcID"] = 134174,
          ["displayID"] = 83371,
        },
        {
          ["name"] = "Animated Guardian",
          ["npcID"] = 133935,
          ["displayID"] = 83252,
        },
        {
          ["name"] = "Shadow-Borne Champion",
          ["npcID"] = 134158,
          ["displayID"] = 83364,
        },
        {
          ["name"] = "Minion of Zul",
          ["npcID"] = nil,
          ["displayID"] = 76055,
        },
        {
          ["name"] = "Umbral Warrior",
          ["npcID"] = 134157,
          ["displayID"] = 83363,
        },
      },
      ["roles"] = {
        ["TANK"] = {
          "Risen Hexer — [Hex Volley]: Interrupt; this is the must-stop cast.",
          "Animated Guardian — [Suppression Slam]: Dodge the aimed frontal and stun.",
          "Animated Guardian — [Heavy Slams]: Avoid stacking multiple guardians below 50%.",
          "Shadow-Borne Champion — [Released Inhibitors]: Soothe the Haste enrage.",
          "Shadow-Borne Champion — [Shadow Whirlwind]: Hold the mob still while melee leave.",
          "Minion of Zul — [Bound by Shadow]: Purge; control the beam-marked Fixate.",
          "Umbral Warrior — [Shadow Slash]: Have mitigation active for the instant hit.",
        },
        ["HEALER"] = {
          "Risen Hexer — [Hex Volley]: Interrupt; this is the must-stop cast.",
          "Risen Hexer — [Shadow Bolt]: Watch random targets; Blizzard replaced the old Shadowfrost Bolt.",
          "Animated Guardian — [Suppression Slam]: Dodge the aimed frontal and stun.",
          "Animated Guardian — [Heavy Slams]: Prepare repeated group healing, especially below 50%.",
          "Shadow-Borne Champion — [Released Inhibitors]: Soothe the Haste enrage.",
          "Shadow-Borne Champion — [Ancestral Fury]: Call for a soothe or purge.",
          "Minion of Zul — [Bound by Shadow]: Purge; control the beam-marked Fixate.",
          "Minion of Zul — [Pit of Despair]: Dispel the fear if a fixated player is struck.",
        },
        ["DPS"] = {
          "Risen Hexer — [Hex Volley]: Interrupt; this is the must-stop cast.",
          "Risen Hexer — [Shadow Bolt]: Use spare interrupts on random-target damage.",
          "Animated Guardian — [Suppression Slam]: Dodge the aimed frontal and stun.",
          "Shadow-Borne Champion — [Released Inhibitors]: Soothe the Haste enrage.",
          "Shadow-Borne Champion — [Ancestral Fury]: Soothe or purge the enrage.",
          "Minion of Zul — [Bound by Shadow]: Purge; control the beam-marked Fixate.",
        },
      },
    },
    {
      ["name"] = "Trash — The Golden Serpent to Mchimba",
      ["after"] = "The Golden Serpent",
      ["npcs"] = {
        {
          ["name"] = "Seneschal M'bara",
          ["npcID"] = 134251,
          ["displayID"] = 83517,
        },
        {
          ["name"] = "Guard Captain Atu",
          ["npcID"] = 137473,
          ["displayID"] = 85270,
        },
        {
          ["name"] = "King Timalji",
          ["npcID"] = 137474,
          ["displayID"] = 85272,
        },
        {
          ["name"] = "Purification Construct",
          ["npcID"] = 134739,
          ["displayID"] = 83836,
        },
        {
          ["name"] = "Queen Wasi",
          ["npcID"] = 137478,
          ["displayID"] = 85274,
        },
        {
          ["name"] = "King Rahu'ai",
          ["npcID"] = 134331,
          ["displayID"] = 83544,
        },
        {
          ["name"] = "King A'akul",
          ["npcID"] = 137484,
          ["displayID"] = 85284,
        },
        {
          ["name"] = "Interment Construct",
          ["npcID"] = 137969,
          ["displayID"] = 85677,
        },
        {
          ["name"] = "Bloodsworn Assassin",
          ["npcID"] = 137485,
          ["displayID"] = 85285,
        },
        {
          ["name"] = "Embalming Fluid",
          ["npcID"] = 137989,
          ["displayID"] = 33008,
        },
        {
          ["name"] = "Half-Finished Mummy",
          ["npcID"] = 270502,
          ["displayID"] = 84688,
        },
      },
      ["roles"] = {
        ["TANK"] = {
          "Seneschal M'bara — [Unholy Mending]: Interrupt or purge the heal.",
          "Guard Captain Atu — [Axe Barrage]: Stop the channel.",
          "Guard Captain Atu — [Captain's Bulwark]: Purge the enemy buff when your group can.",
          "King Timalji — [Bladestorm]: Run out; do not drag it through allies.",
          "Purification Construct — [Purification Beam]: Follow the rotating beam.",
          "King Rahu'ai — Overload: Move the pack away or stop the channel with displacement.",
          "King A'akul — [Mortal Bleed]: Use a defensive before impact.",
          "Interment Construct — [Entomb]: Keep coffin access clear.",
        },
        ["HEALER"] = {
          "Seneschal M'bara — [Unholy Mending]: Interrupt or purge the heal.",
          "Guard Captain Atu — [Axe Barrage]: Stop the channel.",
          "King Timalji — [Bladestorm]: Run out; do not drag it through allies.",
          "Purification Construct — [Purification Beam]: Follow the rotating beam.",
          "King Rahu'ai — Overload: Prepare group healing if the channel is not displaced.",
          "Bloodsworn Assassin — [Sudden Rupture]: Spot-heal the bleed before Blood Drain.",
          "Embalming Fluid — [Lingering Fluid]: Poison dispel quickly.",
          "Interment Construct — [Wail of Mourning]: Free the entombed player fast.",
        },
        ["DPS"] = {
          "Seneschal M'bara — [Unholy Mending]: Interrupt or purge the heal.",
          "Guard Captain Atu — [Axe Barrage]: Stop the channel.",
          "Guard Captain Atu — [Captain's Bulwark]: Purge the enemy buff.",
          "King Timalji — [Bladestorm]: Run out; do not drag it through allies.",
          "King Timalji — [Bladestorm]: Keep damage on while the fixate is kited.",
          "Purification Construct — [Purification Beam]: Follow the rotating beam.",
          "Queen Wasi — [Bind Soul]: Interrupt the mind control.",
          "Half-Finished Mummy — [Wretched Discharge]: Interrupt every cast.",
        },
      },
    },
    {
      ["name"] = "Trash — Mchimba to The Council of Tribes",
      ["after"] = "Mchimba the Embalmer",
      ["npcs"] = {
        {
          ["name"] = "Royal Berserker",
          ["npcID"] = 135167,
          ["displayID"] = 84112,
        },
        {
          ["name"] = "Phantom Hex Priest",
          ["npcID"] = 135204,
          ["displayID"] = 84140,
        },
        {
          ["name"] = "Spectral Shaman",
          ["npcID"] = 135239,
          ["displayID"] = 84163,
        },
        {
          ["name"] = "Honored Raptor",
          ["npcID"] = 135192,
          ["displayID"] = 84133,
        },
        {
          ["name"] = "Ghostly Brute",
          ["npcID"] = 135231,
          ["displayID"] = 85125,
        },
      },
      ["roles"] = {
        ["TANK"] = {
          "Royal Berserker — [Bloodthirsty Axe]: Plan mitigation for heavy physical pressure.",
          "Royal Berserker — [Violent Lunge]: Keep the landing zone clear.",
          "Phantom Hex Priest — [Hex]: Interrupt the long control effect.",
          "Spectral Shaman — [Healing Tide Totem]: Kill the totem immediately.",
          "Honored Raptor — [Hunting Leap]: Leave the landing cleave.",
          "Ghostly Brute — [Soul Crush]: Mitigate, then respect the damage-amplification debuff.",
          "Ghostly Brute — [Seismic Upheaval]: Move the pack out of the lethal circle.",
        },
        ["HEALER"] = {
          "Royal Berserker — [Bloodthirsty Axe]: Plan mitigation for heavy physical pressure.",
          "Royal Berserker — [Bloodthirsty Axe]: Spot-heal both bleed targets.",
          "Phantom Hex Priest — [Hex]: Interrupt the long control effect.",
          "Phantom Hex Priest — [Hex]: Curse dispel only if the interrupt fails.",
          "Spectral Shaman — [Healing Tide Totem]: Kill the totem immediately.",
          "Spectral Shaman — [Frost Shock]: Dispel the dangerous slow when needed.",
          "Honored Raptor — [Hunting Leap]: Leave the landing cleave.",
          "Ghostly Brute — [Soul Crush]: Watch the tank until the damage amp expires.",
        },
        ["DPS"] = {
          "Royal Berserker — [Bloodthirsty Axe]: Plan mitigation for heavy physical pressure.",
          "Phantom Hex Priest — [Hex]: Interrupt the long control effect.",
          "Phantom Hex Priest — [Spectral Bolt]: Use spare interrupts.",
          "Spectral Shaman — [Healing Tide Totem]: Kill the totem immediately.",
          "Honored Raptor — [Hunting Leap]: Leave the landing cleave.",
        },
      },
    },
    {
      ["name"] = "Final trash — The Council of Tribes to Dazar",
      ["after"] = "The Council of Tribes",
      ["npcs"] = {
        {
          ["name"] = "Shadow of Zul",
          ["npcID"] = 138489,
          ["displayID"] = 85860,
        },
        {
          ["name"] = "Minion of Zul",
          ["npcID"] = nil,
          ["displayID"] = 76055,
        },
      },
      ["roles"] = {
        ["TANK"] = {
          "Shadow of Zul — [Shadow Barrage]: Sustained tank magic damage.",
          "Shadow of Zul — [Shadow Barrage]: Use a defensive if repeated hits overlap.",
          "Shadow of Zul — [Dark Revelation]: Two targets move 20+ yards away; this now comes before Pool.",
          "Shadow of Zul — [Dark Revelation]: Pick up Minions of Zul without leaving the soaks.",
          "Shadow of Zul — [Pool of Darkness]: Use the assigned soak after [Dark Revelation].",
          "Shadow of Zul — [Pool of Darkness]: Hold the miniboss where both pools are reachable.",
          "Minion of Zul — [Bound by Shadow]: Purge, then control Fixate.",
        },
        ["HEALER"] = {
          "Shadow of Zul — [Shadow Barrage]: Sustained tank magic damage.",
          "Shadow of Zul — [Shadow Barrage]: Triage random targets.",
          "Shadow of Zul — [Dark Revelation]: Two targets move 20+ yards away; this now comes before Pool.",
          "Shadow of Zul — [Dark Revelation]: Heal spread targets and call for add purges.",
          "Shadow of Zul — [Pool of Darkness]: Use the assigned soak after [Dark Revelation].",
          "Shadow of Zul — [Pool of Darkness]: Ensure both pools remain soaked.",
          "Minion of Zul — [Bound by Shadow]: Purge, then control Fixate.",
        },
        ["DPS"] = {
          "Shadow of Zul — [Shadow Barrage]: Sustained tank magic damage.",
          "Shadow of Zul — [Shadow Barrage]: Use a personal if targeted during an overlap.",
          "Shadow of Zul — [Dark Revelation]: Two targets move 20+ yards away; this now comes before Pool.",
          "Shadow of Zul — [Dark Revelation]: Spread out, then purge or kill the spawned adds.",
          "Shadow of Zul — [Pool of Darkness]: Use the assigned soak after [Dark Revelation].",
          "Shadow of Zul — [Pool of Darkness]: (Ranged) assign one ranged player to each soak.",
          "Minion of Zul — [Bound by Shadow]: Purge, then control Fixate.",
        },
      },
    },
  },
  ["bosses"] = {
    {
      ["name"] = "The Golden Serpent",
      ["sheet"] = {
        ["TANK"] = "Tank away from the marked gold pile. Boss away from gold > mitigate [Tail Thrash] > move from adds.",
        ["HEALER"] = "Prioritise [Spit Gold] targets. Track [Spit Gold] > safe Gust position > stabilise loose adds.",
        ["DPS"] = "Place [Spit Gold] tightly. Stack gold > control adds > leave early for Gust.",
        ["WIPE"] = "Animated Gold reaching the boss grants [Luster]: a shield and damage increase.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 135322,
      ["displayID"] = 84202,
      ["wipe"] = {
        "Animated Gold reaching the boss grants [Luster]: a shield and damage increase.",
        "Tunnelling the boss while Animated Gold reaches it.",
        "[Lucre's Call] animates every gold pool; any add reaching the boss grants [Luster].",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Tank away from the marked gold pile.",
            "Mitigate [Tail Thrash].",
            "Move the boss away from Animated Gold after [Lucre's Call].",
          },
          ["avoid"] = {
            "[Serpentine Gust] and its push.",
            "Dragging the boss through [Molten Gold].",
            "Keep clear of [Spit Gold] puddles.",
          },
          ["defensive"] = {
            "Active mitigation for [Tail Thrash].",
            "Extra coverage if Gust, [Spit Gold] and adds overlap.",
          },
          ["reminder"] = "Boss away from gold > mitigate [Tail Thrash] > move from adds.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Prioritise [Spit Gold] targets.",
            "Keep healing while the group controls Animated Gold.",
            "Watch the tank at every [Tail Thrash].",
            "Heal [Spit Gold], the main targeted damage.",
            "Recover anyone displaced by [Serpentine Gust].",
          },
          ["avoid"] = {
            "Gust push and [Molten Gold].",
            "Standing where the marked gold pile blocks your escape.",
          },
          ["cooldowns"] = {
            "Use group healing if [Spit Gold] overlaps Gust or loose adds.",
          },
          ["reminder"] = "Track [Spit Gold] > safe Gust position > stabilise loose adds.",
        },
        ["DPS"] = {
          ["job"] = {
            "Place [Spit Gold] tightly.",
            "Root, slow, stun or knock Animated Gold back.",
            "Kill adds together before returning to the boss.",
            "Animated Gold is the priority target; control is more valuable than early boss damage.",
          },
          ["avoid"] = {
            "[Serpentine Gust].",
            "Standing between Animated Gold and the boss.",
          },
          ["defensive"] = {
            "Personal if [Spit Gold] overlaps Gust or add pressure.",
          },
          ["reminder"] = "Stack gold > control adds > leave early for Gust.",
        },
      },
    },
    {
      ["name"] = "Mchimba the Embalmer",
      ["sheet"] = {
        ["TANK"] = "Hold Mchimba near centre. See [Struggle] > correct coffin > stop the 5-sec cast.",
        ["HEALER"] = "Heal [Desiccation] targets above 90%. [Desiccation] above 90% > correct coffin > 5-sec kick.",
        ["DPS"] = "Use [Struggle] once if entombed. Shaking coffin first > kick the 5-sec cast.",
        ["WIPE"] = "Wrong coffin adds a mummy; [Wretched Discharge] is now a 5-second must-stop cast.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 134993,
      ["displayID"] = 83529,
      ["wipe"] = {
        "Wrong coffin adds a mummy; [Wretched Discharge] is now a 5-second must-stop cast.",
        "A completed [Wretched Discharge] still applies a dangerous group disease, despite the longer cast.",
        "[Entomb] must be solved quickly or Open Coffin releases extra Finished Mummies.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Hold Mchimba near centre.",
            "Open the coffin showing [Struggle].",
            "Pick up released Half-Finished Mummies.",
            "Stack spawned mummies on Mchimba and keep every coffin reachable.",
          },
          ["avoid"] = {
            "[Burn Corruption], [Burning Ground] and [Explosive Acids].",
          },
          ["defensive"] = {
            "Use mitigation if [Awakening Slam] overlaps mummy pressure.",
          },
          ["reminder"] = "See [Struggle] > correct coffin > stop the 5-sec cast.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Heal [Desiccation] targets above 90%.",
            "Prepare for [Awakening Slam].",
            "Help identify the correct coffin.",
            "Heal the [Drain Fluids] target.",
            "Heal [Awakening Slam] group damage.",
            "Heal disease damage after a missed [Wretched Discharge], now a 5-second cast.",
          },
          ["avoid"] = {
            "[Burn Corruption], [Burning Ground] and [Explosive Acids].",
          },
          ["cooldowns"] = {
            "Group cooldown for [Awakening Slam] when another mechanic overlaps; [Wretched Discharge] now gives a 5-second stop window instead of an instant cast.",
          },
          ["reminder"] = "[Desiccation] above 90% > correct coffin > 5-sec kick.",
        },
        ["DPS"] = {
          ["job"] = {
            "Use [Struggle] once if entombed.",
            "Open the shaking coffin if free.",
            "Swap to Half-Finished Mummies.",
            "Interrupt Half-Finished Mummy's [Wretched Discharge], now a 5-second cast but still mandatory.",
            "Prioritise the correct coffin before boss damage.",
          },
          ["avoid"] = {
            "[Burn Corruption], [Burning Ground] and [Explosive Acids].",
          },
          ["defensive"] = {
            "Personal for [Drain Fluids] or [Awakening Slam].",
          },
          ["reminder"] = "Shaking coffin first > kick the 5-sec cast.",
        },
      },
    },
    {
      ["name"] = "The Council of Tribes",
      ["sheet"] = {
        ["TANK"] = "Position the active boss so axes, charges and totems stay visible. Backhand defensive > soak charge > never miss Nova.",
        ["HEALER"] = "Prepare for Kula's bleed, Aka'ali's tank spike and Zanazal's totems. Heal Axe > external Backhand > [Explosive Totem] first.",
        ["DPS"] = "Join [Barrel Through]. Soak together > [Explosive Totem] first > never miss Nova.",
        ["WIPE"] = "Missed [Barrel Through], [Poison Nova] or [Explosive Totem].",
      },
      ["encounterID"] = nil,
      ["npcID"] = 135475,
      ["displayID"] = 84272,
      ["wipe"] = {
        "Missed [Barrel Through], [Poison Nova] or [Explosive Totem].",
        "[Poison Nova] or Explode completing.",
        "Explosive Totem — [Explode] is the first target; a completed cast can wipe the group.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Position the active boss so axes, charges and totems stay visible.",
            "Major defensive for [Debilitating Backhand].",
            "Reserve an interrupt for [Poison Nova].",
            "Tank Kula the Butcher centrally; stack for Aka'ali the Conqueror — [Barrel Through]; move Zanazal the Wise to priority totems.",
          },
          ["avoid"] = {
            "[Whirling Axes] — periodic damage now 11% lower, but still avoid them.",
            "Aiming [Barrel Through] away from the group.",
            "Leave Kula the Butcher — [Whirling Axes] and kite after Aka'ali the Conqueror — [Debilitating Backhand].",
          },
          ["defensive"] = {
            "Major mitigation for [Debilitating Backhand] and following hits.",
          },
          ["reminder"] = "Backhand defensive > soak charge > never miss Nova.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Prepare for Kula's bleed, Aka'ali's tank spike and Zanazal's totems.",
            "Keep the [Severing Axe] target stable.",
            "Join [Barrel Through].",
            "Heal the [Severing Axe] target.",
            "Heal the tank after [Debilitating Backhand].",
            "Heal the group after a charge or totem overlap.",
            "Spot-heal Kula the Butcher — [Severing Axe] and prepare group healing for Zanazal the Wise — [Arc Lightning].",
          },
          ["avoid"] = {
            "[Whirling Axes] and totem danger zones — periodic axe damage is now 11% lower, but still heal clipped players.",
          },
          ["cooldowns"] = {
            "External for Backhand.",
            "Group cooldown if soak, axes and totems overlap.",
          },
          ["reminder"] = "Heal Axe > external Backhand > [Explosive Totem] first.",
        },
        ["DPS"] = {
          ["job"] = {
            "Join [Barrel Through].",
            "Swap instantly to [Explosive Totem].",
            "Keep [Poison Nova] assigned.",
            "Interrupt Zanazal's [Poison Nova].",
            "Kill [Explosive Totem] before it explodes.",
            "Only target [Lightning Bolt] once Nova is covered.",
          },
          ["avoid"] = {
            "[Whirling Axes] — periodic damage now 11% lower, but still dodge them.",
            "Chasing through hazards for uptime.",
          },
          ["defensive"] = {
            "Personal for [Severing Axe] or a bad overlap.",
          },
          ["reminder"] = "Soak together > [Explosive Totem] first > never miss Nova.",
        },
      },
    },
    {
      ["name"] = "Dazar, the First King",
      ["sheet"] = {
        ["TANK"] = "Face Dazar away. Late Combo hurts most > control Reban > brace for Gilded.",
        ["HEALER"] = "Track increasing [Blade Combo] damage. Top group > cooldown Gilded > cover late Combo.",
        ["DPS"] = "Swap to Reban. Leap out > dodge spears > defensive for Gilded.",
        ["WIPE"] = "[Gilded Destruction] hits the group and leaves a 15-second Fire DoT.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 136160,
      ["displayID"] = 84352,
      ["wipe"] = {
        "[Gilded Destruction] hits the group and leaves a 15-second Fire DoT.",
        "Entering [Gilded Destruction] with players already low.",
        "Greeding uptime during spears or leap before [Gilded Destruction].",
        "[Deathly Roar] causes a group fear; a missed interrupt during high damage can collapse the group.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Face Dazar away.",
            "Cover later [Blade Combo] hits.",
            "Pick up Reban and manage [Savage Maul].",
            "Focus Reban first; face Reban — [Hunting Leap] and King Dazar's empowered melee frontals away.",
          },
          ["avoid"] = {
            "[Quaking Leap] impacts and [Impaling Spear] lines.",
            "Turning Dazar or Reban through melee.",
          },
          ["defensive"] = {
            "Major defensive for late [Blade Combo].",
            "Additional coverage if [Savage Maul] overlaps reduced armour.",
          },
          ["reminder"] = "Late Combo hurts most > control Reban > brace for Gilded.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Track increasing [Blade Combo] damage.",
            "Heal [Quaking Leap] targets after they move.",
            "Top the group before [Gilded Destruction].",
            "Heal the tank during [Blade Combo] and [Savage Maul].",
            "Heal through [Gilded Destruction] and its 15-second DoT.",
          },
          ["avoid"] = {
            "Spear lines and leap impacts while keeping the group in range.",
          },
          ["cooldowns"] = {
            "Assign a major healing cooldown to [Gilded Destruction].",
            "External late [Blade Combo] hits.",
          },
          ["reminder"] = "Top group > cooldown Gilded > cover late Combo.",
        },
        ["DPS"] = {
          ["job"] = {
            "Swap to Reban.",
            "Move [Quaking Leap] away.",
            "Respect the redesigned ability sequence.",
            "Reban is the priority add.",
            "Maintain control without standing in raptor frontals.",
            "Interrupt Reban — [Deathly Roar]; spread King Dazar — [Aerial Smash] markers.",
          },
          ["avoid"] = {
            "[Impaling Spear] lines, leap impacts and raptor frontals.",
            "Sidestep Reban — [Hunting Leap].",
          },
          ["defensive"] = {
            "Personal for [Gilded Destruction] and its DoT.",
          },
          ["reminder"] = "Leap out > dodge spears > defensive for Gilded.",
        },
      },
    },
  },
})
