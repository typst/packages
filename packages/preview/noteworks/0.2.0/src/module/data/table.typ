// =====================================================
// TABLE - Table objects and rendering
// =====================================================
// Object constructors return dictionaries, rendering is separate

#import "../../core/setup.typ": *

// =====================================================
// OBJECT CONSTRUCTORS
// =====================================================

/// Creates a table-data object
/// - headers: Array of column headers
/// - data: Array of rows (each row is an array of cells)
/// - style: Optional style overrides (header-fill, row-fill, stroke-color, align-cols)
#let table-data(
  headers,
  data,
  horizontal: false,
  style: (:),
) = (
  type: "table-data",
  headers: headers,
  data: data,
  horizontal: horizontal,
  style: style,
)

/// Creates a value-table object (for function values)
/// - variable: Variable name (e.g. $x$)
/// - func: Function name (e.g. $f(x)$)
/// - values: Array of input values
/// - results: Array of output values
#let value-table-data(
  variable,
  func,
  values,
  results,
  horizontal: false,
  style: (:),
) = table-data(
  (variable, func),
  values.zip(results),
  horizontal: horizontal,
  style: style,
)

/// Creates a grid-table object (for matrices)
/// - data: 2D array of cells
/// - show-indices: Whether to show column indices as headers
#let grid-data(
  data,
  show-indices: false,
  horizontal: false,
  style: (:),
) = (
  type: "grid-data",
  data: data,
  show-indices: show-indices,
  horizontal: horizontal,
  style: style,
)

// =====================================================
// RENDERING FUNCTIONS
// =====================================================

/// Renders a table-data object
/// - horizontal: If true, renders table horizontally (headers as first column)
#let render-table(obj, theme) = {
  let headers = obj.headers
  let data = obj.data
  let horizontal = obj.horizontal
  let style = obj.style

  let header-fill = style.at("header-fill", default: theme.blocks.theorem.fill)
  let stroke-color = style.at("stroke-color", default: theme.blocks.theorem.stroke.transparentize(50%))
  let row-fill = style.at("row-fill", default: (theme.page-fill, theme.blocks.definition.fill.transparentize(50%)))

  align(center)[
    #if horizontal {
      // Horizontal layout: headers as first column, data rows as columns
      let num-data-rows = data.len()
      let num-cols = num-data-rows + 1 // +1 for header column

      let align-cols = style.at("align-cols", default: (center,) * headers.len())

      table(
        columns: (auto,) * num-cols,
        align: (col, row) => {
          if row == 0 or col == 0 {
            center
          } else {
            // row > 0 and col > 0: use alignment from original column (row - 1)
            align-cols.at(calc.min(row - 1, align-cols.len() - 1))
          }
        },
        fill: (col, row) => {
          if col == 0 {
            header-fill
          } else {
            row-fill.at(calc.rem(col, row-fill.len()))
          }
        },
        stroke: (x, y) => {
          if x == 0 {
            (right: 2pt + stroke-color, rest: 1pt + stroke-color)
          } else if x == 1 {
            (left: 2pt + stroke-color, rest: 1pt + stroke-color)
          } else {
            1pt + stroke-color
          }
        },
        inset: 10pt,

        ..range(headers.len())
          .map(header-col => {
            let header-cell = text(
              fill: theme.text-heading,
              weight: "bold",
              size: 11pt,
              font: theme.at("title-font", default: "IBM Plex Serif"),
            )[#headers.at(header-col)]
            let data-cells = range(num-data-rows).map(row => text(
              fill: theme.text-main,
              size: 10pt,
            )[#data.at(row).at(header-col)])
            (header-cell,) + data-cells
          })
          .flatten(),
      )
    } else {
      // Vertical layout: normal table
      let num-cols = headers.len()
      let align-cols = style.at("align-cols", default: (center,) * num-cols)

      table(
        columns: (auto,) * num-cols,
        align: (col, row) => {
          if row == 0 { center } else { align-cols.at(calc.min(col, align-cols.len() - 1)) }
        },
        fill: (col, row) => {
          if row == 0 {
            header-fill
          } else {
            row-fill.at(calc.rem(row - 1, row-fill.len()))
          }
        },
        stroke: (x, y) => {
          if y == 0 {
            (bottom: 2pt + stroke-color, rest: 1pt + stroke-color)
          } else if y == 1 {
            (top: 2pt + stroke-color, rest: 1pt + stroke-color)
          } else {
            1pt + stroke-color
          }
        },
        inset: 10pt,

        // Header row
        ..headers.map(h => text(
          fill: theme.text-heading,
          weight: "bold",
          size: 11pt,
          font: theme.at("title-font", default: "IBM Plex Serif"),
        )[#h]),

        // Data rows
        ..data
          .flatten()
          .map(cell => text(
            fill: theme.text-main,
            size: 10pt,
          )[#cell]),
      )
    }
  ]
}

/// Renders a grid-data object
/// - horizontal: If true, renders table horizontally (transposes the grid)
#let render-grid(obj, theme) = {
  let data = obj.data
  let show-indices = obj.show-indices
  let horizontal = obj.horizontal
  let style = obj.style

  if show-indices {
    let num-cols = if data.len() > 0 { data.at(0).len() } else { 0 }
    let headers = range(num-cols).map(i => str(i))
    render-table(table-data(headers, data, horizontal: horizontal, style: style), theme)
  } else {
    let stroke-color = style.at("stroke-color", default: theme.blocks.theorem.stroke.transparentize(50%))
    let row-fill = style.at("row-fill", default: (theme.page-fill, theme.blocks.definition.fill.transparentize(50%)))

    align(center)[
      #if horizontal {
        // Horizontal layout: transpose the grid
        let num-rows = data.len()
        let num-cols = if data.len() > 0 { data.at(0).len() } else { 0 }

        table(
          columns: (auto,) * num-rows,
          align: center,
          fill: (col, row) => row-fill.at(calc.rem(col, row-fill.len())),
          stroke: 1pt + stroke-color,
          inset: 10pt,
          ..range(num-cols)
            .map(col => range(num-rows).map(row => text(
              fill: theme.text-main,
              size: 10pt,
            )[#data.at(row).at(col)]))
            .flatten(),
        )
      } else {
        // Vertical layout: normal grid
        let num-cols = if data.len() > 0 { data.at(0).len() } else { 0 }

        table(
          columns: (auto,) * num-cols,
          align: center,
          fill: (col, row) => row-fill.at(calc.rem(row, row-fill.len())),
          stroke: 1pt + stroke-color,
          inset: 10pt,
          ..data
            .flatten()
            .map(cell => text(
              fill: theme.text-main,
              size: 10pt,
            )[#cell]),
        )
      }
    ]
  }
}
