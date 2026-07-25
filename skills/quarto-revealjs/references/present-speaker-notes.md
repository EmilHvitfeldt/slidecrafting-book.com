# Speaker notes

References:
- https://quarto.org/docs/presentations/revealjs/presenting.html#speaker-notes

Add notes to a slide with a `.notes` div:

```markdown
## Slide

Visible content.

::: {.notes}
Only I see this in speaker view. Remember to mention the caveat.
:::
```

Notes appear in speaker view (press `S`) alongside the current slide, next slide, and timer. See `present-speaker-view.md`.

## Gotchas

- Notes are still present in the HTML source (not secret); don't put sensitive material there.
- One `.notes` div per slide; place it anywhere in the slide's content.
