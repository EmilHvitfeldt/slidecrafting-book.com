# Absolute positioning

References:
- https://slidecrafting-book.com/layout
- https://quarto.org/docs/presentations/revealjs/advanced.html#absolute-position

The `.absolute` class places any element at exact coordinates, independent of content flow. Works on images **and** text.

## Attributes

| Attribute | Meaning |
|---|---|
| `width` / `height` | element size |
| `top` / `bottom` | distance from top / bottom edge |
| `left` / `right` | distance from left / right edge |

Use one of `top`/`bottom` and one of `left`/`right`. All accept any CSS length (`px`, `%`, `in`). Setting just one of `width`/`height` avoids distorting images.

## Images

```markdown
![](photo.jpg){.absolute top=0 right=0 height="100%"}
```

## Text

```markdown
[python is great]{.absolute bottom="45%" left="20%"}

[and so is R]{.absolute bottom="0%" right="0%"}
```

Or a whole block:

```markdown
::: {.absolute left="55%" top="55%" style="font-size:1.8em;"}
Be Brave
:::
```

## Bleeding past the slide edge

Reveal.js caps media at `max-width: 95%; max-height: 95%`. To exceed the frame, unset those and use negative offsets:

```markdown
![](photo.jpg){.absolute top="-10%" right="-10%" height="120%" style="max-height: unset; max-width: unset;"}
```

## Gotchas

- `0` is inside the slide; use negative values to overflow the edge.
- A perfect bleed is nearly impossible across all aspect ratios — make it work for the ratio you present at and move on.
- Pixel-tuning coordinates is tedious; use the `editable` extension to drag/resize in-browser (`extension-editable.md`).
