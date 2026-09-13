# Decision trail

One entry per decision that shaped the work, newest at the bottom.

## 2026-09-12

- Project lives at `~/hearth`, public at github.com/nabil144/hearth. Same account, SSH alias, and per-repo identity as `life-is-a-game`. The work account stays out of it.
- This repo is a mock, not an app. The plan in `docs/plan.md` says the first ninety days are twelve chapters and thirty shorts, and "do not open Xcode". So the repo carries what a person needs to react to: the spec, the screens as HTML, the content shape with real locators, and the order of work. The same order `life-is-a-game` used the day before, minus the Swift.
- Data shape copied from the plan, unchanged. Tradition, Source, Claim, Variant, Entity, Lesson. `content/greek.json` is the first instance. Entities carry `parents` so the genealogy graph is derived, never drawn by hand. Variants are edges between claims, so the lesson can fork and the quiz can say "in Hesiod, not in Ovid".
- The one rule worth a machine check is "never ask what the chapter never said". `content/check.mjs` enforces it, along with source binding and the `do-not-ship` flag. A negative test (a check pointed at a claim outside its chapter) fails with the lesson id. This is the Hearth equivalent of the engine tests in `life-is-a-game`.
- Three Tonight layouts in `design/`. A is one telling, audio first, the calmest. B is the family graph on top with tonight's names in gold, the one people would screenshot. C is the hook sentence as the whole screen with a tap-to-check, which is the short-form video turned into a screen and the natural landing page for someone arriving from a video. Current lean: C for a first visit, A for every night after. B becomes the Family tab, which it already is. Decide after living with them on the phone.
- Dark only. The product is stories told at night. A light theme is a phase 2 question.
- Every wrong answer shows a work and a locator. This is the line between Hearth and a quiz database, so the mock shows it on both the lesson check and the battle.
- Living traditions carry `do-not-ship` in the data and do not appear in the library mock. The plan says empty is better than a costume. Egyptian appears as "Soon" because it is a literary corpus with a named researcher requirement, not a living-religion flag.
- Prices in the mock are the plan's two numbers. $39.99 a year, $6.99 a month. No trial, no ladder.
- GitHub Pages serves `design/` from `main` so the mockups open on any phone without the laptop firewall dance. The `serve-md` route still works locally.

- The first Lesson mock was a scrolling transcript. Wrong. The plan says a Lesson is "original script, audio, original stills," which is Paladin's format, a voice over a sequence of pictures with quiz cards cut in. The transcript hid the one thing Paladin does well. Lesson is now a stills player. Nine slides for chapter 2: six stills, the family check, the variant fork, the recall set. Tap right to advance, left to go back. Transcript is a toggle. Stills are emoji placeholders until there is a drawing budget. Spec rule 2 changed to match.

- POC scope is three chapters, 3, 4, 5, not twelve. Three nights is the smallest test of a nightly habit, and chapter 4 is the hook the shorts point at. Chapters 1, 2, and 6 to 12 stay outlined with empty `beats` until strangers have heard these three.
- A Lesson is now a list of beats. `still` (one picture, one spoken paragraph), `check` (a card, the voice pauses), `variant` (two claims side by side), `recall` (last, always). One audio clip per beat, `web/audio/<lesson>/<beat>.mp3`, so the player never syncs timestamps against a five-minute file. It plays clip N over still N and advances on `ended`. Cheaper to build, cheaper to re-record one paragraph, and the check pause is free.
- Recall questions live in a top-level `cards` list bound to claims, not inside lessons. A card asked as tonight's check is the same object that comes back next week in recall. `check.mjs` still refuses a check whose claim the chapter never says.
- Voice is Cartesia TTS, not the owner's voice, for the POC. `tools/tts.mjs` generates one MP3 per beat from `greek.json`, keyed by a hash of model, voice, and text, so re-running only touches beats whose words changed. The plan wants a face people recognize for the shorts; the app voice can be synthetic while the test is "do they come back", and swapped later without touching the player. Verified against the API up to the auth wall (401 with a fake key, request shape accepted).
- Stills come from the Met's Open Access collection, CC0, downloaded by `tools/stills.mjs` from a manifest of object IDs in `content/stills.json`. Real vases and marbles for free, with a credit line, instead of placeholder art or something scraped. Original drawings replace them when there is a drawing budget; the beat shape does not change.
- Fourth variant added while writing chapter 4. How Zeus got the sky. Hesiod 883-885 has the gods ask him; Iliad 15.187-193 has the brothers draw lots. Same century, two answers. Exactly the kind of fork the product exists to keep open.

- The web folder is `web/`. The Swift folder is `ios/`. A Mac disk treats `App` and `app` as one path, so those names are gone.
- iOS pulled forward as a personal shell in this same repo. Engine decodes `greek.json`. App is SwiftUI, layout A, one `progress.json`, no SwiftData, no type named Path. CI copies the Life is a Game three-job workflow with every `LifeIsAGame` string renamed. Splice login 503s on this laptop, so the Mac plus a free Apple ID is the install that works today. Audio is in git. `.env` is not.

## Checkpoints that need the owner

- Pick a Tonight layout after a week on the phone. Delete the other two.
- On the Mac: clone, `xcodegen generate`, pick a team, Run. Hear chapter 4. If a paragraph drags, cut words in `greek.json` and re-run tts; only that beat regenerates.
- Read chapters 3 to 5 against the Theogony lines cited. The claims are mine from the text, not from a translation the owner has checked.
- Five strangers, three nights. Two numbers: finished chapter 3, opened chapter 4 the next night.

## 2026-09-13

- First MVP story is Family, not Battle, not Mythologies, not one-chapter-a-night. The POC already tells a chapter. Paladin's missing piece here is the house you can walk after you hear it. The plan said audio, variants, and a graph, and that quiz apps fake the graph. So the graph is the slice.
- The graph is derived in Engine (`Family.of`) from `entities[].parents` plus claims on heard lessons. iOS does not walk parents. Aphrodite stays off the tree because her parents are the fork. Gaia now names Chaos as a parent so the spine is data, not a hardcoded union.
- Home is `Screen` × `Tab`. Lesson and Done stay full screen. Tab bar is Tonight and Family only.

- First video work is a short, not an in-app film. Cartoon stills come from Fal. Prompts live in `content/prompts.json`. The nightly player stays beat-by-beat so the family check still has a pause. `docs/STATUS.md` is the file a new session reads first.
- Assemble is ffmpeg on this machine, not CapCut. CapCut has no official MCP and no public editing API. Community servers write desktop draft files and still need a person to export. This box is Linux, so those drafts would not open here. `tools/assemble.mjs` cuts 1080x1920 and Ken Burns portraits. A leftover landscape still would pan; new stills stay `portrait_16_9` so a short is one frame size. `tools/tts.mjs --short` owns the hook voice. `tools/short.mjs` runs both.
- While testing, Fal image jobs use a cheap illustration model (`fal-ai/recraft-20b`), not Recraft V3/Pro. Every still in a short is the same size (`imageSize` in `content/prompts.json`). Mixed landscape was a one-off to fit six figures and broke the "real short" cut.
- The chapter-4 film stays on this machine. GitHub rejects 100 MB+ files, and a 111 MB mp4 does not belong in the ipa. Watch streams it over the LAN. `tools/serve-film.py` binds the Wi-Fi address only and serves one allow-listed file behind a token path. iOS reads `content/films.json`. Not public HTTPS. Same Wi-Fi, not the internet.
