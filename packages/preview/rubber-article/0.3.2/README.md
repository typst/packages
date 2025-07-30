# The `rubber-article` Package
[![Dynamic TOML Badge](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fnpikall%2Frubber-article%2Frefs%2Fheads%2Fmain%2Ftypst.toml&query=%24.package.version&prefix=v&logo=typst&label=template&color=239DAD)](https://typst.app/universe/package/rubber-article)
[![MIT License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/npikall/rubber-article/blob/main/LICENSE)

<!-- <div align="center">Version 0.3.2</div> -->

This template is a intended as a starting point for creating documents, which should have the classic LaTeX Article look.

## Getting Started

These instructions will get you a copy of the project up and running on the typst web app. Perhaps a short code example on importing the package and a very simple teaser usage.

```typ
#import "@preview/rubber-article:0.3.2": *

#show: article.with()

#maketitle(
  title: "The Title of the Paper",
  authors: ("Authors Name",),
  date: "September 2024",
)
```

## Further Functionality
The template provides a few more functions to customize the document.
For an indepth look into the functionality checkout the [guide].

```typ
#show article.with(
  lang:"de",
  eq-numbering:none,
  text-size:10pt,
  page-numbering: "1",
  page-numbering-align: center,
  heading-numbering: "1.1  ",
)
```

[guide]: https://github.com/npikall/rubber-article/tree/main/docs/docs.pdf