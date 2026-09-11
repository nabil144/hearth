# Hearth

A plan for a mythology learning app. The easier Paladin. Same habit engine as the game-lore file, pointed at a corpus nobody owns.

This file is an explanation, written before this repo existed. Its sister plan for game lore lives outside the repo.

Working name. Hearth. The place stories get told every night. The product is the telling, not a costume of Zeus.

Date. 11 September 2026.

---

## What I think

If you want Paladin's money motion with less legal risk, start here. Not with game lore.

Mythology already is what Paladin flattened history into. Named figures. Family fights. Objects that mean more than they look. A commute-sized story. You can read the source texts. Homer, Ovid, Snorri, the Pyramid Texts. No publisher can send a letter because you taught the Cyclops.

The catalog is close to infinite without a license. Every culture has cycles. Every cycle has variants. Comparative paths never run out. New translations and school syllabi keep the hook warm. Paladin already proved the format on the Iliad and the Odyssey, which tells you the factory next door will come for this vertical if they have not already.

That is the catch. The idea is easier. The empty slot is less empty than game lore. Tomo, Pantheon, MythJet, and Mythos Unveiled already say "Duolingo for gods." None of them looks like a finished habit company with audio, a voice, and a short-form machine. You still have to be the one that feels like a show, not a quiz wrapper.

I would ship Hearth first, on the same engine you later point at games. One company. Two libraries. Or two store listings, Smartheads-style. Do not build two codebases.

---

## Why this is easier than game lore

| | Mythology | Game lore |
| --- | --- | --- |
| Who owns the stories | Mostly nobody. Public-domain texts. | Publishers. |
| "Infinite content" | True. Traditions, variants, comparisons, epics. | True only if you add worlds one legal posture at a time. |
| Viral hook | "They made Duolingo for Greek gods." | "They made Duolingo for game lore." Stronger nerd identity. Hotter lawyers. |
| Accuracy fight | Classicists and living-religion communities. Winnable if you cite texts and stay off sacred costume. | Reddit plus a takedown. |
| Closest competitor | Small myth quiz apps. Extra History and Overly Sarcastic Productions on YouTube. Paladin's Homer paths. | Free wikis and Vaati. |
| Same buyer as Paladin | Yes. Curious commuters. | Narrower. People who already finished a game. |

The pedagogy is almost a copy. Paladin teaches a person. You teach a god, a hero, a monster, then the family they broke.

The one thing you must not copy is Paladin's "great man, no variants" voice. Myths disagree on purpose. That disagreement is the product, the same way contradictions are the product in game lore.

---

## Who already sits here

These existed when I looked, September 2026.

- **Tomo.** "Like Duolingo, but for Greek mythology." Levels, streaks, quizzes. A course wrapper, not a narrated show.
- **Pantheon: Gods and Mythology.** Narrated tales, Iliad and Odyssey chapters, many pantheons, a Pro upgrade. Closest in shape. Still reads like a reading app with a daily god, not a habit you would steal a commute for.
- **MythJet.** Quiz modes, flashcards, nine mythologies, leaderboards. A game about names. Thin stories.
- **Mythos Unveiled.** Character database and quizzes across 15 traditions.
- **YouTube.** Extra History at about 4.6 million subscribers. Overly Sarcastic Productions at about 2.6 million. They own the essay. They do not own the Tuesday after.

Paladin itself shipped the Iliad and the Odyssey as chaptered paths. The Deepstash factory already knows this corpus is free.

None of that is a reason to skip. It is a reason to be a habit with a voice, not a third quiz database. The empty slot is "five minutes, audio, a family graph, and a sentence that creates the category." Same slot Paladin took from history textbooks.

---

## The product

### Who it is for

The person who liked Percy Jackson at fourteen, watches a 40-second Zeus clip now, and cannot hold a genealogy in their head.

Not a classics graduate. Not a priest. Someone who wants the stories to connect, and will give you five minutes if you do not treat living religions like a Halloween aisle.

### What they open every day

One path. One chapter. About five minutes. Narration with the screen off. A family or object check in the middle. A short recall set that may pull last week's card. When two cities told the story differently, you see both. You are not asked to pick a winner unless the path is about that fight.

