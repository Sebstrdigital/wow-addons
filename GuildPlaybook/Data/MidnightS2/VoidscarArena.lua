-- GENERATED FILE — do not edit by hand.
-- Source: content/midnight-s2/voidscar-arena.yaml   (regenerate with tools/generate.py)
local _, ns = ...

ns.RegisterDungeon({
  ["dungeon"] = "Voidscar Arena",
  ["slug"] = "voidscar-arena",
  ["season"] = "midnight-s2",
  ["patch"] = "12.1.0",
  ["sourceVersion"] = "0.12",
  ["instanceID"] = nil,
  ["mdtRoutes"] = {
    {
      ["name"] = "Tactyks PUG Friendly - Method/wago.io (Aug 2026)",
      ["string"] = "!~MDT2~XVNNT1NBFHXeR2mhLW0hcEEjoyAq4gewatwYMRgiCyJodGOcvnenPDq8gffmQXHFTGNMiAv/gnwU3foDDIn/xn1XbEyxIZTV3HvunHNmTmZ+eEng12be70RLW++C2torX2FdqVXmqd1aTJffvKQLUYChL3Zxm4kEj3EzESL+9pM0srm8ZbI5Z89t5Av9KZ3r2UtrUtxDTwoZcc7nkPODjCYdoN2W8Zg0iGVbDWJbdrtyGjaxLlHmsGkZx3WM4/ZpktUkd0mgjJw3iXFc2zhuXpN+TQoXY855ZQ4PYUQTuNnlOofNlHaKbbuSJgOaDF4xLeNRydjWgHGtwUa2t+8Sl/NmWjtF47gl47gD2hlsZHrSF9zyueWoJnDDXEi2b8F50zK9Gduke4qmUBzSNoBJuZ0dbKZte0J02tapou4v6fyQJgDGIl3xnRDdY+mU2z5BLlvS6eF9mIBJoHAPbsFtGIe7cAfGuhJuurovpbNFnS/p3PA+3IdpeAhTMAsP4Ak8ghl43JX3MTGZ3pLuH9IWgLGdrrSP4LomMKYJ0CtBBzEK9FQgQ12oeUkUYaiWEyEKstOsJBWB2yjIVgd4kYRVlOGiX4fDqqyso6dic8D8z2fPPv5Zff2bXzs7/ZT7uzLx6ztp1Z/Oz1NGKxHbERjRgNMQ0UefKkkj9BMPqVpD6q2x0EPKaC3warQqMaaScxa2/usGs6Nfv0yenp3ufRg5WshMkFZ9aimJFW2/Yjoz/X8tUxnR2dCnFRnH03SJxeq8ZGEr8CJkCv3nu4d+yDaw2vkaGCETG8GKktFGxKq45gkWx4t+vW/dDzgPvESoXRgXzPdl+BajOJDhiLW5eZ7gMhOoFC6GXB4Ilig530aDsNqSXXO/7vwD",
    },
  },
  ["quicksheet"] = {
    ["trash"] = {
      ["TANK"] = "Raj'kess the Spellstorm — [Thundering Storm]: Hold the pack steady; leave room for targeted strikes.; Watchful Harrower — [Sky Strike]: Join the soak, then move out.; Devouring Brutalizer — [Devour]: Kill its low-health enemy target before the cast ends.; Brutal Overseer — [Brutal Slams]: Hold the enemy steady while DPS break the shield.",
      ["HEALER"] = "Raj'kess the Spellstorm — [Thundering Storm]: Prepare spot healing for targeted strikes.; Watchful Harrower — [Void Beam]: Commit focused healing or a save.; Devouring Brutalizer — [Devour]: Kill its low-health enemy target before the cast ends.; Brutal Overseer — [Brutal Slams]: Prepare focused tank healing for the hit and DoT.",
      ["DPS"] = "Raj'kess the Spellstorm — [Orb of Disruption]: Destroy the orbs within 13 seconds.; Watchful Harrower — [Sky Strike]: Commit priority damage to shorten the pull, then move out after the soak.; Devouring Brutalizer — [Devour]: Kill its low-health enemy target before the cast ends.; Brutal Overseer — [Brutal Slams]: Use a personal if other damage overlaps.",
      ["ROUTE"] = "Opening Trash Before Taz'Rah (miniboss choice) > Taz'Rah > Trash Between Taz'Rah and Atroxus > Lieutenant Choice Before Atroxus (Watchful Harrower) > Atroxus > Trash Between Atroxus and Charonus > Charonus.",
    },
  },
  ["overview"] = {
    ["interrupts"] = {
      {
        ["spell"] = "Demoralizing Shout",
        ["note"] = "Dominated Brawler — weakens party damage",
      },
      {
        ["spell"] = "Shadowbolt Volley",
        ["note"] = "Voidtouched Magi — heavy group damage",
      },
      {
        ["spell"] = "Violent Sand",
        ["note"] = "Angry Krolusk — heavy group damage",
      },
      {
        ["spell"] = "Mad Shriek",
        ["note"] = "Killvore Screamer — six-second group fear",
      },
      {
        ["spell"] = "Mending Void",
        ["note"] = "Voidminder — heals nearby enemies",
      },
      {
        ["spell"] = "Orb of Disruption",
        ["note"] = "Raj'kess the Spellstorm — destroy the orbs within 13 seconds",
      },
    },
    ["killPriority"] = {
      "[Orb of Disruption]",
      "Toxic Creeper",
      "Devouring Brutalizer's low-health [Devour] target — kill it before the cast ends",
    },
    ["tank"] = {
      ["damage"] = {
        "Taz'Rah — [Cosmic Spike]",
        "Atroxus — [Hulking Claw]",
        "Brutal Overseer — [Brutal Slams]",
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
        "[Nether Dash] DoTs",
        "[Hulking Claw]",
        "[Monstrous Roar]",
        "[Cosmic Blast]",
      },
      ["pullWarnings"] = {
        "Enter Watchful Harrower with mana and a healing cooldown available.",
      },
    },
    ["dps"] = {
      ["defensives"] = {
        "Use personals for [Monstrous Roar], [Cosmic Blast] and dangerous overlaps.",
      },
      ["pullWarnings"] = {
        "Raj'kess the Spellstorm — [Thundering Storm]: Avoid targeted lightning strikes.",
        "Agitated Voidscythe — [Corrosive Essence]: Three poison debuffs — spread, dispel poisons and use defensives.",
        "Watchful Harrower — [Sky Strike]: Commit priority damage to shorten the pull.",
        "Position: Avoid adding nearby packs; the miniboss has true sight.",
        "Devouring Brutalizer — [Devour]: Kill its low-health enemy target before the cast ends.",
        "Brutal Overseer — [Brutal Slams]: Use a personal if other damage overlaps.",
      },
    },
    ["tip"] = {
      "Tank: Preserve movement for gravity pulls and knockbacks.",
      "Healer: Enter Watchful Harrower with mana and a cooldown ready.",
      "DPS: Priority mechanics are worth more than boss uptime.",
      "Draft 0.12, verified 12 September 2026 (hotfixes through 10 September). Biggest change: [Devour] now heals its caster 50% and is stopped by killing its low-health enemy target, not by freeing a trapped player.",
      "Version note: Midnight Season 2 is live on Patch 12.1.0 as of 10 Sep; Patch 12.1.5 remains on PTR and is not the baseline.",
      "Requires live verification: Enemy Forces values, the best opening path for each weekly affix, and post-12.1.5 tuning once it leaves PTR.",
    },
  },
  ["trashSegments"] = {
    {
      ["name"] = "Opening trash — before Taz'Rah",
      ["after"] = nil,
      ["npcs"] = {
        {
          ["name"] = "Raj'kess the Spellstorm",
          ["npcID"] = 267546,
          ["displayID"] = 143575,
        },
        {
          ["name"] = "Enthralled Shaman",
          ["npcID"] = 241496,
          ["displayID"] = 130201,
        },
        {
          ["name"] = "Dominated Brawler",
          ["npcID"] = 238883,
          ["displayID"] = 130200,
        },
        {
          ["name"] = "Brutal Overseer",
          ["npcID"] = 252053,
          ["displayID"] = 137329,
        },
        {
          ["name"] = "Aegyra the Unyielding",
          ["npcID"] = 267545,
          ["displayID"] = 147378,
        },
      },
      ["roles"] = {
        ["TANK"] = {
          "Raj'kess the Spellstorm — [Orb of Disruption]: Destroy the orbs within 13 seconds.",
          "Raj'kess the Spellstorm — [Thundering Storm]: Avoid the targeted lightning strikes; hold the pack steady and leave room for strikes.",
          "Enthralled Shaman — [Magma Totem]: Kill the totem immediately.",
          "Dominated Brawler — [Bloodsurge]: Soothe, crowd-control or kite at high stacks.",
          "Brutal Overseer — [Brutal Slams]: Break the shield to stop the channel.",
          "Aegyra the Unyielding — [Champion's Spear]: Destroy the spear quickly; its health is 15% lower.",
          "Opening path choice: Aegyra grants Proof of Endurance, Raj'kess grants Proof of Mastery — both are buffs now. Method favours the left path, Icy Veins the right; still live-unverified, so choose by composition and weekly affix.",
        },
        ["HEALER"] = {
          "Raj'kess the Spellstorm — [Orb of Disruption]: Destroy the orbs within 13 seconds.",
          "Raj'kess the Spellstorm — [Thundering Storm]: Avoid the targeted lightning strikes; prepare spot healing for hits.",
          "Enthralled Shaman — [Magma Totem]: Kill the totem immediately.",
          "Dominated Brawler — [Bloodsurge]: Soothe, crowd-control or kite at high stacks.",
          "Brutal Overseer — [Brutal Slams]: Break the shield to stop the channel.",
          "Aegyra the Unyielding — [Champion's Spear]: Destroy the spear quickly; its health is 15% lower.",
          "Opening path choice: Aegyra grants Proof of Endurance, Raj'kess grants Proof of Mastery — both are buffs now. Method favours the left path, Icy Veins the right; still live-unverified, so choose by composition and weekly affix.",
        },
        ["DPS"] = {
          "Raj'kess the Spellstorm — [Orb of Disruption]: Destroy the orbs within 13 seconds.",
          "Raj'kess the Spellstorm — [Thundering Storm]: Avoid the targeted lightning strikes.",
          "Enthralled Shaman — [Magma Totem]: Kill the totem immediately.",
          "Dominated Brawler — [Bloodsurge]: Soothe, crowd-control or kite at high stacks.",
          "Brutal Overseer — [Brutal Slams]: Use a personal if other damage overlaps.",
          "Aegyra the Unyielding — [Champion's Spear]: Destroy the spear quickly; its health is 15% lower.",
          "Opening path choice: Aegyra grants Proof of Endurance, Raj'kess grants Proof of Mastery — both are buffs now. Method favours the left path, Icy Veins the right; still live-unverified, so choose by composition and weekly affix.",
        },
      },
    },
    {
      ["name"] = "Trash between Taz'Rah and Atroxus",
      ["after"] = "Taz'Rah",
      ["npcs"] = {
        {
          ["name"] = "Savage Shredclaw",
          ["npcID"] = 243835,
          ["displayID"] = 141810,
        },
        {
          ["name"] = "Agitated Voidscythe",
          ["npcID"] = 263228,
          ["displayID"] = 138723,
        },
      },
      ["roles"] = {
        ["TANK"] = {
          "Savage Shredclaw — [Shred Defense]: Use mitigation for the hit and follow-up damage.",
          "Agitated Voidscythe — [Corrosive Essence]: Three poison debuffs — spread, dispel poisons and use defensives.",
          "Agitated Voidscythe — [Rip And Slice]: Mitigate; remove the bleed when available.",
        },
        ["HEALER"] = {
          "Savage Shredclaw — [Shred Defense]: Keep the tank topped and cover the hit; remove the bleed when available.",
          "Agitated Voidscythe — [Corrosive Essence]: Three poison debuffs — spread, dispel poisons and use defensives.",
          "Agitated Voidscythe — [Rip And Slice]: Keep the tank topped and cover the hit; remove the bleed when available.",
        },
        ["DPS"] = {
          "Agitated Voidscythe — [Corrosive Essence]: Three poison debuffs — spread, dispel poisons and use defensives.",
        },
      },
    },
    {
      ["name"] = "Lieutenant choice before Atroxus — Watchful Harrower",
      ["after"] = "Taz'Rah",
      ["npcs"] = {
        {
          ["name"] = "Watchful Harrower",
          ["npcID"] = 245950,
          ["displayID"] = 141286,
        },
      },
      ["roles"] = {
        ["TANK"] = {
          "Watchful Harrower — [Sky Strike]: Stack in the target, then leave the follow-up area.",
          "Watchful Harrower — [Void Beam]: Hold the pack still and use a group stop if the target is in danger.",
          "Position: Avoid adding nearby packs; Watchful Harrowers have true sight.",
        },
        ["HEALER"] = {
          "Watchful Harrower — [Sky Strike]: Stack in the target, then leave the follow-up area.",
          "Watchful Harrower — [Void Beam]: Heal the target; combat drops can cancel it.",
          "Position: Avoid adding nearby packs; Watchful Harrowers have true sight.",
        },
        ["DPS"] = {
          "Watchful Harrower — [Sky Strike]: Stack in the target, then leave the follow-up area.",
          "Position: Avoid adding nearby packs; Watchful Harrowers have true sight.",
        },
      },
    },
    {
      ["name"] = "Trash between Atroxus and Charonus",
      ["after"] = "Atroxus",
      ["npcs"] = {
        {
          ["name"] = "Devouring Brutalizer",
          ["npcID"] = 268184,
          ["displayID"] = 142611,
        },
        {
          ["name"] = "Voidminder",
          ["npcID"] = 244708,
          ["displayID"] = 147460,
        },
      },
      ["roles"] = {
        ["TANK"] = {
          "Devouring Brutalizer — [Dreadbellow]: Use group defensives and avoid nearby pulls.",
          "Devouring Brutalizer — [Brutalize]: Use active mitigation and a defensive.",
          "Devouring Brutalizer — [Devour]: Kill its low-health enemy target before the cast ends.",
          "Voidminder — [Dimensional Shred]: Use a personal and focused healing.",
          "Lieutenants are required before Charonus.",
        },
        ["HEALER"] = {
          "Devouring Brutalizer — [Dreadbellow]: Use group defensives and avoid nearby pulls.",
          "Devouring Brutalizer — [Brutalize]: Use active mitigation and a defensive.",
          "Devouring Brutalizer — [Devour]: Kill its low-health enemy target before the cast ends.",
          "Voidminder — [Dimensional Shred]: Use a personal and focused healing.",
          "Lieutenants are required before Charonus.",
        },
        ["DPS"] = {
          "Devouring Brutalizer — [Devour]: Kill its low-health enemy target before the cast ends.",
          "Voidminder — [Dimensional Shred]: Use a personal and focused healing.",
          "Lieutenants are required before Charonus.",
        },
      },
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
            "Mitigate [Cosmic Spike].",
            "Keep escape space for Dark Rift.",
          },
          ["avoid"] = {
            "Dark Rift's centre, [Nether Dash] lines and overlapping Ethereal Shards.",
          },
          ["defensive"] = {
            "Use mitigation for [Cosmic Spike].",
            "Save mobility for the rift pull.",
          },
          ["reminder"] = "Mitigate Spike > run from Rift > dodge shade lines.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Heal [Nether Dash] DoTs while moving away from Dark Rift.",
            "Prioritise dash targets and the tank after [Cosmic Spike].",
          },
          ["avoid"] = {
            "Shade dash lines, Dark Rift and overlapping Ethereal Shards.",
          },
          ["cooldowns"] = {
            "Use group healing if several players are hit by [Nether Dash].",
          },
          ["reminder"] = "Heal dash DoTs > move from Rift > separate shards.",
        },
        ["DPS"] = {
          ["job"] = {
            "Separate Ethereal Shards and keep damage going while escaping Dark Rift.",
            "No boss interrupt confirmed; clean positioning is the priority.",
          },
          ["avoid"] = {
            "Dark Rift, [Nether Dash] lines and another player's shard path.",
          },
          ["defensive"] = {
            "Use a personal if hit by [Nether Dash] or threatened by the rift.",
          },
          ["reminder"] = "Separate shards > dodge lines > run from Rift.",
        },
      },
    },
    {
      ["name"] = "Atroxus",
      ["sheet"] = {
        ["TANK"] = "Face away > 4-sec Breath dodge > Creeper first.",
        ["HEALER"] = "4-sec Breath move > Roar cooldown > Creeper pressure.",
        ["DPS"] = "Creeper first > 4-sec Breath dodge > avoid pools.",
        ["WIPE"] = "Breath through the group or leaving the Toxic Creeper alive beside players.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 239008,
      ["displayID"] = 131553,
      ["wipe"] = {
        "Breath through the group or leaving the Toxic Creeper alive beside players.",
        "An ignored Creeper compounds aura damage during Roar or poison pools.",
        "Ignoring the Creeper and allowing its aura to pressure the group.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Face Atroxus away.",
            "Mitigate [Hulking Claw] and recover from its knockback and damage-over-time effect.",
            "Make the Toxic Creeper easy to reach.",
          },
          ["avoid"] = {
            "[Noxious Breath] — random-target frontal, 4-sec cast; stay close enough to sidestep without dragging the boss.",
            "[Poison Splash] and Poison Pools.",
          },
          ["defensive"] = {
            "Use a defensive for [Hulking Claw] or a dangerous [Monstrous Roar] overlap.",
            "Use a major defensive if Toxic Creeper — [Sickening Bite] stacks remain.",
          },
          ["reminder"] = "Face away > 4-sec Breath dodge > Creeper first.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Cover [Monstrous Roar] and the tank's [Hulking Claw] damage.",
            "Prioritise the tank and the Toxic Creeper's fixated target.",
          },
          ["avoid"] = {
            "[Noxious Breath] — random-target frontal, 4-sec cast; reposition during the longer window without dragging the boss.",
            "[Poison Splash] and the Creeper's close aura.",
          },
          ["cooldowns"] = {
            "Use group healing for [Monstrous Roar]; save throughput after repositioning for the 4-sec Breath.",
          },
          ["reminder"] = "4-sec Breath move > Roar cooldown > Creeper pressure.",
        },
        ["DPS"] = {
          ["job"] = {
            "Kill the Toxic Creeper immediately.",
            "Kite it away if fixated.",
            "Toxic Creeper first.",
            "Return to Atroxus only after it dies.",
          },
          ["avoid"] = {
            "[Noxious Breath] — random-target frontal, 4-sec cast; poison impacts, pools and the Creeper aura.",
          },
          ["defensive"] = {
            "[Noxious Breath] — random-target frontal, 4-sec cast: move early, and use a personal for [Monstrous Roar].",
          },
          ["reminder"] = "Creeper first > 4-sec Breath dodge > avoid pools.",
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
        "Unconsumed orbs creating prolonged pressure during [Cosmic Blast].",
        "Failing to consume Gravitic Orbs in the Singularity.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Place [Unstable Singularity] cleanly and leave routes for Gravitic Orbs.",
          },
          ["avoid"] = {
            "[Void Cascade], knockbacks and stranding the group far from the Singularity.",
          },
          ["defensive"] = {
            "Prepare a defensive for Dark Waves after Gravitic Orbs.",
          },
          ["reminder"] = "Place the well > feed the orbs > brace after orbs.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Prepare group healing for [Cosmic Blast] and guide your orb into the Singularity.",
            "Stabilise [Cosmic Blast]'s DoT and Condensed Mass targets.",
          },
          ["avoid"] = {
            "[Void Cascade] and the damaging centre of the Singularity.",
          },
          ["cooldowns"] = {
            "Use group healing for [Cosmic Blast].",
          },
          ["reminder"] = "Feed your orb > dodge Cascade > stabilise Blast.",
        },
        ["DPS"] = {
          ["job"] = {
            "Guide your Gravitic Orb into [Unstable Singularity] before returning to damage.",
            "Orb first.",
            "Boss uptime second.",
          },
          ["avoid"] = {
            "[Void Cascade], knockbacks, the Singularity centre and crossed paths.",
          },
          ["defensive"] = {
            "Use a personal for [Cosmic Blast] or a Condensed Mass overlap.",
          },
          ["reminder"] = "Guide orb to well > dodge Cascade > stay nearby.",
        },
      },
    },
  },
})
