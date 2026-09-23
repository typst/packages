// Style layer: page geometry, typography, headings, running headers/footers,
// and matter switching. Metadata and content live in main.typ.

#import "@preview/hydra:0.6.3": hydra
#import "@preview/i-figured:0.2.4"
#import "@preview/drafting:0.2.2": set-page-properties, set-margin-note-defaults
#import "frontmatter.typ": title-page, dedication-page, abstract-page

#let _chapter-pages() = query(heading.where(level: 1)).map(h => h.location().page())

// Pages that get no running header: chapter openings and the blank verso
// before one. The even-page heuristic can also blank the last content page
// of a chapter that ends flush on a verso — rare and harmless.
#let _plain-page(pg) = {
  let chapters = _chapter-pages()
  pg in chapters or (calc.even(pg) and pg + 1 in chapters)
}

#let _header = context {
  let pg = here().page()
  if not _plain-page(pg) {
    if calc.even(pg) {
      strong(counter(page).display()) + h(1fr) + emph(hydra(1, book: true))
    } else {
      emph(hydra(2, book: true)) + h(1fr) + strong(counter(page).display())
    }
  }
}

#let _footer(version, draft) = context {
  let pg = here().page()
  let chapters = _chapter-pages()
  let blank-verso = calc.even(pg) and pg + 1 in chapters
  if pg in chapters {
    align(center, counter(page).display())
  }
  if draft and not blank-verso {
    align(center, text(size: 7pt, fill: gray)[
      #version — compiled #datetime.today().display("[year]-[month]-[day]")
    ])
  }
}

// Chapter opening: recto page, big gray number, then the title.
#let _chapter-opening(it) = {
  pagebreak(to: "odd", weak: true)
  v(2cm)
  if it.numbering != none {
    block(text(
      size: 64pt,
      weight: "bold",
      fill: gray.lighten(40%),
      counter(heading).display(it.numbering),
    ))
    v(0.8cm)
  }
  block(text(size: 22pt, weight: "bold", it.body))
  v(1.2cm)
}

#let thesis(
  title: [Thesis Title],
  author: "A. Author",
  degree: "Doctor of Philosophy",
  university: "University of Somewhere",
  faculty: none,
  department: none,
  supervisors: (),
  location: none,
  date: datetime.today(),
  keywords: (),
  version: "v0.1",
  draft: true,
  dedication: none,
  abstract: none,
  body,
) = {
  set document(title: title, author: author, keywords: keywords)

  // In draft mode the outside margin widens to hold todo notes.
  let outside = if draft { 45mm } else { 19mm }
  set page(
    width: 176mm,
    height: 250mm,
    margin: (inside: 24mm, outside: outside, top: 24mm, bottom: 22mm),
    binding: left,
    numbering: "i",
    header: _header,
    footer: _footer(version, draft),
  )
  set text(font: ("Charter", "Libertinus Serif"), size: 10.5pt, lang: "en")
  set par(justify: true, first-line-indent: 1.2em)

  set heading(numbering: none)
  show heading.where(level: 1): _chapter-opening
  show heading: i-figured.reset-counters
  show figure: i-figured.show-figure
  show math.equation: i-figured.show-equation

  // ---- front matter (roman page numbers, unnumbered headings) ----
  title-page(
    title: title, author: author, degree: degree, university: university,
    faculty: faculty, department: department, supervisors: supervisors,
    location: location, date: date, version: version, draft: draft,
  )
  if dedication != none { dedication-page(dedication) }
  if abstract != none { abstract-page(abstract) }
  outline(depth: 2)
  i-figured.outline(target-kind: image, title: [List of Figures])
  i-figured.outline(target-kind: table, title: [List of Tables])

  set-page-properties(margin-left: 24mm, margin-right: outside)
  set-margin-note-defaults(hidden: not draft, side: right, stroke: gray + 0.5pt)

  // ---- main matter ----
  pagebreak(to: "odd", weak: true)
  set page(numbering: "1")
  counter(page).update(1)
  set heading(numbering: "1.1")
  body
}

// Heading numbering switches to A, B, C — apply with `#show: appendix`.
#let appendix(body) = {
  counter(heading).update(0)
  set heading(numbering: "A.1", supplement: [Appendix])
  show figure: it => i-figured.show-figure(it, numbering: "A.1")
  show math.equation: it => i-figured.show-equation(it, numbering: "(A.1)")
  body
}

// Unnumbered chapters for bibliography, index, glossary, summary, etc.
#let backmatter(body) = {
  set heading(numbering: none)
  body
}
