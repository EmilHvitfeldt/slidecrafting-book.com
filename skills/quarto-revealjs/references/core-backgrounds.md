# Slide backgrounds

References:
- https://quarto.org/docs/presentations/revealjs/#slide-backgrounds
- https://slidecrafting-book.com/layout

Set on the slide heading. Backgrounds fill the whole viewport, behind content.

## Color

```markdown
## Slide {background-color="#1C1C2B"}
```

## Gradient

```markdown
## Slide {background-gradient="linear-gradient(to bottom, #283b95, #17b2c3)"}
```

## Image

```markdown
## Slide {background-image="photo.jpg"}
```

Extra controls: `background-size` (`cover`/`contain`), `background-position`, `background-repeat`, `background-opacity`.

```markdown
## {background-image="photo.jpg" background-size="cover" background-opacity="0.5"}
```

Leaving the heading text empty (`## {...}`) gives a clean canvas; place content with absolute positioning (`layout-absolute.md`) or an overlay box (`layout-overlay-textbox.md`).

## Video

```markdown
## Slide {background-video="clip.mp4" background-video-loop="true" background-video-muted="true"}
```

## Iframe

```markdown
## Slide {background-iframe="https://example.com" background-interactive="true"}
```

## Gotchas

- For readable text over a busy image, add an overlay box — see `layout-overlay-textbox.md`.
- To keep content clear of full-bleed background decoration, consider the paper-card technique (`layout-paper-card.md`).
- Background image aspect handling varies by slide aspect ratio; tune for the ratio you actually present at.
