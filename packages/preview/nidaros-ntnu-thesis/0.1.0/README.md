# Nidaros NTNU Thesis

Unofficial NTNU thesis template for Typst, based on the public visual structure of the NTNU LaTeX thesis template. The goal is to give students a compact Typst starting point with NTNU-like title pages, roman-numbered front matter, chapter openings, running headers, lists of figures/tables, references, and appendices.

This project is not affiliated with, endorsed by, or maintained by NTNU.

## Usage

Start a new project from Typst Universe:

```sh
typst init @preview/nidaros-ntnu-thesis:0.1.0
```

Or import the template in an existing document:

```typst
#import "@preview/nidaros-ntnu-thesis:0.1.0": *

#show: ntnu-thesis.with(
  title: [The title of your master's thesis],
  author: "Your Name",
)
```

The generated `main.typ` shows the recommended structure:

```typst
#title-page(
  author: "Your Name",
  title: "The title of your master's thesis",
  subtitle: "Optional subtitle",
  programme: "Master's thesis in Physics and Mathematics",
  supervisor: "Supervisor Name",
  co-supervisor: "Co-supervisor Name",
  date: "June 2026",
)

#front-matter[
  #front-chapter("Abstract")[Your abstract.]
  #contents()
]

#main-matter[
  = Introduction
  Your thesis starts here.
]
```

## Logo

The official NTNU logo is not bundled with this template. University logos and similar assets usually need explicit redistribution rights. If you have permission to use the logo in your own thesis, pass it as content from your project:

```typst
#title-page(
  logo: image("figures/ntnu-logo.png", width: 28%),
)
```

## Public API

- `ntnu-thesis(..)[body]`: Applies global document, font, heading, figure, equation, paragraph, and link styles.
- `title-page(..)`: Creates the NTNU-like thesis title page.
- `front-matter[body]`: Starts roman-numbered front matter with centered footers.
- `front-chapter(title)[body]`: Creates unnumbered front matter chapters such as Abstract and Preface.
- `contents()`: Creates Contents, List of Figures, and List of Tables pages.
- `main-matter[body]`: Starts arabic-numbered main matter with running chapter headers.
- `references[body]`: Adds a references page wrapper. Put `#bibliography("bibliography.bib", title: "References", style: "ieee")` inside it.
- `appendices[body]`: Starts the appendix section.

## Development

This repository is intentionally small. Do not commit generated PDFs, LaTeX build artifacts, local editor files, or copyrighted assets without redistribution rights.

To test the template locally before it is published, place or symlink the repository into Typst's local package path as:

```text
{data-dir}/typst/packages/preview/nidaros-ntnu-thesis/0.1.0
```

Then run:

```sh
typst init @preview/nidaros-ntnu-thesis:0.1.0
typst compile main.typ
```