Once a week, a battle. Timed recall. Wrong answers show the text you used, "Hesiod, Theogony, the castration of Ouranos," not "Oops."

Collectibles are seals for a finished cycle and for holding a variant in review. Original drawings. No Marvel-Zeus. No God of War Kratos in the Greek path. If you later teach how a game reused a myth, that is a different path with a different legal posture.

### What we refuse

Quizzes on names the chapter never said.

One "correct" version of a myth that has three.

Hindu, Indigenous, or other living sacred stories treated as monster-collecting. Those traditions can exist later, with people from them in the room, or not at all.

A $99 trial and a letter-to-Delaware cancel.

An ad that looks like a film the app does not contain.

### The sentence that creates the category

Test these.

- "They made Duolingo for Greek gods."
- "Most people can't name Zeus's siblings."
- "The version you know is the Roman one. The Greek one is meaner."

I would bet on the first for install, the third for trust. Paladin won on category-creation. Manna won on "most X can't answer this." Run both.

---

## The catalog that is actually infinite

This is why mythology beats lore as a first company. The well does not close.

**Launch library, 90 days.** Greek and Norse. They already travel on TikTok. The texts are easy to get. School memory does free acquisition.

**First-year traditions.** Egyptian, Mesopotamian, Celtic. Japanese myth as literature, with care. Mesoamerican cycles with a researcher who has read the actual books, not a blog.

**The infinite layers, once the engine works.**

- Variants of the same story. Homer versus the tragedians versus Ovid versus a vase.
- Genealogies as a graph you can walk. This is the feature quiz apps fake and never finish.
- Objects. Thunderbolts, apples, cauldrons, sun barges. Same muscle as a game item path.
- Comparative weeks. Floods. Dying-and-rising. Tricksters. World trees. This is new content from old texts. It never ends.
- Full epics, chaptered. Iliad, Odyssey, Aeneid, Metamorphoses, Prose Edda, Journey to the West. Paladin already showed people will sit these on a phone.
- How later art reused the myth. A painting, an opera, a game. The game slice is commentary on the public myth plus the title of the game. It is also the bridge into the lore app.

Do not lead with "every mythology on earth." Lead with two traditions done well, then let the home screen say Mythologies the way the lore app says Worlds. The brand is the catalog. The first month is Greek.

---

## The data shape

Same engine as the lore file. Different source types.

A **Tradition** is Greek, Norse, Egyptian. It has a sensitivity flag. `literary`, `living-religion`, `do-not-ship`.

A **Source** points at a public text. "Hesiod, Theogony, lines 154 to 210," or "Prose Edda, Gylfaginning, the binding of Fenrir." Store a locator and a short original paraphrase. You may quote more freely than in game lore. You still write your own chapter.

A **Claim** has confidence.

- `attested`. The named text says this.
- `common-version`. What most modern retellings use.
- `variant`. Another city or century told it differently.
- `later-invention`. A Roman, Victorian, or game addition sitting on an older name.

A **Variant** is an edge between claims. The lesson can fork. The quiz can ask "in Hesiod, not in Ovid."

An **Entity** is a god, mortal, monster, place, or object. The genealogy graph is the home screen people will screenshot.

A **Lesson** is a walk. Original script, audio, original stills, quiz items bound to claim ids.

Ship twelve Greek chapters in a spreadsheet before you draw a mascot.

---

## Legal and care

Most of the launch corpus is public domain. That is the whole point.

Still do the memo. Trademarks exist on modern retellings. Percy Jackson is owned. God of War is owned. Marvel's Thor is owned. Your Zeus is Hesiod's Zeus, drawn by you.

Living religions are the other rail. A Greek path is literature for most buyers. A Hindu path is someone's practice. Indigenous stories are often not yours to app-ify. The rule I would write into the product. `do-not-ship` until a person from that tradition has signed the path. Empty is better than a costume.

Fair use is a side issue here. You are teaching old texts. Quote them. Cite them. Do not scrape a modern illustrated children's book and call it research.

---

## Growth

Same machine as Paladin. Different pictures.

