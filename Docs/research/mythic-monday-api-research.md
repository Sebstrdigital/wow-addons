# Mythic Monday board — API research (2026-09-08)

Scope: guild sign-up board for next Mythic Monday. Own key + role, create/join groups, synced via guild addon messages. No server.
Target: `GuildPlaybook.toc` Interface 120007, 120100 (Midnight 12.x).

## 1. Keystone reading — CONFIRMED, plain values out of dungeon

- `C_MythicPlus.GetOwnedKeystoneLevel()`, `GetOwnedKeystoneChallengeMapID()`, `GetOwnedKeystoneMapID()`, `C_ChallengeMode.GetMapUIInfo(mapID)` all documented on warcraft.wiki.gg, no Secret badge.
- Astral Keys (Interface 120100, v4.61, updated ~late Aug 2026) calls `GetOwnedKeystoneChallengeMapID()` / `GetOwnedKeystoneLevel()` unguarded in `Keystone.lua`. Same addon guards `UnitGUID` with `canaccessvalue()` in GOSSIP_CLOSED handler → they guard where it matters, keystone getters not among them.
- Gotcha, UNVERIFIED: Secret Values system (warcraft.wiki.gg/wiki/Secret_Values) has cvar `addonChallengeModeRestrictionsForced` + predicate `SecretInChatMessagingLockdown`. Guarded APIs may return secrets *inside an active challenge-mode map* or during chat lockdown. Whether keystone getters are on that list: not exhaustively checked.
- Design consequence: read key on login / key-change events outside dungeon, cache in SavedVariables, never read inside a key. Wrap reads in `canaccessvalue()` / `issecretvalue()` guard anyway.

## 2. Astral Keys sync protocol — MAINTAINED for 12.x

Source: github.com/astralguild/AstralKeys

- Prefix `AstralKeys`, channel GUILD. `Communications.lua`.
- NOT ChatThrottleLib / AceComm. Home-rolled queue, OnUpdate send loop, randomised intervals: 0.2s raid, 1s normal, 2s version-check.
- Sub-commands = space-split first arg: `request` (full pull; also registered on ENCOUNTER_END), `updateWeekly`, `versionRequest` / `versionPush`.
- Weekly reset: wall-clock vs hardcoded per-region reset timestamps in main lua. No API push.
- Takeaway: pattern proven for guild-wide key sharing since Legion. We can copy the request/push shape but should use ChatThrottleLib (or AceComm) instead of home-rolled queue.

## 3. Role detection — CONFIRMED, already in repo

`GetSpecializationRole(GetSpecialization())` at `GuildPlaybook/Core.lua:73`.

## 4. Calendar — usable but stateful, restrictions unverified

- `C_Calendar.OpenEvent(offsetMonths, monthDay, index)` first, then argless `GetEventInfo()`, `GetNumInvites()`, `EventGetInvite(index)` operate on "current" event.
- Throttling / protected status of invite reads: not verified.
- Verdict: viable as optional persistence layer (phase 4), not needed for v1.

## 5. Addon message limits — CONFIRMED

- 255 chars payload, prefix ≤16 chars, `C_ChatInfo.SendAddonMessage`.
- Throttle: 10-message burst per prefix, refills 1/sec, overflow returns `Enum.SendAddonMessageResult.AddonMessageThrottle`. Wiki recommends ChatThrottleLib / AceComm.
- GUILD is valid chatType, same throttle applies.
- Design consequence: one board entry ≈ name, role, key map+level, intent, bracket, groupId, timestamp → fits 255 easily. Full board pull for 30 entries = 30 msgs → needs throttle lib, or pack 3-4 entries per message.

## Design decisions this unlocks

- Leader-authoritative groups (single writer per group) stays the plan. Pool entries gossip-merged by timestamp.
- Use ChatThrottleLib (vendored, MIT) rather than home-rolled queue.
- Weekly scope: ISO week of next Monday, entries expire after reset. Reuse Astral Keys' region reset timestamp approach or compute from `C_DateAndTime.GetSecondsUntilWeeklyReset()` (verify exists).
- Never read keystone inside a dungeon. Guard with `issecretvalue`.

## Sources (ctx_search labels, session-local)

"wiki C_MythicPlus keystone API", "wiki secret values midnight", "wiki GetSpecializationRole", "wiki SendAddonMessage limits", "wiki C_Calendar OpenEvent/GetNumInvites/EventGetInvite/GetEventInfo", "AstralKeys Communications.lua", "AstralKeys Keystone.lua", "AstralKeys main lua", "AstralKeys TOC".
