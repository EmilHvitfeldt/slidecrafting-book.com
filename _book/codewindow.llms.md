# 14  Codewindow

The [quarto-revealjs-codewindow](https://github.com/EmilHvitfeldt/quarto-revealjs-codewindow) extension adds styled codeblock windows to your Quarto reveal.js presentations, giving your code chunks a polished, IDE-like appearance.

## 14.1 What is Codewindow?

Codewindow wraps your code chunks in a styled window frame with a file tab, similar to how code appears in modern code editors. This visual treatment makes code stand out on slides and provides helpful context through language-specific icons.

Demo of the codewindow extension: code blocks styled as IDE-like windows with a title bar, file tab with language icon, and polished appearance resembling a modern code editor.

## 14.2 Installation

To use this extension, run the following command in your terminal:

``` bash
quarto add emilhvitfeldt/quarto-revealjs-codewindow
```

Once installed, add the extension to your YAML header:

``` yaml
---
title: "My Presentation"
format: revealjs
revealjs-plugins:
  - codewindow
---
```

## 14.3 Basic Usage

Wrap any code chunk in a `::: {.codewindow}` fenced div to apply the window styling. Add plain text before the code chunk to create a file tab label:

```` markdown
::: {.codewindow}
script.R

```r
library(ggplot2)

ggplot(mtcars, aes(mpg, wt)) +
  geom_point()
```
:::
````

## 14.4 Language Icons

Add a language class to display an icon in the file tab. The following languages are supported:

- `.r` - R
- `.py` - Python
- `.js` - JavaScript
- `.quarto` - Quarto
- `.html` - HTML
- `.css` - CSS
- `.sass` - Sass
- `.julia` - Julia

Example with an R icon:

```` markdown
::: {.codewindow .r}
analysis.R

```r
mtcars |>
  dplyr::group_by(cyl) |>
  dplyr::summarize(mean_mpg = mean(mpg))
```
:::
````

## 14.5 Customizing Width

You can control the width of the codewindow using the `width` argument directly in the fenced div:

```` markdown
::: {.codewindow .r width="80%"}
script.R

```r
print("Hello, world!")
```
:::
````

[ Github](https://github.com/EmilHvitfeldt/quarto-revealjs-codewindow) [ Demo](https://emilhvitfeldt.github.io/quarto-revealjs-codewindow/)
