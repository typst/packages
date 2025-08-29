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
    if arr.last()  in ([], [ ], parbreak(), linebreak()) {
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
  let skip-cells = (:)  // Track cells that should be skipped

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
      while k < cols and body-2d.at(i).at(k) in ([], [ ], [<]) {
        colspan += 1
        k += 1
      }

      // Check for vertical merge
      let rowspan = 1
      let m = i + 1
      while m < rows and body-2d.at(m).at(j) in ([], [ ], [^]) {
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
    if row.at(i) in ([], [ ], [<]) {
      let span = 1
      let j = i + 1
      while j < count and j < row.len() and row.at(j) in ([], [ ], [<]) {
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

#let tablem(
  render: table,
  ignore-second-row: true,
  use-table-header: true,
  ..args,
  body,
) = {
  let arr = _tablem-compose(_tablem-tokenize(body))
  // use the count of first row as columns
  let columns = 0
  for item in arr {
    if item == [ ] {
      break
    }
    columns += 1
  }
  // split rows with [ ]
  let res = ()
  let count = 0
  for item in arr {
    if count < columns {
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
  let table-header = res.slice(0, calc.min(columns, len))
  let table-body = if ignore-second-row {
    // remove secound row
    res.slice(calc.min(2 * columns, len))
  } else {
    res.slice(calc.min(columns, len))
  }
  
  // Process both header and body
  let header-2d = _to-2d-array(table-header, columns)
  let processed-header = _process-merged-cells(header-2d)
  
  let body-2d = _to-2d-array(table-body, columns)
  let processed-body = _process-merged-cells(body-2d)
  
  if use-table-header {
    render(columns: columns, ..args, table.header(..processed-header), ..processed-body)
  } else {
    render(columns: columns, ..args, ..processed-header, ..processed-body)
  }
}

#let three-line-table = tablem.with(
  render: (columns: auto, ..args) => {
    table(
      columns: columns,
      stroke: none,
      align: center + horizon,
      table.hline(y: 0),
      table.hline(y: 1, stroke: .5pt),
      ..args,
      table.hline(),
    )
  },
)
