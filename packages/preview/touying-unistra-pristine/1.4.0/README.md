# touying-unistra-pristine

> [!WARNING]
> This theme is **NOT** affiliated with the University of Strasbourg. The logo, fonts and icons are the property of the University of Strasbourg.

**touying-unistra-pristine** is a [Touying](https://github.com/touying-typ/touying) theme for creating presentation slides in [Typst](https://github.com/typst/typst), adhering to the core principles of the [style guide of the University of Strasbourg, France](https://langagevisuel.unistra.fr) (French). It is an **unofficial** theme and it is **NOT** affiliated with the University of Strasbourg.

This theme was partly created using components from [tud-slides](https://github.com/typst-tud/tud-slides) and [grape-suite](https://github.com/piepert/grape-suite).

# Features

- **Focus Slides**, with predefined themes and custom colors support.
- **Hero Slides**.
- **Gallery Slides**.
- **Icons** (see [Icons](#Icons)).
- **Better Citations** (see [Citations](#Citations)).
- **Universally Toggleable Header/Footer** (see [Configuration](#Configuration)).
- Subset of predefined colors taken from the [style guide of the University of Strasbourg](https://langagevisuel.unistra.fr/index.php?id=396) (see [colors.typ](colors.typ)).

# Example

See [example/example.pdf](example/example.pdf) for an example PDF output, and [example/example.typ](example/example.typ) for the corresponding Typst file.

# Installation

These steps assume that you already have [Typst](https://typst.app/) installed and/or running.

## Import from Typst Universe

```typst
#import "@preview/touying:0.6.1": *
#import "@preview/touying-unistra-pristine:1.4.0": *

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
#import "src/icons.typ": *

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
> The default font used by touying-unistra-pristine is "Unistra A", a font that can only be downloaded by students and staff from the University of Strasbourg from [here](https://langagevisuel.unistra.fr/index.php?id=402). If the font is not installed on your computer, Segoe UI or Roboto will be used as a fallback, in that specific order. You can change that behavior in the [settings](#Configuration).

# Icons

**touying-unistra-pristine** supports icons from the University of Strasbourg (_Unistra Symbol_). These icons can only be downloaded by students and staff from the University of Strasbourg from [here](https://langagevisuel.unistra.fr/index.php?id=402).

As an alternative, or in addition to these icons, you can also use _Nova Icons_, based on Font Awesome 4.7, which can be downloaded freely from [here](https://s3.unistra.fr/master/common/assets/fonts/nova-icons/1.0.1/fonts/novaicons.ttf?AWSAccessKeyId=M2M78RKXPAP75Y692QZX&Signature=QzVHDIlE0dxe7NsiXplv969Bkuc%3D&Expires=1870941573&v=1.0.0) (.ttf format).

The full list of _Unistra Symbol_ and _Nova Icons_ is available [here](https://di.pages.unistra.fr/pictogrammes/).

Once these fonts are installed in your environment, they can be used with the `us-icon()` (_Unistra Symbol_) and the `nv-icon()` (_Nova Icons_) functions. Both functions take the icon string ID (which can be found in the list linked above) without the prefix as an argument. For example:

```typst
#nv-icon("coins") // original name is "nv-coins", but no need for the prefix
#us-icon("plant") // original name is "us-plant", but no need for the prefix
```

Icons are also supported for focus slides. An icon can be defined using the `icon` parameter to be shown above the title:

```typst
#focus-slide(theme: "berry", icon: us-icon("edit-done"))[Focus Slide Title]
```

Icon function definitions and character-to-string mapping in [src/icons.typ](src/icons.typ) are generated automatically using [scripts/get_icons.py](scripts/get_icons.py).

# Citations

**touying-unistra-pristine** improves on the handling of citations for French users by adding functions that formats citations in accordance with standard academic styling (use of non-breaking space + semicolon to separate multiple citations; use of colon before page number; replacement of "&" with "et"). These should be used along the `assets/apa.csl` file, which should be specified as the value of the `style` argument when invoking `#bibliography()`. When using this style:
- `@label` acts as a prose citation (e.g., "Astley et Morris (2020)"). Supplements are accepted and will show as "Astley et Morris (2020:[supplement]).
- `#pcite(label, ..args)` acts as a parenthesis citation for a single label. E.g., "(Astley et Morris, 2020)". Supplement can be specified as an additional argument to the function. Example: `#pcite(<a>, 5)`.
- `#mcite(..args)` acts as a parenthesis citation for multiple labels. E.g., "(Astley et Morris, 2020 ; Morris et Astley, 2021)". Supplement for the corresponding label can be specified as an additional argument within the citation array. Example: `#mcite((<a>, 5), (<b>, "24-25"), (<c>,))`.

# Configuration

The theme can be configured to your liking by adding the `config-store()` object when initializing `unistra-theme`. An example with the `quotes` setting can be found in [example/example.typ](example/example.typ).

A complete list of settings can be found in the `config-store` object in [src/unistra.typ](src/unistra.typ).
