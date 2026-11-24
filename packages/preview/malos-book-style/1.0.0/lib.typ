#let book(subtitle: none, body) = {
  import "@preview/malos-presets:1.5.0": presets
  show: presets

  set page(
    header: context if here().page() > 1 {
      show: block.with(
        width: 100%,
        inset: (bottom: 0.4em),
        stroke: (bottom: 0.5pt),
      )
      set align(bottom)
      show: smallcaps

      // Query the last outlined heading of level 1 that is before or within the
      // current page.
      let chapter = query(heading.where(level: 1, outlined: true))
        .filter(h => h.location().page() <= here().page())
        .map(h => h.body)
        .last(default: none)

      if chapter == none {
        document.title
      } else {
        grid(
          columns: 3,
          gutter: 1fr,
          align(start, document.title),
          h(1cm),
          align(end, chapter),
        )
      }
    },
  )

  show title: set text(size: 42pt)

  // Make the digits slightly taller to better fit the uppercase letters used
  // for Roman numerals.
  // https://github.com/alerque/libertinus/blob/master/documentation/Features.md#cased-forms-case
  show regex(`[IVXLCDM](\.[0-9])+`.text): set text(features: ("case",))

  set heading(numbering: "I.1.")

  show heading.where(level: 1): set align(center + horizon)
  show heading.where(level: 1): set text(size: 36pt)
  show heading.where(level: 1): set heading(
    supplement: context (
      en: [Chapter],
      fr: [Chapitre],
    ).at(text.lang, default: auto),
  )
  show heading.where(level: 1): it => {
    show: page.with(header: none)
    set block(spacing: 24pt)
    if it.numbering != none {
      show: block.with(
        width: 80%,
        inset: (bottom: 8pt),
        stroke: (bottom: 1pt),
      )
      set align(start)
      set text(size: 18pt, weight: "regular")
      if it.supplement != none {
        [#it.supplement ]
      }
      counter(heading).display(it.numbering)
    }
    block(it.body)
    v(10%)
  }
  // Revoke rule for outline and bibliography headings.
  show selector.or(outline, bibliography): it => {
    show heading: set text(size: 16pt)
    show heading: set align(start + top)
    show heading: itt => block(itt.body)
    it
  }

  show heading.where(level: 2): set align(center)
  show heading.where(level: 2): set block(
    width: 100%,
    stroke: (y: 1.5pt),
    inset: (y: 0.3em),
    spacing: 0.8em,
  )
  show heading.where(level: 2): set text(size: 32pt)
  show heading.where(level: 2): smallcaps

  show heading.where(level: 3): set text(size: 24pt)
  show heading.where(level: 4): set text(size: 18pt)
  show heading.where(level: 5): set text(size: 14pt)

  set outline(indent: 1em, depth: 3)
  show outline: it => it + v(1cm, weak: true)
  show outline.entry.where(level: 1): it => {
    if it.element.func() != heading {
      return it
    }
    set block(above: 1.2em)
    set text(weight: "bold")
    let prefix = if it.element.numbering != none {
      it.element.supplement
      [ ]
      it.prefix()
    }
    link(
      it.element.location(),
      it.indented(prefix, it.inner()),
    )
  }

  // Document content.

  v(1.5cm, weak: false)

  title()

  if subtitle != none {
    v(32pt, weak: true)
    set align(center)
    set text(size: 32pt, font: "Libertinus Sans")
    set par(justify: false)
    block(subtitle)
  }

  v(48pt, weak: true)
  align(center, context document.author.join(linebreak()))

  v(2.5cm, weak: true)

  body
}
