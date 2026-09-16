# RVL Touying Theme

A Touying-based slide template for RVL group meetings.

## Use as a package

Import the theme in an existing Typst project:

```typ
#import "@preview/steady-rvl-slides:0.1.0": *
```

Then apply the theme:

```typ
#show: rvl-theme.with(
  config-info(
    title: [Paper Title],
    presenter: [Your Name],
    paper_venue: [ICRA 2026],
    date: rvl-date("2026-05-03"),
  ),
)
```

Use the template package to start a new project:

```bash
typst init @preview/steady-rvl-slides:0.1.0
```

This creates a project with:

- `main.typ`
- `assets/logo.png`

## Minimal example

```typ
#import "@preview/steady-rvl-slides:0.1.0": *

#show: rvl-theme.with(
  config-info(
    title: [Paper Title],
    presenter: [Your Name],
    paper_authors: [First Author, Second Author, Third Author, et al.],
    paper_venue: [ICRA 2026],
    date: rvl-date("2026-05-03"),
  ),
)

#rvl-title-slide()

#rvl-outline-slide(
  question: [What is the central research question?],
)[]

#rvl-slide(title: [Introduction])[
  - Motivation
  - Method
  - Results
]
```

## Public API

- `rvl-theme`
- `rvl-title-slide`
- `rvl-slide`
- `rvl-outline-slide`
- `rvl-stat-card`
- `rvl-figure-placeholder`
- `speaker-note`
- `alert`

## Template project

In the bundled starter template:

- `= Section` is a logical section marker only.
- Each `== Slide Title` becomes a slide automatically.
- For larger or more stable decks, prefer explicit `#rvl-slide(...)` and `#rvl-outline-slide(...)`.

## Development repo

This repository also includes local development helpers:

- `Makefile` for repo-local PDF and PPTX builds
- `examples/` for real decks and regression checks
- `skills/` for repo-local slide authoring guidance

## Repository layout

```text
.
├── typst.toml
├── lib.typ
├── src/
│   └── rvl_theme.typ
├── template/
│   ├── assets/
│   │   └── logo.png
│   ├── main.typ
├── thumbnail.png
├── examples/
│   └── YYYY-MM-DD/
│       ├── main.typ
│       ├── paper.pdf
│       └── figs/
├── Makefile
├── skills/
│   └── rvl-group-meeting-typst/
│       └── SKILL.md
```

- `lib.typ` is the package entrypoint.
- `src/rvl_theme.typ` is the single source of truth for the theme implementation.
- `template/` is the Universe-facing template copied by `typst init`.
- `Makefile` scaffolds repo-local examples from `template/main.typ`.
