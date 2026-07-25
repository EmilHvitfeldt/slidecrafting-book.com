# Readable text over busy photos

References:
- https://slidecrafting-book.com/layout

Text placed directly on a busy or high-contrast background image is often unreadable. Fix it with a semi-transparent box behind the text.

## Build it up

Start with absolute text (readable problem visible):

```markdown
## {background-image="photo.jpg"}

::: {.absolute left="55%" top="55%" style="font-size:1.8em;"}
Be Brave

Take Risks
:::
```

Add a translucent background and padding:

```markdown
::: {.absolute left="55%" top="55%" style="font-size:1.8em; padding: 0.5em 1em; background-color: rgba(255, 255, 255, .5);"}
Be Brave

Take Risks
:::
```

Polish into a frosted-glass card:

```markdown
::: {.absolute left="55%" top="55%" style="font-size:1.8em; padding: 0.5em 1em; background-color: rgba(255, 255, 255, .5); backdrop-filter: blur(5px); box-shadow: 0 0 1rem 0 rgba(0, 0, 0, .5); border-radius: 5px;"}
Be Brave

Take Risks
:::
```

- `background-color: rgba(...)` — translucency lets the image show through.
- `padding` — so the box is bigger than the text.
- `backdrop-filter: blur(5px)` — glass effect.
- `box-shadow` — depth.
- `border-radius` — softens corners.

## Gotchas

- This is CSS-heavy; move repeated overlays into a reusable class in `scss:rules`.
- On very light images use a dark rgba fill (`rgba(0,0,0,.5)`) with light text instead.
- Don't rely on `backdrop-filter` for print/PDF export — it may not render; keep the solid rgba fill as the fallback.
