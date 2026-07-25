# Images

References:
- https://slidecrafting-book.com/layout
- https://quarto.org/docs/authoring/figures.html

Three ways to add images, in increasing control. For style images (reinforcing, not carrying content), prefer absolute or background.

## Basic figure

```markdown
![](photo.jpg){fig-align="right"}
```

Added as content: respects margins and pushes other content around. Fine for real figures, less so for decorative images.

## Absolute

Most control over position and size. See `layout-absolute.md` for the full attribute set and bleed technique.

```markdown
![](photo.jpg){.absolute top=0 right=0 height="100%"}
```

## Background

Simplest full-bleed option; set on the slide heading:

```markdown
## Slide Title {background-image="photo.jpg"}
```

Often best with an empty title and absolutely-positioned content:

```markdown
## {background-image="photo.jpg"}

[always explore]{.absolute left="50%" top="20%" style="rotate: -10deg;"}
```

More background options (size, position, video, iframe): `core-backgrounds.md`.

## Gotchas

- Basic figures obey `max-width/height: 95%`; unset those for larger absolute images.
- Text placement over a background image changes the slide's whole feel — use it deliberately.
- For readable captions/text over a photo, add an overlay box (`layout-overlay-textbox.md`).
