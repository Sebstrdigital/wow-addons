# Releasing on CurseForge

*What's already prepared in this repo, and the steps only a human can do on CurseForge's side. Written 2026-07-29.*

## Already in place

- **Policy compliance**: the addon is free, unobfuscated, ad-free, and now MIT-licensed (`LICENSE` in the repo root, bundled into the zip as `LICENSE.txt`) — meets Blizzard's UI Add-On Development Policy and CurseForge's requirements.
- **Automated releases**: pushing a git tag `v*` now runs `.github/workflows/release-addon.yml`, which builds the addon zip (playbook data included, dev files excluded), attaches it to a GitHub release with generated notes, and — once the two CurseForge values below exist — uploads the same file to CurseForge with the right game versions (read from the TOC) automatically.
- **Metadata**: TOC has title, notes, author, version, icon. The addon has no bundled libraries and no dependencies, which keeps review simple.

## Steps for you (one-time, ~15 minutes + review wait)

1. **Create an author account** at https://authors.curseforge.com (log in with the account you want to own the project — consider a shared guild account if others should be able to manage it later).
2. **Create the project**: Authors dashboard → Create Project → World of Warcraft → Addon.
   - Name: "Stand as One's Playbook" (public name can differ from the folder name — the folder stays `GuildPlaybook`).
   - Summary/description: paste from the repo README; mention it's a guild tactics playbook (role-filtered boss/trash guidance), content curated by the guild.
   - Category: something like "Guides" / "Boss Encounters".
   - License: MIT (they have it in the dropdown).
   - Submit — new projects go through a **manual approval queue**, typically hours to a couple of days.
3. **Grab the project ID**: shown on the project page (a number like `123456`).
4. **Create an API token**: authors.curseforge.com → account → API Tokens → generate.
5. **Wire both into GitHub** (repo → Settings):
   - Secrets → Actions → new secret `CF_API_KEY` = the token.
   - Variables → Actions → new variable `CF_PROJECT_ID` = the project ID.
6. **Tag a release**: `git tag v0.3.1 && git push origin v0.3.1`. The workflow builds, publishes to GitHub, and uploads to CurseForge. First one lands as the project's initial file (also goes through file review the first time).

After that, every future release is just a tag push — guildmates on the CurseForge app get auto-updates like any other addon.

## Things worth knowing

- **Public means public.** CurseForge has no private tier — anyone can install it. The guild's edge is execution, not secrecy, and the addon policy requires open code anyway; but be aware Raven's tactics text becomes publicly readable.
- **Name/trademark**: don't use Blizzard marks in the project name or icon. "Stand as One's Playbook" is fine.
- **The icon**: CurseForge wants a project image — any square guild logo works (current in-game icon is a generic book texture).
- **Fallbacks stay**: the GitHub release zip keeps working for WowUp/manual installs regardless of CurseForge status.
- If CurseForge's upload API rejects the first automated upload (their game-version list occasionally lags a new patch), upload the zip manually once via the project page and re-try the workflow next tag.
