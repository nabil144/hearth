# Testing

Back to [overview](overview.md).

## Before the first ipa that should speak

`git ls-files web/audio` must list the 25 MP3s. If it prints nothing, the runner has no voice. Commit those files on purpose. They are not a secret. `.env` stays untracked.

## Always

- `node content/check.mjs` on every push. Already wired.
- `swift test` in `Engine/` on `macos-15`. Phase 4 onward.

## Per UI phase

No iOS control skill is installed. Do not pretend XCTest on Linux covers a still or a voice.

| Phase | Surface | What you look at |
| --- | --- | --- |
| 4 | Actions screenshot | Stub launched |
| 5 | `zipinfo` on the ipa | JSON and media inside |
| 7 | Actions screenshot | Tonight card, correct title |
| 8 | Actions screenshot | A real Met still, not a gradient |
| 10 | The owner's phone | Voice, miss-cite, persist |

## Date trap

Any test that builds a "today" string must use the local calendar, not `ISO8601DateFormatter` on `Date()` at midnight-adjacent hours. The web player already paid for this.

## What we will not add

A second copy of `greek.json` under `testdata/` that can rot. The Engine test reads the file authors edit.
