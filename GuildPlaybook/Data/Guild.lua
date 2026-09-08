local ADDON, ns = ...

-- ------------------------------------------------------------------
-- Guild handbook content
-- ------------------------------------------------------------------
-- The guild's own mission, rules and rank structure, transcribed from the
-- documents the officer team maintains. This is prose, not tactics: it carries
-- no ability markup and no role split, so it is kept apart from the generated
-- dungeon data under Data/MidnightS2 and is edited by hand.
--
-- Page shape, shared by top-level pages and their children:
--   id       unique string, used as the nav selection key
--   title    nav row label and content heading
--   hero     optional banner shown above the body, for the landing page only:
--            { tagline = "...", stats = { { label, value }, ... } }
--   body     ordered list of blocks, each one of:
--              "a paragraph"                  plain body prose
--              { head = "Section" }           a heading inside the page
--              { bullets = { "a", "b" } }     a bulleted list
--              { note = "aside" }             dimmed aside, e.g. an instruction
--   children optional list of sub-pages; a page with children renders as an
--            accordion row in the nav, exactly like a trash segment
--
-- A parent page's own `body` still shows when its row is clicked, so an
-- expander is never a dead row - it summarises what it expands into.

ns.GUILD_PAGES = {
    -- The landing page, and the one the Guild tab opens on. It is a signpost
    -- rather than a document: the handbook proper starts at Mission & Vision.
    {
        id = "welcome",
        title = "Welcome",
        hero = {
            tagline = "Stand together. Play your way. Bring people with you.",
        },
        body = {
            "This is the guild handbook - the same mission, rules and rank "
            .. "structure the officer team maintains, kept where you actually "
            .. "play rather than in a document nobody opens twice.",
            { head = "What's in here" },
            { bullets = {
                "Mission & Vision - what we're building, and why.",
                "Direction & Goals - where the guild is pointed, and how streaming fits in.",
                "Guild Rules - nine of them, one page each.",
                "Ranks - Initiate through GM, and how inactivity is handled at each.",
                "Roster & Alts - why your guild note matters, and rejoining after a break.",
                "Discord - the invite, and what lives there.",
            } },
            { head = "New here?" },
            "Read Mission & Vision, skim the rules, put your name in your guild "
            .. "note, and get into Discord. That's the whole onboarding.",
            { head = "The rest of the addon" },
            "The Dungeons tab carries the Mythic+ playbooks - per-boss and "
            .. "per-pull calls, filtered to your role, with MDT routes you can "
            .. "import in one click.",
            { note = "#StandAsOne" },
        },
    },
    {
        id = "mission",
        title = "Mission & Vision",
        body = {
            "Our goal is to build a friendly, supportive and inclusive community "
            .. "where people feel they belong - somewhere you can find people to "
            .. "play with, have a laugh, ask for help, learn, and enjoy the game "
            .. "together.",
            "It's about sharing what we know, helping each other when we can, and "
            .. "making the game more enjoyable for everyone.",
            "We want Stand as One to be a place where people feel comfortable "
            .. "joining in, whether they're new, returning, experienced, or "
            .. "somewhere in between.",
            "Many players find themselves playing WoW alone - sometimes because of "
            .. "past experiences, feeling judged, or finding it difficult to connect "
            .. "with others. We want to change that by supporting people as they "
            .. "learn, return to the game, build confidence, or simply find others "
            .. "to play with.",
            { head = "Final thought" },
            "You're not just in the guild - you're part of what builds it. Every "
            .. "person who joins in, welcomes someone new, shares what they know, "
            .. "offers a hand or simply adds to the conversation helps shape Stand "
            .. "as One.",
            "Ratings fade, seasons end, but the people we meet and the memories we "
            .. "create are what make the journey worthwhile. We're in this together. "
            .. "Let's keep building something special.",
            { note = "#StandAsOne" },
        },
    },
    {
        id = "direction",
        title = "Direction & Goals",
        body = {
            "Our main focus is building a strong social community, with Mythic+ as "
            .. "our primary group content. We also support delves, achievements, "
            .. "collecting, housing, levelling, old content and other activities "
            .. "that bring members together.",
            "You can choose how you'd like to be involved and help shape our "
            .. "direction.",
            "Being part of Stand as One doesn't mean always putting your hand up "
            .. "for dungeons, runs or activities. Support each other when you can, "
            .. "but know your limits - we're here to enjoy the game together, not "
            .. "make helping each other feel like an obligation.",
            { head = "Streaming & guild communication" },
            "Some of our members stream or record their gameplay, so we ask "
            .. "everyone to keep guild communication reasonably workplace-friendly "
            .. "and respectful.",
            "We still want Stand as One to be relaxed, social and somewhere we can "
            .. "joke around - we're not trying to take the fun out of Discord or "
            .. "guild chat. Just be mindful of what you're saying and who may be "
            .. "hearing or seeing it.",
            "If you're streaming or recording guild activities, let the people "
            .. "you're playing with know, particularly when voice chat is involved.",
        },
    },
    {
        id = "rules",
        title = "Guild Rules",
        body = {
            "Nine rules, and none of them is a rule about damage meters. They're "
            .. "about how we treat each other in guild chat, in Discord and in a "
            .. "key that's going sideways.",
            { note = "Pick a rule on the left to read it in full." },
        },
        children = {
            {
                id = "rules-help",
                title = "Help & Support",
                body = {
                    "Stand as One is a supportive community, but support isn't an "
                    .. "entitlement. Members are encouraged to help each other when "
                    .. "they can, but nobody is expected to always be available or "
                    .. "say yes.",
                    "Ask for help, invite people along and offer support in return - "
                    .. "but respect that sometimes people will be busy, have other "
                    .. "plans, or simply want to do their own thing.",
                },
            },
            {
                id = "rules-respect",
                title = "Respect Each Other",
                body = {
                    "Friendly banter and giving each other a bit of grief is part of "
                    .. "gaming, but keep it respectful. Abuse, bullying, harassment, "
                    .. "discrimination or personal attacks towards other members "
                    .. "aren't acceptable.",
                    "Know where the line is, and if someone tells you you've crossed "
                    .. "it, respect that.",
                },
            },
            {
                id = "rules-feedback",
                title = "Communication & Feedback",
                body = {
                    "Your thoughts, ideas and feedback matter. If something isn't "
                    .. "working, you're unsure about something, or you have an idea "
                    .. "for the guild, talk to us.",
                    "If you're having an issue with another member, try to deal with "
                    .. "it respectfully. If you don't feel comfortable doing that, or "
                    .. "the issue continues, speak with an officer so we can help "
                    .. "address it before it becomes a bigger problem.",
                },
            },
            {
                id = "rules-name",
                title = "Help Us Know Who You Are",
                body = {
                    "Please have a consistent, recognisable name that identifies you "
                    .. "across the guild and Discord. This doesn't have to be your "
                    .. "main character's name.",
                    "That name should be listed in your in-game guild note on each of "
                    .. "your characters and should match the name you use in Discord.",
                    "With lots of members and alts, this helps guildies know who's "
                    .. "who and makes managing the guild roster much easier for the "
                    .. "officer team.",
                },
            },
            {
                id = "rules-learn",
                title = "People Are Allowed to Learn",
                body = {
                    "Everyone starts somewhere, and everyone makes mistakes. Missed "
                    .. "interrupts, wrong turns, accidental pulls, deaths and failed "
                    .. "keys are part of learning and playing the game.",
                    "Offer constructive advice and help people understand what "
                    .. "happened. Don't belittle someone because of their experience, "
                    .. "performance, class, role, rating or mistakes.",
                },
            },
            {
                id = "rules-playyourway",
                title = "Play Your Way",
                body = {
                    "Some members want to push higher keys, some are learning, and "
                    .. "others prefer delves, achievements, collecting, housing, "
                    .. "levelling or simply being social. There's room for all of "
                    .. "that in Stand as One.",
                    "Play at the level you enjoy and challenge yourself if you want "
                    .. "to - but don't judge someone else for enjoying the game "
                    .. "differently.",
                },
            },
            {
                id = "rules-keys",
                title = "Keys & Group Content",
                body = {
                    "Sometimes runs don't go to plan. Keys get bricked, people make "
                    .. "mistakes, groups wipe, and occasionally it's simply not our "
                    .. "night.",
                    "When that happens, keep it respectful. Talk about what went "
                    .. "wrong if it helps, reset and try again - but never take your "
                    .. "frustration out on another guild member.",
                    "That respect also extends beyond the guild. When you're playing "
                    .. "with people from the wider WoW community, remember that "
                    .. "you're representing Stand as One. Treat other players with "
                    .. "the same respect we'd expect within our own community, even "
                    .. "when a run isn't going well.",
                },
            },
            {
                id = "rules-groups",
                title = "Forming Groups",
                body = {
                    "Everyone is encouraged to ask for groups, start their own runs "
                    .. "and invite others along. At the same time, members are free "
                    .. "to choose who they run with and what level of content they "
                    .. "want to do.",
                    "Not getting an invite to a particular run isn't necessarily "
                    .. "personal - sometimes people already have a group, need a "
                    .. "particular role, are working on a specific goal, or simply "
                    .. "want to play with friends.",
                },
            },
            {
                id = "rules-chat",
                title = "Guild Chat & Discord",
                body = {
                    "Guild chat and Discord are shared spaces for everyone. Have a "
                    .. "laugh, join the conversation and enjoy the social side of "
                    .. "the guild, but be mindful of where conversations are heading.",
                    "Sometimes conversations can get carried away when lots of "
                    .. "people join in. If a discussion starts getting out of "
                    .. "control, becomes inappropriate, heated or overly personal, "
                    .. "pull it back or move it to a more appropriate space.",
                    "The aim isn't to stop people chatting - being social is a big "
                    .. "part of Stand as One. It's about keeping our shared spaces "
                    .. "comfortable and enjoyable for everyone.",
                },
            },
            {
                id = "rules-officers",
                title = "Officer Support & Decisions",
                body = {
                    "Officers are here to support the guild and help when problems "
                    .. "arise. Sometimes that means stepping into a conversation, "
                    .. "addressing behaviour, or asking people to take something out "
                    .. "of a shared space. If an officer does step in, please respect "
                    .. "the request at the time.",
                    "That doesn't mean decisions can't be questioned. If you disagree "
                    .. "with something or want to understand why an officer stepped "
                    .. "in, talk to us privately afterwards so it can be discussed "
                    .. "properly.",
                },
            },
        },
    },
    {
        id = "ranks",
        title = "Ranks",
        body = {
            "The guild roster is regularly reviewed to keep it organised, "
            .. "manageable and reflective of our active membership.",
            { head = "The ladder" },
            { bullets = {
                "Initiate  >  Member  >  Veteran",
                "Sergeant  >  Officer  >  Senior Officer  >  GM",
            } },
            "The first three ranks reflect membership and involvement within the "
            .. "guild. Sergeant, Officer and Senior Officer are support and "
            .. "leadership roles with additional responsibilities.",
            { note = "Pick a rank on the left for what it means and how inactivity "
                     .. "is handled." },
        },
        children = {
            {
                id = "rank-initiate",
                title = "Initiate",
                body = {
                    "New members join Stand as One at the Initiate rank for their "
                    .. "first 30 days.",
                    "During this time, we expect to see some activity in the guild "
                    .. "rather than the character simply remaining unused on the "
                    .. "roster.",
                    "After 30 days, active Initiates can be promoted to Member.",
                    { head = "Inactivity" },
                    "Initiates who have been inactive for 30 days will be removed "
                    .. "from the guild roster.",
                },
            },
            {
                id = "rank-member",
                title = "Member",
                body = {
                    "Members are established members of Stand as One who have "
                    .. "completed their first 30 days with the guild.",
                    { head = "Inactivity" },
                    "Members can remain inactive for up to three months. Members who "
                    .. "have been inactive for three months will be removed from the "
                    .. "guild roster.",
                },
            },
            {
                id = "rank-veteran",
                title = "Veteran",
                body = {
                    "Veteran recognises members who have been part of Stand as One "
                    .. "for some time and are actively involved in the guild "
                    .. "community.",
                    { head = "Promotion is based on" },
                    { bullets = {
                        "Time in the guild",
                        "Joining in with guild activities",
                        "Being active and involved in the guild Discord",
                        "Supporting other members",
                    } },
                    "Veteran is not an automatic promotion based on time alone.",
                    { head = "Inactivity" },
                    "Veterans can remain inactive for up to six months. Before an "
                    .. "inactive Veteran is removed, the roster manager will "
                    .. "generally discuss it with the GM, recognising that member's "
                    .. "history and involvement with the guild.",
                },
            },
            {
                id = "rank-sergeant",
                title = "Sergeant",
                body = {
                    { note = "Guild support role" },
                    "Sergeant is a guild support role rather than a standard "
                    .. "membership progression rank.",
                    "It recognises members who have agreed to take responsibility "
                    .. "for a particular area of guild activity, such as organising "
                    .. "or running events. The role may be temporary or ongoing by "
                    .. "agreement.",
                    "Sergeant may also be used as a development role for someone "
                    .. "being considered for Officer, giving both the member and the "
                    .. "officer team an opportunity to see whether a broader "
                    .. "leadership role is a good fit.",
                    { head = "Inactivity" },
                    "Because Sergeant is a support role, there is no set inactivity "
                    .. "period attached to the rank. If a Sergeant becomes inactive "
                    .. "or is no longer able to fulfil the role, their rank will be "
                    .. "reviewed through discussion with the GM and Senior Officers.",
                },
            },
            {
                id = "rank-officer",
                title = "Officer",
                body = {
                    "Officers take an active role in supporting the day-to-day "
                    .. "running of Stand as One and helping maintain the culture and "
                    .. "values of the guild.",
                    { head = "The role may include" },
                    { bullets = {
                        "Supporting members",
                        "Helping manage guild activities",
                        "Responding to concerns",
                        "Welcoming and assisting newer members",
                        "Helping the leadership team with decisions that affect the community",
                        "Stepping in when behaviour breaches guild rules",
                    } },
                    "Officer is a position of responsibility, not a status or "
                    .. "reward. Officers are expected to lead by example and "
                    .. "represent the values of Stand as One in how they interact "
                    .. "with members.",
                    { head = "Officer authority" },
                    "Officers have the authority to step in when behaviour seriously "
                    .. "breaches guild rules or threatens the wellbeing of the "
                    .. "community. This includes the ability to remove a member from "
                    .. "the guild when necessary, such as in cases of bullying, "
                    .. "harassment, abuse or other serious inappropriate behaviour.",
                    "Where circumstances allow, concerns should be discussed with "
                    .. "the leadership team. However, an Officer does not need to "
                    .. "leave serious or harmful behaviour unchecked while waiting "
                    .. "for another Officer to be available. Significant actions "
                    .. "should be communicated to the GM and Senior Officers "
                    .. "afterwards.",
                    { head = "Inactivity" },
                    "There is no set inactivity period for Officers. If an Officer "
                    .. "becomes inactive or is no longer able to fulfil the role, "
                    .. "their position will be reviewed with the GM and Senior "
                    .. "Officers.",
                },
            },
            {
                id = "rank-senior",
                title = "Senior Officer",
                body = {
                    "Senior Officers take on broader responsibility for the "
                    .. "management and direction of Stand as One and work closely "
                    .. "with the GM in overseeing the guild.",
                    { head = "Alongside an Officer's duties, they may" },
                    { bullets = {
                        "Support and guide the officer team",
                        "Help manage more complex member or community issues",
                        "Contribute to guild decisions",
                        "Take responsibility for particular areas of guild management",
                        "Take on additional leadership responsibility when the GM is unavailable",
                    } },
                    "Senior Officers help ensure the guild can continue to operate "
                    .. "smoothly when the GM isn't available.",
                    "Senior Officer reflects an established leadership role and a "
                    .. "high level of trust and responsibility within the guild. It "
                    .. "isn't simply the next promotion after Officer.",
                    { head = "Inactivity" },
                    "There is no set inactivity period for Senior Officers. Changes "
                    .. "to the role are handled through discussion with the GM and "
                    .. "leadership team.",
                },
            },
            {
                id = "rank-gm",
                title = "Guild Master",
                body = {
                    "The GM has overall responsibility for Stand as One, its "
                    .. "leadership, culture and direction.",
                    "The GM works with the Senior Officers, Officers and wider guild "
                    .. "community to guide the guild while maintaining the values "
                    .. "and purpose of Stand as One.",
                },
            },
        },
    },
    {
        id = "roster",
        title = "Roster & Alts",
        body = {
            { head = "Characters, alts & guild notes" },
            "Roster inactivity is considered across all of a member's characters, "
            .. "rather than treating each character separately.",
            "This is why members are asked to have the same identifying name in "
            .. "their in-game guild notes across their characters and use that "
            .. "identifying name in Discord.",
            "It allows officers to recognise which characters belong to the same "
            .. "person and makes managing a large roster much easier.",
            { head = "Returning after inactivity" },
            "Removal due to inactivity isn't a disciplinary action.",
            "If you've been removed because you've been away from the game, you're "
            .. "welcome to rejoin Stand as One when you return.",
            "Sometimes real life happens. The roster needs to be managed, but that "
            .. "doesn't mean the door is closed.",
        },
    },
    -- The Discord page is the one that carries a live widget rather than only
    -- prose: WoW gives an addon no way to write the clipboard, so the invite has
    -- to be handed over as selectable text. UI.lua keys the copy box off this id.
    {
        id = "discord",
        title = "Discord",
        body = {
            "Everything that doesn't fit in guild chat lives there: M+ night "
            .. "sign-ups, roster and key planning, and the tactics discussions "
            .. "these playbooks come out of.",
            { note = "Hit Select, then Ctrl+C to copy the invite." },
        },
    },
}

-- Depth-first walk of the pages, so a lookup by id doesn't have to know
-- whether a page is top-level or a child.
ns.GUILD_PAGE_BY_ID = {}
for _, page in ipairs(ns.GUILD_PAGES) do
    ns.GUILD_PAGE_BY_ID[page.id] = page
    for _, child in ipairs(page.children or {}) do
        ns.GUILD_PAGE_BY_ID[child.id] = child
    end
end

-- Key-level brackets people sign up under on the Mythic Monday board. The
-- ranges overlap on purpose: a +6 key is the top of "low" and the bottom of
-- "mid", and someone with one is happy in either kind of group. "any" carries
-- no range at all - it means "put me wherever there is a slot".
ns.MONDAY_BRACKETS = {
    { id = "low",  label = "Low",  min = 2,   max = 6 },
    { id = "mid",  label = "Mid",  min = 6,   max = 10 },
    { id = "high", label = "High", min = 10,  max = 15 },
    { id = "any",  label = "Any",  min = nil, max = nil },
}
