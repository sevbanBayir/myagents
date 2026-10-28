# Recipes

Moves that make a deck teach, mapped to kit pieces. The teaching moves themselves are in
`ui-craft/references/explainers.md`; names below are kit API, looked up in `KIT.md`.

## Structure

- **Hook before title.** A cold open (the payoff in motion, or one surprising number as a
  `statement`) can precede `title(...)`. Talks for a mixed room open on the title.
- **Signposts.** `agenda(...)` once, then `section(...)` before each part. In an agenda revisited
  mid-talk, `current = n` (from 0) steps the other parts down to the faint tone.
- **One running example** grows through the talk: keep its data in one place in the talk's
  folder and render every version from it.
- **Close with one line.** `closing(...)` carries the takeaway, handles, an optional QR.

## Build steps

- **One beat, one change.** A step changes one property; everything else holds still.
- **Code is the visual's state.** `codeAndDemo` derives both panes from the same state; grow
  code with `codeSteps` / `add(fromStep, line)` so the diff flashes only the new line.
- **Arrivals.** The first step of a slide is static (strips show what the room sees); later
  items arrive with `Modifier.arrive(shown = …, index = …)`. `bullets(oneByOne = true)` and
  `facts(oneByOne = true)` do this for you.
- **Point with the camera.** When attention moves to a sub-part, `FocusZoom` onto it on the
  same step as the code focus, then zoom out.
- **Make the invisible visible.** `Modifier.brackets` around bounds, `Modifier.circled` around
  a phrase, grids under a curve, live values printed beside the thing they describe.
- **Contrast by name.** Three code tabs named for the outcome (`TooSmall.kt`, `JustRight.kt`)
  let the tab carry the point.

## Atmosphere

- One look per talk; vary rhythm with section styles and per-slide transitions, not palettes.
- A Heavy background (RadialDrift) carries the whole talk alone; overlays (Glow, GraphPaper,
  Stars, Grain) go over `Canvas` with `layered(...)`.
- Over a drift, muted text needs a lighter tone than on a flat canvas; Drift's palette shows
  how.
- A transition belongs to the jump into a slide: set it on the slide that arrives, matched to
  the jump (Push for siblings in a sequence, BlurZoom or Camera into a new part, TitleThrough
  for a title, Fade for a quiet beat), and read its strip.

## Live parts

- A slide that calls a backend starts its work only while current (`isCurrentSlide()`), shows
  a loading state, and fails visibly. Give it a `settle` long enough for the render.
- Declare the backend on the `Talk` so the launcher health-checks it before the window opens.
