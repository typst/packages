#import "i8n.typ": i8n, i8n-page-counter
#import "utils.typ": *

/// This stile is applied to the entire project.
#let global-style(doc) = {
  set page(paper: "a4", margin: (bottom: 2cm, rest: 2.5cm))
  set text(font: "Arial", size: 11pt)
  set par(justify: true)
  show footnote: set text(size: 0.8em)
  show: line-spacing.with(1.25em)
  show figure.where(kind: table): set figure.caption(position: top)
  doc
}

/// This style is applied to the entire document (project without title page).
#let document-style(doc) = context {
  // Setup page decorations
  let current-top-heading = state("_ght-cth", none)
  let header = context [
    #set text(size: 0.9em)
    #align(right, {
      let cur-heading = current-top-heading.at(
        query(selector(<_ght-footer>).after(here())).first().location(),
      )
      let cur-heading-body = if cur-heading != none {
        cur-heading.body
      } else {
        "Placeholder"
      }
      let render-content = {
        show: strong
        set block(spacing: 1.25em)
        rect(stroke: none, inset: 0pt, underline(cur-heading-body))
      }
      if cur-heading != none {
        render-content
      } else {
        hide(render-content)
      }
    })
    #line(length: 100%)
    #v(2em)
  ]
  let footer = context [
    #set text(size: 0.9em)
    #set par(spacing: 1em)
    #v(2em)
    #line(length: 100%) <_ght-footer>

    #document.title
    #h(1fr)
    #i8n-page-counter(
      counter(page).get().first(),
      counter(page).final().first(),
    )
  ]
  set page(header: header, header-ascent: 0cm)
  set page(footer: footer, footer-descent: 0cm)
  let target-margin = page.margin
  set page(margin: (
    ..target-margin,
    top: target-margin.top + measure(header).height,
    bottom: target-margin.bottom + measure(footer).height,
  ))
  // Default page numbering style for the whole document
  set page(numbering: "I")

  // Setup headings
  show heading.where(level: 1): set text(size: 1.6em)
  show heading.where(level: 2): set text(size: 1.4em)
  show heading.where(level: 3): set text(size: 1.25em)
  show heading.where(level: 4): set text(size: 1.1em)
  show heading.where(level: 1): it => {
    it
    current-top-heading.update(it)
  }
  show heading: set block(above: 1.5em, below: 1em)
  show heading.where(level: 1): set block(inset: (top: 0.25em))
  // Default heading style for the whole document
  set heading(numbering: none)
  show heading: set align(right)

  // Typography
  set par(spacing: 2em)

  doc
}

/// This style is applied to the chapter content of the document, everything that the template wraps so to say.
#let content-style(doc) = {
  // Arabic for text sections = content
  set page(numbering: "1")

  // Setup headers
  set heading(numbering: "1.1")
  show heading: set align(left)
  show heading.where(level: 1): it => {
    colbreak(weak: true)
    it
  }
  let current-top-heading = state("_ght-cth", none)
  set heading(numbering: (..args) => context {
    let current-top-heading = query(selector(heading).before(here())).last()
    let chapter-outline-heading = query(selector(
      <_ght-chapter-outline>,
    )).first()
    // For display in chapter outline, we must remove the margin from the heading numbering
    if (
      current-top-heading.location().page()
        == chapter-outline-heading.location().page()
    ) {
      numbering("1.1", ..args)
    } else {
      box(
        width: 1.5cm,
        numbering("1.1", ..args),
      )
    }
  })

  doc
}

/// This style is applied to the declaration page.
#let declaration-style(doc) = {
  set heading(outlined: false)
  doc
}

/// This style is applied to the acknowledgement section.
#let acknowledgement-style(doc) = {
  doc
}

/// This style is applied to the abstract section (both german and english).
#let abstract-style(doc) = {
  // Arabic for text sections = abstract
  set page(numbering: "1")

  doc
}

/// This style is applied to the preamble section.
#let preamble-style(doc) = {
  // Arabic for text sections = abstract
  set page(numbering: "1")

  doc
}

/// This style is applied to the chapter outline.
#let chapter-outline-style(doc) = {
  set outline(indent: auto)

  doc
}

#let abbreviations-style(doc) = {
  doc
}

/// This style is applied to the figure outline.
#let figure-outline-style(doc) = {
  doc
}

#let table-outline-style(doc) = {
  doc
}

/// This style is applied to the bibliography section.
#let bibliography-style(doc) = {
  // Arabic for literature section
  set page(numbering: "1")

  // Configure actual bibliography style
  set bibliography(style: "apa", title: i8n("bibliography"))

  doc
}

/// This style is applied to the appendix section.
#let appendix-style(doc) = {
  // Arabic for text sections = appendix
  set page(numbering: "1")

  doc
}
