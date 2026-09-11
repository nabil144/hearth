# Build plan

How Hearth gets built, and what it borrows from `life-is-a-game`. That repo went from an idea to an unsigned .ipa on the phone in one day by writing the spec, HTML mockups, and a tested engine before any UI code. Hearth copies that order and changes the target, because the plan says web first and no Xcode until the shorts move.

## What carries over from life-is-a-game

| life-is-a-game | Hearth | Why it transfers |
|---|---|---|
| `docs/spec.md`, one page, non-goals up front | `docs/spec.md` | Same gate. If a feature is not on the page, it is not in phase 1. |
| `design/*.html`, three Today styles behind a nav switcher | `design/*.html`, three Tonight styles | The owner reacts to a phone screen before any real code. Losers get deleted. |
| `templates/*.json`, bundled starter paths | `content/greek.json` | Content is data in the repo, not strings in code. |
| `Engine/` pure Swift package with 20 tests | `content/check.mjs` | The rule that matters most ("never ask what the chapter did not say") is a check a machine runs, not a review note. |
| `DECISIONS.md` | `DECISIONS.md` | Same trail, same format. |
| Public repo on the personal account, `github-personal` SSH alias, per-repo git identity | Same | Free macOS minutes later. Work account untouched. |
| GitHub Actions macOS build, Splice install | Phase 2 only | Hearth phase 1 is a web app. The iOS pipeline is ready when the content has earned it. |

What does not carry over. Life is a Game has no server and one user. Hearth has audio files, paid tiers, and strangers. So phase 1 needs a static host and a payment provider, and the content pipeline matters more than the app shell.

## Phases

**Phase 0. Twelve chapters and thirty shorts.** Weeks 1 to 4.

- Fill `content/greek.json` to twelve real chapters. Every claim bound to a source with a locator. `node content/check.mjs` stays green.
- Write the twelve scripts. Family gossip, then the cite. About 700 words each for five minutes of audio.
- Record them. One voice. No music bed at first.
- Cut thirty shorts from the plan's three hooks, ten each. Face to camera, no God of War armor.
- A one-page waitlist at the Pages URL of this repo, with `design/today-c.html` as the interactive hook.
- Gate. If none of the thirty move, stop. The graph becomes a newsletter.

**Phase 1. The web habit.** Weeks 5 to 12.

- Pick one Tonight layout from the three mockups. Delete the other two.
- Static site, no framework. One HTML page per screen, one script that reads `content/greek.json` and renders it. Audio as MP3 in the repo or a bucket.
- Local storage for progress. No account. Export as JSON so nothing is lost when accounts arrive.
- Family graph rendered from `entities[].parents`. Variant edges drawn from `variants`.
- Recall scheduling. A card comes back at one day, three days, a week, then monthly. Plain table, no algorithm paper.
- Sunday battle from the claims the user has heard.
- Hearth+ behind a payment link. $39.99 a year or $6.99 a month. Two numbers.

**Phase 2. iOS.** Month 4 onward, only if phase 1 has paying users.

- Same content files. A SwiftUI shell that reads them, plus background audio and notifications.
- Built the `life-is-a-game` way. XcodeGen, GitHub Actions macOS runner, unsigned .ipa, Splice on the laptop. Copy `.github/workflows/build.yml` and `project.yml` from that repo as the starting point.

**Phase 3. Norse and one epic.** Month 6.

- `content/norse.json`. Prose Edda and Poetic Edda locators. Ten chapters.
- The Odyssey chaptered, 24 chapters of five minutes.
- First comparative week. Floods or tricksters.
- A changelog that says which chapters used a late variant and why.

**Month 12. Decision.** Egyptian or Mesopotamian next, or point the same reader and quiz compiler at the game-lore plan.

## The first week, concretely

1. Open Hesiod. Fill chapters 1, 5, 7, 9, and 10 in `content/greek.json`, which are still empty of claims. Run the check.
2. Write the chapter 4 script, "Zeus's siblings", first. It is the hook chapter and the one the shorts point at.
3. Record it once on a phone. Play it back against `design/lesson.html`. If the five minutes drag, cut the script, not the format.
4. Push. The Pages URL is the waitlist.

## What is not decided

- Which Tonight layout wins. Three candidates in `design/`. See DECISIONS.md for the current lean.
- Whether audio is recorded by the owner or a paid voice. The plan prefers a face and a voice people recognize.
- Where MP3s live. The repo is fine under 100 MB. A bucket after that.
- Payment provider. Any of them works for two prices. Pick the one with the least setup.
