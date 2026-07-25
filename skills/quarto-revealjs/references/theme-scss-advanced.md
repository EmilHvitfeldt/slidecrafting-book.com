# Advanced SCSS: maps, functions, @each, @mixin

References:
- https://slidecrafting-book.com/scss
- https://sass-lang.com/documentation

For themes that reuse colors, generate many utility classes, or repeat CSS. Start with `theme-quickstart.md`; come here when plain variables get unwieldy.

## CSS classes and the `.reveal .slide` prefix

Free-form rules go in `scss:rules`. Slide-content selectors need the `.reveal .slide` prefix to beat theme specificity:

```scss
/*-- scss:rules --*/
.reveal .slide a { text-decoration: underline; }
```

Utility text classes, applied inline with `[text]{.blue}` or to a block with `::: {.blue}`:

```scss
/*-- scss:rules --*/
.blue   { color: #219ea7; font-weight: bold; }
.yellow { color: #F4BA02; font-weight: bold; }
```

## Store the palette in a map

```scss
$colors: (
  "red":      #FA5F5C,
  "blue":     #394D85,
  "darkblue": #13234B,
  "yellow":   #FFF7C7,
  "white":    #FEFEFE
);
```

Quote the keys consistently (`"blue"`, not `blue`) — unquoted `yellow` etc. can be read as CSS color keywords.

## Pull values out with a function

```scss
@function theme-color($color) {
  @return map-get($colors, $color);
}

$body-bg:    theme-color("yellow");
$link-color: theme-color("blue");
$body-color: theme-color("darkblue");
```

## Generate classes with `@each` + interpolation

```scss
@each $name, $color in $colors {
  .text-#{$name} { color: $color; }
  .bg-#{$name}   { background-color: $color; }
}
```

Add a color to the map and every class set updates. Nested `@each` builds compound classes (only worth it for tightly-coupled pairs like gradients):

```scss
@each $n1, $c1 in $colors {
  @each $n2, $c2 in $colors {
    span.hl-#{$n1}-#{$n2}, .hl-#{$n1}-#{$n2} > h2 {
      background-image: linear-gradient(90deg, $c1, $c2);
      background-size: 100% 42%;
      background-repeat: no-repeat;
      background-position: 0 85%;
      width: fit-content;
    }
  }
}
```

## Avoid repetition with `@mixin` + `@for`

```scss
@mixin background-full {
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
}

@mixin theme-slide($number) {
  .theme-slide#{$number} {
    &:is(.slide-background) {
      background-image: url('../../../../../assets/slide#{$number}.svg');
      @include background-full;
    }
  }
}

@for $i from 1 through 3 { @include theme-slide($i); }
```

## Gotchas

- Maps aren't valid CSS on their own; they only do work through `map-get`/`@each`.
- Interpolation is `#{...}`; forgetting it means the literal variable name lands in the selector.
- Don't over-generate: skip compound classes like `.hl-green-bold` you'd never combine — make `.hl-green` and `.bold` separately.
