# touying-unistra-pristine

> [!WARNING]
> This theme is **NOT** affiliated with the University of Strasbourg. The logo, fonts and icons are the property of the University of Strasbourg.

**touying-unistra-pristine** is a [Touying](https://github.com/touying-typ/touying) theme for creating presentation slides in [Typst](https://github.com/typst/typst), adhering to the core principles of the [style guide of the University of Strasbourg, France](https://langagevisuel.unistra.fr) (French). It is an **unofficial** theme and it is **NOT** affiliated with the University of Strasbourg.

> [!NOTE]
> Even though this theme was originally intended for members of the University of Strasbourg, it is perfectly acceptable (and even encouraged!) to use this theme for your own (academic) presentations. You can easily customize and extend the theme to your liking, either by [configuring the theme](#Configuration) and using Typst's basic functions, or by forking the project and editing the source code directly. If you have ideas for improvements, feel free to [open an issue](https://github.com/spidersouris/touying-unistra-pristine/issues).

This theme was partly created using components from [tud-slides](https://github.com/typst-tud/tud-slides).

# Features

- **Focus Slides**, with predefined themes and custom colors support.
- **Hero Slides**.
- **Gallery Slides**.
- **Icons** and **Link Icons** (see [Icons](#Icons)).
- **Better Citations** (see [Citations](#Citations)).
- **Universally Toggleable Header/Footer** (see [Configuration](#Configuration)).
- Subset of predefined colors taken from the [style guide of the University of Strasbourg](https://langagevisuel.unistra.fr/index.php?id=396) (see [colors.typ](src/colors.typ)).

# Examples

The [examples folder](https://github.com/spidersouris/touying-unistra-pristine//examples) contains two examples:
- a **basic example** highlighting main features of the theme ([examples/basic.typ](examples/basic.typ); [examples/basic.pdf](examples/basic.pdf) for output),
- an **extensively commented, real-usage example** of slides made for an academic presentation for the ACL 2025 conference ([examples/acl25.typ](examples/acl25.typ); [examples/acl25.pdf](examples/acl25.pdf) for output),

# Installation

These steps assume that you already have [Typst](https://typst.app/) installed and/or running.

## Import from Typst Universe

```typst
#import "@preview/touying:0.6.1": *
#import "@preview/touying-unistra-pristine:1.4.2": *

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

See [examples/basic.typ](examples/basic.typ) for a basic example with configuration.

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

The full list of icons from _Unistra Symbol_ and _Nova Icons_ is available [here](https://di.pages.unistra.fr/pictogrammes/).

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

## Link Icons

By default, icons are shown next to links ending or containing specific extensions or keywords (see an example on [p. 8 of examples/basic.pdf](examples/basic.pdf). This can be disabled by setting `link-icons` to `()`. Similarly, default labels can be overriden and new labels can be added by changing the setting values. Default supported labels are specified in the table below.

<table>
  <tr>
    <th>Label</th>
    <th>Description</th>
    <th>Regular Expression</th>
    <th>Icon</th>
  </tr>
  <tr>
    <td>video</td>
    <td>Links to video or animated image files.</td>
    <td><code>\.(gif|mp4|avi|mov|webm|mkv)$</code></td>
    <td><code>nv-icon("file-video")</code></td>
  </tr>
  <tr>
    <td>image</td>
    <td>Links to image files.</td>
    <td><code>\.(jpg|jpeg|png|bmp|svg|webp|tiff)$</code></td>
    <td><code>nv-icon("picture-layer")</code></td>
  </tr>
  <tr>
    <td>audio</td>
    <td>Links to audio files.</td>
    <td><code>\.(mp3|wav|ogg|flac|m4a)$</code></td>
    <td><code>nv-icon("file-audio")</code></td>
  </tr>
  <tr>
    <td>archive</td>
    <td>Links to compressed archive files.</td>
    <td><code>\.(zip|tar|gz|bz2|xz)$</code></td>
    <td><code>nv-icon("folders")</code></td>
  </tr>
  <tr>
    <td>code</td>
    <td>Links to source code or configuration files.</td>
    <td><code>\.(css|html|js|ts|tsx|json|xml|yml|toml|ini|cfg|bat|sh|ps1|py|java|c|cpp|h|hpp|rs|go|php|rb|pl|swift)$</code></td>
    <td><code>us-icon("code")</code></td>
  </tr>
  <tr>
    <td>facebook</td>
    <td>Links to Facebook.</td>
    <td><code>(fb|facebook)\.com/</code></td>
    <td><code>nv-icon("facebook")</code></td>
  </tr>
  <tr>
    <td>pinterest</td>
    <td>Links to Pinterest.</td>
    <td><code>pinterest\.com/</code></td>
    <td><code>nv-icon("pinterest")</code></td>
  </tr>
  <tr>
    <td>tumblr</td>
    <td>Links to Tumblr.</td>
    <td><code>tumblr\.com/</code></td>
    <td><code>nv-icon("tumblr")</code></td>
  </tr>
  <tr>
    <td>youtube</td>
    <td>Links to YouTube.</td>
    <td><code>(youtube\.com|youtu\.be)/</code></td>
    <td><code>nv-icon("video-control-play")</code></td>
  </tr>
</table>

# Citations

**touying-unistra-pristine** improves on the handling of citations specifically for academic/research-focused slides. This is achieved by making prose citation the default for label reference, and providing language-specific (French and English/other) CSL files for the formatting of citations and bibliographies.

## Language Specificities

If you're using a bibliography for your slides, it is recommended to change the value of the `style` argument when invoking `#bibliography()` to one of the two provided CSL files: [apa.csl](assets/csl/apa.csl) (French) or [apa_en.csl](assets/csl/apa_en.csl) (English/other languages):

```typst
#bibliography(
  "my_bib.bib",
  style: "apa.csl",
  title: none,
) // https://typst.app/docs/reference/model/bibliography/
```

When doing so, make sure to properly set the language of your document:

```typst
#set text(lang: "fr") // https://typst.app/docs/reference/text/text/#parameters-lang
```

Specifically, for French users using `apa.csl`, this will:
- separate multiple citations with a non-breaking space and a semicolon,
- replace the ampersand (&) with "et" for two-author papers.

## Syntax

When using any of the provided CSL files described above:
- `@label` acts as a prose citation (e.g., "Astley & Morris (2020)"). Supplements are accepted as `@label[supplement]` and will show as "Astley & Morris (2020:[supplement]).
- `#pcite(label, ..args)` acts as a parenthesis citation for a single label. E.g., "(Astley & Morris, 2020)". Supplement can be specified as an additional argument to the function. Example: `#pcite(<a>, 5)`.
- `#mcite(..args)` acts as a parenthesis citation for multiple labels. E.g., "(Astley & Morris, 2020 ; Morris & Astley, 2021)". Supplement for the corresponding label can be specified as an additional argument within the citation array. Example: `#mcite((<a>, 5), (<b>, "24-25"), (<c>,))`.

# Configuration

The theme can be configured to your liking by adding the `config-store()` object when initializing `unistra-theme`. An example with the `quotes` setting can be found in [examples/basic.typ](examples/basic.typ).

A complete list of settings is available below.

|          Name         |                                                      Description                                                     |     Value Type    | Default                                                             |
|:---------------------:|:--------------------------------------------------------------------------------------------------------------------:|:-----------------:|---------------------------------------------------------------------|
| link-icons           | Icons (content) to be appended next to URLs matched by the regex.                                                                                          | dict[str, dict[regex, content]]              | See list in [Link Icons](##Link%20Icons)                                                             |
| show-header           | Whether to show the header.                                                                                          | bool              | `false`                                                             |
| show-footer           | Whether to show the footer.                                                                                          | bool              | `true`                                                              |
| footer-first-sep      | First separator in the footer.                                                                                       | str               | `" \| "`                                                            |
| footer-second-sep     | Second separator in the footer.                                                                                      | str               | `" \| "`                                                            |
| footer-appendix-label | Label to be shown before slide number in the Appendix.                                                               | str               | `"A-"`                                                              |
| font                  | Font to be used.                                                                                                     | str \| array[str] | `("Unistra A", "Segoe UI", "Roboto")`                               |
| quotes                | Settings to be used for the custom `#quote()` element. Dict with keys `left`, `right`, `outset`, `margin-top`. | dict[str, length]  | `(left: "« ", right: " »", outset: 0.5em, margin-top: 0em)` |
| footer-hide           | Elements from the footer to hide (can include "author" or "date").                                                   | array[str]        | `()`                                                                |
