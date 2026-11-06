<p align="center">
  <img src="docs/assets/mosaic-slide.svg" alt="The Mosaic logo: a slide divided into a wide header band and two body blocks" width="150">
</p>

<h1 align="center">Mosaic</h1>

<p align="center"><em>Beautiful slides for <a href="https://typst.app/">Typst</a>.</em></p>

Write your talk as an ordinary Typst document and Mosaic makes the slides for you. Style them with the `set` and `show` rules you already know, because Mosaic is a thin layer on Typst rather than a framework: it adds slides, named cells, and sensible defaults, then leaves the rest of the document to the language itself. Batteries included: modern themes, ready-made layouts, nested grids, incremental reveals, speaker notes, handouts, callouts, cards, quotes, and progress indicators.

## Website

Detailed documentation, many examples, and themes can be found on the package website:

<https://vincentarelbundock.github.io/mosaic>

## Install

Mosaic 0.0.1 requires Typst 0.15 or newer. Once it is published on Typst Universe, no installation step is needed: importing it downloads it.

```typ
#import "@preview/mosaic:0.0.1" as m
```

To work from source instead, clone the repository and install the working tree over that same import, which is how the tests, the documentation, and the example decks in this repository resolve the package:

```sh
git clone https://github.com/vincentarelbundock/mosaic.git
cd mosaic
make install
```

`make uninstall` removes the working-tree copy and restores the published one.

## A complete deck

```typ
#import "@preview/mosaic:0.0.1" as m

#show: m.setup.with(title: [A short talk])

#m.slide(layout: "title")

= Methods

== Data

One slide.

== Model

Another slide.
```

Compile it with `typst compile talk.typ`. A level-one heading opens a section slide, a level-two heading a content slide, and everything between them is ordinary Typst content.

## Gallery

Here are some slides created with Mosaic:

![Contact sheet of slides from the Mosaic example decks, three across](docs/assets/images/showcase-contact-sheet.webp)
