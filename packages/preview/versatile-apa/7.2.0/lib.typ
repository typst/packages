#import "utils/to-string.typ": to-string
#import "utils/languages.typ": get-terms, language-terms
#import "utils/authoring.typ": print-affiliations, print-authors
#import "utils/appendix.typ": appendix, appendix-outline
#import "utils/apa-figure.typ": apa-figure
#import "utils/abstract.typ": abstract-page
#import "utils/title.typ": title-page
#import "utils/constants.typ": double-spacing, first-indent-length, quote-word-trigger


/// The APA 7th edition template for academic and professional documents.
#let versatile-apa(
  font-size: 12pt,
  custom-terms: (:),
  running-head: none,
  running-head-limit: 50,
  body,
) = {
  context language-terms.update(custom-terms)

  set text(
    size: font-size,
  )

  show std.title: set text(size: font-size, weight: "bold")
  show std.title: set block(spacing: double-spacing)
  show std.title: set align(center)

  set page(
    paper: "us-letter",
    numbering: "1",
    number-align: top + right,
    margin: 1in,
    header: if running-head != none {
      grid(
        columns: (1fr, auto),
        upper(running-head), context here().page(),
      )
    } else { auto },
  )

  set par(
    leading: double-spacing,
    spacing: double-spacing,
  )

  // Show-set rules are at least, easier to override compared to show-function
  // https://github.com/typst/typst/discussions/2883
  show link: set text(fill: blue)
  show link: underline // considering one would want to disable underline, current workaround is set its stroke to 0pt

  if running-head != none {
    if type(running-head) == content { running-head = to-string(running-head) }
    if running-head.len() > running-head-limit {
      panic(
        "Running head must be no more than",
        running-head-limit,
        "characters, including spaces and punctuation.",
        "Current length:",
        running-head.len(),
      )
    }
  }

  show heading: set text(size: font-size)
  show heading: set block(spacing: double-spacing)

  show heading.where(level: 1): set align(center)
  show heading.where(level: 3).or(heading.where(level: 5)): set text(style: "italic")
  show heading.where(level: 4).or(heading.where(level: 5)): it => [#it.body.]

  set par(
    first-line-indent: (
      amount: first-indent-length,
      all: true,
    ),
    leading: double-spacing,
  )

  show table.cell: set par(leading: 1em)

  show figure.where(kind: image): set block(breakable: true, sticky: true)
  show figure.where(kind: table): set block(breakable: true, sticky: false)

  set figure(
    gap: double-spacing,
    placement: auto,
  )

  set figure.caption(separator: parbreak(), position: top)
  show figure.caption: set align(left)
  show figure.caption: set par(first-line-indent: 0em)
  show figure.caption: it => {
    strong[#it.supplement #context it.counter.display(it.numbering)]
    it.separator
    emph(it.body)
  }

  set table(stroke: (x, y) => if y == 0 {
    (
      top: (thickness: 1pt, dash: "solid"),
      bottom: (thickness: 0.5pt, dash: "solid"),
    )
  })

  set list(
    marker: ([•], [◦]),
    indent: 0.5in - 1.75em,
    body-indent: 1.3em,
  )

  set enum(
    indent: 0.5in - 1.5em,
    body-indent: 0.75em,
  )

  set raw(
    tab-size: 4,
    block: true,
  )

  show raw.where(block: true): block.with(
    fill: luma(250),
    stroke: (left: 3pt + rgb("#6272a4")),
    inset: (x: 10pt, y: 8pt),
    width: auto,
    breakable: true,
    outset: (y: 7pt),
    radius: (left: 0pt, right: 6pt),
  )

  show raw: set text(
    size: 10pt,
  )

  show raw.where(block: true): set par(leading: 1em)
  show figure.where(kind: raw): set block(breakable: true, sticky: false, width: 100%)

  set math.equation(numbering: "(1)")

  show quote.where(block: true): set block(spacing: double-spacing)

  show quote: it => context {
    let quote-text-words = to-string(it.body).split(regex("\\s+")).filter(word => word != "").len()

    // https://apastyle.apa.org/style-grammar-guidelines/citations/quotations
    if quote-text-words < quote-word-trigger.get() {
      ["#it.body" ]

      if (type(it.attribution) == label) {
        cite(it.attribution)
      } else if (
        type(it.attribution) == str or type(it.attribution) == content
      ) {
        it.attribution
      }
    } else {
      block(inset: (left: 0.5in))[
        #set par(first-line-indent: 0.5in)
        #it.body
        #if (type(it.attribution) == label) {
          cite(it.attribution)
        } else if (type(it.attribution) == str or type(it.attribution) == content) {
          it.attribution
        }
      ]
    }
  }

  show outline.entry: it => context {
    if (
      (
        it.element.supplement == [#context get-terms(text.lang, text.script).Appendix]
      )
        and it.element.has("level")
        and it.element.level == 1
    ) {
      link(it.element.location(), it.indented([#it.element.supplement #it.prefix().], it.inner()))
    } else {
      it
    }
  }

  set outline(depth: 3, indent: 2em)

  set bibliography(style: "assets/styles/apa.csl")
  show bibliography: set par(
    first-line-indent: 0in,
    hanging-indent: 0.5in,
  )

  show bibliography: bib-it => {
    show block: block-it => context {
      // if it body is auto or styled()
      if block-it.body == auto or block-it.body.func() == text(fill: red)[].func() {
        block-it
        // if its body isn't sequence(), for example: pdf-marker-tag
      } else if block-it.body.func() != [].func() {
        par(block-it.body)
      } else {
        par(block-it.body)
      }
    }

    bib-it
  }

  body
}
