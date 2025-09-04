// convert a sequence to a array splited by "|"
#let _tablem-tokenize(seq) = {
  let res = ()
  for cont in seq.children {
    if cont.func() == text {
      res = res + cont.text.split("|").map(s => text(s.trim())).intersperse([|]).filter(it => it.text != "")
    } else {
      res.push(cont)
    }
  }
  res
}

// trim first or last empty space content from array
#let _arr-trim(arr) = {
  if arr.len() >= 2 {
    if arr.first() in ([], [ ], parbreak(), linebreak()) {
      arr = arr.slice(1)
    }
    if arr.last() in ([], [ ], parbreak(), linebreak()) {
      arr = arr.slice(0, -1)
    }
    arr
  } else {
    arr
  }
}

// compose table cells
#let _tablem-compose(arr) = {
  let res = ()
  let column-num = 0
  res = arr.split([|]).map(_arr-trim).map(subarr => subarr.sum(default: []))
  _arr-trim(res)
}

// Recognize table separators
// | --- | -> auto
// | :--- | -> left
// | :---: | -> center
// | ---: | -> right
// not a separator -> none
#let _tablem-recognize-separators(seq) = {
  let arr = if seq.has("children") {
    seq.children
  } else {
    (seq,)
  }
  if arr.len() == 0 { return none }
  if arr.len() == 1 {
    return if arr.at(0) in ([-], [--], [---]) { auto } else { none }
  }
  if arr.len() == 2 and arr.at(0) == [:] and arr.at(1) == [:] {
    return none
  }
  for i in range(1, arr.len() - 1) {
    if arr.at(i) not in ([-], [--], [---]) {
      return none
    }
  }
  if arr.at(0) not in ([:], [-], [--], [---]) {
    return none
  }
  if arr.at(-1) not in ([:], [-], [--], [---]) {
    return none
  }
  if arr.at(0) == [:] and arr.at(-1) == [:] {
    return center
  } else if arr.at(0) == [:] {
    return left
  } else if arr.at(-1) == [:] {
    return right
  } else {
    return auto
  }
}

// Convert 1D array to 2D array
#let _to-2d-array(arr, columns) = {
  let result = ()
  let row = ()
  for (i, cell) in arr.enumerate() {
    row.push(cell)
    if calc.rem(i + 1, columns) == 0 {
      result.push(row)
      row = ()
    }
  }
  result
}

// Process merged cells in both directions
#let _process-merged-cells(body-2d) = {
  let rows = body-2d.len()
  let cols = if rows > 0 { body-2d.at(0).len() } else { 0 }
  let merged = ()
  let skip-cells = (:) // Track cells that should be skipped

  // Scan the table
  for i in range(rows) {
    let row = ()
    let j = 0
    while j < cols {
      if skip-cells.at(str(i) + "," + str(j), default: false) {
        j += 1
        continue
      }

      // Check for horizontal merge
      let colspan = 1
      let k = j + 1
      while k < cols and body-2d.at(i).at(k) == [<] {
        colspan += 1
        k += 1
      }

      // Check for vertical merge
      let rowspan = 1
      let m = i + 1
      while m < rows and body-2d.at(m).at(j) == [^] {
        rowspan += 1
        m += 1
      }

      // Handle merged cell
      if colspan > 1 or rowspan > 1 {
        let content = body-2d.at(i).at(j)

        // Mark cells to skip
        for r in range(i, i + rowspan) {
          for c in range(j, j + colspan) {
            if r != i or c != j {
              skip-cells.insert(str(r) + "," + str(c), true)
            }
          }
        }

        if colspan > 1 and rowspan > 1 {
          row.push(table.cell(colspan: colspan, rowspan: rowspan, content))
        } else if colspan > 1 {
          row.push(table.cell(colspan: colspan, content))
        } else {
          row.push(table.cell(rowspan: rowspan, content))
        }
        j = k
      } else {
        row.push(body-2d.at(i).at(j))
        j += 1
      }
    }
    merged.push(row)
  }
  merged.flatten()
}

// merge cells in a row
#let _merge-cells(row, start, count) = {
  let merged = ()
  let i = 0
  while i < count {
    if i >= row.len() { break }
    if row.at(i) == [<] {
      let span = 1
      let j = i + 1
      while j < count and j < row.len() and row.at(j) == [<] {
        span += 1
        j += 1
      }
      if j < count and j < row.len() {
        merged.push(table.cell(colspan: span + 1, row.at(j)))
        i = j + 1
      } else {
        i = j
      }
    } else {
      merged.push(row.at(i))
      i += 1
    }
  }
  merged
}

#let _process-table-body(body, columns) = {
  let processed = ()
  let row = ()
  for (i, cell) in body.enumerate() {
    row.push(cell)
    if calc.rem(i + 1, columns) == 0 {
      processed += _merge-cells(row, 0, columns)
      row = ()
    }
  }
  processed
}

#let _update_align(align, default: left + top) = {
  if align == auto {
    return default
  } else if type(align) == alignment {
    if align.x == none {
      return align + default.x
    } else if align.y == none {
      return align + default.y
    } else {
      return align
    }
  } else if type(align) == array {
    return align.map(it => _update_align(it, default: default))
  }
}

