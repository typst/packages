# Minimal Books

<center>
  Simple and complete books without introducing new syntax
</center>


## Quick Start

```typst
#import "@preview/min-book:1.1.0": book
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

- [Official manual](https://raw.githubusercontent.com/mayconfmelo/min-book/refs/tags/1.1.0/docs/manual.pdf)
- [Example PDF result](https://raw.githubusercontent.com/mayconfmelo/min-book/refs/tags/1.1.0/docs/example.pdf)
- [Example Typst code](https://github.com/mayconfmelo/min-book/blob/1.1.0/template/main.typ)
- [Changelog](https://github.com/mayconfmelo/min-book/blob/main/CHANGELOG.md)


## Default Fonts

<table>
  <tr>
    <td>Text:</td>
    <td>Book Antiqua, or<br/>Times New Roman</td>
  </tr>
  <tr>
    <td>Math:</td>
    <td><a href="https://mirrors.ctan.org/fonts/Asana-Math/Asana-Math.otf">
      Asana Math
    </a></td>
  </tr>
  <tr>
    <td>Mono:</td>
    <td><a href="https://fonts.google.com/specimen/Inconsolata">
      Inconsolata
    </a></td>
  </tr>
  <tr>
    <td>Cover title:</td>
    <td><a href="https://fonts.google.com/specimen/Cinzel">Cinzel</a></td>
  </tr>
  <tr>
    <td>Cover text:</td>
    <td><a href="https://fonts.google.com/specimen/Alice">Alice</a></td>
  </tr>
</table>


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
- Multi-language support
- Advanced customization options
- Accessible default fonts
- Book parts (headings)
- Book chapters (headings)
- End Notes
- Horizontal Rule
- Block Quote
- Appendices ambient
- Annexes ambient