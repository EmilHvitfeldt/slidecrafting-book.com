# Footer and logo

References:
- https://quarto.org/docs/presentations/revealjs/#footer-logo

## Global footer and logo

```yaml
format:
  revealjs:
    footer: "My conference 2026"
    logo: logo.png
```

Both appear on every slide.

## Per-slide overrides

Remove the footer or logo on a single slide with classes on the heading:

```markdown
## Clean slide {.hide-footer .hide-logo}
```

Override footer text on one slide:

```markdown
## Slide

::: footer
Custom footer for just this slide
:::
```

## Styling

- Logo size/position: target `.reveal .slide-logo` in `scss:rules`.
- Footer text: target `.reveal .footer`.

```scss
.reveal .slide-logo { height: 60px; }
.reveal .footer { color: #888; font-size: 0.6em; }
```

## Gotchas

- The logo sits top-right by default and can collide with corner content; restyle or hide it there.
- Footer/logo render above slide content but below overlays; heavy absolute-positioned content may overlap them.
