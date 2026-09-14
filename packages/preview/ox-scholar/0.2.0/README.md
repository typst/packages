# ox-scholar
[![Typst Universe](https://img.shields.io/badge/dynamic/xml?url=https%3A%2F%2Ftypst.app%2Funiverse%2Fpackage%2Fox-scholar&query=%2Fhtml%2Fbody%2Fdiv%2Fmain%2Fdiv%5B2%5D%2Faside%2Fsection%5B2%5D%2Fdl%2Fdd%5B3%5D&label=universe&logo=typst&color=39cccc)](https://typst.app/universe/package/ox-scholar)
[![Repo](https://img.shields.io/badge/GitHub-repo-blue)](https://github.com/fcelli/ox-scholar)
[![License: MIT](https://img.shields.io/badge/License-MIT-success.svg)](https://opensource.org/licenses/MIT)
![Release](https://img.shields.io/github/v/release/fcelli/ox-scholar)
[![Tests](https://github.com/fcelli/ox-scholar/actions/workflows/tests.yml/badge.svg)](https://github.com/fcelli/ox-scholar/actions/workflows/tests.yml)

Unofficial Typst template for an Oxford DPhil thesis.

<p align="center">
  <picture>
    <img src="thumbnail.png" style="width: 300px; height: auto;">
  </picture>
</p>

## Getting Started
To get started with Typst, please refer to the official [installation guide](https://github.com/typst/typst?tab=readme-ov-file#installation).

Once the Typst CLI is installed on your system, you can set up a new project using this template:
```shell
typst init @preview/ox-scholar:0.2.0
```

The template includes a pre-filled example demonstrating the basic layout. You can compile it to PDF with:
```shell
typst compile main.typ
```

For live preview while editing:
```shell
typst watch main.typ
```

A preview of the latest version of the default template is available on the ox-scholar [wiki](https://github.com/fcelli/ox-scholar/wiki#gallery).

### Thesis Function Documentation
The template provides a `thesis()` function that generates the thesis layout. You can use it with the parameters in the table below.

| Parameter |        Type       |        Description        | Default |
|-----------|-------------------|---------------------------|---------|
| `body`    | `content`         | The thesis content        |    —    |
| `title`   | `content \| none` | Full title of the thesis  | `none`  |
| `author`  | `content \| none` | Author’s full name        | `none`  |
| `college` | `content \| none` | Author’s college          | `none`  |
| `degree`  | `content`         | The degree being pursued  | `Doctor of Philosophy` |
| `submission-term` | `content \| none` | The term and year of submission (e.g., “Trinity Term, 2025”) | `none` |
| `acknowledgements` | `content \| none` | Content for the acknowledgements page | `none` |
| `abstract` | `content \| none` | Content for the abstract page | `none` |
| `logo`     | `image \| none`   | Image for the University or college logo | `none` |
| `show-toc` | `bool`            | Whether to show the table of contents | `true` |
| `bib`      | `content \| none` | Content for the bibliography | `none` |
| `draft`    | `bool`            | Whether to show line numbers | `false` |

Example usage:
```typ
#import "@preview/ox-scholar:0.2.0": *

#show: thesis.with(
  title: "Thesis Title",
  author: "Author",
  college: "College",
  degree: "Doctor of Philosophy",
  submission-term: "Submission Term, Year",
  acknowledgements: include "content/acknowledgements.typ",
  abstract: include "content/abstract.typ",
  logo: image("assets/beltcrest.png", width: 4.5cm),
  show-toc: true,
  bib: bibliography(
    "content/bibliography.bib",
    title: "References",
  ),
)

#include "content/section01.typ"
```

## Disclaimer
This template was developed after the submission of the author’s thesis. The author does not guarantee that a thesis prepared using this template will be accepted by the University of Oxford. However, the template is designed to conform to the University’s prescribed formatting and styling requirements.

## Acknowledgements
This template was heavily inspired by the [OxThesis](https://github.com/mcmanigle/OxThesis) LaTeX template, which served as a valuable reference in creating this Typst version.

## Contributions
If you encounter any issues using the template, please open an issue on this repository. Contributions are also welcome - if you develop useful extensions or make improvements, we would be happy to accept pull requests.
