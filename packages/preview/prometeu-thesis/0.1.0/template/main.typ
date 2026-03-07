#import "@preview/prometeu-thesis:0.1.0": colors, formatting, thesis

#show: thesis(
  author: "Author's full name",
  title: [Title Title Title Title Title Title \ Title Title Title Title Title \ Title Title Title Title],
  date: [september 2025],
  supervisors: (
    [Supervisor Name],
    [Co-Supervisor Name],
  ),
  cover-images: (image("logos/uminho/color/UM.jpg"), image("logos/uminho/color/EE.jpg")),
  cover-gray-images: (image("logos/uminho/gray/UM.jpg"), image("logos/uminho/gray/EE.jpg")),
  school: [School of Engineering],
  degree: [Master's Dissertation in Informatics Engineering],
)

// Setup glossary
#import "@preview/glossy:0.8.0": *
#show: init-glossary.with(yaml("glossary.yaml"))

// Setup index
#import "@preview/in-dexter:0.7.2": *

#formatting.show-preamble[
  #include "preamble/copyright.typ"
  #pagebreak()
  #include "preamble/acknowledgements.typ"
  #pagebreak()
  #include "preamble/integrity.typ"
  #pagebreak()
  #include "preamble/abstract.typ"
  #pagebreak()
  #outline()
  #pagebreak()
  #outline(title: [List of Figures], target: figure.where(kind: image))
  #pagebreak()
  #outline(title: [List of Tables], target: figure.where(kind: table))
  #pagebreak()
  #pagebreak()
]

#show: formatting.show-main-content

= Introductory Material

== Introduction

Context, motivation, main aims.

== State of the Art
State of the art review; related work.

=== Citations

Example of a citation: @rustbook, or #cite(<rustbook>, form: "full"). This entry is in the `bibliography.yml` file.

Typst also supports the LaTeX `.bib` file format, but the #link("https://github.com/typst/hayagriva/blob/main/docs/file-format.md")[Hayagriva YAML format] is easier to use.

Check more information about bibliography #link("https://typst.app/docs/reference/model/bibliography/")[here] and #link("https://typst.app/docs/reference/model/cite/")[here].

=== Mathematical expressions

The mass-energy equivalence is expressed by the equation

#[
  // Move this set rule out of this content block to affect all equations in the document
  #set math.equation(numbering: "(1)")
  $
    E = m c^2
  $
]

discovered in 1905 by Albert Einstein. In natural units ($c = 1$) the formula expresses the identity
$
  E = m
$

Check more information about math expressions #link("https://typst.app/docs/reference/math/equation/")[here].

=== Footnotes

This is a footnote example #footnote[The quick brown fox jumps over the lazy dog.].

=== Acronyms and Glossary

Given a set of numbers, there are elementary methods to compute its @gcd, which is abbreviated @gcd. This process is similar to that used for the @lcm.

The @typst language is specially suitable for documents that include @maths. @formula:pl are rendered properly as the Typst syntax is designed to be easy to understand and use.

This glossary is powered by the #link("https://typst.app/universe/package/glossy/")[glossy] package. Check more about it there.

=== Index

In this example, several keywords #index[keywords] will be used which are important and deserve to appear in the Index#index[Index].

Terms like generate #index[generate] and some #index[others] will also show up. Terms in the index can also be nested#index([Index], [nested]).

The index is powered by the #link("https://typst.app/universe/package/in-dexter/")[in-dexter] package. Check more about it there.

== The problem and its challenges

The problem and its challenges.

=== Images

Example of inserting an image as displayed text,

#align(center, image("logos/uminho/color/UM.jpg", width: 10%))

or as a figure:

#figure(image("logos/uminho/color/UM.jpg", width: 30%), caption: [Logo of the University of Minho])

= Core of the Dissertation

== Contribution

Main result(s) and their scientific evidence

=== Introduction

=== Summary

== Applications

Applications of the main result (examples and case studies)

=== Introduction

=== Summary

== Conclusions and future work

Conclusions and future work

=== Conclusions

=== Future work

== Planned Schedule

=== Activities

#let filled = $circle.filled.small$

#figure(
  table(
    columns: 11,
    [Task], [Oct], [Nov], [Dec], [Jan], [Feb], [Mar], [Apr], [May], [Jun], [Jul],
    [Background and SOA], filled, filled, filled, [], [], [], [], [], [], [],
    [PDR preparation], [], filled, filled, filled, [], [], [], [], [], [],
    [Contribution], [], [], ..(filled,) * 7, [],
    [Writing up], [], [], [], [], [], [], ..(filled,) * 4,
  ),
  caption: [Planned Schedule],
)

For more elegant visualisation check some community-made packages like #link("https://typst.app/universe/package/gantty/")[gantty] or #link("https://typst.app/universe/package/timeliney/")[timeliney].

#formatting.show-postamble[
  // Render bibliography
  // Change this to a .bib file if you prefer that format instead
  #bibliography("bibliography.yml", full: true)

  // Render index
  = Index
  #columns(
    2,
    make-index(
      title: none,
      use-page-counter: true,
      section-title: (letter, counter) => {
        set text(weight: "bold")
        block(letter, above: 1.5em)
      },
    ),
  )
]

#formatting.show-appendix[
  #include "appendix.typ"
]

#set page(numbering: none)

#page(fill: colors.pantonecoolgray7)[]

#align(
  horizon,
)[Place here information about funding, FCT project, etc. in which the work is framed. Leave empty otherwise.]
