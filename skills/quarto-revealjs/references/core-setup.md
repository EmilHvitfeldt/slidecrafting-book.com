# New deck setup

References:
- https://quarto.org/docs/presentations/revealjs/
- https://slidecrafting-book.com/10-minute

## Minimal deck

A deck is a single `.qmd`:

```yaml
---
title: "My talk"
author: "Your Name"
format: revealjs
---

## First slide

- point one
- point two

## Second slide

Content.
```

Render: `quarto render deck.qmd`. Live preview with reload: `quarto preview deck.qmd`.

## Recommended scaffold (with a theme)

Pair the deck with an SCSS file so styling has a home from the start:

```yaml
---
title: "My talk"
format:
  revealjs:
    theme: [default, styles.scss]
    slide-number: true
---
```

```scss
/*-- scss:defaults --*/
// Sass variables go here (fonts, colors, sizes)

/*-- scss:rules --*/
// Plain CSS / SCSS rules go here
```

`theme` takes a list: an optional built-in theme (`default`, `dark`, `solarized`, ...) followed by one or more stylesheets that layer on top. `theme: styles.scss` alone is also valid. See `theme-quickstart.md` to fill in the SCSS.

## Sensible defaults worth setting

```yaml
format:
  revealjs:
    theme: [default, styles.scss]
    slide-number: true
    incremental: false        # opt into incremental per-list instead
    code-line-numbers: true
    code-overflow: wrap
    fig-align: center
```

Bump font sizes early (most decks are too small) — see `theme-sizes.md`.

## Sharing a single file

For a deck you email or upload as one file, add `embed-resources: true` (formerly `self-contained: true`) to inline all assets:

```yaml
format:
  revealjs:
    embed-resources: true
```

## Gotchas

- **Inside this repo's `examples/`, do NOT use `self-contained`/`embed-resources`.** Examples share a common `libs/` directory and must be rendered before the book (two-pass build): `quarto render examples/` then `quarto render`.
- A `#` heading makes a section divider slide; `##` makes a content slide. Mixing them structures the deck.
- The title slide is auto-generated from YAML metadata; see `core-title-slide.md` to customize or disable it.
