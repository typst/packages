// A small, complete thesis built with MTT.
// Copy this file into your project and replace the example content. The

#import "@preview/mtt-thesis:0.1.0": *

// Acronyms are optional. Define them before using mtt-acronyms() below.
#import "@preview/acrostiche:0.7.0": *
#init-acronyms((
  "MTT": ("modular thesis template", "modular thesis templates"),
  "API": ("application programming interface", "application programming interfaces"),
))

#import "@preview/codly:2.0.0" as codly
#show raw.where(block: true): codly.new
#show: codly.theme("one-light")


// mtt-thesis controls the document-wide layout. The order of items in
// `before` and `after` is the order in which their pages are rendered.
#show: mtt-thesis.with(
  coverpage: mtt-coverpage(
    logo-left: image("template/eth_logo_kurz_cropped.svg", height: 25pt),
    logo-center: [],
    logo-right: rect(height: 35pt)[Department logo],
    org-units: (
      "Department of Everything",
      "Institute of Nothing",
    ),
    title: [A Very Inspiring Title],
    project-type: "Bachelor Thesis",
    date: datetime.today(),
    cover-image: image("template/cover-image.svg", width: 100%),
    authors: (
      (name: "Jane Doe", email: "janedoe@university.org"),
      (name: "John Doe", email: "johndoe@university.org"),
    ),
    authors-horizontal: true,
    advisors: ((name: "Advisor One", email: "advisor.one@university.org"),),
    professors: ((name: "Prof. Dr. Professor", email: "professor@university.org"),),
    empty-page: false,
  ),
  before: (
    mtt-abstract[
      This example shows the smallest useful configuration for a thesis. The
      document body follows the configuration below, while the lists and
      bibliography are added afterwards.
    ],
    mtt-toc(),
  ),
  after: (
    mtt-figures(),
    mtt-tables(),
    mtt-codes(),
    mtt-acronyms(),
    mtt-bibliography(
      bibliography(
        "references.bib",
        style: "american-physics-society",
        full: true,
        title: none,
      ),
    ),
    // Add this optional guide when starting to learn Typst.
    mtt-typst-guide(),
  ),
)

= Introduction

This is the document body. Write chapters directly in this file, or split
them into separate files with `#include("chapters/introduction.typ")`.

The #acr("MTT") provides reasonable defaults while leaving the document
structure in your control. The tables below summarize the functions provided by
the template. The examples in the following chapters demonstrate some of them
in more detail.

== The main template function

The main entry point configures the document and assembles its parts.

#mtt-code-sample(
  caption: [A simple example of `#mtt-thesis`.],
  ref: "code:simple"
)[
  #codly.new(
    raw(read("README.md").split(regex("```(typ\n)?")).at(1), lang: "typst", block: true),
    file: "simple.typ (from README)",
    indent-guides: (width: 4),
    rainbow: true,
    wrap-marker: [↪],
    breakable: true,
  )
]


== Functions that generate pages

These functions create complete pages or page-sized sections. They are mainly intended as appendix modules, as illustrated in @code:simple on lines 10-20.

#figure(
  table(
    columns: (auto, 1fr),
    table.header([*Function*], [*Purpose*]),
    [mtt-coverpage],
    [Create the thesis cover page from institutional, author, and project metadata.],
    [mtt-abstract],
    [Create a page containing a titled abstract.],
    [mtt-toc],
    [Create a formatted table of contents page.],
    [mtt-figures],
    [Create a list of figures of a selected figure kind.],
    [mtt-tables],
    [Create a list containing only table figures.],
    [mtt-codes],
    [Create a list containing only code sample figures.],
    [mtt-todos],
    [Create a list containing only todo figures.],
    [mtt-acronyms],
    [Create an acronym index with configurable sorting and layout.],
    [mtt-bibliography],
    [Create a titled bibliography page.],
    [mtt-content-frame],
    [Place content in a centered, titled frame.],
    [mtt-typst-guide],
    [Add the bundled Typst guide as a standalone page.],
  ),
  caption: [Functions that generate pages.],
)

== Smaller helper functions

These functions support common content patterns without creating a complete
document page.

#figure(
  table(
    columns: (auto, 1fr),
    table.header([*Function*], [*Purpose*]),
    [mtt-placeholder],
    [Display a task-style placeholder with an explanation and usage snippet.],
    [mtt-breakable-figure],
    [Place content in a breakable figure and infer its figure kind when requested.],
    [mtt-code-sample],
    [Place a breakable code sample in a raw figure with a configurable caption and label.],
    [mtt-space-equally],
    [Basically a grid, but with equal spacing in between the elements. \ Useful to distribute elements along a line or page.],
  ),
  caption: [Smaller helper functions.],
)


= Code of this File <ch:code>

This section reproduces the source code used to generate this entire PDF.

#mtt-code-sample(
  caption: [The Typst code generating this file.],
  ref: "code:example.typ"
)[
  #codly.new(
    raw(read("example.typ"), lang: "typst", block: true),
    file: "example.typ",
    indent-guides: (width: 4),
    rainbow: true,
    wrap-marker: [↪],
    breakable: true,
  )
]

