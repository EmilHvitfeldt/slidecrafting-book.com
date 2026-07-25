# Floating paper card slides

References:
- https://slidecrafting-book.com/layout

Elevate each slide's content into a floating "paper" card above the background, so background decoration never collides with text.

## The card

```scss
/*-- scss:rules --*/
.reveal .slides section.paper {
  width: 92%;
  height: 86% !important;
  max-height: 86% !important;
  left: 4% !important;
  top: 6% !important;
  border-radius: 4px;
  padding: 40px;
  box-sizing: border-box;
  overflow: hidden;
  background-color: #fdfcfa;
  box-shadow:
    0 2px 4px rgba(0, 0, 0, 0.1),
    0 8px 24px rgba(0, 0, 0, 0.15),
    0 16px 48px rgba(0, 0, 0, 0.1);
}
```

`!important` is needed because Reveal.js sets slide position via inline styles.

## Usage

Set a background on the slide; it fills the viewport behind the card:

```markdown
## My Slide {.paper background-color="#ffe83e"}

Content, cleanly inside the card.
```

```markdown
## My Slide {.paper background-image="photo.jpg" background-size="cover"}
```

## Card as default

Change the selector from `section.paper` to `section` to make every slide a card, and add a `.paperless` opt-out:

```scss
.reveal .slides section { /* ...card styles... */ }

.reveal .slides section.paperless {
  width: 100%;
  height: 100% !important;
  max-height: 100% !important;
  left: 0 !important;
  top: 0 !important;
  background: transparent !important;
  box-shadow: none !important;
}
```

## Gotchas

- The card shrinks the content area; elements injected into `.slide-background` via JS can extend outside the card, which is handy for scattering decorative accents around the edges without overlapping text.
- Keep the `!important` overrides or Reveal's inline positioning wins.
