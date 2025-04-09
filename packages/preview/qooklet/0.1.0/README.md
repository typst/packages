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
  - read as three-line table (`#ktable(data, k, inset: 0.3em)`)
  - read from .xlsx (using [rexllent](https://github.com/hongjr03/typst-rexllent))
- Code Block
  - highlighting (using [coldly](https://github.com/Dherse/codly))
  - read code block (`#code(text, lang: "python", breakable: true, width: 100%)`)
- Theorem
  - auto numbering based on chapter (using [ctheorems](https://github.com/sahasatvik/typst-theorems))
  - multilingual (using [linguify](https://github.com/typst-community/linguify))

## Get Started

```typst
#import "@preview/qooklet:0.1.0": *
#show: doc => conf(
  title: "Bellman Eqation",
  author: "ivaquero",
  header-cap: "Reinforcement Learning",
  footer-cap: "ivaquero",
  outline-on: false,
  doc,
)
```

## Get Started

```typst
#import "@local/qooklet:0.1.0": *
#show: doc => conf(
  title: "Bellman Eqation",
  author: "ivaquero",
  header-cap: "Reinforcement Learning",
  footer-cap: "ivaquero",
  outline-on: false,
  doc,
)
```

See [examples.typ](./examples/example.typ).

![example](examples/example.png)
