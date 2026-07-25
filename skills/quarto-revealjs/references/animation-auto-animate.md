# Auto-animate persistent elements across slides

References:
- https://slidecrafting-book.com/auto-animate
- https://quarto.org/docs/presentations/revealjs/advanced.html#auto-animate
- https://revealjs.com/auto-animate/
- Positioning helper: https://github.com/EmilHvitfeldt/quarto-revealjs-editable

Carry a small, fixed cast of shapes (**persistent elements**) across slides; Reveal tweens their position, size, color, and radius between adjacent auto-animate slides. An element can be a big region on one slide and a small marker on the next. Call them persistent elements, not "morph tiles."

## The one rule

**Not every slide takes part.** The effect works when *enough* slides share the cast to feel intentional; static slides between are good pacing. If asked to "animate everything," steer toward a recurring motif instead.

## The data-id contract

Mark adjacent slides `auto-animate=true`; matching elements share a `data-id`:

```markdown
## First {auto-animate=true}

::: {.panel data-id="review" style="left:470px; top:220px; width:340px; height:360px;"}
:::

## Second {auto-animate=true}

::: {.panel data-id="review" style="left:96px; top:200px; width:800px; height:400px;"}
:::
```

Always set `data-id` explicitly for shapes (auto-matching by text/order is fine for code/headings, unreliable for divs).

## Identity in SCSS, geometry inline

```scss
[data-id="draft"]   { background: #2E7D6B; }
[data-id="review"]  { background: #E8A33D; }
[data-id="release"] { background: #4A5899; }
```

Per-slide `left/top/width/height` stay inline. A fixed canvas keeps inline coordinates honest:

```yaml
format:
  revealjs:
    width: 1280
    height: 700
    margin: 0
    center: false
    auto-animate-duration: 0.9
    auto-animate-easing: cubic-bezier(0.22, 1, 0.36, 1)
    theme: [default, my-deck.scss]
```

```scss
.reveal .slides section { padding: 0 !important; height: 700px; }
.panel  { position: absolute; border-radius: 18px; box-sizing: border-box; overflow: hidden; }
.marker { width: 40px; height: 40px; border-radius: 10px; }  // parked state
```

## Content inside elements

An element is a div, so it can hold Markdown or a figure. Inner content is unmatched across slides, so it fades in/out while the element glides (keep `auto-animate-unmatched` at default `true`). For a ggplot figure, put a knitr chunk inside the fenced div and theme the plot to the element's background.

## Patterns that are NOT bento

Code diffs, an agenda/progress rail, a single hero shape reshaping between sections, zoom-to-detail card grids, diagram reflow, stat-to-figure. Steer away from "colored rounded rectangles" as the only idea.

## Positioning

Don't hand-tune every coordinate — use [quarto-revealjs-editable](https://github.com/EmilHvitfeldt/quarto-revealjs-editable) (`extension-editable.md`): rough elements in, then drag/resize on the rendered slide and save back.

## Gotchas

- Animating a text block between very different sizes looks bad mid-word; keep title sizes close.
- `overflow: hidden` on the base element gives clean shrink-to-marker.
- Raw SVG must go in a ` ```{=html} ` block; Pandoc won't pass it through an inline span.
- A non-auto-animate slide between two auto-animate slides breaks the tween; mark the "quiet" slide `auto-animate=true` too and park the element as a marker.
- Book examples never use `self-contained`; `examples/` builds before the book.

Full worked decks: `examples/auto-animate/` (basics, agenda, hero-shape, colored-panels, figure-in-element) and the standalone `auto-animate-elements` skill.
