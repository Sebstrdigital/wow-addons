# World of Warcraft Addon Development Guide

*Researched and written July 2026. Live retail patch: Midnight 12.0.7 (`Interface: 120007`). Patch 12.1.0 "Curse of Ula'tek" ships August 11, 2026 (`120100`), with Mythic+ Season 2 starting August 18.*

This guide covers what a retail WoW addon is made of, how the runtime environment works, which libraries and tools the community standardizes on, and how addons are packaged and distributed. It also covers the single most important development of the last year: the **Secret Values system** introduced with Midnight, which fundamentally changed what combat-related addons are allowed to do.

---

## 1. What an addon is

An addon is a folder of Lua and XML files that the WoW client loads into its UI environment at login. It lives at:

```
World of Warcraft/_retail_/Interface/AddOns/MyAddon/
├── MyAddon.toc      ← manifest; basename MUST match the folder name
├── Main.lua
├── Options.lua
└── Libs/            ← embedded libraries (LibStub, Ace3, …)
```

There is no compilation step and no install process beyond placing the folder — the client discovers it at startup. During development you iterate with `/reload` in-game.

Addons run sandboxed: Lua 5.1 (with Blizzard extensions) with no filesystem, network, or OS access. The only persistence is the SavedVariables mechanism (§5), and the only outside communication is the in-game addon message channel (§9).

## 2. The .toc manifest

The `.toc` file declares metadata and lists the files to load, in order:

```
## Interface: 120007, 120100
## Title: My Addon
## Author: Yourname
## Version: @project-version@
## Notes: Short description shown in the addon list.
## SavedVariables: MyAddonDB
## OptionalDeps: Ace3
## IconTexture: Interface\AddOns\MyAddon\icon

Libs\LibStub\LibStub.lua
Main.lua
Options.lua
```

Key points:

- **`## Interface`** is the client build the addon targets, formed by stripping periods from the patch version (12.0.7 → `120007`). It accepts a comma-separated list; declaring `120007, 120100` keeps the addon loading through the 12.1 release. **As of Midnight, addons whose TOC doesn't declare `120000` or higher do not load at all.**
- **File paths** load in listed order. Use backslashes (`subfolder\file.lua`).
- **`## SavedVariables`** / `## SavedVariablesPerCharacter`** name the global variables the client persists (§5).
- **`## Dependencies`** hard-requires another addon; **`## OptionalDeps`** just loads it first if present.
- **Addon Compartment**: `## AddonCompartmentFunc` (plus `IconTexture`/`IconAtlas`) puts your addon in the native minimap addon drawer — the modern alternative to a LibDBIcon minimap button.
- **Multi-flavor support**: the client first looks for a game-flavor-specific TOC (retail: `MyAddon_Standard.toc`; also `_Mists`, `_Vanilla`, etc.), falling back to `MyAddon.toc`. The wiki now recommends a *single* TOC with comma-separated Interface versions and per-line conditionals instead:

```
MainlineOnly.lua [AllowLoadGameType mainline]
Localization\[TextLocale].lua
```

Reference: <https://warcraft.wiki.gg/wiki/TOC_format>

## 3. The Lua environment

Every Lua file in your addon receives two varargs — the addon's name and a private table shared across all of that addon's files. This is the idiomatic way to structure an addon without polluting globals:

```lua
-- FileA.lua
local addonName, ns = ...
ns.version = "1.0"

-- FileB.lua
local addonName, ns = ...
print(addonName, ns.version)   -- "MyAddon 1.0"
```

The environment gives you:

- **Global API functions** (`UnitName`, `GetInstanceInfo`, …) and namespaced **`C_*` systems** (`C_Timer`, `C_Map`, `C_ChallengeMode`, `C_ChatInfo`, …). Newer APIs live in `C_*` namespaces.
- **Widgets**: everything visual is a frame. `CreateFrame("Frame"|"Button"|"StatusBar"|…)` creates one; textures and font strings hang off frames. See the Widget API: <https://warcraft.wiki.gg/wiki/Widget_API>
- **`Enum.*`** constant tables, mixins, and Blizzard's own UI code (readable — see §11).

## 4. Events — how addons react to the game

