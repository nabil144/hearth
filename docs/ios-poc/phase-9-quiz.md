# Phase 9. Check, variant, recall

Back to [overview](overview.md).

## Goal

The rest of the nightly loop. A check pauses the voice. A wrong answer shows the claim and the cite, never a bare fail. A variant shows both sides and does not ask for a winner. Recall runs up to three cards, then marks the lesson heard and shows Done.

## Changes

- `app/Sources/Views/CardView.swift`. Four options, Held, miss-plus-cite, Continue.
- Variant layout from `design/lesson.html` fork. Side label is the first word of the source work.
- Recall uses `pickRecall` from the engine. Done copy from the web player. "Tomorrow:" plus the next title.

`app/app.js` is the behavior spec. Port the rules, not the DOM.

## Data structures

Reuse `Card`, `Variant`, and `Progress` from the engine. No second card type in the app.

## Verification

**Static.** Engine tests for pickRecall (skip the chapter's check card, fill from this lesson, prefer due cards) and for grade due dates.

**Runtime.** Simulator can tap if a later phase adds a UI test. This POC does not add XCUITest unless a tap is free. Native control skill is absent. The owner walks chapter 4 on the phone in phase 10. That walk is the test.
