# 7  Elements

## 7.1 Style menu button

The menu button you see in the lower left-hand side of the slide. Styling it can be done by setting the `$link-color` sass variable. If you want a different icon, or have it colored differently than `$link-color` you need to specify it directly as the color [is hardcoded into the svg](https://github.com/quarto-dev/quarto-cli/blob/13c916d041b2f83c20855fd24c7bd68d07720981/src/resources/formats/revealjs/quarto.scss#L505). The icon is specified as the background image of `.reveal .slide-menu-button .fa-bars::before`.

``` scss
.reveal .slide-menu-button .fa-bars::before {
background-image: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="rgb(42, 118, 221)" class="bi bi-list" viewBox="0 0 16 16"><path fill-rule="evenodd" d="M2.5 12a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5zm0-4a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5zm0-4a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5z"/></svg>') !important;
}
```

The color is specified by the `fill="rgb(42, 118, 221)"` part of the svg. But since this is an image, we can use whatever image we want.

``` scss
.reveal .slide-menu-button .fa-bars::before {
background-image: url('https://cdn-icons-png.flaticon.com/512/2163/2163350.png') !important;
}
```

Slide showing a custom hamburger menu icon: the default three-bar icon is replaced with a custom image via CSS background-image on `.reveal .slide-menu-button .fa-bars::before`.

[qmd](examples/styling/tip-2.qmd) [scss](examples/styling/tip-2.scss)

## 7.2 Working with the logo

There are many reasons why you would want to have a logo on your slides. Quarto has a [`logo` option](https://quarto.org/docs/presentations/revealjs/#footer-logo) for exactly that.

``` yaml
format:
  revealjs:
    logo: logo.svg
```

The logo is placed in the lower right-hand corner, and it is repeated on every slide.

Slide with a logo placed in the lower right-hand corner using the `logo` option.

[qmd](examples/elements/logo-default.qmd)

If you want to modify the logo beyond this, we will have to use SCSS to do it.

One thing to know before you start writing rules against it. Quarto styles the logo in a stylesheet that is loaded *after* your theme, so a rule with the same specificity as Quarto’s will lose. The fix is `!important`, which is why it shows up throughout this section.

### 7.2.1 Moving it around

The default position comes from `bottom` and `right`. We can specify the position with `top`, `left`, `bottom`, and `right`. To move the logo somewhere else, set the two properties you want, and reset the two you don’t want to `auto`.

``` scss
.reveal .slide-logo {
  top: 12px !important;
  left: 16px !important;
  bottom: auto !important;
  right: auto !important;
}
```

Slide with the logo moved to the upper left-hand corner by setting `top` and `left` and resetting `bottom` and `right` to `auto`.

[qmd](examples/elements/logo-position.qmd) [scss](examples/elements/logo-position.scss)

Notice that the logo now sits right on top of the slide title. If you wanted to keep the logo there, you will need to modify the styling of the headers and body to not take up space there.

### 7.2.2 Sizing it

The size is set with `max-height` rather than `height`, since `height` is already used to scale the logo against the slide. Give the height and let the width follow along.

``` scss
.reveal .slide-logo {
  max-height: 5rem !important;
  bottom: 20px !important;
  right: 20px !important;
}
```

Bumping the height means the logo takes up more room in the corner, so it is worth revisiting the offsets at the same time.

Slide with a logo enlarged to 5rem tall using `max-height`, with the corner offsets adjusted to match.

[qmd](examples/elements/logo-size.qmd) [scss](examples/elements/logo-size.scss)

Quarto shrinks the logo on narrow screens with a media query. Because we used `!important` our size wins there as well, which is what I want most of the time. If you would rather keep a smaller logo on small screens, repeat the rule inside `@media screen and (max-width: 800px)` with a smaller `max-height`.

### 7.2.3 Hiding it

One of the interesting things about the logo is that it isn’t tied to any one of the slides. It sits as its own element on top of the slide deck itself. This means that it is a little harder to modify it on a slide to slide basis. Not impossible, just harder.

A very common thing one might want is to be able to turn off the logo for specific slides. The following is the SCSS needed to make that happen.

``` scss
.reveal:has(section.present.hide-logo) .slide-logo {
  display: none;
}
```

With that rule in your theme, adding `{.hide-logo}` to a slide heading removes the logo from that slide only.

    ## No logo here {.hide-logo}

Three-slide deck where the middle slide uses the `.hide-logo` class to remove the logo, which returns on the following slide.

[qmd](examples/elements/logo-hide.qmd) [scss](examples/elements/logo-hide.scss)

### 7.2.4 A bigger logo on the title slide

The above code works for normal slides, but the title slide is different. If you want to modify it then we need to do something more. Instead of just hiding it we will instead show how we can move the whole logo around just for the title slide.

``` scss
.reveal:has(section#title-slide.present) .slide-logo {
  max-height: 4rem !important;
  top: 12% !important;
  left: 50% !important;
  bottom: auto !important;
  right: auto !important;
  transform: translateX(-50%);
}
```

Deck where the logo is centered above the title on the title slide at a slightly larger size, then returns to its small corner position on the following slide.

[qmd](examples/elements/logo-title.qmd) [scss](examples/elements/logo-title.scss)

### 7.2.5 Keeping it visible on dark and busy slides

Having the same logo on every single slide can be hard, since depending on the background it might blend in too well on some slides. We can fix that by creating a CSS class that specifies an alternative.

If you have a light version of the logo as a separate file, you can swap the image out with `content`. If the slide has `{.dark}` then the light logo will be used.

``` scss
.reveal:has(section.present.dark) .slide-logo {
  content: url('../../../../../logo-light.svg');
}
```

The `../../../../../` is the same ugliness we ran into when [embedding a font](fonts.llms.md#embedding-fonts), and for the same reason. Paths are resolved against the generated stylesheet rather than against your `.qmd` file, so you may have to add or remove `../` for your folder structure. Getting the count wrong leaves you with a broken image icon instead of a logo.

Three-slide deck where the middle dark slide swaps in a light version of the logo using `content: url()`.

[qmd](examples/elements/logo-swap.qmd) [scss](examples/elements/logo-swap.scss)

If your logo is monochrome you don’t need a second file at all, `invert()` will do it.

``` scss
.reveal:has(section.present.inverted) .slide-logo {
  filter: invert(1);
}
```

Neither approach helps on top of a photo, since there is no single color to fit in with. What works there is giving the logo its own plate to sit on.

``` scss
.reveal:has(section.present.plate) .slide-logo {
  background-color: #fdf8f4;
  padding: 4px 10px;
  border-radius: 8px;
  box-sizing: content-box;
  filter: drop-shadow(0 2px 6px rgba(0, 0, 0, 0.4));
}
```

The `box-sizing: content-box` is there so the padding is added around the logo instead of eating into it, and the shadow lifts the plate off the image.

Deck showing a monochrome logo inverted with `filter: invert(1)` on a dark slide, and placed on a light rounded plate with a drop shadow on a slide with a background photo.

[qmd](examples/elements/logo-contrast.qmd) [scss](examples/elements/logo-contrast.scss)

Photo by [Galen Crout](https://unsplash.com/@galen_crout?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash) on [Unsplash](https://unsplash.com/photos/person-on-top-of-mountain-during-daytime-fItRJ7AHak8?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash)

## 7.3 Working with the footer

Another element that you will often use is the footer, it comes from the [`footer` option](https://quarto.org/docs/presentations/revealjs/#footer-logo).

``` yaml
format:
  revealjs:
    footer: "Slidecrafting 2026 / [slidecrafting.com](https://slidecrafting.com)"
```

You can put most anything markdown inside of it, and it will appear at the botton of the page and centered.

Slide with a centered footer along the bottom edge using the `footer` option.

[qmd](examples/elements/footer-default.qmd)

### 7.3.1 Changing it on a single slide

you can either set it globally for the whole slidedeck as we saw above. Or you can set it on a slide by slide basis with the `footer` div as seen below.

    ## A footer of its own

    ::: footer
    Photo by [Galen Crout](https://unsplash.com/@galen_crout) on [Unsplash](https://unsplash.com)
    :::

If you have a global footer set using the yaml, then you can remove it by setting `footer` to `false`

    ## No footer at all {footer="false"}

Four-slide deck where the second slide replaces the footer text with its own, the third turns the footer off with `footer="false"`, and the fourth gets the default footer back.

[qmd](examples/elements/footer-slide.qmd)

### 7.3.2 Styling it

We can also apply some styling to the footer itself. This will give us 2 things. First it will style the text and content such as links for us. but we can also set a new background for the footer, giving it its own little area to live in.

Styling happens on `.reveal .footer`, and the same warning from the logo applies: Quarto’s rules load after your theme, so anything you set that Quarto also sets needs `!important`.

``` scss
.reveal .footer {
  // placement, this is what makes it a bar
  bottom: 0 !important;
  padding: 0.35em 1.5em !important;

  // looks, change freely
  background-color: #2a3b4c;
  color: #fdf8f4 !important;
  font-size: 16px !important;
  text-align: left !important;

  a {
    color: #f0b429 !important;
  }
}

.reveal .slide-menu-button {
  bottom: 2.5em !important;
}
```

That last rule is the part that is easy to forget. The menu button lives in the same corner, so growing the footer means moving the button up out of the way.

Slide where the footer is styled as a full-width dark bar along the bottom edge, with the menu button moved up above it.

[qmd](examples/elements/footer-style.qmd) [scss](examples/elements/footer-style.scss)

### 7.3.3 Rolling your own

The footer gives us some ideas that can be expanded a bit further. It is a bar that holds content along the bottom of the slides. We can create a similar banner along the top of the slides, or the side of them.

#### 7.3.3.1 A banner along the top

Set the `content` to the text you want, then position it like the footer. `position: fixed` keeps it out of the slide scaling, and `z-index: 2` matches what Quarto uses for the footer and logo.

``` scss
.reveal::after {
  content: "Slidecrafting 2026";

  // placement, this is what puts the banner along the top
  display: block;
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 2;

  // looks, change freely
  padding: 0.3em 1.5em;
  background-color: #2a3b4c;
  color: #fdf8f4;
  font-size: 16px;
  font-style: normal;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.reveal .slides > section:not(#title-slide) {
  box-sizing: border-box;
  padding-top: 1.5em;
}
```

While this next part isn’t strictly needed, it makes it so our banner doesn’t appear on the title slide, or with any slides that add the `{.no-banner}` class.

``` scss
.reveal:has(section#title-slide.present)::after,
.reveal:has(section.present.no-banner)::after {
  display: none;
}
```

Deck with a custom banner along the top generated in SCSS, absent on the title slide and on a slide marked with the `.no-banner` class.

[qmd](examples/elements/banner-top.qmd) [scss](examples/elements/banner-top.scss)

#### 7.3.3.2 A banner down the side

We can do the same type of tricks to have a banner that appears on the side of the slide. Here we need to do a couple more things to make sure the text is rotated correctly, and that the content of the slides are shifted correctly as well.

``` scss
.reveal::before {
  content: "Slidecrafting 2026";

  // placement, this is what makes the strip and turns the text
  display: flex;
  align-items: center;
  justify-content: flex-end;
  position: fixed;
  top: 0;
  bottom: 0;
  left: 0;
  z-index: 2;
  width: 2em;
  writing-mode: vertical-rl;
  transform: rotate(180deg);

  // looks, change freely
  padding-bottom: 1.5em;
  background-color: #2a3b4c;
  color: #fdf8f4;
  font-size: 16px;
  font-style: normal;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.reveal .slides > section {
  box-sizing: border-box;
  padding-left: 2em;
}

.reveal .slide-menu-button {
  left: 2.5em !important;
}
```

Deck with a custom banner running down the left-hand side, with the text rotated using `writing-mode` and the slide content shifted over to make room.

[qmd](examples/elements/banner-side.qmd) [scss](examples/elements/banner-side.scss)

#### 7.3.3.3 Changing the text per slide

What we have shown so far is very nice, but it only let us set new banners globally for the whole slidedeck. But what if we wanted to do something on a per-slide basis like with the footer?

    ::: footer
    Custom footer for just this slide
    :::

We can make it happen, but it is a little more involved.

``` scss
$banner-bleed-x: calc((100vw / var(--slide-scale) - var(--slide-width)) / -2);
$banner-bleed-y: calc((100vh / var(--slide-scale) - var(--slide-height)) / -2);

%banner-top {
  // placement, this is what puts the banner along the top and out to the edges
  display: block;
  position: absolute;
  top: $banner-bleed-y;
  left: $banner-bleed-x;
  right: $banner-bleed-x;
  z-index: 2;
  line-height: 1.3; // matched by the `> *` rule below

  // looks, change freely
  padding: 0.3em 1.5em;
  background-color: #2a3b4c;
  color: #fdf8f4;
  font-size: 0.45em;
  font-style: normal;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.reveal .slides::after {
  @extend %banner-top;
  content: "Slidecrafting 2026";
}

.reveal .banner-top {
  @extend %banner-top;

  > * {
    margin-top: 0;
    margin-bottom: 0;
    line-height: inherit;
  }

  a {
    color: #f0b429;
  }
}

.reveal .slides:has(section#title-slide.present)::after,
.reveal .slides:has(section.present .banner-top)::after {
  display: none;
}

.reveal .slides > section:not(#title-slide) {
  box-sizing: border-box;
  padding-top: 1em;
}
```

With that in place the deck reads exactly like the footer does.

    ## A banner of its own

    ::: banner-top
    Photo by [Galen Crout](https://unsplash.com/@galen_crout) on [Unsplash](https://unsplash.com)
    :::

Deck where the second slide replaces the default top banner with its own text using a `::: banner-top` div, and the banner returns to the default on the next slide.

[qmd](examples/elements/banner-slide.qmd) [scss](examples/elements/banner-slide.scss)

## 7.4 Showing quarto code

This one isn’t as much a slidecrafting tip, as it is a quarto tip! If you are showing how to do something in Quarto using Quarto you need this tip. In essence what we are working with are [unexcuted blocks](https://quarto.org/docs/computations/execution-options.html#unexecuted-blocks).

Adding a `markdown` cell around what you want to show. Important to use more ticks than any of the inside cells inside.

Using double curly brackets to indicate that the code block should not be executed. The following code when used in a quarto document will render as shown in the example

````` markdown
```` markdown
This is **Quarto** code

```{{python}}
1 + 1
```
````
`````

Slide demonstrating how to display Quarto/R code as literal unexecuted source using double curly brackets (`{{python}}`), so the code block appears verbatim rather than being run.

[qmd](examples/elements/tip-6.qmd)

## 7.5 Changing plot backgrounds

Plots and charts are useful in slides. Changing the background makes them fit in. This post will go over how to change the background of your plots to better match the slide background, in a handful of different libraries.

### 7.5.1 Why are we doing this?

If you are styling your slides to change the background color, you will find that most plotting libraries default to using a white background color. If your background is non-white it will stick out like a sore thumb. I find that changing the background color to something transparent `#FFFFFF00` is the easiest course of action.

> Why make the background transparent instead of making it match the background?

It is simply easier that way. There is only one color we need to set and it is `#FFFFFF00`. This works even if the slide background color is different from slide to slide, or if the background is a non-solid color.

### 7.5.2 base R

we don’t have to make any changes to the R code, we can supply the chunk options `dev` and `dev.args` for the chunk to `"png"` and `list(bg="transparent")` respectively and you are good. The chunk will look like this.

```` markdown
```{r, dev = "png", dev.args=list(bg="transparent")}
plot(mpg ~ disp, data = mtcars, col = factor(am), pch = 16, bty = "n")
```
````

You can also change the options globally using the following options in the yaml.

``` yaml
knitr:
  opts_chunk:
    dev: png
    dev.args: { bg: "transparent" }
```

![](media/base-before.webp)

![](media/base-after.webp)

### 7.5.3 ggplot2

ggplot2 are handled the same way as base R plotting, so we don’t have to make any changes to the R code, we can supply the chunk options `dev` and `dev.args` for the chunk to `"png"` and `list(bg="transparent")` respectively and you are good. The chunk will look like this.

```` markdown
```{r, dev = "png", dev.args=list(bg="transparent")}
library(ggplot2)
mtcars |>
  ggplot(aes(disp, mpg, color = factor(am))) +
  geom_point() +
  theme_minimal()
```
````

You can also change the options globally using the following options in the yaml.

``` yaml
knitr:
  opts_chunk:
    dev: png
    dev.args: { bg: "transparent" }
```

![](media/ggplot2-before.webp)

![](media/ggplot2-after.webp)

### 7.5.4 matplotlib

With matplotlib, we need to set the background color twice, once for the plotting area, and once for the area outside the plotting area.

``` python
fig = plt.figure()
# outside plotting area
plt.axes().set_facecolor("#FFFFFF00")

# your plot
plt.scatter(x, y, c=colors)

# inside plotting area
fig.patch.set_facecolor("#FFFFFF00")
```

![](media/matplotlib-before.webp)

![](media/matplotlib-after.webp)

### 7.5.5 seaborn

For seaborn, we also set it twice, both of them in `set_style()`

``` python
sns.set_style(rc={'axes.facecolor':'#FFFFFF00',
                  'figure.facecolor':'#FFFFFF00'})
```

![](media/seaborn-before.webp)

![](media/seaborn-after.webp)

### 7.5.6 Source Document

The above was generated with this document.

[source document](examples/elements/plot-background-examples.qmd)

## 7.6 Plot sizing

Plots and charts are useful in slides. But we need to make sure they are sized correctly to be as effective as possible.

### 7.6.1 auto-stretch option

Revealjs slides default to having the option [auto-stretch: true](https://quarto.org/docs/presentations/revealjs/advanced.html#stretch), this ensures that figures always fit inside the slide. You can turn it off globally like this.

``` yaml
format:
  revealjs:
    auto-stretch: false
```

or on a slide-by-slide basis by adding the `.nostretch` class to the slide.

    ## Slide Title {.nostretch}

We see how they affect sizing in the following slides first with the default, and second with `.nostretch`.

Plot slide with `auto-stretch: true` (default): the figure is automatically scaled down to fit within the slide boundaries.

Same plot slide with `.nostretch` class: the figure is shown at its natural size, potentially overflowing the slide.

By themselves, they look pretty similar. One occasion where you really notice the difference is when there are other elements on the slide. `auto-stretch` makes sure the image fits by making the image smaller as seen below.

Plot and title text on the same slide with `auto-stretch` enabled: image is shrunk to fit alongside the other content.

Same slide with `.nostretch`: image renders at full natural size and may overlap or push other content off the slide.

### 7.6.2 Sizing Options

When sizing plots we need to remember that we have to deal with two kinds of sizes. First is the size of the actual file on disk, this is controlled using `out-width` and `out-height`. Next is how big the image is supposed to be in the document, which is controlled using `fig-width`, `fig-height`, and/or `fig-asp`. Lastly, you can control the location using `fig-align` and the resolution using `fig-dpi`.

All of these numbers will change depending on whether you have a title or other elements on your slides, what fonts you use, and the aspect ratio of the slides themselves.

#### 7.6.2.1 out-width, out-height

Setting these options affects the size of the resulting image on disk. If they are set smaller than usual, we get an image that doesn’t take up the whole screen.

```` markdown
```{r}
#| out-width: 6in
#| out-height: 3.5in
```
````

Plot with `out-width: 6in, out-height: 3.5in`: the saved image file is small, resulting in a figure that does not fill the slide.

Comparison slide for the small `out-width`/`out-height` example, shown alongside a default-sized chart.

I don’t find myself using these options much as I tend to want images that take up most of the space, but they are useful to know.

### 7.6.3 fig-width, fig-height

I end up using `fig-width` and `fig-height` the most out of the options shown in this blog post. I find that the default values are too high, making the text on the plot too small for the viewer to see. Especially for an in-person audience.

Below is the same chart 4 times with different value pairs for `fig-width` and `fig-height`. Notice how the default values appear to be around `fig-width: 9` and `fig-height: 5`.

Chart with `fig-width: 9, fig-height: 5` (Reveal.js defaults): text labels on the chart appear small and may be hard to read for an audience.

Chart with reduced `fig-width` and `fig-height`: larger text relative to the plot area, improving readability for live audiences.

Another `fig-width`/`fig-height` combination showing how the ratio between dimensions affects text and element sizes on the chart.

Fourth `fig-width`/`fig-height` variant in the comparison series, demonstrating that smaller values produce larger, more legible chart text.

All of the above figures have roughly the same aspect ratios, but if you want others you just specify different values. Like this square chart below.

Square chart using equal `fig-width` and `fig-height` values, demonstrating how aspect ratio is controlled independently of the slide dimensions.

### 7.6.4 fig-asp

You might have noticed that the ratios shown in the last section weren’t identical. Because unless you deal with 1-2 or 1-1 ratios you are going to get decimals very fast. And you have to recalculate small things over and over again. This is why `fig-asp` is amazing. Simply determine the aspect ratio between the height and width, set that as the `fig-asp` and then you just have to set one of `fig-height` or `fig-width`. Is it too small? increase `fig-height` and keep `fig-asp` the same. is it too big? decrease `fig-height` and keep `fig-asp` the same.

Chart using `fig-asp` to fix the aspect ratio: changing `fig-height` scales the chart proportionally without needing to update both dimensions.

Same `fig-asp` ratio at a different `fig-height`, showing how the chart scales up or down while maintaining consistent proportions.

### 7.6.5 fig-align

Unless your chart fits fully inside the slide then it tends to be left aligned, you can change that with `fig-align`, setting it to `left`, `center` or `right`.

Chart with `fig-align: left`: the figure is positioned against the left edge of the slide content area.

Chart with `fig-align: center`: the figure is centered horizontally on the slide.

Chart with `fig-align: right`: the figure is positioned against the right edge of the slide content area.

### 7.6.6 fig-dpi

Lastly, something you might need to worry about is the **D**ots **P**er **I**nch (DPI) specified by `fig-dpi`. This is a measure of resolution in your chart. If you see your chart becoming a little blurry, increase the dpi until it isn’t anymore. Note that dpi will result in larger file sizes, so only change if you have to.

Chart at standard DPI: text and elements may appear slightly soft at high display resolutions.

Same chart at higher `fig-dpi`: text and lines are crisp and sharp, at the cost of a larger file size.

### 7.6.7 Make work with columns

even if you set the option globally, you will have to make slide-by-slide adjustments, such as with charts in `.columns`. Below is one example of how we can modify the `fig-asp` to make it look decent in a column layout.

Chart inside a two-column layout with `fig-asp` adjusted to fit the narrower column width, preventing the figure from overflowing its column.

### 7.6.8 Source Document

The above was generated with this document.

[source document](examples/elements/plot-sizing-examples.qmd)
