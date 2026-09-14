# The `rubber-article` Package
[![Dynamic TOML Badge](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fnpikall%2Frubber-article%2Frefs%2Fheads%2Fmain%2Ftypst.toml&query=%24.package.version&prefix=v&logo=typst&label=template&color=239DAD)](https://typst.app/universe/package/rubber-article)
[![MIT License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/npikall/rubber-article/blob/main/LICENSE)
[![Test Status](https://github.com/npikall/rubber-article/actions/workflows/ci.yml/badge.svg)](https://github.com/npikall/rubber-article/actions/workflows/ci.yml)
[![User Manual](https://img.shields.io/badge/doc-.pdf-mediumpurple)](https://github.com/npikall/rubber-article/blob/main/docs/docs.pdf)



<!-- <div align="center">Version 0.4.0</div> -->

This template is intended as a starting point for creating documents, which should have the classic LaTeX Article look.

## Getting Started

You can use this template in the Typst web app by clicking **Start from template** on the dashboard and searching for `rubber-article`.
Alternatively, you can use the CLI to kick this project off using the command
```bash
typst init @preview/rubber-article
```
This will create a new Typst project in the current directory with the `rubber-article` template, with some example content, applied.

The following code snippet shows the minimal example of how to use the template.
```typ
#import "@preview/rubber-article:0.4.0": *

#show: article.with()

#maketitle(
  title: "The Title of the Paper",
  authors: ("Authors Name",),
  date: "September 2024",
)
```

## Further Functionality
The template provides a few more functions and parameters to customize the document.
For an indepth look into the functionality checkout the [guide].

For now here are a few of the most important parameters of the main function.

```typ
#show article.with(
  lang:"de",
  eq-numbering:"(1.1)",
  eq-chapterwise:true,
  text-size:10pt,
  page-numbering: "1",
  page-numbering-align: center,
  heading-numbering: "1.1",
  header-display: false,
  fig-caption-width:70%,
)
```
Some features are not from the original LaTeX article class, but have been added, as they have been deemed useful or nice to have. An example would be the built-in header, which displays the Documents title and the current chapter name.

## Contributing
Feel free to open an issue or a pull request in the [repository].
Questions, suggestions and feature requests are always welcome.

## Local Installation
To install this template locally, follow the steps below:

- Install `Just` task runner
- Clone the [repository]
- run `just install`

The template can then be imported with
```typ
#import "@local/rubber-article:0.4.0"
```
To install the package in the preview namespace, run `just install-preview` instead.


[guide]: https://github.com/npikall/rubber-article/tree/main/docs/docs.pdf
[repository]: https://github.com/npikall/rubber-article