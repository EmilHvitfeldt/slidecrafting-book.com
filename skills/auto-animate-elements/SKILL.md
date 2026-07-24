---
name: auto-animate-elements
description: How to spruce up Quarto reveal.js slides with auto-animate by carrying a small cast of persistent elements (shapes) across slides that grow, shrink, and rearrange. Use this skill whenever the user wants elements that persist/animate/reshape between reveal.js slides, a set of shapes that move or morph across a deck, an "auto-animate" motif, or a bento-style animated presentation in Quarto. Covers the data-id contract, the SCSS-plus-inline split, content and figures inside elements, and the "enough, not all" pacing rule.
---

# Auto-Animate persistent elements

References:

- https://slidecrafting-book.com/auto-animate
- https://quarto.org/docs/presentations/revealjs/advanced.html#auto-animate
- https://revealjs.com/auto-animate/
- Positioning helper: https://github.com/EmilHvitfeldt/quarto-revealjs-editable

The goal: take a deck and give it motion by carrying a small, fixed cast of shapes (**persistent elements**) across slides. Each element has a stable `data-id`; reveal.js tweens its position, size, colour, and radius between adjacent auto-animate slides. An element can be a big content region on one slide and a small marker on the next.

Do not call these "morph tiles." Call them persistent elements (or just elements).

## The one rule to set expectations first

**Not every slide has to take part.** The effect works when *enough* slides share the cast to feel intentional. Static slides in between are good for pacing. Never force every element onto every slide. When a user asks for "animate everything," push back gently and aim for a recurring motif instead.

## File structure

A deck is a `.qmd` plus a paired `.scss` (matching the book's example convention):

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

`width`/`height` + `margin: 0` + `center: false` (and zeroed slide padding in SCSS) give a fixed pixel canvas whose top-left is the origin, so inline `left`/`top` match what you see.

## The `data-id` contract

Mark adjacent slides `auto-animate=true` and give matching elements the same `data-id`:

```markdown
## First {auto-animate=true}

::: {.panel data-id="review" style="left:470px; top:220px; width:340px; height:360px;"}
:::

## Second {auto-animate=true}

::: {.panel data-id="review" style="left:96px; top:200px; width:800px; height:400px;"}
:::
```

Always set `data-id` explicitly for shapes. Auto-matching by text/order is fine for code and headings but unreliable for a cast of divs.

## Identity in SCSS, geometry inline

This is the key split that keeps the markup sane.

**Identity** (things that rarely change) go in the paired SCSS, keyed on `data-id`:

```scss
[data-id="draft"]   { background: #2E7D6B; }
[data-id="review"]  { background: #E8A33D; }
[data-id="release"] { background: #4A5899; }
```

**Geometry** (per-slide position and size) goes inline:

```markdown
::: {.panel data-id="draft" style="left:96px; top:220px; width:340px; height:360px;"}
:::
```

## Recommended helper classes (in the paired SCSS)

```scss
.reveal .slides section { padding: 0 !important; height: 700px; }

// base element
.panel {
  position: absolute;
  border-radius: 18px;
  box-sizing: border-box;
  overflow: hidden;   // clips inner content cleanly during shrink
}

// the "parked marker" state
.marker { width: 40px; height: 40px; border-radius: 10px; }

// set text colour once per slide via a class on the heading
.dark  h2, .dark  .big-title { color: #F1EEE6; }
.light h2, .light .big-title { color: #17251F; }

// let the ## heading double as the slide's small kicker label
.reveal h2 {
  position: absolute; left: 96px; top: 54px; margin: 0;
  font-size: 18px; letter-spacing: .18em; font-weight: 600; text-transform: uppercase;
}

// content that lives inside an element
.card   { padding: 26px 28px; }
.card .h { font-size: 32px; font-weight: 700; }
.card .p { font-size: 19px; line-height: 1.45; margin-top: 12px; opacity: .92; }
```

Use `.dark` / `.light` on the heading (`## Title {.dark auto-animate=true ...}`) so text colour is stated once per slide, not on every span. Use the `##` heading text as the kicker; use fenced divs (`::: {}`) for the big title and elements, not raw `<div>`.

## Content and figures inside an element

An element is a div, so it can hold markdown or a figure. Inner content is unmatched across slides, so it **fades in/out while the element glides** (this is the desired effect; keep `auto-animate-unmatched` at its default `true`).

Text card:

```markdown
::: {.panel .card data-id="review" style="left:96px; top:200px; width:800px; height:400px;"}
[Review]{.h}

[Read it as if you did not write it.]{.p}
:::
```

ggplot2 figure (needs R at render time): put a knitr chunk inside the fenced div.

````markdown
::: {.panel data-id="panel" style="left:96px; top:160px; width:1088px; height:480px;"}
```{r}
#| echo: false
#| fig-width: 12
#| fig-height: 4.8
#| dev: svg
library(ggplot2)
ggplot(...) + theme_minimal()
```
:::
````

Theme the plot to the element's background (e.g. `plot.background = element_rect(fill = "#16273E")`) so it reads as part of the shape.

## Patterns that are NOT bento

Steer users toward varied uses, not just colored rounded rectangles:

- **Code**: the same code block on consecutive auto-animate slides animates added/removed lines. No shapes needed.
- **Agenda / progress rail**: a column of items where the active one enlarges and the rest dim on each section divider.
- **Hero shape**: one recurring shape that reshapes between section dividers (circle → bar → frame), parked as a marker on the quiet slides between. Best illustration of "enough, not all."
- **Zoom to detail**: a grid of cards; one expands to fill the slide, the others park at the edges, then collapse back.
- **Diagram reflow**: boxes/nodes rearranging from a linear flow into a cycle.
- **Stat → figure**: a big number that expands into a panel holding a chart.

## Positioning workflow

Do not hand-tune every coordinate. Recommend `quarto-revealjs-editable`:

```bash
quarto add EmilHvitfeldt/quarto-revealjs-editable
```

Click **Modify** in the deck menu (or mark elements `{.editable}`), drag/resize on the rendered slide, and save coordinates back to the `.qmd`. Workflow: rough the elements in, then nudge visually.

## Gotchas

- Animating a text block between very different sizes looks bad mid-word. Keep title sizes close, or accept the stretch only on short headings.
- `overflow: hidden` on the base element gives clean shrink-to-marker transitions.
- Raw SVG must go in a ```` ```{=html} ```` block; Pandoc will not pass it through an inline `[]{}` span.
- Fenced divs need the opening and closing `:::` on their own lines; an empty element is a two-line block.
- Book examples never use `self-contained: true`, and `examples/` must be rendered before the book (two-pass build).
- If a non-auto-animate slide sits between two auto-animate slides, elements will not tween across that gap. To keep an element persistent through a "quiet" slide, mark that slide `auto-animate=true` too and park the element as a marker.

## Starting point

The book's worked examples live in `examples/auto-animate/` (`basics`, `agenda`, `hero-shape`, `colored-panels`, `figure-in-element`). Adapt `colored-panels.qmd` + `.scss` as a copy-paste skeleton for a multi-element deck, or `hero-shape.*` for the single-shape approach.
