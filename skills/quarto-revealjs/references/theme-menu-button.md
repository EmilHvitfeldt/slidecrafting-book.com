# Restyling the slide menu button

References:
- https://slidecrafting-book.com/elements

The hamburger menu button (lower-left) takes its color from `$link-color`. To recolor it independently or swap the icon, override its background image in `scss:rules` — the color is hardcoded into the SVG.

## Recolor via inline SVG

The `fill="..."` inside the SVG sets the color:

```scss
.reveal .slide-menu-button .fa-bars::before {
  background-image: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="rgb(42, 118, 221)" viewBox="0 0 16 16"><path fill-rule="evenodd" d="M2.5 12a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5zm0-4a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5zm0-4a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5z"/></svg>') !important;
}
```

## Use any image

```scss
.reveal .slide-menu-button .fa-bars::before {
  background-image: url('https://.../icon.png') !important;
}
```

## Gotchas

- `!important` is required to override Quarto's default.
- For a simple recolor that matches links, just set `$link-color` and skip this entirely.
