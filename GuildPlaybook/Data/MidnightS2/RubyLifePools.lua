-- GENERATED FILE — do not edit by hand.
-- Source: content/midnight-s2/ruby-life-pools.yaml   (regenerate with tools/generate.py)
local _, ns = ...

ns.RegisterDungeon({
  ["dungeon"] = "Ruby Life Pools",
  ["slug"] = "ruby-life-pools",
  ["season"] = "midnight-s2",
  ["patch"] = "12.1.0",
  ["sourceVersion"] = "0.6",
  ["instanceID"] = nil,
  ["quicksheet"] = {
    ["trash"] = {
      ["TANK"] = "Primal Juggernaut — Crushing Smash: Mitigate, face away and sidestep Excavating Blast.; Flashfrost Earthshaper — Tectonic Slam: Call a hard stop; avoid overlapping dangerous casters.; Blazebound Destroyer — Inferno: Keep the pack stable and leave before Burnout finishes.",
      ["HEALER"] = "Primal Juggernaut — Crushing Smash: Watch the tank and keep moving for Excavating Blast.; Flashfrost Earthshaper — Tectonic Slam: Help stop it; prepare group healing if it completes.; Blazebound Destroyer — Inferno: Prepare group healing for the hit and follow-up damage.",
      ["DPS"] = "Flashfrost Chillweaver — Ice Shield: Interrupt first or purge; kill the Chillweaver quickly.; Flashfrost Earthshaper — Tectonic Slam: Use a stun or other hard stop.; Primalist Cinderweaver — Cinderbolt: Interrupt; purge or control Burning Ambition.",
    },
  },
  ["overview"] = {
    ["interrupts"] = {
      {
        ["spell"] = "Ice Shield",
        ["note"] = "Flashfrost Chillweaver — interrupt first or purge; kill the Chillweaver quickly.",
      },
      {
        ["spell"] = "Tectonic Slam",
        ["note"] = "Flashfrost Earthshaper — use a stun or other hard stop.",
      },
      {
        ["spell"] = "Frigid Shard",
        ["note"] = "Melidrussa Chillworn — kick as assigned.",
      },
      {
        ["spell"] = "Cinderbolt",
        ["note"] = "Primalist Cinderweaver — interrupt; purge or control Burning Ambition.",
      },
      {
        ["spell"] = "Roaring Blaze",
        ["note"] = "Kokia Blazehoof — kick; Firestorm add before Kokia.",
      },
      {
        ["spell"] = "Flame Dance",
        ["note"] = "Primalist Flamedancer — hard stop it; leave Blaze of Glory on death.",
      },
    },
    ["killPriority"] = {
      "Flashfrost Chillweaver — kill it quickly among the opening trash.",
      "Defier Draghar — the first miniboss must die to open Melidrussa's door.",
      "Whelps and Ice Bulwark before the boss (Melidrussa Chillworn).",
      "Blazebound Firestorm add before Kokia.",
      "Kyrakka whenever she is targetable; no routine boss kick on Erkhart.",
    },
    ["tank"] = {
      ["damage"] = {
        "Crushing Smash (Primal Juggernaut) — mitigate, face away and sidestep Excavating Blast.",
        "Steel Barrage (Defier Draghar) — mitigate the channel; bait Blazing Rush toward a wall.",
        "Thunder Jaw (Thunderhead) — mitigate and preserve a safe knockback lane.",
        "Fire Maw (Flamegullet) — mitigate and face away; its damage-ramp stacks are now capped.",
        "Searing Blows (Kokia Blazehoof) — always cover; request help if the bleed becomes unsafe.",
      },
      ["pullWarnings"] = {
        "Plan controlled pulls around eggs and grounded dragon patrols.",
        "Face frontals away; protect knockback lanes.",
        "The first miniboss must die to open Melidrussa's door.",
        "Call a hard stop for Tectonic Slam; avoid overlapping dangerous casters.",
        "PTR route, count and the final-trash package require live verification.",
      },
    },
    ["healer"] = {
      ["dispels"] = {
        "Rolling Thunder (Thunderhead) — stagger dispels; heal the second target before expiration.",
      },
      ["pressure"] = {
        "Inferno (Blazebound Destroyer / Kokia Blazehoof) — prepare group healing for the hit and follow-up damage.",
        "Molten Blood (Flamegullet) — prepare sustained group healing below 50%; the ramp is capped.",
        "Frost Overload (Melidrussa Chillworn) — Chillstorm ticks more slowly but lasts longer; recover after Frost Overload.",
        "Inferno Spit (Kyrakka and Erkhart Stormvein) — top targets before expiration; prioritise marked players and anyone trapped by fire.",
      },
      ["pullWarnings"] = {
        "Plan for Inferno, Molten Blood, Frost Overload and Inferno Spit.",
        "Tank damage overlaps group pressure on Kokia.",
        "The first miniboss must die to open Melidrussa's door.",
        "Help stop Tectonic Slam; prepare group healing if it completes.",
        "PTR dispels and the final-trash damage events require live verification.",
      },
    },
    ["dps"] = {
      ["purges"] = {
        "Burning Ambition (Primalist Cinderweaver) — purge or control it after kicking Cinderbolt.",
        "Ice Shield (Flashfrost Chillweaver) — interrupt first, or purge the shield if the kick is missed.",
      },
      ["defensives"] = {
        "Use a personal for Chillstorm or Frost Overload (Melidrussa Chillworn).",
        "Use a personal for Inferno, especially after a missed cast (Kokia Blazehoof).",
        "Use a personal for Inferno Spit expiration or a bad overlap (Kyrakka and Erkhart Stormvein).",
        "Use a personal for Rolling Thunder if needed (Thunderhead, trash).",
      },
      ["pullWarnings"] = {
        "Prioritise Ice Shield, Tectonic Slam and Roaring Blaze.",
        "Switch immediately to boss adds and shields.",
        "Hard stops matter as much as interrupts.",
        "Primal Juggernaut — Excavating Blast: sidestep the impact and puddle.",
        "Blazebound Destroyer — Burnout: run out before the death explosion.",
        "Thunderhead — Storm Breath: sidestep the frontal and personal Rolling Thunder if needed.",
        "PTR route and the final-trash priority list require live verification.",
      },
    },
    ["tip"] = {
      "Version 0.6, verified 9 August 2026 against Blizzard PTR/launch notes, Wowhead, Method and Icy Veins. No gameplay change found after 27 July.",
      "Pre-season: Patch 12.1 launches 11 August; Mythic+ Season 2 launches 18 August. Recheck live hotfixes.",
      "Requires live verification: the 29:00 PTR timer, enemy forces, route, final-trash spawns and launch hotfixes.",
    },
  },
  ["trashSegments"] = {
    {
      ["name"] = "Opening trash — before Melidrussa",
      ["after"] = nil,
      ["npcs"] = {
        {
          ["name"] = "Primal Juggernaut",
          ["npcID"] = 188244,
          ["displayID"] = 101209,
        },
        {
          ["name"] = "Flashfrost Earthshaper",
          ["npcID"] = nil,
          ["displayID"] = nil,
        },
        {
          ["name"] = "Flashfrost Chillweaver",
          ["npcID"] = 188067,
          ["displayID"] = 107397,
        },
        {
          ["name"] = "Defier Draghar",
          ["npcID"] = 187897,
          ["displayID"] = 107106,
        },
      },
      ["roles"] = {
        ["TANK"] = {
          "Primal Juggernaut — Crushing Smash: Mitigate, face away and sidestep Excavating Blast.",
          "Flashfrost Earthshaper — Tectonic Slam: Call a hard stop; avoid overlapping dangerous casters.",
          "Flashfrost Chillweaver — Ice Shield: Assign an interrupt or purge; keep the pack controlled.",
          "Defier Draghar — Steel Barrage: Mitigate the channel. This miniboss must die to open Melidrussa's door.",
        },
        ["HEALER"] = {
          "Primal Juggernaut — Crushing Smash: Watch the tank and keep moving for Excavating Blast.",
          "Flashfrost Earthshaper — Tectonic Slam: Help stop it; prepare group healing if it completes.",
          "Flashfrost Chillweaver — Ice Shield: Call the interrupt or purge before the shield grows.",
          "Defier Draghar — Steel Barrage: Focus the tank through the channel; the miniboss opens Melidrussa's door.",
        },
        ["DPS"] = {
          "Flashfrost Chillweaver — Ice Shield: Interrupt first or purge; kill the Chillweaver quickly.",
          "Flashfrost Earthshaper — Tectonic Slam: Use a stun or other hard stop.",
          "Primal Juggernaut — Excavating Blast: Sidestep the impact and puddle.",
          "Defier Draghar — Blazing Rush: Bait toward a wall, dodge, then kill him to open the boss door.",
        },
      },
    },
    {
      ["name"] = "Ruby Overlook trash — between bosses 1 & 2",
      ["after"] = "Melidrussa Chillworn",
      ["npcs"] = {
        {
          ["name"] = "Blazebound Destroyer",
          ["npcID"] = 190034,
          ["displayID"] = 102505,
        },
        {
          ["name"] = "Primalist Cinderweaver",
          ["npcID"] = 190207,
          ["displayID"] = 102886,
        },
        {
          ["name"] = "Primalist Flamedancer",
          ["npcID"] = nil,
          ["displayID"] = nil,
        },
        {
          ["name"] = "Thunderhead",
          ["npcID"] = 197698,
          ["displayID"] = 106435,
        },
        {
          ["name"] = "Flamegullet",
          ["npcID"] = 197697,
          ["displayID"] = 106023,
        },
      },
      ["roles"] = {
        ["TANK"] = {
          "Blazebound Destroyer — Inferno: Keep the pack stable and leave before Burnout finishes.",
          "Primalist Flamedancer — Flame Dance: Call a hard stop; move out of Blaze of Glory on death.",
          "Thunderhead — Thunder Jaw: Mitigate and preserve a safe knockback lane.",
          "Flamegullet — Fire Maw: Mitigate and face away; its damage-ramp stacks are now capped.",
        },
        ["HEALER"] = {
          "Blazebound Destroyer — Inferno: Prepare group healing for the hit and follow-up damage.",
          "Blazebound Destroyer — Living Bomb: Track the target and leave before Burnout.",
          "Thunderhead — Rolling Thunder: Stagger dispels; heal the second target before expiration.",
          "Flamegullet — Molten Blood: Prepare sustained group healing below 50%; the ramp is capped.",
        },
        ["DPS"] = {
          "Primalist Cinderweaver — Cinderbolt: Interrupt; purge or control Burning Ambition.",
          "Primalist Flamedancer — Flame Dance: Hard stop it; leave Blaze of Glory on death.",
          "Blazebound Destroyer — Burnout: Run out before the death explosion.",
          "Thunderhead — Storm Breath: Sidestep the frontal and personal Rolling Thunder if needed.",
        },
      },
    },
    {
      ["name"] = "Final approach — between bosses 2 & 3",
      ["after"] = "Kokia Blazehoof",
      ["roles"] = {
        ["TANK"] = {
          "Simplified trash: The Season 2 package is substantially reduced; no retained must-kick cast is confirmed. Use normal stops and avoid visible hazards.",
          "Requires live verification: Confirm final spawns, count and any launch-day ability package.",
        },
        ["HEALER"] = {
          "Simplified trash: The Season 2 package is substantially reduced; no retained must-kick cast is confirmed. Use normal stops and avoid visible hazards.",
          "Requires live verification: Confirm final spawns, count and any launch-day ability package.",
        },
        ["DPS"] = {
          "Simplified trash: The Season 2 package is substantially reduced; no retained must-kick cast is confirmed. Use normal stops and avoid visible hazards.",
          "Requires live verification: Confirm final spawns, count and any launch-day ability package.",
        },
      },
    },
  },
  ["bosses"] = {
    {
      ["name"] = "Melidrussa Chillworn",
      ["sheet"] = {
        ["TANK"] = "Kick Frigid Shard. Collect whelps at 66% and 33%, then help break Ice Bulwark. Kick. Gather whelps. Break the shield.",
        ["HEALER"] = "Top before Chillstorm and the 66%/33% shield phases; help damage Ice Bulwark when safe. Top first. Keep the escape lane clear.",
        ["DPS"] = "Place Hailbombs together; swap immediately to whelps and Ice Bulwark. Place ice. Kick. Burn the shield.",
        ["WIPE"] = "Loose whelps or slow Ice Bulwark damage overwhelms the group.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 188252,
      ["displayID"] = 106891,
      ["wipe"] = {
        "Loose whelps or slow Ice Bulwark damage overwhelms the group.",
        "Entering a shield phase unstable while whelps remain loose.",
        "Slow shield damage or loose whelps during the intermission.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Kick Frigid Shard.",
            "Collect whelps at 66% and 33%, then help break Ice Bulwark.",
          },
          ["avoid"] = {
            "Keep a clear path through Hailbombs during the longer, weaker Chillstorm pull.",
            "Do not step on extra eggs before the encounter.",
          },
          ["defensive"] = {
            "Cover whelp pickup and any missed Frigid Shard.",
          },
          ["reminder"] = "Kick. Gather whelps. Break the shield.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Top before Chillstorm and the 66%/33% shield phases.",
            "Help damage Ice Bulwark when safe.",
            "Chillstorm ticks more slowly but lasts longer; recover after Frost Overload.",
          },
          ["avoid"] = {
            "Hailbomb contact now deals little damage but applies a 50% Haste penalty.",
            "Keep an escape route during Chillstorm.",
          },
          ["cooldowns"] = {
            "Cover Frost Overload or a shield phase entered with players low.",
          },
          ["reminder"] = "Top first. Keep the escape lane clear.",
        },
        ["DPS"] = {
          ["job"] = {
            "Place Hailbombs together.",
            "Swap immediately to whelps and Ice Bulwark.",
            "Kick Frigid Shard; whelps and Ice Bulwark before boss damage.",
          },
          ["avoid"] = {
            "Hailbomb contact applies a 50% Haste penalty.",
            "Move early for Chillstorm.",
          },
          ["defensive"] = {
            "Use a personal for Chillstorm or Frost Overload.",
          },
          ["reminder"] = "Place ice. Kick. Burn the shield.",
        },
      },
    },
    {
      ["name"] = "Kokia Blazehoof",
      ["sheet"] = {
        ["TANK"] = "Cover Searing Blows. Place the targeted Firestorm add for clean cleave. Mitigate. Cleave. Follow the endpoint.",
        ["HEALER"] = "Prepare for Inferno while tracking Searing Blows on the tank. Inferno is the check; the tank bleed continues.",
        ["DPS"] = "Place Ritual of Blazebinding using its target rim; swap instantly to the Firestorm add. Add first. Kick. Respect the endpoint.",
        ["WIPE"] = "An early Boulder collision or holding the boss in Burnout.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 189232,
      ["displayID"] = 106851,
      ["wipe"] = {
        "An early Boulder collision or holding the boss in Burnout.",
        "Falling behind on group and tank damage together.",
        "Ignoring the add or detonating Boulder into nearby terrain.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Cover Searing Blows.",
            "Place the targeted Firestorm add for clean cleave.",
          },
          ["avoid"] = {
            "Follow Molten Boulder's direction and displayed final explosion point.",
            "Leave the add before Burnout finishes.",
          },
          ["defensive"] = {
            "Always cover Searing Blows and request help if the bleed becomes unsafe.",
          },
          ["reminder"] = "Mitigate. Cleave. Follow the endpoint.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Prepare for Inferno while tracking Searing Blows on the tank.",
            "Stabilise after Inferno while the tank bleed continues.",
          },
          ["avoid"] = {
            "Use the immediate Boulder endpoint marker; leave Burnout and permanent fire.",
          },
          ["cooldowns"] = {
            "Cover an Inferno overlap or a poorly placed Firestorm add.",
          },
          ["reminder"] = "Inferno is the check; the tank bleed continues.",
        },
        ["DPS"] = {
          ["job"] = {
            "Place Ritual of Blazebinding using its target rim.",
            "Swap instantly to the Firestorm add.",
            "Kick Roaring Blaze; kill the Firestorm before Kokia.",
          },
          ["avoid"] = {
            "Follow the displayed Boulder endpoint and leave before Burnout.",
            "Do not stand in permanent fire.",
          },
          ["defensive"] = {
            "Use a personal for Inferno, especially after a missed cast.",
          },
          ["reminder"] = "Add first. Kick. Respect the endpoint.",
        },
      },
    },
    {
      ["name"] = "Kyrakka and Erkhart Stormvein",
      ["sheet"] = {
        ["TANK"] = "Keep Kyrakka hittable; use the longer landing delay to position before the final phase. Use the landing pause. Protect the path.",
        ["HEALER"] = "Top Inferno Spit targets; use the landing delay to stabilise before the final phase. Top marks. Preserve the path. Move early.",
        ["DPS"] = "Prioritise Kyrakka; use the longer landing delay to reset positioning. Kill Kyrakka. Edge the fire. Reset on landing.",
        ["WIPE"] = "Breath through the group or no safe route through fire.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 190484,
      ["displayID"] = 107137,
      ["wipe"] = {
        "Breath through the group or no safe route through fire.",
        "Low players at Inferno Spit expiration or standing in breath.",
        "Fire through the centre or greed inside breath.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Keep Kyrakka hittable.",
            "Use the longer landing delay to position before the final phase.",
          },
          ["avoid"] = {
            "Face Roaring Firebreath away and do not let wind push you into fire.",
          },
          ["defensive"] = {
            "Cover heavy hits and dangerous Inferno Spit overlaps.",
          },
          ["reminder"] = "Use the landing pause. Protect the path.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Top Inferno Spit targets.",
            "Use the landing delay to stabilise before the final phase.",
            "Prioritise marked players and anyone trapped by fire.",
          },
          ["avoid"] = {
            "Reduced winds move fire more slowly, but keep the centre and safe paths clear.",
          },
          ["cooldowns"] = {
            "Cover overlapping expirations or restricted space.",
          },
          ["reminder"] = "Top marks. Preserve the path. Move early.",
        },
        ["DPS"] = {
          ["job"] = {
            "Prioritise Kyrakka; use the longer landing delay to reset positioning.",
            "No routine boss kick; Kyrakka remains the damage priority.",
          },
          ["avoid"] = {
            "Reduced winds move fire more slowly; still move early for Roaring Firebreath.",
          },
          ["defensive"] = {
            "Use a personal for Inferno Spit expiration or a bad overlap.",
          },
          ["reminder"] = "Kill Kyrakka. Edge the fire. Reset on landing.",
        },
      },
    },
  },
})
