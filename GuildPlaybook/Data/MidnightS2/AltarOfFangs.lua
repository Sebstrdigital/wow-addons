-- GENERATED FILE — do not edit by hand.
-- Source: content/midnight-s2/altar-of-fangs.yaml   (regenerate with tools/generate.py)
local _, ns = ...

ns.RegisterDungeon({
  ["dungeon"] = "Altar of Fangs",
  ["slug"] = "altar-of-fangs",
  ["season"] = "midnight-s2",
  ["patch"] = "12.1.0",
  ["sourceVersion"] = "1.0",
  ["instanceID"] = nil,
  ["mdtRoutes"] = {
    {
      ["name"] = "Tactyks PUG Friendly - Method/wago.io (Aug 2026)",
      ["string"] = "!~MDT2~XZK9bhNBFIU1+2vvem0njiMiUWwJUpBILAp3/FuRImSRBEVUGe/eMZuMZ8LubLAlCs/YiUTNGzhrRAstTcRrIPEMNK5CgZwYE1POOffce+fT/RykUXi0/W5/b3P/7p3XzzZDAV0hdnEgekeJ39xr+M/jCFhIe3CCaQpjOE4pTT6OraFp6YatLNuRyB2sVCsQcMpjQkgNCMmQ1CyZt4deoerOnKlehwxJZA00lLNVLn8jU4MxkoalvKI9XKksLzn9eawOhHxCUtf6liq4tioV5yYhpFWDkaM0/caUGoyKEt1oXoexdlouFTWkKw05/cLcnZYTkmlD2zJMXRoFqc1z9VYNMm3gFVxdOW5B/htx9cWSREsKaVWF/kbwxnTYua5KBW+A5itdIznXVdHzlGEu4BjlFxatQWaeIc0wdSsnkadcZ4FCZp6Vl5a9YiknNW9o5/LWAofMUuWSIw1vWCouVxaAZEhZZk4anlqpLoDJnH5Zosp/QKIEKAQi4kxaR0Eax8BEM6XU4rPHTtqicAIUvZ0JT1PWBs62wu6trM1bhxCIRI1weHr5MPxR/rZ6++flRdoY/2qsPkKT7touTpnwGw/u+4L705vyI+EnnHLMJtepg68nzdH3D5cXB+Xf71+8/IIm3XvbaSKuqzfW/U0W+i2eJH7EBMSdKEkiztb9bZyIKx2zSRTEgAWEj3vnIcMdaM8uG2LAtBPtCB53YtyGNwHFSbIVdt3DMCIkClIqeqsUhyFnryCeNl7Tjo+vCDUxBSFgixE+ojgV/MlUjVh7whf8sGv8AQ==",
    },
  },
  ["quicksheet"] = {
    ["trash"] = {
      ["TANK"] = "Ravenous Descendant — [Ravenous]: Soothe, stun or kite to reset stacks.; Ritual Chieftain — [Dismember]: Mitigate the tank hit; do not overpull.; Rattling Writhe — [Corrosive Fangs]: Use active mitigation.; Ascendant Serpent — [Noxious Spray]: Face away and brace for pushback.",
      ["HEALER"] = "Ritual Chieftain — [Blood Sacrifice]: Heal the hit and absorb; line of sight does not stop it.; Twinfang Harrower — [Paralyzing Shots]: Magic dispel or movement freedom.; High Evolutionist — [Envenom]: Poison dispel missed casts.; Living Venom — [Venom Burst]: Top the group; stagger kills.",
      ["DPS"] = "High Evolutionist — [Evolve]: Hard stop; then interrupt poison casts.; Ula'tek's Chosen — [Mass Envenom]: Interrupt every cast.; Ascendant Serpent — [Infest]: Stack summons near the pack, then cleave.; Living Venom — [Venom Burst]: Stagger deaths; use a defensive.",
      ["ROUTE"] = "Entrance + Carnage Pit > Rav'i > The Writhing Coil > Altar Ascent > Zul'jan",
    },
  },
  ["overview"] = {
    ["interrupts"] = {
      {
        ["spell"] = "Piercing Hiss",
        ["note"] = "Primal Serpent (trash) — priority interrupt; group damage and haste loss.",
      },
      {
        ["spell"] = "Envenom",
        ["note"] = "High Evolutionist (trash) — priority interrupt; poison DoT on one player.",
      },
      {
        ["spell"] = "Mass Envenom",
        ["note"] = "High Evolutionist (trash) — priority interrupt; heavy group poison damage.",
      },
      {
        ["spell"] = "Toxic Atrophy",
        ["note"] = "The Writhing Coil — priority interrupt every cast; stacks a 20% damage and movement reduction.",
      },
      {
        ["spell"] = "Toxic Atrophy",
        ["note"] = "Uncoiled Writhe (Writhing Coil split) — priority interrupt; stacking movement and damage penalty.",
      },
      {
        ["spell"] = "Mass Envenom",
        ["note"] = "Ula'tek's Chosen (trash) — priority interrupt; heavy group poison damage.",
      },
      {
        ["spell"] = "Evolve",
        ["note"] = "High Evolutionist (trash) — interrupt or hard-stop; prioritise the High Evolutionist.",
      },
      {
        ["spell"] = "Totemic Ritual",
        ["note"] = "Ritual Chieftain (trash) — stop the cast and handle spawned totems.",
      },
    },
    ["killPriority"] = {
      "Rav'i's feeding shield ([Ssscavenging]) — break it immediately; catching meat is worth more than boss uptime.",
      "[Infusion Totems] (Ascendant Serpent, trash) — destroy four totems before pulling the Ascendant Serpent; the three [Infest] Hatchlings die when the Serpent dies.",
      "Uncoiled snakes (The Writhing Coil) — burst and hard-CC during the 20-sec split; damage carries into the reformed boss.",
      "High Evolutionist (trash) — priority stop and target in the trash after Rav'i.",
    },
    ["tank"] = {
      ["damage"] = {
        "Ravenous Descendant — [Ravenous]: stacking attack-speed enrage; focus and control early — the live value is 10% attack speed per stack.",
        "[Hydrastrike] (Rav'i) — use active mitigation; each of the three heads strikes the current target.",
        "[Tail Scythe] (The Writhing Coil) — use active mitigation or a short defensive for the heavy Physical hit.",
        "[Chop Down] (Zul'jan) — use a strong defensive for both Physical strikes; the hit triggers [Bloodletting].",
        "[Laced Edge] (Blade of the Altar, trash) — random target damage; plan mitigation if it lands on you.",
        "Ritual Chieftain — [Blood Sacrifice]: heavy Physical hit plus heal absorb; the live dungeon no longer supports avoiding it with line of sight. Use a defensive and focused healing.",
        "Ritual Chieftain — [Dismember]: heavy tank damage; use mitigation and avoid stacking it with Ravenous pressure.",
      },
      ["pullWarnings"] = {
        "Keep Rav'i's nearest Carrion Pile clean of [Fresh Meat] before she reaches 0 energy.",
        "Face [Venom Jet] and other frontals away; keep dangerous trash stable for stops.",
        "Do not combine evolving enemies (High Evolutionist) without an interrupt plan.",
        "Ritual Chieftain — [Blood Sacrifice] can no longer be avoided with line of sight; keep pulls controlled instead of relying on it.",
      },
    },
    ["healer"] = {
      ["dispels"] = {
        "[Regurgitate] (Rav'i) — Disease-tagged; dispel it if a player is hit.",
        "[Envenom] (High Evolutionist, trash) — Poison-tagged; dispel any cast that lands.",
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
        "Ritual Chieftain — [Blood Sacrifice]: heal the hit and absorb — line of sight no longer stops it (trash).",
      },
    },
    ["dps"] = {
      ["defensives"] = {
        "Interrupt in priority order: [Piercing Hiss], then [Envenom]/[Mass Envenom], then [Toxic Atrophy].",
        "Priority mechanics before uptime.",
        "Use a personal for [Regurgitate], a heavy [Carrion Burst] stack or [Synchronized Venom] overlaps.",
      },
      ["pullWarnings"] = {
        "[Piercing Hiss] first, then poison casts and [Toxic Atrophy]; stop dangerous trash casts on assignment.",
        "Ravenous Descendant — [Ravenous]: stacking attack-speed enrage; focus and control early — the live value is 10% attack speed per stack.",
        "Caustic Mist Totem — [Unstable Totem]: destroy all six to open Rav'i; a player can complete the interaction while taking the constant group damage.",
        "Break Rav'i's eating shield ([Ssscavenging]) immediately; destroy the four [Infusion Totems] before the Ascendant Serpent pull.",
        "CC Uncoiled Writhes and dangerous trash; do not stand over dying Writhes.",
        "Rattling Writhe no longer patrols on the first pull; still confirm final live placement.",
        "Trash before Zul'jan — kick every [Mass Envenom] from Ula'tek's Chosen and dodge [Virulent Whirl] from Ascendant Serpent.",
      },
    },
    ["tip"] = {
      "Tank: Save movement for [Vine Grip] and keep frontals away from allies.",
      "Healer: Track [Ritual Venom] timers, not only player health.",
      "DPS: Assign beams on Zul'jan before the pull.",
      "Version 1.0, live Mythic+ verified 12 September 2026 against the Tank/Healer/Ranged DPS playbooks; biggest change: Ritual Chieftain moved to the opening trash and Blood Sacrifice can no longer be avoided with line of sight.",
      "Live since Patch 12.1, Midnight Season 2. Re-verify after the next Altar of Fangs hotfix or by 26 September 2026.",
      "The dungeon runs on a 29-minute timer.",
      "A player with at least 25 Midnight Cooking or Alchemy can use the Unfinished Mixture after boss two for Mutating Elixir.",
      "Season 2 uses Lindormi's Guidance on lower keys and rotating Xal'atath bargains on applicable levels; follow the marked route while learning.",
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
          ["name"] = "Ritual Chieftain",
          ["npcID"] = 270306,
          ["displayID"] = 146680,
        },
        {
          ["name"] = "Twinfang Harrower",
          ["npcID"] = 261554,
          ["displayID"] = 147569,
        },
        {
          ["name"] = "Primal Serpent",
          ["npcID"] = 261560,
          ["displayID"] = 146653,
        },
      },
      ["roles"] = {
        ["TANK"] = {
          "Ritual Chieftain — [Blood Sacrifice]: Group damage and healing absorb; the live dungeon no longer supports avoiding it with line of sight. Keep pulls controlled.",
          "Ritual Chieftain — [Dismember]: Heavy tank damage; use mitigation and avoid stacking it with Ravenous pressure.",
          "Ritual Chieftain — [Totemic Ritual]: The latest PTR build fixed missed casts; stop it and handle spawned totems.",
          "Caustic Mist Totem — [Unstable Totem]: Constant group damage; a player can complete the interaction while taking damage. Destroy all six totems to open Rav'i.",
          "Twinfang Harrower — [Toxic Breath]: Sweeping frontal; face it away and hold still until the sweep is clear.",
          "Ravenous Descendant — [Ravenous]: Stacking attack-speed enrage; soothe, stun or kite to reset stacks — the live value is 10% attack speed per stack.",
          "Primal Serpent — [Piercing Hiss]: Interrupt when available and avoid avoidable poison pressure.",
        },
        ["HEALER"] = {
          "Ritual Chieftain — [Blood Sacrifice]: Group damage and healing absorb; pre-heal and clear the absorb — line of sight no longer prevents it.",
          "Ritual Chieftain — [Totemic Ritual]: The latest PTR build fixed missed casts; stop it and handle spawned totems.",
          "Caustic Mist Totem — [Unstable Totem]: Constant group damage; a player can complete the interaction while taking damage. Expect steady damage until all six totems are destroyed.",
          "Twinfang Harrower — [Paralyzing Shots]: Magic snare on two players; use a dispel or a movement-freedom effect.",
          "Ravenous Descendant — [Ravenous]: Stacking attack-speed enrage; warn the tank and support the reset rather than healing through stacks.",
          "Primal Serpent — [Piercing Hiss]: Interrupt when available and avoid avoidable poison pressure.",
        },
        ["DPS"] = {
          "Ritual Chieftain — [Totemic Ritual]: The latest PTR build fixed missed casts; stop it and handle spawned totems. Commit kick or hard CC.",
          "Caustic Mist Totem — [Unstable Totem]: Constant group damage; a player can complete the interaction while taking damage. Destroy all six totems to open Rav'i.",
          "Primal Serpent — [Piercing Hiss]: Group damage and haste loss; kick every cast from range.",
          "Twinfang Harrower — [Paralyzing Shots]: Magic snare on two players; use a freedom or immunity if assigned.",
          "Twinfang Harrower — [Toxic Breath]: Sweeping frontal; stay wide enough to see and sidestep the sweep.",
          "Ravenous Descendant — [Ravenous]: Stacking attack-speed enrage; soothe or help the tank reset with control.",
        },
      },
    },
    {
      ["name"] = "Rav'i > The Writhing Coil",
      ["after"] = "Rav'i",
      ["npcs"] = {
        {
          ["name"] = "High Evolutionist",
          ["npcID"] = 261557,
          ["displayID"] = 146663,
        },
        {
          ["name"] = "Rattling Writhe",
          ["npcID"] = 262011,
          ["displayID"] = 146664,
        },
        {
          ["name"] = "Hatchling",
          ["npcID"] = 261556,
          ["displayID"] = 146662,
        },
        {
          ["name"] = "Bloodletter",
          ["npcID"] = 261552,
          ["displayID"] = 146661,
        },
      },
      ["roles"] = {
        ["TANK"] = {
          "High Evolutionist — [Evolve]: Empowers its poison casts; call a hard stop and keep it with the pack.",
          "Rattling Writhe — [Corrosive Fangs]: Heavy tank damage; mitigate before the bite lands.",
          "Rattling Writhe — [Rattle]: Heavy group damage; avoid combining this with another dangerous pack.",
          "Bloodletter — Bloodletting: Creates melee ground hazards; use control and move the pack out of puddles.",
          "Rattling Writhe — patrol: The first one no longer patrols; still confirm final live placement.",
        },
        ["HEALER"] = {
          "High Evolutionist — [Envenom]: Poison DoT on one player; poison dispel any cast that lands.",
          "High Evolutionist — [Mass Envenom]: Heavy group poison damage; prepare recovery if the empowered cast lands.",
          "Rattling Writhe — [Rattle]: Heavy group damage; commit a healing cooldown on a large pull.",
          "Rattling Writhe — [Corrosive Fangs]: Heavy tank damage; pre-load the tank before the hit.",
          "Rattling Writhe — patrol: The first one no longer patrols; still confirm final live placement.",
        },
        ["DPS"] = {
          "High Evolutionist — [Evolve]: Empowers its poison casts; hard stop the channel, or commit a kick as backup.",
          "High Evolutionist — [Envenom]: Poison DoT on one player; kick after Evolve is secured.",
          "Rattling Writhe — [Rattle]: Heavy group damage; use a defensive when the channel starts.",
          "Hatchling — [Nascent Hunger]: Fixates random players; slow and control fixates without scattering them.",
          "Rattling Writhe — patrol: The first one no longer patrols; still confirm final live placement.",
        },
      },
    },
    {
      ["name"] = "The Writhing Coil > Altar Ascent",
      ["after"] = "The Writhing Coil",
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
          ["name"] = "Ula'tek's Chosen",
          ["npcID"] = 263109,
          ["displayID"] = 147578,
        },
        {
          ["name"] = "Living Venom",
          ["npcID"] = 263112,
          ["displayID"] = 146677,
        },
        {
          ["name"] = "Venom Leech",
          ["npcID"] = 261550,
          ["displayID"] = 146598,
        },
      },
      ["roles"] = {
        ["TANK"] = {
          "Ascendant Serpent — [Infusion Totems]: Destroy four Infusion Totems, then defeat the Ascendant Serpent.",
          "Ascendant Serpent — [Noxious Spray]: Tank frontal and pushback; face away and brace against the push.",
          "Ascendant Serpent — [Infest]: Kill the three Hatchlings; they die when the Serpent dies. Stack the adds together for cleave after the spread.",
          "Ascendant Serpent — [Virulent Whirl]: Move from the reduced number of twisters.",
          "Blade of the Altar — [Laced Edge]: Random target damage; plan mitigation if it lands on you.",
          "Ula'tek's Chosen — [Toxic Surge]: Pulsing damage and line attacks; hold it steady while the group dodges lines.",
          "Living Venom — [Venom Burst]: Group damage on death; do not chain several deaths together.",
          "Venom Leech — [Septic Spatter]: Move from pools; current PTR duration is 30 sec with fewer pools.",
        },
        ["HEALER"] = {
          "Ascendant Serpent — [Infusion Totems]: Destroy four Infusion Totems, then defeat the Ascendant Serpent.",
          "Ascendant Serpent — [Infest]: Kill the three Hatchlings; they die when the Serpent dies. Watch spread targets and the follow-up add damage.",
          "Ascendant Serpent — [Virulent Whirl]: Move from the reduced number of twisters.",
          "Blade of the Altar — [Laced Edge]: Random target damage; spot-heal the target.",
          "Ula'tek's Chosen — [Toxic Surge]: Pulsing damage and line attacks; heal while moving and keep sight of the group.",
          "Living Venom — [Venom Burst]: Group damage on death; top the group between staggered kills.",
          "Venom Leech — [Septic Spatter]: Move from pools; current PTR duration is 30 sec with fewer pools.",
        },
        ["DPS"] = {
          "Ascendant Serpent — [Infusion Totems]: Destroy four Infusion Totems, then defeat the Ascendant Serpent.",
          "Ascendant Serpent — [Infest]: Kill the three Hatchlings; they die when the Serpent dies. Drop the spawn near the pack, then cleave.",
          "Ascendant Serpent — [Virulent Whirl]: (Ranged) maintain a clear firing lane while dodging.",
          "Blade of the Altar — [Laced Edge]: Random target damage; use a personal if it lands on you.",
          "Ula'tek's Chosen — [Mass Envenom]: Heavy group poison damage; kick every cast.",
          "Living Venom — [Venom Burst]: Group damage on death; stagger kills and use a defensive before your target dies.",
          "Venom Leech — [Septic Spatter]: Move from pools; current PTR duration is 30 sec with fewer pools.",
        },
      },
    },
  },
  ["bosses"] = {
    {
      ["name"] = "Rav'i",
      ["sheet"] = {
        ["TANK"] = "Clean pile > mitigate [Hydrastrike] > break shield > catch meat.",
        ["HEALER"] = "Top the group > soak [Messy Eater] > break the shield.",
        ["DPS"] = "Spread for [Triple Shot] > soak [Messy Eater] > burst the shield.",
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
            "[Regurgitate]'s three acid lines; dispel the Disease debuff if a player is hit.",
            "Missed [Messy Eater] chunks — each one adds another [Carrion Burst].",
          },
          ["cooldowns"] = {
            "Use a healing cooldown if the shield break is slow or [Carrion Burst] stacks climb high.",
          },
          ["reminder"] = "Top the group > soak [Messy Eater] > break the shield.",
        },
        ["DPS"] = {
          ["job"] = {
            "Spread at least 5 yd for [Triple Shot].",
            "Hard-swap to the shield ([Ssscavenging]) the moment it appears; end [Feeding Frenzy] before [Carrion Burst] overwhelms the group.",
            "Catch assigned [Messy Eater] chunks within 3.5 yd; missed chunks cause [Carrion Burst].",
            "Break the shield first; catching chunks is worth more than boss uptime.",
          },
          ["avoid"] = {
            "[Regurgitate]'s three acid lines — a hit slows you and cuts damage done.",
            "[Ravenous Stomp]'s 5-yd stalactite impacts.",
            "[Triple Shot] if targeted.",
            "Ranged: don't outrange the group while dodging [Regurgitate] or [Ravenous Stomp]'s stalactites.",
          },
          ["defensive"] = {
            "Use a personal during a long feeding phase or a heavy [Carrion Burst] stack.",
          },
          ["reminder"] = "Spread for [Triple Shot] > soak [Messy Eater] > burst the shield.",
        },
      },
    },
    {
      ["name"] = "The Writhing Coil",
      ["sheet"] = {
        ["TANK"] = "Mitigate [Tail Scythe] > run out for [Vine Grip] > stack Uncoiled Writhes.",
        ["HEALER"] = "Heal [Synchronized Venom] > run out for [Vine Grip].",
        ["DPS"] = "Kick all three [Toxic Atrophy] > run out for [Vine Grip] > cleave snakes.",
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
            "During the Uncoil split, gather the five Uncoiled Writhes together for cleave and control.",
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
          ["reminder"] = "Mitigate [Tail Scythe] > run out for [Vine Grip] > stack Uncoiled Writhes.",
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
          ["reminder"] = "Heal [Synchronized Venom] > run out for [Vine Grip].",
        },
        ["DPS"] = {
          ["job"] = {
            "Kick all three [Toxic Atrophy] casts — each stacks a 20% damage and movement reduction.",
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
          ["reminder"] = "Kick all three [Toxic Atrophy] > run out for [Vine Grip] > cleave snakes.",
        },
      },
    },
    {
      ["name"] = "Zul'jan",
      ["sheet"] = {
        ["TANK"] = "Intercept one of four beams > clear venom via [Boneslicer] > dodge axes.",
        ["HEALER"] = "Track four beam intercepts and the 50-sec [Ritual Venom] timer.",
        ["DPS"] = "Claim the far beam > clear > reposition.",
        ["WIPE"] = "Every Ritual beam must be intercepted. On Mythic, [Ritual Venom] stacks and must be cleared by a deliberate [Boneslicer] hit before it expires.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 259447,
      ["displayID"] = 145435,
      ["wipe"] = {
        "Every Ritual beam must be intercepted — four in total. On Mythic, [Ritual Venom] stacks on a 50-second timer and must be cleared by a deliberate [Boneslicer] hit before it expires.",
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
          ["reminder"] = "Intercept one of four beams > clear venom via [Boneslicer] > dodge axes.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Heal beam interceptors, track [Ritual Venom] stacks and confirm it clears through a deliberate [Boneslicer] hit.",
            "Heal [Fang Empowered] damage, [Boneslicer]'s armor-ignoring hit and bleed, and players deliberately clearing venom.",
            "Track the 50-second [Ritual Venom] timer and confirm every stacked player clears it.",
          },
          ["avoid"] = {
            "[Axegrinder].",
            "[Boneslicer]'s path.",
            "Blood pools.",
          },
          ["cooldowns"] = {
            "Plan healing around beam intercepts and [Fang Empowered] stacks; a personal while intercepting.",
          },
          ["reminder"] = "Track four beam intercepts and the 50-sec [Ritual Venom] timer.",
        },
        ["DPS"] = {
          ["job"] = {
            "Intercept your assigned [Ritual of the Fang] beam for the full channel, track [Ritual Venom] and clear it with one deliberate [Boneslicer] hit.",
            "A missed beam stacks [Fang Empowered] — beam assignment and venom clearing come first; ranged keep beam lanes open, melee avoid the front.",
            "Ranged: claim a beam at maximum distance during [Ritual of the Fang] so melee can take the near lanes.",
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
          ["reminder"] = "Claim the far beam > clear > reposition.",
        },
      },
    },
  },
})
