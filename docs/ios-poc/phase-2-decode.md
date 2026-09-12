# Phase 2. Decode the corpus

Back to [overview](overview.md).

## Goal

`HearthEngine` decodes `content/greek.json` into typed values. A Linux test loads the real file from the checkout and fails if a written lesson cannot be walked.

## Changes

- `Engine/Sources/HearthEngine/Corpus.swift`. Codable types that match the JSON keys already in the file. No rename at the boundary.
- `Engine/Tests/HearthEngineTests/DecodeTests.swift`. Walk from the test file to the repo root and read `content/greek.json`, the same four-parent walk `LifeEngine` uses for `templates/`. Assert three written lessons, four beat kinds, every check card exists, last beat is recall. Do not vendor a second JSON under `testdata/`.

Do not port `check.mjs` into Swift. The JS check stays the authoring gate. The Swift test proves the decoder agrees with the file the check already accepted.

## Data structures

`Corpus` holds arrays of `Tradition`, `Source`, `Entity`, `Claim`, `Variant`, `Card`, `Lesson`. `Beat` is an enum with `still`, `check`, `variant`, `recall`. `Still` is optional on a still beat. Lookups are dictionaries keyed by `id`, built once after decode.

## Verification

**Static.** Engine tests green. `node content/check.mjs` still green.

**Runtime.** Not applicable. Native control skill is absent. The test file read is the runtime for this phase.
