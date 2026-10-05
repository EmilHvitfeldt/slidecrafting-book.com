---
name: "fragment-stop-and-retarget"
description: "Retrofit a custom reveal.js fragment/slide animation (or any JS-driven exit/entrance effect) so that interrupting it mid-flight — navigating the opposite direction before it finishes — stops and redirects from the live state instead of finishing the old animation or snapping. Use when a fragment's custom JS animation doesn't reverse cleanly if triggered before the forward (or reverse) pass completes, or when a staggered/choreographed multi-element effect only picks up a direction change after a long delay."
---

# Fragment stop-and-retarget

A companion to the `quarto-revealjs-fragment` skill's "Reversal" section. That skill's state-tracking pattern is enough for most effects: when a presenter backs up mid-animation, snap whatever's still "animating" straight to idle and only truly reverse what already finished. That's correct and simple, and for most effects nobody will ever notice the snap.

This skill is for the harder case: an element that's visibly mid-motion (falling, morphing, flying) when the direction changes, and a snap would be jarring. The fix is **stop-and-retarget**: wrap "start this unit animating toward target X" in one function that always stops whatever's currently driving the unit first, then starts the new animation computed from the unit's *live current value* — never from a nominal start/end state.

## 1. Locate

Search for the fragment's custom JS:

```bash
grep -rn "fragmentshown\|fragmenthidden" _extensions/*/*.js custom.html *.html 2>/dev/null
```

Also check inline `<script>` blocks in `custom.html` / other `include-after-body` files — many Quarto reveal.js extensions put the JS there rather than in `_extensions/`.

## 2. Classify

A single effect can mix flavors (e.g. CSS transitions for position/opacity alongside manual rAF tweening for shape). Identify what's actually driving each animated property:

1. **CSS-transition-driven** — a plain `element.style.transform = ...` / `.style.opacity = ...` change with a CSS `transition` declared.
2. **`requestAnimationFrame`/manual-tween-driven** — a hand-rolled frame loop (e.g. tweening an SVG path's `d` attribute, which CSS can't interpolate).
3. **Timeline-library-driven** — anime.js, GSAP, Motion One, etc., producing a reusable instance/handle.
4. **CSS `@keyframes`-driven** — an `animation-name` assignment (Animate.css/Magic.css-style class libraries are the common case). Unlike a transition, a browser does **not** interpolate a freshly-assigned keyframe animation from the live value: reassigning `animation-name` restarts from that animation's first keyframe, which *is* the snap bug in this flavor's native form.

## 3. Apply the matching fix

### CSS-transition flavor

**Recognizing when no fix is needed at all**: if the handler's entire job is a direct reassignment — `el.style.transform = newValue` (or `opacity`, etc.) — against a plain `transition` declaration, with no `transition: none` + forced-reflow reset anywhere in the same path and no per-unit stagger to worry about, it's already correct with zero code changes. The browser always interpolates a reassigned transition target from whatever the live value currently is; there's nothing to "stop" because nothing destructive happens in between. Confirm this by reading the assignment site, not just the CSS: a reset step can hide anywhere in the same function and would turn this into the §3-opening snap bug. Worth verifying empirically anyway (see `quarto-timeline` below) since "looks like a direct reassignment" and "is one, with no reset hiding nearby" aren't the same confidence level.

No handle needed — `getComputedStyle` always reflects the true live interpolated value while a transition is running. "Stop" is implicit as long as you never do `transition: none` plus a forced reflow before reapplying (that destroys the live position and *is* the snap-to-instant bug). "Retarget" is: reassign the transition's properties/duration/easing, *then* assign the new target value; the browser interpolates from wherever it currently is automatically.

**The easy-to-miss step**: if the two directions use different easing curves or durations (accelerating fall vs. decelerating return, say), you must explicitly reassign `transition` to the new direction's declaration *before* setting the new target — every time, even mid-flight, not just on a fresh start. A unit currently mid-flight still has the *opposite* direction's transition applied; skipping the reassignment makes the browser interpolate the new target using the wrong easing/duration.

**`transition-property` wants the CSS (hyphenated) name, not the JS/CSSOM camelCase accessor.** If you build the `transition` shorthand programmatically from the same string you use to index `el.style` (e.g. a property map keyed `"strokeDashoffset"`), `el.style.transition = "strokeDashoffset 0.3s ease"` is silently treated as an unrecognized custom-ident — no error, no exception, the property value you set afterward just snaps instantly with zero interpolation. Confirmed empirically: `getAnimations()` stayed empty the whole time. Keep a small name map (`{ opacity: "opacity", strokeDashoffset: "stroke-dashoffset" }`) and use the hyphenated form specifically for the `transition` string, even though you use the camelCase form everywhere else (`el.style.strokeDashoffset = ...`).

**If the unit already has a "cancel the previous animation" step, measure the live value *before* calling it, not after.** A retrofit that already calls something like `el._animCancel()` at the top of its "start toward target X" function looks like it's already doing stop-and-retarget correctly — it is stopping first. But if that cancel handler clears the inline style override that was holding the live interpolated value (e.g. resetting `max-width`/`max-height` back to `''` so the element reverts to its CSS-natural size), then measuring `from` *after* the cancel reads the natural size for whatever class/attribute state is still active — which, if the class toggle for the new direction hasn't happened yet either, is the *previous* target's fully-arrived state, not the live mid-transition value. The element then visibly snaps to that stale full state for one frame before the new transition carries it toward the real target. The fix is purely about statement order: snapshot the live rect (or value) *before* touching anything the cancel handler clears, even though the cancel handler itself must still run (to stop the old transition and reset bookkeeping) before the new target is computed and applied.

