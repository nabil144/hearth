# Phase 6. Progress store

Back to [overview](overview.md).

## Goal

Heard lessons and card due dates persist across launch. Same shape as the web key `hearth.v1`. One atomic JSON write in Application Support.

## Changes

- `Engine/Sources/HearthEngine/Progress.swift`. `heard: [LessonID: Day]`, `cards: [CardID: CardRecord]`. Gaps `[1, 3, 7, 30]`. Day is a calendar date in the local timezone, not `Date` UTC. The web player already hit this. `toISOString` at 02:00 UTC+3 stored yesterday.
- `Engine` functions: `nextLesson`, `pickRecall`, `grade(held:)`, `grade(missed:)`. Pure. No file I/O.
- `ios/Sources/Store.swift`. Load and save the document. `@Observable`, or it will not travel through `.environment`. On decode failure, move the file aside (`progress.broken-<unix>.json`) instead of overwriting it. Same pattern as Life is a Game `world.json`.

## Data structures

`Progress` is the document. `CardRecord` holds `due`, `held`, `missed`. Session quiz cursor stays in memory, same as `web/app.js` `session`. It is not persisted.

## Verification

**Static.** Engine tests. Grade a card, save, load, assert due is today plus one / three / seven / thirty. A date-at-local-midnight test so UTC slice cannot regress.

**Runtime.** Not on a phone yet. Native control skill is absent.
