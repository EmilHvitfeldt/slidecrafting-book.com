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

There is no built-in option to remove the logo or footer on a single slide.
Add a CSS rule keyed off the current slide, then use the class on the heading:

```scss
.reveal:has(section.present.hide-logo) .slide-logo { display: none; }
.reveal:has(section.present.hide-footer) .footer { display: none; }
```

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

## Second logo (co-branding)

`logo` takes one file, but `footer` accepts HTML:

```yaml
logo: logo.svg
footer: "<img src='logo-conf.svg' alt='CONF'> &nbsp; My conference 2026"
```

Size it with `.reveal .footer img { height: 1.6rem; vertical-align: middle; }`.
This is also the only way to make a logo clickable (wrap it in `<a>`); the `logo` option renders a bare `<img>`.

## Different treatment on the title slide

The title slide has the id `title-slide` and no `.title-slide` class:

```scss
.reveal:has(section#title-slide.present) .slide-logo {
  max-height: 4rem !important;
  top: 12% !important;
  left: 50% !important;
  bottom: auto !important;
  right: auto !important;
  transform: translateX(-50%);
}
```

## Contrast on dark or photo slides

- Swap files: `content: url('../../../../../logo-light.svg')` (see the path gotcha below).
- Monochrome logos only: `filter: invert(1)`. A colored logo comes out in its complementary color.
- Over photos: give the logo a plate with `background-color` + `padding` + `border-radius` + `box-sizing: content-box` + `filter: drop-shadow(...)`.

## Styling

- Logo size/position: target `.reveal .slide-logo` in `scss:rules`. Size with `max-height`, not `height`.
- Footer text: target `.reveal .footer`.
- Quarto's `footer.css` loads after the theme, so these rules need `!important`.

```scss
.reveal .slide-logo { max-height: 5rem !important; }
.reveal .footer { color: #888; font-size: 0.6em; }
```

## Gotchas

- The logo sits bottom-right by default and can collide with corner content (menu button bottom-left, slide number top-right when a logo is present); restyle or hide it there.
- When repositioning, reset the unused offsets to `auto` (e.g. set `top`/`left`, reset `bottom`/`right`).
- Footer/logo render above slide content but below overlays; heavy absolute-positioned content may overlap them.
- Relative image paths in theme SCSS resolve against the generated stylesheet in `libs/revealjs/dist/theme/`, not the `.qmd`. Prefix with `../../../../../` (adjust the count for your folder structure), the same pattern used for `@font-face` and `background-image`. A wrong count gives a broken image icon.
