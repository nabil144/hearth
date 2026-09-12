# Phase 1. Engine package

Back to [overview](overview.md).

## Goal

A Swift package named `HearthEngine` exists. It compiles on Linux. It has no UI imports. Later phases add types into this package, not into the app target.

## Changes

- `Engine/Package.swift`. Library `HearthEngine`, iOS 17 and macOS 14 like LifeEngine, so `swift test` runs on the laptop toolchain and on the runner.
- `Engine/Sources/HearthEngine/HearthEngine.swift`. Empty public module, one exported placeholder type or nothing.
- Copy `~/life-is-a-game/swift.sh` into this repo only if the local `.toolchain` already exists next to Life is a Game and you want Linux tests tonight. Optional. The cloud job does not need it.

## Data structures

None yet. Scaffold only.

## Verification

**Static.** `cd Engine && swift test` on the Actions `macos-15` job, or `../swift.sh test` locally if the toolchain is wired.

**Runtime.** Not applicable. No behavior. Native control skill is absent. Flag stands.
