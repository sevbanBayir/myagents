# Color, light, depth, texture

Evidence paths are relative to `SRC` in ChromaDecks at commit `b3073d1`; see
[sources.md](sources.md). Lightness (OKLCH L) and contrast figures were computed from the hex
values in `ui/theme/Colors.kt`, not from rendered screenshots.

## The palette is a (hue, step) grid

`Colors.kt` is the Tailwind CSS v4 palette ported to Kotlin: 26 families × 11 steps
(50, 100…900, 950), each family an `object X : Swatch()` with fields `v50..v950`.

**Why it works:** in Tailwind v4 a step number sits in a nearly fixed lightness band whatever
the hue (step 300 → L .78–.90, 500 → .58–.80, 900 → .36–.42). Swap the hue, keep the step,
and the light/dark structure of the screen stays the same. Everything below relies on that.

**The ring.** The 17 chromatic hues form a ring (Red, Orange, Amber, Yellow, Lime, Green,
Emerald, Teal, Cyan, Sky, Blue, Indigo, Violet, Purple, Fuchsia, Pink, Rose) with wraparound
arithmetic: `Red + 1 == Orange`, `Red - 1 == Rose`. On v500 one step is ~21° on average, so
+1 is analogous, +2 ≈ 40°, +4 ≈ 80–110°, +8/9 ≈ complementary. The 9 neutrals form their own
ring.

```kotlin
operator fun Swatch.plus(n: Int): Swatch {
    val ring = if (this in chromaticRing) chromaticRing else desaturatedRing
    val i = ring.indexOf(this)
    return ring[((i + n) % ring.size + ring.size) % ring.size]
}
```

**Dark-first, light-ready.** `infix fun Color.or(light: Color)` lets him write
`Zinc950 or Zinc200`, so both themes are considered at the point of use; the stub always
returns the dark value for now.

## Roles bind to steps

| Role | Swatch |
| --- | --- |
| Letterbox / outer void | Black |
| Canvas | Zinc900 (faintly cool, chroma ≤ .015, never dead grey) |
| Wells, code panes | Zinc950, or Zinc950 α .7 over color |
| Raised | Zinc800/700 |
| Body text | Slate50 (16.9:1 on Zinc900) |
| Secondary text | Zinc400, Slate500 |
| Text and strokes on a vivid background | `s.v50` text, `s.v100` strokes |
| Accent fills | v400–v500 |
| Glows | v200 at α ≤ .9, v300 at α .2 |
| Code tokens | v200–v300; comments v500 or α .5 |

**Deriving a theme from one base hue `s`** (latest deck, `_004_TimelyTimer/TimelyTimerPresentation.kt:62-75`):

| Role | Formula |
| --- | --- |
| background center / mid / edge | `s.v400` / `(s+2).v400` / `(s+4).v200` |
| keyword / function / string | `s.v300` / `(s+1).v300` / `(s+2).v300` |
| number / param / comment | `s.v200` / `(s+1).v200` / `s.v500` |

Every color on a screen comes from an arc of at most 4–6 ring steps, so nothing clashes; each
role keeps its step, so contrast between roles stays constant while the hue moves. The outer
stop moves further around the ring *and* to a lighter step, so edges go pastel and read like
lit atmosphere.

**Rotating the hue per screen.** `s = Red - index * 3`. Because 3 and 17 share no factor, the
walk visits all 17 hues before repeating, and neighbouring screens differ clearly without
jumping to a complement. All colors fade over `tween(800)`.

**Shading shifts hue, like a painter.** The shadow side of a fill goes to the neighbouring hue
one step darker: a radial gradient from `s.v500` into `(s+1).v600`
(`_003_ChromaDial/components/MonthDurationPickerComponent.kt:241`). Tube shading lerps the
light end 20% toward Slate50 and the dark end 20% toward Slate950, never to pure white or
black (`_002_PathAnimations/slides/PromoTest.kt:237-244`).

**Gradients on text and strokes keep one step across neighbouring hues** (Sky400 → Teal400 →
Lime400; Yellow400 → Green400), so lightness and legibility stay constant. Ramps that do climb
in value climb steadily with neutral endpoints and peak chroma in the middle: the mesh title
runs Zinc900 → Rose800 → Yellow500 → Slate50, L .21 → .98, chroma .006 → .18 → .003
(`_001_MeshGradients/slides/TitleSlide.kt:78-110`).

## Surface recipes

| Recipe | Values | Evidence |
| --- | --- | --- |
| Card | Zinc900 fill; 1dp border, vertical gradient Zinc100 α .3 → .1; radius 24; selected tint Blue950 α .4 | `_talks/ui_delight/components/ListItem.kt:467-498` |
| Hover/press | Accent inner shadow, radius 0→40 and α 0→1 from the focus value | `ListItem.kt:700-714` |
| Neon tile | 1dp accent border; fill accent α .06–.10; accent drop shadow radius 40 α .15–.2; accent inner shadow radius 40 α .3 (1.0 when armed) | `ListItem.kt:166-190, 812-819` |
| Translucent panel over vivid background | Zinc700 α .3; 1dp border Zinc500 α .3 → .05; radius 24; inner well Zinc950 α .7, radius 22 after a 2dp inset | `ui/components/CodeIDE.kt:68-81, 169-176` |
| Device frame | Neutral900 body, radius 32; hairline Zinc300 α .3 → .2; 12dp bezel → screen radius 20; rim glint = clip + 6dp blur + 1dp border; diagonal sheen Transparent → Zinc200 α .1 → Transparent | `ui/displays/Compact.kt:67-131` |
| Glass pill | Fill White α 0 → .2 (vertical); 1dp border White → White α .1 | `_003_ChromaDial/components/TemperatureDialComponent.kt:232-250` |
| Glass layer | 1dp `v100` α .6; inner shadows White radius 60 α .2 (wide, neutral) + `v200` radius 24 α .4 (tight, tinted) | `_004_TimelyTimer/components/ExplodedTimelyDial.kt:116-130` |

