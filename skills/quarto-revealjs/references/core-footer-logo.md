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

Both appear on every slide. `footer` accepts markdown (links, emphasis, inline images).

## Per-slide footer (built in)

The footer has both per-slide behaviors built in; no CSS needed.

Override the text on one slide with a div carrying the `footer` class:

```markdown
## Slide

::: footer
Custom footer for just this slide
:::
```

Remove it on one slide with the `footer` attribute on the heading:

```markdown
## Clean slide {footer="false"}
```

Both are applied by the quarto-support plugin on `slidechanged`, so they only take
effect while presenting. In a printed PDF every slide gets the default footer.

## Per-slide logo (needs CSS)

The logo has no equivalent option. Add a rule keyed off the current slide, then use
the class on the heading:

```scss
.reveal:has(section.present.hide-logo) .slide-logo { display: none; }
```

```markdown
## Clean slide {.hide-logo}
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

The footer is a full-width block, so it can be a bar rather than a line of text:

Long rules below are split into `placement` (does the work) and `looks` (safe to restyle).

```scss
.reveal .footer {
  // placement
  bottom: 0 !important;
  padding: 0.35em 1.5em !important;

  // looks
  background-color: #2a3b4c;
  color: #fdf8f4 !important;
  text-align: left !important;
}
.reveal .slide-menu-button { bottom: 2.5em !important; } // out of the bar
```

## Custom banners (top or side)

The `footer` option gives one strip, at the bottom. For a banner along the top or down
a side, use the `::before` / `::after` pseudo-elements of `.reveal` (reveal.js and Quarto
leave both unused), so no markup is added to the deck. `position: fixed` keeps them out
of the slide scaling; `z-index: 2` matches Quarto's footer and logo.

```scss
.reveal::after {
  content: "Slidecrafting 2026";

  // placement
  display: block;
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 2;

  // looks
  padding: 0.3em 1.5em;
  background-color: #2a3b4c;
  color: #fdf8f4;
  font-size: 16px;
  font-style: normal;
}
// keep titles off the banner, but only where the banner is shown
.reveal .slides > section:not(#title-slide) { box-sizing: border-box; padding-top: 1.5em; }
```

Make room with padding on the slides, never a margin on `.slides`: a margin moves the slide
area instead of shrinking it, pushing the far edge out of view and cutting off long content.
reveal.js leaves slides as `content-box`, so `box-sizing: border-box` is required or the
padding is added to the width and you are back to overflowing.

Hide per slide (and usually on the title slide) exactly like the logo:

```scss
.reveal:has(section#title-slide.present)::after,
.reveal:has(section.present.no-banner)::after { display: none; }
```

Keep the padding and the banner in sync: a slide without the banner but with the padding
is pushed down for nothing (very visible on the vertically centered title slide).

For a side strip, stretch `top`/`bottom` instead, give a `width`, and rotate the text.
`writing-mode: vertical-rl` alone reads top-to-bottom; add `rotate(180deg)` for
bottom-to-top (book-spine direction). Flex places the text along the strip.

```scss
.reveal::before {
  content: "Slidecrafting 2026";

  // placement
  display: flex;
  align-items: center;
  justify-content: flex-end; // top of the strip; `center` for the middle
  position: fixed;
  top: 0;
  bottom: 0;
  left: 0;
  z-index: 2;
  width: 2em;
  writing-mode: vertical-rl;
  transform: rotate(180deg);

  // looks
  background-color: #2a3b4c;
  color: #fdf8f4;
  font-size: 16px;
  font-style: normal;
}
.reveal .slides > section { box-sizing: border-box; padding-left: 2em; }
.reveal .slide-menu-button { left: 2.5em !important; }
```

Limits: two pseudo-elements means two banners, and `content` is fixed for the whole deck.

### Per-slide banner text

To support `::: banner-top` overrides, the default banner and the div must share a
coordinate system. reveal.js puts a `transform` on `.slides`, which makes it the reference
for any `fixed` descendant, so a div on a slide can never be positioned against the window
the way `.reveal::after` is. Move the default banner into the slide box instead: hang it off
`.slides`, use `position: absolute`, and share the declarations via a placeholder selector.

Inside the slide box `top: 0` stops short of the screen edge (reveal.js adds a margin and
letterboxes the rest). Reach back out with the variables reveal.js publishes: `--slide-scale`,
`--slide-width`, `--slide-height`. These are lengths, not percentages, so they mean the same
thing to the div and to the pseudo-element.

```scss
$banner-bleed-x: calc((100vw / var(--slide-scale) - var(--slide-width)) / -2);
$banner-bleed-y: calc((100vh / var(--slide-scale) - var(--slide-height)) / -2);

%banner-top {
  // placement
  display: block;
  position: absolute;
  top: $banner-bleed-y;
  left: $banner-bleed-x;
  right: $banner-bleed-x;
  z-index: 2;
  line-height: 1.3; // matched by the `> *` rule below

  // looks
  padding: 0.3em 1.5em;
  background-color: #2a3b4c;
  color: #fdf8f4;
  font-size: 0.45em; // scales with the deck; use px only in window space
  font-style: normal;
}

.reveal .slides::after { @extend %banner-top; content: "Slidecrafting 2026"; }

.reveal .banner-top {
  @extend %banner-top;
  // pandoc wraps div text in <p>, which brings margins and the theme's line height
  // that the `content` string never gets; without this the bar changes height per slide
  > * { margin-top: 0; margin-bottom: 0; line-height: inherit; }
}

// default banner steps aside for the title slide and for slides with their own
.reveal .slides:has(section#title-slide.present)::after,
.reveal .slides:has(section.present .banner-top)::after { display: none; }

// padding, not margin: absolute offsets start at the padding edge, so the banner stays put
.reveal .slides > section:not(#title-slide) { box-sizing: border-box; padding-top: 1em; }
```

```markdown
## A banner of its own

::: banner-top
Text for this slide only
:::
```

Difference from the window-space version: a banner in the slide box scales with the deck, so
size it in `em`. Window-space banners and Quarto's `.footer` do not scale (the footer stays
18px in an embedded frame and on a projector).

## Gotchas

- The logo sits bottom-right by default and can collide with corner content (menu button bottom-left, slide number top-right when a logo is present); restyle or hide it there.
- Any banner along an edge that content also uses needs matching `padding` on `.reveal .slides > section` (plus `box-sizing: border-box`), scoped to the slides that actually show the banner, and the menu button moved if it is in the way. A margin on `.slides` shifts the slide area rather than shrinking it and cuts off content at the far edge.
- When repositioning, reset the unused offsets to `auto` (e.g. set `top`/`left`, reset `bottom`/`right`).
- Footer/logo render above slide content but below overlays; heavy absolute-positioned content may overlap them.
- Relative image paths in theme SCSS resolve against the generated stylesheet in `libs/revealjs/dist/theme/`, not the `.qmd`. Prefix with `../../../../../` (adjust the count for your folder structure), the same pattern used for `@font-face` and `background-image`. A wrong count gives a broken image icon.
