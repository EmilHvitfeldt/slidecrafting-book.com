# Hiding slides

References:
- https://slidecrafting-book.com/miscellaneous
- https://quarto.org/docs/presentations/revealjs/advanced.html#slide-visibility

Skip a slide during presentation without deleting it, via the heading attribute:

```markdown
## Slide Title {visibility="hidden"}
```

Useful for disclaimers or seasonal slides you toggle between deliveries: flip the attribute instead of cutting and re-pasting content.

Related: `visibility="uncounted"` keeps a slide in the deck but excludes it from slide numbering/count.

## Gotchas

- `hidden` slides are still in the HTML source (searchable, in the DOM); this is presentation-skipping, not access control.
- `uncounted` shows the slide but leaves it out of the total in `slide-number` (`present-slide-numbers.md`).
