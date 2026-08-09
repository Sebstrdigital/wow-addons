-- GENERATED FILE — do not edit by hand.
-- Source: content/midnight-s2/murder-row.yaml   (regenerate with tools/generate.py)
local _, ns = ...

ns.RegisterDungeon({
  ["dungeon"] = "Murder Row",
  ["slug"] = "murder-row",
  ["season"] = "midnight-s2",
  ["patch"] = "12.1.0",
  ["sourceVersion"] = "1.0",
  ["instanceID"] = nil,
  ["quicksheet"] = {
    ["trash"] = {
      ["TANK"] = "Felmaster Lucsei — Blade Dance: Priority stop or move clear; never stack avoidable damage into it.; Corrupted Warlock — Curse of Doom: Highest interrupt priority; avoid combining with Defiled Golem danger without a planned stop.; Corrupted Warlock — Dark Pact: Interrupt or purge the defensive if it lands.; Defiled Golem — Defiled Slam: Leave the impact and use mitigation if targeted.",
      ["HEALER"] = "Felmaster Lucsei — Blade Dance: Priority stop or move clear; never stack avoidable damage into it.; Corrupted Warlock — Curse of Doom: Plan around it — it is the group's highest interrupt priority.; Corrupted Warlock — Dark Pact: Interrupt or purge the defensive if it lands.; Defiled Golem — Defiled Slam: Leave the impact and use mitigation if targeted.",
      ["DPS"] = "Felmaster Lucsei — Blade Dance: Priority stop or move clear; never stack avoidable damage into it.; Corrupted Warlock — Curse of Doom: Assigned interrupt priority — stop it before Dark Pact.; Corrupted Warlock — Dark Pact: Interrupt or purge the defensive if it lands.; Defiled Golem — Defiled Slam: Leave the impact and use mitigation if targeted.",
    },
  },
  ["overview"] = {
    ["interrupts"] = {
      {
        ["spell"] = "Curse of Doom",
        ["note"] = "Corrupted Warlock (trash) — highest interrupt priority; kick before Dark Pact.",
      },
      {
        ["spell"] = "Dark Pact",
        ["note"] = "Corrupted Warlock (trash) — interrupt or purge the defensive if it lands.",
      },
      {
        ["spell"] = "Blade Dance",
        ["note"] = "Felmaster Lucsei (trash) — priority stop or move clear; never stack avoidable damage into it.",
      },
      {
        ["spell"] = "Mirror Image — Felstorm",
        ["note"] = "Kystia Manaheart — assign one interrupt to each image; both casts must be stopped (two interrupts per image on Mythic/Mythic+).",
      },
      {
        ["spell"] = "Chaos Bolt",
        ["note"] = "Lithiel Cinderfury — interrupt when assigned; adds before boss; do not turn the boss unpredictably.",
      },
    },
    ["killPriority"] = {
      "Corrupted Warlock and Defiled Golem — kill first among trash.",
      "Nibbles — bring to 20% without wasting burst on Kystia's Felshield, then swap to Mirror Images.",
      "Mirror Images — both Felstorm casts must be stopped before bursting Kystia in Destabilized.",
      "Lithiel's summoned demons — hard swap and cleave; prioritise empowered demons before Malefic Wave.",
    },
    ["tank"] = {
      ["damage"] = {
        "Chaos Barrage (Kystia Manaheart) — active mitigation; keep nearby players clear of the jump where positioning allows.",
        "Envenom (Zaen Bladesorrow) — mitigate the tank hit and call for Heartstop Poison removal.",
        "Legion Strike (Xathuux the Annihilator) — active mitigation; keep the frontal away from allies.",
        "Vilefiend pressure (Lithiel Cinderfury) — cover Vilefiend and stacked add pressure.",
        "Felmaster Lucsei — Blade Dance (trash): priority stop or move clear; never stack avoidable damage into it.",
        "Defiled Golem — Defiled Slam (trash): leave the impact and use mitigation if targeted.",
      },
      ["pullWarnings"] = {
        "Avoid combining Corrupted Warlock and Defiled Golem danger without a planned stop.",
        "Corrupted Warlock — Curse of Doom: highest interrupt priority; kick before Dark Pact. Hold the pack still for the live split-damage visual.",
        "Corrupted Warlock — Dark Pact: interrupt or purge the defensive if it lands; keep control of the pack while the shield is down.",
        "Bribed Captain / Bribed Guard — live cast list: use visible danger cues and stop assigned casts; exact late-PTR cast priority requires live verification.",
        "Warehouse Worker — live cast list: interrupt or CC dangerous casts shown on live; workers no longer flee at 30%.",
      },
    },
    ["healer"] = {
      ["dispels"] = {
        "Heartstop Poison (Zaen Bladesorrow) — remove quickly when supported; otherwise use a personal and focused healing.",
        "Corroding Spittle (Kystia Manaheart) — remove the stacking Magic effect when available and stabilise the target.",
        "Corrupted Warlock — Dark Pact (trash): interrupt or purge the defensive if it lands; call the shield if your spec cannot purge.",
        "Corrupted Warlock — Curse of Doom (trash): prepare for split damage; follow the live stack visual.",
      },
      ["pressure"] = {
        "Destabilized (Kystia Manaheart) — sustain heavy party damage for the 15-sec window while the group bursts Kystia.",
        "Killing Spree (Zaen Bladesorrow) — top the group before the sequence and use a cooldown if players are uneven.",
        "Demonic Rage (Xathuux the Annihilator) — use a planned group cooldown and personals.",
        "Post-gateway Fire damage (Lithiel Cinderfury) — take the gateway immediately while maintaining healing range; heal lingering Fire damage after.",
        "Felmaster Lucsei — Blade Dance (trash): priority stop or move clear; never stack avoidable damage into it. Pre-heal the group hit and damage-over-time effect if the stop is missed.",
        "Defiled Golem — Defiled Slam (trash): prepare a direct tank heal.",
      },
      ["pullWarnings"] = {
        "Prepare a response for Felmaster Lucsei — Blade Dance.",
        "Bribed Captain / Bribed Guard — live cast list: use visible danger cues; exact late-PTR cast priority requires live verification.",
        "Warehouse Worker — live cast list: interrupt or CC dangerous casts shown on live; workers no longer flee at 30%.",
      },
    },
    ["dps"] = {
      ["purges"] = {
        "Corrupted Warlock — Dark Pact: purge or break the shield; live-verify its dispel type.",
      },
      ["defensives"] = {
        "Felmaster Lucsei — Blade Dance: priority stop or move clear; never stack avoidable damage into it. Prioritise Lucsei and use a personal defensive if caught.",
        "Corrupted Warlock — Curse of Doom: highest interrupt priority; follow the live split visual and do not guess the stack count if the kick is missed.",
        "Defiled Golem — Defiled Slam: leave the impact and use mitigation if targeted; stop it if the live build allows, otherwise use a defensive.",
        "Heartstop Poison (Zaen Bladesorrow): use a personal if targeted and allow the healer to remove it.",
        "Demonic Rage (Xathuux the Annihilator): use a personal and keep dealing damage if safe.",
        "Use personals for Killing Spree and add-heavy overlaps.",
      },
      ["pullWarnings"] = {
        "Exact trash kick and stop ranking needs live verification.",
        "Bribed Captain / Bribed Guard — live cast list: use visible danger cues; exact late-PTR cast priority requires live verification.",
        "Warehouse Worker — live cast list: interrupt or CC dangerous casts shown on live; workers no longer flee at 30%.",
      },
    },
    ["tip"] = {
      "Tank: Position, mitigation and pace — face trash and bosses away, plan mitigation for Chaos Barrage/Envenom/Legion Strike without overlapping every cooldown, and avoid combining Corrupted Warlock and Defiled Golem danger without a planned stop.",
      "Healer: Dispels and cooldowns — prioritise Heartstop Poison and Corroding Spittle when removable, plan around Curse of Doom, and cover Kystia's 15-sec Destabilized pulse and Xathuux's Demonic Rage.",
      "DPS: Interrupts and burst — assign both Mirror Image — Felstorm casts, stop Curse of Doom and Chaos Bolt, and save damage for Destabilized and Lithiel's empowered demons.",
      "Version 1.0, reviewed and verified 9 August 2026 against Blizzard PTR/launch notes, Wowhead, Wowhead Dungeon Journal data and Icy Veins; Syndicate Guild cross-checked only. Destabilized corrected from 20 sec to 15 sec; no other verified gameplay changes since 27 July 2026.",
      "Pre-launch verified for Midnight Season 2, Patch 12.1 PTR. Patch 12.1 launches 11 August; Mythic+ Season 2 opens 18 August 2026.",
      "Requires live verification: the 34:00 PTR timer, Burning Steps duration, opening/Warehouse Worker live cast priority, and any late PTR tuning.",
      "Tank: Plan Zaen cover and Xathuux movement space before each fight.",
      "Healer: Keep movement tools available so mechanics do not stop healing.",
      "DPS: Mechanic execution is worth more than boss uptime.",
    },
  },
  ["trashSegments"] = {
    {
      ["name"] = "Opening trash — before Kystia Manaheart",
      ["after"] = nil,
      ["npcs"] = {
        {
          ["name"] = "Bribed Captain",
          ["npcID"] = nil,
          ["displayID"] = nil,
        },
        {
          ["name"] = "Bribed Guard",
          ["npcID"] = nil,
          ["displayID"] = nil,
        },
      },
      ["roles"] = {
        ["TANK"] = {
          "Bribed Captain / Bribed Guard — live cast list: use visible danger cues and stop assigned casts; exact late-PTR cast priority requires live verification.",
          "Cantina — Five Star Review: complete the shortened event cleanly; do not pull extra civilians.",
          "Positioning — keep enemies faced away and leave room for Fel effects.",
        },
        ["HEALER"] = {
          "Bribed Captain / Bribed Guard — live cast list: use visible danger cues and stop assigned casts; exact late-PTR cast priority requires live verification.",
          "Cantina — Five Star Review: complete the shortened event cleanly; do not pull extra civilians.",
          "Positioning — keep enemies faced away and leave room for Fel effects.",
        },
        ["DPS"] = {
          "Bribed Captain / Bribed Guard — live cast list: use visible danger cues and stop assigned casts; exact late-PTR cast priority requires live verification.",
          "Cantina — Five Star Review: complete the shortened event cleanly; do not pull extra civilians.",
          "Positioning — keep enemies faced away and leave room for Fel effects.",
        },
      },
    },
    {
      ["name"] = "Kystia > Zaen trash",
      ["after"] = "Kystia Manaheart",
      ["npcs"] = {
        {
          ["name"] = "Warehouse Worker",
          ["npcID"] = nil,
          ["displayID"] = nil,
        },
      },
      ["roles"] = {
        ["TANK"] = {
          "Warehouse Worker — live cast list: interrupt or CC dangerous casts shown on live; workers no longer flee at 30%.",
          "Freight — do not destroy cover needed for Zaen's Murder in a Row.",
          "Heartstop Poison — use dispel/personal support when encountered.",
        },
        ["HEALER"] = {
          "Warehouse Worker — live cast list: interrupt or CC dangerous casts shown on live; workers no longer flee at 30%.",
          "Freight — do not destroy cover needed for Zaen's Murder in a Row.",
          "Heartstop Poison — use dispel/personal support when encountered.",
        },
        ["DPS"] = {
          "Warehouse Worker — live cast list: interrupt or CC dangerous casts shown on live; workers no longer flee at 30%.",
          "Freight — do not destroy cover needed for Zaen's Murder in a Row.",
          "Heartstop Poison — use dispel/personal support when encountered.",
        },
      },
    },
    {
      ["name"] = "Zaen > Xathuux trash",
      ["after"] = "Zaen Bladesorrow",
      ["npcs"] = {
        {
          ["name"] = "Felmaster Lucsei",
          ["npcID"] = nil,
          ["displayID"] = nil,
        },
      },
      ["roles"] = {
        ["TANK"] = {
          "Felmaster Lucsei — Blade Dance: priority stop or move clear; never stack avoidable damage into it.",
          "Pack control — stagger stops and avoid pulling through unsafe ground.",
        },
        ["HEALER"] = {
          "Felmaster Lucsei — Blade Dance: priority stop or move clear; never stack avoidable damage into it.",
          "Pack control — stagger stops and avoid pulling through unsafe ground.",
        },
        ["DPS"] = {
          "Felmaster Lucsei — Blade Dance: priority stop or move clear; never stack avoidable damage into it.",
          "Pack control — stagger stops and avoid pulling through unsafe ground.",
        },
      },
    },
    {
      ["name"] = "Xathuux > Lithiel trash",
      ["after"] = "Xathuux the Annihilator",
      ["npcs"] = {
        {
          ["name"] = "Corrupted Warlock",
          ["npcID"] = nil,
          ["displayID"] = nil,
        },
        {
          ["name"] = "Defiled Golem",
          ["npcID"] = nil,
          ["displayID"] = nil,
        },
      },
      ["roles"] = {
        ["TANK"] = {
          "Corrupted Warlock — Curse of Doom: highest interrupt priority.",
          "Corrupted Warlock — Dark Pact: interrupt or purge the defensive if it lands.",
          "Defiled Golem — Defiled Slam: leave the impact and use mitigation if targeted.",
        },
        ["HEALER"] = {
          "Corrupted Warlock — Curse of Doom: highest interrupt priority.",
          "Corrupted Warlock — Dark Pact: interrupt or purge the defensive if it lands.",
          "Defiled Golem — Defiled Slam: leave the impact and use mitigation if targeted.",
        },
        ["DPS"] = {
          "Corrupted Warlock — Curse of Doom: highest interrupt priority.",
          "Corrupted Warlock — Dark Pact: interrupt or purge the defensive if it lands.",
          "Defiled Golem — Defiled Slam: leave the impact and use mitigation if targeted.",
        },
      },
    },
  },
  ["bosses"] = {
    {
      ["name"] = "Kystia Manaheart",
      ["sheet"] = {
        ["TANK"] = "Nibbles 20% > kick images twice > burst Kystia.",
        ["HEALER"] = "Pre-heal Destabilized; images cannot free-cast.",
        ["DPS"] = "Nibbles 20% > kick images twice > burst boss.",
        ["WIPE"] = "Missed Felstorm interrupts or failed healing during Destabilized can end the pull.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 252458,
      ["displayID"] = 124578,
      ["wipe"] = {
        "Missed Felstorm interrupts or failed healing during Destabilized can end the pull.",
        "Felstorm overlaps Destabilized.",
        "Slow swaps allow several Felstorms together.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Hold Kystia steady while the group drains Nibbles to 20%; keep her positioned away from Nibbles.",
            "Kick Mirror Image — Felstorm; both images must be stopped.",
          },
          ["avoid"] = {
            "Fel Nova and Nibbles' Fel Spray.",
            "Move out after the Fel Nova teleport and avoid the knockback.",
          },
          ["defensive"] = {
            "Mitigate Chaos Barrage; keep nearby players clear of the jump where positioning allows.",
          },
          ["reminder"] = "Nibbles 20% > kick images twice > burst Kystia.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Track and dispel Corroding Spittle; stabilise the target.",
            "Pre-heal Destabilized; sustain heavy party damage for the 15-sec window while the group bursts Kystia.",
            "Help stop Mirror Image — Felstorm if your toolkit allows; heal only unavoidable residue.",
          },
          ["avoid"] = {
            "Fel Nova and Nibbles' Fel Spray; prepare spot healing after mistakes.",
          },
          ["cooldowns"] = {
            "Use a healing cooldown if an image remains active.",
          },
          ["reminder"] = "Pre-heal Destabilized; images cannot free-cast.",
        },
        ["DPS"] = {
          ["job"] = {
            "Push Nibbles below 20% without wasting burst on Kystia's Felshield, then swap to images and burst Kystia.",
            "Mirror Image — Felstorm: assign one interrupt to each image; two interrupts required on Mythic/Mythic+.",
          },
          ["avoid"] = {
            "Fel Nova and Fel Spray — leave the cone and teleport impact.",
            "Melee save mobility.",
            "Ranged own far kicks.",
          },
          ["defensive"] = {
            "Personal during Destabilized if images remain; otherwise commit offensive cooldowns during the 15-sec window.",
          },
          ["reminder"] = "Nibbles 20% > kick images twice > burst boss.",
        },
      },
    },
    {
      ["name"] = "Zaen Bladesorrow",
      ["sheet"] = {
        ["TANK"] = "Preserve one box > defensive on Envenom > hide.",
        ["HEALER"] = "Cover first > heal Spree > protect tank.",
        ["DPS"] = "Bomb away > hide at 100 > reconnect.",
        ["WIPE"] = "Destroyed or missed freight cover makes Murder in a Row lethal.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 234649,
      ["displayID"] = 124592,
      ["wipe"] = {
        "Destroyed or missed freight cover makes Murder in a Row lethal.",
        "Missing cover applies heavy damage and a long bleed.",
        "Destroying all safe freight before 100 energy leaves no safe cover for Murder in a Row.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Keep Zaen near safe Forbidden Freight.",
            "Call Envenom and mitigate the tank hit; call for Heartstop Poison removal.",
            "Re-engage cleanly after the Killing Spree cover sequence; keep Zaen positioned away from the group.",
          },
          ["avoid"] = {
            "Hide behind intact freight for Murder in a Row at 100 energy.",
            "Keep Fire Bomb away from planned cover.",
          },
          ["defensive"] = {
            "Major defensive for Envenom while maximum health is reduced.",
          },
          ["reminder"] = "Preserve one box > defensive on Envenom > hide.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Track Envenom and Heartstop Poison; dispel promptly when supported, otherwise commit focused healing.",
            "Reach cover early; keep line-of-sight considerations in mind.",
            "Top the group before Killing Spree and use a cooldown if players are uneven; stabilise the tank after.",
          },
          ["avoid"] = {
            "Same-Day Delivery, Fire Bomb and exploding freight.",
          },
          ["cooldowns"] = {
            "Group cooldown for Killing Spree; external for Envenom.",
          },
          ["reminder"] = "Cover first > heal Spree > protect tank.",
        },
        ["DPS"] = {
          ["job"] = {
            "Pre-position by cover and place Fire Bomb away from freight still needed.",
            "No boss kick priority; execute cover and bomb placement.",
          },
          ["avoid"] = {
            "Stop damage and hide behind intact freight for Murder in a Row at 100 energy.",
            "Melee leave early.",
            "Ranged place bombs wide.",
          },
          ["defensive"] = {
            "Personal for Heartstop Poison if targeted (let the healer finish the removal), Killing Spree, or a late cover move.",
          },
          ["reminder"] = "Bomb away > hide at 100 > reconnect.",
        },
      },
    },
    {
      ["name"] = "Xathuux the Annihilator",
      ["sheet"] = {
        ["TANK"] = "Front away > edge-kite Rage > preserve room.",
        ["HEALER"] = "External before Strike > cooldown for Rage.",
        ["DPS"] = "Behind boss > dodge axe > burst Rage.",
        ["WIPE"] = "Demonic Rage plus Burning Steps punishes poor spacing and late defensives.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 234647,
      ["displayID"] = 140268,
      ["wipe"] = {
        "Demonic Rage plus Burning Steps punishes poor spacing and late defensives.",
        "Legion Strike hits the group and applies 80% healing reduction.",
        "A Strike clip applies 80% healing reduction for 12 seconds; several players taking it becomes difficult to heal.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Face Legion Strike away and use active mitigation.",
            "Edge-kite Demonic Rage; keep control of boss position during the damage spike.",
            "Burning Steps last 120 seconds on PTR — move deliberately and preserve safe floor.",
          },
          ["avoid"] = {
            "Axe Toss, persistent axe zones and pointing Legion Strike at allies.",
          },
          ["defensive"] = {
            "Mitigate Legion Strike.",
            "Major defensive for Rage's faster melees.",
          },
          ["reminder"] = "Front away > edge-kite Rage > preserve room.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Pre-heal the tank before Legion Strike and watch for overlap with avoidable damage.",
            "Prepare for Demonic Rage.",
            "Keep moving and heal without standing in Burning Steps; do not cast from unsafe ground.",
          },
          ["avoid"] = {
            "Axe Toss, persistent axes and the boss front.",
          },
          ["cooldowns"] = {
            "External before Legion Strike.",
            "Group cooldown for Rage.",
          },
          ["reminder"] = "External before Strike > cooldown for Rage.",
        },
        ["DPS"] = {
          ["job"] = {
            "Stay behind, follow the edge-kite and burst during Rage's 30% damage-taken window.",
            "No boss interrupt; prioritise safe Rage uptime.",
          },
          ["avoid"] = {
            "Axe Toss and Legion Strike — never cross the frontal.",
            "Move out immediately for Burning Steps and keep safe space for later.",
          },
          ["defensive"] = {
            "Personal during Demonic Rage; keep dealing damage if safe.",
          },
          ["reminder"] = "Behind boss > dodge axe > burst Rage.",
        },
      },
    },
    {
      ["name"] = "Lithiel Cinderfury",
      ["sheet"] = {
        ["TANK"] = "Adds first > kick Bolt > click gateway.",
        ["HEALER"] = "Top > spread > gateway > recover.",
        ["DPS"] = "Kick Bolt > kill demons > click gateway.",
        ["WIPE"] = "Missing the gateway or leaving empowered demons alive can overwhelm the group.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 234763,
      ["displayID"] = 124577,
      ["wipe"] = {
        "Missing the gateway or leaving empowered demons alive can overwhelm the group.",
        "Surviving demons gain 100% haste if the boss tunnels through the gateway.",
        "Missed gateway or empowered demons create lethal pressure.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Pick up demons quickly for clean cleave.",
            "Help kick Chaos Bolt when assigned; do not turn the boss unpredictably.",
            "Kill adds before Malefic Wave.",
            "Use the gateway promptly, then re-establish boss position.",
          },
          ["avoid"] = {
            "Spread 6+ yards for Fingers of the Legion without dragging the boss through allies.",
            "Keep Infernal aura away.",
          },
          ["defensive"] = {
            "Cover Vilefiend and stacked add pressure.",
          },
          ["reminder"] = "Adds first > kick Bolt > click gateway.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Pre-position by the gateway.",
            "Track add damage and help control empowered demons during pressure.",
            "Top before crossing; heal lingering Fire damage after.",
            "Prepare a spot heal if Chaos Bolt lands.",
            "Take the gateway immediately while maintaining healing range.",
          },
          ["avoid"] = {
            "Spread 6+ yards.",
            "Avoid Infernal aura.",
          },
          ["cooldowns"] = {
            "Cooldown if demons survive into Malefic Wave.",
          },
          ["reminder"] = "Top > spread > gateway > recover.",
        },
        ["DPS"] = {
          ["job"] = {
            "Kill Imps, Vilefiend and Infernal before the wave.",
            "Hard swap onto summoned demons and cleave; prioritise empowered demons.",
            "Chaos Bolt: maintain an interrupt rotation; adds before boss for cleave priority.",
            "Pre-position for the gateway; take it immediately.",
          },
          ["avoid"] = {
            "Spread at least 6 yd for Fingers of the Legion and avoid clipping allies.",
            "Melee avoid Infernal aura.",
          },
          ["defensive"] = {
            "Personal during add-heavy overlaps.",
          },
          ["reminder"] = "Kick Bolt > kill demons > click gateway.",
        },
      },
    },
  },
})
