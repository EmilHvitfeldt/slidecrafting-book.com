# Sizes

References:
- https://slidecrafting-book.com/sizes
- https://quarto.org/docs/presentations/revealjs/themes.html#sass-variables

Control sizing with Sass variables in `scss:defaults`. Most decks are too small — err large, especially for in-person audiences.

## The key variables

```scss
$presentation-font-size-root: 40px;   // base; nearly everything scales from this
$presentation-h1-font-size:   80px;
$presentation-h2-font-size:   60px;
$presentation-h3-font-size:   40px;
$presentation-h4-font-size:   32px;
$code-block-font-size:        0.9em;
```

- `$presentation-font-size-root` is the master dial: raise it and body, headings, and most spacing grow together.
- Heading variables set each level; most decks only need `h1`/`h2`.
- `$code-block-font-size` sizes code blocks and their output independently (use `em` so it tracks the root).

## Related

```scss
$presentation-line-height:         1.3;
$presentation-heading-line-height: 1.2;
$presentation-block-margin:        12px;
```

## Gotchas

- Because most sizes derive from the root, change it first and only override individual headings if the proportions feel off.
- Bigger code font can overflow — pair with `code-overflow: wrap` or `.scrollable` (`core-overflow.md`).
- `em`-based sizes track the root; `px` sizes don't. Prefer `em` for things that should scale with the deck.
