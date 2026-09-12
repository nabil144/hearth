# Phase 8. Stills player

Back to [overview](overview.md).

## Goal

A still beat shows the Met picture, the spoken caption, the credit line, and plays that beat's MP3. `AVAudioPlayer` or `AVPlayer`. On `didFinish`, advance only if the beat is `still`. Tap left goes back, tap right goes forward. Screen-off keeps the voice going (`audio` background mode from phase 3). Missing file shows "no audio yet" and does not crash.

## Changes

- `app/Sources/Views/LessonView.swift`. Dots, chapter line, still frame, caption.
- `app/Sources/Voice.swift`. One player. Stop on beat change. The `onended` bug from the web review must not return. Only still beats auto-advance.

## Data structures

The lesson screen reads `state.beat` and `lesson.beats[i]`. No parallel "current still index."

## Verification

**Static.** App compiles. Engine tests unchanged.

**Runtime.** Simulator screenshot of `greek-04` beat 1 (the Vestal). Confirm the JPEG is visible, not a placeholder. Native control skill is absent. Audio on Simulator is best-effort. Real listen is phase 10 on the phone. Say so in the PR if the Simulator is mute.
