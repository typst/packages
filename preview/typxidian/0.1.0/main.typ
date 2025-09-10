
#import "template.typ": template
#import "dependencies.typ": cetz, subfigure, gls, glspl, booktabs-default-table-style, wrap-content, wrap-top-bottom

#show: template.with(
  title: [TypXdian],
  subtitle: [A modern Typst template inspired by Obsidian],
  authors: ("Angelo Nazzaro",),
  supervisors: ("Prof. Mario Rossi", "Prof. Giuseppe Verdi"),
  abstract: [
    This is Typst template inspired by Obsidian callouts and color palette. 
    The template is designed for note taking and thesis/reports writing. This document serves both as a showcase example and as documentation on how to use the template.
  ],
  university: [University of Salerno],
  department: [Department of Computer Science],
  faculty: [Faculty of Science],
  degree: [Master's Degree in Computer Science],
  academic-year: [2024/2025],
  citation: [
    "_*Dreams*. Each man longs to pursue his dream. 
     Each man is tortured by this dream, but the dream gives meaning to his life. 
     Even if the dream ruins his life, man cannot allow himself to leave it behind.
     In this world, is man ever able to possess anything more solid, than a dream?_" 
    #align(right, [_#sym.tilde.op Kentaro Miura_])
],
  is-thesis: true,
)
#import "@preview/metalogo:1.2.0": TeX, LaTeX 


= Introduction

The *TypXdian template* offers a clean, modern structure for academic documents. It is heavily inspired by Obsidian’s design principles, while the style of headers, headings, and citations takes inspiration from @scardapane2024alicesadventuresdifferentiablewonderland. This chapter introduces the general layout of the template and demonstrates how it can be configured through parameters.

== Front Matter

=== Cover Page
The cover page supports two display modes:
- *Authors-only view*: for reports, notes, or shorter projects;
- *Supervisors + authors view*: for theses or dissertations.

You can switch between them by setting the `supervisors` parameter. If you pass an empty list (the default), the supervisors section will be hidden.

Additional metadata parameters include:
- `university`: name of the university;
- `logo`: university logo (defaults to `assets/figures/logo.svg`);
- `academic-year`: the academic year, e.g. *2024/2025* (defaults to `none`);
- `faculty`: the faculty name (defaults to `none`);
- `department`: the department name (defaults to `none`);
- `degree`: the degree program (defaults to `none`);
- `is-thesis`: if `true`, the “AUTHOR(S)” label changes to “CANDIDATE(S)” (defaults to `false`).

=== Abstract & Citation
By setting the `abstract` and `citation` parameters, the template adds two additional pages *before* the table of contents. The abstract page summarizes the work, while the citation page provides an optional epigraph or quotation. The citation page does *not* appear in the table of contents.

=== Table of Contents
The table of contents automatically detects headings up to level $3$. It also supports dynamically generated:
- List of Figures,
- List of Tables,
- List of Definitions (#gls("wip")),
- List of Theorems (#gls("wip")).

=== Glossary
Glossary terms can be referenced with explicit citation functions from the `glossarium` package:
- `#gls("ai")` → renders the glossary entry for #gls("ai").
- `#glspl("AI")` → renders the plural form (if defined).

Currently, direct referencing with `@ref` is not supported.

=== Additional Content
You may inject content directly via parameters:
- `before-content`: material inserted between the abstract/citation and the table of contents (defaults to `none`);
- `after-content`: material added immediately after the table of contents.

These are useful for dedicatory pages, acknowledgements, or institutional notices.

== Main Matter

Each top-level heading (`=`) starts on a fresh page, separating major chapters. The heading and header styles are designed for clarity and are inspired by @scardapane2024alicesadventuresdifferentiablewonderland.

== Back Matter

The back matter includes automatically generated references and a credits page. You can disable the credits page by setting the `include-credits` parameter. 

= Figures, Equations, and Paragraphs

Figures (images, tables and custom environments), equations, and paragraphs are all numbered within their section to ensure consistent cross-referencing.

== Subfigures
The template provides a wrapper around the `subpar` package to simplify subfigure handling. Use the `subfigure` function instead of `subpar.grid` to maintain numbering consistency.
For example, this code:
```typst
#subfigure(
  columns: (1fr, 1fr),
  figure(
    image("assets/figures/cat.jpg"),
    caption: [This is a cat.],
  ),
  figure(
    image("assets/figures/dog.jpg"),
    caption: [This is a dog.],
  ),
  caption: [A cat and a dog.]
)
```
outputs:
#subfigure(
  columns: (1fr, 1fr),
  figure(
    image("assets/figures/cat.jpg", width: 150pt, height: 100pt),
    caption: [This is a cat.],
  ),
  figure(
    image("assets/figures/dog.jpg", width: 150pt, height: 100pt),
    caption: [This is a dog.],
  ),
  caption: [A cat and a dog.]
)

== Paragraphs
Headings at or deeper than level $4$ are styled as standalone paragraphs, mimicking LaTeX’s `\paragraph{}` command.
For example, this code:
```typst
==== Paragraph test
<par-test>
I am the body of this paragraph.
```
outputs:
==== Paragraph test
<par-test>
I am the body of this paragraph.
#linebreak()
Each labeled paragraph can be referenced like any other element, e.g. @par-test.

= Callouts, Definitions and Theorems

Obisidian-like callouts, definitions and theorems are a work in progress and will be released soon.