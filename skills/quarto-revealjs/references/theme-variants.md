# Theme variants and full slide themes

References:
- https://slidecrafting-book.com/theme
- https://sass-lang.com/documentation/style-rules#nesting

Two related ideas for consistent, low-effort decks: **variants** (a few restyled slide types) and **slide themes** (each slide picks a full pre-designed style).

## Variants

A variant is a reusable slide style you tag with a class. Classic example: an `inverse` dark slide for section breaks and quotes, alongside default slides. Also good for functional buckets (exercise/demo/results) or a red/yellow/green problem/solution/results arc.

Mark slides:

```markdown
## Slide

## Slide {.variant-one}

## Slide {.variant-two}
```

Style them in `scss:rules`, using nesting to keep it readable:

```scss
.variant-one {
  color: #d6d6d6;
  h1, h2, h3 { color: #f3f3f3; }
  a          { color: #00e0e0; }
  p code     { color: #ffd700; }
}

.variant-two {
  color: #a6a6d6;
  h1, h2, h3 { color: #222222; }
  a          { color: #f22341; }
  p code     { color: #ff00ff; }
}
```

Keep the un-tagged slide as the good default; only add `{.class}` when you want a different look. Worked examples: [quarto-revealjs-inverse](https://github.com/EmilHvitfeldt/quarto-revealjs-inverse), [quarto-revealjs-seasons](https://github.com/EmilHvitfeldt/quarto-revealjs-seasons).

## Full slide themes

Like a slide-layout dropdown in Google Slides: each slide class controls colors, sizes, backgrounds, even text position. Usage stays minimal:

```markdown
## Happy slides {.theme-title1 .center}

## Fancy Section {.theme-section3 .center}

## Funny title {.theme-slide1}

Content
```

Build each class up incrementally:

```scss
@mixin background-full {
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
}

.theme-slide1 {
  &:is(.slide-background) {
    background-image: url('../../../../../assets/slide1.svg');
    @include background-full;
  }
  h3 { color: $theme-blue; font-size: 2em; }
  // keep text off the background art:
  h2, h3, h4, h5, p, pre { margin-left: 100px; }
}
```

Backgrounds are typically SVGs but any image works. Worked examples: [earth](https://github.com/EmilHvitfeldt/quarto-revealjs-earth), [cinco-de-mayo](https://github.com/EmilHvitfeldt/quarto-revealjs-cinco-de-mayo). For behavior beyond CSS, a Lua extension can go further (e.g. Katie Masiello's PositConf 2023 theme).

## Gotchas

- Background-image on a slide goes through the `&:is(.slide-background)` selector, not the section itself.
- The `../../../../../assets/...` depth is real; adjust the number of `../` to your layout.
- Use `@mixin`/`@for` to avoid copy-pasting near-identical slide-class blocks (`theme-scss-advanced.md`).
- When background art occupies part of the slide, shift text regions with `margin-*` so they don't overlap.
