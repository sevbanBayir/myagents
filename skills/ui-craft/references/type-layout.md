# Type, layout, readability, code on screen

Evidence paths are relative to `SRC` in ChromaDecks at commit `b3073d1`; see
[sources.md](sources.md). Fonts live in `composeApp/src/commonMain/composeResources/font`.
Sizes and fits are read from code; nothing was measured on a rendered screen.

## Typefaces have jobs

| Face | Job | Evidence |
| --- | --- | --- |
| JetBrains Mono (regular, bold, bold italic) | The main voice: code, labels, metadata, and big lowercase titles (mono bold 96–100sp). 77% of explicit text-style uses. | `ui/theme/ChromaTheme.kt:43-64`, `ui/components/AccordionText.kt:30-35` |
| League Spartan (geometric sans) | UI text inside the demo components | `ChromaTheme.kt:30-41` |
| Prata (high-contrast serif) | Only the person: the presenter's name | `ui/frames/TitleFrame.kt:184-191` |
| Roboto Flex (variable) | Only section cards: width 25 (very condensed), auto-sized up to 280sp, tracking −10sp | `_talks/ui_delight/components/TitleCardFrame.kt:257-305` |

Mono means technical, serif means human, condensed sans means section. JetBrains Mono replaced
Space Mono in commit `01b0cc3`, which also raised the small label size from 14 to 18sp.

## Scale

| sp | Ratio | Role |
| --- | --- | --- |
| 18 | — | code in half-width panes (video) |
| 20 | 1.11 | labels, metadata, code in older decks |
| 28 | 1.40 | code on a projector, emphasis |
| 32 | 1.14 | body, agenda labels |
| 56 | 1.75 | display small: name, timer readout |
| 72 | 1.29 | display medium |
| 96–100 | 1.33 | titles |
| 280 | 2.9 | section card |

Two clusters: text and code at 18–32 (steps ≈ 1.1–1.4), display at 56/72/96 (≈ ×1.3), with a
deliberate ≈ 1.75× jump between them. Two weights in practice: 400 and 700 (one ExtraLight for
a unit label next to a big number).

- **Tracking:** negative only at display sizes (−1% at 96sp, −3.6% at 280sp). Body, labels and
  code are never letter-spaced.
- **Line height:** display 1.0; code lines get 2dp vertical padding each instead of a line
  height.
