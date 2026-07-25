# Slide numbers and auto-advance

References:
- https://quarto.org/docs/presentations/revealjs/presenting.html

## Slide numbers

```yaml
format:
  revealjs:
    slide-number: true      # or a format string
```

Format options: `c` (current), `c/t` (current/total), `h.v` (horizontal.vertical), `h.v.c`. Control where they show with `show-slide-number: all | print | speaker`.

## Auto-advance

```yaml
format:
  revealjs:
    auto-slide: 5000        # ms per slide
    loop: true              # loop back to start
```

Good for kiosk/unattended playback.

## Slide tone

Audible cue on advance (accessibility / pacing):

```yaml
format:
  revealjs:
    slide-tone: true
```

## Gotchas

- `auto-slide` also pauses on user interaction; press `A` to toggle it live.
- `show-slide-number: print` keeps numbers out of the live talk but in the PDF.
- There is no documented per-slide way to hide the number; `show-slide-number` controls visibility globally by context (`all`/`print`/`speaker`). To suppress it on one slide, hide it with your own CSS targeting that slide.
