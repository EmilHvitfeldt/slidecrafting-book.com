# Extension: autoanimate-extra (rotation, 3D, filters in auto-animate)

References:
- https://github.com/EmilHvitfeldt/quarto-revealjs-autoanimate-extra
- https://slidecrafting-book.com/auto-animate

Reveal's built-in auto-animate only interpolates position (translate) and size (scale): its FLIP engine overwrites `transform` wholesale, so any rotation you author is dropped, and it cannot ride along in `autoAnimateStyles` either. This extension makes `transform` tween like every other auto-animated property, which brings auto-animate close to PowerPoint's Morph.

## Install

```bash
quarto add emilhvitfeldt/quarto-revealjs-autoanimate-extra
```

```yaml
format: revealjs
revealjs-plugins:
  - autoanimate-extra
```

## Use

No special attributes. Write an ordinary CSS `transform` inline, exactly as you would change `width` to animate size:

```markdown
## Slide 1 {auto-animate=true}

::: {data-id="box" style="width: 200px; height: 200px; background: #2c6fbb;"}
:::

## Slide 2 {auto-animate=true}

::: {data-id="box" style="width: 200px; height: 200px; background: #2c6fbb; transform: rotate(90deg);"}
:::
```

It composes with auto-animate's own move and resize, so one element can travel, grow, spin, flip and round its corners in a single transition.

| Effect | Transform |
|---|---|
| 2D rotation | `rotate(90deg)` |
| Card flip | `perspective(800px) rotateY(180deg)` |
| Tumble in 3D | `perspective(1000px) rotateX(55deg) rotateY(35deg)` |
| Mirror | `scaleX(-1)` |
| Skew | `skewX(-25deg) skewY(8deg)` |
| Full turn | `rotate(360deg)` |

Rotations are absolute and may exceed 360° or go negative, which controls spin direction and turn count.

## Style tweening

On top of Reveal's defaults (opacity, color, background color, padding, font size, line height, letter spacing, border width/color/radius, outline) the extension adds `box-shadow`, `text-shadow` and `filter` deck-wide, so shadows and blur morph too. Anything else is opt-in per element with `data-auto-animate-styles` (comma-separated property list, mirroring Reveal's `autoAnimateStyles`):

```markdown
::: {data-id="shape" data-auto-animate-styles="clip-path" style="clip-path: polygon(50% 0%, 100% 100%, 0% 100%);"}
:::
```

## Moving code and a chart independently

Wrap each chunk in a div carrying its own `data-id` and its own absolute geometry, and the two move on separate paths. Pair with `data-auto-animate-delay` on the destination so one leads and the other follows:

```markdown
## Code, then chart {auto-animate=true}

::: {data-id="code" style="position: absolute; left: 30px; top: 220px; width: 470px;"}
...code block...
:::

::: {data-id="chart" style="position: absolute; left: 550px; top: 200px; width: 470px; transform: rotate(0deg);"}
...plot chunk...
:::

## Code, then chart {auto-animate=true}

::: {data-id="code" style="position: absolute; left: 175px; top: 130px; width: 700px;"}
...code block...
:::

::: {data-id="chart" data-auto-animate-delay="0.25" style="position: absolute; left: 275px; top: 340px; width: 500px; transform: rotate(360deg);"}
...plot chunk...
:::
```

Absolute positioning is what keeps them independent; a shared `.columns` wrapper would tie them to one layout flow.

## Gotchas

- **Write the transform inline.** A transform in a stylesheet is only readable as a computed matrix, so it animates as a matrix decomposition: rotation takes the shortest path and multi-turn spins collapse. `rotate(720deg)` only means two turns when written inline.
- **Use the same transform-function list, in the same order, on both slides.** The extension unions the two lists and pads with identity values, but keeping them matched avoids surprises (`perspective()` has no identity, so it borrows the other side's value).
- The FLIP math assumes `transform-origin: center`; the extension sets it for the duration of the transition.
- Reveal supports a single global `autoAnimateMatcher`. Another extension that sets one will conflict (last one wins).
- Per-glyph text morph and true SVG path morph are different algorithms and out of scope.

## Examples in the extension repo

`example.qmd` (one slide-pair per capability) and `examples/pinwheel/` (a rotating photo pinwheel recreating a PowerPoint Morph tutorial, where each picture counter-rotates so the photographs stay upright).
