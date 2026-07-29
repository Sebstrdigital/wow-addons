-- GENERATED FILE — do not edit by hand.
-- Source: content/midnight-s2/the-blinding-vale.yaml   (regenerate with tools/generate.py)
local _, ns = ...

ns.RegisterDungeon({
  ["dungeon"] = "The Blinding Vale",
  ["slug"] = "the-blinding-vale",
  ["season"] = "midnight-s2",
  ["patch"] = "12.1.0",
  ["sourceVersion"] = "0.9",
  ["instanceID"] = nil,
  ["quicksheet"] = {
    ["trash"] = {
      ["TANK"] = "INTERRUPT: Radiant Spellsower — Frantic Blooming; Lightwarden Ruia — Warden's Wrath.; MITIGATE: Luminous Thornmaw — Grievous Gash; Virid Grovekeeper — Earthrupture Strike.; POSITION: Luminous Thornmaw — Solar Breath; Sporeblight Belcher — Lightwarden's Blight.",
      ["HEALER"] = "HEAL: Sporeblight Belcher — Spouting Floret; Potatoad Matriarch — Toxic Spew.; TOP TO FULL: Luminous Thornmaw — Grievous Gash; Lightwarden Ruia — Grievous Thrash.; MOVE: Virid Grovekeeper — Uproot; Overgrown Hydra — Lightmaw Beams.; LIVE CHECK: Bloodthorn Roots dispel type and final tuning.",
      ["DPS"] = "INTERRUPT: Radiant Spellsower — Frantic Blooming; Lightwarden Ruia — Warden's Wrath.; STOP DAMAGE: Spineshield Beetle — Spiny Shield reflects attacks.; KILL FIRST: Pollinating Lashers, roots, Potadpole eggs and boss shields.; MOVE: Thorny Saptor — Thornclaw Leap; Overgrown Hydra — Lightmaw Beams.",
      ["ROUTE"] = "Current PTR left path; final placement requires live verification.",
    },
  },
  ["overview"] = {
    ["interrupts"] = {
      {
        ["spell"] = "Frantic Blooming",
        ["note"] = "Radiant Spellsower — must stop",
      },
      {
        ["spell"] = "Warden's Wrath",
        ["note"] = "Lightwarden Ruia — must stop",
      },
    },
    ["killPriority"] = {
      "Pollinating Lashers",
      "Blocking roots",
      "Potadpole eggs",
      "Ziekket's shield",
    },
    ["tank"] = {
      ["damage"] = {
        "Luminous Thornmaw — Grievous Gash",
        "Trinity — Bedrock Slam",
        "Ziekket — Thornspike",
      },
      ["pullWarnings"] = {
        "Do not combine Pollination, Spiny Shield and heavy caster pressure without stops.",
        "Mitigate: Luminous Thornmaw — Grievous Gash; Virid Grovekeeper — Earthrupture Strike.",
        "Position: Luminous Thornmaw — Solar Breath; Sporeblight Belcher — Lightwarden's Blight.",
      },
    },
    ["healer"] = {
      ["dispels"] = {
        "Bloodthorn Roots dispel type and final tuning need live confirmation.",
      },
      ["pressure"] = {
        "Heal first: Spouting Floret, Bedrock Surge, Lightcrazed Frenzy, Grievous Thrash and Oozing Xylem.",
        "Sporeblight Belcher — Spouting Floret; Potatoad Matriarch — Toxic Spew.",
        "Top to full: Luminous Thornmaw — Grievous Gash; Lightwarden Ruia — Grievous Thrash.",
      },
      ["pullWarnings"] = {
        "Toxic Spew plus Spouting Floret can create a dangerous party-damage overlap.",
        "Move for Virid Grovekeeper — Uproot and Overgrown Hydra — Lightmaw Beams.",
      },
    },
    ["dps"] = {
      ["purges"] = {
        "Spineshield Beetle — Spiny Shield reflects attacks; stop attacking into the reflect and break the absorb.",
        "Kill first: Pollinating Lashers, roots, Potadpole eggs and boss shields.",
      },
      ["pullWarnings"] = {
        "Stop attacking into Spineshield Beetle — Spiny Shield.",
        "Move: Thorny Saptor — Thornclaw Leap; Overgrown Hydra — Lightmaw Beams.",
      },
      ["defensives"] = {
        "Save personals for scheduled party damage; do not spend them after the hit.",
      },
    },
    ["tip"] = {
      "Tank: Use the current left-path PTR route; keep death pools and frontals away from the party.",
      "Healer: Pre-position for beam mechanics so movement does not interrupt recovery healing.",
      "DPS: Save personals for scheduled party damage; do not spend them after the hit.",
    },
  },
  ["bosses"] = {
    {
      ["name"] = "Lightblossom Trinity",
      ["sheet"] = {
        ["TANK"] = "Steady bosses, mitigate Slam, block the beam.",
        ["HEALER"] = "Heal Surge, support the bleed, protect the soak.",
        ["DPS"] = "Kick Light Bolt; dodge plants; block beam.",
        ["WIPE"] = "Block Lightblossom Beam; Light-Gorged becomes Overgrowth after 10 sec.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 243028,
      ["displayID"] = 129588,
      ["wipe"] = {
        "Block Lightblossom Beam; Light-Gorged becomes Overgrowth after 10 sec.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Keep the trio steady for cleave.",
            "Point movement away.",
            "Assign the beam intercept.",
          },
          ["avoid"] = {
            "Fertile Loam, seed impacts and Fan of Thorns within 15 yd.",
          },
          ["defensive"] = {
            "Mitigate Bedrock Slam.",
            "Use a personal during Bedrock Surge overlaps.",
          },
          ["reminder"] = "Steady bosses, mitigate Slam, block the beam.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Stabilise shared-health pressure and protect the assigned beam interceptor.",
            "Bedrock Surge pulses for 8 sec; recover the Thornblade bleed before the next hit.",
          },
          ["avoid"] = {
            "Fertile Loam, seeds, Fan of Thorns and unassigned beam contact.",
          },
          ["cooldowns"] = {
            "Use a group cooldown for a poor Bedrock Surge overlap.",
          },
          ["reminder"] = "Heal Surge, support the bleed, protect the soak.",
        },
        ["DPS"] = {
          ["job"] = {
            "Cleave the shared health pool and execute the assigned beam intercept.",
            "Priority: Kezkitt — Light Bolt; beam intercept before damage.",
          },
          ["avoid"] = {
            "Fertile Loam, seeds, Dash lanes and Fan of Thorns.",
          },
          ["defensive"] = {
            "Use a personal during Bedrock Surge or while intercepting.",
          },
          ["reminder"] = "Kick Light Bolt, dodge plants, block the beam.",
        },
      },
    },
    {
      ["name"] = "Ikuzz the Light Hunter",
      ["sheet"] = {
        ["TANK"] = "Clear roots, open the lane, never let Ikuzz connect.",
        ["HEALER"] = "Pre-heal, support the kite, avoid Footfalls.",
        ["DPS"] = "Open lane; kite Gaze; avoid Footfalls.",
        ["WIPE"] = "If Ikuzz catches the fixate, Incise and Crunched add a bleed and 5 sec stun.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 244887,
      ["displayID"] = 129424,
      ["wipe"] = {
        "If Ikuzz catches the fixate, Incise and Crunched add a bleed and 5 sec stun.",
        "A trapped or caught Gaze target can die during Crunched.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Keep roots out of the kite lane.",
            "Use Crushing Footfalls to destroy them.",
          },
          ["avoid"] = {
            "Standing within 7 yd during Bloodthirsty Gaze.",
            "Blocking the kite path.",
          },
          ["defensive"] = {
            "Use a personal for Lightcrazed Frenzy or a bad Verdant Stomp recovery.",
          },
          ["reminder"] = "Clear roots, open the lane, never let Ikuzz connect.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Support the Gaze target and pre-heal Thorncaller Roar and Frenzy.",
            "Lightcrazed Frenzy pulses; a caught target is stunned for 5 sec.",
          },
          ["avoid"] = {
            "Verdant Stomp roots after 4 sec on Mythic.",
            "Avoid Crushing Footfalls.",
          },
          ["cooldowns"] = {
            "Plan a group cooldown for Frenzy.",
            "External a trapped fixate target.",
          },
          ["reminder"] = "Pre-heal, support the kite, avoid Footfalls.",
        },
        ["DPS"] = {
          ["job"] = {
            "Break roots blocking the route and kite Gaze through a clear lane.",
            "Priority: Bloodthorn Roots that block the fixate path.",
          },
          ["avoid"] = {
            "The 7 yd Footfalls zone.",
            "Crossing the fixated player's route.",
          },
          ["defensive"] = {
            "Use a personal during Frenzy or when targeted by Gaze.",
          },
          ["reminder"] = "Open the lane, kite Gaze, avoid Footfalls.",
        },
      },
    },
    {
      ["name"] = "Lightwarden Ruia",
      ["sheet"] = {
        ["TANK"] = "Kick Wrath, walk the cones, let the healer top.",
        ["HEALER"] = "Top to full, move for Lightfire, cooldown below 40%.",
        ["DPS"] = "Kick Wrath; place beams wide; clean below 40%.",
        ["WIPE"] = "Grievous Thrash clears only at full health; Lightfire damages and silences.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 245912,
      ["displayID"] = 129856,
      ["wipe"] = {
        "Grievous Thrash clears only at full health; Lightfire damages and silences.",
        "Multiple uncleared Grievous Thrash bleeds quickly snowball.",
        "Missed Warden's Wrath overwhelms the healer.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Face bear cones away.",
            "Interrupt Warden's Wrath.",
            "Create a clean top-up window.",
          },
          ["avoid"] = {
            "Lightfall, Lightfire beams and repeated Pulverizing Strikes hits.",
          },
          ["defensive"] = {
            "Rotate mitigation through Pulverizing Strikes.",
            "Major personal below 40%.",
          },
          ["reminder"] = "Kick Wrath, walk the cones, let the healer top.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Top every player to clear Grievous Thrash.",
            "Move before Lightfire expires.",
            "Below 40%, Spirits of the Vale repeats abilities every 8 sec.",
          },
          ["avoid"] = {
            "Lightfire beams, Lightfall and tank-facing cones.",
          },
          ["cooldowns"] = {
            "Save a group cooldown for the sub-40% sequence.",
          },
          ["reminder"] = "Top to full, move for Lightfire, cooldown below 40%.",
        },
        ["DPS"] = {
          ["job"] = {
            "Place Lightfire wide and keep movement clean below 40%.",
            "Priority: Lightwarden Ruia — Warden's Wrath.",
          },
          ["avoid"] = {
            "Pulverizing Strikes cones, Lightfall and Lightfire beams.",
          },
          ["defensive"] = {
            "Use a personal below 40% or while waiting to be topped.",
          },
          ["reminder"] = "Kick Wrath, place beams wide, stay clean below 40%.",
        },
      },
    },
    {
      ["name"] = "Ziekket",
      ["sheet"] = {
        ["TANK"] = "Beam Lashers, manage orbs, brace for Thornspike.",
        ["HEALER"] = "Heal the pulse, watch orb stacks, protect Thornspike.",
        ["DPS"] = "Dormant at 1%; beam Lashers; catch assigned orbs.",
        ["WIPE"] = "Essence reaching Ziekket triggers Fluorescent Outburst, shield and damage gain.",
      },
      ["encounterID"] = nil,
      ["npcID"] = 247676,
      ["displayID"] = 136619,
      ["wipe"] = {
        "Essence reaching Ziekket triggers Fluorescent Outburst, shield and damage gain.",
        "Uncaught Essence empowers Ziekket; excessive stacks can kill the interceptor.",
      },
      ["roles"] = {
        ["TANK"] = {
          ["job"] = {
            "Aim Concentrated Lightbeam through dormant Lashers.",
            "Control boss and orb lanes.",
          },
          ["avoid"] = {
            "Lightsap puddles and unassigned Essence orbs.",
          },
          ["defensive"] = {
            "Mitigate Thornspike and its bleed.",
            "Personal during Oozing Xylem.",
          },
          ["reminder"] = "Beam Lashers, manage orbs, brace for Thornspike.",
        },
        ["HEALER"] = {
          ["job"] = {
            "Heal Oozing Xylem and support assigned Essence interceptors.",
            "Each orb grants 10% output but adds a stacking 12 sec self-DoT.",
          },
          ["avoid"] = {
            "Lightsap puddles, unassigned orbs and the beam lane.",
          },
          ["cooldowns"] = {
            "Plan group healing for Xylem with orb DoTs active.",
          },
          ["reminder"] = "Heal the pulse, watch orb stacks, protect Thornspike.",
        },
        ["DPS"] = {
          ["job"] = {
            "Bring Lashers to 1% Dormant, beam through them and intercept assigned orbs.",
            "Priority: Dormant Lasher setup; break Ziekket's shield if an orb reaches him.",
          },
          ["avoid"] = {
            "Lightsap puddles, unassigned orbs and the beam lane.",
          },
          ["defensive"] = {
            "Use a personal during Xylem or with multiple orb stacks.",
          },
          ["reminder"] = "Dormant at 1%, beam Lashers, catch assigned orbs.",
        },
      },
    },
  },
})
