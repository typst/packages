# Faculty of Engineering Freiburg Thesis Template

A Typst thesis template for bachelor, master, and doctoral theses at the
Faculty of Engineering, University of Freiburg.

## Quick Start

Create a new project from Typst Universe:

```sh
typst init @preview/tf-freiburg-thesis:0.1.0
```

Or import the package in an existing Typst document:

```typst
#import "@preview/tf-freiburg-thesis:0.1.0": *

#show: thesis.with(
  title: "Thesis Title",
  author: "Author Name",
  faculty: "Faculty of Engineering, University of Freiburg",
  department: "Department of Computer Science",
  research-group: "Research Group Name",
  thesis-type: "master",
  language: "en",

  abstract: [
    Your abstract goes here.
  ],

  chapters: (
    include "content/1_introduction.typ",
  ),

  bibliography-content: bibliography("references.bib", style: "ieee", title: none),
)
```

For local development from this repository, import the package entrypoint
directly:

```typst
#import "src/main.typ": *
```

## Configuration

Core metadata:

- `title`, `author`, `email`, `immatriculation`
- `faculty`, `department`, `research-group`, `website`
- `location`, `date`, `language`, `title-language`
- `thesis-type`: `"bachelor"`, `"master"`, or `"phd"`
- `jury`: tuples of `(role, person)`, for example `([Supervisor], [Prof. Dr. Name])`

Document content:

- `abstract`, `abstract-en`, `abstract-de`
- `declaration`, `declaration-signature`
- `acknowledgments`
- `chapters`, `appendices`
- `bibliography-content`

Layout and typography:

- `two-sided`, `mirror-book`, `margin-top`, `margin-bottom`, `margin-inner`, `margin-outer`
- `body-font`, `sans-font`, `mono-font`
- `body-size`, `mono-size`, `footnote-size`, `header-size`
- `chapter-number-size`, `chapter-title-size`, `sections`
- `logo`, `logo-width`, `seal`, `seal-width`

## Helpers

The package exports common thesis helpers:

```typst
#todo[Add more detail]
#sidenote[numbered: true][A margin note.]
#definition(title: "Definition")[A custom definition box.]
#theorem(title: "Theorem")[A custom theorem box.]
#algorithm(caption: [Binary search])[...]
#citet(<turing1950>)
#citep(<turing1950>)
```

It also exports `ie`, `eg`, `cf`, and `etal` abbreviation helpers.

## License and Assets

This repository is licensed as CC BY 4.0, matching `typst.toml`.

The Freiburg logo and seal assets in `src/assets/template/logo-freiburg/` are
included for use with this university template. If you redistribute a modified
package, verify that your use of those assets follows the University of
Freiburg's current brand and usage rules.

## Publishing

CI validates the package on pushes and pull requests. To prepare a Typst
Universe submission PR, create a repository secret named `REGISTRY_TOKEN` with
permission to push to `Arturjssln/typst-packages`, then push a tag matching the
manifest version:

```sh
git tag v0.1.0
git push origin v0.1.0
```

The publish workflow stages this package under
`packages/preview/tf-freiburg-thesis/0.1.0` in the fork and opens a pull request
against `typst/packages`.
