# Hearth

A mythology learning habit. One chapter a night, five minutes, a voice over a sequence of pictures, from the actual texts. When Hesiod and Homer disagree, you hear both. When you get a recall card wrong, you see the line, not "Oops".

The repo holds the plan, the mockups, a web player, and a SwiftUI iOS shell that reads the same `content/greek.json`. Three Greek chapters are written. It is a POC, not a store listing.

## Layout

- `docs/plan.md` why this and not game lore, who already sits here, the money, the phases. Written first.
- `docs/spec.md` one page. What phase 1 is and is not.
- `docs/screens-and-flows.md` five screens, the first night, a normal night, Sunday.
- `docs/build-plan.md` what this borrows from `life-is-a-game` and the order of work.
- `design/` static HTML mockups. Three Tonight layouts behind a switcher, plus Lesson, Family, Battle, and Mythologies.
- `content/greek.json` the data. Traditions, sources with locators, entities with parents, claims, variants, recall cards, and twelve chapters. Chapters 3, 4, and 5 have their spoken beats written.
- `content/stills.json` which Met Open Access object illustrates which beat.
- `content/check.mjs` proves every claim has a source, every check asks only what its chapter said, every written lesson ends in recall, and no `do-not-ship` tradition has a lesson.
- `tools/stills.mjs` downloads the CC0 pictures from the Met and writes their credits into `greek.json`.
- `tools/tts.mjs` generates one MP3 per beat with Cartesia. Idempotent by text hash.
- `app/` the player. Vanilla HTML, CSS, and JS. Reads `content/greek.json`, plays `app/audio/`, keeps progress in local storage, installs to a phone home screen.
- `Engine/` pure Swift package. Decodes the corpus and owns progress and recall rules. Tests run on Linux.
- `App/` SwiftUI shell. Tonight, Lesson, Done. One JSON progress file. No server.
- `project.yml` XcodeGen definition. `xcodegen generate` produces the Xcode project.
- `docs/ios-poc/` how the iOS shell is sequenced.
- `DECISIONS.md` why things are the way they are.

## Run the player

On the web: https://nabil144.github.io/hearth/app/

Locally:

```sh
cd ~/hearth && python3 -m http.server 8000
```

Then open http://localhost:8000/app/ in a phone-width window. `?lesson=greek-04&beat=5` opens a beat directly.

Without audio files the player shows "no audio yet" and you tap through. To generate the audio:

```sh
export CARTESIA_API_KEY=sk_car_...
node tools/tts.mjs --voices            # pick a voice id
CARTESIA_VOICE_ID=<id> node tools/tts.mjs   # all written chapters
node tools/tts.mjs greek-04            # one chapter
```

Re-running only regenerates beats whose text, voice, or model changed.

## Check the content

```sh
node content/check.mjs
```

Prints the counts and exits 0, or lists every unbound id and exits 1. GitHub Actions runs it on every push.

## Run the iOS app on a Mac

```sh
git clone git@github-personal:nabil144/hearth.git
cd hearth
brew install xcodegen
xcodegen generate
open Hearth.xcodeproj
```

In Xcode, pick your development team under Signing, then Run on the Simulator or a plugged-in iPhone. The first launch should show Tonight with "The father who ate".

Engine tests on this Linux laptop:

```sh
cd Engine && ../swift.sh test
```

Cloud build on push to `main` uploads `Hearth-unsigned-ipa`. Download with `gh run download --name Hearth-unsigned-ipa --dir artifacts/`. `splice install` if login works that day. If Splice 503s, use Xcode on the Mac.

## Look at the mockups

https://nabil144.github.io/hearth/design/today-a.html. The strip at the top switches between screens.
