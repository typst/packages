#import "@preview/elembic:1.1.1"as e
#import "typing.typ": primary-gutter, secondary-gutter
#import "utils.typ": (
  arbitrary-pos-arg-parser,
  reflow,
  resolve-gutter1,
  resolve-gutter2,
)
#import "item.typ": resolve-item
#import "transform.typ": rescale

#let matrix = e.element.declare(
  "matrix",
  prefix: "tesselate.masonry",
  fields: (
    e.field(
      "children",
      e.types.array(content),
      named: false,
      default: (),
    ),
    e.field(
      "columns",
      e.types.smart(e.types.union(int, e.types.array(fraction))),
      default: 1,
      named: true,
    ),
    e.field(
      "rows",
      e.types.smart(e.types.union(int, e.types.array(fraction))),
      default: auto,
      named: true,
    ),
    e.field(
      "flow",
      e.types.array(direction),
      default: (ltr, ttb),
      named: true,
      folds: false,
    ),
    e.field(
      "gutter",
      length,
      default: 0pt,
      named: true,
    ),
    e.field(
      "row-gutter",
      primary-gutter,
      default: auto,
      named: true,
    ),
    e.field(
      "column-gutter",
      primary-gutter,
      default: auto,
      named: true,
    ),
  ),
  allow-unknown-fields: true,
  parse-args: arbitrary-pos-arg-parser,
  display: el => {
    let (
      children,
      rows,
      columns: cols,
      flow,
      gutter,
      row-gutter,
      column-gutter,
    ) = e.fields(el)
    let n-items = children.len()

    // convert row / column number to repeating `1fr`s
    if type(rows) == int {
      rows = (1fr,) * rows
    }
    if type(cols) == int {
      cols = (1fr,) * cols
    }

    // regularize parameters
    // calculate number of rows and columns
    // pad or trim `children` to desired number of cells
    let n-rows
    let n-cols
    let n-cells

    if rows == auto {
      if columns == auto {
        n-rows = n-items
        n-cols = 1
        rows = (1fr,) * n-items
        cols = (1fr,)
        n-cells = n-rows * n-cols
      } else {
        n-cols = cols.len()
        n-rows = cdiv(n-items, n-cols)
        rows = (1fr,) * n-rows
        // pad with empty grids
        n-cells = n-rows * n-cols
        children += ([],) * (n-cells - n-items)
      }
    } else if cols == auto {
      n-rows = rows.len()
      n-cols = cdiv(n-items, n-rows)
      cols = (1fr,) * n-cols
      // pad with empty grids
      n-cells = n-rows * n-cols
      children += ([],) * (n-cells - n-items)
    } else {
      n-rows = rows.len()
      n-cols = cols.len()
      n-cells = n-rows * n-cols
      if n-cells < n-items {
        // remove residual cells
        children = children.slice(0, n-cells)
      } else if n-cells > n-items {
        // pad with empty grids
        children += ([],) * (n-cells - n-items)
      }
    }

    children = reflow(
      children
        .map(resolve-item)
        .chunks(n-cols),
      flow: flow
    ).join()

    let (
      gutter: row-gutter,
      sum: row-gutter-sum,
    ) = resolve-gutter1(
      gutter: row-gutter,
      default-gutter: gutter,
      n: n-rows,
    )
    let (
      gutter: column-gutter,
      sum: column-gutter-sum,
    ) = resolve-gutter1(
      gutter: column-gutter,
      default-gutter: gutter,
      n: n-cols,
    )
    let column-fraction-sum = cols.sum(default: 0fr)
    let row-fraction-sum = rows.sum(default: 0fr)

    layout(((width,)) => {
      let fr = (width - column-gutter-sum) / (column-fraction-sum / 1fr)
      let height = fr * (row-fraction-sum / 1fr) + row-gutter-sum
      block(
        grid(
          ..children.map(
            item => {
              let fields = e.fields(item)
              let body = fields.remove("body")
              if "aspect-ratio" in fields {
                fields.remove("aspect-ratio")
              }
              if body.func() == image {
                return layout(((width, height)) => {
                  rescale(body, width: width, height: height, ..fields)
                })
              } else {
                return body
              }
            }
          ),
          // ..args,
          rows: rows,
          columns: cols,
          row-gutter: row-gutter,
          column-gutter: column-gutter,
        ),
        width: 100%,
        height: height,
      )
    })
  },
)