# Extension: codewindow (IDE-window code blocks)

References:
- https://github.com/EmilHvitfeldt/quarto-revealjs-codewindow
- https://slidecrafting-book.com/codewindow

Wraps code blocks in a styled window frame with a file tab and language icon, like a modern editor.

## Install

```bash
quarto add emilhvitfeldt/quarto-revealjs-codewindow
```

```yaml
format: revealjs
revealjs-plugins:
  - codewindow
```

## Use

Wrap a code chunk in `::: {.codewindow}`; plain text above the chunk becomes the file-tab label:

````markdown
::: {.codewindow .r}
analysis.R

```r
mtcars |>
  dplyr::group_by(cyl) |>
  dplyr::summarize(mean_mpg = mean(mpg))
```
:::
````

Add a language class for the tab icon: `.r`, `.py`, `.js`, `.quarto`, `.html`, `.css`, `.sass`, `.julia`. Control width with `width`:

```markdown
::: {.codewindow .r width="80%"}
```

## Gotchas

- The file-tab label is the plain text line immediately inside the div, before the fence.
- Language icon comes from the class, not the code fence's language.
