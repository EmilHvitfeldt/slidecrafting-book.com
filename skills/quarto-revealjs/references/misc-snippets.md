# VS Code / Positron Sass-variable snippets

References:
- https://slidecrafting-book.com/miscellaneous
- https://code.visualstudio.com/docs/editing/userdefinedsnippets

The reveal.js Sass variables are hard to remember. Project-scoped editor snippets surface them (with default values) as you type `$` inside `.scss` files.

Create `.vscode/<name>.code-snippets` at the project root. Each snippet triggers on the variable name and inserts the assignment with its default as a placeholder:

```json
{
  "colors - background": {
    "scope": "scss",
    "prefix": "$body-bg",
    "body": ["\\$body-bg: ${1:#fff};"]
  },
  "headings - h1 font size": {
    "scope": "scss",
    "prefix": "$presentation-h1-font-size",
    "body": ["\\$presentation-h1-font-size: ${1:2.5em};"]
  }
}
```

The book's miscellaneous chapter ships a full snippets file covering every compatible reveal.js Sass variable (colors, fonts, headings, code blocks, layout, callouts) — copy it wholesale from <https://slidecrafting-book.com/miscellaneous>.

## Gotchas

- Escape the leading `$` as `\\$` in JSON snippet bodies.
- `"scope": "scss"` limits them to SCSS files; they trigger once you type `$`.
- Keep them project-scoped (`.vscode/`) since they're presentation-specific.
