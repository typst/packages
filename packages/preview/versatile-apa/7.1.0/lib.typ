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
  course: [],
  instructor: [],
  due-date: [],
  // Professional-specific fields
  running-head: [],
  author-notes: [],
  keywords: (),
  abstract: [],
  // Common fields
  font-family: "Libertinus Serif",
  font-size: 12pt,
  region: "us",
  language: "en",
  paper-size: "us-letter",
  implicit-introduction-heading: true,
  abstract-as-description: true,
  body,
) = {
  let double-spacing = 1.5em
  let first-indent-length = 0.5in

  authors = validate-inputs(authors, custom-authors, "author")
  affiliations = validate-inputs(affiliations, custom-affiliations, "affiliation")

  set document(
    title: title,
    author: if type(authors) == array {
      authors.map(it => to-string(it.name))
    } else {
      to-string(authors).trim(" ", at: start).trim(" ", at: end)
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

  set page(
    margin: 1in,
    paper: paper-size,
    numbering: "1",
    number-align: top + right,
    header: context {
      upper(running-head)
      h(1fr)
      str(here().page())
    },
  )

  set par(
    leading: double-spacing,
    spacing: double-spacing,
  )

  show link: set text(fill: blue)

  show link: it => {
    underline(it.body)
  }

  if running-head != none and running-head != [] and running-head != "" {
    if to-string(running-head).len() > 50 {
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

    #if type(course) == content and course != [] {
      course
    } else if type(course) != content {
      panic("Course must be of type content: ", type(course))
    }

    #if type(instructor) == content and instructor != [] {
      instructor
    } else if type(instructor) != content {
      panic("Instructor must be of type content: ", type(instructor))
    }

    #if ((type(due-date) == content and due-date != []) or (type(due-date) == str and due-date != "")) {
      due-date
    } else if type(due-date) != content {
      panic("Due date must be of type content or string: ", type(due-date))
    }

    #if author-notes != [] and author-notes != none {
      v(1fr)

      strong(get-terms(language).at("Author Note"))

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
  show heading.where(level: 2): it => par(
    first-line-indent: 0in,
    strong(it.body),
  )

  show heading.where(level: 3): it => par(
    first-line-indent: 0in,
    emph(strong(it.body)),
  )

  show heading.where(level: 4): it => strong[#it.body.]
  show heading.where(level: 5): it => emph(strong[#it.body.])

  set par(
    first-line-indent: first-indent-length,
    leading: double-spacing,
  )

  show figure: set figure.caption(position: top)

  show table.cell: set par(leading: 1em)

  show figure: set block(breakable: true)

  show figure: it => {
    it.caption
    align(center, it.body)
  }

  set figure(
    gap: double-spacing,
    placement: none,
  )

  show figure.caption: it => {
    set par(first-line-indent: 0in)
    align(left)[
      *#it.supplement #context it.counter.display(it.numbering)*

      #emph(it.body)
    ]
  }

  set table(stroke: none)

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

  set math.equation(numbering: "(1)")

  show figure.where(kind: raw): it => {
    set align(left)
    it.caption
    it.body
  }

  show quote: set pad(left: 0.5in)
  show quote: set block(spacing: 1.5em)

  show quote: it => {
    let quote-text = to-string(it.body)
    let quote-text-words = to-string(it.body).split(" ").len()

    if quote-text-words <= 40 {
      set quote(block: false)
      [
        "#quote-text.trim(" ")"~#it.attribution.
      ]
    } else {
      set quote(block: true)
      set par(hanging-indent: 0.5in)
      [
        #quote-text.trim(" ")~#it.attribution
      ]
    }
  }

  set bibliography(style: "apa")
  show bibliography: set par(first-line-indent: 0in)

  if ((type(abstract) == content or type(abstract) == str) and (abstract != [] and abstract != "")) {
    heading(level: 1, get-terms(language).Abstract, outlined: false)

    par(first-line-indent: 0in)[
      #abstract
    ]

    emph(get-terms(language).Keywords)
    [: ]
    keywords.map(it => it).join(", ")

    pagebreak()
  } else {
    panic(
      "Invalid abstract, abstract must be content or string, and not be empty. Type is " + type(abstract),
      "Abstract input is: " + abstract,
    )
  }

  if implicit-introduction-heading {
    heading(level: 1, title)
  }

  body
}
