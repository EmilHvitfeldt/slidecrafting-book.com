# Hand-styled / manually highlighted code

References:
- https://slidecrafting-book.com/manual-code

When you want highlight control beyond automatic syntax highlighting, render code as plain text and style parts by hand with classes and fragments.

## A monospace text block

```scss
/*-- scss:rules --*/
.mono {
  font-family: monospace;
  font-size: 0.9em;
}
```

Put the code in a fenced div with `.mono`. Use `\ ` for leading spaces; end each line with two trailing spaces to force line breaks:

```markdown
::: {.mono}
library(ggplot2)
mtcars |> 
\ \ ggplot(aes(mpg, disp)) + 
\ \ geom_point() + 
\ \ geom_smooth(method = "lm", formula = "y ~ x")
:::
```

## Color pieces by hand

Inline style or a class colors a token:

```markdown
library([ggplot2]{style="color:purple;"})
```

Reuse theme classes here (`content-code-manual` pairs well with `theme-scss-advanced.md` color classes).

## Incremental highlight with fragments

Add `.fragment` + a `.highlight-*` class to reveal highlights one press at a time:

```markdown
geom_smooth([method = "lm"]{.fragment .highlight-red}, [formula = "y ~ x"]{.fragment .highlight-blue})
```

This highlights `method = "lm"` in red on the first advance, then `formula = "y ~ x"` in blue.

## Gotchas

- Leading whitespace needs `\ ` (backslash-space); ordinary spaces collapse.
- Two trailing spaces = a newline in Markdown; without them lines merge.
- This bypasses real syntax highlighting — only worth it when you need precise, animated emphasis. For executed code, prefer `content-code-highlighting.md`.
