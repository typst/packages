# cnam-thesis

[![Generic badge](https://img.shields.io/badge/Version-0.1.0-cornflowerblue.svg)](https://github.com/maucejo/bookly/releases/tag/0.1.0)
[![MIT License](https://img.shields.io/badge/License-MIT-forestgreen)](https://github.com/maucejo/book_template/blob/83b81913230586d26d11426b1a642ebb9081a360/LICENSE)
[![User Manual](https://img.shields.io/badge/Manual-.pdf-mediumpurple)](https://github.com/maucejo/cnam-thesis/blob/83b81913230586d26d11426b1a642ebb9081a360/docs/en/guide-en.pdf)
[![User Manual (FR)](https://img.shields.io/badge/Manual%20(FR)-.pdf-mediumpurple)](https://github.com/maucejo/cnam-thesis/blob/83b81913230586d26d11426b1a642ebb9081a360/docs/fr/guide-fr.pdf)

A Typst package to write Cnam PhD theses with a ready-to-use structure, title page, front/back matter helpers, and thesis-oriented styling. For more detailed information, see the [manual](https://github.com/maucejo/cnam-thesis/blob/83b81913230586d26d11426b1a642ebb9081a360/docs/en/guide-en.pdf).

`community-cnam-thesis` provides:

- A preconfigured thesis layout built on top of [`bookly`](https://typst.app/universe/package/bookly/).
- A Cnam-styled title page.
- Consistent chapter/section, TOC, table, and figure styling.
- Helpers for algorithms, review comments/annotations, and boxed content.
- A complete project template (`template/`) to bootstrap a new thesis quickly.

## Installation and initialization

Import from Typst Universe:

```typst
#import "@preview/community-cnam-thesis:0.1.0": *
```

## Quick start

Minimal thesis document:

```typst
#import "@preview/community-cnam-thesis:0.1.0": *

#show: community-cnam-thesis.with(
	title: "My Thesis Title",
	author: "Jane Doe",
	thesis-info: (
		doctoral-school: "Sciences des Metiers de l'Ingenieur",
		laboratory: "My Lab",
		defense-date: "June 15, 2026",
	),
	lang: "en",
	open-right: true,
)

#show: front-matter

= Abstract
My abstract.

#show: main-matter

#tableofcontents

= Introduction
Hello thesis.

#bibliography("bibliography/sample.bib")

#show: appendix

= Appendix
I forgot some information
```

## Configuration: `thesis-info`

`thesis-info` is a dictionary merged with package defaults. Main keys:

- `doctoral-school`
- `supervisor` (array of `(name, title, institution)`)
- `co-supervisor` (same shape)
- `laboratory`
- `defense-date`
- `discipline`
- `speciality`
- `committee` (array of `(name, position, role)`)
- `dedication`
- `logo` (single image or array of images)

You can also load data from JSON/YAML and spread it into `thesis-info`.

## Main functions

### Core entrypoint

- `community-cnam-thesis(...)`
	- Main setup wrapper for the whole document.
	- Applies fonts, theme, colors, title page, bibliography style, and document options.
	- Parameters:
		- `title`, `author`
		- `thesis-info`
		- `lang` (`"fr"` or `"en"`)
		- `open-right` (chapter opening behavior)

### Theme-level helpers

- `#part("Title")`: Styled part page.
- `#minitoc`: Mini table of contents of a chapter.
- `tableofcontents`: Table of contents of the thesis.
- `listoffigures`: List of figures.
- `listoftables`: List of tables.

### Content helpers

- `algorithm[...]`: Pseudocode blocks with thesis styling.
- `backcover(resume: ..., abstract: ...)`: A back cover with bilingual summaries.

### Review/annotation helpers

- `activate-comment` / `deactivate-comment`: Enable/disable wide margin layout for review notes.
- `comment(by: ..., type: ..., inline: ...)[...]`: Margin or inline review note.
- `highlight-comment(..., highlight-body: ...)[...]`: Highlights text and attaches a comment.
- `listofnotes`: List of review notes.

## Licence

MIT licensed

Caution: The Cnam logo included in the template is from Wikimedia and is under a CC-0 license.

Copyright © 2026 Mathieu AUCEJO (maucejo)
