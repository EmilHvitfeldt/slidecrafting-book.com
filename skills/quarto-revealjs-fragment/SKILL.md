---
name: quarto-revealjs-fragment
description: How to create custom Reveal.js fragment animations in Quarto presentations. Use this skill whenever the user wants to add a custom animated fragment effect to a Quarto revealjs slide — things like letters falling, elements fading in unusually, text that animates on a keypress, or any effect tied to Reveal.js fragment navigation. Covers the div syntax, CSS states, JS events, and mid-animation reversal patterns.
---

# Custom Quarto Reveal.js Fragments

References:
- https://slidecrafting-book.com/fragments
- https://quarto.org/docs/presentations/revealjs/advanced.html#fragments
- https://revealjs.com/fragments/

A fragment is content that appears (or animates) when the presenter presses the forward key, and reverses when they press back. Custom fragments let you attach any CSS animation to that trigger.


## File structure

A typical Quarto revealjs presentation wires up custom fragments across three files:

```
index.qmd     ← slide content + YAML
styles.scss   ← CSS animations and fragment states
custom.html   ← JavaScript logic, included via include-after-body
```

`index.qmd` YAML:
```yaml
format:
  revealjs:
    theme: [default, styles.scss]
    include-after-body:
      - "custom.html"
```

## 1. Marking content as a custom fragment

```markdown
::: {.fragment .my-effect}
Content here
:::
```

`.fragment` — makes Reveal.js treat the div as a fragment. `.my-effect` is your custom class, targeted in CSS and JS.

## 2. CSS fragment states

Reveal.js applies three CSS states to fragments. List them in this order:

```scss
// Before triggered — what it looks like at rest
.reveal .slides section .fragment.my-effect { }

// After triggered — once the presenter has moved past it
.reveal .slides section .fragment.my-effect.visible { }

// Currently being triggered
.reveal .slides section .fragment.my-effect.current-fragment { }
```

By default, `.fragment` sets `opacity: 0`. If you want the content **visible before the fragment fires** (common for effects where visible text then animates away), override the default in the first rule:

```scss
.reveal .slides section .fragment.my-effect {
  opacity: 1;
  visibility: visible;
}
```

### Animation classes (applied via JS)

Define your keyframes and the classes that trigger them:

```scss
@keyframes my-animation {
  0%   { transform: translateY(0); opacity: 1; }
  100% { transform: translateY(110vh); opacity: 0; }
}

.my-char {
  display: inline-block;       // required for transform to work on inline elements
  transform-origin: top center;

  &.is-animating {
    animation: my-animation 0.6s ease-in forwards;
  }

  &.is-parked {
    // Static snapshot of the end state, used when reversing mid-animation
    opacity: 0;
    transform: translateY(110vh);
  }
}
```

`animation-fill-mode: forwards` holds the final keyframe after the animation ends. To clear that hold, remove the class and force a reflow: `void el.offsetWidth`.

## 3. CSS-only vs JavaScript fragments

For simple effects — fading, sliding, color changes, transforms that go in one direction — CSS alone is enough. Define the three state rules and Reveal.js handles the rest automatically. No JS needed.

```scss
// Example: spin in on trigger, stay spun
.reveal .slides section .fragment.spin-in {
  opacity: 0;
  transform: rotate(-180deg);
  transition: transform 0.6s ease, opacity 0.6s ease;
}
.reveal .slides section .fragment.spin-in.visible {
  opacity: 1;
  transform: rotate(0deg);
}
```

JavaScript is only needed when:
- The effect is too complex to express as a CSS transition between two states (e.g. staggered per-character animations)
- You need to manipulate the DOM when the fragment triggers (e.g. wrapping text in spans)
- You need custom reversal logic beyond what CSS transitions give you for free

## 4. JavaScript events (when needed)

Every custom fragment **must** handle both directions — presenters navigate backward too.

```js
Reveal.on('fragmentshown', event => {
  if (event.fragment.classList.contains('my-effect')) {
    startAnimation(event.fragment);
  }
});

Reveal.on('fragmenthidden', event => {
  if (event.fragment.classList.contains('my-effect')) {
    reverseAnimation(event.fragment);
  }
});
```

Prepare DOM changes (like wrapping characters in spans) at `ready` time, not when the fragment fires, to avoid layout shifts:

```js
Reveal.on('ready', () => {
  document.querySelectorAll('.my-effect').forEach(prepareEl);
});
```


## 5. Reversal

Presenters navigate backward, so your `fragmenthidden` handler must genuinely undo the effect — not just clear state. The simplest correct approach is to run the animation in reverse when `fragmenthidden` fires.

