# slidecrafting.com

Source for [slidecrafting-book.com](https://slidecrafting-book.com) — a guide to making beautiful slides with Reveal.js and Quarto.

## Claude Skills

Skills extend Claude's knowledge with specialized patterns from this project. Install them into your coding agent so Claude understands the slidecrafting conventions without needing to rediscover them from scratch.

| Skill | Description |
|---|---|
| **[quarto-revealjs-fragment](./skills/quarto-revealjs-fragment/)** | CSS states, JS events, reversal logic, and the state-tracking pattern for custom Reveal.js fragment animations |
| **[auto-animate-elements](./skills/auto-animate-elements/)** | Carry a small cast of persistent elements across slides with auto-animate: the `data-id` contract, the SCSS-plus-inline split, figures inside elements, and the "enough, not all" pacing rule |

### Installation

#### Using `npx skills add` (any agent)

Works with Claude Code, Cursor, Codex, Cline, and other supported agents:

```bash
# Install all skills
npx skills add emilhvitfeldt/slidecrafting.com

# Install a specific skill
npx skills add emilhvitfeldt/slidecrafting.com --skill quarto-revealjs-fragment
```

#### Claude Code

Add this repository as a skill marketplace in Claude Code:

```
/plugin marketplace add emilhvitfeldt/slidecrafting.com
```

Then browse and install skills through the Claude Code UI.

#### Manual installation

```bash
git clone https://github.com/emilhvitfeldt/slidecrafting.com.git
cp -r slidecrafting.com/skills/quarto-revealjs-fragment ~/.config/claude-code/skills/
```

### Using skills

Once installed, Claude will automatically activate the relevant skill based on your task — no need to invoke it explicitly.

## Structure

- `*.qmd` — book chapter source files
- `examples/` — standalone Reveal.js slide decks embedded as iframes in the book
- `_book/` — built output (do not edit directly)

## Building

The site has two components that must be rendered in order:

```bash
# 1. Render the example slide decks
quarto render examples/

# 2. Render the book
quarto render
```

The book copies from `examples/` during its render, so the examples must be built first.

## Adding new examples

Create a new `.qmd` in the appropriate `examples/` subdirectory. Use `format: revealjs` without `self-contained: true`:

```yaml
---
format:
  revealjs: {}
---
```

Or with options:

```yaml
---
format:
  revealjs:
    theme: [default, my-theme.scss]
---
```

Do **not** add `self-contained: true` — examples share a common `libs/` directory to avoid bundling Reveal.js (~11MB) into every file.
