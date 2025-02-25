# touying-unistra-pristine

> [!WARNING]
> This theme is **NOT** affiliated with the University of Strasbourg. The logo and the fonts are the property of the University of Strasbourg.

**touying-unistra-pristine** is a [Touying](https://github.com/touying-typ/touying) theme for creating presentation slides in [Typst](https://github.com/typst/typst), adhering to the core principles of the [style guide of the University of Strasbourg, France](https://langagevisuel.unistra.fr) (French). It is an **unofficial** theme and it is **NOT** affiliated with the University of Strasbourg.

This theme was partly created using components from [tud-slides](https://github.com/typst-tud/tud-slides) and [grape-suite](https://github.com/piepert/grape-suite).

# Features

- **Focus Slides**, with predefined themes and custom colors support.
- **Hero Slides**.
- **Gallery Slides**.
- **Admonitions** (with localization and plural support).
- **Universally Toggleable Header/Footer** (see [Configuration](#Configuration)).
- Subset of predefined colors taken from the [style guide of the University of Strasbourg](https://langagevisuel.unistra.fr/index.php?id=396) (see [colors.typ](colors.typ)).

# Example

See [example/example.pdf](example/example.pdf) for an example PDF output, and [example/example.typ](example/example.typ) for the corresponding Typst file.

# Installation

These steps assume that you already have [Typst](https://typst.app/) installed and/or running.

## Import from Typst Universe

```typst
#import "@preview/touying:0.6.1": *
#import "@preview/touying-unistra-pristine:1.3.1": *

#show: unistra-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Title],
    subtitle: [_Subtitle_],
    author: [Author],
    date: datetime.today().display("[month repr:long] [day], [year repr:full]"),
  ),
)

#title-slide[]

= Example Section Title

== Example Slide

A slide with *important information*.

#lorem(50)
```

## Local installation

### 1. Clone the project

`git clone https://github.com/spidersouris/touying-unistra-pristine`

### 2. Import Touying and touying-unistra-pristine

See [example/example.typ](example/example.typ) for a complete example with configuration.

```typst
#import "@preview/touying:0.6.1": *
#import "src/unistra.typ": *
#import "src/colors.typ": *
#import "src/admonition.typ": *

#show: unistra-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Title],
    subtitle: [_Subtitle_],
    author: [Author],
    date: datetime.today().display("[month repr:long] [day], [year repr:full]"),
  ),
)

#title-slide[]

= Example Section Title

== Example Slide

A slide with *important information*.

#lorem(50)
```

> [!NOTE]
> The default font used by touying-unistra-pristine is "Unistra A", a font that can only be downloaded by students and staff from the University of Strasbourg. If the font is not installed on your computer, Segoe UI or Roboto will be used as a fallback, in that specific order. You can change that behavior in the [settings](#Configuration).

# Configuration

The theme can be configured to your liking by adding the `config-store()` object when initializing `unistra-theme`. An example with the `quotes` setting can be found in [example/example.typ](example/example.typ).

A complete list of settings can be found in the `config-store` object in [src/unistra.typ](src/unistra.typ).
