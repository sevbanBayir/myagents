# Motion, micro to macro

Evidence paths are relative to `SRC` in ChromaDecks at commit `b3073d1`; see
[sources.md](sources.md) for the permalink base. Settle times are computed from Compose's
spring constants (unit mass, within 1% of the distance), not measured on screen.

## The spring vocabulary

He uses 115 springs and 126 tweens, but the tweens are almost all loops and clocks. Every
position, scale, zoom and rotation change in the latest deck is a spring.

| Spec | ≈ settle | Overshoot | Where he uses it |
| --- | --- | --- | --- |
| `StiffnessMedium` (the bare `spring()`) | 0.17 s | 0 | hover/press focus value, pencil rotation |
| `StiffnessMediumLow`, no bounce | 0.33 s | 0 | snap to the nearest detent after a drag |
| `StiffnessLow`, no bounce | 0.47 s | 0 | **component default**: reveals, selection residue |
| `StiffnessLow` + `MediumBouncy` | 0.65 s | 16% | small things arriving (a check icon, a dial point) |
| `StiffnessVeryLow`, no bounce | 0.95 s | 0 | **screen default**: camera zoom, slide scroll, code flash |
| `StiffnessVeryLow` + `LowBouncy` | 0.9 s | 3% | slide-to-slide scroll in the latest deck |
| `StiffnessVeryLow` + `MediumBouncy` | 1.3 s | 16% | a dragged object with mass (a cube that lags the finger) |
| `StiffnessHigh` + `MediumBouncy` | 0.09 s | 16% | physical button push, mechanical ticking |
| `HighBouncy` + `MediumLow` | — | 53% | rubber-band snap-back on release |
| stiffness `4f` + `MediumBouncy` | 4.6 s | 16% | background drift: a heavy, distant layer |
| stiffness 100k–600k | instant | — | shake oscillation |

**Distribution:** 70% of springs are `VeryLow` or `Low`; 71% are critically damped, and 78 of
those 82 simply leave the damping argument out. Bounce is opt-in, and when he opts in it is
usually `MediumBouncy`.

**Tweens are for four cases:** a stagger that needs `delayMillis`; a color fade
(`tween(800)`); a loop or clock (`LinearEasing`); a shape interpolation where t > 1 would break
the shape (the digit morph, 700 ms `FastOutSlowIn`). He uses no `keyframes`,
`updateTransition` or `Crossfade` at all.

**Visibility threshold in the property's unit:** `1f` when the spring animates a dp distance
("settles at a whole dp"), `.0001f` for a normalized 0..1 value on a slow spring, so the tail
doesn't snap (`_004_TimelyTimer/slides/TimelyGallerySlide.kt:84-91`, `ui/components/FocusZoomer.kt:51-55`).

## One driver

His core idiom (133 `lerp` calls): animate one value, derive everything from it.

```kotlin
// Hover and press as one continuous motion (pattern from _talks/ui_delight/components/ListItem.kt:683-714)
val focus by animateFloatAsState(
    when { pressed -> 1f; hovered -> .5f; else -> 0f }   // default spring: fast feedback
)
val selected by animateFloatAsState(if (isSelected) 1f else 0f, spring(stiffness = Spring.StiffnessLow))
val shape = RoundedCornerShape(24.dp)
Modifier
    .background(Zinc900, shape)
    .background(Blue950.copy(alpha = lerp(0f, .4f, selected)), shape)
    .innerShadow(shape) {            // androidx.compose.ui.draw.innerShadow
        color = Blue500
        radius = lerp(0f, 40f, focus)
        alpha = focus
    }
```

Other instances:
- **Gallery shots:** one spring animates the distance travelled; alpha, rotation (to the shot's
  tilt) and scale (1.15 → 1) are computed from it. Shots arrive large and tilt into place
  (`TimelyGallerySlide.kt:86-114`).
- **Exploded view:** decoration alpha is `spacing / 48dp`, so the frames finish appearing in
  the first ~37% of the spread (`_004_TimelyTimer/components/ExplodedTimelyDial.kt:105-130`).
- **Shake:** one value bounces ±1, and a config maps it onto rotate, rotateX/Y, scale and
  translate (`ui/modifiers/Shake.kt:20-77`).
- **Title reveals:** one linear 0..1 progress, split into overlapping windows per element
  (version 0–.5, hint 0–.7, number .2–.5, description .45–.9, rule .6–1), each eased on its
  own (`ui/frames/TitleFrame.kt:44-48`, helper in `ui/util/Easing.kt:10-11`).

