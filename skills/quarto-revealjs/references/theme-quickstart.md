# The 10-minute theme

References:
- https://slidecrafting-book.com/10-minute
- https://quarto.org/docs/presentations/revealjs/themes.html

A complete, good-looking theme comes from three things: fonts, colors, sizes. Set them as Sass variables in `scss:defaults`. This gets you 90% of the way; escalate to `theme-scss-advanced.md` only when you outgrow variables.

## Setup

```yaml
format:
  revealjs:
    theme: [default, styles.scss]
```

```scss
/*-- scss:defaults --*/

/*-- scss:rules --*/
```

Variables go in `scss:defaults`; free-form CSS in `scss:rules`.

## Fonts (3 variables)

```scss
@import url('https://fonts.googleapis.com/css2?family=Josefin+Sans:wght@100..700&family=Lato:wght@100;300;400;700&family=Space+Mono&display=swap');

$presentation-heading-font: "Josefin Sans", sans-serif;
$font-family-sans-serif:    "Lato", sans-serif;
$font-family-monospace:     "Space Mono", monospace;
```

`presentation-heading-font` falls back to `font-family-sans-serif` if unset. Detail: `theme-fonts.md`.

## Colors (5 variables)

```scss
$body-bg:                    #1C1C2B;
$body-color:                 #bac2de;
$presentation-heading-color: #cba6f7;
$link-color:                 #fab387;   // also colors menu + progress bar
$code-color:                 #89b4fa;
```

Many other values (`$text-muted`, `$selection-bg`, `$border-color`) derive automatically from these. Detail: `theme-colors.md`.

## Sizes (2-3 variables)

```scss
$presentation-font-size-root: 40px;   // scales almost everything
$presentation-h1-font-size:   80px;
$presentation-h2-font-size:   60px;
$code-block-font-size:        0.9em;
```

Most decks use text that is too small; size up. Detail: `theme-sizes.md`.

## Gotchas

- `@import` for web fonts must come before the variables that use them, at the top of `scss:defaults`.
- If bold/italic don't render, you didn't request those weights/styles in the Google Fonts URL.
- When authoring a theme others will layer on, suffix variable definitions with `!default`.
