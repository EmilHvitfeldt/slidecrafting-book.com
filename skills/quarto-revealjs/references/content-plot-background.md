# Transparent plot backgrounds

References:
- https://slidecrafting-book.com/elements

Most plotting libraries default to a white background that sticks out on a non-white slide. Make the plot background transparent (`#FFFFFF00`) so it blends into any slide background, solid or not.

## base R and ggplot2

No code change — set chunk options:

````markdown
```{r, dev = "png", dev.args=list(bg="transparent")}
library(ggplot2)
ggplot(mtcars, aes(disp, mpg, color = factor(am))) +
  geom_point() +
  theme_minimal()
```
````

Or globally in YAML:

```yaml
knitr:
  opts_chunk:
    dev: png
    dev.args: { bg: "transparent" }
```

## matplotlib

Set both the axes and figure facecolor:

```python
fig = plt.figure()
plt.axes().set_facecolor("#FFFFFF00")   # inside the plotting area
plt.scatter(x, y, c=colors)
fig.patch.set_facecolor("#FFFFFF00")    # outside the plotting area
```

## seaborn

```python
sns.set_style(rc={'axes.facecolor':'#FFFFFF00',
                  'figure.facecolor':'#FFFFFF00'})
```

## Gotchas

- Prefer transparent (`#FFFFFF00`) over matching the slide color: one value, works across differently-colored or non-solid backgrounds.
- Transparency needs a format that supports alpha (`png`, `svg`), not `jpeg`.
- For auto-animate figures that live inside a colored element, theme the plot panel to that element's color instead (`animation-auto-animate.md`).
