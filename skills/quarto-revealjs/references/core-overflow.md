# Content overflow

References:
- https://quarto.org/docs/presentations/revealjs/#content-overflow

When a slide has too much content, pick one of these rather than letting it spill off-screen.

## Smaller text

```markdown
## Dense slide {.smaller}
```

Shrinks the slide's text a notch. Good first reach.

## Scrollable

```markdown
## Long slide {.scrollable}
```

Adds a vertical scrollbar to the slide instead of overflowing. Useful for long code or tables.

## Code-specific overflow

For code blocks that are too wide or tall:

```yaml
format:
  revealjs:
    code-overflow: wrap     # or "scroll"
```

Code blocks default to a max height of ~500px with their own scroll.

## Gotchas

- `.smaller` and `.scrollable` are per-slide classes on the heading; they can be combined.
- Prefer splitting a crowded slide into two over shrinking text below legibility. The best fix for overflow is usually less content.
- `.scrollable` hides content below the fold during presentation; don't put the punchline there.