Events are delivered to frames. The minimal addon:

```lua
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self, event, ...)
    print("event fired:", event)
end)
```

- `RegisterUnitEvent("UNIT_HEALTH", "player")` filters unit events server-side — prefer it over registering broadly and filtering in Lua.
- `OnUpdate` runs every frame and receives `elapsed`; it's a performance foot-gun. Prefer events, or `C_Timer.After`/`C_Timer.NewTicker` for scheduled work.
- Full event list: <https://warcraft.wiki.gg/wiki/Events_(API)>. In-game, `/eventtrace` shows events firing live.

## 5. SavedVariables — persistence

Declare global variable names in the TOC; the client writes them to disk on logout and restores them at login:

- `## SavedVariables` → account-wide (`WTF/Account/<acct>/SavedVariables/MyAddon.lua`) — settings, profiles.
- `## SavedVariablesPerCharacter` → per character.

Pitfalls worth memorizing:

1. Saved variables load **after** your Lua files execute. Initialize defaults in an `ADDON_LOADED` handler (checking the addon name), not at file scope — file-scope defaults get overwritten by the load.
2. Only strings, numbers, booleans, and tables persist. Functions don't; shared table references are split into separate copies; circular references may break.
3. **Since Midnight: saved variables cannot contain secret values** — they serialize to `nil` (§8).

## 6. Slash commands, key bindings, options

**Slash commands** are two globals:

```lua
SLASH_MYADDON1, SLASH_MYADDON2 = "/myaddon", "/mya"
SlashCmdList.MYADDON = function(msg, editBox)
    print("args:", msg)
end
```

**Key bindings** are declared in a `Bindings.xml` plus `BINDING_HEADER_*`/`BINDING_NAME_*` global strings, and managed via `SetBinding`/`GetBindingKey` (note: override-binding APIs are blocked in combat).

**Options panels** use the Settings API (the old `InterfaceOptions_AddCategory` is gone since 10.0):

```lua
local category = Settings.RegisterVerticalLayoutCategory("My Addon")
Settings.RegisterAddOnCategory(category)

local setting = Settings.RegisterAddOnSetting(category, "MyAddon_enabled", "enabled",
    MyAddonDB, "boolean", "Enable thing", true)
Settings.CreateCheckbox(category, setting, "Tooltip description.")
```

Sliders and dropdowns follow the same pattern; `Settings.RegisterCanvasLayoutCategory(frame, name)` embeds a fully custom frame instead. Open programmatically with `Settings.OpenToCategory(category:GetID())`. Guide: <https://warcraft.wiki.gg/wiki/Creating_a_settings_menu>

## 7. Taint and secure execution

The client distinguishes **secure** (Blizzard) code from **tainted** (addon) code. Protected functions — casting, targeting, using items, moving protected frames in combat — can only run securely or from a genuine hardware event. Touching secure state from addon code "taints" it, which can break Blizzard UI until `/reload`.

Rules of thumb:

- Never overwrite Blizzard functions. Post-hook safely with `hooksecurefunc("Name", fn)` and `frame:HookScript("OnClick", fn)`.
- Check `InCombatLockdown()` before showing/hiding/moving anything that is (or is anchored to) a protected frame. Plain display frames you create yourself are not protected and can be toggled in combat.
- Secure templates (`SecureActionButtonTemplate`) are the sanctioned path for buttons that cast spells.

Deep dive: <https://warcraft.wiki.gg/wiki/Secure_Execution_and_Tainting>

## 8. Secret Values — the big Midnight change (must read)

With Midnight (12.0, early 2026), Blizzard shipped the "addon disarmament": **combat-state information is now wrapped in opaque "secret values" that addons can display but not inspect.** Ion Hazzikostas' framing: *"combat events are in a black box; addons can change the size or shape of the box, and they can paint it a different color, but what they can't do is look inside the box."*

Mechanics:

