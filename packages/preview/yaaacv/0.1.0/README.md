# yaaacv — Yet Another Also Awesome CV

A [Typst](https://typst.app) template package ported from the
[`yaac-another-awesome-cv`](https://github.com/darwiin/yaac-another-awesome-cv)
LaTeX class (© Christophe Roger, LPPL 1.3c).  It reproduces the class's
layout closely — light Source Sans Pro typography, blue accents, Font Awesome
icons, skill dot scales, tag chips, and the characteristic vertical rules —
while using idiomatic Typst APIs.

## Installation

Works out of the box from the Typst package registry:

```sh
typst init @preview/yaaacv
```

or import it directly in an existing document:

```typst
#import "@preview/yaaacv:0.1.0": *
```

## Requirements

The template uses system fonts; install them before compiling:

- [Source Sans Pro](https://github.com/adobe-fonts/source-sans) (Light + Regular)
- [Font Awesome 6 Free](https://fontawesome.com) (Solid + Regular)
- [Font Awesome 6 Brands](https://fontawesome.com)

## Usage

```typst
#import "@preview/yaaacv:0.1.0": *

#show: cv.with(language: "en")

#cvheader((
  firstname: [Jane],
  lastname: [Doe],
  tagline: [Professional Title],
  photo: "photo.jpg",   // cropped to a 2.5 cm circle
  github: "janedoe",    // linkedin, github-pages, phone, email,
  email: "jane@example.com",  // address, info likewise; none to omit
))

#section-title[Experience][#fa-suitcase]

#experience(
  [May 2024],                       // end date
  [Engineer at ACME],               // title
  website("https://acme.com", []),  // or none
  [Berlin],                         // location, or none
  [June 2020],                      // start date, or none
  [
    Summary of the role.
    - Achievement one
    - Achievement two
  ],
  ("tag", "tag"),
)
```

### Component overview

| Component | Purpose |
|---|---|
| `cv` | show rule / document setup (`language:` sets hyphenation) |
| `cvheader` | name, tagline, contact rows, circular photo |
| `section-title` | icon + small-caps heading + rule |
| `keywords` / `keywords-entry` | label/content competence lists |
| `experience` | dated entry with vertical rule and tags |
| `scholarship` / `scholarship-entry` | education entries |
| `project` | project entry with optional links, `visible:` flag |
| `skill` / `skills` | 6-level dot scales |
| `two-column-section` | side-by-side blocks |
| `website`, `cv-link`, `cvtag`, `tag-row`, `empty-separator` | helpers |
| `fa-*` | Font Awesome icon constants (`fa-github`, `fa-globe`, …) |

See the doc comments in [`lib.typ`](lib.typ) for every parameter.

## License

Dual-licensed under your choice of [MIT](LICENSE) or
[LPPL-1.3c](https://www.latex-project.org/lppl/lppl-1-3c/)
(SPDX: `MIT OR LPPL-1.3c`).  The design derives from the LPPL-licensed
`yaac-another-awesome-cv` LaTeX class; see the attribution note in
[LICENSE](LICENSE).
