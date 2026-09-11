# Hearth

A mythology learning habit. One chapter a night, five minutes, narrated, from the actual texts. When Hesiod and Homer disagree, you hear both. When you get a recall card wrong, you see the line, not "Oops".

This repo is the mock. Spec, screen mockups you can open on a phone, the content shape with real Hesiod locators, and the build plan. No app yet. The plan says not to open Xcode until the shorts move.

## Layout

- `docs/plan.md` why this and not game lore, who already sits here, the money, the phases. Written first.
- `docs/spec.md` one page. What phase 1 is and is not.
- `docs/screens-and-flows.md` five screens, the first night, a normal night, Sunday.
- `docs/build-plan.md` what this borrows from `life-is-a-game` and the week-by-week order.
- `design/` static HTML mockups. Three Tonight layouts behind a switcher, plus Lesson, Family, Battle, and Mythologies.
- `content/greek.json` the data shape with twelve Greek chapters outlined, seven of them bound to claims and sources.
- `content/check.mjs` proves every claim has a source, every check asks only what its chapter said, and no `do-not-ship` tradition has a lesson.
- `DECISIONS.md` why things are the way they are.

## Look at the mockups

On the web: https://nabil144.github.io/hearth/design/today-a.html

Locally on the phone, the same way as `life-is-a-game`, through the `serve-md` server on the one open port:

```sh
serve-md ~/hearth/docs/plan.md --port 53317 --static ~/hearth/design
```

Then open `http://<laptop-ip>:53317/design/today-a.html`. The strip at the top switches between screens.

## Check the content

```sh
node content/check.mjs
```

Prints the counts and exits 0, or lists every unbound id and exits 1. GitHub Actions runs it on every push.
