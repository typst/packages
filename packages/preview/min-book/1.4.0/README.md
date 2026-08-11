# Minimal Books

<div align="center">

<p class="hidden">
  Simple and complete books without introducing new syntax  
</p>

<p class="hidden">
  <a href="https://typst.app/universe/package/min-book">
    <img src="https://img.shields.io/badge/dynamic/xml?url=https%3A%2F%2Ftypst.app%2Funiverse%2Fpackage%2Fmin-book&query=%2Fhtml%2Fbody%2Fdiv%2Fmain%2Fdiv%5B2%5D%2Faside%2Fsection%5B2%5D%2Fdl%2Fdd%5B3%5D&logo=typst&label=Universe&color=%23239DAE&labelColor=%23353c44" /></a>
  <a href="https://github.com/mayconfmelo/min-book/tree/dev/">
    <img src="https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fmayconfmelo%2Fmin-book%2Frefs%2Fheads%2Fdev%2Ftypst.toml&query=%24.package.version&logo=github&label=Development&logoColor=%2397978e&color=%23239DAE&labelColor=%23353c44" /></a>
</p>

[![Manual](https://img.shields.io/badge/Manual-%23353c44)](https://raw.githubusercontent.com/mayconfmelo/min-book/refs/tags/1.4.0/docs/manual.pdf)
[![Themes](https://img.shields.io/badge/Themes-%23353c44)](https://github.com/mayconfmelo/min-book/blob/main/docs/themes.md)
[![Example PDF](https://img.shields.io/badge/Example-.pdf-%23777?labelColor=%23353c44)](https://raw.githubusercontent.com/mayconfmelo/min-book/refs/tags/1.4.0/docs/example.pdf)
[![Example SRC](https://img.shields.io/badge/Example-.typ-%23777?labelColor=%23353c44)](https://github.com/mayconfmelo/min-book/blob/1.4.0/template/main.typ)
[![Changelog](https://img.shields.io/badge/Changelog-%23353c44)](https://github.com/mayconfmelo/min-book/blob/main/docs/changelog.md)
[![Contribute](https://img.shields.io/badge/Contribute-%23353c44)](https://github.com/mayconfmelo/min-book/blob/main/docs/contributing.md)

<p class="hidden">
  <a href="https://github.com/mayconfmelo/min-book/actions/workflows/tests.yml">
    <img alt ="Tests" src="https://github.com/mayconfmelo/min-book/actions/workflows/tests.yml/badge.svg"></a>
  <a href="https://github.com/mayconfmelo/min-book/actions/workflows/build.yml">
    <img alt="Build" src="https://github.com/mayconfmelo/min-book/actions/workflows/build.yml/badge.svg"></a>
  <a href="https://github.com/mayconfmelo/min-book/actions/workflows/spellcheck.yml">
    <img alt ="Spellcheck" src="https://github.com/mayconfmelo/min-book/actions/workflows/spellcheck.yml/badge.svg"></a>
</p>
</div>


## Quick Start

```typst
#import "@preview/min-book:1.4.0": book
#show: book.with(
  title: "Book Title",
  subtitle: "Book subtitle",
  authors: "Book Author",
)

= Book Part

== Book Chapter
#lorem(200)
```


## Description

Generate complete and complex books, without any annoying new commands or
syntax, just good old pure Typst. This package manipulates the standard Typst
elements as much as possible, adapting them to the needs of a book structure
in a way that there's no need to learn a whole new semantic just because of
_min-book_.

For some fancy book features there is no existing compatible Typst element to
re-work and adapt; in those cases, this package do provide additional commands
that are completely optional, for the sake of completeness.

This package comes with some thoughful ready-to-use defaults but also allows
you to play with highly customizable options if you need them, so it's really
up to you: customize it your way or ride along the defaults — both ways are
possible and encouraged.


## Feature List

- Cover
  - Automatic generation
  - Creation using Typst
  - Existing image
- Title page
  - Automatic generation
  - Creation using Typst
- Cataloging in Publication
- Errata
- Dedication
- Acknowledgments
- Epigraph
- Table of contents
  - Automatic generation
  - Insert manually
- Book parts (headings)
- Book chapters (headings)
- Translations
  - Default translations for several languages
  - Custom translation files
  - Localization using [Fluent](https://projectfluent.org/)
- Themes
  - Stylish (default)
  - Coffee
  - Elegance
  - Custom themes
- Advanced customization options
- Free default fonts
- End Notes
- Horizontal Rule
- Block Quote
- Appendices ambient
- Annexes ambient


## Default Fonts

Each theme may require a different set of default fonts to function correctly.
The fonts required by the built-in themes can be found in [`docs/themes.md`](
https://github.com/mayconfmelo/min-book/blob/main/docs/themes.md).

For third-party themes, please refer to their documentation.