- A secret wraps any Lua value. Tainted code can store it, pass it around, concatenate it, `string.format` it, and hand it to display APIs (`FontString:SetText`, etc.). It **cannot** compare it, do arithmetic on it, use it as a table key, index it, or take its length — all of those raise Lua errors. Test with `issecretvalue(v)`.
- Secrecy activates under named **restriction scopes**: combat, instance encounter, **challenge mode (Mythic+ — active for the whole timed run)**, PvP match, restricted maps. Each has a force-on CVar for testing (e.g. `secretChallengeModeRestrictionsForced`).
- **Dead for addons:** `COMBAT_LOG_EVENT_UNFILTERED` (registering it errors), creature names/GUIDs/npcIDs inside instances (unconditionally secret), reading auras to drive logic (further locked down in 12.1), boss unit comparisons.
- **Still alive:** all cosmetic/UI customization; zone and instance metadata (`GetInstanceInfo`); `ENCOUNTER_START`/`ENCOUNTER_END`; keystone level and affixes (`C_ChallengeMode`); your own role/spec; static pre-authored content; **duration objects** (`StatusBar:SetTimerDuration(durationObject)`, `Cooldown:SetCooldownFromDurationObject(...)`) — the sanctioned way to render timers over data you can't read; `C_EncounterEvents.SetEventColor/SetEventSound` to restyle Blizzard's built-in boss warnings.
- **Anchoring trap:** feeding a secret into a widget can mark the whole frame's layout data secret, and that propagates to children — your own code then can't read `GetPoint()` on it. Keep secret-displaying widgets in a separate frame tree from frames whose positions you save. Check with `frame:IsAnchoringSecret()`.
- Addon comms are blocked during active keys, PvP matches, and boss encounters (§9).
- Consequences in the wild: WeakAuras is effectively dead as a combat tool; DBM/BigWigs now reformat Blizzard's native Encounter Timeline instead of tracking mechanics themselves; combat-log *files* (Warcraft Logs) are unaffected.

Direction of travel is **tighter every patch** (12.1 locks down aura access further). Do not design anything premised on reading live combat state.

Sources: <https://news.blizzard.com/en-us/article/24246290/combat-philosophy-and-addon-disarmament-in-midnight> · <https://warcraft.wiki.gg/wiki/Secret_Values> · <https://warcraft.wiki.gg/wiki/Patch_12.0.0/Planned_API_changes>

## 9. Addon-to-addon communication

`C_ChatInfo.RegisterAddonMessagePrefix("MyPrefix")` (max 16 chars, re-register after every reload), then `C_ChatInfo.SendAddonMessage(prefix, msg, "PARTY"|"RAID"|"GUILD"|"WHISPER", target)`; receive via `CHAT_MSG_ADDON`. Messages are capped at 255 bytes and throttled, so the community stack is:

```lua
local serialized = LibSerialize:Serialize(data)
local compressed = LibDeflate:CompressDeflate(serialized)
local encoded    = LibDeflate:EncodeForWoWAddonChannel(compressed)
self:SendCommMessage("MyPrefix", encoded, "PARTY")   -- AceComm chunks + throttles
```

**Midnight restriction:** sends fail (`Enum.SendAddonMessageResult.AddOnMessageLockdown`) while a keystone run is active, a PvP match is running, or a boss encounter is in progress. The proven pattern (used by Cell and others) is to guard every send with a restriction check, queue failures, and flush the queue on `ENCOUNTER_END` / key completion.

## 10. Standard libraries

All loaded through **LibStub**, the tiny versioned loader every library registers with.

| Library | What it does |
|---|---|
| **Ace3** | The framework suite: AceAddon (lifecycle), AceDB (SavedVariables profiles), AceConfig (declarative options → GUI + slash), AceGUI (widgets), AceEvent, AceComm (chunked messaging), AceHook, AceTimer, AceLocale, AceConsole, AceSerializer, AceBucket |
| **CallbackHandler-1.0** | Pub/sub backbone used by AceEvent, LDB, LSM |
| **LibSharedMedia-3.0** | Shared registry of fonts/sounds/textures across UI addons |
| **LibDataBroker-1.1** + **LibDBIcon-1.0** | Data-object broker + minimap button |
| **LibSerialize** + **LibDeflate** | Modern serialize/compress stack for comms and `!WA:2!`-style export strings |
| **LibCustomGlow-1.0** | Button/frame glow effects |