As a nice-to-have, if your forward animation is staggered or multi-step, you can also handle the case where the presenter goes back mid-way through. Rather than jumping to the completed state and reversing from there, you track per-element state and reverse only what has actually moved.

### State tracking pattern

```js
// When forward animation starts, tag each element with its state
el._state = 'idle';      // not yet started
el._state = 'animating'; // currently animating
el._state = 'done';      // animation complete
```

### Forward function

```js
function startAnimation(el) {
  const items = Array.from(el.querySelectorAll('.my-char'));
  el._timers = [];
  el._order = items.slice().sort(() => Math.random() - 0.5); // random order example

  items.forEach(item => { item._state = 'idle'; });

  el._order.forEach((item, i) => {
    const t = setTimeout(() => {
      item._state = 'animating';
      item.classList.add('is-animating');

      const t2 = setTimeout(() => {
        item._state = 'done';
      }, 600); // match animation duration
      el._timers.push(t2);
    }, i * 250);
    el._timers.push(t);
  });
}
```

### Reverse function

```js
function reverseAnimation(el) {
  // Cancel all pending timers first
  (el._timers || []).forEach(t => clearTimeout(t));
  el._timers = [];

  const reversed = (el._order || []).slice().reverse();
  const toReverse = [];

  reversed.forEach(item => {
    if (item._state === 'idle') {
      // Never moved — already in place, do nothing
    } else if (item._state === 'animating') {
      // Mid-animation — snap back (it's close enough to origin)
      item.classList.remove('is-animating');
      void item.offsetWidth; // force reflow to clear forwards-fill state
      item._state = 'idle';
    } else {
      // Done — park it at the end state, then animate it back
      item.classList.remove('is-animating');
      void item.offsetWidth;
      item.classList.add('is-parked'); // static snapshot of end state
      item._state = 'done';
      toReverse.push(item);
    }
  });

  // Only reverse items that actually completed their animation
  toReverse.forEach((item, i) => {
    const t = setTimeout(() => {
      item.classList.remove('is-parked');
      void item.offsetWidth;
      item.classList.add('is-returning');

      const t2 = setTimeout(() => {
        item.classList.remove('is-returning');
        void item.offsetWidth;
        item._state = 'idle';
      }, 600);
      el._timers.push(t2);
    }, i * 250);
    el._timers.push(t);
  });
}
```

The key insight: `is-parked` is a plain CSS class (no animation) that statically places the element at the end position. This prevents a flash to the natural position before the return animation starts.

## 6. Complete working example — falling letters

This is the full pattern that produced the falling letters effect:

**`index.qmd`** — mark the text as a fragment:
```markdown
::: {.fragment .falling}
Hello World
:::
```

**`styles.scss`** — keep text visible, define animations:
```scss
.reveal .slides section .fragment.falling { opacity: 1; visibility: visible; }
.reveal .slides section .fragment.falling.visible { opacity: 1; visibility: visible; }
.reveal .slides section .fragment.falling.current-fragment { opacity: 1; visibility: visible; }

@keyframes dangle {
  0%   { transform: rotate(0deg); }
  20%  { transform: rotate(18deg); }
  40%  { transform: rotate(-12deg); }
  60%  { transform: rotate(10deg); }
  80%  { transform: rotate(-6deg); }
  100% { transform: rotate(4deg); }
}

@keyframes fall {
  0%   { transform: rotate(4deg) translateY(0);      opacity: 1; }
  100% { transform: rotate(25deg) translateY(110vh); opacity: 0; }
}

@keyframes rise {
  0%   { transform: rotate(25deg) translateY(110vh); opacity: 0; }
  100% { transform: rotate(4deg) translateY(0);      opacity: 1; }
}

.falling-char {
  display: inline-block;
  transform-origin: top center;

  &.is-dangling { animation: dangle 0.7s ease-in-out forwards; }
  &.is-falling  { animation: fall   0.6s cubic-bezier(0.4, 0, 1, 1) forwards; }
  &.is-fallen   { opacity: 0; transform: rotate(25deg) translateY(110vh); } // park class
  &.is-rising   { animation: rise   0.6s cubic-bezier(0, 0, 0.6, 1) forwards; }
}
```

