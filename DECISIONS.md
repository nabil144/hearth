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

## Checkpoints that need the owner

- Pick a Tonight layout after a week on the phone. Delete the other two.
- Decide whose voice records chapter 4. The plan wants a face people recognize.
- Read chapters 1, 5, 7, 9, and 10 against the texts and fill their claims. The check will stay green with empty claims, which is a gap in the check, on purpose for now.
