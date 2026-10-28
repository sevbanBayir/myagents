---
name: ui-craft
description: Visual and motion craft for Compose UI, distilled from sinasamaki's decks, articles and talks - spring motion, hue-ring palettes, layered light and depth, readable type, and a render-and-critique loop. Use when designing or polishing a screen, component or interaction; when choosing animation specs, colors, shadows, glows, spacing or type; when a UI looks flat or generated; or when building an explanatory deck, tutorial or feature demo.
---

# ui-craft

The taste here is reverse-engineered from sinasamaki (Ian Leshan): five presentation decks
written in Compose (176 files, 28 commits), 44 blog articles and his conference talks. He
calls himself a non-designer. His base is Material and Apple's HIG; everything on top is
tuned by eye in a hot-reload loop that renders in seconds. The **loop** is the method and the
numbers below are what it left behind. Work the same way: decide, render, look, correct.

## Stance

- **Delight is information.** Every effect tells the user something about state. A hover glow
  says "you are about to act", a swipe background that deepens says "releasing now triggers",
  a rubber band says "this goes no further". An effect that carries no information gets cut.
- **Physics for state, time for clocks.** Springs drive every state change. Tweens are kept
  for color fades, delayed staggers, loops and shape morphs.
- **One driver.** One animated value per interaction or reveal, and every property is
  `lerp`ed from it. Properties stay in sync and the motion stays interruptible.
- **Light from the top, depth from faint layers.** Each layer looks like nothing on its own;
  stacked, they read as material.
- **(hue, step) color.** Every color is a palette swatch at a shade step. Roles bind to
  steps; themes and screens rotate the hue.
- **One idea per step.** On screen and in explanations, one thing changes and everything else
  holds still.
- **Decide, then display.** Each place on screen answers one question. Every fact gets its own
  slot: text, a label/value pair, a status badge, or a hover. Show what deviates from the
  default; the default itself needs no space.

## Steps

1. **Write the intent.** For each interaction, one sentence: which state change does it
   communicate? List the states (rest, hover, pressed, dragging, armed, disabled, empty…).
   Done when every effect you plan maps to a state it communicates.
2. **Lay down the system before the screen.** When the project has one (theme tokens,
   Material, shadcn), map the roles onto it and take only the gaps from **Defaults**;
   otherwise pick palette roles, spacing, type and radius from **Defaults**. Done when the
   code has no color, dp or sp literal outside the system.
3. **Build in layers, in order:** layout → state feedback (hover, press) → motion → light and
   depth → texture. Render after each layer, so a layer that adds nothing is visible as such.
4. **Render and look.** Compose: the `compose-preview` skill, with a timeline or GIF for
   motion (its `capture-modes` reference). Web: the browser, with screenshots timed across the
   motion (its first frame, mid-way, after it settles) and `getBoundingClientRect` where the
   eye can't judge a gap. Render every state from step 1 and read the images. Done when you
   have looked at an image of every state you changed. A clean compile is not a look.
5. **Critique** against **Checklist**, writing pass or fail per item with what you saw. Fix,
   re-render, repeat. Done when every item passes or carries a written reason it doesn't apply.
6. **Hand over the feel.** Spring weight, drag resistance and haptics can't be judged from
   stills. Name the interactions the human should try by hand, and what to watch for in each.

## Defaults

His house values, measured across the code. Deviate on purpose, and say why.

