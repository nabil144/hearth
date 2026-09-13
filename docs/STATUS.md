# Where Hearth is

Read this first in a new session. Date the top when you change it. Put new facts at the top of the dated block. The why behind older choices is in [DECISIONS.md](../DECISIONS.md). The original company argument is [plan.md](plan.md).

**Updated.** 13 September 2026.

## One sentence

Hearth is a Paladin-shaped mythology habit: one chapter a night, voice over stills, a family check, a variant fork, recall with cites, and a genealogy graph of who you have heard.

## Now

- Chapter 4 POC film stays on this computer. The phone streams it. `python3 tools/serve-film.py` binds `192.168.0.121:8766` only, and only the token path in `content/films.json`. The 111 MB mp4 is not in the iOS bundle and cannot go to GitHub (100 MB limit). Watch still has pause, −10s, +10s, Exit. Same Wi-Fi, allow local network, keep the serve process running. The Met stills and the beat player are unchanged.
- While testing, Hearth image jobs stay on cheap Fal models. Locked `fal-ai/recraft-20b` with Recraft `digital_illustration` ($0.022/image). Every short still uses the same real-short frame: `portrait_16_9` (1024x1820), stored as `imageSize` in `content/prompts.json`. Do not mix landscape into a set. Regenerated `web/shorts/siblings-0.jpg`, `siblings-1.jpg`, `siblings-2.jpg` to that size. Shot 1 still undershoots a clean six-count (five figures, wheat and hearth). Recut `web/shorts/short-siblings.mp4` from the matching stills (20.4s, all 1024x1820, zoom only).
- First short is cut. `node tools/assemble.mjs` wrote `web/shorts/short-siblings.mp4`, 1080x1920, about 20s. That is under the 40–60s target because the three `spoken` lines are short, not because the cut is missing a shot. All stills are portrait, so they zoom in. No CapCut MCP. Next is watch it, step 6 in [first-video.md](first-video.md).
- Fal MCP is connected. First-video steps 1 to 5 are done. Hook voice: `web/shorts/siblings-0.mp3` and so on. Do not replace `web/stills/`.
- Working name. Hearth. Repo https://github.com/nabil144/hearth, personal account `nabil144`, SSH `github-personal`.
- POC is playable. iOS on a Mac with a free Apple ID. Web at https://nabil144.github.io/hearth/web/
- Three written chapters. `greek-03` The father who ate. `greek-04` Zeus's siblings. `greek-05` Ten years of war. Chapters 1, 2, 6 to 12 are outlined only.
- iOS has Tonight, Lesson (pause, Tonight button, 0.7s gap between stills), Done, and a Family tab. Family is [PR 1](https://github.com/nabil144/hearth/pull/1) on `family-tab`, not merged to `main` yet.
- Friends share the Pages URL, not the Xcode build. A free-team install dies in seven days and needs the Mac.
- The 90-day gate is still the plan's two numbers. Did ten shorts move. Did a stranger finish chapter 3 and open chapter 4 the next night. Do not write the remaining nine chapters until those move.

## What the app already does

- Data lives in `content/greek.json`. `content/check.mjs` refuses a quiz on a claim the chapter never said.
- Stills are Met CC0 jpgs in `web/stills/`, listed in `content/stills.json`. Audio is Cartesia mp3s in `web/audio/<lesson>/<beat>.mp3`. Both are committed and copied into the iOS bundle. No stream. No login. Progress is a local `progress.json` on the phone, localStorage on the web.
- Engine (`Family.of`, `Review`, `Memory`) is Linux-testable. `cd Engine && ../swift.sh test` is 7/7.
- Family graph is derived from `entities[].parents` plus heard claims. Aphrodite is off the tree because her parents are the fork. Gaia names Chaos.

## Out of scope until the gate moves

Battle, Mythologies, Hearth+, accounts, one-chapter-a-night lock, replacing the in-app lesson with one film, Norse, living-religion traditions.

## Owner still owes

- Merge PR 1 when `main` should match the phone.
- Read chapters 3 to 5 against the Theogony lines they cite.
- Fal MCP is in the user `mcp.json`. Do not put `FAL_KEY` in git.
- Five strangers, three nights. Ten shorts, face to camera or the first cartoon cut.

## How a new session starts

1. Read this file.
2. Read [first-video.md](first-video.md) if the work is pictures or the short.
3. `git status` and `gh pr view 1`. Do not assume `main` has Family.
4. Do not open `.env`. Cartesia and Fal keys stay on the machine.
