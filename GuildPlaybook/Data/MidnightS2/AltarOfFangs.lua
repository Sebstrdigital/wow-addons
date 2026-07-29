-- GENERATED FILE — do not edit by hand.
-- Source: content/midnight-s2/altar-of-fangs.yaml   (regenerate with tools/generate.py)
local _, ns = ...

ns.RegisterDungeon({
  ["dungeon"] = "Altar of Fangs",
  ["slug"] = "altar-of-fangs",
  ["season"] = "midnight-s2",
  ["patch"] = "12.1.0",
  ["sourceVersion"] = "0.5",
  ["instanceID"] = nil,
  ["quicksheet"] = {
    ["trash"] = {
      ["TANK"] = "High Evolutionist — Evolve: Interrupt first; group the pack for stops.; Ravenous Descendant — attack-speed stacks: Plan mitigation as damage ramps; live cast-name check.; Caustic Mist Totem — Destroy: Keep the interaction accessible.",
      ["HEALER"] = "High Evolutionist — Evolve: Call the interrupt; failed casts increase pull pressure.; Ravenous Descendant — attack-speed stacks: Expect rising tank damage; live cast-name check.; Caustic Mist Totem — Destroy: Cover the group during the interaction.",
      ["DPS"] = "High Evolutionist — Evolve: Must interrupt.; Ravenous Descendant — attack-speed stacks: Focus or control before the damage ramp.; Caustic Mist Totem — Destroy: Complete the interaction.",
      ["ROUTE"] = "Opening > Rav'i > Mutation Chambers > The Writhing Coil > Altar Ascent > Zul'jan",
    },
  },
  ["overview"] = {
    ["interrupts"] = {
      {
        ["spell"] = "Evolve",
        ["note"] = "High Evolutionist — interrupt first",
      },
      {
        ["spell"] = "Toxic Atrophy",
        ["note"] = "The Writhing Coil — interrupt first",
      },
    },
    ["killPriority"] = {
      "Rav'i feeding shield",
      "fixating snakes",
      "dangerous casters",
    },
    ["tank"] = {
      ["damage"] = {
        "Ravenous Descendant stacks",
        "Hydrastrike",
        "Tail Scythe",
        "Chop Down",
      },
      ["pullWarnings"] = {
        "Do not combine evolving enemies without an interrupt plan.",
      },
    },
    ["healer"] = {
      ["pressure"] = {
        "Fetid Roar",
        "Synchronized Venom",
        "Fang Empowered",
      },
    },
    ["dps"] = {
      ["defensives"] = {
        "Stop Evolve and Toxic Atrophy.",
        "Priority mechanics before uptime.",
        "Personal for roar, venom and movement overlaps.",
      },
      ["pullWarnings"] = {
        "Ravenous Descendant — attack-speed stacks: Focus or control before the damage ramp becomes dangerous.",
        "Caustic Mist Totem — Destroy: Complete the interaction; damage no longer interrupts it on PTR.",
        "Ascendant Serpent — live verification required: Use spare stops only after Evolve is covered.",
        "Altar ascent pack — live verification required: Confirm final kick, stop and kill order on live.",
      },
    },
    ["tip"] = {
      "Tank: Save movement for Vine Grip and keep frontals away from allies.",
      "Healer: Track Ritual Venom timers, not only player health.",
      "DPS: Assign beams on Zul'jan before the pull.",
    },
  },
  ["bosses"] = {
    {
      ["name"] = "Rav'i",
      ["sheet"] = {
        ["TANK"] = "Correct pile > break shield > catch meat > survive roar.",
        ["HEALER"] = "Track Triple Shot > catch meat > prepare for roar.",
        ["DPS"] = "Break shield fast and catch your meat.",
        ["WIPE"] = "Long feeding adds Stuffed stacks and makes Fetid Roar lethal.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 259445,
      ["displayID"] = 144110,
      ["wipe"] = {
        "Long feeding adds Stuffed stacks and makes Fetid Roar lethal.",
        "Uncaught meat plus a delayed shield break stacks two healing checks.",
        "Uncaught meat damages everyone; a slow shield break strengthens the roar.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Guide Rav'i to the safest carrion pile.",
            "Mitigate Hydrastrike.",
            "Break the feeding shield.",
          },
          ["avoid"] = {
            "Regurgitate waves.",
            "Triple Shot targets.",
            "Unplanned movement before feeding.",
          },
          ["defensive"] = {
            "Use mitigation for Hydrastrike and a defensive for Scent of Blood or a strong Fetid Roar.",
          },
          ["reminder"] = "Correct pile > break shield > catch meat > survive roar.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Track Triple Shot, stabilise feeding damage and catch meat when safe.",
            "Heal Triple Shot targets, the tank during Scent of Blood and the group before Fetid Roar.",
          },
          ["avoid"] = {
            "Regurgitate waves.",
            "Triple Shot overlaps.",
            "Unplanned meat impacts.",
          },
          ["cooldowns"] = {
            "Use a healing cooldown if feeding lasts too long; personal for a strong Fetid Roar.",
          },
          ["reminder"] = "Track Triple Shot > catch meat > prepare for roar.",
        },
        ["DPS"] = {
          ["job"] = {
            "Break the feeding shield immediately.",
            "Catch assigned meat.",
            "Spread for Triple Shot.",
            "Feeding shield first; catching meat is worth more than boss uptime.",
          },
          ["avoid"] = {
            "Regurgitate waves.",
            "Triple Shot overlaps.",
            "Multiple meat impacts.",
          },
          ["defensive"] = {
            "Use a personal during feeding or a high-stack Fetid Roar.",
          },
          ["reminder"] = "Break shield fast and catch your meat.",
        },
      },
    },
    {
      ["name"] = "The Writhing Coil",
      ["sheet"] = {
        ["TANK"] = "Save movement > pull together > stop Toxic Atrophy.",
        ["HEALER"] = "Move first > heal while moving > stop Toxic Atrophy.",
        ["DPS"] = "Movement ready. Run immediately.",
        ["WIPE"] = "Moving late or not far enough fails the Death Rattle pull.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 259446,
      ["displayID"] = 144156,
      ["wipe"] = {
        "Moving late or not far enough fails the Death Rattle pull.",
        "Death Rattle cannot be healed indefinitely.",
        "One late player can prevent enough distance being created.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Face away, mitigate Tail Scythe, stop Toxic Atrophy and move immediately with Vine Grip.",
          },
          ["avoid"] = {
            "Burrowing Charge.",
            "Venom Jet.",
            "Undermining.",
            "Frontals through allies.",
          },
          ["defensive"] = {
            "Use mitigation for Tail Scythe; defensive for delayed Death Rattle or Synchronized Venom.",
          },
          ["reminder"] = "Save movement > pull together > stop Toxic Atrophy.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Move immediately with Vine Grip.",
            "Heal Death Rattle while moving.",
            "Watch fixated players.",
            "Heal Death Rattle ramp, Synchronized Venom and fixated players.",
          },
          ["avoid"] = {
            "Burrowing Charge.",
            "Venom Jet.",
            "Undermining knock-ups.",
          },
          ["cooldowns"] = {
            "Save movement for Vine Grip; cooldown if the group is slow to uncoil.",
          },
          ["reminder"] = "Move first > heal while moving > stop Toxic Atrophy.",
        },
        ["DPS"] = {
          ["job"] = {
            "Stop Toxic Atrophy, move directly away with Vine Grip and focus fixating snakes.",
            "The Writhing Coil — Toxic Atrophy; fixating snakes during Uncoil.",
          },
          ["avoid"] = {
            "Burrowing Charge.",
            "Venom Jet.",
            "Undermining.",
            "Tank-facing side in melee.",
          },
          ["defensive"] = {
            "Use a personal for delayed Death Rattle or Synchronized Venom.",
          },
          ["reminder"] = "Movement ready. Run immediately.",
        },
      },
    },
    {
      ["name"] = "Zul'jan",
      ["sheet"] = {
        ["TANK"] = "Soak beam > clear venom > dodge axes.",
        ["HEALER"] = "Track beam soaks and venom timers.",
        ["DPS"] = "Soak > clear > reposition.",
        ["WIPE"] = "Ignored beams empower Zul'jan; uncleared Ritual Venom bursts lethally.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 259447,
      ["displayID"] = 145435,
      ["wipe"] = {
        "Ignored beams empower Zul'jan; uncleared Ritual Venom bursts lethally.",
        "On Mythic, Ritual Venom stacks and bursts when it expires uncleared.",
        "Repeated soaking without clearing creates lethal venom stacks.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Face away, mitigate both Chop Down hits, soak an assigned beam and clear Ritual Venom.",
          },
          ["avoid"] = {
            "Axegrinder.",
            "Boneslicer's path.",
            "Blood pools.",
            "Turning the boss into allies.",
          },
          ["defensive"] = {
            "Use strong mitigation for Chop Down and a personal while soaking.",
          },
          ["reminder"] = "Soak beam > clear venom > dodge axes.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Heal beam interceptors, track Ritual Venom and confirm it clears through Bloodletting.",
            "Heal Fang Empowered damage, Boneslicer targets and players deliberately clearing venom.",
          },
          ["avoid"] = {
            "Axegrinder.",
            "Boneslicer's path.",
            "Blood pools.",
          },
          ["cooldowns"] = {
            "Plan healing around beam phases and Fang Empowered; personal while soaking.",
          },
          ["reminder"] = "Track beam soaks and venom timers.",
        },
        ["DPS"] = {
          ["job"] = {
            "Soak your assigned beam, track Ritual Venom and clear it with a physical mechanic.",
            "Beam assignment and venom clearing first; ranged keep beam lanes open; melee avoid the front.",
          },
          ["avoid"] = {
            "Axegrinder.",
            "Boneslicer unless clearing.",
            "Blood pools.",
            "The boss's front.",
          },
          ["defensive"] = {
            "Use a personal while soaking or deliberately clearing venom.",
          },
          ["reminder"] = "Soak > clear > reposition.",
        },
      },
    },
  },
})
