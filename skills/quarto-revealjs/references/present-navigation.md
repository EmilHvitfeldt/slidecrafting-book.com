# Navigation, menu, overview, keyboard

References:
- https://quarto.org/docs/presentations/revealjs/presenting.html

## Keyboard cheat sheet

| Key | Action |
|---|---|
| →, Space, N | next |
| ←, P | previous |
| F | fullscreen |
| S | speaker view |
| O | overview (thumbnail grid) |
| M | menu |
| B | chalkboard |
| C | notes canvas |
| E | print/PDF view |
| R | scroll view |
| Esc | exit overview/mode |
| `<number>` then Enter | jump to slide |
| ? | show all shortcuts |

## Menu and overview

The menu (button bottom-left, or `M`) lists slides for quick jumps. Overview (`O`) shows a zoomed-out thumbnail grid.

## Options

```yaml
format:
  revealjs:
    menu: true          # or false to disable
    navigation-mode: linear   # linear | vertical | grid
    controls: true      # on-screen arrows
    progress: true      # progress bar (colored by $link-color)
```

## Scroll view

`R` toggles a continuous vertical scroll of the whole deck (good for reading, not presenting). Enable by default with `view: scroll`.

## Gotchas

- Style the progress bar via `$link-color` (`theme-colors.md`).
- `navigation-mode: grid` matters only when you use vertical (nested) slides.
- The menu is a plugin (on by default); `menu: false` removes both button and `M`.
