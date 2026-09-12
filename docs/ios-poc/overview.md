# iOS POC plan

The plan is the deliverable. Do not implement until the owner says to start.

## Context

The web player at `web/` already tells three Greek chapters. Stills, Cartesia audio, checks, variants, and recall all work in a browser. The owner wants that loop on an iPhone they can hold, the same way [life-is-a-game](https://github.com/nabil144/life-is-a-game) went from HTML mockups to an unsigned `.ipa` on the phone.

`docs/build-plan.md` had parked iOS in "month 4, after paying users." That was right for an App Store listing. It is the wrong gate for a personal install. The content has earned a shell. The shorts have not earned a store page.

## Scope

**In.** Tonight, Lesson (stills plus one MP3 per beat), family check, variant fork, three recall cards, Done. Progress in one JSON file on device. Three written chapters only. Unsigned `.ipa` from GitHub Actions, installed with Splice. Engine types and decode tests that run on Linux.

**Out.** Family tab, Sunday battle, Mythologies shelf, Hearth+, accounts, sync, App Store, notifications, a second content file, original drawings, a new git remote. The web player stays. Do not rewrite `content/greek.json` for Swift.

## Constraints

- No Mac on the desk for everyday builds. Build on `macos-15` runners. `splice` is on PATH here and `splice login` currently dies with HTTP 503 from Apple, then segfaults. Life is a Game already hit this. The unsigned `.ipa` is still the CI artifact. The working install, until Splice is back, is Xcode on a Mac with a free Apple ID, or a later Splice retry. Do not declare the POC done on a green Actions badge.
- Public repo on `nabil144`, `github-personal` SSH alias, per-repo identity. Free macOS minutes. Work account stays out.
- iOS 26 / Xcode 26 / Swift 6, same as `life-is-a-game/project.yml`. Copy those numbers, do not invent new ones.
- Content is `content/greek.json`. Stills are `web/stills/*.jpg` (~2.6 MB) and already in git. Audio is `web/audio/<lesson>/<n>.mp3` (~8.3 MB, 25 clips), on disk, **not committed**. The runner will not see it until `web/audio/` is added. Both fit in the `.ipa` once they are in the tree.
- `node content/check.mjs` stays the content gate. Swift does not reimplement it. Swift decodes what the check already accepted.
- This laptop has no iOS control skill. Runtime proof is the Actions Simulator screenshot plus the owner tapping the phone after `splice install`. Flag that on every UI phase.

## Alternatives

**A. Same repo, Engine plus App, copy the Life is a Game pipeline.** One `greek.json`, one stills folder, one audio tree. Web and iOS are two skins. CI already knows how to test a Swift package and ship an unsigned ipa from this account.

**B. New repo that vendors or submodules content.** A cleaner iOS-only history. Every chapter edit becomes a sync bug. The 11 MB of media gets copied or forgotten.

**C. Wrap the web player in a `WKWebView`.** Fastest tap on a phone. Loses background audio, home-screen audio controls, and the reason to have a Swift app at all. Paladin is not a website in a box.

Choice is A. The product is the corpus. The app is a reader. Splitting the corpus from the reader is how they drift. A new repo earns its place if signing, privacy nutrition, or a second store listing ever needs a different remote. That is not this POC.

## Applicable skills

- **how** over `life-is-a-game` Engine, `project.yml`, and `.github/workflows/build.yml` before copying each.
- **principle-model-the-domain** for `Beat` as an enum and `Progress` as one document.
- **principle-boundary-discipline** for JSON decode at the bundle edge.
- **principle-prove-it-works** for Simulator screenshot and a real Splice install, not "it compiled on the runner."
- **principle-sequence-verifiable-units** for the phase order below.
- **unslop** and **technical-writing** on any README or DECISIONS edit.
- `/deslop` before each commit. **no-comments** before review.

## Phases

1. [Engine package](phase-1-engine-package.md)
2. [Decode the corpus](phase-2-decode.md)
3. [XcodeGen app stub](phase-3-xcodegen.md)
4. [Cloud build](phase-4-ci.md)
5. [Bundle media](phase-5-bundle.md)
6. [Progress store](phase-6-progress.md)
7. [Tonight](phase-7-tonight.md)
8. [Stills player](phase-8-player.md)
9. [Check, variant, recall](phase-9-quiz.md)
10. [Install on the phone](phase-10-install.md)

[Testing](testing.md) lists the checks that span phases.

## Verification

```sh
node content/check.mjs
cd Engine && ../swift.sh test
gh run download --name Hearth-unsigned-ipa --dir artifacts/
splice install artifacts/Hearth-unsigned.ipa
```

`swift.sh` can be copied from `~/life-is-a-game/swift.sh` plus `.toolchain/` if Engine tests should run on this laptop. The first cloud build does not depend on that copy. The phone install does not either.

## Implementation guidance

The implementer owns each phase as a Feature playbook run.

- Run **how** on `life-is-a-game` Engine and the workflow before the first copy.
- Do not invent a `Path` type. SwiftUI already owns that name. That collision broke the first Life is a Game cloud build.
- Keep the Engine free of SwiftUI and UIKit so `swift test` stays Linux-legal.
- One JSON progress document. No SwiftData. Life is a Game already made that call for the same data size.
- `/deslop` each diff. **unslop** any prose. **show-me-your-work** into `DECISIONS.md` when a phase changes a call from this plan.
- After the install PR, Cursor **babysit**. A subagent that opens a PR returns the URL and does not babysit.

Temporary breakage is allowed through phase 4. The stub app may screenshot as a blank Tonight. Phases 7 to 10 must each leave a chapter playable on the Simulator artifact. Do not keep a WKWebView fallback "just until Swift is ready."
