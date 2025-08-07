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
  cover: image("assets/cover.jpeg"),
)
```


## Description

Generate complete and complex books, without any annoying new commands or syntax,
just good old pure Typst. This package works by manipulating the standard Typst
elements, adapting them to the needs of a book structure. All of this is managed
behind the scenes, so that nothing changes in the Typst code itself.


## More Information

- [Official manual](https://raw.githubusercontent.com/mayconfmelo/min-book/refs/tags/0.1.0/docs/pdf/manual.pdf)
- [Example PDF result](https://raw.githubusercontent.com/mayconfmelo/min-book/refs/tags/0.1.0/docs/pdf/example.pdf)
- [Example Typst code](https://github.com/mayconfmelo/min-book/blob/0.1.0/template/main.typ)
- [Changelog](https://github.com/mayconfmelo/min-book/blob/main/CHANGELOG.md)