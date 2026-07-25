# PDF export / printing

References:
- https://quarto.org/docs/presentations/revealjs/presenting.html#print-to-pdf

Reveal.js decks print to PDF from the browser:

1. Open the rendered HTML.
2. Press `E` to switch to print view (or append `?print-pdf` to the URL).
3. Print (Cmd/Ctrl-P) and choose "Save as PDF". Set margins to None and enable background graphics.

Chrome/Chromium gives the most reliable output.

## Notes and fragments

- Fragments export as separate pages by default; add `pdf-separate-fragments: false` to collapse each slide's fragments onto one page.
- Speaker notes are included with `show-notes: true` (or `show-notes: separate-page` to put them on their own pages); `false` is the default.
- A too-tall slide expands onto multiple pages; cap that with `pdf-max-pages-per-slide` (unrelated to notes).

## Gotchas

- Use `?print-pdf` **or** press `E`; printing the normal view yields only the current slide.
- Chalkboard drawings and live/interactive content don't appear in the PDF.
- Very tall (`.scrollable`) slides get clipped in print; split them for the PDF version.
