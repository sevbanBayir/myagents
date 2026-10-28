# Sources and study list

## ChromaDecks

Repo: https://github.com/sinasamaki/ChromaDecks. Every reference in this skill is pinned to
commit `b3073d1` (2026-09-19). `SRC` means:

```
https://github.com/sinasamaki/ChromaDecks/blob/b3073d18ecf980b1666a53b79e98d841317048db/composeApp/src/desktopMain/kotlin/com/sinasamaki/chromadecks/
```

Append a path and `#L<start>-L<end>` for a line permalink.

**License:** the repo has no license file, so all rights are reserved by default. Study it and
reproduce the *ideas* in your own code; don't copy files or large excerpts into another
project. The snippets in these references are re-written sketches of the patterns.

| Deck | Package | Main class | Matching content |
| --- | --- | --- | --- |
| #001 Mesh gradients | `_001_MeshGradients` | `MeshGradientPresentationKt` | video https://youtu.be/C7iq8m2dQOo |
| #002 Path animations | `_002_PathAnimations` | `PathAnimationPresentationKt` | video https://youtu.be/20b_bshZo84 |
| #003 ChromaDial | `_003_ChromaDial` | `ChromaDialPresentationKt` | video https://youtu.be/_DGyafGvcMY |
| #004 Timely timer | `_004_TimelyTimer` | `TimelyTimerPresentationKt` | video https://youtu.be/Tn_ZnFsJ9lE |
| UI Delight talk | `_talks.ui_delight` | `UIDelightPrentationKt` | KotlinConf 2026 https://www.youtube.com/watch?v=wj7zUoX8BZA |
| Teaser (9:16) | `_bites.teaser` | `TeaserKt` | — |

Main classes are in package `com.sinasamaki.chromadecks.<package>`.

**Running a deck.** The build uses Gradle 8.9, which doesn't run on JDK 25, so point
`JAVA_HOME` at a JDK 21. `./gradlew :composeApp:run` opens whichever deck `App.kt` selects. To
open a specific deck, put the run classpath on the JVM yourself:

```sh
# decks.init.gradle, in the repo root
allprojects {
    if (path == ":composeApp") {
        tasks.register("printRunClasspath") {
            dependsOn("desktopJar")
            doLast { println("CP=" + tasks.getByName("run").classpath.asPath) }
        }
    }
}
```

```sh
export JAVA_HOME=<a JDK 21 home>
CP=$(./gradlew -q --init-script decks.init.gradle :composeApp:printRunClasspath --no-configuration-cache | sed -n 's/^CP=//p')
java -Dcompose.application.configure.swing.globals=true -cp "$CP" com.sinasamaki.chromadecks._004_TimelyTimer.TimelyTimerPresentationKt
```

Right and left arrows step through build states, then slides.

## Files worth studying, by topic

| Topic | File (under `SRC`) | Why |
| --- | --- | --- |
| Framework | `data/ListSlide.kt` | slide = initial state + deltas |
| Framework | `ui/components/SlidesPresenter.kt` | one spring drives every transition; progress per slide; background slot |
| Framework | `ui/slideanimations/BasicAnimations.kt` | transitions as pure functions of progress |
| Motion | `_004_TimelyTimer/slides/SetUpSlide.kt` | the model build: state, code from state, camera, stagger |
| Motion | `_004_TimelyTimer/components/DuckingNumberDial.kt` | binary vs continuous falloff in four steps |
| Motion | `_004_TimelyTimer/components/TimelyDial.kt` | detent settle, proximity ticks, ring hand-off, DstOut cuts |
| Motion | `_004_TimelyTimer/slides/TimelyGallerySlide.kt` | one spring, four derived properties, stagger by stiffness |
| Motion | `_talks/ui_delight/components/ListItem.kt` (549–905) | focus value, rubber band, check entrance, shake + haptics |
| Motion | `ui/components/FocusZoomer.kt` | camera zoom with centred pivot and vignette |
| Motion | `ui/frames/TitleFrame.kt`, `ui/components/AccordionText.kt` | one timeline split into windows; scramble and stepped text |
| Color | `ui/theme/Colors.kt` (719–788) | swatches, rings, wraparound arithmetic |
| Color | `_004_TimelyTimer/TimelyTimerPresentation.kt` (62–128) | per-slide hue rotation, role formulas, deck transition |
| Color | `_004_TimelyTimer/components/RadialDriftBackground.kt` | layered atmospheric background, stiffness-4 drift |
| Depth | `_003_ChromaDial/components/MonthDurationPickerComponent.kt` (74–321) | full material stack: groove, glow leak, hue-shifted shade, rim light; odometer tick |
| Depth | `_003_ChromaDial/components/TemperatureDialComponent.kt` (141–257) | stacked 6/40/60dp glows, glass pill |
| Depth | `ui/displays/Compact.kt` | device bezel: hairline, glint, sheen, concentric radii |
| Depth | `_bites/teaser/Teaser.kt` (159–201, 420–546) | bloom by Screen blend; gradient text via SrcIn |
| Texture | `ui/modifiers/Grain.kt` | Overlay grain with randomized tiles |
| Type | `ui/theme/ChromaTheme.kt` | the whole type system in ~90 lines |
| Code | `ui/components/CodeBlock.kt`, `ui/components/CodeIDE.kt`, `ui/util/CodeHighlight.kt` | line-diff animation, panel anatomy, minimal highlighter |
| Teaching | `_002_PathAnimations/slides/PencilPaper.kt` | 16 one-line steps synced to a drawing |
| Teaching | `_003_ChromaDial/slides/ChromaDialTeaserSlide.kt` | live values written into code comments |