**Clearing the inline override on `transitionend` can snap the element to the wrong rest state.** It's tempting to "clean up" after a retarget by blanking the animated property back to `""` once the transition finishes, so later unrelated style changes don't inherit a stray `transition` declaration. But once the *real* keyframe/animation this property used to be driven by has been permanently cancelled (as it has, by this point, in every retarget path), the base non-animated stylesheet rule is whatever its single static value is — usually the *hidden* rest state, regardless of which direction just finished. Blanking the override after a retarget that just finished *arriving* (not leaving) snaps the element invisible again. Only clear `transition` itself in the cleanup; leave the animated property pinned at its `to` value for as long as this JS-driven scheme is in control of the element. This is easy to miss because it's invisible exactly when the retarget's target happens to coincide with the base rule's value (e.g. a reverse-to-hidden retarget, where hidden *is* the base value) — it only shows up once you test the *other* direction (a forward retarget settling at "shown").

```js
function retarget(el, direction) {
  el.style.transition = direction === "forward"
    ? `transform ${DUR}ms ${FORWARD_EASE}, opacity ${DUR}ms ease-in`
    : `transform ${DUR}ms ${REVERSE_EASE}, opacity ${DUR}ms ease-out`;
  el.style.transform = direction === "forward" ? FORWARD_TARGET : "";
  el.style.opacity = direction === "forward" ? "0" : "";
}
```

### `requestAnimationFrame`/manual-tween flavor

There's no browser-native live value to query, so the frame loop itself must record the current interpolated value every tick (e.g. `el._currentPts = pts;` inside the frame callback), and "stop" must explicitly `cancelAnimationFrame` the stored id before anything else starts.

**The subtle trap**: if the forward and reverse passes are driven by *different functions* (`morphOne()` vs. `reverseMorphOne()`, say), it's tempting to assume removing a stagger delay is enough to make the interrupt immediate. It isn't, if the "start fresh" function unconditionally tears down and recreates whatever DOM node/proxy carries the animation. Interrupting a live reverse by calling a forward function that deletes the current (visible, mid-tween) element and builds a brand-new invisible one — even if it fades back in over a short crossfade — *is* a visible snap-then-play, just a subtler one than a full teleport. The fix: make the "start" function reuse a live handle/element if one already exists, continuing its tween from the recorded current value, and only build fresh when there's genuinely nothing live (idle/settled state).

```js
function ensureProxy(el, state) {
  if (state.proxy) return state.proxy; // reuse whatever is already live
  const proxy = createProxyAtRestPosition(el);
  state.proxy = proxy;
  return proxy;
}

function animateToward(el, state, targetPts) {
  const proxy = ensureProxy(el, state);
  const fromPts = proxy._currentPts || sourcePts(el); // live value if mid-tween, else the rest position
  tweenShape(proxy, fromPts, targetPts, DURATION); // tweenShape itself must cancelAnimationFrame(proxy._raf) first
}
```

If the effect has *sub-phases* driven by different functions (e.g. "morph shape" then "fly away", reversed as "fly back" then "unmorph shape"), the forward dispatcher needs to pick the right *resume point* based on live state, not always re-enter from the first phase:

```js
function startOrResume(el, state) {
  if (state.phase === "reversing-phase-2") {
    resumePhase2Forward(el, state); // already past phase 1, redirect phase 2 in place
  } else {
    startOrResumePhase1(el, state); // idle, or still mid phase-1 reverse — continues or starts phase 1
  }
}
```

### Timeline-library flavor

Store the live instance handle on the unit (`el._tl = tl`). To reverse, call the library's native reverse primitive (`tl.reverse()`, `playbackRate = -1`) on the *same instance* — never instantiate a fresh one, and never force a hard reset/seek-to-start first. A manual `tl.reset()` "to unstick" the timeline before reversing causes every child to render its pristine start state synchronously, which is the same snap-then-play bug in timeline-library form.

**anime.js-specific trap, found only by testing a *second* redirect, not just the first**: calling the same instance's `.reverse()` twice — redirecting forward→backward, then backward→forward again before it settles — snaps to time 0 on the second redirect, with no code-visible reason if you've only read the call sites. The cause is inside the library: `instance.reverse()` unconditionally sets `instance.completed = true` the moment it flips back to the forward direction (it's designed for a one-shot "play backward until done," not a repeatedly-toggled live redirect), and `instance.play()` hard-resets anything it finds `completed` before resuming. Confirmed via an isolated instrumentation harness logging `currentTime`/`reversed`/`completed` across each pause/reverse/play call — the first redirect preserved `currentTime` correctly, the second silently reset it to 0 right inside `.reverse()`, before `.play()` even ran. Fix: immediately after calling `.reverse()`, if it landed back on forward (`!instance.reversed`), clear `instance.completed = false` yourself before the next `.play()`. Generalizes to any anime.js-driven reversible instance — wrap this into whatever helper calls `.reverse()`, and apply it per-instance if several are bundled behind one combined play/pause/reverse surface.

**Deriving a discrete state (which string to show, which class to apply) from a continuous tween: use elapsed time, not a tweened property's value.** A punchline effect that collapses an element then pops it back up past its normal size and swaps its text content partway through is a natural candidate for a single `keyframes` instance instead of two phase-chained calls (see §3's sub-phase note) — but if the text swap is keyed off a tweened value crossing a threshold (e.g. `scale < 0.5`), it breaks the moment any segment uses an overshooting easing (`easeOutBack`, `easeOutElastic`, ...): the pop segment's scale rises *past* 1 before settling, so scale is not monotonic across the full range, and reversing from the settled end retraces that overshoot bump — the value climbs back above the threshold and down again, flickering the discrete state back and forth on every redo. Confirmed by watching the live value do exactly this (rise to ~1.09 before descending) when reversing a fully-popped instance. Fix: read `instance.currentTime` (passed as the first argument to anime.js's `update` callback) against the segment boundary's own fixed duration, instead of comparing a tweened property value against a threshold. Elapsed time is monotonic in either playback direction regardless of easing shape; a tweened value generally isn't once any segment overshoots.

