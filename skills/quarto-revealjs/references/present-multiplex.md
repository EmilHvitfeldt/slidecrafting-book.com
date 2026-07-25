# Multiplex (audience follow-along)

References:
- https://quarto.org/docs/presentations/revealjs/presenting.html#multiplex

Multiplex lets the audience follow your navigation on their own devices while you control the master.

```yaml
format:
  revealjs:
    multiplex: true
```

Rendering produces two files: your presenter copy (with a secret token) and an audience copy (`-speaker`/read-only split). Share the audience URL; navigate from the presenter copy and everyone's slides advance in sync.

## Gotchas

- Uses a public multiplex socket server by default; fine for public talks, not confidential ones.
- Only navigation syncs — not chalkboard drawings or local interaction.
- Keep the presenter (token-bearing) file private; anyone with it can drive.
