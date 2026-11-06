# Minimal Books

<center align="center">

<p class="hidden">
Simple and complete books without introducing new syntax  
</p>

[![Tests](https://github.com/mayconfmelo/min-book/actions/workflows/tests.yml/badge.svg)](https://github.com/mayconfmelo/min-book/actions/workflows/tests.yml)
[![Build](https://github.com/mayconfmelo/min-book/actions/workflows/build.yml/badge.svg)](https://github.com/mayconfmelo/min-book/actions/workflows/build.yml)
[![Spellcheck](https://github.com/mayconfmelo/min-book/actions/workflows/spellcheck.yml/badge.svg)](https://github.com/mayconfmelo/min-book/actions/workflows/spellcheck.yml)

</center>


## Quick Start

```typst
#import "@preview/min-book:1.3.0": book
#show: book.with(
  title: "Book Title",
  subtitle: "Book subtitle, not more than two lines long",
  authors: "Book Author",
)
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

## More Information

- [Official manual](https://raw.githubusercontent.com/mayconfmelo/min-book/refs/tags/1.3.0/docs/manual.pdf)
- [Example PDF result](https://raw.githubusercontent.com/mayconfmelo/min-book/refs/tags/1.3.0/docs/example.pdf)
- [Example Typst code](https://github.com/mayconfmelo/min-book/blob/1.3.0/template/main.typ)
- [Changelog](https://github.com/mayconfmelo/min-book/blob/main/docs/changelog.md)
- [Development info](https://github.com/mayconfmelo/min-book/blob/main/docs/dev.md)


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
- Multi-language structure
  - Default translations for several languages
  - Custom translation files
  - Localization using [Fluent](https://projectfluent.org/)
- Advanced customization options
- Free default fonts
- End Notes
- Horizontal Rule
- Block Quote
- Appendices ambient
- Annexes ambient


## Default Fonts

**Text:**
[TeX Gyre Pagella](https://www.gust.org.pl/projects/e-foundry/tex-gyre/pagella/qpl2_501otf.zip) or
Book Antiqua
  
**Math:**
[Asana Math](https://mirrors.ctan.org/fonts/Asana-Math/Asana-Math.otf)
  
**Mono:**
[Inconsolata](https://fonts.google.com/specimen/Inconsolata)

**Cover title:**
[Cinzel](https://fonts.google.com/specimen/Cinzel)
    
**Cover text:**
[Alice](https://fonts.google.com/specimen/Alice)


## Translation Notice

From _min-book:1.3.0+_ there will be no automatic fallback to English anymore.
Refer to the section _TRANSLATION_ at the end of the manual for more information.