```kotlin
fun ClosedFloatingPointRange<Float>.progress(t: Float) =
    ((t - start) / (endInclusive - start)).coerceIn(0f, 1f)
val rule = LinearOutSlowInEasing.transform((.6f..1f).progress(master))
```

## Micro motion

**Press.** Several properties on the same fast bouncy spring read as one physical push: down
5dp, rotate 5°, shadow to .8 on `StiffnessHigh` + `MediumBouncy`
(`_003_ChromaDial/components/RadioShowcaseComponent.kt:216-236`). A grabbed thumb squishes to
0.8 on `Medium` + `MediumBouncy` (`_003_ChromaDial/slides/ThumbCustomizationSlide.kt:120-126`).

**Drag.**
- Follow the finger with `snap()` while dragging; spring only on release.
- **Rubber band** where the item can't really move: offset × 0.25 during the drag, `HighBouncy`
  + `MediumLow` on release (`ListItem.kt:838-851`). The resistance teaches "not deletable"
  better than a dead, unswipeable item.
- **Mass:** render a drag-derived rotation through a `VeryLow` + `MediumBouncy` spring and the
  object lags like something heavy (`_talks/ui_delight/slides/CubeCodeSlide.kt:83-96`).
- **Detent:** on release, settle to the nearest whole unit on `NoBouncy` + `MediumLow`; a new
  grab cancels the settle; the readout already shows whole units while dragging
  (`_004_TimelyTimer/components/TimelyDial.kt:98-161`).
- **Hard stop:** spring toward a target past the limit and clamp, so it arrives fast and stops
  dead, like an impact (`_003_ChromaDial/components/RotaryDialComponent.kt:65-75`).
- **Overshoot past a range** (his ChromaDial library): decay the overshoot (`.8f`) and spring
  back on `Low` + `MediumBouncy`; draw the stretch so it's visible.

**Proximity falloff.** Strength scales with closeness instead of flipping at a threshold. Tick
marks within 18° of the thumb grow from 10 to 40dp, `x = 1 - (|delta| / 18).coerceIn(0, 1)`
(`TimelyDial.kt:250-261`). The NumberDucking slide teaches this in four modes (none, pop exact,
pop range, smooth): a binary trigger pops, a continuous falloff feels physical
(`_004_TimelyTimer/components/DuckingNumberDial.kt:43-55, 161-179`).

**Numbers and text.**
- **Digit morph:** every glyph has the same Bézier point count, so any digit tweens into any
  other; the digit's width animates with it so neighbours reflow
  (`_004_TimelyTimer/components/NumberView.kt:157-251`; glyph data ported from
  christiandeange/NumberView).
- **Odometer tick:** the new number slides in by only 5% of its height, in the direction of
  change; the old one disappears instantly
  (`_003_ChromaDial/components/MonthDurationPickerComponent.kt:307-321`). From his blog:
  digits move in the direction of the whole number's change, not each digit's.
- **Scramble/decode:** characters resolve left to right as progress passes each slot; the
  description cycles 6 scramble states per character (`TitleFrame.kt:54-91`).
- **Stepped motion as style:** `StepsEasing(6)` quantizes an extrusion reveal so it reads like
  stop motion (`ui/components/AccordionText.kt:41-49`).

**Staggers.**

| Where | Delay per item | Item duration |
| --- | --- | --- |
| New code lines | 50 ms | default fade |
| 8 grip dots (`_004_TimelyTimer/slides/SetUpSlide.kt:255-257`) | 40 ms | 250 ms |
| 4 dial numbers (`DuckingNumberDial.kt:85-92`) | 90 ms | 350 ms |
| 6 gallery shots | no delay; `StiffnessLow - index * 20` | spring |

The delay is 15–40% of the item's duration, so items overlap and the group reads as one wave.
The newest code staggers by stiffness instead of delay: no timers, so the group stays
interruptible.

**Bounce in, plain out.** The track enters on `MediumBouncy` and leaves on a plain `Low`;
`scaleIn` is bouncy and `scaleOut` default; `expandHorizontally` is `LowBouncy` and
`shrinkHorizontally` default (`_003_ChromaDial/slides/ChromaDialTeaserSlide.kt:95-167`,
`ListItem.kt:744-758`). Scale alone looks like popping in, so arrivals pair scale with fade.

