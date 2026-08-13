-- GENERATED FILE — do not edit by hand.
-- Source: content/midnight-s2/kings-rest.yaml   (regenerate with tools/generate.py)
local _, ns = ...

ns.RegisterDungeon({
  ["dungeon"] = "King's Rest",
  ["slug"] = "kings-rest",
  ["season"] = "midnight-s2",
  ["patch"] = "12.1.0",
  ["sourceVersion"] = "0.6",
  ["instanceID"] = nil,
  ["mdtRoutes"] = {
    {
      ["name"] = "Echo#12882 - keystone.guru (Jul 2026)",
      ["string"] = "!~MDT2~XZPNU9pAGMa7IYDfSrUtctpjD5opRLQ5IgRFbKUf43gNyRtIu9l1shuLnlxGp177LxA70/5/5d6FSgUPmUze931+u8/uk9/HjucxegoRDxjd1MKWywiLWg4BIaBBfTY4dmLBqqNqQDvDk5m+19NrAnrCbn7EvHTA2l/AFfxmUPFu7bL1xijXt0t7lmGh4Vmhe+4Q3I7bbQKYRVhEEKpXFyKo0OE/xV7ZMOvbZrFs7KBhjcRcTFq7pR2jqFpvS8augpnvalv485iwhffHzC1M2QjNHTcK/MAFLBgGR2DRBeyDE01QO2XLKKl9FYuGqVCvhUO/4kCMd4I5w98AqxMR+DwmBHNwGfVwGNBA6atx4DXrbNfaiyu9XvPAvnBIDL/s0Sj/kaAbpOkp7S6d1VMZbQ7Z47Oq+74Jvp+k+xmky0lxVLLgPt1P69rtwuLSyrwutSmBCYPM1LA1IsxJlJWPVL9tQrIi0eoM1IT7RYmWJVqS0xuwIJka8v2FG5TS9HmJkv9DluKtSZQvfJ/X51A6pT0qRpp8oZ/N5B4FTnHEzUktX7hbWlhcWV7NrQ2ey1nX9zN21/tIe6WeDYl+bly/kNpLidZlatb2xvWM60E+/8TzIL/5xHHTjaMIqGipe0AnDx+fYhWHCyCoBRTCywrnQYeGqsGvPzyM1GLaAUZVjHMHAkDdcudZgwNRIVZ/g0RNlSRx4vsclOjIC3yVq5iIS60aekFy6EcAXUY81GhDJw6IkqP3k+IRCyh4fxpupEII3v5lcugSh3O1WLZGnRDs0+DqitmqTcJm1VGrchE5/Oov",
    },
  },
  ["quicksheet"] = {
    ["trash"] = {
      ["TANK"] = "Shadow-Borne Witch Doctor — Shadow Bolt Volley: Interrupt; this is the must-stop cast.; Seneschal M'bara — Induce Regeneration: Interrupt or purge the heal.; Spectral Shaman — Healing Tide Totem: Kill the totem immediately.; Shadow of Zul — Dark Revelation: Two targets move 20+ yards away; this now comes before Pool.",
      ["HEALER"] = "Shadow-Borne Witch Doctor — Shadow Bolt Volley: Interrupt; this is the must-stop cast.; Seneschal M'bara — Induce Regeneration: Interrupt or purge the heal.; Spectral Shaman — Healing Tide Totem: Kill the totem immediately.; Shadow of Zul — Dark Revelation: Two targets move 20+ yards away; this now comes before Pool.",
      ["DPS"] = "Shadow-Borne Witch Doctor — Shadow Bolt Volley: Interrupt; this is the must-stop cast.; Seneschal M'bara — Induce Regeneration: Interrupt or purge the heal.; Spectral Shaman — Healing Tide Totem: Kill the totem immediately.; Shadow of Zul — Dark Revelation: Two targets move 20+ yards away; this now comes before Pool.",
    },
  },
  ["overview"] = {
    ["interrupts"] = {
      {
        ["spell"] = "Shadow Bolt Volley",
        ["note"] = "must-stop cast",
      },
      {
        ["spell"] = "Hex",
        ["note"] = "interrupt the long control effect",
      },
      {
        ["spell"] = "Wretched Discharge",
        ["note"] = "Half-Finished Mummy's cast — now 5 seconds long, still mandatory",
      },
      {
        ["spell"] = "Poison Nova",
        ["note"] = "interrupt Zanazal's cast",
      },
    },
    ["killPriority"] = {
      "Explosive Totem",
      "Healing Tide Totem",
      "Animated Gold",
    },
    ["tank"] = {
      ["damage"] = {
        "Royal Berserker — Bloodthirsty Axe: plan mitigation for heavy physical pressure.",
        "Shadow of Zul — Shadow Barrage: sustained tank magic damage.",
      },
      ["pullWarnings"] = {
        "Plan stops, soothes and pulls before the key.",
        "Danger windows: Royal Berserkers, Shadow of Zul, Debilitating Backhand and Blade Combo.",
        "Shadow-Borne Champion — Released Inhibitors: soothe the Haste enrage.",
        "Shadow of Zul — Dark Revelation: two targets move 20+ yards away; this now comes before Pool of Darkness.",
      },
    },
    ["healer"] = {
      ["dispels"] = {
        "Confirm poison and disease coverage before the key.",
      },
      ["pressure"] = {
        "Spit Gold — the Golden Serpent's main targeted damage.",
        "Awakening Slam — Mchimba's group damage; watch for mechanic overlaps.",
        "Council overlaps — soak, axes and totems overlapping create heavy raid damage.",
        "Gilded Destruction — Dazar's group hit plus a 15-second Fire DoT.",
      },
      ["pullWarnings"] = {
        "Confirm poison and disease coverage before the key.",
        "Danger windows: Berserkers, Spit Gold, Awakening Slam, Council overlaps and Gilded Destruction.",
      },
    },
    ["dps"] = {
      ["purges"] = {
        "Induce Regeneration — interrupt or purge the heal (Seneschal M'bara).",
        "Bound by Shadow — purge, then control Fixate (Minion of Zul).",
      },
      ["defensives"] = {
        "Personal if Spit Gold overlaps Gust or add pressure.",
        "Personal for Drain Fluids or Awakening Slam.",
        "Personal for Severing Axe or a bad overlap.",
        "Personal for Gilded Destruction and its DoT.",
      },
      ["pullWarnings"] = {
        "Animated Guardian — Suppression Slam: Dodge the aimed frontal and stun.",
        "Guard Captain Atu — Axe Barrage: Stop the channel.",
        "King Timalji — Bladestorm: Run out; do not drag it through allies.",
        "Purification Construct — Purification Beam: Follow the rotating beam.",
        "Honored Raptor — Hunting Leap: Leave the landing cleave.",
        "Shadow of Zul — Dark Revelation: two targets move 20+ yards away; this now comes before Pool.",
        "Shadow of Zul — Pool of Darkness: Use the assigned soak after Dark Revelation.",
      },
    },
    ["tip"] = {
      "Version 0.6, verified 9 August 2026 against Blizzard PTR dungeon testing (7 Jul-3 Aug), Wowhead Midnight S2 overview and PTR data, Icy Veins Patch 12.1 overview and Warcraft Wiki. No gameplay change found after 27 July aside from Wretched Discharge (now 5 sec), Whirling Axe periodic damage (-11%) and Dark Revelation now preceding Pool of Darkness.",
      "Assign interrupts, gold placement and the first Pool of Darkness before starting.",
      "Requires live verification before Version 1.0: final Enemy Forces, dispel types, encounter timings and any launch hotfixes.",
    },
  },
  ["trashSegments"] = {
    {
      ["name"] = "Opening trash — before The Golden Serpent",
      ["after"] = nil,
      ["npcs"] = {
        {
          ["name"] = "Shadow-Borne Witch Doctor",
          ["npcID"] = nil,
          ["displayID"] = nil,
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
      },
      ["roles"] = {
        ["TANK"] = {
          "Shadow-Borne Witch Doctor — Shadow Bolt Volley: Interrupt; this is the must-stop cast.",
          "Animated Guardian — Suppression Slam: Dodge the aimed frontal and stun.",
          "Shadow-Borne Champion — Released Inhibitors: Soothe the Haste enrage.",
          "Minion of Zul — Bound by Shadow: Purge; control the beam-marked Fixate.",
        },
        ["HEALER"] = {
          "Shadow-Borne Witch Doctor — Shadow Bolt Volley: Interrupt; this is the must-stop cast.",
          "Animated Guardian — Suppression Slam: Dodge the aimed frontal and stun.",
          "Shadow-Borne Champion — Released Inhibitors: Soothe the Haste enrage.",
          "Minion of Zul — Bound by Shadow: Purge; control the beam-marked Fixate.",
        },
        ["DPS"] = {
          "Shadow-Borne Witch Doctor — Shadow Bolt Volley: Interrupt; this is the must-stop cast.",
          "Animated Guardian — Suppression Slam: Dodge the aimed frontal and stun.",
          "Shadow-Borne Champion — Released Inhibitors: Soothe the Haste enrage.",
          "Minion of Zul — Bound by Shadow: Purge; control the beam-marked Fixate.",
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
      },
      ["roles"] = {
        ["TANK"] = {
          "Seneschal M'bara — Induce Regeneration: Interrupt or purge the heal.",
          "Guard Captain Atu — Axe Barrage: Stop the channel.",
          "King Timalji — Bladestorm: Run out; do not drag it through allies.",
          "Purification Construct — Purification Beam: Follow the rotating beam.",
        },
        ["HEALER"] = {
          "Seneschal M'bara — Induce Regeneration: Interrupt or purge the heal.",
          "Guard Captain Atu — Axe Barrage: Stop the channel.",
          "King Timalji — Bladestorm: Run out; do not drag it through allies.",
          "Purification Construct — Purification Beam: Follow the rotating beam.",
        },
        ["DPS"] = {
          "Seneschal M'bara — Induce Regeneration: Interrupt or purge the heal.",
          "Guard Captain Atu — Axe Barrage: Stop the channel.",
          "King Timalji — Bladestorm: Run out; do not drag it through allies.",
          "Purification Construct — Purification Beam: Follow the rotating beam.",
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
          ["name"] = "Spectral Hex Priest",
          ["npcID"] = nil,
          ["displayID"] = nil,
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
      },
      ["roles"] = {
        ["TANK"] = {
          "Royal Berserker — Bloodthirsty Axe: Plan mitigation for heavy physical pressure.",
          "Spectral Hex Priest — Hex: Interrupt the long control effect.",
          "Spectral Shaman — Healing Tide Totem: Kill the totem immediately.",
          "Honored Raptor — Hunting Leap: Leave the landing cleave.",
        },
        ["HEALER"] = {
          "Royal Berserker — Bloodthirsty Axe: Plan mitigation for heavy physical pressure.",
          "Spectral Hex Priest — Hex: Interrupt the long control effect.",
          "Spectral Shaman — Healing Tide Totem: Kill the totem immediately.",
          "Honored Raptor — Hunting Leap: Leave the landing cleave.",
        },
        ["DPS"] = {
          "Royal Berserker — Bloodthirsty Axe: Plan mitigation for heavy physical pressure.",
          "Spectral Hex Priest — Hex: Interrupt the long control effect.",
          "Spectral Shaman — Healing Tide Totem: Kill the totem immediately.",
          "Honored Raptor — Hunting Leap: Leave the landing cleave.",
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
          "Shadow of Zul — Shadow Barrage: Sustained tank magic damage.",
          "Shadow of Zul — Dark Revelation: Two targets move 20+ yards away; this now comes before Pool.",
          "Shadow of Zul — Pool of Darkness: Use the assigned soak after Dark Revelation.",
          "Minion of Zul — Bound by Shadow: Purge, then control Fixate.",
        },
        ["HEALER"] = {
          "Shadow of Zul — Shadow Barrage: Sustained tank magic damage.",
          "Shadow of Zul — Dark Revelation: Two targets move 20+ yards away; this now comes before Pool.",
          "Shadow of Zul — Pool of Darkness: Use the assigned soak after Dark Revelation.",
          "Minion of Zul — Bound by Shadow: Purge, then control Fixate.",
        },
        ["DPS"] = {
          "Shadow of Zul — Shadow Barrage: Sustained tank magic damage.",
          "Shadow of Zul — Dark Revelation: Two targets move 20+ yards away; this now comes before Pool.",
          "Shadow of Zul — Pool of Darkness: Use the assigned soak after Dark Revelation.",
          "Minion of Zul — Bound by Shadow: Purge, then control Fixate.",
        },
      },
    },
  },
  ["bosses"] = {
    {
      ["name"] = "The Golden Serpent",
      ["sheet"] = {
        ["TANK"] = "Tank away from the marked gold pile. Boss away from gold > mitigate Tail Thrash > move from adds.",
        ["HEALER"] = "Prioritise Spit Gold targets. Track Spit Gold > safe Gust position > stabilise loose adds.",
        ["DPS"] = "Place Spit Gold tightly. Stack gold > control adds > leave early for Gust.",
        ["WIPE"] = "Animated Gold reaching the boss grants Luster: a shield and damage increase.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 135322,
      ["displayID"] = 84202,
      ["wipe"] = {
        "Animated Gold reaching the boss grants Luster: a shield and damage increase.",
        "Tunnelling the boss while Animated Gold reaches it.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Tank away from the marked gold pile.",
            "Mitigate Tail Thrash.",
            "Move the boss away from Animated Gold after Lucre's Call.",
          },
          ["avoid"] = {
            "Serpentine Gust and its push.",
            "Dragging the boss through Molten Gold.",
          },
          ["defensive"] = {
            "Active mitigation for Tail Thrash.",
            "Extra coverage if Gust, Spit Gold and adds overlap.",
          },
          ["reminder"] = "Boss away from gold > mitigate Tail Thrash > move from adds.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Prioritise Spit Gold targets.",
            "Keep healing while the group controls Animated Gold.",
            "Watch the tank at every Tail Thrash.",
            "Heal Spit Gold, the main targeted damage.",
            "Recover anyone displaced by Serpentine Gust.",
          },
          ["avoid"] = {
            "Gust push and Molten Gold.",
            "Standing where the marked gold pile blocks your escape.",
          },
          ["cooldowns"] = {
            "Use group healing if Spit Gold overlaps Gust or loose adds.",
          },
          ["reminder"] = "Track Spit Gold > safe Gust position > stabilise loose adds.",
        },
        ["DPS"] = {
          ["job"] = {
            "Place Spit Gold tightly.",
            "Root, slow, stun or knock Animated Gold back.",
            "Kill adds together before returning to the boss.",
            "Animated Gold is the priority target; control is more valuable than early boss damage.",
          },
          ["avoid"] = {
            "Serpentine Gust.",
            "Standing between Animated Gold and the boss.",
          },
          ["defensive"] = {
            "Personal if Spit Gold overlaps Gust or add pressure.",
          },
          ["reminder"] = "Stack gold > control adds > leave early for Gust.",
        },
      },
    },
    {
      ["name"] = "Mchimba the Embalmer",
      ["sheet"] = {
        ["TANK"] = "Hold Mchimba near centre. See Struggle > correct coffin > stop the 5-sec cast.",
        ["HEALER"] = "Heal Desiccation targets above 90%. Desiccation above 90% > correct coffin > 5-sec kick.",
        ["DPS"] = "Use Struggle once if entombed. Shaking coffin first > kick the 5-sec cast.",
        ["WIPE"] = "Wrong coffin adds a mummy; Wretched Discharge is now a 5-second must-stop cast.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 134993,
      ["displayID"] = 83529,
      ["wipe"] = {
        "Wrong coffin adds a mummy; Wretched Discharge is now a 5-second must-stop cast.",
        "A completed Wretched Discharge still applies a dangerous group disease, despite the longer cast.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Hold Mchimba near centre.",
            "Open the coffin showing Struggle.",
            "Pick up released Half-Finished Mummies.",
          },
          ["avoid"] = {
            "Burn Corruption, Burning Ground and Explosive Acids.",
          },
          ["defensive"] = {
            "Use mitigation if Awakening Slam overlaps mummy pressure.",
          },
          ["reminder"] = "See Struggle > correct coffin > stop the 5-sec cast.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Heal Desiccation targets above 90%.",
            "Prepare for Awakening Slam.",
            "Help identify the correct coffin.",
            "Heal the Drain Fluids target.",
            "Heal Awakening Slam group damage.",
            "Heal disease damage after a missed Wretched Discharge, now a 5-second cast.",
          },
          ["avoid"] = {
            "Burn Corruption, Burning Ground and Explosive Acids.",
          },
          ["cooldowns"] = {
            "Group cooldown for Awakening Slam when another mechanic overlaps; Wretched Discharge now gives a 5-second stop window instead of an instant cast.",
          },
          ["reminder"] = "Desiccation above 90% > correct coffin > 5-sec kick.",
        },
        ["DPS"] = {
          ["job"] = {
            "Use Struggle once if entombed.",
            "Open the shaking coffin if free.",
            "Swap to Half-Finished Mummies.",
            "Interrupt Half-Finished Mummy's Wretched Discharge, now a 5-second cast but still mandatory.",
            "Prioritise the correct coffin before boss damage.",
          },
          ["avoid"] = {
            "Burn Corruption, Burning Ground and Explosive Acids.",
          },
          ["defensive"] = {
            "Personal for Drain Fluids or Awakening Slam.",
          },
          ["reminder"] = "Shaking coffin first > kick the 5-sec cast.",
        },
      },
    },
    {
      ["name"] = "The Council of Tribes",
      ["sheet"] = {
        ["TANK"] = "Position the active boss so axes, charges and totems stay visible. Backhand defensive > soak charge > never miss Nova.",
        ["HEALER"] = "Prepare for Kula's bleed, Aka'ali's tank spike and Zanazal's totems. Heal Axe > external Backhand > Explosive Totem first.",
        ["DPS"] = "Join Barrel Through. Soak together > Explosive Totem first > never miss Nova.",
        ["WIPE"] = "Missed Barrel Through, Poison Nova or Explosive Totem.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 135475,
      ["displayID"] = 84272,
      ["wipe"] = {
        "Missed Barrel Through, Poison Nova or Explosive Totem.",
        "Poison Nova or Explode completing.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Position the active boss so axes, charges and totems stay visible.",
            "Major defensive for Debilitating Backhand.",
            "Reserve an interrupt for Poison Nova.",
          },
          ["avoid"] = {
            "Whirling Axes — periodic damage now 11% lower, but still avoid them.",
            "Aiming Barrel Through away from the group.",
          },
          ["defensive"] = {
            "Major mitigation for Debilitating Backhand and following hits.",
          },
          ["reminder"] = "Backhand defensive > soak charge > never miss Nova.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Prepare for Kula's bleed, Aka'ali's tank spike and Zanazal's totems.",
            "Keep the Severing Axe target stable.",
            "Join Barrel Through.",
            "Heal the Severing Axe target.",
            "Heal the tank after Debilitating Backhand.",
            "Heal the group after a charge or totem overlap.",
          },
          ["avoid"] = {
            "Whirling Axes and totem danger zones — periodic axe damage is now 11% lower, but still heal clipped players.",
          },
          ["cooldowns"] = {
            "External for Backhand.",
            "Group cooldown if soak, axes and totems overlap.",
          },
          ["reminder"] = "Heal Axe > external Backhand > Explosive Totem first.",
        },
        ["DPS"] = {
          ["job"] = {
            "Join Barrel Through.",
            "Swap instantly to Explosive Totem.",
            "Keep Poison Nova assigned.",
            "Interrupt Zanazal's Poison Nova.",
            "Kill Explosive Totem before it explodes.",
            "Only target Lightning Bolt once Nova is covered.",
          },
          ["avoid"] = {
            "Whirling Axes — periodic damage now 11% lower, but still dodge them.",
            "Chasing through hazards for uptime.",
          },
          ["defensive"] = {
            "Personal for Severing Axe or a bad overlap.",
          },
          ["reminder"] = "Soak together > Explosive Totem first > never miss Nova.",
        },
      },
    },
    {
      ["name"] = "Dazar, the First King",
      ["sheet"] = {
        ["TANK"] = "Face Dazar away. Late Combo hurts most > control Reban > brace for Gilded.",
        ["HEALER"] = "Track increasing Blade Combo damage. Top group > cooldown Gilded > cover late Combo.",
        ["DPS"] = "Swap to Reban. Leap out > dodge spears > defensive for Gilded.",
        ["WIPE"] = "Gilded Destruction hits the group and leaves a 15-second Fire DoT.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 136160,
      ["displayID"] = 84352,
      ["wipe"] = {
        "Gilded Destruction hits the group and leaves a 15-second Fire DoT.",
        "Entering Gilded Destruction with players already low.",
        "Greeding uptime during spears or leap before Gilded Destruction.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Face Dazar away.",
            "Cover later Blade Combo hits.",
            "Pick up Reban and manage Savage Maul.",
          },
          ["avoid"] = {
            "Quaking Leap impacts and Impaling Spear lines.",
            "Turning Dazar or Reban through melee.",
          },
          ["defensive"] = {
            "Major defensive for late Blade Combo.",
            "Additional coverage if Savage Maul overlaps reduced armour.",
          },
          ["reminder"] = "Late Combo hurts most > control Reban > brace for Gilded.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Track increasing Blade Combo damage.",
            "Heal Quaking Leap targets after they move.",
            "Top the group before Gilded Destruction.",
            "Heal the tank during Blade Combo and Savage Maul.",
            "Heal through Gilded Destruction and its 15-second DoT.",
          },
          ["avoid"] = {
            "Spear lines and leap impacts while keeping the group in range.",
          },
          ["cooldowns"] = {
            "Assign a major healing cooldown to Gilded Destruction.",
            "External late Blade Combo hits.",
          },
          ["reminder"] = "Top group > cooldown Gilded > cover late Combo.",
        },
        ["DPS"] = {
          ["job"] = {
            "Swap to Reban.",
            "Move Quaking Leap away.",
            "Respect the redesigned ability sequence.",
            "Reban is the priority add.",
            "Maintain control without standing in raptor frontals.",
          },
          ["avoid"] = {
            "Impaling Spear lines, leap impacts and raptor frontals.",
          },
          ["defensive"] = {
            "Personal for Gilded Destruction and its DoT.",
          },
          ["reminder"] = "Leap out > dodge spears > defensive for Gilded.",
        },
      },
    },
  },
})
