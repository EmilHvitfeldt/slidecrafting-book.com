# Multi-column layout

References:
- https://slidecrafting-book.com/layout
- https://quarto.org/docs/presentations/revealjs/#multiple-columns

Split slide content side by side. Great for comparisons.

```markdown
::: {.columns}

::: {.column width="40%"}
Left column
:::

::: {.column width="60%"}
Right column
:::

:::
```

## Variations

Each `.column` is a div, so style it directly:

```markdown
::: {.column width="50%" style="text-align: right;"}
Right column
:::
```

More than two columns (rarely go past four):

```markdown
::: {.columns}
::: {.column width="25%"}1st:::
::: {.column width="25%"}2nd:::
::: {.column width="25%"}3rd:::
::: {.column width="25%"}4th:::
:::
```

An empty column is a quick spacer to push content around:

```markdown
::: {.columns}
::: {.column width="30%"}
:::
::: {.column width="70%"}
Only right side
:::
:::
```

## Gotchas

- `.column` must be nested inside `.columns`; each needs its own `:::` lines.
- Charts inside columns need per-slide sizing (usually `fig-asp`) — see `content-plot-sizing.md`.
- Widths should roughly sum to 100%; leftover space is distributed.
