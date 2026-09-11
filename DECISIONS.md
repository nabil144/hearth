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
- A Lesson is now a list of beats. `still` (one picture, one spoken paragraph), `check` (a card, the voice pauses), `variant` (two claims side by side), `recall` (last, always). One audio clip per beat, `app/audio/<lesson>/<beat>.mp3`, so the player never syncs timestamps against a five-minute file. It plays clip N over still N and advances on `ended`. Cheaper to build, cheaper to re-record one paragraph, and the check pause is free.
- Recall questions live in a top-level `cards` list bound to claims, not inside lessons. A card asked as tonight's check is the same object that comes back next week in recall. `check.mjs` still refuses a check whose claim the chapter never says.
- Voice is Cartesia TTS, not the owner's voice, for the POC. `tools/tts.mjs` generates one MP3 per beat from `greek.json`, keyed by a hash of model, voice, and text, so re-running only touches beats whose words changed. The plan wants a face people recognize for the shorts; the app voice can be synthetic while the test is "do they come back", and swapped later without touching the player. Verified against the API up to the auth wall (401 with a fake key, request shape accepted).
- Stills come from the Met's Open Access collection, CC0, downloaded by `tools/stills.mjs` from a manifest of object IDs in `content/stills.json`. Real vases and marbles for free, with a credit line, instead of placeholder art or something scraped. Original drawings replace them when there is a drawing budget; the beat shape does not change.
- Fourth variant added while writing chapter 4. How Zeus got the sky. Hesiod 883-885 has the gods ask him; Iliad 15.187-193 has the brothers draw lots. Same century, two answers. Exactly the kind of fork the product exists to keep open.

## Checkpoints that need the owner

- Pick a Tonight layout after a week on the phone. Delete the other two.
- Cartesia key. `CARTESIA_API_KEY=sk_car_... node tools/tts.mjs --voices` to pick a voice, then `CARTESIA_VOICE_ID=... node tools/tts.mjs` to generate the three chapters. Commit `app/audio/`.
- Listen to chapter 4 once end to end before anyone else does. If a paragraph drags, cut words in `greek.json` and re-run tts; only that beat regenerates.
- Read chapters 3 to 5 against the Theogony lines cited. The claims are mine from the text, not from a translation the owner has checked.
- Five strangers, three nights. Two numbers: finished chapter 3, opened chapter 4 the next night.
