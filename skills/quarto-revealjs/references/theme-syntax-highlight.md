# Custom code syntax highlighting

References:
- https://slidecrafting-book.com/colors
- https://quarto.org/docs/output-formats/html-code.html#highlighting

## Presets

Pick a built-in scheme in YAML:

```yaml
format:
  revealjs:
    highlight-style: github   # dracula, monokai, nord, solarized, ...
```

## Per-token custom colors

Highlighting uses [skylighting](https://github.com/jgm/skylighting), which tags each token type with a two-letter class. Target them in `scss:rules`. Group tokens that share a color to keep it compact:

```scss
code {
  span.an, span.op, span.sc, span.in,
  span.wa, span.do, span.cv, span.co { color: #5E5E5E; }  // annotations, comments, operators

  span.er, span.bn, span.al, span.pp,
  span.dt, span.fl, span.dv { color: #AD0000; }           // errors, numbers, datatypes

  span.ss, span.st, span.vs, span.ch { color: #20794D; }  // strings
  span.ot, span.cf, span.kw          { color: #003B4F; }  // keywords, control flow
  span.at { color: #657422; }                             // attribute
  span.fu { color: #4758AB; }                             // function
  span.va { color: #111111; }                             // variable
  span.im { color: #00769E; }                             // import
  span.cn { color: #8f5902; }                             // constant
}
```

Full token key: `kw` keyword, `cf` control flow, `ot` other, `st`/`ss`/`vs`/`ch` strings, `fu` function, `va` variable, `dt` datatype, `dv`/`bn`/`fl` numbers, `co`/`cv` comments, `op` operator, `at` attribute, `im` import, `cn` constant, `er` error, `al` alert, `pp` preprocessor, `sc` special char, `an` annotation, `in` info, `wa` warning, `do` documentation.

You can also make tokens italic/underlined, but keep the contrast rules and don't change font sizes (breaks alignment).

## Gotchas

- Changing token font-size misaligns code; only touch color/style.
- Custom token colors still need to contrast with `$code-block-bg`.
- These classes live under `code`; scope broader if you also style inline `code` spans differently.
