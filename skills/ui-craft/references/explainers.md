# Explanatory decks, tutorials, feature demos

How he structures a technical video or talk, and how the same ideas carry into onboarding,
feature tours and demo screens. Evidence paths are relative to `SRC` in ChromaDecks at commit
`b3073d1`; see [sources.md](sources.md). Narration isn't in the repo, so the reason behind a
beat is an inference unless marked otherwise.

## The architecture that makes it work

```kotlin
// One slide = an initial state + an ordered list of one-line deltas (data/ListSlide.kt)
data class SetUpState(val tab: Int, val zoom: Float, val pivot: Offset, val thumbStage: Int)

class SetUpSlide : ListSlideAdvanced<SetUpState>() {
    override val initialState get() = SetUpState(tab = GRADLE, zoom = 1f, pivot = CENTER, thumbStage = 0)
    override val stateMutations get() = listOf<SetUpState.() -> SetUpState>(
        { copy(tab = DIAL) },
        { copy(tab = THUMB, zoom = 2.8f, pivot = THUMB_PIVOT) },  // code tab and camera move together
        { copy(thumbStage = 1) },
        { copy(zoom = 1f, pivot = CENTER) },
    )
    @Composable override fun content(state: SetUpState) { /* code from state | live visual from state */ }
}
```

- **States are precomputed** by folding the deltas once, so going back is free and each beat
  is a one-line insert or reorder. This replaced an earlier API where every state was restated
  in full.
- **The code string is generated from the same state that drives the render**
  (`buildString`, `thumbCode(stage)`, `timelyDialCode(sweepTurns)`), so the two panes can't
  contradict each other.
- **The right arrow** advances the slide's state; when the list runs out, the slide index
  advances. The presenter derives every transition from one scroll spring
  ([motion.md](motion.md#macro-motion)).
- **A background slot** behind transparent slides receives the index, so the world is
  continuous across slides with no per-slide background seams.
- **Development habit:** the slide in progress is moved to index 0 while he works on it. The
  framework has no jump-to-slide, so a duplicated first slide in an old deck is this, not a
  hook.

The same shape fits an onboarding flow or a feature tour: one state per step, every visual and
every line of copy derived from it, one value driving the transition.

## Deck template

Recurring across the four YouTube decks. The early decks open on the title; the later ones
push the title to slide 3–4, after the hook.

1. **Cold open:** the signature effect in motion with a story beat; the year morphing 2026 →
   2013 into the app being recreated, using that app's own digit morph. No title.
2. **Payoff preview or gallery:** the finished thing, or 6–12 working variations, one per step
   (12 different dials before the title).
3. **Anatomy (optional):** an exploded or layered view of the target.
4. **Title card:** episode number, lowercase title, one-line description, one API hint.
5. **Agenda or chapter map** for multi-part content.
6. **Intuition demo:** visual and interactive, no syntax yet. The mesh definition slide has no
   code at all.
7. **API reveal:** the bare name first, then the full signature.
8. **Build slides,** per chapter: code on the left generated from state, live render on the
   right, one change per step.
9. **Variations / carousel:** the same API, different outputs.
10. **Bridge** into the next chapter: the last step of one chapter teases the next technique.
11. **Final payoff:** the finished piece next to its inspiration (the original app's
    screenshots springing in around the recreated dial).
12. **Outro:** URL, handle, logo.
13. **Production slide:** a thumbnail composition, kept out of the narrative.

## Teaching moves

- **Visual first, code second, and the code is the visual's state.**
- **One beat, one change.** 78% of build steps change exactly one property; the pencil slide
  adds exactly one path call per step (16 steps).
- **Stable scaffold, changing body.** Code is built from wrapper templates so the diff
  highlights only the lines that matter; irrelevant parts are `...`.
- **Ramps of complexity:**
  - primitive → composite (one triangle → a square → a grid → a dense mesh);
  - naive → better → best (pop exact → pop range → smooth);
  - wrong → fixed (path effects chained in the wrong order first);
  - exaggerate → settle (mesh resolution 5 → 16 → 64 → back to 16; a sweep of 99 turns);
  - strip to bounds → rebuild (flash the thumb's bounds, show the empty slot, restore it);
  - take apart → reassemble (unstack the arcs into a row, restyle, restack).
- **Show the target, then rewind:** the finished element opens the talk; the smooth behaviour
  is previewed, then reset to the naive version.
- **Point with the camera:** when the code focus moves to a sub-part, zoom the visual to it on
  the same step, then zoom out.
- **Make the invisible visible:** draw ranges and bounds; print live values (offset, `atan2`
  angle in degrees) as code comments; a shake stands in for a haptic a projector can't play.
- **Teach the technique with the technique:** the mesh-gradient title is revealed by a mesh
  wipe; the "Four Path Effects" heading is struck out and rewritten as "three, +1" using the
  dash effect being taught; the talk's last section explains the deck's own decorations.
- **Teach by contrast in names:** three panels titled `TooSmall.kt`, `TooLarge.kt`,
  `JustRight.kt` let the tab label carry the point.
- **One running example** grows through the whole talk: an email-style list item, about ten
  versions.
- **Personality inside the material:** a joke comment in the shown code, a strike-through gag.

## Video vs live talk

| | Video decks | Conference talk |
| --- | --- | --- |
| Build density | 3.2–4.6 steps per slide | ~0.1 (4 steps in 31 slides) |
| Driver | scripted state changes, tuned to the recorded voice-over | the presenter interacts live with the real component |
| Signposting | one agenda, a few chapter cards | a section card before every topic |
| Code | grows from an empty skeleton | a static excerpt with `...`, up to three tabs |
| Format | 4:3 | 16:9 (it was 4:3 at the first venue) |

A room can't rewind, so the talk trades build steps for live demos and frequent section resets
(inference). Vertical 9:16 has no room for side-by-side, so a tap flips one frame between code
and visual (`_bites/test/bitesTest.kt`).

## His production loop (from an interview)

Experiment in a hot-reload scratch project → write a word-for-word script, then a second pass
for how it sounds aloud, with animation cues → build the slides side by side with hot reload →
record the voice-over and tune animation timing to it → screen-record while advancing slides
live → light cuts. His articles are often what is left over from making a video, and the open
source deck gives advanced viewers a second layer to study.

## Feature demos inside an app

The deck moves transfer directly to onboarding, empty states and feature tours:

- Show the finished outcome before asking for anything.
- One step, one change; derive copy and visuals from the step's state.
- Use the real component, live, rather than a screenshot of it.
- Point by zooming or dimming (opacity 1 / .5 / .25), not with arrows and boxes.
- Make the hidden state visible: the range a gesture covers, the threshold that arms an action.
- Teach a gesture with a gesture: a one-time "peek" that slides the item partly open shows the
  swipe without a tooltip (his slide-to-dismiss talk).
