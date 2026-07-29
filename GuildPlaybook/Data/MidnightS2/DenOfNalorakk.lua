-- GENERATED FILE — do not edit by hand.
-- Source: content/midnight-s2/den-of-nalorakk.yaml   (regenerate with tools/generate.py)
local _, ns = ...

ns.RegisterDungeon({
  ["dungeon"] = "Den of Nalorakk",
  ["slug"] = "den-of-nalorakk",
  ["season"] = "midnight-s2",
  ["patch"] = "12.1.0",
  ["sourceVersion"] = "0.9",
  ["instanceID"] = nil,
  ["quicksheet"] = {
    ["trash"] = {
      ["TANK"] = "Keen-Eyed Screecher — Piercing Screech: group and control.; Spirit of Hunger — Starvation Effigy: tank beside it.; The Winter Squall — Harsh Winds: priority target.; Grizzled Warbringer — Poison Spear Volley: keep space clear.; Grizzled Warbringer — Primal Echo: mitigate.",
      ["HEALER"] = "Keen-Eyed Screecher — Piercing Screech: pre-position for silence.; Spirit of Hunger — Starvation Effigy: kill; max health falls.; The Winter Squall — Harsh Winds: heal while moving.; Grizzled Warbringer — Poison Spear Volley: prepare for misses.; Grizzled Warbringer — Primal Echo: react quickly.",
      ["DPS"] = "Keen-Eyed Screecher — Piercing Screech: interrupt / stop.; Spirit of Hunger — Starvation Effigy: kill immediately.; The Winter Squall — Harsh Winds: kill first.; Grizzled Warbringer — Poison Spear Volley: dodge.; Grizzled Warbringer — Primal Echo: use a personal.",
      ["ROUTE"] = "Foraging > Hoardmonger > Winter > Sentinel > Heart of Rage > Nalorakk.",
    },
  },
  ["overview"] = {
    ["interrupts"] = {
      {
        ["spell"] = "Piercing Screech",
        ["note"] = "interrupt / stop",
      },
    },
    ["killPriority"] = {
      "Piercing Screech",
      "Starvation Effigy",
      "The Winter Squall",
      "Volatile Totems",
    },
    ["tank"] = {
      ["damage"] = {
        "Tank checks: empowered Hoardmonger, Frozen Tempest, Primal Echo and Overwhelming Onslaught.",
      },
      ["pullWarnings"] = {
        "Pull plan: do not combine unknown PTR packs or difficult patrols until live-tested.",
        "Positioning: face large enemies away and preserve shelter during the winter gauntlet.",
        "Control priority: Piercing Screech, Starvation Effigy and dangerous Heart of Rage packs.",
      },
    },
    ["healer"] = {
      ["dispels"] = {
        "Dispel: Mother's Wrath is confirmed dispellable; current PTR removes all stacks.",
      },
      ["pressure"] = {
        "Healing checks: Hoardmonger roars, Frozen Tempest, Primal Echo and Fury of the War God.",
      },
      ["pullWarnings"] = {
        "Silence warning: Piercing Screech silences the party for 2 seconds.",
        "Mana: avoid healing through Starvation Effigy; the group must kill it.",
      },
    },
    ["dps"] = {
      ["defensives"] = {
        "Movement: dodge Poison Spear Volley and keep clean shelter routes in the winter gauntlet.",
        "Personal defensives: boss roars, Frozen Tempest and difficult Fury sequences.",
      },
      ["pullWarnings"] = {
        "Keen-Eyed Screecher — Razor Dive: Use a defensive if targeted repeatedly; stop the eagle where possible.",
        "Spirit of Hunger — Starvation Effigy: Immediate swap: kill the Starvation Effigy before health reduction stacks.",
        "Territorial Matriarch — Mother's Wrath: Use a stop if available and give the healer room to dispel.",
        "The Winter Squall — Harsh Winds: Priority target. Kill The Winter Squall to end Harsh Winds.",
        "Glacial Revenant — Current PTR ability package: Live verification required; observe the cast bar and stop dangerous casts.",
        "Frigid Mauler / Terra Rumbler — Current PTR ability package: Live verification required; respect frontals and ground telegraphs.",
        "Grizzled Warbringer — Poison Spear Volley: Move out of impact circles; current PTR travel time is 3 seconds.",
        "Grizzled Warbringer — Primal Echo: Use a personal if targeted and avoid adding spear damage.",
        "Bonded Beasttamer — Current PTR ability package: Priority target; exact current interrupt list requires live verification.",
        "Loyal Saberfang — Fixate (cast name unconfirmed): Priority kill; targeted player kites without crossing the group.",
        "Loa Speaker Nanea — Volatile Totem: Immediate swap to Volatile Totems. Exact release behaviour requires live verification.",
      },
    },
    ["tip"] = "Mechanics beat uptime.",
  },
  ["bosses"] = {
    {
      ["name"] = "The Hoardmonger",
      ["sheet"] = {
        ["TANK"] = "Control the pile > face slams away > keep the arena clear.",
        ["HEALER"] = "Heal the roar > watch mushroom cleaners > limit spore stacks.",
        ["DPS"] = "Clear mushrooms safely > dodge slams > defensive the roar.",
        ["WIPE"] = "Uncleared Rotten Mushrooms burst and apply Toxic Spores to the party.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 248710,
      ["displayID"] = 129344,
      ["wipe"] = {
        "Uncleared Rotten Mushrooms burst and apply Toxic Spores to the party.",
        "Multiple spore stacks plus a roar can overwhelm the group.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Control which resource pile the boss reaches at 90%, 60% and 30%.",
            "Face Earthshatter Slam and Bonespike Slam away.",
            "Move early as mushrooms and spikes reduce space.",
          },
          ["avoid"] = {
            "Both frontal slams.",
            "Bone spikes and unnecessary Toxic Spores stacks.",
          },
          ["defensive"] = {
            "Mitigate Colossal Roar.",
            "Use stronger protection when Hearty Bellow is active.",
          },
          ["reminder"] = "Control the pile > face slams away > keep the arena clear.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Prepare for Colossal Roar.",
            "Track Toxic Spores on mushroom-clearing players.",
            "Keep the tank stable while the boss repositions.",
            "Hearty Bellow adds an initial hit and follow-up group damage.",
            "Stabilise one mushroom-clearing player at a time.",
          },
          ["avoid"] = {
            "Both frontals, bone spikes and clearing several mushrooms together.",
          },
          ["cooldowns"] = {
            "Use a healing cooldown when a later roar overlaps Toxic Spores or Hearty Bellow.",
          },
          ["reminder"] = "Heal the roar > watch mushroom cleaners > limit spore stacks.",
        },
        ["DPS"] = {
          ["job"] = {
            "Destroy or safely trigger Rotten Mushrooms before they burst.",
            "Maintain damage while the tank guides the boss to a resource pile.",
            "Rotten Mushrooms are the priority mechanic; clear them before Putrid Burst.",
          },
          ["avoid"] = {
            "Earthshatter Slam, Bonespike Slam and bone spikes.",
            "Running through multiple mushrooms.",
          },
          ["defensive"] = {
            "Use a personal for a roar overlapping Toxic Spores.",
          },
          ["reminder"] = "Clear mushrooms safely > dodge slams > defensive the roar.",
        },
      },
    },
    {
      ["name"] = "Sentinel of Winter",
      ["sheet"] = {
        ["TANK"] = "Centre the boss > preserve Snowdrifts > move inside.",
        ["HEALER"] = "Pre-heal > move inside > cover the Frost damage.",
        ["DPS"] = "Kill cores > soak fragment > get inside.",
        ["WIPE"] = "An unsoaked Rimeshatter causes party damage and a root.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 261053,
      ["displayID"] = 129418,
      ["wipe"] = {
        "An unsoaked Rimeshatter causes party damage and a root.",
        "Missing Rimeshatter or entering the storm low can collapse the party.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Keep the boss central so the party can reach the Frozen Tempest safe zone.",
            "Group Fractured Shivercores and preserve useful Snowdrifts.",
          },
          ["avoid"] = {
            "Raging Squalls and Rimeshatter impact zones assigned to another player.",
          },
          ["defensive"] = {
            "Enter the 10-yard inner safe zone and mitigate Frozen Tempest.",
          },
          ["reminder"] = "Centre the boss > preserve Snowdrifts > move inside.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Pre-heal Frozen Tempest while moving into the safe zone.",
            "Cover ramping Glacial Torment and Winter's Shroud pressure.",
            "Stabilise players assigned to Rimeshatter.",
            "Keep the party healthy before Frozen Tempest starts.",
          },
          ["avoid"] = {
            "Raging Squalls and becoming isolated before the storm.",
          },
          ["cooldowns"] = {
            "Use a healing cooldown during Frozen Tempest.",
          },
          ["reminder"] = "Pre-heal > move inside > cover the Frost damage.",
        },
        ["DPS"] = {
          ["job"] = {
            "Swap to Fractured Shivercores.",
            "Soak assigned Rimeshatter impacts.",
            "Move inside the boss's 10-yard safe zone for Frozen Tempest.",
            "Fractured Shivercores are the priority target; reduce Winter's Shroud pressure.",
          },
          ["avoid"] = {
            "Raging Squalls and unassigned Rimeshatter zones.",
          },
          ["defensive"] = {
            "Use a personal during Frozen Tempest or high Frost vulnerability.",
          },
          ["reminder"] = "Kill cores > soak fragment > get inside.",
        },
      },
    },
    {
      ["name"] = "Nalorakk",
      ["sheet"] = {
        ["TANK"] = "Use Zul'jarra's cover > keep echoes outside > protect her.",
        ["HEALER"] = "Heal interceptors > cover Fury > stay away from echoes.",
        ["DPS"] = "Drop outside > intercept one lane > avoid stored echoes.",
        ["WIPE"] = "Echoes reaching Zul'jarra trigger group damage and a stacking damage-taken penalty.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 258877,
      ["displayID"] = 125154,
      ["wipe"] = {
        "Echoes reaching Zul'jarra trigger group damage and a stacking damage-taken penalty.",
        "Repeated failures to protect Zul'jarra create escalating party damage.",
        "Poorly placed echoes repeat Echoing Maul and can make the arena unusable.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Stand in Zul'jarra's Defensive Stance coverage for Overwhelming Onslaught.",
            "Keep Echoing Maul placements away from the centre.",
            "Help assign separate echo-interception lanes during Fury of the War God.",
          },
          ["avoid"] = {
            "Stored Echoing Maul locations and unsafe Forceful Slam angles.",
          },
          ["defensive"] = {
            "Mitigate Overwhelming Onslaught and Forceful Slam.",
            "Use a group defensive for difficult Fury sequences.",
          },
          ["reminder"] = "Use Zul'jarra's cover > keep echoes outside > protect her.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Keep echo interceptors healthy during Fury of the War God.",
            "Prepare for Overwhelming Onslaught as a group mechanic.",
            "Track the arena before each Echoing Maul.",
            "Recover the party quickly if an echo reaches Zul'jarra.",
            "Current PTR: Fury interceptors no longer receive Spectral Slash from the intercepted echo.",
          },
          ["avoid"] = {
            "Stored Echoing Maul locations and duplicate interceptions.",
          },
          ["cooldowns"] = {
            "Use a healing cooldown during Fury; save recovery for a failed interception.",
          },
          ["reminder"] = "Heal interceptors > cover Fury > stay away from echoes.",
        },
        ["DPS"] = {
          ["job"] = {
            "Place Echoing Maul at an outside edge.",
            "Intercept one assigned echo during Fury of the War God.",
            "Return without crossing stored echoes.",
            "No boss interrupt priority confirmed; mechanic execution is the priority.",
          },
          ["avoid"] = {
            "Overlapping Maul markers and standing near stored echoes when they repeat.",
          },
          ["defensive"] = {
            "Use a personal before a dangerous Fury or Onslaught sequence.",
          },
          ["reminder"] = "Drop outside > intercept one lane > avoid stored echoes.",
        },
      },
    },
  },
})
