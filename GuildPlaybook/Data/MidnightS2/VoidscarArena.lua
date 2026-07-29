-- GENERATED FILE — do not edit by hand.
-- Source: content/midnight-s2/voidscar-arena.yaml   (regenerate with tools/generate.py)
local _, ns = ...

ns.RegisterDungeon({
  ["dungeon"] = "Voidscar Arena",
  ["slug"] = "voidscar-arena",
  ["season"] = "midnight-s2",
  ["patch"] = "12.1.0",
  ["sourceVersion"] = "0.9",
  ["instanceID"] = nil,
  ["quicksheet"] = {
    ["trash"] = {
      ["TANK"] = "Raj'kess the Spellstorm — Thundering Storm: Hold the pack steady; leave room for targeted strikes.; Watchful Harrower — Live Verification: Use a conservative pull size; this is a high-health true-sight miniboss.; Devouring Brutalizer — Devour: Protect and help free the target before the cast completes.; Brutal Overseer — Brutal Slam: Mitigate the tank hit and DoT.",
      ["HEALER"] = "Raj'kess the Spellstorm — Thundering Storm: Prepare spot healing for targeted strikes.; Watchful Harrower — Live Verification: Expect a long, high-pressure miniboss pull.; Devouring Brutalizer — Devour: Keep the target stable while the group breaks it free.; Brutal Overseer — Brutal Slam: Prepare focused tank healing for the hit and DoT.",
      ["DPS"] = "Raj'kess the Spellstorm — Orb of Disruption: Kill immediately before Disrupting Blast.; Watchful Harrower — Live Verification: Commit priority damage to shorten the pull.; Devouring Brutalizer — Devour: Swap immediately and free the target.; Brutal Overseer — Brutal Slam: Use a personal if other damage overlaps.",
    },
  },
  ["overview"] = {
    ["interrupts"] = {
      {
        ["spell"] = "Orb of Disruption",
        ["note"] = "kill the orb before Disrupting Blast",
      },
    },
    ["killPriority"] = {
      "Orb of Disruption",
      "Toxic Creeper",
      "Any target trapped by Devour",
    },
    ["tank"] = {
      ["damage"] = {
        "Taz'Rah — Cosmic Spike",
        "Atroxus — Hulking Claw",
        "Brutal Overseer — Brutal Slam",
      },
      ["pullWarnings"] = {
        "Do not combine Watchful Harrower with nearby packs until release tuning is confirmed.",
      },
    },
    ["healer"] = {
      ["dispels"] = {
        "Atroxus poison interactions changed on PTR; confirm the release behaviour.",
      },
      ["pressure"] = {
        "Nether Dash DoTs",
        "Hulking Claw",
        "Sickening Roar",
        "Cosmic Blast",
      },
      ["pullWarnings"] = {
        "Enter Watchful Harrower with mana and a healing cooldown available.",
      },
    },
    ["dps"] = {
      ["defensives"] = {
        "Use personals for Sickening Roar, Cosmic Blast and dangerous overlaps.",
      },
      ["pullWarnings"] = {
        "Raj'kess the Spellstorm — Thundering Storm: Avoid targeted lightning strikes.",
        "Agitated Voidscythe — Corrosive Essence: Separate from other targeted players.",
        "Watchful Harrower — Live Verification: Commit priority damage to shorten the pull.",
        "Position: Avoid adding nearby packs; the miniboss has true sight.",
        "Devouring Brutalizer — Devour: Swap immediately and free the target.",
        "Brutal Overseer — Brutal Slam: Use a personal if other damage overlaps.",
      },
    },
    ["tip"] = {
      "Tank: Preserve movement for gravity pulls and knockbacks.",
      "Healer: Enter Watchful Harrower with mana and a cooldown ready.",
      "DPS: Priority mechanics are worth more than boss uptime.",
    },
  },
  ["bosses"] = {
    {
      ["name"] = "Taz'Rah",
      ["sheet"] = {
        ["TANK"] = "Mitigate Spike > run from Rift > dodge shade lines.",
        ["HEALER"] = "Heal dash DoTs > move from Rift > separate shards.",
        ["DPS"] = "Separate shards > dodge lines > run from Rift.",
        ["WIPE"] = "Being pulled into Dark Rift while shades dash through the arena.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 238887,
      ["displayID"] = 140300,
      ["wipe"] = {
        "Being pulled into Dark Rift while shades dash through the arena.",
        "Dash damage overlapping the Dark Rift pull.",
        "Both shards striking one player or greeding uptime in Dark Rift.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Mitigate Cosmic Spike.",
            "Keep escape space for Dark Rift.",
          },
          ["avoid"] = {
            "Dark Rift's centre, Nether Dash lines and overlapping Ethereal Shards.",
          },
          ["defensive"] = {
            "Use mitigation for Cosmic Spike.",
            "Save mobility for the rift pull.",
          },
          ["reminder"] = "Mitigate Spike > run from Rift > dodge shade lines.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Heal Nether Dash DoTs while moving away from Dark Rift.",
            "Prioritise dash targets and the tank after Cosmic Spike.",
          },
          ["avoid"] = {
            "Shade dash lines, Dark Rift and overlapping Ethereal Shards.",
          },
          ["cooldowns"] = {
            "Use group healing if several players are hit by Nether Dash.",
          },
          ["reminder"] = "Heal dash DoTs > move from Rift > separate shards.",
        },
        ["DPS"] = {
          ["job"] = {
            "Separate Ethereal Shards and keep damage going while escaping Dark Rift.",
            "No boss interrupt confirmed; clean positioning is the priority.",
          },
          ["avoid"] = {
            "Dark Rift, Nether Dash lines and another player's shard path.",
          },
          ["defensive"] = {
            "Use a personal if hit by Nether Dash or threatened by the rift.",
          },
          ["reminder"] = "Separate shards > dodge lines > run from Rift.",
        },
      },
    },
    {
      ["name"] = "Atroxus",
      ["sheet"] = {
        ["TANK"] = "Face away > mitigate Claw > keep the arena clean.",
        ["HEALER"] = "Cooldown Roar > heal Claw > avoid the Creeper.",
        ["DPS"] = "Creeper first > kite cleanly > dodge Breath.",
        ["WIPE"] = "Roar facing the group or an uncontrolled Toxic Creeper.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 239008,
      ["displayID"] = 131553,
      ["wipe"] = {
        "Roar facing the group or an uncontrolled Toxic Creeper.",
        "A Creeper surviving during Roar or heavy tank damage.",
        "Ignoring the Creeper and allowing its aura to pressure the group.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Face Atroxus away.",
            "Mitigate Hulking Claw and aim Sickening Roar away.",
          },
          ["avoid"] = {
            "Noxious Breath, Poison Splash and Poison Pools.",
          },
          ["defensive"] = {
            "Use a defensive for Hulking Claw and its lingering damage.",
          },
          ["reminder"] = "Face away > mitigate Claw > keep the arena clean.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Prepare for Sickening Roar and heal Hulking Claw's lingering damage.",
            "Prioritise the tank and the Toxic Creeper's fixated target.",
          },
          ["avoid"] = {
            "Noxious Breath, Poison Splash and the Creeper's close aura.",
          },
          ["cooldowns"] = {
            "Use group healing for Sickening Roar.",
          },
          ["reminder"] = "Cooldown Roar > heal Claw > avoid the Creeper.",
        },
        ["DPS"] = {
          ["job"] = {
            "Kill the Toxic Creeper immediately.",
            "Kite it away if fixated.",
            "Toxic Creeper first.",
            "Return to Atroxus only after it dies.",
          },
          ["avoid"] = {
            "Noxious Breath, poison impacts, pools and the Creeper aura.",
          },
          ["defensive"] = {
            "Use a personal for Sickening Roar.",
          },
          ["reminder"] = "Creeper first > kite cleanly > dodge Breath.",
        },
      },
    },
    {
      ["name"] = "Charonus",
      ["sheet"] = {
        ["TANK"] = "Place the well > feed the orbs > brace after orbs.",
        ["HEALER"] = "Feed your orb > dodge Cascade > stabilise Blast.",
        ["DPS"] = "Guide orb to well > dodge Cascade > stay nearby.",
        ["WIPE"] = "Poor Singularity placement leaving no safe orb route.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 248015,
      ["displayID"] = 141323,
      ["wipe"] = {
        "Poor Singularity placement leaving no safe orb route.",
        "Unconsumed orbs creating prolonged pressure during Cosmic Blast.",
        "Failing to consume Gravitic Orbs in the Singularity.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Place Unstable Singularity cleanly and leave routes for Gravitic Orbs.",
          },
          ["avoid"] = {
            "Void Cascade, knockbacks and stranding the group far from the Singularity.",
          },
          ["defensive"] = {
            "Prepare a defensive for Dark Waves after Gravitic Orbs.",
          },
          ["reminder"] = "Place the well > feed the orbs > brace after orbs.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Prepare group healing for Cosmic Blast and guide your orb into the Singularity.",
            "Stabilise Cosmic Blast's DoT and Condensed Mass targets.",
          },
          ["avoid"] = {
            "Void Cascade and the damaging centre of the Singularity.",
          },
          ["cooldowns"] = {
            "Use group healing for Cosmic Blast.",
          },
          ["reminder"] = "Feed your orb > dodge Cascade > stabilise Blast.",
        },
        ["DPS"] = {
          ["job"] = {
            "Guide your Gravitic Orb into Unstable Singularity before returning to damage.",
            "Orb first.",
            "Boss uptime second.",
          },
          ["avoid"] = {
            "Void Cascade, knockbacks, the Singularity centre and crossed paths.",
          },
          ["defensive"] = {
            "Use a personal for Cosmic Blast or a Condensed Mass overlap.",
          },
          ["reminder"] = "Guide orb to well > dodge Cascade > stay nearby.",
        },
      },
    },
  },
})