/// Markdown-style tables for Typst.
///
/// Arguments:
/// - render (function): Custom render function, defaults to Typst's `table`. Receives an integer-type `columns` (the count of the first row), `..args` (combining `tablem`'s `args` and the generated children from `body`).
/// - columns (auto | int | relative | fraction | array): Optional column sizes. Specify a track size array or an integer for that many auto-sized columns. Unlike rows/gutters, a single track size creates only one column.
/// - align (auto | array | alignment | function): Optional alignment. Can be a single alignment, an array (per column), or a function receiving column and row indices (starting from zero). If `auto`, the outer alignment is used.
/// - args: Additional arguments passed to the `render` function.
/// - body: The markdown-like table content. There should be no extra line breaks in it.
//
/// `tablem` lets you write tables using familiar markdown syntax, with support for cell merging and custom rendering.
///
/// Tables are used to arrange content in cells. Cells can contain arbitrary content, including multiple paragraphs, and are specified in row-major order.
///
/// Features:
/// - Write tables using `|`-delimited markdown-like syntax.
/// - Automatic detection of header rows and column alignment (left, center, right, auto).
/// - Merge cells horizontally with `<` and vertically with `^`.
/// - Pass any arguments supported by Typst's built-in `table`.
/// - Use a custom render function for advanced styling.
///
/// Example usage:
/// ```typ
/// #import "@preview/tablem:0.3.0": tablem, three-line-table
///
/// #tablem[
///   | *Name* | *Location* | *Height* | *Score* |
///   | ------ | ---------- | -------- | ------- |
///   | John   | Second St. | 180 cm   | 5       |
///   | Wally  | Third Av.  | 160 cm   | 10      |
/// ]
///
/// #three-line-table[
///   | *Name* | *Location* | *Height* | *Score* |
///   | :----: | :--------: | :------: | :-----: |
///   | John   | Second St. | 180 cm   | 5       |
///   | Wally  | Third Av.  | 160 cm   | 10      |
/// ]
/// ```
///
/// Cell merging:
/// Merge cells horizontally with `<` and vertically with `^`.
/// ```typ
/// #three-line-table[
///   | Substance             | Subcritical °C | Supercritical °C |
///   | --------------------- | -------------- | ---------------- |
///   | Hydrochloric Acid     | 12.0           | 92.1             |
///   | Sodium Myreth Sulfate | 16.6           | 104              |
///   | Potassium Hydroxide   | 24.7           | <                |
/// ]
/// ```
///
/// Custom rendering:
/// You can define a custom render function for advanced styling:
/// ```typ
/// #let three-line-table = tablem.with(render: (columns: auto, align: auto, ..args) => {
///   table(
///     columns: columns,
///     stroke: none,
///     align: center + horizon,
///     table.hline(y: 0),
///     table.hline(y: 1, stroke: .5pt),
///     ..args,
///     table.hline(),
///   )
/// })
/// ```
///
/// Much like with grids, you can use `table.cell` to customize the appearance and the position of each cell.
#let tablem(
  render: table,
  columns: auto,
  align: auto,
  ..args,
  body,
) = {
  let arr = _tablem-compose(_tablem-tokenize(body))
  // use the count of first row as columns
  let column-len = 0
  if type(columns) == array {
    column-len = columns.len()
  } else if type(columns) == int {
    column-len = columns
  } else {
    for item in arr {
      if item == [ ] {
        break
      }
      column-len += 1
    }
  }
  let final-columns = if type(columns) in (array, int) {
    columns
  } else if columns == auto {
    column-len
  } else {
    column-len * (columns,)
  }
  // split rows with [ ]
  let res = ()
  let count = 0
  for item in arr {
    if count < column-len {
      res.push(item)
      count += 1
    } else {
      assert.eq(
        item,
        [ ],
        message: "There should be a linebreak. Or, instead of using empty cells in table header, just use the empty string `| #\" \" |`  in table header instead.",
      )
      count = 0
    }
  }
  let len = res.len()
  let table-separators = res.slice(column-len, calc.min(2 * column-len, len)).map(_tablem-recognize-separators)
  let use-table-header = table-separators.len() == column-len and table-separators.all(it => it != none)
  if use-table-header {
    let aligns = table-separators
    if type(align) == alignment {
      aligns = _update_align(aligns, default: align)
    }
    let final-align = if align == auto {
      if table-separators.all(it => it == auto) {
        (:)
      } else {
        (align: aligns)
      }
    } else if type(align) == alignment {
      if table-separators.all(it => it == auto) {
        (align: align)
      } else {
        (align: aligns)
      }
    } else {
      (align: align)
    }

    let table-header = res.slice(0, calc.min(column-len, len))
    let table-body = res.slice(calc.min(2 * column-len, len))

    // Process both header and body
    let header-2d = _to-2d-array(table-header, column-len)
    let processed-header = _process-merged-cells(header-2d)

    let body-2d = _to-2d-array(table-body, column-len)
    let processed-body = _process-merged-cells(body-2d)

    return render(columns: final-columns, ..final-align, ..args, table.header(..processed-header), ..processed-body)
  } else {
    let table-body = res
    let body-2d = _to-2d-array(table-body, column-len)
    let processed-body = _process-merged-cells(body-2d)

    if align != auto {
      return render(columns: final-columns, align: align, ..args, ..processed-body)
    } else {
      return render(columns: final-columns, ..args, ..processed-body)
    }
  }
}

#let three-line-table = tablem.with(render: (columns: auto, align: center + horizon, ..args) => {
  align = _update_align(align, default: center + horizon)
  table(
    columns: columns,
    stroke: none,
    align: align,
    table.hline(y: 0),
    table.hline(y: 1, stroke: .5pt),
    ..args,
    table.hline(),
  )
})
