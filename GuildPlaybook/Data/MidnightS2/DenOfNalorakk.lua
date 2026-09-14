-- GENERATED FILE — do not edit by hand.
-- Source: content/midnight-s2/den-of-nalorakk.yaml   (regenerate with tools/generate.py)
local _, ns = ...

ns.RegisterDungeon({
  ["dungeon"] = "Den of Nalorakk",
  ["slug"] = "den-of-nalorakk",
  ["season"] = "midnight-s2",
  ["patch"] = "12.1.0",
  ["sourceVersion"] = "Hotfixes through 11 September 2026",
  ["instanceID"] = nil,
  ["mdtRoutes"] = {
    {
      ["name"] = "Tactyks PUG Friendly - Method/wago.io (Aug 2026)",
      ["string"] = "!~MDT2~hVbLb9xEGJcf632l2aSPdEsBzYVSpGbk8WtsDrRqK0pRgUhNe3fW48SNY2/9aDdCQjtOEByQChcQHJBok1C4c+DWP6BHLogzJxCPw55yQTPeRutF3e5h9/t5Zn6/7/t9n+193MsDb/P9lQ9WryZ39VXjlpeRQZatur1sezMFK7eugbeTgEReuE3uuWFO9kk/D8P0i8cClcRCkqVdWaop8rAzXKRit0sF0ovDOPF9Xye+fyDShkQ7ciHXO7vt1sLi4nC8zlYd8r1AayJtSnRBplJnt9FU6t0urU9w6ORA3KkrNWm31aw3ZNroFMdPLO40W40jIof4/sOFCWV/TSc/iLQtFaeW5KLVVIb1YWPY2T15aun0Im1PZKCTPbnozCu7grh4vPvKcELYIY/FoTRUdmqSXN9R6u1GIcktKlQq8P09Zaeh1BuFUmsWNfnovLOmk4MaFZTi2Fyd1pq03qLi0UF29EdpyF0bHqfCCSqcpEL35WH31WfsLmJJ7LepMFcI4jEqLE1Zu98uJHGOSvM7giidZl8VZ/fbhVybo/I8lU9TuWLo3hytHSskcamQxIqJj05RYdIE5uMBS7J7hgrdl6jQPXuUROlekJKQ9LIgjqiy2cuThETZSh6GSjwGN/O1kNwjoXB3fOFqHq2TOLruDbrfrcdrd0gvSx88dL1P6ocX//2afb4RRn75eX3khp96WIeOv6xbOsQeVqHJYgxRJbZsiFjsQPs5XOdGbvi5xzawfRpU2XmNxSY0qjEqYxva1VjjeliD2nNic0YdnxFk61D3lw3bgYggG0HLXzYcDRpTAPNaDMeE5jTALHvDsZ6rdO5IifNhqBFkq8w/w9GhPQWwXfKpY9kJgFndho2hOrsmbEHDXzawCjFBWOfJYp1TTALL4Qlhi5U+DfQSzOocU1Kh6i8blg0tgjAqT2lQnQYaxAyUhlWAyfpkYPsFfdKQzpuOLIiJhlQ+MZoK1Smg4hKwAv8H2DRqJkQza2JKbHQ0A9pEQ6gEiFFUgOpwPmRz2QrAfBsyoTW7T7rNnUAq81zH3EqmPg1M3k5ksfGYBnwbftHs6WU3xkrjU3ywq8Dm3UC8NVXAC2Sy2qznAi8e+8u6abM+qQYbKnZno2mgPXt+zJ4wTeX3BuMrKXR2Sh2TT4BSlvFNA5sVqFsGz/zjw0vhEvrr7w8vHT7JDv75/Y/XLgqjgXFlww0iEERZDPJ+nySg7/Y2wf0NEoF+Qu4FcZ6CjEQeSVLgJgR4xPXcaFQSfiT9eeGXy7cPn5Df3n3w5re/CqOB816QpkG0DjKSJC5I8q21kCQgiMA1w7wAEtIP3R7xwP0g2wDXTB34cQJ6cR5lR6zv6D+fb1358vBJ+pPknP3qqTAavHUjTzPAXvUAXSh/bRAnAKljhExwnlOWyHiDrd5w0wysxWnqRqOglxA3I97l7Ude5G6R9fF/CpIQN9wKbmZxspW462SjF7ppet0btO94ge8HvTzMtpdC1/Pi6DZJ0iCOzoh5n791VtyQZBm5Hvnxw9DNs/gKuxpE66O4su4N5P8A",
    },
  },
  ["quicksheet"] = {
    ["trash"] = {
      ["TANK"] = "Keen-Eyed Striker — [Piercing Screech]: group and stop.; Keen-Eyed Striker — [Scavenge]: priority interrupt; steals a required offering.; Spirit of Hunger — [Starvation Effigy]: tank beside it.; The Winter Squall — [Harsh Winds]: keep shelter close.; Grizzled Warbringer — [Poison Spear Volley]: keep space clear.; Grizzled Warbringer — [Primal Echo]: mitigate.",
      ["HEALER"] = "Keen-Eyed Striker — [Piercing Screech]: pre-position for silence.; Keen-Eyed Striker — [Scavenge]: priority interrupt; steals a required offering.; Spirit of Hunger — [Starvation Effigy]: kill it; maximum health falls.; The Winter Squall — [Harsh Winds]: heal while moving.; Grizzled Warbringer — [Poison Spear Volley]: prepare for missed circles.; Grizzled Warbringer — [Primal Echo]: react quickly.",
      ["DPS"] = "Keen-Eyed Striker — [Piercing Screech]: interrupt / stop.; Keen-Eyed Striker — [Scavenge]: interrupt beside the offerings.; Spirit of Hunger — [Starvation Effigy]: kill immediately.; The Winter Squall — [Harsh Winds]: kill first.; Grizzled Warbringer — [Poison Spear Volley]: dodge circles.; Grizzled Warbringer — [Primal Echo]: use a personal.",
      ["ROUTE"] = "Foraging > Hoardmonger > Winter > Sentinel > Heart of Rage > Nalorakk.",
    },
  },
  ["overview"] = {
    ["interrupts"] = {
      {
        ["spell"] = "Piercing Screech",
        ["note"] = "interrupt / stop",
      },
      {
        ["spell"] = "Healing Breeze",
        ["note"] = "heals nearby enemies (Earthwhisper Tender)",
      },
      {
        ["spell"] = "Frigid Roar",
        ["note"] = "heavy group damage (Frigid Mauler)",
      },
      {
        ["spell"] = "Arc Lightning",
        ["note"] = "repeated group damage (Stormbound Mystic)",
      },
      {
        ["spell"] = "Scavenge",
        ["note"] = "steals a required offering (Keen-Eyed Striker)",
      },
    },
    ["killPriority"] = {
      "[Piercing Screech]",
      "[Starvation Effigy]",
      "The Winter Squall",
      "[Rumbling Ward]",
      "[Magma Totem]",
      "Volatile Totems",
    },
    ["tank"] = {
      ["damage"] = {
        "Tank checks: empowered Hoardmonger, [Frozen Tempest], [Primal Echo] and [Overwhelming Onslaught].",
      },
      ["pullWarnings"] = {
        "Pull plan: do not combine unknown PTR packs or difficult patrols until live-tested.",
        "Positioning: face large enemies away and preserve shelter during the winter gauntlet.",
        "Control priority: [Piercing Screech], [Starvation Effigy] and dangerous Heart of Rage packs.",
      },
    },
    ["healer"] = {
      ["dispels"] = {
        "Dispel: [Mother's Wrath] is confirmed dispellable; current PTR removes all stacks.",
        "Curse-dispel: [Insatiable Hunger] during Spirit of Hunger's [Feast of Misery].",
        "Dispel: [Glacial Torment] (Sentinel of Winter) promptly; a dangerous dispellable DoT.",
      },
      ["pressure"] = {
        "Healing checks: Hoardmonger roars, [Frozen Tempest], [Primal Echo] and [Fury of the War God].",
      },
      ["pullWarnings"] = {
        "Silence warning: [Piercing Screech] silences the party for 2 seconds.",
        "Mana: avoid healing through [Starvation Effigy]; the group must kill it.",
      },
    },
    ["dps"] = {
      ["defensives"] = {
        "Movement: dodge [Poison Spear Volley] and keep clean shelter routes in the winter gauntlet.",
        "Personal defensives: boss roars, [Frozen Tempest] and difficult Fury sequences.",
        "Use a personal for [Hearty Bellow] or when carrying several [Toxic Spores] stacks.",
      },
      ["pullWarnings"] = {
        "Keen-Eyed Striker — [Razor Dive]: The cast is less frequent after the PTR cooldown increase; use a defensive if repeatedly targeted.",
        "Keen-Eyed Striker — [Scavenge]: Interrupt beside the offerings to protect them.",
        "Spirit of Hunger — [Starvation Effigy]: Immediate swap: kill the [Starvation Effigy] before health reduction stacks.",
        "Territorial Matriarch — [Mother's Wrath]: Use a stop if available and give the healer room to dispel.",
        "The Winter Squall — [Harsh Winds]: Priority target. Kill The Winter Squall to end [Harsh Winds].",
        "Glacial Revenant — [Cryo Surge]: Loosely spread; remove the magic debuff if able.",
        "Frigid Mauler — [Frigid Roar]: Assign a kick and stay in range.",
        "Terra Rumbler — [Rumbling Ward]: Priority swap until the shield breaks.",
        "Grizzled Warbringer — [Poison Spear Volley]: Move out of impact circles; current PTR travel time is 3 seconds.",
        "Grizzled Warbringer — [Primal Echo]: Use a personal if targeted and avoid adding spear damage.",
        "Bonded Beasttamer — [Bestial Wrath]: Live cast confirmed; no DPS-specific call in the current docs.",
        "Loyal Saberfang — Fixate (cast name unconfirmed): Priority kill; targeted player kites without crossing the group.",
        "Loa Speaker Nanea — [Volatile Totem]: Immediate swap to Volatile Totems. Exact release behaviour requires live verification.",
        "Loa Speaker Nanea — [Earthquake]: Place at the edge; kill Volatile Totems.",
      },
    },
    ["tip"] = {
      "Mechanics beat uptime: clear mushrooms, soak [Rimeshatter] and place echoes outside.",
      "Midnight Season 2, Patch 12.1, hotfixes through 11 September 2026; supersedes PTR Draft 0.10 (9 August 2026). Biggest live change: the PTR-era 1-second pre-charge window on Nalorakk's echoes and the Onslaught knockback reduction are no longer documented; the Healer guide now requires healing Onslaught's three protected hits instead (mechanism unconfirmed).",
      "Still needs live confirmation: whether [Mother's Wrath] is dispellable or soothe-only, whether Loyal Saberfang's Fixate still exists alongside [Shred Armor], The Hoardmonger's mushroom naming, and Nalorakk's three protected hits during [Overwhelming Onslaught].",
      "Collect six Food Offerings to summon The Hoardmonger.",
      "Hotfix: Food Offerings now recover correctly after mounted interaction.",
      "Druid in Bear Form or 25+ Midnight Alchemy: activate Warding Incense for 5% Versatility for 10 minutes; the second altar refreshes it.",
      "Night Elf, Troll, or Druid in Bear Form: Snowworn Provisions grant Rune of Anchoring, reducing forced movement by 50% for 15 minutes.",
      "Seasonal affixes: Lindormi's Guidance applies at keys +2–4; Xal'atath's Bargains begin at +5 — adapt utility to the active weekly bargain.",
      "Hotfix: player pets can now damage The Winter Squall.",
      "Hotfix: Nalorakk — [Echoing Maul] no longer triggers unintentionally.",
    },
  },
  ["trashSegments"] = {
    {
      ["name"] = "Opening trash — The Foraging",
      ["after"] = nil,
      ["npcs"] = {
        {
          ["name"] = "Keen-Eyed Striker",
          ["npcID"] = nil,
          ["displayID"] = 124212,
        },
        {
          ["name"] = "Spirit of Hunger",
          ["npcID"] = 245855,
          ["displayID"] = 26857,
        },
        {
          ["name"] = "Territorial Matriarch",
          ["npcID"] = 241808,
          ["displayID"] = 14316,
        },
        {
          ["name"] = "Earthwhisper Tender",
          ["npcID"] = 241814,
          ["displayID"] = 128080,
        },
        {
          ["name"] = "Thornclaw Gatherer",
          ["npcID"] = 241813,
          ["displayID"] = 141213,
        },
      },
      ["roles"] = {
        ["TANK"] = {
          "Keen-Eyed Striker — [Piercing Screech]: Group it tightly; the cast damages and silences the party for 2 seconds.",
          "Keen-Eyed Striker — [Razor Dive]: The 28 July PTR increased its cooldown; still watch repeated dives and the stacking bleed.",
          "Keen-Eyed Striker — [Scavenge]: Priority interrupt; steals a required offering.",
          "Spirit of Hunger — [Starvation Effigy]: Keep the pack near the effigy so the group can swap immediately.",
          "Spirit of Hunger — [Feast of Misery]: Avoid stacking this miniboss with another heavy group check.",
          "Territorial Matriarch — [Mother's Wrath]: Expect rising pressure while stacks remain; soothe after cub deaths, or use a major defensive.",
          "Earthwhisper Tender — [Healing Breeze]: Heals nearby enemies; priority interrupt.",
          "Keep early pulls controlled: two fewer Earthwhisper Tenders are present after the 26 August hotfix.",
          "Thornclaw Gatherer — [Shredding Claws]: Mitigate stacks; kite before armour collapses.",
        },
        ["HEALER"] = {
          "Keen-Eyed Striker — [Piercing Screech]: Pre-position before the silence; do not begin a long cast as Screech completes.",
          "Keen-Eyed Striker — [Razor Dive]: The cast is less frequent after the PTR change; track and stabilise the stacking bleed.",
          "Keen-Eyed Striker — [Scavenge]: Priority interrupt; steals a required offering.",
          "Spirit of Hunger — [Starvation Effigy]: Maximum health falls while the effigy lives; do not try to heal through it.",
          "Spirit of Hunger — [Feast of Misery]: Pre-heal the channel; curse-dispel [Insatiable Hunger].",
          "Territorial Matriarch — [Mother's Wrath]: Dispel [Mother's Wrath]; the current PTR removes all stacks; expect rising tank damage after cub deaths.",
          "Earthwhisper Tender — [Healing Breeze]: Call the kick; purge the heal if it lands.",
        },
        ["DPS"] = {
          "Keen-Eyed Striker — [Piercing Screech]: Top stop priority. Interrupt or crowd-control the party-wide silence.",
          "Keen-Eyed Striker — [Razor Dive]: The cast is less frequent after the PTR change; use a defensive if repeatedly targeted.",
          "Keen-Eyed Striker — [Scavenge]: Interrupt beside the offerings; use a personal for [Razor Dive] if repeatedly targeted.",
          "Spirit of Hunger — [Starvation Effigy]: Immediate swap. Kill the effigy before maximum-health reduction stacks.",
          "Territorial Matriarch — [Mother's Wrath]: Stop the cast where possible and give the healer room to dispel; soothe after cub deaths if your class can.",
          "Earthwhisper Tender — [Healing Breeze]: Highest kick; purge if missed.",
        },
      },
    },
    {
      ["name"] = "Winter gauntlet — after The Hoardmonger",
      ["after"] = "The Hoardmonger",
      ["npcs"] = {
        {
          ["name"] = "The Winter Squall",
          ["npcID"] = 250478,
          ["displayID"] = 138885,
        },
        {
          ["name"] = "Glacial Revenant",
          ["npcID"] = 241876,
          ["displayID"] = 103213,
        },
        {
          ["name"] = "Frigid Mauler",
          ["npcID"] = 241872,
          ["displayID"] = 141288,
        },
        {
          ["name"] = "Terra Rumbler",
          ["npcID"] = 241911,
          ["displayID"] = 35201,
        },
        {
          ["name"] = "Avatar of Determination",
          ["npcID"] = 241869,
          ["displayID"] = 128095,
        },
        {
          ["name"] = "Frostfang",
          ["npcID"] = 241874,
          ["displayID"] = 141223,
        },
      },
      ["roles"] = {
        ["TANK"] = {
          "The Winter Squall — [Harsh Winds]: Pull deliberately and keep the group near shelter; killing the Squall ends [Harsh Winds].",
          "Glacial Revenant — [Cryo Surge]: Live cast confirmed; no tank-specific call in the current docs.",
          "Terra Rumbler — [Rumbling Ward]: Keep it in cleave and break the shield quickly.",
          "Frigid Mauler — [Frigid Roar]: Heavy group damage; priority interrupt.",
          "Frostfang — [Bloodrush]: Stabilise the pull for its dangerous first 10 seconds.",
          "Avatar of Determination — [Pulverize]: Move the pack out of the impact area.",
        },
        ["HEALER"] = {
          "The Winter Squall — [Harsh Winds]: Heal while moving between shelter; the effect ends when the Squall dies.",
          "Glacial Revenant — [Cryo Surge]: Dispellable splash debuff; magic-dispel promptly and keep the target away from allies.",
          "Terra Rumbler — [Rumbling Ward]: Heal pulses until DPS breaks the ward.",
          "Frigid Mauler — [Frigid Roar]: Heavy group damage; priority interrupt.",
          "Avatar of Determination — [Glacial Tomb]: Freedom or help break rooted players.",
        },
        ["DPS"] = {
          "The Winter Squall — [Harsh Winds]: Priority target. Kill the Squall to stop [Harsh Winds].",
          "Glacial Revenant — [Cryo Surge]: Loosely spread; remove the magic debuff if able.",
          "Frigid Mauler — [Frigid Roar]: Assign a kick and stay in range.",
          "Terra Rumbler — [Rumbling Ward]: Priority swap until the shield breaks.",
        },
      },
    },
    {
      ["name"] = "Heart of Rage — after Sentinel of Winter",
      ["after"] = "Sentinel of Winter",
      ["npcs"] = {
        {
          ["name"] = "Grizzled Warbringer",
          ["npcID"] = nil,
          ["displayID"] = nil,
        },
        {
          ["name"] = "Bonded Beasttamer",
          ["npcID"] = 245145,
          ["displayID"] = 129581,
        },
        {
          ["name"] = "Loyal Saberfang",
          ["npcID"] = 245190,
          ["displayID"] = 124949,
        },
        {
          ["name"] = "Loa Speaker Nanea",
          ["npcID"] = 244889,
          ["displayID"] = 138584,
        },
        {
          ["name"] = "Stormbound Mystic",
          ["npcID"] = 245139,
          ["displayID"] = 129562,
        },
        {
          ["name"] = "Ruthless Totemcaller",
          ["npcID"] = 245143,
          ["displayID"] = 129563,
        },
      },
      ["roles"] = {
        ["TANK"] = {
          "Grizzled Warbringer — [Poison Spear Volley]: Keep the area readable; impacts land after a 3-second travel time.",
          "Grizzled Warbringer — [Primal Echo]: Use mitigation during the short, intense damage-over-time window.",
          "Bonded Beasttamer — [Bestial Wrath]: Enrages the beast and handler. Control it with its bonded beast. [Overwhelmed Prey] was removed.",
          "Loyal Saberfang — Fixate (cast name unconfirmed): Help control its path while it pursues a non-tank player.",
          "Loyal Saberfang — [Shred Armor]: Stacking armour reduction; overlaps with Bonded Beasttamer — [Bestial Wrath] — soothe or kite.",
          "Loa Speaker Nanea — [Volatile Totem]: Position Nanea so the group can reach spawned totems.",
          "Loa Speaker Nanea — [Earthquake]: Hold mobs outside placed zones; kill Volatile Totems.",
          "Stormbound Mystic — [Arc Lightning]: Repeated group damage; priority interrupt.",
          "Ruthless Totemcaller — [Magma Totem]: Persistent group damage; priority target.",
        },
        ["HEALER"] = {
          "Grizzled Warbringer — [Poison Spear Volley]: Prepare for avoidable party damage if players are slow to move.",
          "Grizzled Warbringer — [Primal Echo]: React quickly to the short, high periodic-damage window.",
          "Bonded Beasttamer — [Bestial Wrath]: Expect a sharp tank spike; soothe if available.",
          "Loyal Saberfang — Fixate (cast name unconfirmed): Keep the pursued player stable.",
          "Loa Speaker Nanea — [Volatile Totem]: Prepare for damage if a totem is not removed quickly.",
          "Loa Speaker Nanea — [Volatile Totem]: Heal escalating pulses until the totem dies.",
          "Stormbound Mystic — [Arc Lightning]: Repeated group damage; priority interrupt.",
          "Ruthless Totemcaller — [Magma Totem]: Persistent group damage; priority target.",
        },
        ["DPS"] = {
          "Grizzled Warbringer — [Poison Spear Volley]: Move out of impact circles; current travel time is 3 seconds.",
          "Grizzled Warbringer — [Primal Echo]: Use a personal if targeted and avoid adding spear damage.",
          "Bonded Beasttamer — [Bestial Wrath]: Live cast confirmed; no DPS-specific call in the current docs.",
          "Loyal Saberfang — Fixate (cast name unconfirmed): Priority kill; the targeted player kites without crossing the group.",
          "Loa Speaker Nanea — [Volatile Totem]: Immediate swap to Volatile Totems; exact release behaviour requires live verification.",
          "Loa Speaker Nanea — [Earthquake]: Place at the edge; kill Volatile Totems.",
          "Stormbound Mystic — [Arc Lightning]: Highest kick; use spare kicks on [Lightning Bolt].",
          "Ruthless Totemcaller — [Magma Totem]: Swap immediately.",
        },
      },
    },
  },
  ["bosses"] = {
    {
      ["name"] = "The Hoardmonger",
      ["sheet"] = {
        ["TANK"] = "Control the pile > face slams away > keep the arena clear.",
        ["HEALER"] = "Heal the roar > watch mushroom cleaners > limit spore stacks.",
        ["DPS"] = "Clear mushrooms safely > dodge slams > defensive the roar.",
        ["WIPE"] = "Uncleared [Rotten Mushrooms] burst and apply [Toxic Spores] to the party.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 248710,
      ["displayID"] = 129344,
      ["wipe"] = {
        "Uncleared [Rotten Mushrooms] burst and apply [Toxic Spores] to the party.",
        "Multiple spore stacks plus a roar can overwhelm the group.",
        "Untouched [Rotten Mushrooms] trigger [Putrid Burst], applying party-wide [Toxic Spores]; call missed mushrooms early.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Control which resource pile the boss reaches at 90%, 60% and 30%.",
            "Face [Earthshatter Slam] and [Bonespike Slam] away.",
            "Move early as mushrooms and spikes reduce space.",
          },
          ["avoid"] = {
            "Both frontal slams.",
            "Bone spikes and unnecessary [Toxic Spores] stacks.",
          },
          ["defensive"] = {
            "Mitigate [Ravenous Bellow].",
            "Use stronger protection when [Hearty Bellow] is active.",
          },
          ["reminder"] = "Control the pile > face slams away > keep the arena clear.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Prepare for [Ravenous Bellow].",
            "Track [Toxic Spores] on mushroom-clearing players.",
            "Keep the tank stable while the boss repositions.",
            "[Hearty Bellow] adds an initial hit and follow-up group damage.",
            "Stabilise one mushroom-clearing player at a time.",
          },
          ["avoid"] = {
            "Both frontals, bone spikes and clearing several mushrooms together.",
          },
          ["cooldowns"] = {
            "Use a healing cooldown when a later roar overlaps [Toxic Spores] or [Hearty Bellow].",
          },
          ["reminder"] = "Heal the roar > watch mushroom cleaners > limit spore stacks.",
        },
        ["DPS"] = {
          ["job"] = {
            "Destroy or safely trigger [Rotten Mushrooms] before they burst.",
            "Maintain damage while the tank guides the boss to a resource pile.",
            "[Rotten Mushrooms] are the priority mechanic; clear them before [Putrid Burst].",
            "Ranged: Spread around the room and cover distant [Rotten Mushrooms].",
            "Ranged: Claim a sector.",
          },
          ["avoid"] = {
            "[Earthshatter Slam], [Bonespike Slam] and bone spikes.",
            "Running through multiple mushrooms.",
          },
          ["defensive"] = {
            "Use a personal for a roar overlapping [Toxic Spores].",
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
        ["WIPE"] = "An unsoaked [Rimeshatter] causes party damage and a root.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 261053,
      ["displayID"] = 129418,
      ["wipe"] = {
        "An unsoaked [Rimeshatter] causes party damage and a root.",
        "Missing [Rimeshatter] or entering the storm low can collapse the party.",
        "A missed [Rimeshatter] causes [Rime Detonation] and a party root.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Keep the boss central so the party can reach the [Frozen Tempest] safe zone.",
            "Group Fractured Shivercores and preserve useful Snowdrifts.",
          },
          ["avoid"] = {
            "[Raging Squalls] and [Rimeshatter] impact zones assigned to another player.",
            "Sidestep [Shattering Frostspike] circles.",
          },
          ["defensive"] = {
            "Enter the 10-yard inner safe zone and mitigate [Frozen Tempest].",
          },
          ["reminder"] = "Centre the boss > preserve Snowdrifts > move inside.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Pre-heal [Frozen Tempest] while moving into the safe zone.",
            "Cover ramping [Glacial Torment] and [Winter's Shroud] pressure.",
            "Dispel [Glacial Torment] promptly; stabilise players you cannot dispel.",
            "Stabilise players assigned to [Rimeshatter].",
            "Keep the party healthy before [Frozen Tempest] starts.",
          },
          ["avoid"] = {
            "[Raging Squalls] and becoming isolated before the storm.",
          },
          ["cooldowns"] = {
            "Use a healing cooldown during [Frozen Tempest].",
          },
          ["reminder"] = "Pre-heal > move inside > cover the Frost damage.",
        },
        ["DPS"] = {
          ["job"] = {
            "Swap to Fractured Shivercores.",
            "Soak assigned [Rimeshatter] impacts.",
            "Move inside the boss's 10-yard safe zone for [Frozen Tempest].",
            "Fractured Shivercores are the priority target; swap quickly and kick [Winter's Shroud].",
          },
          ["avoid"] = {
            "[Raging Squalls] and unassigned [Rimeshatter] zones.",
            "Stay out of [Shattering Frostspike] circles and tornadoes.",
          },
          ["defensive"] = {
            "Use a personal during [Frozen Tempest] or high Frost vulnerability.",
          },
          ["reminder"] = "Kill cores > soak fragment > get inside.",
        },
      },
    },
    {
      ["name"] = "Nalorakk",
      ["sheet"] = {
        ["TANK"] = "Use Zul'jarra's cover > 1-second lane check > intercept echoes.",
        ["HEALER"] = "Pre-heal Fury > use the 1-second window > heal interceptors.",
        ["DPS"] = "Drop outside > take your lane in 1 second > intercept once.",
        ["WIPE"] = "Zul'jarra — [Demoralizing Scream] stacks if [Forceful Slam] or an echo reaches her.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 258877,
      ["displayID"] = 125154,
      ["wipe"] = {
        "Zul'jarra — [Demoralizing Scream] stacks if [Forceful Slam] or an echo reaches her.",
        "Repeated failures to protect Zul'jarra create escalating party damage.",
        "Poorly placed echoes repeat [Echoing Maul] and can make the arena unusable.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Stand behind Zul'jarra for [Overwhelming Onslaught]; its PTR knockback is 50% lower, but the protection remains required.",
            "Keep [Echoing Maul] placements away from the centre.",
            "Echoes now wait 1 second before charging — use that window to help assign separate echo-interception lanes during [Fury of the War God].",
          },
          ["avoid"] = {
            "Stored [Echoing Maul] locations and unsafe [Forceful Slam] angles.",
            "Do not point the shield lane toward an Echo of Nalorakk — [Spectral Slash] zone.",
          },
          ["defensive"] = {
            "Mitigate [Overwhelming Onslaught] and [Forceful Slam].",
            "Use a group defensive for difficult Fury sequences.",
            "Use a personal when blocking an echo's [Echoing Fury].",
          },
          ["reminder"] = "Use Zul'jarra's cover > 1-second lane check > intercept echoes.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Keep echo interceptors healthy during [Fury of the War God].",
            "Prepare for [Overwhelming Onslaught] as a group mechanic; its knockback is 50% lower on the current PTR.",
            "Track the arena before each [Echoing Maul].",
            "Recover the party quickly if an echo reaches Zul'jarra.",
            "Current PTR: Fury interceptors no longer receive [Spectral Slash] from the intercepted echo.",
            "Use the new 1-second pre-charge window on Fury echoes to confirm lanes and prepare recovery.",
            "Heal its three protected hits during [Overwhelming Onslaught].",
          },
          ["avoid"] = {
            "Stored [Echoing Maul] locations and duplicate interceptions.",
          },
          ["cooldowns"] = {
            "Use a healing cooldown during Fury; save recovery for a failed interception.",
          },
          ["reminder"] = "Pre-heal Fury > use the 1-second window > heal interceptors.",
        },
        ["DPS"] = {
          ["job"] = {
            "Place [Echoing Maul] at an outside edge.",
            "Intercept one assigned echo during [Fury of the War God]; echoes now wait 1 second before charging, so take your lane during that window.",
            "Return without crossing stored echoes.",
            "No boss interrupt priority confirmed; mechanic execution is the priority.",
          },
          ["avoid"] = {
            "Overlapping Maul markers and standing near stored echoes when they repeat.",
            "Keep casting lanes outside Echo of Nalorakk's [Spectral Slash] range.",
          },
          ["defensive"] = {
            "Use a personal before a dangerous Fury or Onslaught sequence.",
            "Use a personal when intercepting Echo of Nalorakk's [Echoing Fury].",
          },
          ["reminder"] = "Drop outside > take your lane in 1 second > intercept once.",
        },
      },
    },
  },
})
