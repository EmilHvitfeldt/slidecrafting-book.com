# Custom fragment animations (CSS states + JS)

References:
- https://slidecrafting-book.com/fragments
- https://quarto.org/docs/presentations/revealjs/advanced.html#fragments
- https://revealjs.com/fragments/

For effects tied to fragment navigation that go beyond the built-ins: letters falling, staggered per-character motion, DOM manipulation on trigger.

## File wiring

```yaml
format:
  revealjs:
    theme: [default, styles.scss]
    include-after-body:
      - custom.html        # JS lives here
```

Mark content as a custom fragment:

```markdown
::: {.fragment .my-effect}
Content
:::
```

## CSS-only vs JavaScript

For one-directional effects (fade, slide, color, single transform), CSS alone is enough — define the three stage rules (`animation-fragments.md`) and Reveal handles forward and reverse for free:

```scss
.reveal .slides section .fragment.spin-in {
  opacity: 0; transform: rotate(-180deg);
  transition: transform 0.6s ease, opacity 0.6s ease;
}
.reveal .slides section .fragment.spin-in.visible {
  opacity: 1; transform: rotate(0deg);
}
```

Reach for JS only when: the effect is too complex for a two-state transition (staggered per-character), you must manipulate the DOM on trigger, or you need custom reversal.

## JS events

```js
Reveal.on('ready', () => {
  document.querySelectorAll('.my-effect').forEach(prepareEl);  // DOM prep here, not on fire
});

Reveal.on('fragmentshown', ({ fragment }) => {
  if (fragment.classList.contains('my-effect')) startAnimation(fragment);
});

Reveal.on('fragmenthidden', ({ fragment }) => {
  if (fragment.classList.contains('my-effect')) reverseAnimation(fragment);
});
```

## Both directions are mandatory

Presenters navigate back, so `fragmenthidden` must genuinely undo the effect. The robust pattern tracks per-element state (`idle` / `animating` / `done`) so a mid-animation reverse only rewinds what actually moved. Park completed elements at their end-state with a plain (non-animated) CSS class before reversing, to avoid a flash to natural position.

```js
// forward: tag state as you go
item._state = 'idle';       // not started
item._state = 'animating';  // in flight
item._state = 'done';       // finished

// reverse: cancel pending timers, then per element:
//   idle      -> leave it
//   animating -> snap back (remove class + void el.offsetWidth), set idle
//   done      -> add park class, then run the reverse animation
```

`animation-fill-mode: forwards` holds the final keyframe; clear it by removing the class and forcing a reflow with `void el.offsetWidth`.

## Advanced

- **Target by id** when a slide has several distinct behaviors: `if (fragment.id === 'chart-fragment') ...`.
- **Long-running animations**: use `slidechanged` to stop on leave and re-derive state on return (check `.visible`, since `fragmentshown` won't re-fire).
- **Libraries**: load e.g. anime.js via a `<script src>` in the include file.
- **Boot guard** if your script may run before Reveal: poll `Reveal.isReady()` before calling `Reveal.on`.

The full worked "falling letters" example (keyframes + complete state-tracking JS) is in the book's fragments chapter and the standalone `quarto-revealjs-fragment` skill.

## Gotchas

- Transforms need `display: inline-block` on inline spans.
- Prepare DOM changes at `ready`, not on fragment fire, to avoid layout shift.
- After removing an animation class, `void el.offsetWidth` to clear `forwards` fill.
- Use a static "park" class (end-state values, no animation) to prevent a flash before reverse.
- Omitting `fragmenthidden` breaks backward navigation.