### CSS-transition/keyframe flavor with no event-time read available at all

Normally (§3's CSS-transition and CSS-`@keyframes` flavors) the live value is readable synchronously inside the `fragmentshown`/`fragmenthidden` handler — the handler runs, *then* you read `getComputedStyle`. But if the only thing driving the animation is a plain CSS rule keyed off the fragment's own visibility class (e.g. `.fragment.visible .thing { animation: draw 0.5s forwards; }`, with no separate JS-managed class/attribute of your own), removing that class is what both triggers the event *and* kills the animation — and reveal.js removes the class **before** firing `fragmenthidden`. By the time your handler runs, `getComputedStyle` already reflects the reverted-to-base value, not the live one. This isn't a timing-sensitive race to tighten; it's unrecoverable *within the event*, confirmed by reading the value from inside a synchronous `fragmenthidden` listener itself (already reverted) and even from a `MutationObserver` microtask watching the class attribute change (also already reverted — the engine applies the cascade effect of the class removal eagerly, not lazily on next query).

The fix is to treat this like the manual-tween flavor even though nothing is "manual": run your own `requestAnimationFrame` loop that samples `getComputedStyle` once per frame for as long as `el.getAnimations()` reports something running, and have every retarget read the *last sample taken before the event*, not a value read during or after it. A `WeakMap` of `el → { value, t }` plus a `maxAgeMs` staleness cutoff (generous — one frame is ~16ms, so even 100ms leaves headroom) works:

```js
var liveSamples = new WeakMap();
var watched = new Set(); // { el, prop }
var rafId = null;

function isLive(el) {
  // Treat CSSAnimation *and* CSSTransition as live — once a retarget has
  // replaced the keyframe with a JS-driven transition, that transition is
  // what must now be sampled, not the (permanently cancelled) animation.
  return el.getAnimations().some(a => a.playState === "running" || a.playState === "paused");
}

function tick() {
  watched.forEach(entry => {
    if (isLive(entry.el)) {
      liveSamples.set(entry.el, { value: sample(entry.el, entry.prop), t: performance.now() });
    } else {
      watched.delete(entry);
    }
  });
  rafId = watched.size ? requestAnimationFrame(tick) : null;
}

function watch(el, prop) {
  for (const e of watched) if (e.el === el) return; // already tracked
  watched.add({ el, prop });
  if (rafId === null) rafId = requestAnimationFrame(tick);
}

function lastLiveValue(el, maxAgeMs) {
  const entry = liveSamples.get(el);
  if (!entry || performance.now() - entry.t > maxAgeMs) return null;
  return entry.value;
}
```

Call `watch()` every time you start *any* animation on the element — the fresh-start (CSS-only) path included, not just the JS-driven retarget path — so the loop is already running by the time a later interrupt needs a sample from it.

**The trap that will bite you on the *second* interrupt, specifically**: if your retarget function sets the frozen "from" value, then defers setting the "to" value to the next `requestAnimationFrame` (a seemingly-harmless "let the browser paint the frozen value first" precaution), there's a one-frame window where a `transition` is declared but the property hasn't actually changed yet — and `getAnimations()` reports nothing running during exactly that window. If this sampling loop's own `tick()` happens to run during that window (a real race: both your deferred "set to" callback and the next `tick()` are separately-queued `requestAnimationFrame` callbacks, and the browser runs them in registration order, not a guaranteed order relative to each other), it sees "not live," stops watching, and never restarts on its own — nobody calls `watch()` again until some *other* event does. The result: a later interrupt reads a stale/missing sample and falls back to the full start/end value, producing a visible "snap to start, then proceed smoothly" on exactly the second redirect, not the first — exactly the kind of bug a single-interrupt test won't catch (see §5's "test every direction, twice" note). Fix: don't defer the "to" assignment at all. Set it synchronously, immediately after the forced reflow that commits the frozen "from" value — the classic `transition: none` → set "from" → reflow → `transition: <real>` → set "to" sequence reliably starts the transition within the same synchronous block, with no `requestAnimationFrame` needed, and no gap for the sampling loop to misread as "nothing running."

### WAAPI/FLIP flavor with ephemeral overlay clones

Some effects (FLIP-style diff animations — e.g. a code/text diff that clones outgoing tokens onto an absolutely-positioned overlay layer so they can fade out independently of the real DOM swap) don't have one persistent element per unit at all: the "exiting" element is a **freshly-created clone**, appended to a shared container, animated via `element.animate()`, and self-removed on `.finished`. A later call's own clones for the *same* logical content are different DOM nodes with no relationship to the earlier call's clones — there's no single handle to store the "is this one still live" check on.

The fix is a **wrapper-level registry**, not a per-unit handle: track every live clone (element + its `Animation`) in an array stashed on the shared container itself, and unconditionally cancel + remove every entry in that array at the start of every call, before creating this call's own clones. Also track any shared container-level `Animation` the same way (e.g. a height transition keyed to content size), since it's equally orphan-prone. A generation counter on the container gates any `.then()`/`.finished` cleanup a *previous* call's clones scheduled (e.g. resetting `overflow`), so an interrupted call's own stale completion handler can't clobber state the new call still depends on:

```js
function animateToStep(container, fromStep, toStep) {
  const wrapper = container.closest(".diff-wrapper");

  // stop-and-retarget: tear down the previous call's still-fading clones
  // and in-flight container animation before building anything new — their
  // own `.finished` cleanup only runs on their original schedule, which is
  // well after this call has already moved on.
  (wrapper._activeClones || []).forEach(({ clone, anim }) => { anim.cancel(); clone.remove(); });
  wrapper._activeClones = [];
  wrapper._heightAnim?.cancel();
  const myGen = (wrapper._gen || 0) + 1;
  wrapper._gen = myGen;

  // ...build this call's own clones, pushing { clone, anim } entries onto
  // wrapper._activeClones (and splicing each back out again on its own
  // `.finished`)...

  wrapper._heightAnim = someHeightAnimation;
  someHeightAnimation.finished.then(() => {
    if (wrapper._gen !== myGen) return; // a later call already took over
    wrapper.style.overflow = "";
  });
}
```

Real per-unit "move"/"enter" animations in this same kind of effect often need **no fix at all**, and it's worth confirming that before adding one: if positions are measured via `getBoundingClientRect()` *before* the DOM is swapped to the new step, that measurement already reflects the true live interpolated position of any still-running WAAPI animation — browsers commit a live animation's current value to layout, not just paint. If the DOM swap then unconditionally recreates every unit's element (wiping any previous animation via removal), the whole thing is already a correct live retarget with zero extra code, because the "stop" is implicit in the DOM wipe and the "retarget" source value was captured correctly beforehand. Confirm this by reasoning about measurement order, not by assuming every animated property needs the registry treatment above — only ask for it where a `.finished`-driven cleanup can run *after* a conflicting call has already started.

### CSS `@keyframes` flavor

Since the browser won't interpolate a reassigned `animation-name` from the live value, convert the interrupt case into the CSS-transition flavor instead: snapshot the live computed value, cancel the stale keyframe animation, freeze the snapshot as inline `opacity`/`transform`, then retarget via an explicit CSS *transition* toward the *target animation's own declared end state* — not a generic neutral value. This still generalizes across an entire named-animation library without needing to hand-author each animation's logic, because you're reading the SAME `@keyframes` data the browser would already use, just picking it up yourself instead of letting a fresh `animation-name` assignment snap to it.

```js
// Looks up a @keyframes rule's own final step (its true "arrived" state —
// e.g. an exit animation may end translated/scaled away, nowhere near
// identity). Interrupting mid-flight must converge on wherever the
// animation would have *actually* ended up, not a generic rest value.
const keyframeEndCache = {};
function getKeyframeEndState(name) {
  if (name in keyframeEndCache) return keyframeEndCache[name];
  let result = null;
  for (const sheet of document.styleSheets) {
    let rules;
    try { rules = sheet.cssRules; } catch (e) { continue; } // cross-origin sheets throw
    for (const rule of rules || []) {
      if (rule.type === CSSRule.KEYFRAMES_RULE && rule.name === name) {
        let best = null, bestPct = -1;
        for (const kf of rule.cssRules) {
          const pct = kf.keyText === "to" ? 100 : kf.keyText === "from" ? 0 : parseFloat(kf.keyText);
          if (!isNaN(pct) && pct >= bestPct) { bestPct = pct; best = kf; }
        }
        if (best) result = { opacity: best.style.opacity || null, transform: best.style.transform || null };
      }
    }
  }
  keyframeEndCache[name] = result;
  return result;
}

function retarget(el, animationName) {
  const anims = el.getAnimations().filter(a => a.animationName && a.playState !== "finished" && a.playState !== "idle");
  if (anims.length === 0) return false; // nothing live — let the fresh-start path run instead
  const cs = getComputedStyle(el);
  const liveOpacity = cs.opacity, liveTransform = cs.transform;
  anims.forEach(a => a.cancel());

  // `.cancel()` immediately reverts computed style to the plain,
  // non-animated cascade — usually indistinguishable from the animation's
  // own *end* state (a correctly authored entrance settles there anyway).
  // Re-freeze the live snapshot in the very next statements, before
  // anything else touches the element's rendered style, so if the browser
  // paints before the retarget transition is set up, it paints the live
  // snapshot, not a flash of "the end".
  el.style.transition = "none";
  el.style.opacity = liveOpacity;
  el.style.transform = liveTransform;
  // The fragment library's own visibility-toggle class has already been
  // applied/removed by this point (reveal.js does that before firing
  // fragmentshown/fragmenthidden) — `visibility` isn't animatable, so force
  // it visible for the duration of the transition or the element
  // vanishes/reappears instantly regardless of how opacity fades.
  el.style.visibility = "visible";
  void el.offsetHeight; // commit the frozen snapshot as the transition's starting point

  // Target `animationName`'s own final keyframe, not a generic neutral
  // value. Fall back to measuring the stylesheet's natural value (off a
  // *detached clone*, never the live element, since stripping/re-reading a
  // property directly on the live element exposes the same "looks like the
  // end" flash as skipping the re-freeze above) for whichever property the
  // keyframe doesn't explicitly declare at its end.
  const endState = getKeyframeEndState(animationName);
  let targetOpacity = endState && endState.opacity;
  let targetTransform = endState && endState.transform;
  if (!targetOpacity || !targetTransform) {
    const probe = el.cloneNode(false);
    probe.removeAttribute("style");
    probe.style.position = "absolute";
    probe.style.visibility = "hidden";
    el.parentNode.insertBefore(probe, el);
    const naturalCs = getComputedStyle(probe);
    if (!targetOpacity) targetOpacity = naturalCs.opacity;
    if (!targetTransform) targetTransform = naturalCs.transform;
    probe.remove();
  }

  el.style.transition = `opacity ${DUR} ease, transform ${DUR} ease`;
  el.style.opacity = targetOpacity;
  el.style.transform = targetTransform;
  return true;
}
```

**Four traps found only by testing every direction on every animation family, not just the one first fixed**: (1) forcing `visibility: visible` only belongs on the *fresh-start* path in most existing code (it's only needed while something is mid-transition toward hidden) — when adding the retarget branch, it's easy to carry over the old code's `if (exitDirection)` condition and forget the retarget needs it unconditionally too, since the live snapshot/target swap happens regardless of direction. (2) hardcoding the opacity target as `0`/`1` based on "hidden" vs "shown" works for the common convention but silently breaks any animation family whose own CSS inverts it — test *every* distinct animation class in both directions, not just one representative per family, since this kind of inversion is invisible by code-reading alone and only shows up empirically. (3) **`element.getAnimations()[i].cancel()` doesn't just stop the animation — it immediately reverts the element's computed style to the plain, non-animated cascade**, which for a `.visible` fragment usually reads as "fully entered" (opacity 1, untransformed), identical to the animation's own end state. Any code between `.cancel()` and re-freezing the live snapshot — even something as seemingly inert as measuring the natural target opacity by temporarily stripping the live element's own `opacity`/`transform` — exposes a real, paintable window where the element's committed style is "the end," producing a visible jump-then-reverse that every `getComputedStyle` poll will miss (polling at arbitrary intervals samples the *settled* value a transition is heading toward or already at, not a flash that exists for a single paint between two synchronous statements). Re-freeze the live snapshot in the *very next* statements after `.cancel()`, and if you need to measure a natural/unoverridden style value, do it on a detached clone (`el.cloneNode(false)` with its `style` attribute stripped, inserted as an invisible sibling so it inherits the same cascade), never on the live element. This trap specifically requires an *exposed paint* between the cancel and the re-freeze — if every statement from `.cancel()` through assigning the new transition runs synchronously with no `await`/`requestAnimationFrame`/timer in between, the browser never gets a chance to paint the reverted-to-cascade value, so reading it (e.g. as a FLIP "from" measurement, where the reverted cascade value is *exactly* the correct pre-swap measurement you want) is safe; the danger is specifically an `async` boundary or a forced-layout-then-yield between the two, not `.cancel()` itself. (4) **Hardcoding the transform target to `"none"` (identity) looks fine for position-only families but is quietly wrong for any family whose own end keyframe lands somewhere else** (e.g. an exit animation that ends translated/scaled far away, not at identity) — the element will smoothly, continuously interpolate *toward the wrong place*: no snap, no discontinuity, `getComputedStyle` polling at any granularity (even per-`requestAnimationFrame`) reads perfectly smooth values the whole way, and the bug is still completely visible, because it's directional, not discontinuous. It reads as "it finishes arriving, *then* reverses" because the transform keeps progressing toward the entrance's own completed look while only opacity reverses — polling won't catch this since nothing it measures is ever wrong *at a point in time*, only wrong as a *trajectory*. The fix is `getKeyframeEndState()` above: read the actual target animation's own declared end keyframe from the CSSOM and use it, rather than assuming identity or deriving a target purely from the non-animated stylesheet cascade (which has no opinion on `transform` at all — it's exclusively animation-driven, unlike `opacity`, which usually does have a static hidden/shown baseline worth measuring).

**The trap that will bite you immediately**: `getAnimations()` returns *every* animation affecting the element, including plain CSS Transitions — and reveal.js's own core CSS gives every `.fragment` a default `transition: all .2s ease`, which starts a real (if generic) opacity transition the moment the `visible` class is toggled, *before* your `fragmentshown`/`fragmenthidden` handler even runs. Only a `CSSAnimation` instance exposes `.animationName`; a `CSSTransition` does not. Filtering on `a.animationName` (as above) is required, or this reads reveal's own fade-in as "a live custom animation" on literally every fragment's first-ever entrance — not just interrupts — and retargets toward the wrong thing. This is especially costly for any animation whose own keyframes end at `opacity: 0` by design (an "exit" animation used standalone as a one-shot entrance, say): with the filter missing, the false-positive forces the forward target to `opacity: 1` instead, freezing the element fully visible and never actually playing its animation at all. Symptom to watch for: an effect that *looks* like it's doing a generic fade (right duration, right direction, but no transform motion at all) is usually this trap, not a correctly-running keyframe animation — the giveaway is `getComputedStyle(el).animationName` reading `"none"` when it should name your animation.

**Check for a `prefers-reduced-motion` carve-out before wiring in any retarget path.** Several of these extensions already have a `@media (prefers-reduced-motion: reduce)` block that keeps the element permanently in its "arrived" state via a plain, unconditional class rule (not scoped to `.visible`), specifically so a reduced-motion user never sees the entrance/exit animation at all. An inline-style retarget that runs unconditionally will still apply — and inline styles outrank a plain class rule — silently re-introducing the fade/motion the user asked to avoid, even though no keyframe or transition ever "plays" in the sense the rest of this skill cares about. Guard the whole retarget mechanism with `window.matchMedia("(prefers-reduced-motion: reduce)").matches` checked once at setup, and no-op entirely when it's true, leaving the existing reduced-motion CSS in sole control.

### CSS `@keyframes` flavor via a static inline start value (stroke-dash draw-in)

A sibling case to the Animate.css/Magic.css flavor above, with a different failure mechanism: an SVG "draw the stroke in" effect commonly sets `stroke-dashoffset` to the path's full length as an inline style *once*, at animation-start time, then assigns a `@keyframes` animation (`to { stroke-dashoffset: 0; }`) to interpolate it down to 0. The inline value is never updated while the keyframe runs — the CSS engine interpolates the *computed* value internally without writing anything back to `element.style`. That means `getComputedStyle` correctly reports the live value at any point while the animation is live, but the moment you cancel it (`element.style.animation = "none"`), the computed style falls back to the stale inline value (still the pre-animation full length), not the live interpolated one — a real, if easy-to-miss, discontinuity distinct from both the WAAPI-`.cancel()` trap (reverts to the non-animated *stylesheet* cascade) and the "no event-time read available" case (the live value is already gone by the time any handler runs). Here the live value **is** available synchronously — you just have to capture it with `getComputedStyle` and write it back as the new inline value in the same synchronous step as cancelling, or the fallback-to-stale-inline-value snap happens anyway:

```js
const liveOffset = parseFloat(getComputedStyle(path).strokeDashoffset) || 0;
path.style.animation = "none";       // would otherwise fall back to the stale inline value...
path.style.strokeDashoffset = liveOffset; // ...so pin it to the live value in the same tick
```

Confirmed empirically (`quarto-roughnotation`): without this, interrupting a fragment's draw-in mid-flight produced a double-snap — first back to fully-undrawn (the cancel-reverts-to-stale-start-value trap above), then forward to fully-drawn (a second, independent bug: the reverse animation's own start value was hardcoded to `"0"` instead of the just-captured live offset). Fixing only the first half still leaves the second: the reverse/undraw pass must also start from the captured live value, not an assumed "fully arrived" one — the same "retarget from the live value, never a nominal one" rule as every other flavor in this skill, just with two independent places (`cancel` and `re-trigger`) where a hardcoded nominal value can sneak back in.

## 4. Fix staggered choreography

For multi-unit effects (many marks falling/morphing on independent per-unit delays): a unit that is *currently* mid-flight must redirect on its next tick, never deferred to its position in a stagger schedule. Units that haven't started yet, or are already fully settled, can keep a nice mirrored stagger (time-reflection: schedule the reverse pass in the reverse order) since there's nothing live to interrupt for them.

```js
order.forEach((unit, i) => {
  // A unit whose turn hasn't come up yet still has a *pending* timer from
  // the direction being interrupted — cancel it before scheduling this
  // one's. Skipping this is invisible to isLive()/getAnimations(), since
  // nothing is running yet; the stale callback just fires later on its own
  // original schedule, redirecting the unit on its own regardless of what
  // this navigation decided.
  if (unit._pendingTimer) clearTimeout(unit._pendingTimer);

  const live = isLive(unit.state);
  // A unit this direction has nothing to do for — e.g. undoing a reveal
  // and this unit was never shown yet (not live, not already revealed) —
  // must be skipped entirely, not scheduled with a stagger delay. The
  // fresh-start path (what runs when nothing is live) assumes it's playing
  // a real transition *from* the unit's current fully-settled appearance;
  // calling it on a unit that was never touched pops it through that
  // transition's own starting look before animating it back, a real (if
  // brief) unwanted appearance — not just a style-flash artifact.
  const alreadyInTargetState = isDirectionAlreadyDone(unit, direction); // e.g. already revealed and not live, when revealing again
  if (alreadyInTargetState) return;

  // Only a unit that's actually live needs the immediate override — idle
  // or already-settled units are fine waiting their turn in the mirrored
  // stagger schedule.
  const delay = live ? 0 : i * STAGGER_MS;
  unit._pendingTimer = setTimeout(() => { unit._pendingTimer = null; retarget(unit); }, delay);
});
```

**A second staggered-choreography trap, distinct from the live-animation one above**: a unit that *hasn't started yet* has no running animation for `isLive()`/`getAnimations()` to see, but it still has a pending `setTimeout` queued from whichever direction is being interrupted. If that timer is never cancelled, it fires on its own original schedule regardless of the new direction — showing (or hiding) that unit well after the navigation that was supposed to supersede it. This reliably produces "some of the last units in the sequence are stuck in the wrong state" after an *early* interrupt (one that happens before most units have had their stagger turn), since those are exactly the units whose timers are still pending when the direction flips. Store the timer handle on the unit itself and clear it before scheduling a new one in *either* direction's loop — the live-animation check and the pending-timer check are both required; neither one covers the other's failure mode.

**A third staggered-choreography trap, which surfaces only once the first two are already fixed**: cancelling the stale timer stops a never-reached unit from getting stuck in the wrong state *forever*, but it's still wrong to schedule a real transition for that unit at all. A unit this direction has nothing to do for (undoing a reveal, and this particular unit was never shown — not live, not already revealed) must be *skipped*, not merely rescheduled with the normal stagger delay — otherwise it still briefly plays through the fresh-start path (pops to its transition's own starting appearance, then animates away/in), which reads as "it flickers into existence, then fades" rather than "nothing happens." The tell that distinguishes this from the first trap: the unit is no longer stuck, it visibly (if briefly) *moves* when it shouldn't move at all. Check both the live-animation state and whatever marks a unit as "already settled in the direction's target state" (a CSS class the fresh-start path itself sets, typically) before deciding whether to schedule anything.

**Watch for a false sense of security here**: the *first* unit in a stagger order always gets `delay = 0` anyway (`0 * STAGGER_MS`), with or without this fix. If you're validating the fix against a specific unit, make sure it's one whose position in the schedule is *not* already 0 in the direction you're testing — otherwise the test can pass identically on the buggy and fixed code, having never actually exercised the live-state check. (This also means: when picking a *reverse*-order position 0 unit, that's the *forward*-order's *last* position — exactly the unit most exposed to the original bug, and the best one to use for proving the fix.)

## 5. Verify

Add a Playwright test that exercises the interrupt-mid-animation case in both directions, asserting on *real-time* behavior a short, fixed delay after the direction change — not eventual settled state. That's the test category whose absence lets this bug ship in the first place.

Practical pitfalls, from building this out end-to-end:

- **Assert direction, not just "something changed."** A transform/value reading will differ moment-to-moment whether or not the fix works, since time passes either way. Capture a before/after pair across the interrupt and assert the value actually moved *toward the new target* (e.g. `expect(afterY).toBeLessThan(beforeY)` for a reversal), not merely that it's different.
- **Pick units deterministically, not by scanning for "any unit in the right state."** With a randomized or long stagger spread, "find the first unit currently mid-flight" risks grabbing one that *just* started a moment ago and hasn't visually progressed — producing a flaky false negative. Prefer a unit at a known, fixed position in the recorded order (e.g. the array's own `order[0]`, guaranteed to start at delay 0 and therefore reliably well into its animation by a fixed wait).
- **For element-identity continuity (the manual-tween/proxy flavor), assert the DOM node itself didn't change** — tag it with a test-only marker (`el.dataset.testMarker = "..."`) and confirm the same marker survives the interrupt — not just that a state flag flipped to the expected string. A state label can say the right thing even if the underlying element was quietly torn down and rebuilt.
- **Also assert a concrete visual-continuity signal**, like opacity not dipping. A torn-down-and-rebuilt element reusing the same state labels can still be caught this way: a fresh element fading in from `opacity: 0` reads very differently, sampled 10-20ms after the interrupt, than a continuously-opaque one that was never recreated.
- **Watch for async setup races.** Effects that lazily prepare the DOM (inlining an `<img>` as `<svg>`, wrapping text in spans) on `fragmentshown`/`ready` can mean a test that presses the fragment key too early finds nothing to interrupt — the setup silently hasn't finished, so the forward/reverse handler no-ops. Wait for a concrete setup-complete marker (a `data-*` attribute set once setup finishes) before interacting.
- **Watch for test-runner CPU contention.** These assertions race real `setTimeout`/CSS-transition/`requestAnimationFrame` timing against wall-clock waits; running many browser instances in parallel (Playwright's default worker pool) can starve one enough to blow through the short windows these tests depend on. Pin `workers: 1` for this kind of test rather than chasing a flaky retry.
- **Never call a screenshot method between triggering the interrupt and asserting on the pre-settle DOM state — including `Locator.screenshot()` or `Page.screenshot()`, not just `expect().toHaveScreenshot()`.** `Locator.screenshot()` performs its own actionability "stability" wait (the element's bounding box must stop changing) before it returns, which silently waits out exactly the kind of orphaned/stale animation this test exists to catch — the assertion checked afterward then finds everything already settled and passes on *both* the buggy and the fixed code. This is a real false negative, found only by deliberately confirming the test fails against `git stash`'d pre-fix code (do this for every test in this category, not just the first one written) — don't trust a doc comment elsewhere in the codebase claiming a particular screenshot API has no such wait without re-verifying it for the specific assertion you're adding. Check DOM/animation state via a plain `locator.evaluate()` (or `page.evaluate()`) first; only take screenshots afterward, purely for the visual-sanity record.
- **Verify you're actually testing your own edits, not a stale server.** If anything reuses a webServer across runs (Playwright's `reuseExistingServer`, or a hand-started dev server), a leftover process from an earlier session — even an unrelated one, in a different worktree — can already be bound to the port your config expects, silently serving its own stale snapshot while your fix appears to do nothing no matter how many times you re-render. `lsof -i :<port>` before trusting a "the fix didn't work" result from manual browser probing, especially if the port is a fixed default (reveal.js/Playwright test setups commonly reuse 4173-ish ports across unrelated projects and sessions).
- Take a mid-interrupt screenshot per effect as a cheap visual sanity check alongside the assertions.

## 6. Reference implementations

- **`quarto-revealjs-cursor-fragments`** (`_extensions/cursor-fragments/cursor-fragments.js`) — timeline-library flavor. Stashes the live anime.js timeline on the element (`el._fxTl`); reverses by calling `.reverse(); .play()` on the same instance, never a fresh one.
- **`quarto-revealjs-zoom`** (`_extensions/zoom-vp/zoom-vp.js`) — hand-rolled rAF flavor, position-only. `animateTo()` always calls `stop()` first, then starts a fresh rAF loop that recomputes the interpolation from the camera's *current live position* every tick. No separate reverse code path at all — forward and backward both go through the same unconditionally-safe function.
- **`quarto-revealjs-more-fragments`** (`_extensions/more-fragments/more-fragments.js`) — CSS `@keyframes` flavor (Animate.css/Magic.css classes assigned via `animation-name`), and the fullest worked example in this skill — every trap in §3 and §4 was found here, in order, each only after the previous fix was verified: the `a.animationName` liveness filter (excluding reveal.js's default fragment fade), the `getKeyframeEndState()` CSSOM lookup (hardcoding the transform target to identity was visually wrong, smoothly, for the `backInDown`/`backOutUp` pairing), the re-freeze-immediately-after-`.cancel()` ordering plus detached-clone measurement (the "looks like the end" flash), and both staggered-letter fixes (`_fragTimer` cancellation, and skipping units with nothing to undo). Worth reading end-to-end as the single example that shows why each fix alone looked complete until tested further.
- **`quarto-revealjs-magic-move`** (`_extensions/magic-move/magic-move.js`, `animateToStep()`) — WAAPI/FLIP flavor with ephemeral overlay clones (the registry pattern above). A div-based code-diff animation that clones exiting tokens onto an overlay layer each call; interrupting mid-exit left the previous call's clones orphaned, still fading on top of the new step's content, since nothing cancelled them. Also the source of the screenshot-masks-the-bug verification trap in §5: the first version of this fix's test passed identically on buggy and fixed code until the `Locator.screenshot()` call was moved to *after* the DOM-state assertion instead of before it.
- **`quarto-revealjs-plot-exit`** (`custom.html`, not in this org's `~/Github` — lives alongside the deck it animates) — mixed CSS-transition (gravity-exit's fall/return) and manual-tween (bats-exit's SVG shape morph) flavor. The bats fix is the fullest worked example of the proxy-reuse subtlety in §3: `morphOne()` now reuses a live proxy via `ensureProxy()` instead of recreating it, and a `startOrResumeForward()` dispatcher picks between resuming the shape-morph phase or the flight phase based on live state, not always re-entering from the first phase.
- **`quarto-revealjs-chat-bubbles`** (`_extensions/chat-bubbles/chat-bubbles.js`, `animateBubble()`) — CSS-transition flavor, the worked example for "measure before you cancel, not after" above. The typing-bubble dots-to-text expand/collapse already called `bubble._animCancel()` first, which looked like correct stop-and-retarget — but the cancel handler cleared the `max-width`/`max-height` override before the live rect was measured, so an interrupt mid-expand read the *previous* call's fully-arrived natural size as `from`, snapping to it for a frame before transitioning toward the real target. Fixed by moving the `getBoundingClientRect()` snapshot to before the cancel call, with no other change needed since `to` was already measured correctly, after the class toggle.
- **`quarto-arrows`** (`_extensions/arrows/resources/arrows-fragment.js`) — the worked example for "no event-time read available at all" above. The arrow's draw-in is a plain `.fragment.visible .path { animation: draw forwards; }` rule with no reverse animation authored at all; reveal.js removes `.visible` before firing `fragmenthidden`, so the live `stroke-dashoffset`/marker-opacity value is already gone by the time any handler or `MutationObserver` can read it — confirmed by trying both. Fixed with the continuous-`requestAnimationFrame`-sampling technique, and the source of three of the traps documented above in the order they were actually hit: the camelCase-vs-hyphenated `transition` string (silently produced zero animation), the deferred-"to"-assignment race with the sampling loop's own tick (caused a snap-to-start on the *second* interrupt only, not the first), and the cleanup-blanking-to-base-value bug (a forward retarget settled back at fully-hidden instead of fully-drawn, invisible in the reverse direction since hidden was already the base value there). Also added the `prefers-reduced-motion` guard, since this extension's own reduced-motion CSS keeps the marker permanently opaque via an unscoped class rule that the retarget's inline opacity would otherwise have outranked.
- **`quarto-roughnotation`** (vendored `_extensions/roughnotation/assets/rough-notation.iife.js`, `hide()`) — the worked example for the "static inline start value" sub-flavor above. Unlike `quarto-arrows`, the live `stroke-dashoffset` *was* synchronously readable via `getComputedStyle` inside the JS-driven `hide()` call (this one has its own JS object managing the animation, not a bare CSS rule) — the bug was simply never reading it, in two independent places: cancelling the draw-in animation without re-pinning the live value first (falls back to the stale full-length inline value set once at render time), and then hardcoding the reverse animation's start offset to `"0"` instead of that live value. Confirmed empirically with a headless Playwright probe sampling `getComputedStyle` immediately before/after an interrupt: pre-fix, a draw-in interrupted at ~20% drawn snapped to 0% then to 100% before the undraw animation even started; post-fix, the offset is continuous across the interrupt and the undraw starts exactly where the draw-in left off.
- **`quarto-timeline`** (`_extensions/timeline/timeline.js`, the `fragment-slide`/`fragment-conveyor` pan handlers) — a worked example of the "no fix needed" recognition case in §3's CSS-transition flavor, not another retrofit. The pan is a single `timeline.style.transform = 'translateX(...)'`/`'translateY(...)'` reassignment against one plain `transition: transform 0.5s ease` rule, with no reset step and no stagger. Confirmed empirically (not just by code-reading): Playwright-driven, advancing 5 fragments then interrupting mid-transition with a backward press showed the live `transform` decelerate smoothly out of its forward trajectory and land exactly on the correct (4-fragment) target, with no snap or wrong-direction coast.
