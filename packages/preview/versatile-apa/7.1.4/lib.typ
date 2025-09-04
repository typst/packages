#import "utils/to-string.typ": *
#import "utils/languages.typ": *
#import "utils/authoring.typ": *
#import "utils/orcid.typ": *
#import "utils/appendix.typ": *
#import "utils/apa-figure.typ": *

/// The APA 7th edition template for academic and professional documents.
///
/// - title (content): The title of your document.
/// - authors (dictionary): The authors of the document.
///   - For each author you must specify their name and their affiliations.
/// - affiliations (dictionary): The affiliations of the authors.
///   - For each affiliation you must specify its ID and its name.
/// - custom-authors (content): The custom authors of the document.
///   - You can manually specify the authors of the document.
/// - custom-affiliations (content): The custom affiliations of the document.
///   - You can manually specify the affiliations of the document.
/// - course (content): The academic course for the document.
/// - instructor (content): The instructor for the document.
/// - due-date (content): The due date for the document.
/// - running-head (content): The running head for the document.
/// - author-notes (): The author notes for the document.
/// - keywords (array | str): The keywords for the document metadata and abstract.
/// - abstract (content): The abstract of the document.
/// - journal (bool): Whether to use journal format.
/// - font-family (): The font family for the document. APA 7th edition recommended fonts are:
///   - Sans Serif fonts such as 11-point Calibri, 11-point Arial, or 10-point Lucida Sans Unicode
///   - Serif fonts such as 12-point Times New Roman, 11-point Georgia, or   10-point Computer Modern (LaTeX)
/// - font-size (length): The font size for the document.
///   - APA 7th edition recommends a 10-12 point font size.
/// - region (str): The region for the document (e.g., "us", "uk", "au").
/// - language (str): The language for the document (e.g., "en", "es", "fr").
/// - paper-size (str): The paper size for the document (e.g., "us-letter", "a4").
/// - implicit-introduction-heading (bool): Wether to include the paper title at the top of the first page of the text, which acts as a de facto Level 1 heading.
/// - abstract-as-description (bool): Whether to use the abstract as the document description.
/// - body (content): The body of the document.
/// -> content
#let versatile-apa(
  title: [Paper Title],
  // Authoring fields
  authors: (:),
  affiliations: (:),
  custom-authors: [],
  custom-affiliations: [],
  // Student-specific fields
  course: none,
  instructor: none,
  due-date: none,
  // Professional-specific fields
  running-head: none,
  author-notes: none,
  keywords: (),
  abstract: none,
  // Common fields
  font-family: "Libertinus Serif",
  font-size: 12pt,
  region: "us",
  language: "en",
  custom-terms: (:),
  paper-size: "us-letter",
  implicit-introduction-heading: true,
  abstract-as-description: true,
  body,
) = {
  let double-spacing = 1.5em
  let first-indent-length = 0.5in

  context language-terms.update(custom-terms)
  authors = validate-inputs(authors, custom-authors, "author")
  affiliations = validate-inputs(affiliations, custom-affiliations, "affiliation")

  set document(
    title: title,
    author: if type(authors) == array {
      authors.map(it => to-string(it.name))
    } else {
      to-string(authors).trim()
    },
    description: if abstract-as-description { abstract },
    keywords: keywords,
  )

  set text(
    size: font-size,
    font: font-family,
    region: region,
    lang: language,
  )

  set page(margin: 1in, paper: paper-size, numbering: "1", number-align: top + right, header: context {
    upper(running-head)
    h(1fr)
    str(here().page())
  })

  set par(
    leading: double-spacing,
    spacing: double-spacing,
  )

  show link: it => {
    if type(it.dest) == str {
      set text(fill: blue)
      underline(it)
    } else { it }
  }

  if running-head != none {
    if type(running-head) == content { running-head = to-string(running-head) }
    if running-head.len() > 50 {
      panic("Running head must be no more than 50 characters, including spaces and punctuation.")
    }
  }

  align(center)[
    #for i in range(4) {
      [~] + parbreak()
    }

    #strong(title)

    ~

    #parbreak()

    #print-authors(authors, affiliations, language)

    #print-affiliations(authors, affiliations)

    #course

    #instructor

    #due-date

    #if author-notes != none {
      v(1fr)

      strong(context get-terms(language).at("Author Note"))

      align(left)[
        #set par(first-line-indent: first-indent-length)
        #author-notes
      ]
    }

    #pagebreak()
  ]

  show heading: set text(size: font-size)
  show heading: set block(spacing: double-spacing)

  show heading: it => emph(strong[#it.body.])
  show heading.where(level: 1): it => align(center, strong(it.body))
  show heading.where(level: 2): it => par(first-line-indent: 0in, strong(it.body))

  show heading.where(level: 3): it => par(first-line-indent: 0in, emph(strong(it.body)))

  show heading.where(level: 4): it => strong[#it.body.]
  show heading.where(level: 5): it => emph(strong[#it.body.])

  set par(
    first-line-indent: (
      amount: first-indent-length,
      all: true,
    ),
    leading: double-spacing,
  )

  show table.cell: set par(leading: 1em)

  show figure: set block(breakable: true, sticky: false)

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
    font: "Cascadia Code",
    size: 10pt,
  )

  show raw.where(block: true): set par(leading: 1em)
  show figure.where(kind: raw): set block(breakable: true, sticky: false, width: 100%)

  set math.equation(numbering: "(1)")

  show quote.where(block: true): set block(spacing: double-spacing)

  show quote: it => {
    let quote-text-words = to-string(it.body).split(regex("\\s+")).filter(word => word != "").len()

    if quote-text-words < 40 {
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

  show outline.entry: it => {
    if (
      (
        it.element.supplement == [#context get-terms(language).Appendix]
          or it.element.supplement == [#context get-terms(language).Annex]
          or it.element.supplement == [#context get-terms(language).Addendum]
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

  set bibliography(style: "apa")
  show bibliography: set par(
    first-line-indent: 0in,
    hanging-indent: 0.5in,
  )

  show bibliography: bib-it => {
    set block(inset: 0in)
    show block: block-it => context {
      if block-it.body.func() != [].func() {
        block-it.body
      } else {
        par(block-it.body)
      }
    }

    bib-it
  }


  if (abstract != none) {
    // Only display the abstract if it's not empty
    if (abstract != [] and abstract != "") {
      heading(level: 1, context get-terms(language).Abstract, outlined: false)

      par(first-line-indent: 0in)[
        #abstract
      ]

      emph[#context get-terms(language).Keywords: ]
      keywords.map(it => it).join(", ")

      pagebreak()
    }
  }

  if implicit-introduction-heading {
    heading(level: 1, title)
  }

  body
}
