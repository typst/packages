#let presets(body) = context {
  let target = {
    if "target" in dictionary(std) {
      std.target
    } else {
      () => "paged"
    }
  }

  // Page numbering.
  set page(numbering: "1/1") if target() == "paged"

  // Fonts.
  set text(font: "Libertinus Serif")
  show selector.or(title, heading): set text(font: "Libertinus Sans")
  show raw: set text(font: "Inconsolata", size: 1em / 0.8)
  show math.equation: set text(
    font: "New Computer Modern Math",
    features: (ss03: 1),
  )

  // Hardcode underline metrics from Libertinus fonts. This prevents
  // discontinuous lines when the underlined content contains style changes.
  // See: https://github.com/typst/typst/issues/8145.
  set underline(offset: 0.078em, stroke: 0.04em)

  // Headings.
  show title: set align(center)
  set heading(
    numbering: "1.",
    hanging-indent: 0pt,
  )

  // Justification.
  set par(
    justify: true,
    justification-limits: (
      tracking: (min: -0.01em, max: 0.02em),
    ),
  )
  show selector.or(
    heading,
    figure.caption,
    table,
  ): set par(justify: false)

  // List markers.
  set list(marker: [--])

  // Footnotes.
  set footnote.entry(indent: 0pt)
  show footnote.entry: it => {
    h(it.indent)
    numbering(
      it.note.numbering + ".",
      ..counter(footnote).at(it.note.location()),
    )
    h(1em)
    it.note.body
  }

  // External links.
  show link: it => {
    if type(it.dest) == str and target() != "html" {
      underline(it)
    } else {
      it
    }
  }

  body
}
