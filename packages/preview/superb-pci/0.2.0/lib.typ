#import "formatters.typ": *

// Workaround for the lack of a `std` scope.
#let std-bibliography = bibliography

#let pci(
  title: [Paper Title],
  authors: (),
  affiliations: (),
  abstract: none,
  doi: none,
  keywords: (),
  correspondence: none,
  numbered_sections: false,
  bibliography: none,
  pcj: false, // removes all unecessary bits
  line_numbers: false,
  doc,
) = {

  // housekeeping to allow use in quarto
  show regex("\\\\"): it => ""
  let sanitize_orcid(author) = {
    if author.at("orcid", default: none) != none {
      author.at("orcid") = author.at("orcid").replace("\\", "")
    }
    return author
  }
  if correspondence != none {correspondence = correspondence.replace("\\", "")}
  if doi != none {doi = doi.replace("\\", "")}
  authors = authors.map(sanitize_orcid)

  // color definitions
  let PCIdark = rgb("#346E92")
  let PCImedium = rgb("#77A4BF")
  let PCIlight = rgb("#9FBFD2")

  // document metadata
  set document(
    title: title,
    author: authors.map(author => author.name),
  )
  // global configuration
  set page(
    paper: "a4",
    margin: 1in,
    // numbering: if pcj {none} else {"1 / 1"},
    header: if pcj {none} else {generate_header(authors, fill: PCIdark)},
    footer: if pcj {none} else {generate_footer(fill: PCIdark)},
    header-ascent: 13pt,
    footer-descent: .55em,
  )
  set text(
    font: ("Lato"),
    fallback: true,
    size: 11pt,
    lang: "en",
    region: "US",
    hyphenate: true,
  )
  let line_spacing = 0.55em * 1.5
  set par(
    first-line-indent: 1.5em,
    justify: true,
    leading: line_spacing, // 0.65 * 1.5 for onehalfspacing
  )
  set par.line(numbering: if line_numbers {n => text(0.7em)[#n]} else {none})
  set block(spacing: line_spacing)
  show link: set text(fill: PCIdark)
  show ref: set text(fill: PCIdark)
  set enum(indent: 2em, numbering: "(1.a)")
  set list(indent: 2em)
  set math.equation(
    numbering: "(1)",
    number-align: top+left,
    supplement: [Eq.],
  )
  // make sure Fira Math is installed on your system
  show math.equation: set text(font: ("Fira Math", "New Computer Modern Math"))

  // Headings
  set heading(
    numbering: if numbered_sections {"1."} else {none},
  )
  show heading.where(level: 1): it => [
    #set align(center)
    #set text(size: 12pt, weight: "bold")
    #block(above: 2em, below: 1em)[
      #if it.numbering != none [#counter(heading).display()#h(.5em)]#it.body
    ]
  ]
  show heading.where(level: 2): it => [
    #set text(weight: "bold", size: 11pt)
    #block(above: 1.6em, below: 1em)[
      #if it.numbering != none [#counter(heading).display()#h(.5em)]#it.body
    ]
  ]
  show heading.where(level: 3): it => [
    #set text(style: "italic", size: 11pt)
    #v(1.6em)
    #if it.numbering != none [#counter(heading).display()#h(.5em)]#it.body.#h(.5em)
  ]


  // Figure and Table settings
  let caption_width = 21cm - 2in - 3cm // 21 - 5.08 - 3 for total margins
  show figure: set block(width: 100%, spacing: 1.6em)
  show figure.caption: it => context [
    #block(width: caption_width)[
      #set align(left)
      #set text(9pt)
      *#it.supplement #it.counter.display(it.numbering)* -- #it.body
    ]
  ]

  set table(stroke: none)
  show figure.where(
    kind: table
  ): set figure.caption(position: top)


  // =========================
  // Document

  // Frontpage
  if not pcj {
    set par(first-line-indent: 0pt)
    set block(spacing: 20pt)
    v(2cm)
    block()[
      #text(size: 25pt, weight: "bold")[#title]
    ]

    display_authors(authors)

    display_affiliations(affiliations)

    if doi != none {
      block()[
        #link(doi)[#doi]
      ]
    }

    display_abstract(abstract)

    if keywords.len() > 0 {
      block()[*Keywords:* #keywords.join(", ")]
    }

    if correspondence != none {
      block()[
        *Correspondence:*
        #link("mailto:" + correspondence)[#correspondence]
      ]
    }
    pagebreak()
  }

  doc

  // bibliography settings
  if bibliography != none {
    show std-bibliography: set par(first-line-indent: 0pt)
    set std-bibliography(title: "References", style: "pci.csl")
    bibliography
  }
}
