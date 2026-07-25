# Code line highlighting and step-through

References:
- https://quarto.org/docs/presentations/revealjs/#line-highlighting

## Line numbers

```yaml
format:
  revealjs:
    code-line-numbers: true
```

## Highlight specific lines

Use the `code-line-numbers` cell option on a code block:

````markdown
```{.python code-line-numbers="2,5"}
import numpy as np
x = np.arange(10)      # highlighted
y = x ** 2
z = y.sum()
print(z)               # highlighted
```
````

Ranges: `"3-5"`. Combine: `"1,3-5"`.

## Step-through (progressive highlighting)

Separate states with `|`; each forward press moves to the next highlight. This pairs with fragment navigation:

````markdown
```{.python code-line-numbers="|1|2-3|5"}
import numpy as np
x = np.arange(10)
y = x ** 2
z = y.sum()
print(z)
```
````

`|1|2-3|5` means: first show all, then highlight line 1, then 2-3, then 5.

## Executable code

For R/Python that runs at render, use `echo`/`eval`/`output` cell options; highlighting works the same on the echoed source.

## Gotchas

- The leading `|` (as in `"|1|..."`) makes the first state "no highlight / all lines," so the reveal starts neutral.
- Line highlighting counts as fragment steps — factor it into slide pacing.
- For hand-built highlights on non-executed pseudo-code, see `content-code-manual.md`.
