#import "/lib/import.typ": *
#import "/lib/common.typ": *
#import "@preview/transl:0.2.0": transl
#import "@preview/decasify:0.11.3": *


#let base-project(
  type: "",
  language: "de",
  sans-font: "Noto Sans",
  serif-font: "Times New Roman",
  title: "",
  authors: (),
  keywords: (),
  description: "",
  study-group: "",
  module: "",
  contact-details: "",
  academic-reviewer: "",
  company-reviewer: "",
  submission-date: "",
  header-logo: none,
  university-logo: none,
  company-logo: none,
  show-list-of-figures: false,
  show-list-of-tables: false,
  show-list-of-code: false,
  acronyms: (:),
  appendix: none,
  glossary: (:),
  bibliography: none,
  restriction-notice: none,
  foreword: none,
  gendering-note: none,
  title-page,
  body,
) = {
  transl(data: yaml("/translations.yml"))
  set document(
    author: authors.map(a => a.name).join(", "),
    title: title,
    keywords: keywords,
    description: description,
  )
  set text(size: 12pt)
  set par(leading: 1.5em)

  set page(
    margin: (
      left: 25mm,
      right: 25mm,
      top: 25mm,
      bottom: 25mm,
    ),
    numbering: none,
    number-align: end,
  )
  set cite(style: "american-psychological-association", form: "prose")
  set par(justify: true, linebreaks: "optimized")

  set linebreak(justify: false)
  set text(
    font: sans-font,
    lang: language,
    hyphenate: false,
  )
  set figure(
    gap: 2em,
  )
  show table: set par(justify: false)
  show footnote.entry: set text(size: 10pt)
  show footnote.entry: set footnote.entry(gap: 1em)
  show figure.caption: set text(size: 10pt)
  show figure.caption: set par(leading: 1em)
  show math.equation: set text(weight: 400)
  show heading: set text(size: 12pt, weight: "bold")
  show heading.where(level: 1): set text(size: 14pt, weight: "bold")
  show heading.where(level: 1): it => {
    if it.outlined and it.numbering == none {
      it
    } else {
      it + linebreak()
    }
  }
  show heading.where(level: 2).or(heading.where(level: 3)): it => {
    linebreak() + it + linebreak()
  }
  show heading.where(level: 4): it => {
    linebreak() + text(it.body, weight: "bold") + linebreak()
  }

  set heading(bookmarked: true)
  show figure: it => {
    linebreak() + it + linebreak()
  }

  show figure.where(kind: image): it => {
    set text(size: 10pt)
    pad(
      it.gap,
      [#pad(it.gap, it.body) #transl("FigAcr") #context it.counter.display(it.numbering): #it.caption.body],
    )
  }

  init-acronyms(acronyms)
  init-glossary(glossary)
  set heading(numbering: "1.1")

  set text(
    font: sans-font,
    lang: language,
    hyphenate: false,
  )

  title-page
  
  set text(
    font: serif-font,
    lang: language,
    hyphenate: false,
  )


  if restriction-notice == true {
    pagebreak()
    heading(outlined: false, numbering: none, text(smallcaps(
      transl("titleRestrictionNotice"),
    )))
    sperrvermerkText
    v(1.618fr)
  }

  if gendering-note == true {
    pagebreak()
    heading(outlined: false, numbering: none, text(
      smallcaps(transl("titleGenderingNote")),
    ))
    genderhinweisText
    v(1.618fr)
  }

  if foreword == true {
    pagebreak()
    v(1fr)
    heading(outlined: false, numbering: none, text(
      smallcaps(transl("titleForeword")),
    ))
    vorwortText
    v(1.618fr)
  }

  set page(numbering: "I")
  counter(page).update(1)

  // Table of contents.
  pagebreak(weak: true)
  outline(
    depth: 3,
    indent: auto,
    title: transl("Toc"),
    target: heading
      .where(depth: 1)
      .or(heading.where(depth: 2))
      .or(heading.where(depth: 3))
      .or(heading.where(depth: 4))
      .and(heading.where(outlined: true)),
  )

  let pagecounter = 0

  if (show-list-of-figures) {
    show outline.entry: it => {
      let new_prefix = transl("FigAcr") + " " + it.prefix().children.at(2)
      it.indented(new_prefix, it.inner())
    }
    pagebreak(weak: true)
    pagecounter += 1
    heading(
      transl("ListOfFigures"),
      numbering: none,
      outlined: true,
      level: 1,
    )
    linebreak()
    outline(title: none, target: figure.where(kind: image))
  }

  if (show-list-of-tables) {
    pagebreak(weak: true)
    pagecounter += 1
    heading(
      transl("ListOfTables"),
      numbering: none,
      outlined: true,
      level: 1,
    )
    linebreak()
    outline(title: none, target: figure.where(kind: table))
  }

  if (show-list-of-code) {
    pagebreak(weak: true)
    pagecounter += 1
    heading(numbering: none, outlined: true, transl("ListOfCode"))
    linebreak()
    outline(title: none, target: figure.where(kind: raw))
  }

  if (acronyms != none) {
    pagebreak(weak: true)
    pagecounter += 1
    heading(numbering: none, outlined: true, transl("ListOfAcronyms"))
    linebreak()
    print-acronyms(
      1em,
    )
  }

  // Main body.
  set par(justify: true)
  set page(numbering: "1")
  counter(page).update(1)

  body

  set heading(numbering: none, outlined: false)

  set page(numbering: "I")
  counter(page).update(pagecounter + 2)

  if (appendix != none) {
    pagebreak(weak: true)
    heading(
      level: 1,
      numbering: none,
      outlined: true,
      transl("Appendix"),
    )
    linebreak()
    appendix
  }

  if (glossary != none) {
    pagebreak(weak: true)
    heading(numbering: none, outlined: true, transl("Glossary"))
    linebreak()
    print-glossary(
      1em,
    )
  }

  if (bibliography != none) {
    pagebreak(weak: true)
    heading(
      level: 1,
      numbering: none,
      outlined: true,
      transl("Bibliography"),
    )
    linebreak()
    bibliography
  }

  pagebreak(weak: true)
  set page(numbering: none)
  align(left)[
    #heading(
      outlined: false,
      numbering: none,
      transl("Affidavit"),
    )
    #transl("StatementUnderOath1")
    #transl(type.replace(type.first(), upper(type.first())))
    #transl("statementUnderOath2")
  ]

  grid(
    columns: 1fr,
    ..for author in authors {
      (
        v(3.5em),
        line(length: 100%),
        v(1em),
        transl("Signature") + " " + author.name,
      )
    }
  )
}
