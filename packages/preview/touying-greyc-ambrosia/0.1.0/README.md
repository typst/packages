touying-greyc-ambrosia [![Typst Universe](https://img.shields.io/badge/dynamic/xml?url=https%3A%2F%2Ftypst.app%2Funiverse%2Fpackage%2Ftouying-greyc-ambrosia&query=%2Fhtml%2Fbody%2Fdiv%2Fmain%2Fdiv%5B2%5D%2Faside%2Fsection%5B2%5D%2Fdl%2Fdd%5B3%5D&logo=typst&label=Universe&color=%23239DAE)](https://typst.app/universe/package/touying-greyc-ambrosia) [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
------

`touying-greyc-ambrosia` is a [Touying](https://github.com/touying-typ/touying) theme for creating presentation slides in [Typst](https://github.com/typst/typst).

It is an _unofficial_ template intended for members of the [GREYC](https://www.greyc.fr/en/home/) lab, and is designed (by default) to mimic the official LaTeX & PPT templates provided in https://www.greyc.fr/intranet.
However, the theme comes with a lot of modifications and a range of different variants.
You are free to use or modify it for your own academic presentations, regardless of your affiliation.

> ✨ **Fun Fact**
>
> _Ambrosia_ 🍲 is a food or drink of the Greek gods, often described as having every flavor imaginable.

## Features

### Flavors

The `greyc-theme` offers six different flavors, inspired by existing touying and beamer themes.

| flavor |  1  |  2  |  3  |
|:------:|:---:|:---:|:---:|
| **`legacy`** | <img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/v0.1.0/assets/samples/sample-legacy-1.webp" alt="Sample title slide with legacy flavor" width="300"> | <img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/v0.1.0/assets/samples/sample-legacy-2.webp" alt="Sample outline slide with legacy flavor" width="300"> | <img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/v0.1.0/assets/samples/sample-legacy-3.webp" alt="Sample content slide with legacy flavor" width="300"> |
| `simple` | <img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/v0.1.0/assets/samples/sample-simple-1.webp"  alt="Sample title slide with simple flavor" width="300"> | <img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/v0.1.0/assets/samples/sample-simple-2.webp" alt="Sample outline slide with simple flavor" width="300"> | <img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/v0.1.0/assets/samples/sample-simple-3.webp" alt="Sample content slide with simple flavor" width="300"> |
| `cambridge` | <img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/v0.1.0/assets/samples/sample-cambridge-1.webp" alt="Sample title slide with cambridge flavor" width="300"> | <img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/v0.1.0/assets/samples/sample-cambridge-2.webp" alt="Sample outline slide with cambridge flavor" width="300"> | <img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/v0.1.0/assets/samples/sample-cambridge-3.webp" alt="Sample content slide with cambridge flavor" width="300"> |
| `darmstadt` | <img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/v0.1.0/assets/samples/sample-darmstadt-1.webp" alt="Sample title slide with darmstadt flavor" width="300"> | <img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/v0.1.0/assets/samples/sample-darmstadt-2.webp" alt="Sample outline slide with darmstadt flavor" width="300"> | <img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/v0.1.0/assets/samples/sample-darmstadt-3.webp" alt="Sample content slide with darmstadt flavor" width="300"> |
| `dewdrop` | <img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/v0.1.0/assets/samples/sample-dewdrop-1.webp" alt="Sample title slide with dewdrop flavor" width="300"> | <img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/v0.1.0/assets/samples/sample-dewdrop-2.webp" alt="Sample outline slide with dewdrop flavor" width="300"> | <img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/v0.1.0/assets/samples/sample-dewdrop-3.webp" alt="Sample content slide with dewdrop flavor" width="300"> |
| `stargazer` | <img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/v0.1.0/assets/samples/sample-stargazer-1.webp" alt="Sample title slide with stargazer flavor" width="300"> | <img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/v0.1.0/assets/samples/sample-stargazer-2.webp" alt="Sample outline slide with stargazer flavor" width="300"> | <img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/v0.1.0/assets/samples/sample-stargazer-3.webp" alt="Sample content slide with stargazer flavor" width="300"> |

To select a flavor, you pass its name to the show rule of the theme.

```typ
#import "@preview/touying-greyc-ambrosia:0.1.0": *

#show: greyc-theme.with(
  flavor: "[flavor-name]"
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

> 💡 **Tip**
>
> Footnote citation, by default, is inserted only in the first slide an article was cited. To make it appear on all slides they are mentioned, modify the `footcite-once` parameter.
> ```typ
> #show: greyc-theme.with(
>   footcite-once: false
> )
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

> ℹ️ **Note**
>
> `touying-greyc-ambrosia` should always be imported after `touying` (which is not necessary and can be removed) in order for the functions and components it overrides to work correctly (e.g. `#alert`, `#show: appendix`, ...).
> ```typ
> #import "@preview/touying:0.6.2": *
> #import "@preview/touying-greyc-ambrosia:0.1.0": *
> ```

Otherwise, you can download it for local use:

```bash
git clone https://github.com/inspiros/touying-greyc-ambrosia
python scripts/install.py
 ```

This Python script stores the package files in the right location following the instructions [here](https://github.com/typst/packages?tab=readme-ov-file#local-packages).
After that, you can import the package with:

```typ
#import "@local/touying-greyc-ambrosia:0.1.0": *
```

### Examples

For more sophisticated use cases, please check [`examples/demo.typ`](https://github.com/inspiros/touying-greyc-ambrosia/blob/v0.1.0/examples/demo.typ) and [`examples/demo.pdf`](https://github.com/inspiros/touying-greyc-ambrosia/blob/v0.1.0/examples/demo.pdf).

## License

MIT licensed, see [LICENSE](LICENSE).
