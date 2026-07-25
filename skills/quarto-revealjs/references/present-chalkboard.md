# Chalkboard and notes canvas

References:
- https://quarto.org/docs/presentations/revealjs/presenting.html#chalkboard

Draw on and over slides during a talk.

```yaml
format:
  revealjs:
    chalkboard: true
```

- `B` — toggle the chalkboard (a blank drawing surface).
- `C` — toggle the notes canvas (draw directly over the current slide).
- `DEL` — clear the current drawing.
- `D` — download drawings as JSON (restore later via the `src` option).

```yaml
format:
  revealjs:
    chalkboard:
      src: drawings.json     # preload saved drawings
      theme: whiteboard      # or chalkboard
```

You can also add per-slide buttons with `.chalkboard-buttons`.

## Gotchas

- Chalkboard is a plugin; it must be enabled in YAML before the keys do anything.
- Drawings are session-local unless you download and reload them via `src`.
- Not captured in PDF export.