- **Casing:** no uppercase anywhere. Episode titles are lowercase ("mesh gradients", "timely
  timer"); section cards use Title Case.
- **Alignment:** start-aligned by default; centred only for numbers inside dials and the
  giant section card.

## Canvas and layout

- **Letterbox, no global scale.** Slides sit in a fixed-aspect surface on Black: 4:3 for the
  video decks, 16:9 for the conference talk (`ui/theme/ChromaContainer.kt:19-32`). Density is
  left at 1, so dp values are absolute on the presenting screen.
- **Scale demos with density, not with their code.** A phone-sized component is shown at 1.5×
  density so it reads on stage, while the code on screen keeps real dp values
  (`_talks/ui_delight/components/ListItemDisplay.kt:49-51`); small dial showcases are drawn
  small and scaled 2.8×.
- **Spacing is 4-based:** 4/8/12/16/24/32/64/128. The canonical content slide is
  `fillMaxSize().padding(64.dp)` with `Arrangement.spacedBy(64.dp)`, vertically centred (21
  uses of `padding(64.dp)`). On app screens his base is Material spacing; 64 is a stage value.

| Pattern | Proportions | Evidence |
| --- | --- | --- |
| Code \| live visual (most common) | `Row`, centred vertically, weight 1:1; 1.4–1.8:1 when lines exceed ~50 columns | `_004_TimelyTimer/slides/SetUpSlide.kt:123-161` |
| Visual over code | visual weight 1 with 72dp vertical padding; code panel 50% wide, centred | `_004_TimelyTimer/slides/MultiArcSlide.kt:96-160` |
| Code alone | a narrow centred column (`widthIn(max = 800.dp)`) in a lot of empty space | `_003_ChromaDial/slides/AddDependencySlide.kt:28-50` |
| Hero object | one object at 40% of the frame, centred | `_004_TimelyTimer/slides/ExplodedDialSlide.kt:89-102` |
| Triptych | 3 equal columns, 128dp gutters, revealed one per step | `_talks/ui_delight/slides/LayoutFundamentalsSlide.kt:54-177` |
| Equation | [code + visual] + [code + visual] = [result], operators in the accent color | `_002_PathAnimations/slides/StampPathEffect.kt:287-337` |

**A content slide holds:** one code panel (≤ ~23 lines, ≤ ~58 columns), one visual, zero
sentences, 4–10 build steps.

**Editorial title frame** (`ui/frames/TitleFrame.kt`): a book cover with metadata in the four
corners at 36dp padding. Center: lowercase mono bold 96sp title with a stepped extrusion. Under
it: a 2dp rule as wide as the title, then "by" + the serif name. Corners: version tag, a hint
(an API name such as `drawVertices()`, rotated −90°), a zero-padded episode number ("004")
and a short description in a 300dp column.

## Code on screen

**Panel** (`ui/components/CodeIDE.kt`): pill tabs with file names (selected Slate50; others at
10% alpha); a 24dp outer radius, 2dp inset, 22dp inner well; no line numbers, gutter, window
buttons or scrollbars. The file name is the slide's title.

**Diff animation** (`ui/components/CodeBlock.kt`): consecutive code states are diffed by line,
so unchanged lines keep their identity. New lines fade in 50ms apart and flash a Slate50
background (snap to α .2, spring to .1, then to 0 on `VeryLow`); a line that is only `)` is
skipped. Moved lines spring into place, removed lines fade out fast. Clicking a line flashes
it again, so the presenter can point.

**Highlighting** (`ui/util/CodeHighlight.kt`): six regexes in priority order (comment > string
> number > named parameter > function > keyword); plain identifiers stay white. Colors come
from the deck palette ([color-depth.md](color-depth.md#code-colors)).

**Writing the code shown:**
- Median 40 columns and 7.5 lines; the latest deck stays ≤ 58 columns and ≤ 23 lines.
- 2-space indentation; each chained call and each `if/else` branch on its own line; named
  arguments. A mono glyph is ≈ 0.6em wide, so at 18sp ≈ 50 characters fit a half-width pane.
- Start from an empty skeleton (signature + `{ }`) and add lines step by step. Elide what isn't
  under discussion with `...`.
- One file at a time: the readability pass in commit `764757e` collapsed two tabs into one.
- **The code is true.** Every number in the code is the value driving the visual; that same
  commit changed `24.dp` to `30.dp` in both the string and the canvas. Live values (drag
  offsets, angles in degrees, the current color name) are written into the code or its comments
  as they change.
- Human-scale units: paths on a 0–100 grid.

## Readability techniques

- **Progressive disclosure:** each build step changes 1–3 fields; code and visual move in the
  same step.
- **Zoom instead of callouts:** 2.2–2.8× about a pivot, with a vignette, back to 1× before
  moving on ([motion.md](motion.md#macro-motion)).
- **De-emphasis:** opacity ladder 1 / .5 / .25 for siblings; blur 50dp + α .7 for the
  background layer; unselected tabs at 10%; comments at ~4:1.
- **Every fact in its own place:** the title frame carries six pieces of metadata (version,
  API hint, episode number, description, title, byline) and gives each a corner or a line of
  its own, with its own face and size; nothing is chained with separators.
- **Hierarchy at one size by tone:** title/subtitle/time as Zinc200/Zinc400/Zinc500
  (`_talks/ui_delight/components/ListItem.kt:126-135`). Size is reserved for the jump from
  ~32 to 56+.
- **Annotations made of the thing itself:** a pill label with live coordinates on a stalk above
  each drag point; a viewfinder bracket around a slot once its content is removed; a
  hand-drawn circle where the presenter clicks (`ui/components/Circler.kt`).
- **Left out:** bullets, paragraphs (the talk's title-card descriptions exist but their render
  is commented out), slide titles and numbers on content slides, line numbers, arrows and
  callout boxes.

## Interactive demos

The slide is a running program: the real library component, real timers, real drag.

| Device | What it makes tangible | Styling |
| --- | --- | --- |
| Slider (`ui/components/ChromaSlider.kt`) | scrubbing one numeric parameter | 84dp white thumb with the value inside in mono 28; pill track with 1dp white α .5 → .1 border and 5% fill |
| Drag handles | Bézier controls, angles | coordinate pill at 70% background, mono bold 18 |
| Pencil on paper (`_002_PathAnimations/slides/PencilPaper.kt`) | one path command per step, drawn by an animated pencil | light "paper" tilted 60° on X: the one deliberate light-mode surface |
| Exploded view (`ui/components/ExplodedView.kt`) | a component's layer anatomy | 60° X tilt, 128dp between layers, borders and inner glows that fade in with the spread |
| Phone frame (`ui/displays/Compact.kt`) | real-device context | 0.5 aspect, concentric 32/12/20dp radii, side buttons, glass sheen |
