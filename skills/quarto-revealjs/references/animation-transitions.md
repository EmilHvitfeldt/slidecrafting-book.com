# Slide and fragment transitions

References:
- https://quarto.org/docs/presentations/revealjs/advanced.html#slide-transitions

## Global transitions

```yaml
format:
  revealjs:
    transition: slide          # none, fade, slide, convex, concave, zoom
    transition-speed: default  # default, fast, slow
    background-transition: fade
```

## Per-slide transition

Override on the heading:

```markdown
## Slide {transition="zoom" transition-speed="fast"}
```

## Gotchas

- `none` or `fade` read as more professional for content-heavy talks; `zoom`/`convex` can feel gimmicky if overused.
- `background-transition` animates slide backgrounds independently of content.
- For elements that move/morph *between* slides rather than a whole-slide swap, use auto-animate (`animation-auto-animate.md`), not a transition.
