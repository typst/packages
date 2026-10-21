#import "cover.typ": cover-page, back-cover-page
#import "front-matter.typ": front-matter

// Font sizes and vertical spacing per heading level.
#let heading-sizes = (25pt, 18pt, 15pt, 12pt, 12pt, 12pt)
#let heading-spacings = (2em, 1.6em, 1.3em, 1.1em, 1em, 1em)

// Heading numbering for the main matter:
// level 1: "Chapter N", level 2: "N.M", level 3: "A.", level 4: "•"
#let thesis-numbering(..nums) = {
  let parts = nums.pos()
  if parts.len() == 1 {
    "Chapter " + str(parts.at(0))
  } else if parts.len() == 2 {
    str(parts.at(0)) + "." + str(parts.at(1))
  } else if parts.len() == 3 {
    numbering("A.", parts.at(2))
  } else if parts.len() == 4 {
    "•"
  } else {
    parts.map(str).join(".")
  }
}

#let graduate-thesis(
  title: [thesis title],
  author: "author name",
  degree: [MS of Computer Information Systems],
  department: [College of Science, Mathematics and Technology],
  university: [Wenzhou-Kean University],
  supervisor: [Supervisor Name],
  month: [Month],
  year: [Year],
  degree-year: [Year],
  program-type: [Master of Computer Information Systems],
  degree-type: [Master],
  degree-department: [College of Science, Mathematics and Technology],
  abstract: none,
  keywords: none,
  acknowledgments: none,
  acronyms: none,
  bibliography: none,
  body
) = {
  set document(title: title, author: author)
  // Front matter headings are unnumbered
  set heading(numbering: none)

  // Headings: bold and sized by level. Numbered level-1 headings
  // (chapters) are centered, and every chapter from Chapter 2 on
  // starts on a fresh page.
  show heading: it => {
    let level = it.level - 1
    let size = if level < heading-sizes.len() { heading-sizes.at(level) } else { 12pt }
    let spacing = if level < heading-spacings.len() { heading-spacings.at(level) } else { 1em }
    let is-chapter = it.level == 1 and it.numbering != none

    if is-chapter and counter(heading).get().at(0, default: 1) >= 2 {
      pagebreak()
    }

    v(spacing, weak: true)

    if is-chapter {
      align(center, text(size: size, weight: "bold", it))
    } else {
      text(size: size, weight: "bold", it)
    }

    v(spacing, weak: true)
  }

  // Captions of tables and figures: 10pt bold, table captions above the table.
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.caption.where(kind: table): it => text(size: 10pt, weight: "bold", it)
  show figure.caption.where(kind: image): it => text(size: 10pt, weight: "bold", it)

  // COVER PAGE
  cover-page(
    title: title,
    author: author,
    degree: degree,
    department: department,
    university: university,
    supervisor: supervisor,
    month: month,
    year: year,
  )

  // COVER PAGE BACKFRONT
  set text(size: 12pt)
  set page(numbering: "i")
  counter(page).update(2)
  back-cover-page(
    title: title,
    author: author,
    university: university,
    supervisor: supervisor,
    program-type: program-type,
    degree-year: degree-year,
    degree-type: degree-type,
    degree-department: degree-department,
  )

  // FRONT MATTER: abstract, acknowledgments, TOC, lists, acronyms
  set par(justify: true, leading: 1em, spacing: 2.5em)
  front-matter(
    abstract: abstract,
    keywords: keywords,
    acknowledgments: acknowledgments,
    acronyms: acronyms,
  )

  // MAIN MATTER: Arabic page numbers starting from 1, chapter numbering
  set page(numbering: "1")
  counter(page).update(1)
  counter(heading).update(0)
  set heading(numbering: thesis-numbering)

  show std.bibliography: set text(12pt)
  show std.bibliography: set par(spacing: 1em, leading: 0.5em)
  set std.bibliography(title: [References], style: "ieee")

  body

  pagebreak()
  bibliography
}
