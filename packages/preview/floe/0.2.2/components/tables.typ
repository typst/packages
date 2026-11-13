// ============================================================================
// FLOE DESIGN SYSTEM — ADAPTIVE TABLES (components/tables.typ)
// Rounded-Corner Sans-Serif Data Tables, Specs & Matrix Comparison Grids
// ============================================================================
#import "../core/lib.typ": *
#import "../primitives/lib.typ": badge

#let _internal-cell-stroke(border-c) = (x, y) => (
  top: if y > 0 { strokes.hairline + border-c } else { none },
  left: if x > 0 { strokes.hairline + border-c } else { none },
)

/// Safe, proportional data table with rounded card frame, crisp sans-serif typography,
/// non-justified cells, bumped zebra striping (slate-200 header / slate-100 even rows),
/// and semantic table.header repetition.
#let data-table(
  columns: none,
  headers: (),
  align: auto,
  stroke: auto,
  inset: (x: 8.5pt, y: 6.5pt),
  radius: radii.md,
  above: 8pt,
  below: 8pt,
  fill: (_, y) => if y == 0 { slate-200 } else if calc.even(y) { slate-100 } else { white },
  ..cells,
) = {
  let resolved-cols = columns
  if resolved-cols == none {
    if headers.len() > 0 {
      resolved-cols = (1fr,) * headers.len()
    } else {
      resolved-cols = 1
    }
  }

  let resolved-align = if align != auto {
    align
  } else {
    (col, row) => if row == 0 { center + horizon } else { left + horizon }
  }

  let resolved-stroke = if stroke != auto {
    stroke
  } else {
    _internal-cell-stroke(slate-200)
  }

  block(
    width: 100%,
    radius: radius,
    stroke: strokes.border + slate-300,
    fill: white,
    clip: true,
    above: above,
    below: below,
    breakable: true,
  )[
    #set text(font: fonts.sans, size: 8.6pt, fill: slate-800)
    #set par(justify: false, leading: 0.5em)
    #table(
      columns: resolved-cols,
      align: resolved-align,
      stroke: resolved-stroke,
      inset: inset,
      fill: fill,
      if headers.len() > 0 {
        table.header(
          ..headers.map(h => table.cell(align: center + horizon)[
            #text(font: fonts.sans, size: 8.6pt, weight: "bold", fill: floe-navy)[#h]
          ])
        )
      },
      ..cells.pos().flatten()
    )
  ]
}

/// Clean 2-column parameter / specification key-value table with rounded corners and zebra rows
#let spec-table(
  columns: (1fr, 2.3fr),
  align: (right + horizon, left + horizon),
  stroke: auto,
  inset: (x: 9pt, y: 6.5pt),
  radius: radii.md,
  above: 8pt,
  below: 8pt,
  ..pairs,
) = {
  let resolved-stroke = if stroke != auto {
    stroke
  } else {
    _internal-cell-stroke(slate-200)
  }

  block(
    width: 100%,
    radius: radius,
    stroke: strokes.border + slate-300,
    fill: white,
    clip: true,
    above: above,
    below: below,
    breakable: true,
  )[
    #set text(font: fonts.sans, size: 8.6pt, fill: slate-800)
    #set par(justify: false, leading: 0.5em)
    #table(
      columns: columns,
      align: align,
      stroke: resolved-stroke,
      inset: inset,
      fill: (_, y) => if calc.even(y) { slate-100 } else { white },
      ..pairs.pos().map(item => {
        if type(item) == array and item.len() == 2 {
          (
            text(font: fonts.sans, size: 8.6pt, weight: "bold", fill: floe-navy)[#item.at(0)],
            item.at(1),
          )
        } else {
          item
        }
      }).flatten()
    )
  ]
}

/// Comparison grid with status chips (e.g. #badge-yes, #badge-no, #badge-opt)
#let badge-yes = badge("YES", variant: "success")
#let badge-no  = badge("NO",  variant: "danger")
#let badge-opt = badge("OPT", variant: "purple")

#let comparison-table(
  columns: none,
  headers: (),
  above: 8pt,
  below: 8pt,
  ..cells,
) = data-table(
  columns: columns,
  headers: headers,
  align: center + horizon,
  above: above,
  below: below,
  ..cells.pos(),
)
