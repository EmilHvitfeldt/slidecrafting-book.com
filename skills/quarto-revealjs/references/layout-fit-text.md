# Big text with r-fit-text

References:
- https://slidecrafting-book.com/layout
- https://quarto.org/docs/presentations/revealjs/advanced.html#fit-text

`r-fit-text` scales text to fill the slide's horizontal space.

```markdown
::: {.r-fit-text}
Big Text
:::
```

Center it vertically too by combining with the `.center` slide class:

```markdown
## {.center}

::: {.r-fit-text}
This fits perfectly!
:::
```

## Multiple lines

One `r-fit-text` block sizes all its lines to the same (smaller) size set by the longest line:

```markdown
::: {.r-fit-text}
This fits perfectly!

On two lines
:::
```

For each line to independently fill the width, use one block per line:

```markdown
::: {.r-fit-text}
This fits perfectly!
:::

::: {.r-fit-text}
On two lines
:::
```

## Gotchas

- Within a single block, all text gets the same size (bounded by the longest line) — split into blocks for per-line scaling.
