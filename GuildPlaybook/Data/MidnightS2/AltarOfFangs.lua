-- GENERATED FILE — do not edit by hand.
-- Source: content/midnight-s2/altar-of-fangs.yaml   (regenerate with tools/generate.py)
local _, ns = ...

ns.RegisterDungeon({
  ["dungeon"] = "Altar of Fangs",
  ["slug"] = "altar-of-fangs",
  ["season"] = "midnight-s2",
  ["patch"] = "12.1.0",
  ["sourceVersion"] = "0.6",
  ["instanceID"] = nil,
  ["mdtRoutes"] = {
    {
      ["name"] = "elitzur - keystone.guru (Aug 2026, 100.4% forces)",
      ["string"] = "!~MDT2~TZJPb9owGMZrx3FM/kIBaUf6AYpG2WAcq0I7SjW6dZu0UwXEptlMMuVPR3dqEkCatE/RMTrtsE+33udMFHGwLOt5fu/zvrbvT7zhRzoKg/Tu0H04tOedRuNFtXm8X2vUqk3w0D97d/G2wgdBWBl6QbC3drVbzWpdmJr1ags8nP03fY44r9QeHZ36wUH12fH+Qa1VfQ63LY29U9thzBlFPLwptb9Q+mmncz3gEf31ehT5PnXDduSOqed27emTZTegXDToeO5tby2fizLgJKR04rjjnZ7vsLDPWEDD4LaTRQTfVyAGeC5jAoHyDSskhwCUJTUGWpov7HZGHvf8Y8bqlLGfIIY4zUlIScqalpbKxbWciS26BLGEE11TFrsF0zL0LbZOBSuwUlFNJIgTw9yQLcHemTHYuNmwTpdwkTctCCQ9BlIq9q2gTJ3JSMF6DKUYbaW06D1MDV2zBJSomh5L5QTAglhbOGNLIwVQygnTzNI3nYgJsmBjoWoyskwSQ3khLsAwrQ2c4Uuc5C1jtlss5NVN+KCWxa9AgmUjKZVJjIoxyG/NlJHn1KWTm8MgcMbuRDxNsAJzhRCiSL8BglgiCKtIwzoxkIktgP8AWQyOEJARxkTKYQ3p2MAmslAekztIEFFnRFTQU1Glv37wi2jI6TXloB3Sadin3Am/Rv7lgIcD/7J2NLGdH6+YT+mVx+1Tz3Gp/ffl4xl0h3QcOVx8FXAUOXbv6Zur9/xDOJ32Tv4B",
    },
  },
  ["quicksheet"] = {
    ["trash"] = {
      ["TANK"] = "High Evolutionist — [Evolve]: Interrupt or hard-stop; prioritise the High Evolutionist.; Ascendant Serpent — [Infusion Totems]: Highlighted on current PTR; hard swap to them.; Ritual Chieftain — [Totemic Ritual]: Stop the cast and handle spawned totems.; Venom Leech — [Septic Spatter]: Move from pools; current PTR duration is 30 sec with fewer pools.",
      ["HEALER"] = "High Evolutionist — [Evolve]: Interrupt or hard-stop; prioritise the High Evolutionist.; Ascendant Serpent — [Infusion Totems]: Highlighted on current PTR; hard swap to them.; Ritual Chieftain — [Totemic Ritual]: Stop the cast and handle spawned totems.; Venom Leech — [Septic Spatter]: Move from pools; current PTR duration is 30 sec with fewer pools.",
      ["DPS"] = "High Evolutionist — [Evolve]: Interrupt or hard-stop; prioritise the High Evolutionist. Commit kick or hard CC.; Ascendant Serpent — [Infusion Totems]: Highlighted on current PTR; hard swap to them.; Ritual Chieftain — [Totemic Ritual]: Stop the cast and handle spawned totems. Commit kick or hard CC.; Venom Leech — [Septic Spatter]: Move from pools; current PTR duration is 30 sec with fewer pools.",
      ["ROUTE"] = "Entrance + Carnage Pit > Rav'i > The Writhing Coil > Altar Ascent > Zul'jan",
    },
  },
  ["overview"] = {
    ["interrupts"] = {
      {
        ["spell"] = "Toxic Atrophy",
        ["note"] = "The Writhing Coil — priority interrupt every cast, ahead of [Evolve]; stacks a 20% damage and movement reduction.",
      },
      {
        ["spell"] = "Evolve",
        ["note"] = "High Evolutionist (trash) — interrupt or hard-stop; prioritise the High Evolutionist.",
      },
      {
        ["spell"] = "Fetid Spit",
        ["note"] = "Primal Serpent (trash) — interrupt when available and avoid avoidable poison pressure.",
      },
      {
        ["spell"] = "Totemic Ritual",
        ["note"] = "Ritual Chieftain (trash) — stop the cast and handle spawned totems.",
      },
    },
    ["killPriority"] = {
      "Rav'i's feeding shield ([Ssscavenging]) — break it immediately; catching meat is worth more than boss uptime.",
      "[Infusion Totems] (Ascendant Serpent, trash) — hard swap; the three [Infest] Hatchlings die when the Serpent dies.",
      "Uncoiled snakes (The Writhing Coil) — burst and hard-CC during the 20-sec split; damage carries into the reformed boss.",
      "High Evolutionist (trash) — priority stop and target in the Entrance + Carnage Pit.",
    },
    ["tank"] = {
      ["damage"] = {
        "Ravenous Descendant — stacking attack-speed effect (trash): focus and control early; exact live spell name requires verification.",
        "[Hydrastrike] (Rav'i) — use active mitigation; each of the three heads strikes the current target.",
        "[Tail Scythe] (The Writhing Coil) — use active mitigation or a short defensive for the heavy Physical hit.",
        "[Chop Down] (Zul'jan) — use a strong defensive for both Physical strikes; the hit triggers [Bloodletting].",
        "[Laced Edge] (Blade of the Altar, trash) — tank-targeted hit; pre-mitigate and keep it off the group.",
        "[Blood Sacrifice] (Ritual Chieftain, trash) — heavy Physical hit plus heal absorb; use a defensive and focused healing.",
      },
      ["pullWarnings"] = {
        "Keep Rav'i's nearest Carrion Pile clean of [Fresh Meat] before she reaches 0 energy.",
        "Face [Venom Jet] and other frontals away; keep dangerous trash stable for stops.",
        "Do not combine evolving enemies (High Evolutionist) without an interrupt plan.",
        "PTR trash casts, route and final live placement require live verification.",
      },
    },
    ["healer"] = {
      ["dispels"] = {
        "[Regurgitate] (Rav'i) — Disease-tagged in the current journal; exact live dispel behaviour needs checking.",
      },
      ["pressure"] = {
        "Rav'i's feeding phase ([Ssscavenging] / [Carrion Burst]) — save throughput; [Feeding Frenzy] doubles the [Carrion Burst] rate.",
        "[Death Rattle] and the Uncoil split (The Writhing Coil) — save throughput; [Synchronized Venom] needs sustained healing too.",
        "Ritual beam overlaps (Zul'jan) — heal Physical bleeds from [Chop Down] and [Boneslicer] alongside beam intercepts.",
      },
      ["pullWarnings"] = {
        "Stay 5 yd apart for [Triple Shot]; move for [Regurgitate] and falling stalactites (Rav'i).",
        "Have a cooldown ready before Rav'i's feeding phase or The Writhing Coil's [Death Rattle].",
        "Ritual Chieftain — [Totemic Ritual]: stop the cast and handle spawned totems (trash).",
        "PTR dispel behaviour and trash pull order require live verification.",
      },
    },
    ["dps"] = {
      ["defensives"] = {
        "Stop [Evolve] and [Toxic Atrophy] — [Toxic Atrophy] has kick priority.",
        "Priority mechanics before uptime.",
        "Use a personal for [Regurgitate], a heavy [Carrion Burst] stack or [Synchronized Venom] overlaps.",
      },
      ["pullWarnings"] = {
        "[Toxic Atrophy] first, then [Evolve]; stop dangerous trash casts on assignment.",
        "Ravenous Descendant — stacking attack-speed effect: focus and control early; exact live spell name requires verification.",
        "Caustic Mist Totem — Destroy: complete the interaction; damage no longer interrupts it on PTR.",
        "Break Rav'i's eating shield ([Ssscavenging]) immediately; kill [Infusion Totems] and priority summons.",
        "CC Uncoiled Writhes and dangerous trash; do not stand over dying Writhes.",
        "Rattling Writhe no longer patrols on the first pull; still confirm final live placement.",
        "Altar ascent pack — live verification required: confirm final kick, stop and kill order on live.",
      },
    },
    ["tip"] = {
      "Tank: Save movement for [Vine Grip] and keep frontals away from allies.",
      "Healer: Track [Ritual Venom] timers, not only player health.",
      "DPS: Assign beams on Zul'jan before the pull.",
      "Version 0.6, reviewed and verified 9 August 2026 against the 12.1 PTR Dungeon Journal, Wowhead, Icy Veins and CompetitiveWoW PTR tester consensus.",
      "Pre-season: Patch 12.1 dungeon unlocks the week of 12 August; Mythic+ Season 2 launches the week of 19 August. PTR tuning and placements can still change.",
      "Requires live verification: exact live spell names (e.g. Ravenous Descendant), Enemy Forces, exact trash/pack placement and final live timing.",
    },
  },
  ["trashSegments"] = {
    {
      ["name"] = "Entrance + Carnage Pit > Rav'i",
      ["after"] = nil,
      ["npcs"] = {
        {
          ["name"] = "Ravenous Descendant",
          ["npcID"] = 261553,
          ["displayID"] = 146654,
        },
        {
          ["name"] = "Caustic Mist Totem",
          ["npcID"] = nil,
          ["displayID"] = nil,
        },
        {
          ["name"] = "High Evolutionist",
          ["npcID"] = 261557,
          ["displayID"] = 146663,
        },
      },
      ["roles"] = {
        ["TANK"] = {
          "Ravenous Descendant — stacking attack-speed effect: Focus and control early; exact live spell name requires verification.",
          "Caustic Mist Totem — Destroy: A player can complete the interaction while taking damage; remove it promptly.",
          "High Evolutionist — [Evolve]: Interrupt or hard-stop; prioritise the High Evolutionist.",
        },
        ["HEALER"] = {
          "Ravenous Descendant — stacking attack-speed effect: Focus and control early; exact live spell name requires verification.",
          "Caustic Mist Totem — Destroy: A player can complete the interaction while taking damage; remove it promptly.",
          "High Evolutionist — [Evolve]: Interrupt or hard-stop; prioritise the High Evolutionist.",
        },
        ["DPS"] = {
          "Ravenous Descendant — stacking attack-speed effect: Focus and control early; exact live spell name requires verification.",
          "Caustic Mist Totem — Destroy: A player can complete the interaction while taking damage; remove it promptly.",
          "High Evolutionist — [Evolve]: Interrupt or hard-stop; prioritise the High Evolutionist. Commit kick or hard CC.",
        },
      },
    },
    {
      ["name"] = "Rav'i > The Writhing Coil",
      ["after"] = "Rav'i",
      ["npcs"] = {
        {
          ["name"] = "Ascendant Serpent",
          ["npcID"] = 261573,
          ["displayID"] = 146299,
        },
        {
          ["name"] = "Blade of the Altar",
          ["npcID"] = 271453,
          ["displayID"] = 142336,
        },
        {
          ["name"] = "Primal Serpent",
          ["npcID"] = 261560,
          ["displayID"] = 146653,
        },
      },
      ["roles"] = {
        ["TANK"] = {
          "Ascendant Serpent — [Infest]: Kill the three Hatchlings; they die when the Serpent dies.",
          "Ascendant Serpent — [Infusion Totems]: Highlighted on current PTR; hard swap to them.",
          "Ascendant Serpent — [Virulent Whirl]: Move from the reduced number of twisters.",
          "Blade of the Altar — [Laced Edge]: Tank-targeted hit; pre-mitigate and keep it off the group. Stabilise facing and plan mitigation.",
          "Primal Serpent — [Fetid Spit]: Interrupt when available and avoid avoidable poison pressure.",
        },
        ["HEALER"] = {
          "Ascendant Serpent — [Infest]: Kill the three Hatchlings; they die when the Serpent dies.",
          "Ascendant Serpent — [Infusion Totems]: Highlighted on current PTR; hard swap to them.",
          "Ascendant Serpent — [Virulent Whirl]: Move from the reduced number of twisters.",
          "Blade of the Altar — [Laced Edge]: Tank-targeted hit; pre-mitigate and keep it off the group. Prepare focused healing.",
          "Primal Serpent — [Fetid Spit]: Interrupt when available and avoid avoidable poison pressure.",
        },
        ["DPS"] = {
          "Ascendant Serpent — [Infest]: Kill the three Hatchlings; they die when the Serpent dies.",
          "Ascendant Serpent — [Infusion Totems]: Highlighted on current PTR; hard swap to them.",
          "Ascendant Serpent — [Virulent Whirl]: Move from the reduced number of twisters.",
          "Blade of the Altar — [Laced Edge]: Tank-targeted hit; pre-mitigate and keep it off the group.",
          "Primal Serpent — [Fetid Spit]: Interrupt when available and avoid avoidable poison pressure.",
        },
      },
    },
    {
      ["name"] = "The Writhing Coil > Altar Ascent",
      ["after"] = "The Writhing Coil",
      ["npcs"] = {
        {
          ["name"] = "Ritual Chieftain",
          ["npcID"] = 270306,
          ["displayID"] = 146680,
        },
        {
          ["name"] = "Venom Leech",
          ["npcID"] = 261550,
          ["displayID"] = 146598,
        },
        {
          ["name"] = "Rattling Writhe",
          ["npcID"] = 262011,
          ["displayID"] = 146664,
        },
      },
      ["roles"] = {
        ["TANK"] = {
          "Ritual Chieftain — [Totemic Ritual]: The latest PTR build fixed missed casts; stop it and handle spawned totems.",
          "Ritual Chieftain — [Blood Sacrifice]: Heavy Physical hit plus heal absorb; use a defensive and focused healing. Stabilise facing and plan mitigation.",
          "Venom Leech — [Septic Spatter]: Move from pools; current PTR duration is 30 sec with fewer pools.",
          "Rattling Writhe — patrol: The first one no longer patrols; still confirm final live placement.",
        },
        ["HEALER"] = {
          "Ritual Chieftain — [Totemic Ritual]: The latest PTR build fixed missed casts; stop it and handle spawned totems.",
          "Ritual Chieftain — [Blood Sacrifice]: Heavy Physical hit plus heal absorb; use a defensive and focused healing. Prepare focused healing.",
          "Venom Leech — [Septic Spatter]: Move from pools; current PTR duration is 30 sec with fewer pools.",
          "Rattling Writhe — patrol: The first one no longer patrols; still confirm final live placement.",
        },
        ["DPS"] = {
          "Ritual Chieftain — [Totemic Ritual]: The latest PTR build fixed missed casts; stop it and handle spawned totems. Commit kick or hard CC.",
          "Ritual Chieftain — [Blood Sacrifice]: Heavy Physical hit plus heal absorb; use a defensive and focused healing.",
          "Venom Leech — [Septic Spatter]: Move from pools; current PTR duration is 30 sec with fewer pools.",
          "Rattling Writhe — patrol: The first one no longer patrols; still confirm final live placement.",
        },
      },
    },
  },
  ["bosses"] = {
    {
      ["name"] = "Rav'i",
      ["sheet"] = {
        ["TANK"] = "Clean pile > mitigate [Hydrastrike] > break shield > catch meat.",
        ["HEALER"] = "Spread for [Triple Shot] > ramp for [Carrion Burst] > catch meat.",
        ["DPS"] = "Break shield > catch chunks > dodge [Regurgitate].",
        ["WIPE"] = "[Fresh Meat] in the nearest pile triggers [Feeding Frenzy]. Break the shield immediately and catch [Messy Eater] chunks.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 259445,
      ["displayID"] = 144110,
      ["wipe"] = {
        "[Fresh Meat] in the nearest pile triggers [Feeding Frenzy]. Break the shield immediately and catch [Messy Eater] chunks.",
        "Missed [Messy Eater] chunks stack [Carrion Burst] faster than it can be healed.",
        "A slow shield break during [Feeding Frenzy] doubles the [Carrion Burst] rate and overwhelms the group.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Dodge [Ravenous Stomp]'s falling stalactites; note which Carrion Piles receive [Fresh Meat].",
            "Keep the nearest Carrion Pile clean before Rav'i reaches 0 energy, to avoid [Feeding Frenzy].",
            "Mitigate [Hydrastrike]; each of the three heads strikes the current target.",
            "Call the [Ssscavenging] shield swap and add damage.",
          },
          ["avoid"] = {
            "[Fresh Meat] in the pile Rav'i reaches at 0 energy.",
            "A shield left standing once [Feeding Frenzy] starts.",
            "[Regurgitate]'s three acid lines.",
            "[Triple Shot] if targeted.",
          },
          ["defensive"] = {
            "Use active mitigation for [Hydrastrike]; a defensive for a delayed shield break or a high [Carrion Burst] stack.",
          },
          ["reminder"] = "Clean pile > mitigate [Hydrastrike] > break shield > catch meat.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Pre-HoT and keep the group spread 5 yd apart for [Triple Shot].",
            "Ramp healing immediately once feeding starts; [Carrion Burst] stacks every 3 sec, every 1.5 sec during [Feeding Frenzy].",
            "Assign players to catch [Messy Eater] chunks; every missed chunk adds another [Carrion Burst].",
          },
          ["avoid"] = {
            "[Regurgitate]'s three acid lines; check live whether the Disease tag is dispellable.",
            "Missed [Messy Eater] chunks — each one adds another [Carrion Burst].",
          },
          ["cooldowns"] = {
            "Use a healing cooldown if the shield break is slow or [Carrion Burst] stacks climb high.",
          },
          ["reminder"] = "Spread for [Triple Shot] > ramp for [Carrion Burst] > catch meat.",
        },
        ["DPS"] = {
          ["job"] = {
            "Hard-swap to the shield ([Ssscavenging]) the moment it appears; end [Feeding Frenzy] before [Carrion Burst] overwhelms the group.",
            "Catch assigned [Messy Eater] chunks within 3.5 yd; missed chunks cause [Carrion Burst].",
            "Break the shield first; catching chunks is worth more than boss uptime.",
          },
          ["avoid"] = {
            "[Regurgitate]'s three acid lines — a hit slows you and cuts damage done.",
            "[Ravenous Stomp]'s 5-yd stalactite impacts.",
            "[Triple Shot] if targeted.",
          },
          ["defensive"] = {
            "Use a personal during a long feeding phase or a heavy [Carrion Burst] stack.",
          },
          ["reminder"] = "Break shield > catch chunks > dodge [Regurgitate].",
        },
      },
    },
    {
      ["name"] = "The Writhing Coil",
      ["sheet"] = {
        ["TANK"] = "Mitigate [Tail Scythe] > track [Vindictive Onslaught] > move for [Vine Grip] > stop [Toxic Atrophy].",
        ["HEALER"] = "Move first > sustain [Synchronized Venom] > heal the Uncoil split > stop [Toxic Atrophy].",
        ["DPS"] = "Kick [Toxic Atrophy] > move for [Vine Grip] > burst Uncoiled snakes.",
        ["WIPE"] = "[Death Rattle] ramps until every attached living player completes the 10-yd movement check.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 259446,
      ["displayID"] = 144156,
      ["wipe"] = {
        "[Death Rattle] ramps until every attached living player completes the 10-yd movement check.",
        "One late player during [Vine Grip] can prevent enough distance being created.",
        "Uncoiled damage carries into the reformed boss — time spent not damaging the snakes is wasted.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Face away and mitigate [Tail Scythe].",
            "Track [Vindictive Onslaught]: watch for [Burrowing Charge] and turn [Venom Jet] away from the group.",
            "Stop [Toxic Atrophy] on assignment and move immediately with [Vine Grip].",
          },
          ["avoid"] = {
            "[Burrowing Charge].",
            "[Venom Jet].",
            "[Undermining].",
            "Frontals through allies.",
          },
          ["defensive"] = {
            "Use mitigation for [Tail Scythe]; a defensive for a delayed [Death Rattle] move or [Synchronized Venom].",
          },
          ["reminder"] = "Mitigate [Tail Scythe] > track [Vindictive Onslaught] > move for [Vine Grip] > stop [Toxic Atrophy].",
        },
        ["HEALER"] = {
          ["job"] = {
            "Move immediately with [Vine Grip].",
            "Prepare sustained healing for the 35-sec [Synchronized Venom].",
            "Heal the Uncoil split hit, then keep moving from fixating snakes and dying-snake [Undermining] zones.",
            "Call missed [Toxic Atrophy] interrupts — its stacking 20% damage and movement reduction prolongs the danger.",
          },
          ["avoid"] = {
            "[Burrowing Charge].",
            "[Venom Jet].",
            "[Undermining] knock-ups.",
          },
          ["cooldowns"] = {
            "Use a group cooldown if the team is slow to complete the [Vine Grip] movement check.",
          },
          ["reminder"] = "Move first > sustain [Synchronized Venom] > heal the Uncoil split > stop [Toxic Atrophy].",
        },
        ["DPS"] = {
          ["job"] = {
            "Kick [Toxic Atrophy] every cast — it stacks a 20% damage and movement reduction.",
            "Move immediately with [Vine Grip]; focus fixating snakes.",
            "Burst and hard-CC the Uncoiled snakes during the 20-sec split; damage carries into the reformed boss.",
          },
          ["avoid"] = {
            "[Burrowing Charge].",
            "[Venom Jet].",
            "[Undermining].",
            "Tank-facing side in melee.",
          },
          ["defensive"] = {
            "Use a personal for a delayed [Death Rattle] move or [Synchronized Venom].",
          },
          ["reminder"] = "Kick [Toxic Atrophy] > move for [Vine Grip] > burst Uncoiled snakes.",
        },
      },
    },
    {
      ["name"] = "Zul'jan",
      ["sheet"] = {
        ["TANK"] = "Intercept beam > clear venom via [Bloodletting] > dodge axes.",
        ["HEALER"] = "Track beam intercepts and [Ritual Venom] timers.",
        ["DPS"] = "Intercept > clear > reposition.",
        ["WIPE"] = "Every Ritual beam must be intercepted. On Mythic, [Ritual Venom] stacks and must be cleared by [Bloodletting] before it expires.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 259447,
      ["displayID"] = 145435,
      ["wipe"] = {
        "Every Ritual beam must be intercepted. On Mythic, [Ritual Venom] stacks and must be cleared by [Bloodletting] before it expires.",
        "A missed beam stacks [Fang Empowered], adding sustained group damage.",
        "Repeated beam intercepts without clearing [Ritual Venom] let it stack to a lethal level.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Face away, mitigate both [Chop Down] hits, intercept an assigned [Ritual of the Fang] beam and clear [Ritual Venom].",
          },
          ["avoid"] = {
            "[Axegrinder].",
            "[Boneslicer]'s path.",
            "Blood pools.",
            "Turning the boss into allies.",
          },
          ["defensive"] = {
            "Use strong mitigation for [Chop Down] and a personal while intercepting a beam.",
          },
          ["reminder"] = "Intercept beam > clear venom via [Bloodletting] > dodge axes.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Heal beam interceptors, track [Ritual Venom] stacks and confirm it clears through [Bloodletting].",
            "Heal [Fang Empowered] damage, [Boneslicer]'s armor-ignoring hit and bleed, and players deliberately clearing venom.",
          },
          ["avoid"] = {
            "[Axegrinder].",
            "[Boneslicer]'s path.",
            "Blood pools.",
          },
          ["cooldowns"] = {
            "Plan healing around beam intercepts and [Fang Empowered] stacks; a personal while intercepting.",
          },
          ["reminder"] = "Track beam intercepts and [Ritual Venom] timers.",
        },
        ["DPS"] = {
          ["job"] = {
            "Intercept your assigned [Ritual of the Fang] beam for the full channel, track [Ritual Venom] and clear it with a planned Physical mechanic.",
            "A missed beam stacks [Fang Empowered] — beam assignment and venom clearing come first; ranged keep beam lanes open, melee avoid the front.",
          },
          ["avoid"] = {
            "[Axegrinder] — read red arrows, dodge the fast opening throws, then track ricocheting axes.",
            "[Boneslicer] unless clearing.",
            "Blood pools.",
            "The boss's front.",
          },
          ["defensive"] = {
            "Use a personal while intercepting a beam or deliberately clearing venom.",
          },
          ["reminder"] = "Intercept > clear > reposition.",
        },
      },
    },
  },
})
