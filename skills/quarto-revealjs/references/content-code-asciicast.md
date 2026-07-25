# Animated terminal recordings (asciicast)

References:
- https://slidecrafting-book.com/asciicast
- https://asciicast.r-lib.org/

R console output with ANSI colors/styling (tidyverse/tidymodels startup, cli messages) loses its color in normal slides. The [asciicast](https://github.com/r-lib/asciicast) R package renders it as a colorized [asciinema](https://asciinema.org/) recording.

## Enable the engine

Put this chunk at the top of the document:

````markdown
```{r}
asciicast::init_knitr_engine()
```
````

Then change a chunk's engine from `r` to `asciicast`:

````markdown
```{asciicast}
library(tidymodels)
```
````

## Key arguments

`init_knitr_engine(same_process, echo, echo_input, ...)`:

- `same_process` (default `TRUE`): all asciicast chunks share one R process. Set `FALSE` to show once-per-session output (like package startup) fresh each chunk.
- `echo` (default `FALSE`) / `echo_input` (default `TRUE`): control whether code appears in the cast. Defaults show the code inside the terminal cast. To instead show code as a normal Quarto block and only the output as a cast:

````markdown
```{r}
asciicast::init_knitr_engine(echo = TRUE, echo_input = FALSE)
```
````

## Theming

```r
options(asciicast_theme = "solarized-light")
```

Built-ins: `asciinema`, `tango`, `solarized-dark`, `solarized-light`, `seti`, `monokai`, `github-light`, `github-dark`, `pkgdown`, `readme`. For a seamless blend, pass a custom theme list (modify an [existing one](https://github.com/r-lib/asciicast/blob/main/R/svg.R)) and set `background` to your slide's background color:

```r
options(asciicast_theme = list(
  # ...token colors as col2rgb() vectors...
  background = c(grDevices::col2rgb("#ffffff")),
  text       = c(grDevices::col2rgb("#657b83"))
))
```

## Gotchas

- Requires R at render time.
- Asciicast output fills the slide width by default, but `self-contained`/`embed-resources: true` can break that sizing — it looks best without.
- Setting both `echo` and `echo_input` to `TRUE` duplicates the code; use one, or both `FALSE` for output only.
