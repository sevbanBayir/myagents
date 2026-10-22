# Critique

Run per slide on the rendered PNGs, after the `ui-craft` checklist. Write pass or fail with
what you saw; a fail is fixed or carries a reason.

## Projection

1. **Back row.** Every text is ≥18sp on the 1920×1080 stage; body 24–32sp; headline ≥40sp.
2. **Contrast.** Body text ≥7:1 against what is actually behind it. Text in the look's roles
   (`ink`, `inkMuted`, `accentInk`) on its canvas or panels already clears it. Measure text over
   a picture or a vivid background: crop the text from the PNG with PIL, take the median of the
   crop's background pixels and its brightest text pixels, and compute the WCAG ratio. Dimmed
   context may drop lower only when it is meant to recede.
3. **One idea.** The headline states the slide's single idea as a sentence a listener could
   repeat; nothing on the slide argues a second idea.
4. **Squint.** The idea's carrier (the number, the new line, the lit part) is the brightest
   or most saturated thing on the slide.
5. **Stage use.** Content sits balanced on the stage: no slide leaves most of it empty unless
   the emptiness is the point (a statement, a section card).
6. **Margins.** 64dp from every edge (an opener's corner text sits closer by design); nothing
   clipped, nothing overlapping at any step.
7. **Glyphs.** Every glyph draws in the intended face (Turkish letters, arrows, currency): a
   fallback face shows as a different stroke weight in the PNG. Prose shows `->`, `===` and
   `!=` as typed; only code panes join them into ligatures.

## Sequence

8. **Rhythm.** No three dense slides in a row; a section card or statement every 4–6 slides.
9. **Steps.** Each build step changes one thing; the last step of a slide is a sensible still.
10. **Transitions.** In the transition sheet, the motion matches the jump (sibling, new part,
    title). It fails when a strip mixes two transitions, when text of both slides is legible at
    once outside a Fade or HeroExit's middle frames, or when a frame shows neither slide outside
    TitleThrough's blur.
11. **Live.** Each live slide renders a loading state, a success state and a failure state.

## Hand-over list

Name what stills cannot judge, per slide where it applies: spring feel, transition speed,
live timing, keys (→ / PageDown / Space, ← / PageUp, Home / End, digits + G, B, F, N).
