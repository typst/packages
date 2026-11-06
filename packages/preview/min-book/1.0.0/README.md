# Minimal Books

<center>
  Simple and complete books without introducing new syntax
</center>


## Quick Start

```typst
#import "@preview/min-book:1.0.0": book
#show: book.with(
  title: "Book Title",
  subtitle: "Complementary subtitle, not more than two lines long",
  authors: "Author",
)
```


## Description

Generate complete and complex books, without any annoying new commands or syntax,
just good old pure Typst. This package works by manipulating the standard Typst
elements, adapting them to the needs of a book structure. All of this is managed
behind the scenes, so that nothing changes in the Typst code itself.

The commands that `min-book` provides are only included for the sake of
completeness, and offers some fancy optional features like horizontal rules or
end notes; but it's perfectly possible to write entire books without them.


## More Information

- [Official manual](https://raw.githubusercontent.com/mayconfmelo/min-book/refs/tags/1.0.0/docs/manual.pdf)
- [Example PDF result](https://raw.githubusercontent.com/mayconfmelo/min-book/refs/tags/1.0.0/docs/example.pdf)
- [Example Typst code](https://github.com/mayconfmelo/min-book/blob/1.0.0/template/main.typ)
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


## Full List of Features

- Cover
  - Automatic generation
  - Creation using Typst
  - Using existing `#image`
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
- Accessible default fonts
- Book parts (headings)
- Book chapters (headings)
- End Notes
- Horizontal Rule
- Block Quote
- Appendices ambient
- Annexes ambient