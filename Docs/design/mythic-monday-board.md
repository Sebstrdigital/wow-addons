# Mythic Monday board — design (2026-09-08)

Internal planning doc. Research: `Docs/research/mythic-monday-api-research.md`.

## Problem

Every Mythic Monday: guild gathers in Discord voice, officer spends 30-45 min forming groups. Goal: groups mostly pre-formed in the addon before voice starts. Officer only fills leftovers.

## Scope v1

- Sign up for **next Monday** with own role (auto) + own keystone (auto).
- Intent: **lead** (my key, I'm leader) or **join** (bracket low 2-6 / mid 6-10 / high 10-15 / any, or join a specific listed group).
- Groups list + unassigned pool, everyone's key visible.
- Login chat summary line.
- No server. Guild addon messages only. No officer permissions, no calendar, no Discord bridge.

## Hard constraints

- 255-byte addon messages, 10-burst / 1 per sec throttle per prefix → ChatThrottleLib (vendored `Libs/ChatThrottleLib/`).
- Secret Values: no addon comms and no keystone reads while inside an active challenge mode. Queue sends, read key only out of dungeon, guard reads with `issecretvalue` when it exists.
- Addon message sender arrives as `Name-Realm` (see `Core.lua:41`). Player key everywhere = `UnitName("player") .. "-" .. GetNormalizedRealmName()`.

## Sync model

**Each client is source of truth for itself.** Own entry lives in own SavedVariables, is broadcast on login / change / request. Peers cache what they hear. Offline members show from cache with last-seen time.

**Groups are leader-authoritative.** Only the leader's client mutates a group roster and broadcasts it. Join/leave are *requests* whispered to the leader. Leader auto-accepts if the role slot is free (1 tank, 1 healer, 3 dps), else replies full. Leader offline → group shown frozen with last-seen.

No merging of group rosters between non-leaders. Pool entries merge by `ts` (max wins).

**Requests return own state only** (not relayed caches) to avoid N² traffic on login.

## Target Monday and expiry

- `ns.Monday.TargetDate()` → `"YYYY-MM-DD"` of the next Monday including today, computed from `C_DateAndTime.GetCurrentCalendarTime()` (server time).
- Every message and every stored record carries `mon`. Records whose `mon` ≠ current target are dropped on load and on receive. Board clears itself Tuesday 00:00 server time.

## Protocol — prefix `GPMM1`

Bump prefix (`GPMM2`) on breaking change. Fields space-separated, `-` = nil. Names contain no spaces. All GUILD unless noted.

| Msg | Fields | Who / when |
|---|---|---|
| `R mon` | request | on login, on opening the page (throttled 60s) |
| `E mon ts role intent bracket mapID level leader` | own entry | on login, on change, in reply to `R` (jitter 0-2s) |
| `X mon` | withdraw own entry | on withdraw |
| `G mon ts mapID level m1:R,m2:R,...` | group roster, members `Name-Realm:T/H/D` | leader: on login, on change, in reply to `R` |
| `D mon` | disband own group | leader |
| `J mon` | join request — WHISPER to leader | joiner |
| `L mon` | leave request — WHISPER to leader | member |
| `N mon reason` | join denied (`full`, `nogroup`) — WHISPER to joiner | leader |

`role` ∈ `T H D`. `intent` ∈ `join lead`. `bracket` ∈ `low mid high any -`. `ts` = server epoch. Leader whose group has members implicitly has `intent=lead`; a leader is also its own group's member entry.

Joiner learns acceptance by receiving a `G` that lists them; sets own `leader` field and re-broadcasts `E`. Disband/leave clear `leader` on affected entries.

In challenge mode (`C_ChallengeMode.IsChallengeModeActive()`): outbound queued, inbound ignored, flushed on `CHALLENGE_MODE_COMPLETED` / leaving instance.

## Keystone detection

Read on `PLAYER_ENTERING_WORLD` (not in instance), `BAG_UPDATE_DELAYED` (debounced 2s), `CHALLENGE_MODE_COMPLETED`. `C_MythicPlus.GetOwnedKeystoneChallengeMapID()` + `GetOwnedKeystoneLevel()`; name via `C_ChallengeMode.GetMapUIInfo(mapID)`. If the value is secret or nil → key = nil (shows "no key"). Change → update own entry + broadcast `E` (and `G` if leader).

## SavedVariables

```lua
GuildPlaybookDB.monday = {
  mon = "2026-09-14",
  me = { role, intent, bracket, mapID, level, leader, ts },      -- own entry or nil
  entries = { ["Name-Realm"] = { role, intent, bracket, mapID, level, leader, ts, seen } },
  groups  = { ["Leader-Realm"] = { mapID, level, ts, seen, members = { ["Name-Realm"] = "T"|"H"|"D" } } },
}
```

`seen` = local epoch of last message from that player. Own group is `groups[myName]` and is the only one this client writes to.

## Module contract — `GuildPlaybook/Monday.lua` → `ns.Monday`

```lua
ns.Monday.TargetDate()            -- "YYYY-MM-DD"
ns.Monday.Me()                    -- own entry table or nil
ns.Monday.MyKey()                 -- { mapID, level, name } or nil
ns.Monday.MyRole()                -- "T"|"H"|"D"
ns.Monday.SignUp{ intent = "join"|"lead", bracket = "low"|"mid"|"high"|"any" }  -- creates/updates own entry; lead also creates own group
ns.Monday.Withdraw()              -- removes own entry; leader → disbands
ns.Monday.Join(leaderName)        -- whisper J; returns false,reason if offline/full known locally
ns.Monday.Leave()                 -- whisper L to current leader
ns.Monday.Disband()               -- leader only
ns.Monday.Groups()                -- array of { leader, mapID, level, keyName, members = { {name, role} }, isMine, isFull, missing = {T=bool,H=bool,D=n} , seen }
ns.Monday.Pool()                  -- array of entries not in a group, sorted bracket then role: { name, role, bracket, mapID, level, keyName, online, seen }
ns.Monday.Refresh()               -- broadcast R (throttled)
ns.Monday.Brackets()              -- from ns.GuildData / Data/Guild.lua: { {id="low", label="Low 2-6", min=2, max=6}, ... }
ns.Monday.RegisterCallback(fn)    -- fn() on any board change; UI redraws
ns.Monday.Summary()               -- one-line chat string for login
```

Login summary printed once on `PLAYER_ENTERING_WORLD` (initial login only, not reloads/zoning) ~5s after the `R` goes out: `Mythic Monday (Mon 14 Sep): 3 groups, 7 in pool. You: not signed up. /gp monday`

Slash: `/gp monday` opens Guild tab on the Monday page. `/gp monday dump` prints board state (debug).

## UI — Guild tab page "Mythic Monday" (top of handbook nav)

1. Header: `Mythic Monday — Mon 14 Sep` + status line (`You: leading +12 KR, 3/5` / `You: in pool, DPS, mid` / `You: not signed up`).
2. **Your sign-up** block: role + key shown read-only. Two buttons `Lead with my key` (disabled if no key) / `Join a group`. Bracket buttons Low / Mid / High / Any (only for join). `Withdraw`.
3. **Groups**: one row per group: `Vizzo  +12 Kings' Rest   T Vizzo · H —— · D Anna, Bob, ——` with `Join` / `Leave` / `Disband` as applicable. Offline leader greyed `(offline 2h)`.
4. **Looking for group**: grouped by bracket; row = `name  role  own key  (offline)`.
5. `Refresh` button (calls Refresh, 60s throttle).

One FontString per line (hyperlink cap rule). Redraw on `ns.Monday` callback.

## Stories

| # | Owner | Files | Deliverable |
|---|---|---|---|
| S1 | heavy (opus) | `Monday.lua` (new), `GuildPlaybook.toc`, `Data/Guild.lua` (brackets), `Core.lua` (slash + login hook), `tools/monday_test.lua` | module per contract, protocol, headless tests for merge/expiry/roster rules |
| S2 | builder (sonnet) | `UI.lua` | page per section above, against the contract, works with a stub `ns.Monday` until S1 lands |
| S3 | skeptic (opus) | — | review both diffs against this doc |
| S4 | Fable | — | version bump 1.3.0, rsync to game, user tests in-client |

## Out of scope (later)

Calendar-backed persistence, officer tools (force-move, lock groups), Discord bridge, configurable slot layout, historical attendance.

---

# Addendum v1.4.0 — Open board ("right now") (2026-09-08)

Second board with identical mechanics, different scope: "I'm online and want to run keys now." Decision: generalise the module on an **event id**, keep the `Monday.lua` / `ns.Monday` name to limit churn.

## Events

| ev id | wire key | expiry | heartbeat |
|---|---|---|---|
| `"monday"` | `M<YYYY-MM-DD>` of target Monday | records with other wire key dropped | none |
| `"open"` | `open` | entries/groups unseen > 15 min hidden from Groups/Pool and pruned on load; leader unseen > 15 min → group hidden | own E (+G if leader) re-sent every 5 min while signed up and online |

Both boards independent: a player can be in a Monday group and an open group at once. Own open entry persists in SavedVariables and is re-broadcast on login, so a relog keeps you on the board; a real logout drops you from others' view after 15 min.

## Protocol — prefix `GPMM2`

Every message's `mon` field becomes `ev` = wire key (`M2026-09-14` or `open`). Receivers map wire key → ev id; unknown or stale wire keys dropped. Everything else unchanged.

## Contract changes

Board-specific functions take `ev` as first arg: `Me(ev)`, `SignUp(ev, opts)`, `Withdraw(ev)`, `Join(ev, leader)`, `Leave(ev)`, `Disband(ev)`, `Groups(ev)`, `Pool(ev)`, `Refresh(ev)`.
Shared, unchanged signature: `TargetDate()`, `MyKey()`, `MyRole()`, `Brackets()`, `Summary()`.
`RegisterCallback(fn)` → `fn(ev)`; UI redraws if the shown page matches.
Constants: `ns.Monday.EVENTS = { "monday", "open" }`, `ns.Monday.EventTitle(ev)` → "Mythic Monday" / "Open groups".

## SavedVariables

```lua
GuildPlaybookDB.monday = {
  boards = {
    monday = { key = "M2026-09-14", me = ..., entries = {...}, groups = {...} },
    open   = { key = "open",        me = ..., entries = {...}, groups = {...} },
  },
}
```
Old flat `GuildPlaybookDB.monday` (v1.3.0, never released) is discarded on load if `boards` is absent.

## UI

Two nav entries at top of the Guild handbook nav: **Mythic Monday**, **Open groups**. Same renderer, `SetMondayBody(ev)`. Header for open: `Open groups — right now`; no date. Offline rows on the open board are not shown at all (they're pruned), so no `(offline)` markers there.

`ns.UI_ShowMonday(ev)`; slash `/gp monday` → monday page, `/gp now` → open page, `/gp monday dump` dumps both boards.

Login line: `Mythic Monday (Mon 14 Sep): 3 groups, 7 in pool. Right now: 1 group, 2 in pool. You: ...` — "You:" summarises Monday status only if signed up there, else open, else "not signed up".
