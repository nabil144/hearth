# Phase 4. Cloud build

Back to [overview](overview.md).

## Goal

A push to `main` runs engine tests, builds an unsigned `.ipa`, and uploads it. The first screenshot may be the stub. That is enough. The owner can `gh run download` the same way they do for Life is a Game.

## Changes

- `.github/workflows/build.yml`. Copy `~/life-is-a-game/.github/workflows/build.yml`. Rename scheme, project, bundle id, artifact names to Hearth. Keep `macos-15`, Xcode 26 fallback, `CODE_SIGNING_ALLOWED=NO` on the device job, Simulator screenshot after `sleep 4`.
- Keep `.github/workflows/check.yml`. Content check and Swift build are different jobs.

The first Life is a Game cloud build failed on seven app issues, none in the engine. Read `~/life-is-a-game/DECISIONS.md` before the first push. Public `Path`, missing `@Observable`, a huge `Settings` body, and a private `Objective` init were the killers. Hearth has none of those types. Do not introduce them.

## Data structures

None.

## Verification

**Static.** Engine-tests job green. Device-ipa job uploads `Hearth-unsigned.ipa`.

**Runtime.** Open the `simulator-screenshot` artifact. It will be a stub. That is the check. Native control skill is absent. The screenshot is the surface.