| Area | Default |
| --- | --- |
| State change | `animate*AsState` + `spring(stiffness = StiffnessLow)` for components, `StiffnessVeryLow` for screen-level moves and camera. Damping left at 1.0. |
| Bounce | `DampingRatioMediumBouncy` for small arrivals, press squish and released drags; `HighBouncy` only for a rubber-band snap-back. Camera, alpha, color, size and layout settle critically damped. |
| Entrances vs exits | The exit is plainer: no bounce, faster (`StiffnessHigh` or a snapped fade), about 70% of the entry distance. |
| Feedback tempo | Touch feedback on the default spring (`StiffnessMedium`); the state it leaves behind on `StiffnessLow`. |
| Hover and press | One `focus` value: rest 0, hover .5, press 1. Inner-glow radius and alpha lerp from it. |
| Stagger | Delay each item by 15–40% of its duration (40–90 ms), or lower stiffness by 20 per item. |
| Proximity | Continuous falloff over a range (full at 0°, none at 15–18°), rather than an on/off trigger. |
| Color change | `tween(800)`. |
| Ambient | A soft spring (stiffness 5–25) retargeted every 200–1000 ms; Linear loops of 8–120 s. Background layers move about 4× slower than content. |
| Palette | Tailwind v4 (11 steps, 50–950), chromatic ring of 17 hues with wraparound `+`/`-`. |
| Color roles | Canvas Zinc900, wells Zinc950 (α .7 over color), letterbox Black, text Slate50, secondary Zinc400/Slate500. Accents 400–500, glows 200–300. |
| Harmony | Foreground roles from hues `s`, `s+1`, `s+2`; background stops up to `s+4`; at most one complementary accent. |
| Shading | Shadow side shifts to `(s+1)` one step darker; highlights lerp 20% toward Slate50, shadows 20% toward Slate950. |
| Borders | 1dp, vertical gradient α .3 at the top → .05–.1 at the bottom. |
| Radius | 24dp default, 32dp large frames, 8–16dp chips. Inner radius = outer − inset. |
| Shadows and glows | Neutral shadow radius 7–10, α .15–.4. Colored glow radius 40–70, α ≤ .9, built from 2–4 stacked blurs (~6, 20–40, 60dp). |
| Type | At most 3 faces, each with one job. Sizes 18/20/28/32 for text and code, 56/72/96 for display; weights 400 and 700. |
| Spacing | 4-based: 4/8/12/16/24/32/64/128. Stage slides use 64dp margin and gutter; app screens start from Material spacing. |
| Hierarchy | Within one size, by tone: neutral 200/400/500. De-emphasis by opacity 1/.5/.25, or blur 50–100dp with α .7. |
| Readability floor | Body and code text ≥ 7:1. Over vivid backgrounds, put text on a dark translucent panel. Tinted text directly on a gradient only at ≥ 48sp, or with a Black α .4, 10px shadow. |

The readability floor corrects a weakness in his own work: his tinted `v50` dial text sits at
1.7–2.8:1 on the gradient. Copy his color logic, keep this floor.

## Checklist

1. **Squint:** the one element that matters is the brightest or most saturated thing on screen.
2. Every color traces to a (hue, step) swatch, with at most one complementary accent.
3. Neutral surfaces carry the screen, containers included; chroma lives on the marks that carry
   meaning (a dot, a badge, a value) and on atmosphere. Warning, success and error colors appear
   only for those states, and an arrival flashes neutral, as a new code line does.
4. Light comes from the top: borders and highlights brighter at the top edge, shadows below.
5. Borders are translucent gradients; nested radii are concentric.
6. Text meets the readability floor.
7. Sizes, weights and faces come from the type scale, and each face keeps its one job.
8. Spacing comes from the scale, and repeated elements share edges and baselines.
9. Each motion is a spring, or one of the four tween cases. Bounce appears only where Defaults allows it.
10. Each interaction has one driver, and hover flows continuously into press.
11. Exits are plainer than entrances.
12. Something holds still while something moves; two unrelated motions never compete for the eye.
13. Every effect maps to a state from step 1.
14. Custom controls carry `semantics`, and state shows in shape as well as color.
15. Each line carries one fact or one label/value pair, set apart by layout: slots, tone and gap.

## References

Each holds the evidence, recipes and file pointers for one branch. Read the one you need:

- Motion, micro to macro: [references/motion.md](references/motion.md)
- Color, light, depth, texture: [references/color-depth.md](references/color-depth.md)
- Type, layout, readability, code on screen: [references/type-layout.md](references/type-layout.md)
- Explanatory decks, tutorials, feature demos: [references/explainers.md](references/explainers.md)
- Study list, source permalinks, articles, talks: [references/sources.md](references/sources.md)
