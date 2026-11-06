#import "@preview/prometeu-thesis:1.0.0": colors, thesis

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
  // Set this to "pt" for Portuguese titles
  language: "en",
)

// Setup glossary and acronyms
#import "@preview/glossarium:0.5.10": *

#show: make-glossary
#let acronyms-data = yaml("acronyms.yml")
#let glossary-data = yaml("glossary.yml")
#register-glossary(acronyms-data + glossary-data)

#let show-acronyms = print-glossary(
  acronyms-data,
  // Change this to your liking
  show-all: true,
  disable-back-references: true,
  user-print-title: entry => {
    let description = if entry.long != none { h(0.5em) + entry.long + [.] }
    text(weight: "bold", entry.short) + description
  },
)

#let show-glossary = print-glossary(
  glossary-data,
  // Change this to your liking
  show-all: true,
  disable-back-references: true,
  user-print-title: entry => {
    let title = if entry.long == none { entry.short } else { entry.long }
    text(weight: "bold", title) + h(0.5em) + entry.description
  },
  user-print-description: entry => if entry.description != none { [.] },
  description-separator: [],
)

// Setup index
#import "@preview/in-dexter:0.7.2": *

#[
  #set page(numbering: "i")
  #counter(page).update(1)

  // Preamble should not be included in the outline
  #set heading(outlined: false, supplement: none, numbering: none)

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
  = Acronyms
  #show-acronyms
  #pagebreak()
  = Glossary
  #show-glossary
  #pagebreak()
]

#counter(page).update(1)
#set heading(supplement: [Chapter], numbering: "1.1") // Change to [Capítulo] for Portuguese

= Introduction

Context, motivation, main aims.

= State of the Art
State of the art review; related work.

== Citations

Example of a citation: @rustbook or #cite(<rustbook>, form: "full"). This entry is in the `bibliography.yml` file.

@typst also supports the @latex `.bib` file format, #link("https://www.bibtex.org/Format/")[BibTeX], but the #link("https://github.com/typst/hayagriva/blob/main/docs/file-format.md")[Hayagriva YAML format] is easier to use.

Check more information about bibliography #link("https://typst.app/docs/reference/model/bibliography/")[here] and #link("https://typst.app/docs/reference/model/cite/")[here].

== Mathematical expressions

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

== Footnotes

This is a footnote example #footnote[The quick brown fox jumps over the lazy dog.].

== Acronyms and Glossary

Given a set of numbers, there are elementary methods to compute its @gcd:long, which is abbreviated @gcd:short. This process is similar to that used for the @lcm.

The @typst language is specially suitable for documents that include @maths:long. @formula:pl are rendered properly as the Typst syntax is designed to be easy to understand and use.

This glossary is powered by the #link("https://typst.app/universe/package/glossarium/")[glossarium] package. Check more about it there.

== Index

In this example, several keywords #index[keywords] will be used which are important and deserve to appear in the Index#index[Index].

Terms like generate #index[generate] and some #index[others] will also show up. Terms in the index can also be nested#index([Index], [nested]).

The index is powered by the #link("https://typst.app/universe/package/in-dexter/")[in-dexter] package. Check more about it there.

= The problem and its challenges

The problem and its challenges.

== Images

Example of inserting an image as displayed text,

#align(center, image("logos/uminho/color/UM.jpg", width: 10%))

or as a figure:

#figure(
  image("logos/uminho/color/UM.jpg", width: 30%),
  caption: [Logo of the University of Minho],
) <uminhologo>

You can also reference figures like @uminhologo.

= Contribution

Main result(s) and their scientific evidence

== Introduction

== Summary

= Applications

Applications of the main result (examples and case studies)

== Introduction

== Summary

= Conclusions and future work

Conclusions and future work

== Conclusions

== Future work

= Planned Schedule

== Activities

#let filled = $circle.filled.small$

#figure(
  table(
    columns: 11,
    [Task], [Oct], [Nov], [Dec], [Jan], [Feb], [Mar], [Apr], [May], [Jun], [Jul],
    [Background and @soa:short], filled, filled, filled, [], [], [], [], [], [], [],
    [@pdr:short preparation], [], filled, filled, filled, [], [], [], [], [], [],
    [Contribution], [], [], ..(filled,) * 7, [],
    [Writing up], [], [], [], [], [], [], ..(filled,) * 4,
  ),
  caption: [Planned Schedule],
)

For more elegant visualisation check some community-made packages like #link("https://typst.app/universe/package/gantty/")[gantty] or #link("https://typst.app/universe/package/timeliney/")[timeliney].

#[
  #set heading(numbering: none)

  // Render bibliography
  // Change this to a .bib file if you prefer that format instead
  #bibliography("bibliography.yml", full: true)

  // Render index
  #set heading(outlined: false)
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

#[
  #counter(heading).update(0)
  #set heading(numbering: "A.1", supplement: [Appendix]) // Change to [Apêndice] for Portuguese

  #include "appendix.typ"
]

#set page(numbering: none)

#page(fill: colors.pantonecoolgray7)[]

#align(
  horizon,
)[Place here information about funding, FCT project, etc. in which the work is framed. Leave empty otherwise.]
