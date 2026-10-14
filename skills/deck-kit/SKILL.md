---
name: deck-kit
description: Presentations built from the my-decks deck kit (Compose Desktop slides) - make a talk, deck or "sunum" about a topic, add or restyle slides, pick a look, opener, transition or background, render a deck to PNG and critique it. Use for any slide work in ~/StudioProjects/my-decks.
---

# deck-kit

A talk is data: a `Talk` (id, title, look, optional backend, slide list) in its own folder under `_talks/`,
registered in `decks/Registry.kt`, built from kit slide types and effects. The kit's
**single source of truth** is `KIT.md` at the repo root: commands, the slide-type and look
tables, the generated catalog of every effect, and the pitfalls. Read it before writing a
slide; this skill is the workflow around it.

- Repo: `~/StudioProjects/my-decks`, branch `main`, the private GitHub repo
  `sevbanBayir/my-decks`. JDK 21 (see `deck.sh`).
- It is built on sinasamaki's ChromaDecks, which carries no license: the repo stays private.
  His repo is the `upstream` remote, its push URL disabled on purpose.
- Taste comes from the `ui-craft` skill; deck structure and teaching moves from its
  `references/explainers.md`. Load both.

## Steps

1. **Brief.** Write down topic, audience, language, length, presenter, date, and which parts
   run live (a backend, a demo). One slide per minute is the default density. A talk given to
   a room past about a dozen slides takes a section card before every part and few build
   steps; a shorter one signposts with a `statement` instead. Ask the human only for what
   changes the deck (audience, language, length); state your defaults for the rest.
   Done when the brief is a short list at the top of the talk file.
2. **Look.** Read the sampler sheet `looks.png` in your render directory, rendering it with
   `./deck.sh looks <render dir>` when it is missing or older than the last commit touching
   `kit/look`, and pick the look whose tone fits the audience; the `-tr` rows show each look
   after `forTurkish()`. Turkish text needs `Look.forTurkish()` on any look whose
   display face lacks Turkish letters (KIT.md lists the faces). Done when the talk names its
   look with a one-line reason.
3. **Outline.** One idea per slide, as one sentence each. Map every slide to a kit slide type
   from KIT.md; mark the few that need a custom `slide{}` body. Pick the opener, section style
   and any per-slide transitions from the catalog. Reach for the recipes in
   [references/recipes.md](references/recipes.md). Done when every slide has a type and a
   one-sentence idea, and the human has seen the outline when the talk is theirs to give.
4. **Build.** Copy `_talks/starter/` to `_talks/<id with _ for ->/`, rename its package, id and val, add it
   to the "talks" group in `decks/Registry.kt`, fill the slides. Done when `./deck.sh list`
   (it compiles on JDK 21; a bare `./gradlew` may pick a JDK Gradle can't run on) shows the talk.
5. **Render.** `./deck.sh <id> render DIR --transitions` (add `--no-backend-check` when a
   backend is off). Open the contact sheet, the transition sheet and every step PNG of the
   render with the Read tool, and single strips where the sheet looks off. Done when you have
   looked at all of them.
6. **Critique.** Walk [references/critique.md](references/critique.md) slide by slide, writing
   pass or fail with what you saw. Fix, re-render with `--only`, repeat, and finish with one
   full render so the sheets hold the whole talk. Done when every item passes or carries a
   written reason.
7. **Hand over.** Tell the human how to run it (`./deck.sh <id>`), the keys, and what only a
   rehearsal can judge: transition feel, live slides, timing. Commit only when asked; tag a
   delivered talk `talk/<id>-<yyyy-mm>`.

## Gotchas

- Slide state lives in the slide instance and is folded in the superclass constructor. Write
  data-driven slides as factories returning `object : ListSlideAdvanced<S>()`; a class with
  constructor parameters read in `initialState`/`stateMutations` crashes.
- `./deck.sh check` must stay clean: the author's decks are live examples, never edited, and
  KIT.md's catalog table is current (`./deck.sh catalog --write KIT.md`). New effects go into
  `kit/` with a catalog entry, talk-only parts into the talk's folder.
- Every `./deck.sh` call rebuilds the desktop jar: one render at a time per checkout.
- A talk that resets a backend's presets needs its own backend port, never the developer's.
