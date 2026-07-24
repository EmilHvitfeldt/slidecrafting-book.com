# 13  Letterbox

The [quarto-revealjs-letterbox](https://github.com/EmilHvitfeldt/quarto-revealjs-letterbox) extension brings the beloved letterbox style from [xaringan](https://github.com/yihui/xaringan) to Quarto reveal.js presentations.

## 13.1 What is Letterbox?

Letterbox is a presentation style that adds colored bars at the top and bottom of your slides, creating a cinematic feel while also providing a consistent visual anchor for your content. This style became popular through the xaringan R package and many presenters found it helpful for branding and visual consistency.

Demo of the letterbox extension: slides with colored bars at the top and bottom creating a cinematic framing effect, similar to the popular xaringan letterbox style.

## 13.2 Installation

To use this extension, run the following command in your terminal:

``` bash
quarto add EmilHvitfeldt/quarto-revealjs-letterbox
```

## 13.3 Basic Usage

Once installed, you can use the letterbox format in your YAML header:

``` yaml
format:
  letterbox-revealjs: default
```

## 13.4 Customization

The extension provides several options for customization. You can change the colors of the top and bottom bars to match your branding:

``` yaml
format:
  letterbox-revealjs:
    letterbox-top-color: "#2c3e50"
    letterbox-bottom-color: "#2c3e50"
```

You can also adjust the height of the bars:

``` yaml
format:
  letterbox-revealjs:
    letterbox-top-height: "50px"
    letterbox-bottom-height: "50px"
```

## 13.5 Combining with Other Themes

The letterbox extension can be combined with other theme customizations. Simply add your custom SCSS file alongside the letterbox format:

``` yaml
format:
  letterbox-revealjs:
    theme: [default, custom.scss]
    letterbox-top-color: "#1a1a2e"
    letterbox-bottom-color: "#1a1a2e"
```

This allows you to have the letterbox style while still applying all the color, font, and size customizations discussed in earlier chapters.

[ Github](https://github.com/EmilHvitfeldt/quarto-revealjs-letterbox) [ Demo](https://emilhvitfeldt.github.io/quarto-revealjs-letterbox/)
