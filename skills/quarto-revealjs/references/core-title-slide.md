# Title slide

References:
- https://quarto.org/docs/presentations/revealjs/advanced.html#title-slide

The title slide is generated automatically from YAML metadata (`title`, `subtitle`, `author`, `date`, `institute`).

## Backgrounds and images on the title slide

Use the `title-slide-attributes` key to pass slide-background attributes to the auto-generated title slide:

```yaml
---
title: "My talk"
format: revealjs
title-slide-attributes:
  data-background-image: cover.png
  data-background-size: cover
  data-background-opacity: "0.4"
---
```

## Logo and footer

```yaml
format:
  revealjs:
    logo: logo.png
    footer: "My conference 2026"
```

The footer and logo appear on every slide; remove them on a specific slide with the `.hide-footer` / `.hide-logo` classes. See `core-footer-logo.md`.

## Disabling the title slide

Omit `title` (and other metadata), or start the document with your own `##` slide, to skip the generated title slide.

## Styling

Title-slide text alignment is set with `$presentation-title-slide-text-align` (default `center`). Target the title slide in SCSS with `.reveal .slides section.title-slide` / the `#title-slide` id.

## Gotchas

- Background attributes on the title slide go under `title-slide-attributes` with the `data-` prefix, not as bare `background-*` keys.
- `data-background-opacity` must be quoted in YAML.
