# Fonts

References:
- https://slidecrafting-book.com/fonts
- https://fonts.google.com

## Finding fonts

Use [Google Fonts](https://fonts.google.com/); they're free and need no shipping. Look for a legible font that offers multiple weights and italics if you'll use them. [Font pairing](https://www.figma.com/google-fonts/) sites help choose a heading + body combo.

## Applying Google Fonts

Copy the `@import` from "Get embed code" into the top of `scss:defaults`, then set the variables:

```scss
/*-- scss:defaults --*/
@import url('https://fonts.googleapis.com/css2?family=IBM+Plex+Serif:ital,wght@0,400;0,600;1,400&display=swap');
@import url('https://fonts.googleapis.com/css2?family=Manrope:wght@200..800&display=swap');

$font-family-sans-serif:    'Manrope', sans-serif;
$presentation-heading-font: 'IBM Plex Serif', serif;
$font-family-monospace:     monospace;
```

Comma-separated names are fallbacks: if `Manrope` fails to load, the browser tries the next. Always end with a generic family (`sans-serif`, `serif`, `monospace`).

## Embedding local fonts

Use local fonts when you need offline decks, a non-web font, or faster load. Download `.woff`/`.woff2`, drop them beside the `.qmd`, and register with `@font-face`:

```scss
/*-- scss:defaults --*/
@font-face {
  font-family: 'FiraCode';
  src: url('../../../../../FiraCode-Regular.woff2') format('woff2'),
       url('../../../../../FiraCode-Regular.woff') format('woff');
}

$font-family-monospace: 'FiraCode';
```

Coding fonts with ligatures (like [FiraCode](https://github.com/tonsky/FiraCode)) render `!=`, `|>`, `->` as single glyphs.

## Gotchas

- **The `../../../../../` path is real.** Local `@font-face` URLs resolve from deep in the render tree; ~5 levels of `../` is typical when the font sits next to the `.qmd`. Adjust to your layout. ([quarto-cli#5712](https://github.com/quarto-dev/quarto-cli/issues/5712))
- Request every weight/style you use in the Google Fonts URL, or bold/italic silently won't work.
- `@import` lines must precede variable assignments.
