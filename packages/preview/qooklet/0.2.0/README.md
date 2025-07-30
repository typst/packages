# Qooklet

A quick start template for scientific booklets.

## Features

- Math Equation
  - auto numbering based on chapter
  - link quote to source
- Figure
  - auto numbering based on chapter
  - subfigure (using [subpar](https://github.com/tingerrr/subpar))
- Table
  - read as three-line table (`#ktable()`)
  - read from .xlsx (using [rexllent](https://github.com/hongjr03/typst-rexllent))
- Code Block
  - highlighting (using [coldly](https://github.com/Dherse/codly))
  - read code block (`#code(text, lang: "python", breakable: true, width: 100%)`)
- Theorem
  - auto numbering based on chapter (using [ctheorems](https://github.com/sahasatvik/typst-theorems))
  - multilingual (using [linguify](https://github.com/typst-community/linguify))

## Get Started

```typst
#import "@preview/qooklet:0.2.0": *
#show: qooklet.with(
  title: "Bellman Eqation",
  author: "ivaquero",
  header-cap: "Reinforcement Learning",
  footer-cap: "ivaquero",
  // the following are optional arguments
  // outline-on: false,
  // par-leading: 1em,
  // list-indent: 1.2em,
  // block-above: 1em,
  // block-below: 1em,
  // figure-break: false,
  // paper: "iso-b5",
  // lang: "en"
)
```

The function `ktable(data, k, stroke: three-line(rgb("000")), inset: 0.3em)` is a shortcut of reading .csv, where `k` is the number of columns, and for stroke, `qooklet` provide 2 predefined styles

- `three-line(stroke-color)`: default style, for three-line table
- `no-left-right(stroke-color)`: for grid without left border and right border

![example](thumbnail.png)

## Clone Official Repository

Clone the [qooklet](https://github.com/ivaquero/qooklet) repository to your `@local` workspace:

- Linux：
  - `$XDG_DATA_HOME/typst/packages/local`
  - `~/.local/share/typst/packages/local`
- macOS：`~/Library/Application\ Support/typst/packages/local`
- Windows：`%APPDATA%/typst/packages/local`

Import `qooklet` in the document

```typst
#import "@local/qooklet:0.1.0": *
```

> For developement convinience, local repo never changes the version
