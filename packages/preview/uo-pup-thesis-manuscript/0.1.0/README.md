# uo-pup-thesis-manuscript

Unofficial [typst](https://typst.app) template for undergraduate thesis manuscript for PUP (Polytechnic University of the Philippines). This template adheres to the University's Thesis and Dissertation Manual as of 2017 (ISBN: 978-971--95208-8-7 (Online)). An example manuscript is also provided (see `./thesis.pdf`).

## Setup
Using [Typst CLI](https://github.com/typst/typst?tab=readme-ov-file#installation):
```bash
typst init @preview/uo-pup-thesis-manuscript my-thesis
cd my-thesis
typst compile thesis.typ  # to compile to PDF
```

or run
```bash
typst watch thesis.typ  # to automatically compiles PDF on save
```

## Usage
The template already provided an example structure and some guides. But to start from nothing, make an entrypoint file with a basic structure like this:
```typ
// thesis.typ
#import "@preview/uo-pup-thesis-manuscript:0.1.0": *


#show: template.with(
  [<your thesis title here>],
  ("Author 1", "Author 2", ..., "Author N"),
  "name of your college here",
  "name of your deg. program here",
  "Month YYYY"
)


// Main content starts here

// This provides a customized heading for
// chapters that follows the manual
#chapter(1, "Chapter 1 Title") 

// Since #chapter() provides a heading level 1,
// start each headings under chapters with level 2
// to avoid messing up the generated Table of Contents
== Introduction

...

#chapter(2, "Chapter 2 Title")

== Topic A

...

// End of main content


// Bibliography formatting setup
#set par(first-line-indent: 0pt, hanging-indent: 0.5in)
#set page(header: context [#h(1fr) #counter(page).get().first()])
#align(center)[ #heading("REFERENCES") ]
#set par(spacing: 1.5em)

// Get the apa.csl file from `template/` folder
#bibliography(title: none, style: "./apa.csl", "path/to/your/bibtex/file.bib")


// Appendices
#show: appendices-section

#appendix(1, "Appendix Title")

...

#pagebreak()

#appendix(2, "Appendix Title")

...
```

There are also provided utilities for some parts that have a specific way of formatting.

For example, in `Definition of Terms` and `Significance of the Study` sections, use `#description` function:
```typ
== Significance of the Study
#description(
  (
    (term: [Topic A], desc: [#lorem(30)]),
    (term: [Topic B], desc: [#lorem(30)]),
    (term: [Topic C], desc: [#lorem(30)]),
  )
)

...

== Definition of Terms
#description(
  (
    (term: [Topic A], desc: [#lorem(30)]),
    (term: [Topic B], desc: [#lorem(30)]),
  )
)
```

<hr>

If there's any mistakes, wrong formatting (e.g., not actually following the manual), etc., file an issue or a pull request.

<hr>


## TODO
- [ ] Chapter 4
- [ ] Chapter 5
- [ ] Abstract
- [ ] Acknowledgement
- [ ] Copyright
- If possible:
    - Approval Sheet
    - Certificate of Originality
