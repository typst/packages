// ============================================================================
// FLOE DESIGN SYSTEM — EQUAL-HEIGHT ROW GRID ENGINE (primitives/grid.typ)
// Layer 1: Parent-Driven Vertical Growth & Row Equalization Hardware
// ============================================================================
#import "../core/lib.typ": *

/// Reconstructs any top-level block at target height `h` while preserving its
/// background fill, stroke, radius, inset, and clip settings, and distributing
/// any vertical `slack` across internal stretch markers so footers stay bottom-aligned.
#let stretch-cell(c, h, slack: 0pt) = {
  if type(c) == content and c.func() == block {
    let f = c.fields()
    let body = f.remove("body", default: none)
    let _ = f.remove("height", default: none)
    let _ = f.remove("above", default: none)
    let _ = f.remove("below", default: none)
    let _ = f.remove("breakable", default: none)

    let new-body = if slack > 0.1pt and type(body) == content and body.has("children") {
      let kids = body.children.map(ch => {
        if type(ch) == content and ch.func() == metadata {
          if ch.value == "floe-footer" {
            v(slack)
          } else if ch.value == "floe-stretch-center" {
            v(slack / 2)
          } else {
            ch
          }
        } else {
          ch
        }
      })
      kids.join()
    } else {
      body
    }
    block(height: h, breakable: false, ..f, new-body)
  } else {
    block(width: 100%, height: h, breakable: false, c)
  }
}

/// Parent-driven Equal-Height Row Grid
/// Automatically ensures all children in the same row grow to match the height
/// of the tallest sibling in that row without per-child configuration, and renders
/// all rows in a single unified grid so row-gutter and column-gutter match exactly.
#let equal-grid(
  columns: (1fr, 1fr),
  gutter: 8pt,
  above: 8pt,
  below: 8pt,
  ..items,
) = {
  let pos = items.pos()
  if pos.len() == 0 { return none }

  let col-specs = if type(columns) == int {
    (1fr,) * columns
  } else if type(columns) == array and columns.len() > 0 {
    columns
  } else {
    (1fr,)
  }
  let ncols = col-specs.len()

  block(
    width: 100%,
    above: above,
    below: below,
    breakable: true,
  )[
    #layout(size => {
      let avail-w = size.width - gutter * (ncols - 1)
      let weights = col-specs.map(c => if type(c) == fraction { c / 1fr } else { 1.0 })
      let total-w = weights.sum()
      let col-widths = weights.map(w => avail-w * (w / total-w))

      let rows = ()
      let curr = ()
      for it in pos {
        curr.push(it)
        if curr.len() == ncols {
          rows.push(curr)
          curr = ()
        }
      }
      if curr.len() > 0 {
        rows.push(curr)
      }

      context {
        let all-cells = ()
        for r in rows {
          let measured = r.enumerate().map(((j, c)) => {
            let cw = col-widths.at(j)
            let clean-c = if type(c) == content and c.func() == block {
              let f = c.fields()
              let b = f.remove("body", default: none)
              let _ = f.remove("height", default: none)
              let _ = f.remove("above", default: none)
              let _ = f.remove("below", default: none)
              block(..f, b)
            } else {
              c
            }
            measure(block(width: cw, clean-c))
          })
          let max-h = calc.max(..measured.map(m => m.height))
          for (j, c) in r.enumerate() {
            all-cells.push(stretch-cell(c, max-h, slack: max-h - measured.at(j).height))
          }
        }
        grid(
          columns: col-specs,
          column-gutter: gutter,
          row-gutter: gutter,
          ..all-cells,
        )
      }
    })
  ]
}