Libraries are embedded via the packager's `.pkgmeta` `externals` (§12) rather than vendored by hand. Starter guide: <https://warcraft.wiki.gg/wiki/Ace3_for_Dummies>

## 11. Development tooling

- **Editor**: VS Code + the Lua language server (`sumneko.lua`) + the **Ketho WoW API extension** (<https://github.com/Ketho/vscode-wow-api>) — full API autocomplete/docs from Blizzard's own generated documentation. Set `"Lua.runtime.version": "Lua 5.1"`.
- **Linting**: `luacheck` with `std = "lua51"` and a WoW globals list (BigWigs maintains a generated one: <https://github.com/BigWigsMods/luacheck>).
- **In-game**: `/reload`, `/console scriptErrors 1`, `/dump expr`, `/run code`, `/eventtrace`, `/fstack` (frame under cursor), plus the **DevTool** addon (table/event inspector) and **BugSack + BugGrabber** (error capture).
- **Testing combat restrictions cheaply**: force scopes with the `secret*RestrictionsForced` CVars; Blizzard also added a test encounter with spell-spamming dummies near The MOTHERLODE!! dungeon entrance specifically for addon authors.
- **Ground truth for APIs**: the community wiki <https://warcraft.wiki.gg> (API, Widget API, Events, per-patch API-change pages), the in-game `/api` browser, and Blizzard's UI source mirror <https://github.com/Gethe/wow-ui-source> (live/ptr/beta branches). <https://wago.tools> browses game data per build. Blizzard's addon-facing announcements land in the **wowuidev Discord**.

## 12. Packaging, releasing, distributing

The standard is the **BigWigs packager** (<https://github.com/BigWigsMods/packager>) driven by GitHub Actions: push a git tag → it builds the zip (pulling library `externals`), generates a changelog, and uploads to GitHub Releases and optionally CurseForge/Wago/WoWInterface.

`.pkgmeta` in the repo root:

```yaml
package-as: MyAddon
externals:
  Libs/LibStub:
    url: https://repos.wowace.com/wow/libstub/trunk
  Libs/CallbackHandler-1.0:
    url: https://repos.wowace.com/wow/callbackhandler/trunk/CallbackHandler-1.0
  Libs/AceAddon-3.0:
    url: https://repos.wowace.com/wow/ace3/trunk/AceAddon-3.0
ignore:
  - README.md
  - tools
```

Workflow (`.github/workflows/release.yml`):

```yaml
name: Package and release
on:
  push:
    tags: ['**']
jobs:
  release:
    runs-on: ubuntu-latest
    env:
      GITHUB_OAUTH: ${{ secrets.GITHUB_TOKEN }}
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }
      - uses: BigWigsMods/packager@v2
```

(Repo Settings → Actions → Workflow permissions must be read-write, or the release upload fails.) `## Version: @project-version@` in the TOC is substituted with the tag at package time.

**Distribution channels**: CurseForge (largest), Wago Addons, WoWInterface, or plain GitHub Releases. Users install via the CurseForge app, **WowUp** (which can install straight from a GitHub Releases URL — the zip must contain the addon folder(s) at its root), or CLI tools.

**Blizzard's addon policy**: addons must be free of charge, code fully visible (no obfuscation), no ads, no donation solicitation, and must not harm the service. Blizzard reserves the right to break any addon at any time — Midnight proved they mean it.

## 13. Minimal skeleton to start from

```
MyAddon/
├── MyAddon.toc
├── Core.lua
└── .pkgmeta            (only needed once you package releases)
```

```lua
-- Core.lua
local addonName, ns = ...

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        MyAddonDB = MyAddonDB or { enabled = true }   -- defaults
    elseif event == "PLAYER_ENTERING_WORLD" then
        print(addonName .. " loaded.")
    end
end)

SLASH_MYADDON1 = "/myaddon"
SlashCmdList.MYADDON = function(msg)
    print("hello from " .. addonName)
end
```

Drop the folder in `Interface/AddOns/`, log in, `/myaddon`. From there: add a frame, register the events you care about, and grow.

---

*Caveat: warcraft.wiki.gg has been under maintenance since 2026-07-23 and some API pages render with template errors; cross-check exact new 12.0.7 function names against `Gethe/wow-ui-source` before relying on them.*
