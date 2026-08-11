// ============================================================================
// Composites: higher-level diagram structures
// ============================================================================
//
// schema        - Top-level inline diagram with title and description
// linked-schema - Schema with fields → connector → target
// grid-row      - A labeled row for tabular / register / cache diagrams
// lane          - A horizontal track for thread / timeline diagrams
// section       - A titled card for grouping related diagrams
// ============================================================================

#import "atoms.typ": *
#import "containers.typ": *

/// A top-level diagram container with optional title and description.
///
/// Wraps content as an inline box so multiple schemas flow horizontally.
#let schema(title: none, desc: none, width: auto, body) = {
  box(
    width: width,
    inset: (bottom: 12pt, right: 16pt),
    baseline: 0%,
    {
      if title != none {
        block(below: 3pt, text(weight: "bold", title))
      }
      { set align(center); body }
      if desc != none {
        block(above: 3pt, text(size: 0.7em, fill: luma(80), desc))
      }
    },
  )
}

/// A schema with top-level fields linked to a target region below.
///
/// ```typst
/// #linked-schema(
///   title: raw("Vec<T>"),
///   fields: (my-ptr(), my-len(), my-cap()),
///   target-fill: blue.lighten(80%),
///   target-label: "(heap)",
///   { cell(fill: salmon)[T]; cell(fill: salmon)[T] },
/// )
/// ```
#let linked-schema(
  title: none,
  desc: none,
  width: auto,
  fields: (),
  target-fill: rgb("#FDECDC"),
  target-label: none,
  target-width: auto,
  danger: false,
  body,
) = {
  schema(title: title, desc: desc, width: width, {
    region(danger: danger, fields.join())
    connector()
    target(fill: target-fill, label: target-label, width: target-width, body)
  })
}

/// A labeled row of cells for tabular, register, or cache diagrams.
///
/// Row label is vertically centered with the content.
#let grid-row(label: none, label-width: 80pt, body) = {
  set par(spacing: 4pt)
  grid(
    columns: (label-width, 1fr),
    align: (right + horizon, left + horizon),
    gutter: 6pt,
    if label != none { text(size: 0.75em, fill: luma(100), label) } else { [] },
    body,
  )
}

/// A horizontal track with color-coded items for thread or timeline diagrams.
///
/// ```typst
/// #lane(
///   name: [Thread 1],
///   items: (
///     (label: [Mutex], fill: green),
///     (label: [Rc],    fill: red),
///   ),
/// )
/// ```
#let lane(name: none, items: ()) = {
  block(width: 100%, inset: (y: 4pt), {
    place(horizon, line(length: 100%, stroke: (paint: luma(200), thickness: 1pt)))
    for item in items {
      h(8pt)
      box(
        fill: item.fill,
        stroke: (paint: black, thickness: 0.5pt),
        radius: 2pt,
        inset: (x: 4pt, y: 2pt),
        baseline: 30%,
        text(size: 0.75em, fill: black, item.label),
      )
    }
    v(4pt)
    if name != none {
      v(1pt)
      text(size: 0.65em, fill: luma(120), name)
    }
  })
}

/// A color legend mapping fills to labels.
///
/// ```typst
/// #legend(
///   (label: [Modified], fill: orange),
///   (label: [Shared],   fill: green),
///   (label: [Invalid],  fill: gray),
/// )
/// ```
///
/// - `items`: Array of dictionaries with `label` and `fill` keys.
/// - `columns`: Number of columns. Default: `auto` (one row).
/// - `swatch-size`: Size of the color swatch. Default: `10pt`.
#let legend(..items, columns: auto, swatch-size: 10pt) = {
  let entries = items.pos()
  let cols = if columns == auto { entries.len() } else { columns }

  grid(
    columns: cols,
    column-gutter: 14pt,
    row-gutter: 6pt,
    ..entries.map(item => {
      box(baseline: 20%, {
        box(
          fill: item.fill, width: swatch-size, height: swatch-size,
          stroke: 0.5pt + black, radius: 2pt,
        )
        h(4pt)
        text(size: 0.8em, item.label)
      })
    }),
  )
}

/// A proportional bit-field row where cell widths scale by bit count.
///
/// Perfect for network protocol headers and hardware register maps.
/// Each field's width is proportional to its bit count relative to `total`.
///
/// ```typst
/// #bit-row(total: 32, width: 400pt, fields: (
///   (bits: 4,  label: [Ver],  fill: yellow),
///   (bits: 4,  label: [IHL],  fill: yellow),
///   (bits: 8,  label: [DSCP], fill: purple),
///   (bits: 16, label: [Total Length], fill: cyan),
/// ))
/// ```
///
/// - `total`: Total bit width of the row (e.g., 32 for a 32-bit word).
/// - `width`: Total visual width of the row.
/// - `fields`: Array of `(bits, label, fill)` dictionaries.
///   Optional keys: `stroke`, `dash`.
/// - `show-bits`: If `true`, show bit widths as subscript. Default: `true`.
#let bit-row(total: 32, width: 400pt, fields: (), show-bits: true) = {
  let gap = 0pt  // no gap between fields for tight packing
  let usable = width - (fields.len() - 1) * gap

  box(baseline: 30%, {
    for (i, f) in fields.enumerate() {
      let w = usable * f.bits / total
      let s = if "stroke" in f { f.stroke } else { 0.8pt + black }
      let d = if "dash" in f { f.dash } else { none }
      cell(
        {
          f.label
          if show-bits {
            sub-label[#{ str(f.bits) }b]
          }
        },
        fill: f.fill,
        width: w,
        stroke: s,
        dash: d,
      )
      if i < fields.len() - 1 { h(gap) }
    }
  })
}

/// A titled section card for grouping related diagrams.
#let section(title, fill: luma(252), stroke: 0.5pt + luma(220), body) = {
  block(
    width: 100%, inset: 14pt, fill: fill,
    radius: 4pt, stroke: stroke, above: 14pt,
    {
      text(size: 1.2em, weight: "bold", title)
      v(8pt)
      body
    },
  )
}
