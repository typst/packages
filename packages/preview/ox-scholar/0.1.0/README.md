# ox-scholar
[![Tests](https://github.com/fcelli/ox-scholar/actions/workflows/tests.yml/badge.svg)](https://github.com/fcelli/ox-scholar/actions/workflows/tests.yml)
[![Repo](https://img.shields.io/badge/GitHub-repo-blue)](https://github.com/fcelli/ox-scholar)
[![License: MIT](https://img.shields.io/badge/License-MIT-success.svg)](https://opensource.org/licenses/MIT)
<div align="center">Version 0.1.0</div><br/>

Unofficial Typst template for an Oxford DPhil thesis.

## Getting Started
To get started with Typst, please refer to the official [installation guide](https://github.com/typst/typst?tab=readme-ov-file#installation).

Once the Typst CLI is installed on your system, you can set up a new project using this template:
```shell
typst init @preview/ox-scholar:0.1.0
```

The template includes a pre-filled example demonstrating the basic layout. You can compile it to PDF with:
```shell
typst compile main.typ
```

For live preview while editing:
```shell
typst watch main.typ
```

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="./thumbnail-dark.svg">
    <img src="./thumbnail-light.svg" style="width: 500px; height: auto;">
  </picture>
</p>

### Thesis Function Documentation
The template provides a `thesis()` function that generates the thesis layout. You can configure it with your title, author, and other optional parameters.
- `title`: The full title of the thesis.
- `author`: The author's full name.
- `college`: The author's college.
- `degree`: The degree being pursued. Defaults to "Doctor of Philosophy".
- `submission-term`: The term and year of submission (e.g., “Trinity Term, 2025”).
- `acknowledgements`: Optional content for acknowledgements.
- `abstract`: Optional content for the abstract section.
- `logo`: Optional image for the university or college logo.
- `show-toc`: Boolean to include the table of contents. Defaults to true.
- `bib`: Optional bibliography.

Example usage:
```typ
#import "@preview/ox-scholar:0.1.0": *

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
