# UC3M Thesis Template

A [Typst](https://typst.app/) template for bachelor/master theses at [Universidad Carlos III de Madrid](https://uc3m.es), following [university guidelines](https://uc3m.libguides.com/en/TFG/writing)[^1].

The template is based on [ldcas-uc3m/thesis-template](https://github.com/ldcas-uc3m/thesis-template) and [clean-uc3m](https://github.com/JorgeyGari/clean-uc3m-typst-template) (a fork of [clean-dhbw](https://github.com/roland-KA/clean-dhbw-typst-template)).

[^1]: We consider some of the guidelines to be... plain ol' ugly, so we took some liberties in the formatting of headings, headers, footers, captions, colors, etc. If you still want to strictly adhere to the guidelines, set `style` to `"strict"`.


## Features

- **Three visual styles**: `fancy` (default), `clean`, and `strict` (university-compliant)
- **Easy to understand error messages**
- **Bilingual**: Spanish (`es`) and English (`en`)
- **Automatic front matter**: title page, abstract, acknowledgements, table of contents, list of figures/tables/listings, and abbreviations
- **Back matter**: bibliography, glossary, appendixes, and the mandatory generative AI declaration
- **APA or IEEE-style citations and figure/table captions** (or clean-style captions)
- **Glossary and acronym support** via [`glossarium`](https://typst.app/universe/package/glossarium/)
- **Chapter-level numbering** for figures, tables, and equations
- **Double-sided layout** support
- **PDF/A** compatible output



## Usage

For more in-depth information, check the [manual](docs/manual.pdf).


### Installation

#### Via Typst Universe (recommended)

You can initialize a new project from the template with:

```shell
typst init @preview/fancy-uc3m-thesis my-final-thesis
```

This creates a `my-final-thesis/` directory with all the files needed to get started.

#### Manual installation

Clone the repository, install [Just](https://github.com/casey/just) and run:
```
just install
```

Now you can initialize the template with:
```
typst init @local/fancy-uc3m-thesis my-final-thesis
```


### Compilation

Install [Typst](https://github.com/typst/typst?tab=readme-ov-file#installation) and run:
```bash
typst compile report.typ
```

To comply with the recommended PDF/A ISO standard:

```bash
typst compile report.typ --pdf-standard=a-4
```

You can also use an IDE extension to preview and compile:
- [VS Code](https://code.visualstudio.com/): [Tinymist Typst](https://marketplace.visualstudio.com/items/?itemName=myriad-dreamin.tinymist)
- [Neovim](https://neovim.io/): [typst-preview.nvim](https://github.com/chomosuke/typst-preview.nvim) plugin.
- [Zed](https://zed.dev/): [Typst](https://zed.dev/extensions/typst)
- [IntelliJ](https://www.jetbrains.com/ides/): [Typst Support](https://plugins.jetbrains.com/plugin/27697-typst-support)
- [GNU Emacs](https://www.gnu.org/software/emacs/): [typst-preview.el](https://github.com/havarddj/typst-preview.el)


## Disclaimer and university affiliation

This repository contains an unofficial thesis template intended to support academic writing and research.

**This template is an independent, community-created project. It is not an official Universidad Carlos III de Madrid (UC3M) publication, has not been approved, reviewed, sponsored, or endorsed by UC3M, and does not represent the university's official thesis formatting requirements.**

The UC3M name, logos, and other university visual identifiers are included solely to facilitate the preparation of academic documents associated with the university. Their inclusion does not imply any institutional affiliation, authorization, or endorsement of this template.

The university's name, logos, and visual identity remain subject to their respective rights and applicable terms. Use of this template does not grant permission to use UC3M trademarks or imply that such use is authorized by the university.

For official requirements, users should consult the relevant UC3M regulations and guidelines.


## More information

### Typst resources
- [Typst documentation](https://typst.app/docs)
  - [Guide for LaTeX users](https://typst.app/docs/guides/guide-for-latex-users/)
- [Typst forum](https://forum.typst.app/)
- [tex2typst](https://qwinsi.github.io/tex2typst-webapp) - converts LaTeX math formulas to/from Typst
  - [LaTeX-to-Typst Cheat Sheet](https://qwinsi.github.io/tex2typst-webapp/cheat-sheet.html)
- [Typst table generator](https://www.latex-tables.com/?format=typst&force)
- [Typst Examples Book](https://sitandr.github.io/typst-examples-book/book/)
- [Typerino](https://typerino.com/) - Online Typst equation editor
- [L. Casais - Memorias de p**** madre: Introducción a Typst](https://github.com/rajayonin/typst-intro)


### Examples
Here are some theses written using this template:
- [J. A. Verde - Procesamiento de señales de encefalograma para la detección de ataques epilépticos](https://github.com/joseaverde/TFG/tree/7ab7c2f6eeb9e70f27b7a67a8807b10a8a5a4152/report)
- [L. D. Casais - Implementing Interrupts, Timers, and Memory-Mapped I/O in CREATOR](https://github.com/ldcas-uc3m/TFM)
- [A. Guerrero - Implementación en FPGA del procesador didáctico WepSIM](https://github.com/ALVAROPING1/TFM)
- [J. A. Verde - Entorno para el modelado y simulación de sistemas electrónicos digitales](https://codeberg.org/joseaverde/TFM)


## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on commits, formatting, and pull requests.

If you find a bug or have a feature request, please [open an issue](https://github.com/guluc3m/uc3m-thesis-typst/issues).
