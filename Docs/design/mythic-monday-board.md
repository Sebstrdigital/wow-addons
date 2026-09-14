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

---

# Addendum v1.5.1 — Class colour and spec icons (2026-09-14)

Board rows name a player and their role but not what they actually play. A
guild roster class cache colours the name; the spec has to come off the wire,
because nothing local knows a guildie's current spec.

## Protocol — still `GPMM2`

Two trailing fields, appended rather than inserted. No prefix bump: `handlers.E`
reads fields 3..9 and `handlers.G` reads 3..6, both by fixed index with no
arity check, so a client that predates these fields never looks at them and a
client that postdates a sender who omits them reads nil.

| Msg | Field | Meaning |
|---|---|---|
| `E ev ts role intent bracket mapID level leader spec` | 10th | own spec id, `0` = not told |
| `G ev ts mapID level m1:R,m2:R,... s1,s2,...` | 7th | spec ids positional against the member list, `0` = not told |

`spec` is `GetSpecializationInfo`'s first return — the spec's own id, not the
1-4 index, which means nothing without the class the wire does not carry. `0`
and a missing field are the same thing; `SpecFromWire` maps both to nil.

The id is **never** folded into the member pair. `handlers.G` matches pairs on
`^(.+):([THD])$`, so a third component would make every older client drop the
member outright rather than ignore the extra.

G's list is built in the same pass as the member list and trimmed with it when
the roster overflows 255 bytes — a body cut shorter than its positional list
would hand receivers the wrong icons rather than none. Cost: +5 bytes on E, at
most +25 on G (five ids and their commas), against worst cases of 65 and 158.

Comms are unchanged otherwise, so Secret Values need nothing new: spec rides
existing `E`/`G` sends through the same `Send`, which still queues everything
under an active key and flushes on `CHALLENGE_MODE_COMPLETED`.

`PLAYER_SPECIALIZATION_CHANGED` now re-broadcasts on a spec change as well as a
role change. Fire → Frost keeps the role and used to be nothing to announce.

## Contract additions

```lua
ns.Monday.ClassOf(fullName)       -- "WARRIOR" etc from the guild roster, or nil
ns.Monday.MySpec()                -- own spec id, or nil if the client will not say
ns.Monday.Groups(ev)              -- members gain `spec`
ns.Monday.Pool(ev)                -- entries gain `spec`
```

`ClassOf` is fed by `GUILD_ROSTER_UPDATE` plus one priming pass at login. It
keys on `GetGuildRosterInfo`'s own `fullName`, the same `Name-Realm` form board
entries already use.

## SavedVariables

`entries[name].spec` and `groups[leader].specs[name]` — both new, both optional.
`Persist` stores the board tables whole, so neither needs listing to survive;
a board saved before this addendum has no `specs` table and loads as unknown.

Spec precedence is the same wherever it is read: the member's own entry first,
the group's `specs` sidecar only for someone whose `E` we have never heard. A
member respecs long after joining and only their own `E` will say so.

## UI

Name is class-coloured, link-blue only when neither the roster nor the spec
names a class. A `|T<icon>:14:14|t` spec icon follows the name, **outside** the
closing `|h`, so the link markup and the line's hyperlink count are unchanged —
past roughly nine links in one FontString the client drops every link in it,
and the group line already runs to five. Unknown spec → no icon, no gap.
