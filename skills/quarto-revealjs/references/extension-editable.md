# Extension: editable (drag-to-reposition)

References:
- https://github.com/EmilHvitfeldt/quarto-revealjs-editable
- https://slidecrafting-book.com/layout

Reposition and resize elements directly in the browser while viewing slides, then copy the resulting CSS values back into your source. Invaluable for absolute positioning (`layout-absolute.md`) and auto-animate layout (`animation-auto-animate.md`), where exact pixels are tedious by trial and error.

## Install

```bash
quarto add EmilHvitfeldt/quarto-revealjs-editable
```

```yaml
format:
  revealjs: default
revealjs-plugins:
  - editable
```

## Use

Click **Modify** in the deck menu (or mark elements `{.editable}`), drag/resize on the rendered slide; the extension outputs the coordinates to paste into the `.qmd`. Workflow: rough elements in, then nudge visually.

## Gotchas

- Still a little buggy — a prototyping aid, not a production feature.
- It reports values; you must paste them back into source to persist them.
