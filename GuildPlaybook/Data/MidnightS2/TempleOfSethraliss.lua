-- GENERATED FILE — do not edit by hand.
-- Source: content/midnight-s2/temple-of-sethraliss.yaml   (regenerate with tools/generate.py)
local _, ns = ...

ns.RegisterDungeon({
  ["dungeon"] = "Temple of Sethraliss",
  ["slug"] = "temple-of-sethraliss",
  ["season"] = "midnight-s2",
  ["patch"] = "12.1.0",
  ["sourceVersion"] = "1.6",
  ["instanceID"] = nil,
  ["mdtRoutes"] = {
    {
      ["name"] = "Echo#12882 - keystone.guru (Jul 2026)",
      ["string"] = "!~MDT2~VZK/b9NAFMc522kilQIDA93YKgYs6nMTe0IhcX40FQkqKvPZfhdcnW3wnaskE5ciIYEQfwMJIPgLGJAQA/8C/wAbOxEDC2eaRun43vt8vk+ne58OSBimyRFkPEqTbS0eBClLswFhIAR0E5rODkgu0kbRjZLhon9hHo6MpoCRaD3sH97kVjv1jyEQ/HReD1/oSFu0bMcnZHdnURfy790/379+KVdf19lzb89yTLd128auaXt72C4KXHVNa2WGjgN27cz8pu9Mfkxedc7MqokV7OyaNc+2sWmpmD3HrK1Mv4bvYHq+89ebz2T7pzIbNsYFaplV5VmmrUIs16w28ijsuc6joS+ejka9tndCWA4fvSc5Y/zlO32q6d7/R7coxUCpIfWS1D8gWdFkRZ8aJUMaJWksmYJw4T2SWxWJNqZIK0u0pmOYb0p0edXD4Cphtik3VhD1Mcy21ojCm185RZpx9UKWC7NrsrSGqaAbt9YQVyW9Xc0LohfkWQaJGKi3of6yOMx9BifA0AASiMd1zqNhEqsBf/ZgiTTzZAhpov77elsAxOoSLnU5MPXZ6mwk6mURFX1KOShpP4wojYKcibHWiMNo3qEZwOOUhajrwzCPmNLR/fPmfholEP7uBhkQAeG98bwTMMK5WlZuJiQG7yiaTFJPjVncaxC1lYuM8Mk/",
    },
  },
  ["quicksheet"] = {
    ["trash"] = {
      ["TANK"] = "OPENING: Control Shrouded Fang — Cheap Shot; face Sandfury Stonefist — Ground Pound away.; POSITION: Keep charge lines, Burrow paths and beam lanes clear of the party.; DEFENSIVE: Plan for Overload, Serpentstorm, Consume Charge and Guardian pressure.",
      ["HEALER"] = "OPENING: Prepare for Sandswept Hunter — Arrow Barrage and Stonefist tank pressure.; DISPEL: Confirm Poison removals live; fewer dungeon abilities remain dispellable.; COOLDOWN: Plan Gale Force > soak, Serpentstorm, three beams and Corruption Burst.",
      ["DPS"] = "INTERRUPT: Shrouded Fang — Cheap Shot; Agitated Nimbus — Accumulate Charge.; KILL FIRST: Burrow adds; the single Essence Defiler; active Faithless Tormentors.; CONTROL: Break A Knot of Snakes; stop Essence Disruption in the Eye gauntlet.; DEFENSIVE: Use personals for Arrow Barrage, Serpentstorm, beams and Corruption Burst.",
      ["ROUTE"] = "33-minute PTR timer; reduced Enemy Forces allow more routing choice — confirm the live route.; Keep the Eye carrier stable; final gauntlet cast names remain pre-release, requiring live verification.",
    },
  },
  ["overview"] = {
    ["interrupts"] = {
      {
        ["spell"] = "Charged Dust Devil — Healing Surge",
        ["note"] = "interrupt first",
      },
      {
        ["spell"] = "Agitated Nimbus — Accumulate Charge",
        ["note"] = "interrupt first; assign kicks, purge the buff if it lands — each stack is 8%",
      },
      {
        ["spell"] = "Shrouded Fang — Cheap Shot",
        ["note"] = "control the reworked ambush window",
      },
      {
        ["spell"] = "Imbued Stormcaller — Shock",
        ["note"] = "interrupt after Nimbus coverage",
      },
      {
        ["spell"] = "Twisted Hexxer — Flame Shock",
        ["note"] = "interrupt / priority",
      },
    },
    ["killPriority"] = {
      "Dangerous casters",
      "dangerous support enemies",
      "Merektha's Burrow adds",
      "Essence Defiler",
      "active Faithless Tormentors",
    },
    ["tank"] = {
      ["damage"] = {
        "Adderis/Aspix — Overload.",
        "Merektha — Serpentstorm and add pressure.",
        "Galvazzt — Galvanized vulnerability or Consume Charge (missed beams now feed a 60%-stronger Consume Charge).",
        "Corrupted Guardian — Vile Charge (renamed from Tainted Strike).",
      },
      ["pullWarnings"] = {
        "Do not combine summon waves or charged Nimbuses without cooldowns.",
        "Anchor the pack away from patrols and charge lines.",
        "Do not combine multiple summon waves without mitigation.",
        "Keep charge lines and frontals clear of the party.",
        "Dutiful Tamer — Swarming Krolusks: group summons for cleave.",
        "Barbed Krolusk — Serrated Charge: keep charge lines away from allies.",
      },
    },
    ["healer"] = {
      ["dispels"] = {
        "Confirm Poison removals live.",
        "Purge Agitated Nimbus — Accumulate Charge.",
        "Confirm the final Season 2 Poison list after launch.",
      },
      ["pressure"] = {
        "Gale Force > soak.",
        "Serpentstorm.",
        "Lightning Spires.",
        "Corruption Burst.",
        "Barbed Krolusk — Serrated Charge: stabilise the target's damage-over-time effect.",
        "Dutiful Tamer — Swarming Krolusks: prepare for summon-wave damage.",
      },
      ["pullWarnings"] = {
        "Do not enter a large caster pull without interrupts and a healing cooldown.",
        "Prepare for Sandswept Hunter — Arrow Barrage and Stonefist tank pressure.",
        "Keep movement-sensitive targets stable before dispelling.",
      },
    },
    ["dps"] = {
      ["purges"] = {
        "Agitated Nimbus — Accumulate Charge: purge the buff if it lands.",
        "Break A Knot of Snakes.",
        "Protect the Eye carrier.",
        "Dutiful Tamer — Swarming Krolusks: kill summons quickly.",
        "Use stops to control overlapping summon waves.",
      },
      ["defensives"] = {
        "Use a personal for Arrow Barrage.",
        "Use a personal for Serpentstorm.",
        "Use a personal for beams (Galvazzt).",
        "Use a personal for Corruption Burst.",
        "Barbed Krolusk — Serrated Charge: avoid the line.",
      },
      ["pullWarnings"] = {
        "Do not overlap priority casts without an assigned kick plan.",
      },
    },
    ["tip"] = {
      "Tank: Set the fight location first; use short, predictable movement.",
      "Healer: Anchor cooldowns to mechanics, not falling health bars.",
      "DPS: One correct interrupt or soak is worth more than one extra global.",
      "Standard 1.6, reviewed 9 August 2026 against Patch 12.1 PTR notes. Confirm on live before applying blindly.",
      "Requires live verification: final Eyes-gauntlet cast names, Shadowlash execute threshold, Tormentor execute threshold, and the live dungeon route (33-minute PTR timer, reduced Enemy Forces).",
    },
  },
  ["trashSegments"] = {
    {
      ["name"] = "Opening trash — before Adderis and Aspix",
      ["after"] = nil,
      ["npcs"] = {
        {
          ["name"] = "Shrouded Fang",
          ["npcID"] = 134602,
          ["displayID"] = 83782,
        },
        {
          ["name"] = "Sandfury Stonefist",
          ["npcID"] = 134991,
          ["displayID"] = 84207,
        },
        {
          ["name"] = "Sandswept Hunter",
          ["npcID"] = 134600,
          ["displayID"] = 83780,
        },
      },
      ["roles"] = {
        ["TANK"] = {
          "Shrouded Fang — Cheap Shot: Control and stop the ambush cast.",
          "Sandfury Stonefist — Ground Pound: Face away and dodge the frontal; damage reduced 5% on PTR.",
          "Sandswept Hunter — Arrow Barrage: Expect tank pressure alongside the caster's spread mechanic.",
        },
        ["HEALER"] = {
          "Sandswept Hunter — Arrow Barrage: Prepare for spread damage and Stonefist tank pressure together; now 9 seconds with lower damage.",
          "Shrouded Fang — Cheap Shot: Stop the ambush cast before it lands.",
          "Sandfury Stonefist — Ground Pound: Dodge the frontal; damage reduced 5% on PTR.",
        },
        ["DPS"] = {
          "Shrouded Fang — Cheap Shot: Interrupt the ambush cast.",
          "Sandswept Hunter — Arrow Barrage: Spread and use a personal if targeted; now 9 seconds with lower damage.",
          "Sandfury Stonefist — Ground Pound: Dodge the frontal; damage reduced 5% on PTR.",
        },
      },
    },
    {
      ["name"] = "Relevant trash — between Adderis and Aspix & Merektha",
      ["after"] = "Adderis and Aspix",
      ["npcs"] = {
        {
          ["name"] = "Dutiful Tamer",
          ["npcID"] = 139422,
          ["displayID"] = 84761,
        },
        {
          ["name"] = "Sand-Sworn Rider",
          ["npcID"] = 134629,
          ["displayID"] = 84761,
        },
        {
          ["name"] = "Barbed Krolusk",
          ["npcID"] = 134616,
          ["displayID"] = 83787,
        },
        {
          ["name"] = "Swarming Krolusk",
          ["npcID"] = 264785,
          ["displayID"] = 83787,
        },
      },
      ["roles"] = {
        ["TANK"] = {
          "Dutiful Tamer / Sand-Sworn Rider — Swarming Krolusks: Group the summons for cleave; summon health reduced.",
          "Barbed Krolusk / Swarming Krolusk — Serrated Charge: Keep charge lines away from allies; impact and duration reduced.",
        },
        ["HEALER"] = {
          "Dutiful Tamer / Sand-Sworn Rider — Swarming Krolusks: Prepare for summon-wave damage; summon health reduced.",
          "Barbed Krolusk / Swarming Krolusk — Serrated Charge: Stabilise the charge target's damage-over-time effect; impact and duration reduced.",
        },
        ["DPS"] = {
          "Dutiful Tamer / Sand-Sworn Rider — Swarming Krolusks: Control and cleave the summons quickly; summon health reduced.",
          "Barbed Krolusk / Swarming Krolusk — Serrated Charge: Avoid the line; impact and duration reduced.",
        },
      },
    },
    {
      ["name"] = "Relevant trash — between Merektha & Galvazzt",
      ["after"] = "Merektha",
      ["npcs"] = {
        {
          ["name"] = "Agitated Nimbus",
          ["npcID"] = 136076,
          ["displayID"] = 65631,
        },
      },
      ["roles"] = {
        ["TANK"] = {
          "Agitated Nimbus — Accumulate Charge: Assign kicks or purge; each stack is 8%.",
          "Agitated Nimbus — Release Charge: Prepare recovery if charges remain; the clear bug was fixed.",
        },
        ["HEALER"] = {
          "Agitated Nimbus — Accumulate Charge: Assign kicks or purge; each stack is 8%.",
          "Agitated Nimbus — Release Charge: Prepare recovery if charges remain; the clear bug was fixed.",
        },
        ["DPS"] = {
          "Agitated Nimbus — Accumulate Charge: Assign kicks or purge; each stack is 8%.",
          "Agitated Nimbus — Release Charge: Prepare recovery if charges remain; the clear bug was fixed.",
        },
      },
    },
    {
      ["name"] = "Eyes gauntlet & final trash — before Avatar of Sethraliss",
      ["after"] = "Galvazzt",
      ["npcs"] = {
        {
          ["name"] = "Temple Disruptor",
          ["npcID"] = 269227,
          ["displayID"] = 80961,
        },
        {
          ["name"] = "Eye of Sethraliss",
          ["npcID"] = 240681,
          ["displayID"] = 169,
        },
      },
      ["roles"] = {
        ["TANK"] = {
          "Temple Disruptor — Essence Disruption: Interrupt to keep the Eye from gaining energy.",
          "Eye of Sethraliss — Siphon Energy: Protect the nearest carrier and finish both Eyes.",
        },
        ["HEALER"] = {
          "Temple Disruptor — Essence Disruption: Interrupt to keep the Eye from gaining energy.",
          "Eye of Sethraliss — Siphon Energy: Protect the nearest carrier and finish both Eyes.",
        },
        ["DPS"] = {
          "Temple Disruptor — Essence Disruption: Interrupt to keep the Eye from gaining energy.",
          "Eye of Sethraliss — Siphon Energy: Protect the nearest carrier and finish both Eyes.",
        },
      },
    },
  },
  ["bosses"] = {
    {
      ["name"] = "Adderis and Aspix",
      ["sheet"] = {
        ["TANK"] = "Hold a clean push-to-soak route; hit only the unshielded boss.",
        ["HEALER"] = "Top before Gale Force; heal the 4.5-second soak.",
        ["DPS"] = "Hit only the boss without Storm Blessed; place two zones at the edge.",
        ["WIPE"] = "Bad Tempest Winds placement blocks the soak.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 133379,
      ["displayID"] = 83550,
      ["wipe"] = {
        "Bad Tempest Winds placement blocks Thunder and Lightning.",
        "Tempest Winds zones block the soak.",
        "A pacified healer or low soak target dies.",
        "A Tempest Winds zone stops recovery healing.",
        "Bad Tempest Winds zones wall off the soak.",
        "Attacking the boss with Storm Blessed active does no damage — hit only the unshielded target.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Keep a clean Gale Force route to Thunder and Lightning.",
            "Hold a clean push-to-soak route; hit only the unshielded boss — Storm Blessed is immune.",
          },
          ["avoid"] = {
            "Tempest Winds zones — they pacify for 4 seconds, not silence.",
          },
          ["defensive"] = {
            "Mitigate Overload; save mobility for the push.",
          },
          ["reminder"] = "Edge Tempest Winds zones > same push > 4.5-sec soak > move out.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Top the group before Gale Force and the 4.5-second group soak.",
            "Cover the soak and its follow-up explosion.",
          },
          ["avoid"] = {
            "Tempest Winds; it pacifies for 4 seconds (two zones on Mythic).",
          },
          ["cooldowns"] = {
            "Use one for the push-to-soak overlap.",
          },
          ["reminder"] = "Top > move together > heal soak > spread.",
        },
        ["DPS"] = {
          ["job"] = {
            "Attack only the boss without Storm Blessed — the protected target is immune; place the two Tempest Winds zones at the edge.",
            "No boss kick; movement and soak are priority.",
          },
          ["avoid"] = {
            "Tempest Winds zones (they pacify) and over-spreading.",
          },
          ["defensive"] = {
            "Use a personal for the push-to-soak sequence.",
          },
          ["reminder"] = "Edge Tempest Winds zones > same push > soak > out.",
        },
      },
    },
    {
      ["name"] = "Merektha",
      ["sheet"] = {
        ["TANK"] = "Hold stable; stack Burrow adds away from her marked path.",
        ["HEALER"] = "Top before Serpentstorm; track Burrow add damage.",
        ["DPS"] = "Stack Knot targets; CC coils; burn tougher Burrow adds.",
        ["WIPE"] = "Slow add kills extend Burrow.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 133384,
      ["displayID"] = 88585,
      ["wipe"] = {
        "Slow add kills extend Burrow.",
        "Failed dodges plus prolonged Burrow overwhelm the group.",
        "Prolonged Burrow overwhelms the group.",
        "Missed casts or living adds extend Burrow.",
        "Missed casts prolong Burrow.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Hold Merektha stable; gather Burrow adds tightly.",
            "Stack Burrow adds away from her path.",
          },
          ["avoid"] = {
            "Thunder Spit, Serpentstorm and the marked Burrow path.",
          },
          ["defensive"] = {
            "Cover Serpentstorm and add pressure.",
          },
          ["reminder"] = "Stable boss > tight adds > fast Burrow.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Top the group before Serpentstorm.",
            "Stabilise Knot targets and Burrow add damage.",
            "Move in Burrow.",
          },
          ["avoid"] = {
            "Thunder Spit trails, swirlies and the Burrow path.",
          },
          ["cooldowns"] = {
            "Use group healing for Serpentstorm.",
          },
          ["reminder"] = "Top > defensive > dodge > stabilise adds.",
        },
        ["DPS"] = {
          ["job"] = {
            "Stack Knot targets; break the Knot; burn Burrow adds.",
            "Storm Serpent — Storm Catalyst (interrupt/priority).",
          },
          ["avoid"] = {
            "Thunder Spit, swirlies and the Burrow path.",
          },
          ["defensive"] = {
            "Use a personal for Serpentstorm.",
          },
          ["reminder"] = "Stack Knot > CC > defensive > adds.",
        },
      },
    },
    {
      ["name"] = "Galvazzt",
      ["sheet"] = {
        ["TANK"] = "Edge the boss; preserve three beam lanes.",
        ["HEALER"] = "Track all three beam soakers for the full channel.",
        ["DPS"] = "Claim a beam immediately and hold it to the end.",
        ["WIPE"] = "Missed beams now make Consume Charge much harsher.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 133389,
      ["displayID"] = 81654,
      ["wipe"] = {
        "An uncovered beam charges Galvazzt — Consume Charge is now 60% stronger on a miss.",
        "A soaker dies or leaves early.",
        "A beam soaker dies or leaves early.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Start near the edge; preserve three beam lanes.",
          },
          ["avoid"] = {
            "Induction and unplanned beam soaking.",
          },
          ["defensive"] = {
            "Mitigate Galvanized vulnerability or Consume Charge.",
            "Do not beam-soak without a cooldown.",
          },
          ["reminder"] = "Edge > short move > clear beams.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Track all three Lightning Spire soakers.",
            "Keep each soaker stable for the full channel.",
          },
          ["avoid"] = {
            "Induction and unassigned beams.",
          },
          ["cooldowns"] = {
            "Rotate across fast Spire waves.",
          },
          ["reminder"] = "Three beams, three healthy soakers.",
        },
        ["DPS"] = {
          ["job"] = {
            "Enter the assigned beam immediately and hold it.",
            "Claim a beam and hold it to the end.",
            "No boss kick; beam coverage is priority.",
          },
          ["avoid"] = {
            "Induction and crossing another lane late.",
          },
          ["defensive"] = {
            "Use a personal while soaking.",
          },
          ["reminder"] = "Your beam is more important than your cast.",
        },
      },
    },
    {
      ["name"] = "Avatar of Sethraliss",
      ["sheet"] = {
        ["TANK"] = "Control one Guardian per main phase and sustain Vile Charge.",
        ["HEALER"] = "Heal the Avatar when the single Defiler dies; line of sight is ignored.",
        ["DPS"] = "Kill the one Defiler; cleanse the Lifeforce without knockback.",
        ["WIPE"] = "Repeated Corruption Bursts amplify sharply.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 133392,
      ["displayID"] = 83203,
      ["wipe"] = {
        "Defiler blocks healing; uncleansed Lifeforce bursts.",
        "Uncleansed Lifeforce bursts repeatedly.",
        "Shadowlash stacks or the Defiler suppress healing.",
        "Each remaining Lifeforce stack causes a Burst.",
        "Each remaining orb stack causes a Burst.",
        "Repeated Corruption Bursts gain a stacking vulnerability, now up to 300%, and can chain-wipe; Shadowlash and Tormentor execute thresholds require live verification.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Protect the Eye carrier; control knockbacks (Eyes gauntlet — live cast names require verification).",
            "Pick up Guardians; control Vile Charge stacks (renamed from Tainted Strike).",
            "Essence Defiler — Defiling Taint (priority).",
          },
          ["avoid"] = {
            "Agony impacts and moving Lifeforce away.",
          },
          ["defensive"] = {
            "Use a major for stacked Guardian damage.",
          },
          ["reminder"] = "Protect the Eye carrier > pick up Guardians > control Vile Charge > major for stacked Guardian damage.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Keep the Eye carrier stable through projectiles (Eyes gauntlet — live cast names require verification).",
            "Heal the Avatar only after the Defiler dies.",
            "Use cleansed Lifeforce and Siphon the Weak to accelerate progress.",
          },
          ["avoid"] = {
            "Tormentor fixates, Hex Muck and Agony.",
          },
          ["cooldowns"] = {
            "Commit throughput only when Defiling Taint is gone.",
          },
          ["reminder"] = "Defiler dead > avoid Tormentors > heal Avatar.",
        },
        ["DPS"] = {
          ["job"] = {
            "Protect the carrier and stop Eye recovery (Eyes gauntlet — live cast names require verification).",
            "Kill the Defiler; push Tormentors below 50%.",
            "Twisted Hexxer — Flame Shock (interrupt priority).",
            "Cleanse Lifeforce only on assignment.",
            "Control Conscripts and Orb Guardians.",
          },
          ["avoid"] = {
            "Hex Muck, Agony and unassigned Lifeforce contact.",
          },
          ["defensive"] = {
            "Use a personal for Corruption Burst.",
          },
          ["reminder"] = "Kick > Defiler > cleanse > Tormentors.",
        },
      },
    },
  },
})
