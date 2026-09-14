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

---

# Addendum v1.7.0 — Open board scheduling and online indicator (2026-09-14)

Two independent additions, protocol-owned half done here: a leader can pin
their open-board group to a start time instead of "right now", and both
boards can show whether a name is actually online.

## Protocol — still `GPMM2`

One more trailing field, appended the same way the spec fields were: no
prefix bump, read by fixed index with no arity check, so a client that
predates it never looks and one whose sender omits it reads nil.

| Msg | Field | Meaning |
|---|---|---|
| `G ev ts mapID level m1:R,m2:R,... s1,s2,... when` | 8th | leader-set start time, decimal server epoch, `-`/`0`/missing = "right now" |

Only the open board ever sets it — the Monday board's key IS the date, so it
has nothing to schedule. It never rides `E`: groups are leader-authoritative,
so only a `G` may say when one starts. `SendGroup`'s 255-byte trim reserves
this token *before* trimming the roster/spec lists, so an overlong roster
never costs the schedule — it only ever costs members.

## Lifetime

A group carrying `when` is exempt from the ordinary 15-minute
(`OPEN_STALE`) silence rule and instead lives until `Now() > when +
OPEN_SCHEDULED_GRACE` (new constant, two hours) — regardless of how long its
leader has been offline, so peers can plan around a scheduled run its leader
hasn't logged in for yet. A group without `when` is unaffected: same
15-minute rule as before. Pool entries (non-lead sign-ups) are untouched
either way — a silent member still ages out on the ordinary clock even while
their leader's group is scheduled hours out.

Peers' *view* of our own group is exempt from this pruning, same as
`OPEN_STALE` — nothing may hide the group out from under the leader looking
at it. The leader's own client is not exempt, though: `PruneOwnSchedule`
disbands an own scheduled group once it is past grace, through the same path
`M.Disband` takes (own `D` broadcast, then back to the pool rather than gone
outright), checked at login and on every heartbeat - the only two moments
that may change state on our own initiative; deliberately not from
`M.Groups`, a getter, since Firing a callback from inside the render that
called it re-enters and corrupts the UI's button pool. A leader who logs back
in days after a run they never started must not re-broadcast it as still on,
and should not have to remember to withdraw by hand. It never fires mid-key
(`InChallenge()`), so a run that started late is not disbanded out from under
the person running it. An own *unscheduled* group is untouched either way,
exactly as before.

A leader's own `E` arriving with an intent other than `"lead"`, or their `X`,
now drops their cached group the same way an explicit `D` does — covering a
client that never sent the disband but has plainly moved on.

## Contract additions

```lua
ns.Monday.SetWhen(ev, when)       -- leader-only, open-board-only; edits me.when,
                                   -- the group, re-broadcasts G, Fires(ev)
ns.Monday.FormatWhen(when, now)   -- "" | "Today 20:00 (in 2h 15m)" | "Sat 19 Sep 20:00" | ...
ns.Monday.BuildWhen(dayOffset, hour, minute, now)  -- -> epoch, local calendar
ns.Monday.DefaultWhen(now)        -- -> next full hour at least 30 min out
ns.Monday.IsScheduled(g)          -- g.when ~= nil
ns.Monday.Groups(ev)              -- group records gain `when`; members gain `online`
ns.Monday.Pool(ev)                -- entries' `online` is now tri-state (was boolean)
ns.Monday.IsOnline(fullName)      -- true / false / nil (nil = not in roster / unscanned)
ns.Monday.RequestRoster()         -- nudges C_GuildInfo.GuildRoster(), guarded + pcall'd
```

`SignUp(ev, { ..., when = epoch|nil })` accepts the schedule at creation, only
for `{ ev = "open", intent = "lead" }`; every other combination ignores it.
`Groups(ev)` sorts own group first, then by `when` ascending (nil treated as
0, so unscheduled groups lead), then the existing level-desc/leader-name
rules.

## Online indicator