Year 0. Twelve Greek chapters on the web. Thirty shorts.

- Ten of "they made Duolingo for Greek gods."
- Ten of "most people can't answer this" from real claims.
- Ten of a variant twist. "The Medusa you know is late."

Kill it if nothing moves. Mythology hooks die when they look like a classroom poster. They live when they feel like gossip about a terrible family.

After launch. One Greek path free. Norse and the epics behind $39.99 a year or $6.99 a month. Two numbers. Store billing only.

Creators. Extra History and OSP will not partner with a slop clone. They might notice a graph that cites line numbers. Pay smaller myth channels for the same hook, face to camera. Manna's lesson stands. Faces beat cinematic AI.

Do not use God of War footage to sell a Greek path. That is how you import the lore legal problem into the easy company.

---

## Money

Mythology buyers look like Paladin buyers. Curious adults. Teachers. Parents. They will tolerate a higher price than lore fans who already have a free wiki.

I would still not copy Paladin's $99 ladder.

- Yearly. $39.99.
- Monthly. $6.99.
- Free. One Greek cycle and the daily god.

Lean year cash is lower than lore. No $15k franchise memo. You still want a classicist on contract for the first 80 chapters. Call it $20k to $40k, not a full-time lore lawyer.

| Case | Paying users at month 12 | Yearly equivalent |
| --- | --- | --- |
| Fail | Hook looks like homework. | Near zero. |
| Lean win | 1,000 to 3,000 at $40/year | $40k to $120k |
| Paladin-shaped | 5,000 to 10,000 | $200k to $400k |

The Paladin-shaped case is more plausible here than in lore. The corpus is free. The buyer is broader. The hook is the one they already proved on history. You still need a company that can run ads, or a year of shorts that behave.

Do not spend the year 1 surplus on a second codebase. Spend it on Egyptian and on the voice.

---

## Build sequence

Same phases as the lore file. Faster, because the lawyer is bored.

**Phase 0.** Twelve Greek chapters. Thirty videos. Waitlist.

**Phase 1.** Web habit. Audio. Review. Genealogy graph that is not ugly.

**Phase 2.** iOS. You can ship a store listing here with a straight face. The corpus is yours to teach.

**Phase 3.** Norse. One epic. Battles. Changelog that admits when a chapter used a late variant.

**Month 12.** Egyptian or Mesopotamian. First comparative week. Decision point. Spin the same engine at game lore, or keep filling traditions.

I would spin the engine. That is the Deepstash move. Hearth stays the cash habit. The lore app inherits the reader, the quiz compiler, the streak, the short-form desk.

---

## What would kill this

Sounding like a textbook. Mitigation. Family gossip, then the cite.

Getting a living tradition wrong on purpose for a joke. Mitigation. The `do-not-ship` flag is not decoration.

Being a worse Pantheon. Mitigation. Audio, variants, and a graph. If you only ship quizzes, stop.

Letting Paladin's Homer paths own the "epic on your phone" sentence while you dither. They already shipped. Move.

---

## Tomorrow morning

1. Open Hesiod. Write one claim. Write the locator. That is the company.
2. Record ten "most people can't name Zeus's siblings" videos. No god-of-war armor. No Marvel hammers.
3. Do not open Xcode.
4. If those ten videos move, write the Norse cousin the same week. The brand is mythologies. The first week is one family.

If they do not move, you learned the category sentence is weaker than Paladin's for $0 of App Store tax. The graph still becomes a newsletter. It should not become a quiet $6.99 charge.

---

## How this sits next to game lore

Hearth is the easier company. Reliquary is the sharper one. They share a reader, a claim graph, a quiz compiler, and a commute loop.

Hearth teaches you to hold variants. Reliquary teaches you to hold contradictions in a world someone else wrote. A person who finishes the Greek family can walk into a "how Hades the game talks to the Hymn to Demeter" path without you stealing a model sheet.

If you can only fund one, fund this. If you can fund the engine once, start here and keep the lore file as the second store listing. The unlimited-content dream is honest in mythology on day one. In game lore it becomes honest when the Worlds shelf can take a new title in a week, under a legal flag, without rewriting the app.
