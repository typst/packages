# Minimal Manuals

<center align="center">

Modern but sober manuals inspired by the manpages of old.

[![Tests](https://github.com/mayconfmelo/min-manual/actions/workflows/tests.yml/badge.svg)](https://github.com/mayconfmelo/min-manual/actions/workflows/tests.yml)
[![Build](https://github.com/mayconfmelo/min-manual/actions/workflows/build.yml/badge.svg)](https://github.com/mayconfmelo/min-manual/actions/workflows/build.yml)
[![Spellcheck](https://github.com/mayconfmelo/min-manual/actions/workflows/spellcheck.yml/badge.svg)](https://github.com/mayconfmelo/min-manual/actions/workflows/spellcheck.yml)

</center>


## Quick Start

```typst
#import "@preview/min-manual:0.2.1": manual
#show: manual.with(
  title: "Package Name",
  description: "Short description, no longer than two lines.",
  package: "pkg-name:0.4.2",
  authors: "Author <@author>",
  license: "MIT",
  logo: image("assets/logo.png")
)
```


## Description

Generate modern manuals without losing the simplicity of old manpages. This
package draws inspiration from old manuals while adopting the facilities of
modern tools, like Markdown and documentation embedded in comments. The design
aims to be sober: a minimal informative header, technical text in comfortable
fonts and well-formatted code examples.


## More Information

- [Official manual](https://raw.githubusercontent.com/mayconfmelo/min-manual/refs/tags/0.2.1/docs/manual.pdf)
- [Example PDF result](https://raw.githubusercontent.com/mayconfmelo/min-manual/refs/tags/0.2.1/docs/example.pdf)
- [Example Typst code](https://github.com/mayconfmelo/min-manual/blob/0.2.1/template/manual.typ)
- [Changelog](https://github.com/mayconfmelo/min-manual/blob/main/docs/changelog.md)
- [Development info](https://github.com/mayconfmelo/min-manual/blob/main/docs/setup.md)


## Feature List

- Universal documentation
  - Typst packages
  - Typst templates
  - Source code in any other language
- `#arg` document arguments/parameters
- `#extract` retrieves code from other files or location
- `#example` displays code-result examples
  - Typst result
    - `#raw(lang: "eg|example")` syntax
  - Custom content result
- `#raw(lang: "term|terminal")` emulates a terminal window, with prompt highlight
- Paper-friendly links (attached to footnotes)
  - `#url` for general links 
  - `#univ` for Typst Universe packages
  - `#pip` for Python PyPi packages
  - `#crate` for Rust crates
  - `#gh` for GitHub repos
  - `#pkg` for packages of any source
- Documentation in standalone Typst files
- Documentation in standalone Markdown files (experimental)
  - CommonMark Markdown
  - Typst code support
  - All _min-manual_ features (Typst-only)
  - Special HTML syntax for `#arg`
- Documentation embedded in source code (comments)
  - Typst code support
  - All _min-manual_ features
  - Special syntax for `#extract`
  - Special syntax for `#arg`


## Default Fonts

**Text:**
[TeX Gyre Heros](https://www.gust.org.pl/projects/e-foundry/tex-gyre/heros/qhv2.004otf.zip) or
Arial

**Headings:**
[TeX Gyre Adventor](https://www.gust.org.pl/projects/e-foundry/tex-gyre/adventor/qag2_501otf.zip) or 
Century Gothic

**Mono:**
[Fira Mono](https://fonts.google.com/specimen/Fira+Mono) or
[Inconsolata](https://fonts.google.com/specimen/Inconsolata)