touying-greyc-ambrosia [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
------

`touying-greyc-ambrosia` is a [Touying](https://github.com/touying-typ/touying) theme for creating presentation slides in [Typst](https://github.com/typst/typst).

It is an _unofficial_ template intended for members of the [GREYC](https://www.greyc.fr/en/home/) lab, and is designed (by default) to mimic the official LaTeX & PPT templates provided in https://www.greyc.fr/intranet.
However, the theme comes with a lot of modifications and a range of different variants.
You are free to use or modify it for your own academic presentations, regardless of your affiliation.

> _**Fun fact:** 🍲Ambrosia is a food or drink of the Greek gods, often described as having every flavor imaginable._

## Features

### Flavors

The `greyc-theme` offers five different flavors, inspired by existing touying and beamer themes.

| flavor |  1  |  2  |  3  |
|:------:|:---:|:---:|:---:|
| **`legacy`** | <img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/master/assets/samples/sample-legacy-1.webp" width="300"> | <img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/master/assets/samples/sample-legacy-2.webp" width="300"> | <img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/master/assets/samples/sample-legacy-3.webp" width="300"> |
| `cambridge` | <img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/master/assets/samples/sample-cambridge-1.webp" width="300"> | <img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/master/assets/samples/sample-cambridge-2.webp" width="300"> | <img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/master/assets/samples/sample-cambridge-3.webp" width="300"> |
| `darmstadt` | <img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/master/assets/samples/sample-darmstadt-1.webp" width="300"> | <img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/master/assets/samples/sample-darmstadt-2.webp" width="300"> | <img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/master/assets/samples/sample-darmstadt-3.webp" width="300"> |
| `dewdrop` | <img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/master/assets/samples/sample-dewdrop-1.webp" width="300"> | <img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/master/assets/samples/sample-dewdrop-2.webp" width="300"> | <img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/master/assets/samples/sample-dewdrop-3.webp" width="300"> |
| `stargazer` | <img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/master/assets/samples/sample-stargazer-1.webp" width="300"> | <img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/master/assets/samples/sample-stargazer-2.webp" width="300"> | <img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/master/assets/samples/sample-stargazer-3.webp" width="300"> |

To select a flavor, you pass its name to the show rule of the theme.

```typ
#import "@preview/touying-greyc-ambrosia:0.1.0": *

#show: greyc-theme.with(
  flavor: "[flavor-name]",
  ..
)
```

### Other Functionalities

#### Footnote Citation

- Instead of using the prose citation `@key`, we can use the `#footcite(<key>)` function, which further includes a full citation to the footnote of the same slide.
- At the end of the presentation, you must add your bibliography either by:
  - A separate bibliography slide.
  ```typ
  #bibliography-slide("bibliography.bib", style: "ieee")
  ```
  - A hidden bibliography.
  ```typ
  #hidden-bibliography("bibliography.bib", style: "ieee")
  ```

> [!TIP]
> Footnote citation, by default, is inserted only in the first slide an article was cited. To make it appear on all slides they are mentioned, modify the `footcite-once` parameter.
> ```typ
> #show: greyc-theme.with(
>   ..
>   footcite-once: false)
> ```

## Usage

This package is available in the Typst universe.
To use it, simply add the following code to your document.

```typ
#import "@preview/touying-greyc-ambrosia:0.1.0": *

#show: greyc-theme.with(
  // legacy | stargazer | dewdrop | cambridge | darmstadt
  flavor: "legacy",
  aspect-ratio: "16-9",
  config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Author],
    date: datetime.today(),
    institution: [Institution],
  ),
)

#title-slide()

= Section Title

== Slide

#lorem(30)
```

> [!NOTE]
> `touying-greyc-ambrosia` should always be imported after `touying` in order for the functions and components it overrides to work correctly (`#alert`, `#show appendix`, ...).
> ```typ
> #import "@preview/touying:0.6.2": *
> #import "@preview/touying-greyc-ambrosia:0.1.0": *
> ```

Or you can only download it for local use:

```cmd
git clone https://github.com/inspiros/touying-greyc-ambrosia
```

### Examples

For more sophisticated use cases, please check [`examples/demo.typ`](https://github.com/inspiros/touying-greyc-ambrosia/blob/master/examples/demo.typ) and [`examples/demo.pdf`](https://github.com/inspiros/touying-greyc-ambrosia/blob/master/examples/demo.pdf).

## License

MIT licensed, see [LICENSE](LICENSE).