**Two springs on one element.** Size on `Medium` + `MediumBouncy`, position on `Low` +
`MediumBouncy`: the size lands first and the position settles after it
(`ChromaDialTeaserSlide.kt:140-154`).

**Focus pull.** Incoming content: blur 100 → 0, fade, scale .75 → 1. Outgoing content in a
swap: slide +50%, scale .9, blur up, fade (`_002_PathAnimations/slides/OtherPathFunctions.kt:352-392`).

**Shake and wiggle.**
- Shake: N iterations on a very stiff spring, then home on the default spring. At a swipe
  threshold he fires 10 iterations when crossing in and 5 when crossing out, together with a
  haptic (`ListItem.kt:567-595`).
- Wiggle: wind up to −10° on `Low`, three ±10° swings on `Medium`, settle on `Low` +
  `MediumBouncy`, rest 400 ms, pivoting at the pill's rounded end
  (`_talks/ui_delight/slides/PillAnimationSlide.kt:79-122`).
- Wave: launch each swing 100 ms apart so every spring is interrupted by the next, then a
  final settle on `VeryLow` + `HighBouncy` (`_bites/teaser/Teaser.kt:262-291`).

**Ambient life.** Retarget a very soft spring to a random point every 200–1000 ms; it never
arrives and its velocity carries over, so the drift is organic with no jumps
(`_001_MeshGradients/slides/InterpolationSlide.kt:85-111`, stiffness 5). Continuous rotation
is `LinearEasing` + `Restart`; hovering and breathing use default easing + `Reverse`.

## Macro motion

**One spring drives every slide transition.** The presenter is a `LazyColumn` with scrolling
disabled; an index change calls `animateScrollBy` on one spring (`VeryLow` + `LowBouncy`).
Each slide reads its own progress (1 below the screen, 0 in place, −1 above) and every
transition modifier is a pure function of it inside `graphicsLayer`
(`ui/components/SlidesPresenter.kt`, `ui/slideanimations/BasicAnimations.kt`). Transitions
can't drift apart, and reverse or interrupt for free. The same structure works for any pager
or step flow: drive it with one value, derive the rest.

**Transition recipes.**
- Content push (latest deck): enter from +100% width with fade, exit to −70% with fade.
  `parallax(1f)` cancels the vertical scroll entirely, leaving it as a clock.
- Depth (ChromaDial deck, conference talk): parallax .8, blur 100 → 0, scale .75 → 1, fade in;
  the exit only fades.
- Chapter cards override the deck style with a blur-out of 200. Content moves sideways, title
  cards use depth, so the kind of transition tells the audience where they are (inference).

**Tempo tiers.** Background drift on stiffness 4 (≈4.6 s), content and camera on
`VeryLow`/`Low` (≈0.5–1 s), touch feedback on `Medium`/`High` (≈0.1–0.2 s). A shared
background rotates 15° per slide and each shape multiplies that by its own parallax factor
(0.5–1.7) (`_004_TimelyTimer/components/RadialDriftBackground.kt:129-136`). Three tempos plus
per-layer parallax read as depth.

**Color across screens.** The palette's hue moves 3 ring steps per slide and every color
(background stops and syntax colors) fades over `tween(800)`
(`_004_TimelyTimer/TimelyTimerPresentation.kt:62-75`). Color works as a progress bar.

**Camera.** `FocusZoomer` zooms 2.2–2.8× about a normalized pivot that stays centred, on
`NoBouncy` + `VeryLow` with threshold `.0001f`, under a radial vignette that hides what spills
past the edges. Zoom-in is its own step, and zoom returns to 1× before the topic changes
(`ui/components/FocusZoomer.kt`).

**Choreography.** Across 118 build steps, 78% change exactly one property; two-property steps
pair a visual change with the code that explains it, or zoom with pivot (one camera move).

## Restraint

What he leaves still is as deliberate as what moves:
- Hard cuts between 12 dial showcases; structural stages snap and only the detail animates.
- Numbers fade in place; his own comment says "no scale, no translate"
  (`DuckingNumberDial.kt:184-188`).
- A 400 ms slide + fade replaced by a plain fade (`_004_TimelyTimer/slides/MultiArcSlide.kt:106-115`).
- Bounce on sizes commented out in three places; size animation on a readout commented out.
- Tab-chip colors switch instantly; the play/pause icon swaps without a morph.
- From his posts: horizontal motion layered on vertical motion is overwhelming, so he aligns
  content to keep it from moving; a slider idea was scrapped over usability; film grain was cut
  from a video as feature creep.
