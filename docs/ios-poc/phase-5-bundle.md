# Phase 5. Bundle media

Back to [overview](overview.md).

## Goal

The app target contains `greek.json`, the 21 still JPEGs, and the 25 MP3s. On launch the stub can print the first written lesson title from the bundled JSON.

## Changes

- `project.yml` resource folders for `content/greek.json`, `app/stills`, and `app/audio`. Folder references, not file lists, so a new clip is a git add and not a project edit.
- A tiny `Bundle+Corpus` loader in the app that asks `HearthEngine` to decode the bundled JSON. Keep the loader in the app. The engine stays file-agnostic.

Do not copy media into `Engine/`. Do not add a download step. Commit `app/audio/` in this phase or the one before it. Stills are already tracked. The MP3s are not. A bundle step that only lists folders in `project.yml` will ship a silent ipa from CI.

## Data structures

Bundle URLs. `still.src` in JSON is `stills/<lesson>-<beat>.jpg`. Audio is `audio/<lessonId>/<beatIndex>.mp3`. The loader maps those relative paths onto the resource folder. One function. No second path scheme.

## Verification

**Static.** Engine tests still green. ipa size grows by about 11 MB.

**Runtime.** Simulator screenshot or a log line in the stub that shows "The father who ate". Native control skill is absent. The screenshot or the build log is the surface. Confirm the ipa contains `greek.json` with `zipinfo`.
