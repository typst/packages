#import "@preview/classic-thesis-uct:0.1.0": *
#import "chapters/chapter01.typ": content as chapter01
#import "chapters/chapter02.typ": content as chapter02
#import "chapters/chapter03.typ": content as chapter03
#import "chapters/chapter04.typ": content as chapter04
#import "chapters/chapter05.typ": content as chapter05
#import "chapters/chapter06.typ": content as chapter06
#import "chapters/chapter07.typ": content as chapter07

#let custom-logo = none
// Example override:
// #let custom-logo = image("graphics/my-logo.png", width: 43mm)

#let meta = (
  title: "UCT Classic Thesis Template",
  logo: custom-logo,
  degree: "Doctor of Philosophy",
  name: "Candidate Name",
  supervisor: "Primary Supervisor",
  co-supervisor: "Co-supervisor or Second Supervisor",
  faculty: "Faculty or School",
  department: "Department or Research Unit",
  university: "University Name",
  location: "City, Country",
  date: "19 April, 2026",
  funder: "Funding body or 'N/A'",
)

#show: configure.with(meta)
#show pagebreak.where(to: "odd"): set page(header: none, footer: none)
#show pagebreak.where(to: "even"): set page(header: none, footer: none)
#set heading(numbering: "1.1")
#set cite(form: "normal")
#set bibliography(style: "ieee", title: none)
#show footnote.entry: set text(size: 8.5pt)
#show link: set text(fill: accent)
#show heading.where(level: 2): it => [
  #block(above: 1.65em, below: 1.45em)[
    #spaced-caps([
      #counter(heading).display(it.numbering)
      #h(0.85em)
      #it.body
    ], size: 9.5pt)
  ]
  #block(spacing: 0pt)[]
]
#show heading.where(level: 3): it => [
  #block(above: 1.65em, below: 1.45em)[
    #text(font: display-font, style: "italic", size: 9.5pt, tracking: 0.01em)[
      #smallcaps([
      #counter(heading).display(it.numbering)
      #h(0.85em)
      #it.body
      ])
    ]
  ]
  #block(spacing: 0pt)[]
]
#show heading.where(level: 4): it => [
  #block(above: 1.65em, below: 1.45em)[
    #pad(left: 1.6em)[
      #text(font: display-font, style: "italic", size: 9.5pt, tracking: 0.01em)[
        #smallcaps([
          #counter(heading).display(it.numbering)
          #h(0.85em)
          #it.body
        ])
      ]
    ]
  ]
  #block(spacing: 0pt)[]
]

// Front matter (title page through Acronyms) uses a single column the same
// width as the major column but centred on the page, with no running header.
// The page number stays at the bottom but is true-centred (shift: 0mm)
// because the content area is no longer offset.
#set page(
  margin: (
    inside: front-matter-side-margin,
    outside: front-matter-side-margin,
    top: page-top-margin,
    bottom: page-bottom-margin,
  ),
  header: none,
  footer: folio-footer("i", shift: 0mm),
)

#title-page(meta)
#title-back(meta)

#abstract-page[
Replace this abstract with a concise overview of the proposal. A useful structure is:

- the research problem and why it matters;
- the gap in the current literature or practice;
- the proposed approach;
- the expected contribution and impact.
]

#contents-page()
#list-of-figures-page()
#list-of-tables-page()

#acronym-page((
  ([AI], [Artificial Intelligence]),
  ([HCI], [Human-Computer Interaction]),
  ([ML], [Machine Learning]),
  ([NLP], [Natural Language Processing]),
  ([PhD], [Doctor of Philosophy]),
))

#metadata(none)<end-front-matter>
#context if calc.odd(locate(<end-front-matter>).page()) {
  page(footer: none, numbering: none)[]
}
// Switch back to the mirrored two-side layout for the main matter:
// asymmetric inside/outside margins and the running chapter-title header.
#set page(
  margin: (
    inside: inner-margin,
    outside: outer-margin,
    top: page-top-margin,
    bottom: page-bottom-margin,
  ),
  header: classic-header(),
  footer: folio-footer("1"),
)
#counter(page).update(1)

// Keep chapter openings custom for the classic thesis layout.
// Use normal Typst `==` headings inside each imported chapter file.
#pagebreak(to: "odd")
#chapter("Introduction", "1")[#chapter01]
#pagebreak(to: "odd")
#chapter("Background and Literature Review", "2")[#chapter02]
#pagebreak(to: "odd")
#chapter("Research Questions and Objectives", "3")[#chapter03]
#pagebreak(to: "odd")
#chapter("Methodology", "4")[#chapter04]
#pagebreak(to: "odd")
#chapter("Resources and Feasibility", "5")[#chapter05]
#pagebreak(to: "odd")
#chapter("Project Timeline", "6")[#chapter06]
#pagebreak(to: "odd")
#chapter("Conclusion", "7")[#chapter07]

#bibliography-page(bibliography("references.bib"))
