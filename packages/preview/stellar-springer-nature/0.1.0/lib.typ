// stellar-springer-nature: A Springer Nature journal article template for Typst.
// Matches the sn-jnl LaTeX class (submission format, Version 3.1 December 2024).

/// A backmatter heading, equivalent to LaTeX `\bmhead{}`.
/// Use for Acknowledgements, Supplementary information, etc.
///
/// - title (content): The heading title.
/// -> content
#let bmhead(title) = {
  v(1.2em)
  block(text(weight: "bold", size: 11pt, title))
  v(0.4em)
}

/// The main article template function. Apply via a show rule:
/// ```typ
/// #show: article.with(title: [...], authors: (...), ...)
/// ```
///
/// - title (content): The article title.
/// - short-title (content): Short title for running page headers (optional).
/// - authors (array): Array of author dictionaries with keys:
///   `name` (str), `affiliations` (array of int), `email` (str, optional),
///   `corresponding` (bool, optional), `equal-contrib` (str, optional),
///   `orcid` (str, optional).
/// - affiliations (array): Array of affiliation dictionaries with keys:
///   `id` (int), `department` (str, optional), `institution` (str),
///   `address` (str, optional).
/// - abstract (content): The article abstract.
/// - keywords (array): Array of keyword strings.
/// - pacs (content): PACS classification codes (optional).
/// - msc (content): MSC classification codes (optional).
/// - body (content): The document body.
/// -> content
#let article(
  title: none,
  short-title: none,
  authors: (),
  affiliations: (),
  abstract: none,
  keywords: (),
  pacs: none,
  msc: none,
  body,
) = {

  // --- PDF metadata ---
  set document(
    title: if title != none { title } else { [] },
    author: authors.map(a => a.name),
    keywords: keywords,
  )

  // --- Page setup (single-column, matching sn-jnl class) ---
  set page(
    paper: "a4",
    margin: (
      top: 25mm,
      bottom: 25mm,
      left: 25mm,
      right: 25mm,
    ),
    numbering: "1",
    number-align: center + bottom,
    header: context {
      let page-num = counter(page).get().first()
      if page-num > 1 {
        set text(size: 8pt)
        let header-title = if short-title != none { short-title } else { title }
        emph(header-title)
      }
    },
  )

  // --- Base typography ---
  set text(
    font: "New Computer Modern",
    size: 10pt,
    lang: "en",
  )
  set par(justify: true, leading: 0.65em, first-line-indent: 1.5em)

  // --- Heading styles (standard numbered: 1, 1.1, 1.1.1) ---
  set heading(numbering: "1.1.1")

  show heading.where(level: 1): it => {
    set text(size: 12pt, weight: "bold")
    set par(first-line-indent: 0pt)
    v(1.2em)
    block[#counter(heading).display("1") #it.body]
    v(0.6em)
  }

  show heading.where(level: 2): it => {
    set text(size: 11pt, weight: "bold")
    set par(first-line-indent: 0pt)
    v(1em)
    block[#counter(heading).display("1.1") #it.body]
    v(0.4em)
  }

  show heading.where(level: 3): it => {
    set text(size: 10pt, weight: "bold")
    set par(first-line-indent: 0pt)
    v(0.8em)
    block[#counter(heading).display("1.1.1") #it.body]
    v(0.3em)
  }

  // Unnumbered headings (for Declarations, etc.)
  show heading.where(numbering: none, level: 1): it => {
    set text(size: 12pt, weight: "bold")
    set par(first-line-indent: 0pt)
    v(1.2em)
    block[#it.body]
    v(0.6em)
  }

  // --- Figure/table captions ---
  show figure.where(kind: image): set figure(supplement: [Fig.])
  show figure.where(kind: table): set figure(supplement: [Table])
  show figure.caption: it => {
    set text(size: 9pt)
    set par(first-line-indent: 0pt)
    [*#it.supplement #it.counter.display()* #h(0.5em) #it.body]
  }

  // --- Table styling (booktabs-style: top/bottom rules, no vertical) ---
  set table(
    stroke: none,
    inset: (x: 6pt, y: 4pt),
  )

  // --- Equations ---
  set math.equation(numbering: "(1)")

  // ========================================
  // TITLE BLOCK
  // ========================================
  {
    set par(first-line-indent: 0pt)

    // Title
    align(center, {
      text(size: 17pt, weight: "bold", title)
    })
    v(16pt)

    // Authors
    if authors.len() > 0 {
      set text(size: 12pt)
      let author-parts = authors.map(a => {
        let name = text(weight: "bold", a.name)
        let sups = a.affiliations.map(n => str(n)).join(",")
        let result = [#name#super(sups)]
        if a.at("corresponding", default: false) {
          result = [#result#super("*")]
        }
        result
      })
      align(center, author-parts.join[ #h(0.3em) #sym.dot.c #h(0.3em) ])
    }
    v(12pt)

    // Equal contribution note
    {
      let equal = authors.filter(a => a.at("equal-contrib", default: none) != none)
      if equal.len() > 0 {
        set text(size: 9pt, style: "italic")
        align(center, equal.first().at("equal-contrib"))
        v(6pt)
      }
    }

    // Affiliations
    if affiliations.len() > 0 {
      set text(size: 9pt)
      for aff in affiliations {
        let parts = ()
        if aff.at("department", default: none) != none { parts.push(aff.department) }
        parts.push(aff.institution)
        if aff.at("address", default: none) != none { parts.push(aff.address) }
        align(center)[
          #super(str(aff.id))#parts.join(", ")
        ]
      }
    }
    v(8pt)

    // Corresponding author email
    {
      let corresponding = authors.filter(a =>
        a.at("corresponding", default: false) and a.at("email", default: none) != none
      )
      if corresponding.len() > 0 {
        set text(size: 9pt)
        let c = corresponding.first()
        align(center)[
          #super("*")Corresponding author: #link("mailto:" + c.email, c.email)
        ]
      }
    }
    v(16pt)

    // Abstract
    if abstract != none {
      set text(size: 10pt)
      pad(left: 15pt, right: 15pt, {
        text(weight: "bold")[Abstract ]
        abstract
      })
      v(10pt)
    }

    // Keywords
    if keywords.len() > 0 {
      set text(size: 9pt)
      pad(left: 15pt, right: 15pt, {
        text(weight: "bold")[Keywords: ]
        keywords.join[ #sym.dot.c ]
      })
    }
    v(6pt)

    // PACS / MSC classification
    if pacs != none {
      set text(size: 9pt)
      pad(left: 15pt, right: 15pt, {
        text(weight: "bold")[PACS: ]
        pacs
      })
      v(4pt)
    }
    if msc != none {
      set text(size: 9pt)
      pad(left: 15pt, right: 15pt, {
        text(weight: "bold")[MSC: ]
        msc
      })
      v(4pt)
    }

    line(length: 100%, stroke: 0.5pt)
    v(8pt)
  }

  // ========================================
  // BODY
  // ========================================
  body
}
