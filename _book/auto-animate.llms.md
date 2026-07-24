# 12  Auto-Animate

Reveal.js ships with a feature called [auto-animate](https://quarto.org/docs/presentations/revealjs/advanced.html#auto-animate) that smoothly animates matching elements from one slide to the next. On its own it is a nice transition. Used with a little structure, it becomes a way to give an otherwise ordinary deck a sense of motion and intent. In this chapter we are gonna try to see how we can use this with what we call **persistent elements**. parts of the slides that persists between slides, mostly to improve the easthetics.

## 12.1 A note before we start: this used to be tedious

Traditionally this is not used that much as far as I can see, and I think it happens because you end up needing to do a lot of div matching with IDs to have things line up. and that is not even taking into account the time it takes to set up the `left`, `top`, `width`, and `height` for every element. Then copied across slides. It is simply too much work. [I did it for a talk once](https://github.com/EmilHvitfeldt/talk-rstudioconf2022-tidyclust/blob/master/index.qmd#L66-L164) and it was a lot of work. and that was only two slides.

Two things have changed that.

AI agents simply excel at this super tedius work. the syntax is quite simple, and repetetive, and it is just something that AI works pretty well with.

The second is the [`quarto-revealjs-editable`](https://github.com/EmilHvitfeldt/quarto-revealjs-editable) extension, which we return to at the end of the chapter. It lets you drag, resize, and rotate elements directly on the rendered slide and write the coordinates back into your `.qmd`, so you tune the look by eye instead of guessing numbers.

## 12.2 What auto-animate does

Mark two adjacent slides with `auto-animate=true` and reveal.js will match up the elements on them and animate the difference.

Automatical matching will happen, but it is much more fragile. so my general advice is to give matching elements the same `data-id`.

``` markdown
## A single element {auto-animate=true}

::: {data-id="box" style="width:140px; height:140px; background:#5E7699;"}
:::

## The same data-id, changed {auto-animate=true}

::: {data-id="box" style="width:520px; height:260px; background:#FF9E8A;"}
:::
```

The element keeps its identity across the slide break, so its position, size, colour, and corner radius all tween between the two states.

A single square with a shared `data-id` grows and changes colour between two auto-animate slides.

[qmd](./examples/auto-animate/basics.qmd)

A few settings control the feel, set globally in the YAML header or per slide:

- `auto-animate-duration` (seconds)
- `auto-animate-easing` (a CSS easing function)
- `auto-animate-delay` (per element)

## 12.3 The persistent-elements pattern

Here is the core idea. Pick a small cast of shapes. anything between 1 and 5 is fine. Give each a `data-id`. Put the parts that never change, the colours, in your SCSS, keyed on the `data-id`:

``` scss
[data-id="draft"]   { background: #2E7D6B; }
[data-id="review"]  { background: #E8A33D; }
[data-id="release"] { background: #4A5899; }
```

and put the parts that *do* change, the geometry, inline on each slide:

``` markdown
::: {.panel data-id="review" style="left:470px; top:220px; width:340px; height:360px;"}
:::
```

we do this to reduce code duplication. Only write what is needed for each element.

then we simply have to place the elements at different stages on the slides, we can put content in them as well if we so pleases.

Three colored panels that regroup across slides: a title cluster, a row of cards, one card expanded while the others shrink to markers, and a final reassembly.

[qmd](./examples/auto-animate/colored-panels.qmd) [scss](examples/auto-animate/colored-panels.scss)

The colored-panel look above is only one of many possibilities.

A three-item agenda where the current section’s item grows and highlights while the others dim, on each section-divider slide.

[qmd](./examples/auto-animate/agenda.qmd) [scss](examples/auto-animate/agenda.scss)

## 12.4 Enough, not all

You do not need a busy cast. A single recurring shape is often plenty. In the deck below one hero shape reshapes between section dividers, a circle, then a bar, then a frame, while the content slides in between stay calm and simply park the shape as a small marker in the corner. That contrast, motion on the dividers and stillness on the content, is what keeps it from feeling like a screensaver.

One hero shape that becomes a circle, a bar, and a frame across section dividers, parked as a small marker on the quiet content slides between them.

[qmd](./examples/auto-animate/hero-shape.qmd) [scss](examples/auto-animate/hero-shape.scss)

## 12.5 Putting content inside an element

An element is just a div, so it can hold text or a figure. Because that inner content has no match on the neighbouring slide, it fades in while the element animates into place. This lets you show a bold headline number while the panel is small, then expand the same panel into a full chart: the number fades out and the ggplot2 figure fades in, without either being animated across the slide. The figure below is a real ggplot2 plot generated by an R chunk placed inside the fenced div.

A small panel showing a large “+42%” that expands to fill the slide, the number fading out as a ggplot2 line chart fades in.

[qmd](./examples/auto-animate/figure-in-element.qmd) [scss](examples/auto-animate/figure-in-element.scss)

Note that this deck needs R at render time, and raw SVG (if you hand-write a figure instead) has to go in a ```` ```{=html} ```` block, since Pandoc will not pass raw SVG through an inline span.

## 12.6 A canvas worth setting up

Absolute positioning is far easier to reason about on a fixed grid, so these decks set an explicit canvas in the header:

``` yaml
format:
  revealjs:
    width: 1280
    height: 700
    margin: 0
    center: false
    auto-animate-duration: 0.9
    theme: [default, my-deck.scss]
```

With `center: false` and the slide padding zeroed in SCSS, `left`/`top` are measured from the slide’s top-left corner, so the coordinates you write match what you see. It is also handy to let the `##` heading double as the slide’s small kicker label, styled through `.reveal h2`, and to set text colour once per slide with a `.dark` / `.light` class on the heading rather than on every span.

## 12.7 Positioning without counting pixels

Everything above still leaves you writing coordinates. The [`quarto-revealjs-editable`](https://github.com/EmilHvitfeldt/quarto-revealjs-editable) extension removes most of that pain. Install it with:

``` bash
quarto add EmilHvitfeldt/quarto-revealjs-editable
```

Then click **Modify** in the deck’s menu (or mark elements with the `{.editable}` class), drag and resize your elements right on the rendered slide, and save the new positions back into the `.qmd`. The recommended workflow for a persistent-elements deck is to rough the shapes in, perhaps with an AI agent’s help, then nudge them into place visually.