`ScanRoster` already walked `GetGuildRosterInfo` for the class cache; the
same pass now also fills `onlineCache[fullName] = true|false`, so "in the
roster but offline" is distinguishable from "never scanned" (nil) rather than
collapsing both to false. `GUILD_ROSTER_UPDATE` now invalidates the cached
scan and re-fires both boards' callbacks, throttled to once per five seconds
— the scan itself keeps its existing 20-second guard, but the event's whole
point is fresher presence, so the repaint forces past it rather than waiting
out the window.

## SavedVariables

`groups[leader].when` and `entries[name].when` (the leader's own copy) are
both new and both optional, riding the board tables `Persist` already stores
whole. A board saved before this addendum has neither and loads as unknown,
same as `specs` did in v1.5.1.

## UI

Covered by the UI half of this change (see `UI.lua`): a status-icon marker
per row instead of the old Monday-only "(offline)" suffix, a `Now` /
`Scheduled` toggle with plain-button day/hour/minute steppers in the lead
flow (no EditBox, no dropdowns — both are unsafe in a raid-scoped addon; see
the constraints above), and the leader line appending `FormatWhen(g.when)`
when set.

# Addendum v1.8.0 — Groups tab and OMKC board (2026-09-14)

A third sign-up board, `omkc`, alongside `monday` and `open`, plus a new
top-level tab, **Groups**, that holds all three. Where Monday and Open are
gated on guild membership, OMKC is gated on membership in the Blizzard
cross-realm Character community "Oceanic Mythic Keys Club" alone — guild
membership neither grants nor is required for access. The Guild tab loses
its two board entries, which move to Groups; Guild itself is unchanged
otherwise. Phase 1 still sends the omkc board's sync traffic over the GUILD
channel — there is no other transport yet — so a guildie who is also an OMKC
member shares the board like any other guild board, while a non-guild OMKC
member gets no sync but a fully working *local* board: sign up to lead with
a key and a time, see their own group rendered, preview the chat line, and
post a real LFM straight into the community via `C_Club.SendMessage`. Phase 2
(a real Community-channel transport, so non-guild members sync too) is gated
on the `/playbook clubtest` probe this addendum adds.

## Protocol — still `GPMM2`

No prefix bump. The wire key `"omkc"` simply joins `"open"` as a second
literal (non-dated) key; a client older than this addendum has never heard of
it, so `EventFromWire` drops it exactly like any other unrecognised key
always was — the same rule that already covered a future version's invented
key.

One new command, diagnostic only and unrelated to board state:

| Msg | Meaning |
|---|---|
| `P omkc` | clubtest ping (CHANNEL); any receiver prints who it came from |

## Board config

Every board-specific branch in `Monday.lua` (`ev == "open"` / `ev ==
"monday"`) is replaced by a per-board config table:

```lua
BOARDS = {
  monday = { title, schedule = false, heartbeat = false, dateHeader = true,  slash = "monday", post = "GUILD", gate = "guild" },
  open   = { title, schedule = true,  heartbeat = true,  dateHeader = false, slash = "now",    post = "GUILD", gate = "guild" },
  omkc   = { title, schedule = true,  heartbeat = true,  dateHeader = false, slash = "omkc",   post = "CLUB",  gate = "club"  },
}
```

`schedule` and `heartbeat` drive exactly what they did for the open board
before this addendum — the leader-set `when` field, `PruneOwnSchedule`, the
presence-proving ticker, `OPEN_STALE` ageing — now keyed on the flag instead
of a literal board id, and the open-board heartbeat ticker itself became one
ticker per heartbeat-capable board (`heartbeats[ev]`, was a single upvalue)
so open and omkc can each hold a heartbeat independently. `post` picks the
transport `M.Post` sends over; `gate` is what `M.IsBoardVisible` checks.

## Contract additions

```lua
ns.Monday.BoardConfig(ev)     -- -> { title, schedule, heartbeat, dateHeader, slash, post, gate } or nil
ns.Monday.IsBoardVisible(ev)  -- guild-gated boards -> ns.isGuildMember; omkc -> IsClubMember()
ns.Monday.ClubInfo()          -- -> { clubId, name, streamId } or nil; cached, event-invalidated
ns.Monday.IsClubMember()      -- ClubInfo() ~= nil
ns.Monday.OMKC_CLUB_NAME      -- "Oceanic Mythic Keys Club"
ns.Monday.Post(ev)            -- renamed from PostToGuild; CLUB boards send via C_Club.SendMessage
ns.Monday.PostToGuild(ev)     -- alias for Post, kept one release
ns.Monday.ClubTest()          -- /playbook clubtest probe (phase-2 groundwork, diagnostic only)
```

`Ready(ev)`, the check every public entry point (`SignUp`, `Post`, `ChatLine`,
`Groups`, `Withdraw`, ...) runs first, now branches on `BOARDS[ev].gate`
instead of checking guild membership unconditionally: a `"guild"`-gated board
still requires `IsInGuild()`, but a `"club"`-gated board requires
`IsClubMember()` and does not care about guild membership at all, in either
direction. `Send()` keeps its own unconditional `IsInGuild()` gate below
that, so a non-guild club member's `SignUp`/heartbeat/etc. run their full
local logic — own entry, own group, `Fire(ev)` — and only the actual GUILD
addon-message send silently no-ops.

`ClubInfo` walks `C_Club.GetSubscribedClubs()` for a `Character`-type club
whose name matches `OMKC_CLUB_NAME` case-insensitively and trimmed, then
`C_Club.GetStreams(clubId)` for the stream whose `streamType` is `General`.
Every call is wrapped in the file's existing `IsSecret`/`pcall` pattern —
a Secret Value or a missing API yields nil, never a throw. The result is
cached and only requeried on `INITIAL_CLUBS_LOADED`, `CLUB_ADDED`,
`CLUB_REMOVED`, or `CLUB_STREAMS_LOADED`, and `Fire("omkc")` runs only when
the membership boolean actually flips, so the UI rebuilds its nav exactly
when the Groups tab or the OMKC entry needs to appear or disappear.

`M.Post(ev)` for a `post == "CLUB"` board refuses with `"noclub"` if
`ClubInfo()` is nil or its `streamId` has not loaded, otherwise calls
`C_Club.SendMessage(clubId, streamId, text)` inside a `pcall`. Same 60-second
per-board throttle as a guild post; a `"noclub"` refusal does not consume it.
`M.ChatLine(ev)` closes a CLUB board's line with `"Whisper " .. MyName()`
instead of `"Sign up: /playbook <slash>"` — a Community member has no addon,
so nothing there could act on a slash command anyway.

`/playbook clubtest` calls `M.ClubTest()`: prints `ClubInfo()`, attempts
`C_Club.AddClubStreamChatChannel`, then scans `GetChannelList()` for a
channel whose name contains both "Community" and the club id, printing every
channel name it sees along the way — the point is to learn the real naming,
which the client API does not document for this shape. If found, it sends `P
omkc` on that channel index; the `P` handler prints `"ping from <sender> via
<distribution>"` for anyone who receives it, self included, and never touches
board state.

## SavedVariables

`boards.omkc` joins `boards.monday` / `boards.open` under
`GuildPlaybookDB.monday.boards`, same shape as `open`. No migration — a
client that predates this addendum has no `omkc` key and gets a fresh board,
same as `open` would if the same client had never seen v1.4.0.

## UI

Covered by the UI half of this change (see `UI.lua`): a new "Groups" tab
next to "Dungeons" and "Guild", shown iff at least one of `ns.Monday.EVENTS`
reports `IsBoardVisible`; the Guild tab's two board nav entries move there.
The OMKC page's subtitle names the community instead of the guild. The post
button reads "Post to guild" or "Post to OMKC" depending on `BoardConfig(ev)
.post`, and reports a `"noclub"` refusal in a one-line error. Everything
else — rows, schedule steppers, online dots — is unchanged and shared by all
three boards.
