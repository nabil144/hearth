# Hearth. Product spec

One page. If a feature is not here, it is not in phase 1. The reasoning behind every line is in [plan.md](plan.md).

## The job

The user liked the Greek gods once and cannot hold the family in their head. Every quiz app they tried asked for names the app never taught. Hearth tells one chapter a night, five minutes, with the screen off if they want, and asks back only what it said.

Said as a job story. When I have a commute or the ten minutes before sleep, I want one story from a mythology told to me well, so that after a month I can walk the family from Chaos to Zeus and know which version I am holding.

## Who it is for

The person who read Percy Jackson at fourteen and watches a 40-second Zeus clip now. Not a classicist. Not a priest.

## Non-goals for phase 1

- No accounts, sync, or App Store. Web first. The plan says do not open Xcode until the videos move.
- No recall question on a name the chapter never said.
- No single "correct" version where the texts disagree.
- No living-religion tradition. `do-not-ship` until a person from that tradition has signed the path.
- No Marvel Thor, no God of War Kratos, no Percy Jackson. Hesiod's Zeus, drawn by us.
- No streak counter you can lose. No leaderboard. No $99 trial.

## The six things the app knows

The shape is the same one the plan names. `content/greek.json` is the first instance.

- Tradition. Greek, Norse, Egyptian. Carries a sensitivity flag: `literary`, `living-religion`, `do-not-ship`.
- Source. A public text and a locator. "Hesiod, Theogony, lines 154-210." Plus a one-line paraphrase in our words.
- Entity. A god, mortal, monster, place, or object. `parents` edges make the genealogy graph.
- Claim. One sentence the app will teach and later ask. Bound to one Source and a confidence: `attested`, `common-version`, `variant`, `later-invention`.
- Variant. A question with two or more Claims as answers. The lesson shows both. The recall card asks "in Hesiod, not in Ovid".
- Lesson. One chapter. Title, hook sentence, minutes, the Sources and Claims it uses, an optional Variant, one mid-chapter check bound to a Claim.

## Rules of the nightly loop

1. One chapter a night at most, from the tradition the user is in.
2. Narration first. The transcript scrolls with the voice. Screen off keeps playing.
3. One family check in the middle, bound to a Claim the chapter already said.
4. When the chapter carries a Variant, both versions show side by side. The user is not asked to pick.
5. Three recall cards after. At least one may come from a previous chapter.
6. A wrong answer shows the Source locator, not "Oops".
7. Once a week, a battle. Timed recall across the cycle so far. Same rule 6.
8. A seal is earned for finishing a cycle or for holding a Variant correctly in review twice. Seals cannot be lost.
9. The first Greek cycle is free forever. Norse, the epics, and comparative weeks are Hearth+.

## Screens

Tonight, Lesson, Family, Battle, Mythologies. Five. Mockups in `design/`. Flows in [screens-and-flows.md](screens-and-flows.md).

## Voice

Family gossip, then the cite. "The father who ate", not "Chapter 3: Kronos". "Held", not "correct". "Still warm", not "history". A cite is always a work and a locator a reader can open.

## Success metric for the 90-day gate

Two numbers from the plan. Do ten "most people can't name Zeus's siblings" shorts move at all. Do people who hear chapter 1 come back for chapter 4. If neither moves, the graph becomes a newsletter and the app stops.

## Platform

Phase 1 is a web app, installable to the home screen. Audio is pre-recorded files, not TTS. iOS comes in phase 2 on the same content files, built the way `life-is-a-game` is built, on GitHub Actions macOS runners and installed with Splice.
