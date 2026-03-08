/// Applies show rules for regular figure (kind: image) styling.
///
/// -> function
#let figure-style(
  /// The figure supplement
  /// -> content
  supplement: none,
) = body => {
  assert.ne(supplement, none, message: "Figure supplement not set")

  show figure.where(kind: image): set figure(supplement: supplement)

  body
}

/// Applies show rules for table styling.
///
/// -> function
#let table-style(
  /// The table supplement
  /// -> content
  supplement: none,
) = body => {
  assert.ne(supplement, none, message: "Table supplement not set")

  show figure.where(kind: table): set figure(supplement: supplement)

  // table & line styles
  set line(stroke: 0.1mm)
  set table(stroke: (x, y) => if y == 0 {
    (bottom: 0.1mm)
  })

  body
}

/// Applies show rules for listing (kind: raw) styling.
///
/// -> function
#let listing-style(
  /// The listing supplement
  /// -> content
  supplement: none,
) = body => {
  import "libs.typ": codly.codly-init

  assert.ne(supplement, none, message: "Listing supplement not set")

  show figure.where(kind: raw): set figure(supplement: supplement)
  show figure.where(kind: raw): it => {
    show raw.where(block: true): block.with(width: 95%)
    it
  }

  show: codly-init.with()

  body
}

/// Applies show rules for chapter-wise figure numbering.
///
/// -> function
#let numbering() = body => {
  show heading.where(level: 1): it => {
    let figures = (image, table, raw).map(kind => figure.where(kind: kind))
    let counters = (..figures, math.equation).map(counter)

    for c in counters {
      c.update(0)
    }

    it
  }
  set figure(numbering: n => {
    let ch = counter(heading).get().first()
    std.numbering("1.1", ch, n)
  })
  set math.equation(numbering: n => {
    let ch = counter(heading).get().first()
    std.numbering("(1.1)", ch, n)
  })

  body
}

/// Shows the outlines for the three kinds of figures, if such figures exist.
///
/// -> content
#let outlines(
  /// The figures outline title
  /// -> content
  figures: none,
  /// The tables outline title
  /// -> content
  tables: none,
  /// The listings outline title
  /// -> content
  listings: none,
) = {
  import "outline.typ": align-fill

  assert.ne(figures, none, message: "List of figures title not set")
  assert.ne(tables, none, message: "List of tables title not set")
  assert.ne(listings, none, message: "List of listings title not set")

  let kinds = (
    (image, figures),
    (table, tables),
    (raw, listings),
  )

  show outline.entry: align-fill()
  set outline.entry(fill: repeat(gap: 6pt, justify: false)[.])

  for (kind, title) in kinds {
    context if query(figure.where(kind: kind)).len() != 0 {
      title
      outline(title: none, target: figure.where(kind: kind))
    }
  }
}
