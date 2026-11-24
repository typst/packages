#import "i18n.typ": i18n, i18n-page-counter, i18n-translation
#import "utils.typ": *

/// This stile is applied to the entire project.
#let global-style(doc) = context {
  set page(paper: "a4", margin: (bottom: 2cm, rest: 2.5cm))
  set text(size: 11pt)
  show: apply-sans-font
  set par(
    justify: true,
    linebreaks: "optimized",
    justification-limits: (
      tracking: (min: -0.05em, max: 0.05em),
    ),
  )
  show: line-spacing.with(1.25em)
  show footnote: set text(size: 0.8em)
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: raw): set align(start)
  show figure.caption: it => {
    grid(
      columns: 3,
      gutter: 0pt,
      align: left,
      context {
        show: strong
        it.supplement
        sym.space
        it.counter.display(it.numbering)
      },
      it.separator,
      it.body,
    )
  }

  show figure.where(kind: image): set figure(supplement: i18n-translation(
    "figure",
    text.lang,
  ))
  show figure.where(kind: table): set figure(supplement: i18n-translation(
    "table",
    text.lang,
  ))
  show figure.where(kind: raw): set figure(supplement: i18n-translation(
    "raw",
    text.lang,
  ))
  show math.equation: set math.equation(supplement: i18n-translation(
    "equation",
    text.lang,
  ))

  // Setup supplements and formatting of references
  show ref.where(form: "normal"): set ref(supplement: it => if it.func()
    == figure {
    if it.kind == image {
      i18n("ref-figure")
    } else if it.kind == table {
      i18n("ref-table")
    } else if it.kind == raw {
      i18n("ref-raw")
    } else {
      return it.supplement
    }
  } else if it.func() == math.equation {
    i18n("ref-equation")
  } else {
    return it.supplement
  })
  show ref.where(form: "normal"): it => {
    if it.element == none {
      return it
    }

    if it.element.func() == math.equation {
      return link(it.element.location())[
        #(it.supplement)(it.element)
        #(
          (it.element.numbering)(
            ..counter(math.equation).at(it.element.location()),
          )
            .trim("(", at: start)
            .trim(")", at: end)
        )
      ]
    }

    return it
  }

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
    #i18n-page-counter(
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
  show heading: mark-heading-boundaries
  show heading: set block(above: 1.5em, below: 1em)
  show heading.where(level: 1): set block(inset: (top: 0.25em))
  // Default heading style for the whole document
  set heading(numbering: none, supplement: i18n-translation(
    "ref-section",
    text.lang,
  ))
  show heading: set align(right)

  // Typography
  set par(spacing: 2em)

  doc
}

/// This style is applied to the chapter content of the document, everything that the template wraps so to say.
#let content-style(doc) = {
  // Arabic for text sections = content
  set page(numbering: "1")
  counter(page).update(1)

  // Reset figure and math counters per chapter
  show heading.where(level: 1): it => {
    reset-listing-counters()
    colbreak(weak: true)
    it
  }

  // Setup headers
  set heading(numbering: "1.1")
  show heading: set align(left)
  let current-top-heading = state("_ght-cth", none)
  set heading(numbering: (..args) => with-inside-heading(is-inside-heading => {
    show: if is-inside-heading {
      box.with(width: 1.5cm)
    } else {
      it => it
    }

    numbering("1.1", ..args)
  }))

  // Hierarchical numbering
  set figure(numbering: hierarchical-numbering("1.1"))
  set math.equation(numbering: hierarchical-numbering("(1.1)"))

  doc
}

/// This style is applied to the declaration page.
#let declaration-style(doc) = {
  set heading(outlined: false)
  show heading: set align(left)
  show heading.where(level: 1): set text(size: 0.5em)
  set page(header: none, footer: none)
  doc
}

/// This style is applied to the acknowledgement section.
#let acknowledgement-style(doc) = {
  set heading(outlined: false)

  doc
}

/// This style is applied to the abstract section (both german and english).
#let abstract-style(doc) = {
  // Arabic for text sections = abstract
  set page(numbering: "1")
  set heading(offset: 1, outlined: false)

  doc
}

/// This style is applied to the preamble section.
#let preamble-style(doc) = {
  // Arabic for text sections = abstract
  set page(numbering: "1")

  set heading(offset: 1, outlined: false)

  doc
}


#let _outline-entry(entry, logical-level: none) = {
  if logical-level == none {
    logical-level = entry.element.level
  }
  let element-location = entry.element.location()
  if entry.element.func() == heading and entry.element.level == 1 {
    element-location = nearest-top-level-heading(element-location)
  }

  link(
    element-location,
    entry.indented(
      entry.prefix(),
      {
        entry.body()
        box(entry.fill, width: 1fr, inset: (x: 1mm))
        numbering(
          element-location.page-numbering(),
          ..counter(page).at(element-location),
        )
      },
    ),
  )
}


/// This style is applied to the chapter outline.
#let chapter-outline-style(doc) = {
  set outline(indent: auto)

  show outline.entry: _outline-entry

  doc
}

#let abbreviations-style(doc) = {
  doc
}

/// This style is applied to the figure outline.
#let figure-outline-style(doc) = {
  show outline.entry: _outline-entry.with(logical-level: 2)
  doc
}

#let table-outline-style(doc) = {
  show outline.entry: _outline-entry.with(logical-level: 2)
  doc
}

/// This style is applied to the bibliography section.
#let bibliography-style(doc) = context {
  // Arabic for literature section
  set page(numbering: "1")

  // Configure actual bibliography style
  set bibliography(style: "apa", title: i18n-translation(
    "bibliography",
    text.lang,
  ))

  doc
}

/// This style is applied to the appendix section.
#let appendix-style(doc) = {
  reset-listing-counters()

  set heading(offset: 1)

  // Arabic for text sections = appendix
  set page(numbering: "1")

  set figure(numbering: (..n) => [A.#numbering("1", ..n)])
  set math.equation(numbering: (..n) => [(A.#numbering("1", ..n))])

  doc
}
