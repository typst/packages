// ČVUT (CTU in Prague) Report Template for term projects etc.
//
// Provides three public functions:
//   - `report`:       full document setup (cover + table-of-content + body + bibliography)
//   - `report-cover`: renders a standalone cover page
//   - `report-toc`:   renders a custom table of content

// Creates the title/cover page of the report.
// Handles layout with university info on the left-top,
// centered title/subtitle, and author info at the bottom.
#let report-cover(
  title: "REPORT TITLE",
  subtitle: "REPORT SUBTITLE",
  author: "AUTHOR NAME",
  username: "STUDENT USERNAME",
  date: "DATE OF SUBMISSION (e.g. Květen 2026)",
  university: "Fakulta elektrotechnická ČVUT v Praze",
  branch: "YOUR STUDY BRANCH",
  logo: none,
) = {
  page(
    margin: 3cm,
    numbering: none,
  )[
    #set align(center)

    // logo + faculty/branch info
    #stack(dir: ltr, spacing: 1.3em)[
      #logo
    ][
      #v(1.5em)
      #set align(left)
      #stack(dir: ttb, spacing: 12pt)[
        #text(university, size: 20pt, weight: "bold")
      ][
        #text(branch, size: 16pt)
      ]
    ]

    // main title block vertically centered
    #align(horizon, block[
      #text(title, size: 26pt, weight: "bold")
      #v(-1.5em)
      #text(subtitle, size: 18pt)
    ])

    // author and year information at the bottom
    #align(bottom, block[
      #text(author, 18pt)\
      #text(username, 12pt)
      #v(1.5em)
      #text(date)
    ])
  ]
}

// Configures and displays the table of contents with custom styling.
// Adjusts spacing and typography for different heading levels (1–4)
// to create a clean, hierarchical TOC.
#let report-toc(
  title: "TABLE OF CONTENTS TITLE",
) = {
  // style headings based on level
  show outline.entry.where(level: 1): it => {
    v(12pt, weak: true) // space above
    text(it, weight: 900, size: 14pt)
  }
  show outline.entry.where(level: 2): it => {
    v(4pt) // space above
    text(it, weight: 500, size: 13pt)
  }
  show outline.entry.where(level: 3): it => {
    v(2pt) // space above
    text(it, weight: 300, size: 12pt)
  }
  show outline.entry.where(level: 4): it => {
    v(2pt) // space above
    text(it, weight: 300, size: 11pt)
  }

  page(
    numbering: none,
  )[
    #align(center, text(size: 18pt)[#title])
    #v(14pt)
    #outline(title: none, indent: 1.6em)
  ]
}

// Main report template function.
// Sets up global document settings (metadata, page layout, typography),
// applies custom styling for headings, paragraphs, figures and code blocks,
// then assembles the document in this order:
//   1. Cover page
//   2. Table of contents
//   3. Main body content
//   4. Bibliography (if provided)
#let report(
  title: "REPORT TITLE",
  subtitle: "REPORT SUBTITLE",
  author: "AUTHOR NAME",
  username: "STUDENT USERNAME",
  date: "DATE OF SUBMISSION (e.g. Květen 2026)",
  university: "Fakulta elektrotechnická ČVUT v Praze",
  branch: "YOUR STUDY BRANCH",
  logo: none,
  toc-title: "TABLE OF CONTENTS TITLE",
  font: "libertinus serif", // typst default
  bib: none,
  body,
) = {
  set document(
    title: title,
    author: author,
  )

  set page(
    paper: "a4",
    margin: 2cm,
    numbering: "1",
  )

  set heading(numbering: "1.")
  show heading.where(level: 1): it => block[#text(size: 18pt, it)]
  show heading.where(level: 2): it => block[#text(size: 16pt, it)]
  show heading.where(level: 3): it => block[#text(size: 14pt, it)]
  show heading.where(level: 4): it => block[#text(size: 12pt, it)]

  set par(justify: true, first-line-indent: 2em) // hezky "do bloku"

  // slightly larger space behind an image/figure
  show figure: it => {
    it
    v(0.4em)
  }

  // code block
  show raw.where(block: true): it => align(
    block(
      stroke: rgb("#ddd"),
      fill: rgb("#fafafa"),
      inset: 10pt,
      radius: 0.5em,
      above: 2em,
      below: 2em,
      it,
    ),
    center,
  )

  report-cover(
    title: title,
    subtitle: subtitle,
    author: author,
    username: username,
    date: date,
    university: university,
    branch: branch,
    logo: logo,
  )

  report-toc(
    title: toc-title,
  )

  // main document
  pagebreak(weak: true)
  counter(page).update(1)
  body // the actual text

  if bib != none {
    pagebreak(weak: true)
    set par(justify: false) // no align to block
    bib
  }
}
