# Slide syntax, lists, callouts, tabsets

References:
- https://quarto.org/docs/presentations/revealjs/
- https://quarto.org/docs/authoring/markdown-basics.html

## Slides from headings

- `## Title` starts a content slide.
- `# Title` starts a section-divider slide.
- Content is standard Markdown between headings.

Slide-level attributes live on the heading in `{}`:

```markdown
## My slide {.center background-color="#1C1C2B"}
```

## Fenced divs and spans

Attach classes/attributes to a block with a fenced div, to a run of text with a span:

```markdown
::: {.callout-note}
A block with a class.
:::

This is [important]{.highlight} text.
```

## Incremental lists

Reveal list items one at a time:

```markdown
::: {.incremental}
- first
- second
- third
:::
```

Or flip the default globally with `incremental: true` in YAML and use `::: {.nonincremental}` to opt individual lists out. To style the currently-revealed item, see `animation-fragments.md` (`.highlight-last`).

## Callouts

```markdown
::: {.callout-tip}
## Optional title
Body text.
:::
```

Types: `note`, `tip`, `important`, `caution`, `warning`. Colors are themeable via `$callout-color-*` Sass variables (see `misc-snippets.md`).

## Tabsets

```markdown
::: {.panel-tabset}
## Tab A
Content A

## Tab B
Content B
:::
```

Advancing tabs with fragments is possible; see `animation-fragments.md`.

## Columns

Quick form (full detail in `layout-columns.md`):

```markdown
::: {.columns}
::: {.column width="40%"}
Left
:::
::: {.column width="60%"}
Right
:::
:::
```

## Content overflow

- `## Title {.smaller}` shrinks text on a crowded slide.
- `## Title {.scrollable}` adds a scrollbar instead of overflowing.

## Gotchas

- Fenced divs need opening and closing `:::` on their own lines.
- `.column` divs must be nested inside a `.columns` div.
- Don't hand-position with absolute placement when a column or default flow will do; reach for `layout-absolute.md` only when you need it.