**Light from the top:** borders and highlights run brighter at the top edge, inner shadows are
offset upward (0, −6/−8), and shading darkens toward the bottom. **Depth from many faint
layers:** the typical alphas are .1, .3, .2 and .05 for tints. From his article on the Airbnb
month dial: each layer looks like nothing in isolation.

**Shadows:** neutral drop shadows radius 7–10, α .15–.4; text halos Black α .4, blur 10. Real
shadows are rarely pure black, so tint or blend them.

## Glows: stacked, clipped, cut

- **Stack 2–4 blurred copies.** Temperature dial: a 6dp blur clipped inside the tube for inner
  glow, a 2dp crisp rim, a 40dp bloom under the thumb, a 60dp trailing arc
  (`TemperatureDialComponent.kt:141-212`).
- **Clip, then blur** for light that stays inside a shape. Month dial: groove (clip + blur 8 +
  4dp dark border), glow leak (clip + rotate 5° + blur 40), body (v500 + hue-shifted radial),
  inner light (clip + blur 20 + v300 α .2), specular rim (clip + blur 4 + offset −3,−3 + 2dp
  gradient border), recessed center (inner shadow offset 0,−6) (`MonthDurationPickerComponent.kt:200-299`).
- **Halo in three draws:** fill α .9, an 80px stroke at α .3, a crisp 4px stroke at α .7, all
  with Hardlight (`_002_PathAnimations/slides/PathIntroSlide.kt:338-364`).
- **Bloom:** record content once into a `GraphicsLayer`; draw it normally, again behind itself
  with Screen blend and 20dp blur, and again in front with Screen, 40dp blur, α .2
  (`_bites/teaser/Teaser.kt:159-201`). Crisp core, tight glow, wide haze.

## Blend-mode cookbook

| Mode | Use | Evidence |
| --- | --- | --- |
| `SrcIn` in an offscreen layer | Gradient-filled text; metal sheen with a mirrored gradient that slides | `Teaser.kt:498-523`, helper `ui/modifiers/DrawScope.kt:10-19` |
| `SrcIn` per copy | Extruded text: 21 stacked copies tinted Lime400 → Green500, darker with depth | `ui/components/AccordionText.kt:57-68` |
| `DstOut` | Knock a glyph out of its own glow; cut gap rings so stacked arcs separate without borders | `_004_TimelyTimer/components/TimelyDial.kt:316-401` |
| `DstIn` | Vignette mask; masked title reveal | `ui/components/FocusZoomer.kt:79-93` |
| `Difference` | Name text stays legible over a photo | `_talks/ui_delight/slides/AboutMeSlide.kt:97` |
| `Screen` / `Overlay` | Bloom; grain | `Teaser.kt:170`, `ui/modifiers/Grain.kt:29` |

## Texture

**Grain** (`ui/modifiers/Grain.kt`): a 512px greyscale noise tile, tiled with a random 90°
rotation and flip per tile to hide the repeat, drawn with Overlay. Effective strength ≈ .35 on
backgrounds and .10–.15 on content. The random orientation is re-rolled on every redraw, so
animated content gets living, film-like grain (inference from the code).

**Atmosphere** (`_004_TimelyTimer/components/RadialDriftBackground.kt`): a radial gradient from
bottom-center (radius 1.15 × the larger side, saturated at the bottom, pastel at the top
corners), then 44 seeded white bokeh shapes at α .14–.28 under a 10dp blur, then 200 small
particles under a 1dp blur. Heavy blur stays on the decorative layer only.

**Blur as depth of field:** blur the de-emphasized layer 0 → 50dp with α → .7 while an overlay
is up; cross-blur up to 100dp on content swaps.

**No runtime shaders in the decks.** Every effect comes from blur, blend modes, gradients,
`drawVertices`, path effects and the shadow APIs. On his blog, AGSL appears only for metaballs
(blur, then an alpha-threshold shader). Reach for a shader when the effect needs per-pixel
math.

**Mesh gradients** (`_001_MeshGradients/MeshGradient.kt`): a grid of (offset, color) points
drawn with `drawVertices(Triangles)`; edges are subdivided with cubic Béziers (handles at 50%)
and colors lerped, turning coarse Gouraud shading into a smooth surface. Resolution trades
smoothness for cost.

## Code colors

Six roles; plain identifiers stay at the base text color, so color marks only structure.
Tokens are separated by **step** within 1–3 neighbouring hues, not by a rainbow: a monochrome
Lime theme, Lime with one Purple accent, or the per-slide analogous set above. Comments recede
to about 4:1. Measured: tokens 10–13.5:1 on the effective panel color, plain text 18:1.

## Readability through color

1. Near-white (Slate50), never pure white, carries text.
2. Dense text goes on a dark translucent panel over vivid backgrounds, bringing tokens back to
   ≥ 7:1.
3. Saturation lives on accents and atmosphere; neutrals (chroma < .015) carry surfaces.
4. Over photos, `Difference` blend or a vignette.
5. **Known weakness:** tinted `v50` text directly on the `v400` gradient measures 1.7–2.8:1,
   which fails WCAG for small text. He compensates with size (56sp), thick strokes and dark
   halos on small labels. Keep the readability floor in SKILL.md rather than copying this.
