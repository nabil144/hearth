# Phase 7. Tonight

Back to [overview](overview.md).

## Goal

The app opens on Tonight. One card. The next unheard written lesson. Listen starts Lesson. Still-warm list under it. Palette and type from `design/shared.css` and `design/today-a.html`. Layout A only. B and C stay web mockups.

## Changes

- `App/Sources/Views/TonightView.swift`. Eyebrow, title, hook, source line, Listen.
- `RootView` switches on a screen enum: `tonight`, `lesson`, `done`. Same three screens as `app/app.js`.

No tab bar. Family and Mythologies are out of this POC.

## Data structures

`Screen` enum with associated `lessonId` and `beat` on `.lesson`. One source of truth, not a pile of booleans.

## Verification

**Static.** App compiles on the runner.

**Runtime.** Simulator screenshot artifact shows "The father who ate" and a Listen control. Native control skill is absent. The screenshot is the surface. Compare it to `design/today-a.html` by eye, not pixel-exact.
