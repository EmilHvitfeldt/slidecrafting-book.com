# Colors

References:
- https://slidecrafting-book.com/colors
- https://quarto.org/docs/presentations/revealjs/themes.html#sass-variables

## Choosing a palette

Think in four roles: **background**, **text**, **highlight** (1-3 colors to draw the eye), **theme** (purely decorative). Aim for 3-6 colors total; be deliberate. Hunt palettes on Pinterest ("Pinterest color palettes" + a mood word like "sea", "pastel"), extract hexes with a picker like ColorSlurp.

## Contrast is the #1 rule

Background, text, and highlight colors must have **high contrast** with each other or the audience can't read the slides. Aim for a contrast ratio of ~12 (10 is acceptable). Check with <https://colourcontrast.cc/> or Coolors' contrast checker.

- Background and text end up quite dark and light as a result.
- Avoid pure black (`#000`) / pure white (`#fff`); they're harsh over time.
- Smaller/finer text needs even more contrast.
- Multiple highlight colors should be colorblind-safe with each other (e.g. avoid red/green pairs). The `prismatic::check_color_blindness()` R function helps.

## Applying colors

Set the three primaries and let derived values follow:

```scss
/*-- scss:defaults --*/
$body-bg:    #01364C;
$body-color: #F7F8F9;
$link-color: #99D9DD;   // also affects the menu button and progress bar
```

Better: name your palette as variables first, so intent is legible and edits are cheap:

```scss
/*-- scss:defaults --*/
$theme-darkblue: #01364C;
$theme-blue:     #99D9DD;
$theme-white:    #F7F8F9;
$theme-yellow:   #F4BA02;

$body-bg:    $theme-darkblue;
$body-color: $theme-white;
$link-color: $theme-blue;
```

Setting `$body-bg`, `$body-color`, `$link-color` auto-derives `$text-muted`, `$selection-bg`, `$border-color`, and more.

## Tweaking with Sass color functions

```scss
$presentation-heading-color: lighten($theme-yellow, 35%);
```

Iterate on the percentage until it pops the right amount.

## The full set

Five variables cover most needs: `$body-bg`, `$body-color`, `$presentation-heading-color`, `$link-color`, `$code-color`. For custom code token colors see `theme-syntax-highlight.md`; for storing a whole palette as a map see `theme-scss-advanced.md`.

## Gotchas

- `$link-color` also drives the hamburger menu and progress bar — pick one that reads on the background.
- Contrast is harder over images; use near-white on dark photos, near-black on light, and consider a text background/outline (`layout-overlay-textbox.md`).
