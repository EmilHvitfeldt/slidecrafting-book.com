# Distributing bullets evenly (.spread)

References:
- https://slidecrafting-book.com/layout

A few short bullets clump at the top of a slide. `.spread` distributes them down the full vertical space with flexbox.

## SCSS

```scss
/*-- scss:rules --*/
.spread {
  --spread-padding: 0.5em;
  padding-top: var(--spread-padding);
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  align-items: flex-start;
}
.spread-evenly { justify-content: space-evenly; }
.spread-around { justify-content: space-around; }
```

## JavaScript (measures remaining height)

`spread-script.html`:

```html
<script type="text/javascript">
function updateSpreads() {
  document.querySelectorAll('.spread').forEach(el => {
    const section = el.closest('section');
    const paddingTop = parseFloat(getComputedStyle(el).paddingTop);
    el.style.height = (section.offsetHeight - el.offsetTop - paddingTop) + 'px';
  });
}
Reveal.on('ready', updateSpreads);
Reveal.on('slidechanged', updateSpreads);
</script>
```

```yaml
format:
  revealjs:
    include-after-body: spread-script.html
```

## Usage

```markdown
::: {.spread}
Think about how models work

Very valid for count data

We rarely care whether a predictor is normal
:::
```

Default `space-between` pins first to top, last to bottom. Use `.spread-evenly` for equal gaps including the edges.

## Gotchas

- `.spread` should be the **last** element on a slide — its JS-set height fills to the slide bottom, pushing later content off-screen.
- Override with an inline height for less than full space: `::: {.spread style="height:60%;"}`.
- Needs the `include-after-body` script; without it the flexbox has no height to distribute within.
