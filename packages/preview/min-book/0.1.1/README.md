# Minimal Books

<center>
  Simple and complete books without introducing new syntax
</center>


## Quick Start

```typst
#import "@preview/min-book:0.1.0": book
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


## More Information

- [Official manual](https://raw.githubusercontent.com/mayconfmelo/min-book/refs/tags/0.1.1/docs/pdf/manual.pdf)
- [Example PDF result](https://raw.githubusercontent.com/mayconfmelo/min-book/refs/tags/0.1.1/docs/pdf/example.pdf)
- [Example Typst code](https://github.com/mayconfmelo/min-book/blob/0.1.1/template/main.typ)
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
    <td>Cover title:</td>
    <td><a href="https://fonts.google.com/specimen/Cinzel">Cinzel</a></td>
  </tr>
  <tr>
    <td>Cover text:</td>
    <td><a href="https://fonts.google.com/specimen/Alice">Alice</a></td>
  </tr>
</table>


