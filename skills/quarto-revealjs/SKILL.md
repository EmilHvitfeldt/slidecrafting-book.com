---
name: quarto-revealjs
description: Build, theme, and present reveal.js slide decks authored in Quarto. Use this skill whenever the user is working on Quarto reveal.js slides (a `.qmd` with `format: revealjs`) - starting a new deck, restyling it (fonts, colors, sizes, SCSS themes), positioning content (columns, absolute positioning, background images, overlays, cards), showing code or plots well, adding fragment or auto-animate motion, or presenting and exporting (speaker notes, speaker view, PDF, chalkboard, multiplex). Routes to focused reference files under references/.
---

# Quarto Reveal.js — beautiful slides

Build and polish presentations written in Quarto that render to [reveal.js](https://revealjs.com). This skill is an index: skim the tables below, then open the one `references/*.md` file that matches the task. Each reference is self-contained, copy-paste ready, and ends with gotchas.

References throughout point at three sources:

- The book: <https://slidecrafting-book.com>
- Quarto reveal.js docs: <https://quarto.org/docs/presentations/revealjs/>
- reveal.js docs: <https://revealjs.com>

## When to use

- Starting a new Quarto reveal.js deck
- Theming / restyling slides (fonts, colors, sizes, SCSS, variants, full slide themes)
- Positioning content (columns, absolute placement, backgrounds, overlays, paper cards)
- Showing code or plots well (highlighting, transparent plot backgrounds, figure sizing)
- Fragment or auto-animate motion
- Presenting and exporting (notes, speaker view, PDF, chalkboard, multiplex)
- Reaching for one of Emil's Quarto reveal.js extensions

## Quick start

A deck is a `.qmd` with a paired `styles.scss`:

```yaml
---
title: "My talk"
format:
  revealjs:
    theme: [default, styles.scss]
---

## First slide

- point one
- point two
```

```scss
/*-- scss:defaults --*/

/*-- scss:rules --*/
```

Render with `quarto render deck.qmd` or preview live with `quarto preview deck.qmd`. Full scaffold, sane defaults, and the two-pass build note: `references/core-setup.md`.

## Basic syntax

- A level-2 heading (`##`) starts a new slide. A level-1 heading (`#`) starts a section divider.
- Body content is plain Markdown: lists, `**bold**`, `[links](...)`, images, code fences.
- Fenced divs `::: {.class}` attach classes/attributes to a block; inline `[text]{.class}` to a span.
- Slide-level attributes go on the heading: `## Title {.center background-color="#222"}`.

Details: `references/core-syntax.md`.

## Core references

Read these first for most tasks.

| Topic | Reference |
|---|---|
| New deck, YAML scaffold, build | `references/core-setup.md` |
| Slide syntax, lists, callouts, tabsets | `references/core-syntax.md` |
| The 10-minute theme (fonts + colors + sizes) | `references/theme-quickstart.md` |
| Columns and side-by-side layout | `references/layout-columns.md` |
| Absolute positioning of anything | `references/layout-absolute.md` |

## Slide structure

| Topic | Reference |
|---|---|
| Title slide, logo, footer attributes | `references/core-title-slide.md` |
| Slide backgrounds (color, image, video, iframe) | `references/core-backgrounds.md` |
| Footer and logo (global + per-slide) | `references/core-footer-logo.md` |
| Content overflow (`.smaller`, `.scrollable`) | `references/core-overflow.md` |

## Theming

| Topic | Reference |
|---|---|
| Fonts: Google Fonts, local `@font-face`, ligatures | `references/theme-fonts.md` |
| Colors: palettes, contrast, applying via variables | `references/theme-colors.md` |
| Sizes: root/heading/code font-size variables | `references/theme-sizes.md` |
| Advanced SCSS: maps, functions, `@each`, `@mixin` | `references/theme-scss-advanced.md` |
| Theme variants and full slide themes (SVG backgrounds) | `references/theme-variants.md` |
| Custom code syntax highlighting | `references/theme-syntax-highlight.md` |
| Restyling the slide menu button | `references/theme-menu-button.md` |

## Layout & positioning

| Topic | Reference |
|---|---|
| Multi-column / side-by-side | `references/layout-columns.md` |
| Big text with `r-fit-text` | `references/layout-fit-text.md` |
| Absolute positioning (text and images) | `references/layout-absolute.md` |
| Images: basic, absolute, background | `references/layout-images.md` |
| Readable text over busy photos | `references/layout-overlay-textbox.md` |
| Distributing bullets evenly (`.spread`) | `references/layout-spread.md` |
| Floating paper card slides | `references/layout-paper-card.md` |

## Content: code, plots, media

| Topic | Reference |
|---|---|
| Code line highlighting and step-through | `references/content-code-highlighting.md` |
| Showing Quarto code literally (unexecuted) | `references/content-code-unexecuted.md` |
| Hand-styled / manually highlighted code | `references/content-code-manual.md` |
| Animated terminal recordings (asciicast) | `references/content-code-asciicast.md` |
| Transparent plot backgrounds (R, Python) | `references/content-plot-background.md` |
| Sizing figures for slides | `references/content-plot-sizing.md` |

## Animation & interactivity

| Topic | Reference |
|---|---|
| Built-in fragments and incremental reveals | `references/animation-fragments.md` |
| Custom fragment animations (CSS states + JS) | `references/animation-fragments-custom.md` |
| Auto-animate persistent elements across slides | `references/animation-auto-animate.md` |
| Slide and fragment transitions | `references/animation-transitions.md` |

## Presenting & exporting

| Topic | Reference |
|---|---|
| Speaker notes | `references/present-speaker-notes.md` |
| Speaker view / presenter mode | `references/present-speaker-view.md` |
| Chalkboard and notes canvas | `references/present-chalkboard.md` |
| PDF export / printing | `references/present-pdf-export.md` |
| Multiplex (audience follow-along) | `references/present-multiplex.md` |
| Navigation, menu, overview, keyboard | `references/present-navigation.md` |
| Slide numbers and auto-advance | `references/present-slide-numbers.md` |

## Extensions (install, don't hand-roll)

| Extension | Reference |
|---|---|
| Drag-to-reposition elements (`editable`) | `references/extension-editable.md` |
| IDE-window code blocks (`codewindow`) | `references/extension-codewindow.md` |

## Miscellaneous

| Topic | Reference |
|---|---|
| Hiding slides | `references/misc-hiding-slides.md` |
| Reusing content with includes | `references/misc-includes.md` |
| VS Code / Positron Sass-variable snippets | `references/misc-snippets.md` |

## Rules of thumb

- Set `theme: [default, styles.scss]`; put Sass variables in `scss:defaults`, CSS in `scss:rules`.
- CSS that targets slide content needs the `.reveal .slides section` (or `.reveal .slide`) prefix to beat theme specificity.
- Most people use text that is too small. Size up.
- Contrast between background, text, and highlight colors matters more than any other single choice.
- Do not add `self-contained: true` inside this repo's `examples/` (shared `libs/`, two-pass build).