**Commits to read** (`git show <sha>`):
- `764757e`: his own readability pass. One tab instead of two, an empty skeleton to grow from,
  wrapped chains, numbers made true, proportional rescaling.
- `9121af1`: the progress-driven transition system.
- `1002aec`: the background slot and the index callback.
- `01b0cc3`: code colors in the theme; Space Mono → JetBrains Mono; 14 → 18sp.

## His writing

Blog: https://www.sinasamaki.com (RSS at `/rss/`). Most relevant to the mindset:

- How I prototype with colors: https://www.sinasamaki.com/how-i-prototype-with-colors-in-jetpack-compose/
- Made in Compose, Airbnb month picker dial (layered depth): https://www.sinasamaki.com/made-in-compose-airbnb-month-picker-dial/
- How to create custom dials (overshoot instead of an invisible wall): https://www.sinasamaki.com/how-to-create-custom-dials/
- New shadow API (tinted shadows, blend modes): https://www.sinasamaki.com/new-shadow-api-for-jetpack-compose/
- Brushed metal UI (one light source, from the top): https://www.sinasamaki.com/brushed-metal-ui-in-jetpack-compose/
- Mesh gradients: https://www.sinasamaki.com/mesh-gradients-in-jetpack-compose/
- Haptic feedback, five implementations: https://www.sinasamaki.com/haptic-feedback-in-jetpack-compose/
- Overscroll animations (communicating bounds): https://www.sinasamaki.com/overscroll-animations-in-jetpack-compose/
- Overslide slider interaction: https://www.sinasamaki.com/implementing-overslide-slider-interaction-in-jetpack-compose/
- Page flip (a coherent motion language): https://www.sinasamaki.com/page-flip-3d-animation-in-jetpack-compose/
- Shake animations: https://www.sinasamaki.com/shake-animations-compose/
- Animated counter (direction of change): https://www.sinasamaki.com/animated-counter/
- Glitch effect (randomness with timing, no shader): https://www.sinasamaki.com/glitch-effect-in-jetpack-compose/
- Wrapping a ribbon around any composable: https://www.sinasamaki.com/wrapping-a-fancy-ribbon-around-any-jetpack-composable/
- Spring animations (paywalled beyond the intro): https://www.sinasamaki.com/spring-animations-in-jetpack-compose/

Talks and process:
- KotlinConf 2026, "Crafting Delightful Experiences": https://www.youtube.com/watch?v=wj7zUoX8BZA. One slide-to-dismiss item built up in layers; the Q&A covers his prototyping (one `Animatable` 0→1, then `lerp` to try ranges), sound, accessibility and performance.
- mDevCamp 2026 workshop, layer by layer: https://github.com/sinasamaki/MDevCampWorkshop
- Livestream interview on his process, inspiration and view of AI: https://youtu.be/7OfjAmUfZ8A
- ChromaDial library and docs: https://github.com/sinasamaki/ChromaDial, https://chromadial.sinasamaki.com/
- Single-progress choreography: https://github.com/sinasamaki/KotlinConf26AnimatedLogo
- Bluesky (build-in-public posts): https://bsky.app/profile/sinasamaki.com

## Not verified

- The decks were read as code and launched, but no transition was timed on screen; settle
  times are computed.
- Paywalled articles, X/Twitter posts, and whether the mDevCamp recording plays publicly.
