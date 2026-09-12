# Phase 10. Install on the phone

Back to [overview](overview.md).

## Goal

The owner has Hearth on the iPhone and can hear chapter 4 with stills. Progress survives a force-quit.

## Changes

- `README.md`. Download line first. `gh run download --name Hearth-unsigned-ipa --dir artifacts/`. Then two install paths. Prefer `splice install` if `splice login` works that day. If it 503s, as it does now, install from Xcode on a Mac with a free Apple ID and trust the developer profile on the phone. Life is a Game already documented that fallback.
- `DECISIONS.md`. Record same-repo, Engine decode, no SwiftData, layout A, audio background, iOS pulled forward as a personal POC, and the Splice 503.
- Do not copy `LifeIsAGame` scheme, project, `.app`, or bundle id strings into the workflow. The simulator job fails on `test -d .../LifeIsAGame.app` if those names stay.

Do not open the App Store. Do not add a signing team.

## Data structures

None.

## Verification

**Static.** Both workflows green. `zipinfo` on the ipa lists `greek.json`, stills, and `greek-04/0.mp3`.

**Runtime.** On the phone. Tonight, Listen, one still with voice, one check (miss on purpose to see the cite), finish recall, force-quit, reopen, Still warm shows chapter 3 or 4. Native control skill is absent. The owner is the instrument. The implementer does not declare done on a green Actions badge.
