// Unofficial Linnaeus University (Linnéuniversitetet) Essay & Thesis Template for Typst
// An independent student implementation adapted from en-essay-template-v260219.docx
// License: MIT-0 (Template code)

#let to-string(val) = {
  if type(val) == str {
    val
  } else if type(val) == content {
    if val.has("text") {
      val.text
    } else if val.has("children") {
      val.children.map(to-string).join("")
    } else if val.has("body") {
      to-string(val.body)
    } else {
      none
    }
  } else {
    none
  }
}

// Function to format the appendix section
#let appendix-section(
  font-sans: ("Arial", "Liberation Sans"),
  font-serif: ("Times New Roman", "Liberation Serif"),
  logo: image("assets/lnu-logo.svg", width: 57mm),
  body
) = {
  pagebreak()
  counter(page).update(1)

  set page(
    paper: "a4",
    margin: (top: 40mm, bottom: 25.4mm, left: 35mm, right: 35mm),
    background: place(top + left, dx: 10mm, dy: 10mm, logo),
    footer: context {
      set text(font: font-sans, size: 10pt)
      set align(right)
      let end-app = query(<end-of-appendices>)
      let total-pages = if end-app.len() > 0 {
        counter(page).at(<end-of-appendices>).first()
      } else {
        counter(page).final().first()
      }
      [Page #counter(page).display() (#total-pages)]
    }
  )

  set heading(numbering: none, outlined: false)
  show heading: it => {
    set text(font: font-sans, size: 18pt, weight: "bold")
    v(19.8pt)
    it
    v(6.6pt)
  }

  body

  [#metadata(()) <end-of-appendices>]
}

// Main template function
#let essay(
  // Metadata
  title: [Title],
  subtitle: none,
  doc-type: [Document type],
  author: [Author Name],
  supervisor: [Supervisor Name],
  examiner: [Examiner Name],
  university: [Linnaeus University],
  term: [xx00],
  subject: [Subject Name],
  level: [xxxx],

  // Front matter
  abstract: none,
  keywords: none,
  acknowledgments: none,
  toc: true,
  appendices: none,

  // Customization & styling
  font-sans: ("Arial", "Liberation Sans"),
  font-serif: ("Times New Roman", "Liberation Serif"),
  justify: false,
  logo: image("assets/lnu-logo.svg", width: 57mm),
  background-image: image("assets/lnu-bg.png", width: 210mm, height: 297mm),

  // Document body
  body
) = {
  // Document metadata for PDF export
  let doc-title = to-string(title)
  let doc-authors = if type(author) == array {
    author.map(to-string).filter(it => it != none)
  } else {
    let a = to-string(author)
    if a != none { (a,) } else { () }
  }
  set document(title: doc-title, author: doc-authors)

  // ----------------------------------------------------
  // 1. Cover Page
  // ----------------------------------------------------
  {
    set page(
      paper: "a4",
      margin: (top: 40mm, bottom: 25.4mm, left: 35mm, right: 35mm),
      background: {
        place(top + left, background-image)
        place(top + left, dx: 10mm, dy: 10mm, logo)
      },
      footer: none,
      header: none,
    )

    // Position title at 84mm from top of page (margin top is 40mm + v(44mm) = 84mm)
    v(43.8mm)
    block[
      #text(font: font-sans, size: 30pt, weight: "bold")[#title]
      #if subtitle != none [
        #v(4pt)
        #text(font: font-sans, size: 14pt, weight: "bold")[#subtitle]
      ]
    ]

    // Metadata block placed at x: 115mm (dx: 80mm from left margin 35mm), y: 242mm (dy: 202mm)
    place(top + left, dx: 80mm, dy: 202mm)[
      #set text(font: font-sans, size: 9pt)
      #set par(leading: 0.55em, justify: false)
      #grid(
        columns: 1,
        row-gutter: 0.6em,
        doc-type,
        if type(author) == array [
          #strong(if author.len() > 1 [Authors:] else [Author:]) #author.join(", ")
        ] else [
          #strong[Author:] #author
        ],
        [#strong[Supervisor:] #supervisor],
        [#strong[Examiner:] #examiner],
        [#strong[University:] #university],
        [#strong[Term:] #term],
        [#strong[Subject:] #subject],
        [#strong[Level:] #level],
      )
    ]
  }

  // ----------------------------------------------------
  // 2. Front Matter (Abstract, Keywords, Acknowledgments)
  // ----------------------------------------------------
  if abstract != none or keywords != none or acknowledgments != none {
    pagebreak()
    set page(
      paper: "a4",
      margin: (top: 40mm, bottom: 25.4mm, left: 35mm, right: 35mm),
      background: place(top + left, dx: 10mm, dy: 10mm, logo),
      footer: none,
      header: none,
    )
    set text(font: font-serif, size: 11pt)
    set par(leading: 0.65em, justify: justify)

    if abstract != none {
      v(12pt)
      text(font: font-sans, size: 18pt, weight: "bold")[Abstract]
      v(8pt)
      abstract
      v(18pt)
    }

    if keywords != none {
      text(font: font-sans, size: 18pt, weight: "bold")[Keywords]
      v(8pt)
      if type(keywords) == array {
        keywords.join(", ")
      } else {
        keywords
      }
      v(18pt)
    }

    if acknowledgments != none {
      text(font: font-sans, size: 18pt, weight: "bold")[Acknowledgments]
      v(8pt)
      acknowledgments
    }
  }

  // ----------------------------------------------------
  // 3. Table of Contents
  // ----------------------------------------------------
  if toc {
    pagebreak()
    set page(
      paper: "a4",
      margin: (top: 40mm, bottom: 25.4mm, left: 35mm, right: 35mm),
      background: place(top + left, dx: 10mm, dy: 10mm, logo),
      footer: none,
      header: none,
    )
    set text(font: font-serif, size: 11pt)

    show outline.entry.where(level: 1): it => {
      v(10pt, weak: true)
      strong(it)
    }

    outline(
      title: text(font: font-sans, size: 18pt, weight: "bold")[Table of Contents],
      indent: 1.5em,
    )

    v(2em)
    text(font: font-sans, size: 18pt, weight: "bold")[Appendices]
    v(0.5em)
    text(font: font-serif, size: 11pt)[Appendices should be listed manually]
  }

  // ----------------------------------------------------
  // 4. Main Body
  // ----------------------------------------------------
  pagebreak()
  counter(page).update(1)

  set page(
    paper: "a4",
    margin: (top: 40mm, bottom: 25.4mm, left: 35mm, right: 35mm),
    background: place(top + left, dx: 10mm, dy: 10mm, logo),
    footer: context {
      set text(font: font-sans, size: 10pt)
      set align(right)
      let end-labels = query(<end-of-body>)
      let total-pages = if end-labels.len() > 0 {
        counter(page).at(<end-of-body>).first()
      } else {
        counter(page).final().first()
      }
      [Page #counter(page).display() (#total-pages)]
    },
    header: none,
  )

  set text(font: font-serif, size: 11pt)
  set par(leading: 0.65em, justify: justify)
  set heading(numbering: "1.1")

  // Heading styles matching LNU specification
  show heading: it => {
    set text(font: font-sans, weight: "bold")
    if it.level == 1 {
      set text(size: 18pt)
      v(19.8pt)
      it
      v(6.6pt)
    } else if it.level == 2 {
      set text(size: 14pt)
      v(15.4pt)
      it
      v(5.15pt)
    } else if it.level == 3 {
      set text(size: 12pt)
      v(13.2pt)
      it
      v(4.4pt)
    } else {
      set text(size: 11pt)
      v(11pt)
      it
      v(3.6pt)
    }
  }

  // Block quote style matching LNU-Quote specification
  show quote: it => {
    set text(font: font-serif, size: 10pt)
    set par(leading: 0.55em)
    pad(left: 24pt, right: 24pt, top: 8pt, bottom: 8pt, it.body)
  }

  body

  [#metadata(()) <end-of-body>]

  // ----------------------------------------------------
  // 5. Appendices (if supplied via parameter)
  // ----------------------------------------------------
  if appendices != none {
    appendix-section(
      font-sans: font-sans,
      font-serif: font-serif,
      logo: logo,
      appendices
    )
  }
}