**`custom.html`** — full JS with state tracking:
```html
<script type="text/javascript">
const STAGGER   = 250;
const DANGLE_MS = 700;

function prepareEl(el) {
  if (el.dataset.initialized) return;
  el.dataset.initialized = 'true';
  el.innerHTML = [...el.textContent].map(char =>
    char === ' '
      ? '<span class="falling-char">&nbsp;</span>'
      : `<span class="falling-char">${char}</span>`
  ).join('');
}

function startFalling(el) {
  const chars = Array.from(el.querySelectorAll('.falling-char'));
  const shuffled = chars.slice().sort(() => Math.random() - 0.5);
  el._timers  = [];
  el._shuffled = shuffled;
  chars.forEach(c => { c._state = 'idle'; });

  shuffled.forEach((char, i) => {
    const t1 = setTimeout(() => {
      char._state = 'dangling';
      char.classList.add('is-dangling');

      const t2 = setTimeout(() => {
        char._state = 'falling';
        char.classList.remove('is-dangling');
        void char.offsetWidth;
        char.classList.add('is-falling');

        const t3 = setTimeout(() => { char._state = 'fallen'; }, 600);
        el._timers.push(t3);
      }, DANGLE_MS);
      el._timers.push(t2);
    }, i * STAGGER);
    el._timers.push(t1);
  });
}

function resetFalling(el) {
  (el._timers || []).forEach(t => clearTimeout(t));
  el._timers = [];

  const reversed = (el._shuffled || []).slice().reverse();
  const toRise = [];

  reversed.forEach(char => {
    if (char._state === 'idle') {
      // untouched — leave it
    } else if (char._state === 'dangling') {
      char.classList.remove('is-dangling');
      void char.offsetWidth;
      char._state = 'idle';
    } else {
      char.classList.remove('is-falling');
      void char.offsetWidth;
      char.classList.add('is-fallen'); // park at bottom, no flash
      char._state = 'fallen';
      toRise.push(char);
    }
  });

  toRise.forEach((char, i) => {
    const t1 = setTimeout(() => {
      char.classList.remove('is-fallen');
      void char.offsetWidth;
      char.classList.add('is-rising');

      const t2 = setTimeout(() => {
        char.classList.remove('is-rising');
        void char.offsetWidth;
        char._state = 'idle';
      }, 600);
      el._timers.push(t2);
    }, i * STAGGER);
    el._timers.push(t1);
  });
}

Reveal.on('ready', () => {
  document.querySelectorAll('.falling').forEach(prepareEl);
});

Reveal.on('fragmentshown', event => {
  if (event.fragment.classList.contains('falling')) startFalling(event.fragment);
});

Reveal.on('fragmenthidden', event => {
  if (event.fragment.classList.contains('falling')) resetFalling(event.fragment);
});
</script>
```

## Common gotchas

- **Transforms don't work on inline elements** — wrap characters in `display: inline-block` spans.
- **Layout shift on fragment fire** — prepare the DOM (wrap chars in spans) at `Reveal.on('ready')`, not inside the fragment handler.
- **`forwards` fill mode persists after class removal** — always do `void el.offsetWidth` after removing an animation class to force a reflow and clear the held state.
- **Flash to natural position when reversing** — use a static "park" class (no animation, just the end-state CSS values) to hold elements at their final position until their reverse animation slot starts.
- **Both directions required** — omitting `fragmenthidden` breaks backward navigation; always handle both.

## Advanced patterns

These come up when fragments trigger complex or long-running behavior.

### Targeting by id instead of class

When a slide has multiple distinct fragment behaviors, targeting by `id` is cleaner than class:

```js
Reveal.on('fragmentshown', ({ fragment }) => {
  if (fragment.id === 'intro-fragment') startIntro();
  if (fragment.id === 'chart-fragment') showChart();
});
```

### Resuming state on slidechanged

If your fragment triggers a long-running animation (a loop, a timer), handle `slidechanged` to stop it when leaving the slide and restore it when returning:

```js
Reveal.on('slidechanged', ({ currentSlide, previousSlide }) => {
  if (previousSlide?.querySelector('.my-slide')) stopAnimation();

  if (currentSlide?.querySelector('.my-slide')) {
    const frag = document.getElementById('my-fragment');
    if (frag?.classList.contains('visible')) startAnimation();
  }
});
```

The `.visible` check matters — when returning to a slide where a fragment already fired, `fragmentshown` won't fire again, so you re-derive state from what's already visible.

### Using an animation library

For complex motion, load a library directly in the include file:

```html
<script src="https://cdn.jsdelivr.net/npm/animejs@3.2.2/lib/anime.min.js"></script>
<script type="text/javascript">
  // anime is now available globally
</script>
```

### Waiting for Reveal to be ready

If your script runs before Reveal initializes, `Reveal.on` won't exist yet:

```js
function boot() {
  if (typeof Reveal === 'undefined' || !Reveal.isReady()) {
    return setTimeout(boot, 80);
  }
  // safe to call Reveal.on() here
}
document.addEventListener('DOMContentLoaded', boot);
```

