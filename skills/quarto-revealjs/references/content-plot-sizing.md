# Sizing figures for slides

References:
- https://slidecrafting-book.com/elements
- https://quarto.org/docs/presentations/revealjs/advanced.html#stretch

Two size concepts: the file on disk (`out-width`/`out-height`) and the drawing dimensions (`fig-width`/`fig-height`/`fig-asp`). Defaults tend to make on-plot text too small for audiences.

## auto-stretch

Slides default to `auto-stretch: true`, shrinking figures to fit. Disable globally or per slide:

```yaml
format:
  revealjs:
    auto-stretch: false
```

```markdown
## Slide {.nostretch}
```

The difference shows most when a figure shares a slide with other content: `auto-stretch` shrinks the figure to make room; `.nostretch` shows natural size (may overflow).

## fig-width / fig-height (the ones you'll use most)

Defaults are roughly `fig-width: 9`, `fig-height: 5`, which renders small text. Reduce them to enlarge on-plot text relative to the plot:

````markdown
```{r}
#| fig-width: 6
#| fig-height: 3.5
```
````

## fig-asp (fix the ratio, tune one dimension)

Set the height/width ratio once, then adjust only `fig-width`:

````markdown
```{r}
#| fig-asp: 0.5
#| fig-width: 7
```
````

Too small? raise `fig-width`, keep `fig-asp`. No decimal juggling.

## out-width / out-height

Control the on-disk/rendered file size — use when you want a figure that deliberately doesn't fill the slide:

````markdown
```{r}
#| out-width: 6in
#| out-height: 3.5in
```
````

## fig-align and fig-dpi

- `fig-align`: `left` / `center` / `right` (figures that don't fill the slide default to left).
- `fig-dpi`: raise if a chart looks blurry; costs file size, so only when needed.

## In columns

Even with a global setting, columns need per-slide tuning — usually a smaller `fig-asp` so the figure fits the narrower width.

## Gotchas

- `fig-*` controls the drawing; `out-*` controls the displayed/file size. They're different levers.
- Optimal numbers shift with titles, other slide content, fonts, and aspect ratio — expect per-slide adjustment.
- Bumping `fig-dpi` inflates file size; reach for it only to fix visible blur.
