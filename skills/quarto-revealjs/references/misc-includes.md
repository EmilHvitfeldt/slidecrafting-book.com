# Reusing content with includes

References:
- https://slidecrafting-book.com/miscellaneous
- https://quarto.org/docs/authoring/includes.html

Pull shared content into multiple decks with the include shortcode:

```markdown
{{< include _content.qmd >}}
```

It splices the file's content in place (copy-paste style) before rendering. Handy for intro/outro slides, a standard disclaimer, or a shared appendix across several talks. Works with `.qmd`, and also HTML and SVG files.

## Gotchas

- Convention: prefix included partials with `_` (e.g. `_intro.qmd`) so Quarto doesn't render them as standalone outputs.
- Includes happen before render, so the included file shares the parent's YAML/engine context — don't put a competing YAML header in the partial.
