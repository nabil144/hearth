# Phase 3. XcodeGen app stub

Back to [overview](overview.md).

## Goal

`xcodegen generate` produces an iOS app target that links `HearthEngine` and launches a one-line Tonight stub. No media yet.

## Changes

- `project.yml`. Copy structure from `~/life-is-a-game/project.yml`. Rename to Hearth. Bundle id `com.nabil.Hearth`. Display name Hearth. Portrait only. `UIBackgroundModes` is `audio`, not `fetch`. Empty `DEVELOPMENT_TEAM`. Signing automatic, disabled later in CI.
- `ios/Sources/HearthApp.swift` and a stub `RootView`. No Settings split yet. Do not name any type `Path`.
- `ios/Info.plist` generated via the `info` block, same as Life is a Game.

## Data structures

None beyond the stub view. The app does not decode the corpus in this phase.

## Verification

**Static.** `xcodegen generate` on the runner. `xcodebuild` is phase 4.

**Runtime.** None on this laptop. Native control skill is absent.
