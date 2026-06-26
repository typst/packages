# Ricopallazzo UNI Theme

A modern, customizable presentation theme for **Typst** built on top of **Touying**. It provides a polished academic presentation layout with automatic section slides, progress indicators, branded headers and footers, and configurable color themes.

> **Status:** Initial release (v0.1.0)

---

## Features

* Modern title slide
* Automatic section overview slides
* Branded header and footer
* Multiple progress indicator styles
* Configurable color themes
* Custom alert boxes
* Automatic slide numbering
* Fully compatible with Touying
* Designed for academic and technical presentations

---

## Installation

Once published on Typst Universe:

```typst
#import "@preview/ricopallazzo-uni-theme:0.1.0": *
```

For local development :

```typst
#import "@local/ricopallazzo-uni-theme:0.1.0": *
```

---

## Quick Start

```typst
#import "@preview/touying:0.7.4": *
#import "@preview/ricopallazzo-uni-theme:0.1.0": *

#show: ricopallazzo-uni-theme.with(
  aspect-ratio: "presentation-16-9", 
  title: "My Presentation",
  short_title: "Presentation",
  author: "Alberto Bertoncini",
  institute: "University of Milan",
  theme: "blue",
  logo: "../assets/logo_RGB_negative_circle.png",
  logo_name: "../assets/logo_coutour_name.png"
)

#title-slide()

= Introduction

== Motivation

Hello, world!
```

---

## Configuration

The theme can be customized through the following parameters.

| Parameter      | Description                         | Default               |
| -------------- | ----------------------------------- | --------------------- |
| `theme`        | Color theme                         | `"blue"`              |
| `aspect-ratio` | Presentation aspect ratio           | `"16-9"`              |
| `title`        | Presentation title                  | —                     |
| `short_title`  | Short title displayed in the footer | —                     |
| `author`       | Author name                         | —                     |
| `institute`    | Institution                         | —                     |
| `logo`         | Header logo                         | `assets/logo_RGB.png` |
| `logo_name`    | Title slide logo                    | `assets/logo_RGB.png` |
| `date`         | Display today's date                | `true`                |
| `progress`     | Progress indicator style            | `"slide"`             |
| `prefix`       | Outline bullet style                | `"numbering"`         |

---

## Progress Indicators

Four progress visualization modes are available:

* `slide`
* `section`
* `slide-by-section`
* `mini`

Example:

```typst
#show: ricopallazzo-uni-theme.with(
  progress: "slide-by-section",
)
```

---

## Color Themes

Themes are defined in

```text
src/themes_colors.typ
```

and selected with

```typst
theme: "orange"
```

Adding a new theme only requires defining a new color palette.

---

## Alert Boxes

The package provides a customizable alert component.

```typst
#alert-box[
Important message.
]
```

It also supports custom colors and gradients.

---

## Package Structure

```
ricopallazzo-uni-theme/
├── assets/
│   └── ...
├── src/
│   ├── theme.typ
│   ├── exports.typ
│   └── themes_colors.typ
├── CHANGELOG.md
├── LICENSE
├── README.md
├── lib.typ
└── typst.toml
```

---

## Public API

The package exports:

* `ricopallazzo-uni-theme`
* `title-slide`
* `alert-box`

All implementation details remain internal to the package.

---

## Local Development

Clone the repository and install it as a local Typst package:

```
~/.local/share/typst/packages/local/
└── ricopallazzo-uni-theme/
    └── 0.1.0/
```

Then import it with

```typst
#import "@local/ricopallazzo-uni-theme:0.1.0": *
```

---

## License

This project is released under the MIT License.

---

## Acknowledgements

This package is built on top of the excellent **Touying** presentation framework and follows the Typst package conventions.

