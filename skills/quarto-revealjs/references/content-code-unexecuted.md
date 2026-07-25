# Showing Quarto code literally

References:
- https://slidecrafting-book.com/elements
- https://quarto.org/docs/computations/execution-options.html#unexecuted-blocks

To display Quarto/knitr code verbatim (teaching how to write Quarto, without running it), you need unexecuted blocks.

Wrap the example in a `markdown` fence that uses **more backticks** than anything inside, and add an **extra layer of curly braces** so the inner block isn't executed (double `{{python}}` for one level; triple `{{{python}}}` when the block is itself shown inside another displayed fence, as below):

`````markdown
```` markdown
This is **Quarto** code

```{{{python}}}
1 + 1
```
````
`````

The `{{{python}}}` renders as literal `{python}` instead of running. The outer ```` ```` ```` fence must have more ticks than the inner ``` ``` ``` fence.

## Gotchas

- Backtick count matters: outer fence needs strictly more ticks than any inner fence.
- Each extra `{`/`}` layer defers execution one more render pass; two braces `{{python}}` for one level, three `{{{python}}}` when the surrounding doc is itself processed again.
- This is a Quarto authoring trick, not a reveal.js feature — it works in any Quarto format.
