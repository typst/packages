
/////////////// 
// Utilities for internal use
/////////////// 

#let is-type(x, ..type-arg) = {
  if type-arg.pos().len() > 0 {
    type(x) == "dictionary" and "_type_" in x and x._type_ == type-arg.pos().at(0)
  } else {
    type(x) == "dictionary" and "_type_" in x
  }
} 

#let remove(d, keys) = {
  for k in keys {
    if k in d {
      let _ = d.remove(k)
    }
  }
  d
}

#let to-text(x) = {
  if type(x) == "string" {
    return x
  }
  if type(x) == content and "text" in x.fields() {
    return x.text
  }
  return none
}

/////////////// 
// Conversion back and forth between table arguments and a matrix
///////////////

#let table-to-matrix(a, ncols) = {
  let matrix = ((ncols * ((body: none),)),)
  let lines = ()
  let current-row-spans = (ncols * (0,))
  let row = 0   // row counter
  let col = 0   // column counter
  let header-rows = 0
  for (k, val) in a.enumerate() {
    if type(val) == content and val.func() == table.header {
      (matrix, lines, _) = table-to-matrix(val.fields().children, ncols)
      header-rows = matrix.len()
      row = row + header-rows
      col = 0
      matrix.push((ncols * ((body: none),)),)
      continue
    }
    if type(val) == content and val.func() == table.hline {
      let flds = val.fields()
      if not "y" in flds {
        flds.y = row 
      }
      lines.push((_type_: "hline") + flds)
      continue
    }
    if is-type(val, "hline") or is-type(val, "header-hline") {
      lines.push(val)
      continue
    }
    if type(val) == content and val.func() == table.vline {
      let flds = val.fields()
      if not "x" in flds {
        flds.x = row 
      }
      lines.push((_type_: "vline") + flds)
      continue
    }
    assert(col <= ncols, message: "Column too long with colspans given.")
    if col == ncols {
      row = row + 1
      col = 0
      matrix.push((ncols * ((body: none),)),)
      current-row-spans = current-row-spans.map(x => x - 1)
    }
    while col < ncols and current-row-spans.at(col) > 0 {   // skip over prior rowspans
      col = col + 1
    }
    if col == ncols { continue }
    if type(val) == content and val.func() == table.cell {
      let cs = val.at("colspan", default: 1)
      let rs = val.at("rowspan", default: 1)
      assert(col + cs <= ncols, message: "Colspan overflows table at ")
      for icol in range(col, col + cs) {
        current-row-spans.at(icol) = rs
      }
      matrix.at(row).at(col).body = val.body
      let fields = val.fields()
      let _ = fields.remove("body")
      matrix.at(row).at(col).cell-fields = fields
      // matrix.at(row).at(col) = (xx, current-row-spans, rs, cs, row,col,val)
      col = col + cs
    } else {
      matrix.at(row).at(col).body = val
      col = col + 1
    }
  }
  (matrix, lines, header-rows)
} 

#let matrix-to-table(matrix, header-rows) = {
  let a = ()
  let row = 0
  let header = ()
  while row < header-rows {
    for (col, el) in matrix.at(row).enumerate() {
      if el.body != none {
        let x = table.cell(el.body, ..el.at("cell-fields", default: (:)))
        header.push(x)
      }
    }
    row = row + 1
  }
  while row < matrix.len() {
    for (col, el) in matrix.at(row).enumerate() {
      if el.body != none {
        let x = table.cell(el.body, ..el.at("cell-fields", default: (:)))
        a.push(x)
      }
    }
    row = row + 1
  }
  return (a, header)
}

/////////////// 
// Convert row/column indicators to integer positions or ranges
///////////////

#let expand-position(x, rng, extras: (:)) = {
  let max = rng.at(rng.len() - 1)
  if type(x) == "integer" {
    if x >= 0 {
      return (rng.at(x),)
    } else {
      return (rng.at(rng.len() + x),)
    }
  }
  if x == end {
    return (max,)
  }
  if x == auto {
    return rng
  }
  if type(x) == "function" {
    return rng.filter(x)
  }
  if is-type(x, "span") {
    return range(expand-position(x.start, rng, extras: extras).at(0), 1 + expand-position(x.stop, rng, extras: extras).at(0), step: x.step)
  }
  if type(x) == array {
    let result = ()
    for el in x {
      result.push(expand-position(el, rng, extras: extras).at(0))  
    }
    return result
  }
  for (k, f) in extras {
    if k == x {
      return f(x)
    }
  }
  assert(false, message: "Unsupported table position: " + repr(x))
}

#let expand-positions(x, row-range, col-range, header-rows) = {
  let result = ()
  for (row, col) in x {
    for irow in expand-position(row, row-range) {
      for icol in expand-position(col, col-range) {
        result.push((irow, icol))
      }
    }
  }
  return result
}

#let expand-positions-by-col(x, row-range, col-range, header-rows) = {
  let result = ()
  for (row, col) in x {
    for icol in expand-position(col, col-range) {
      let col-pairs = ()
      for irow in expand-position(row, row-range) {
        col-pairs.push((irow, icol))
      }
      result.push(col-pairs)
    }
  }
  return result
}
/////////////// 
// tblr -- main function
///////////////

// Main wrapper for tables that support several helper functions.
//
// Returns a Typst `table`.
//
// Normal table arguments like `columns`, `fill`, `gutter`,
// `table.hline`, and cell contents are passed to the `table` function.
//
// Other arguments can be special directives to control formatting.
// These include `cells()`, `cols()`, `rows()`, ...
// 
// Named arguments specific to `tblr` include:
// `header-rows` (default: auto): Number of header rows in the content.
// `remarks`: Content to include as a comment below the table.
// `caption`: If provided, wrap the `table` in a `figure`.
// `placement` (default: `auto`): Passed to figure.
// `table-fun` (default: `table`): Specifies the table-creation function to use.

#let tblr(header-rows: auto, 
          caption: none, 
          placement: auto, 
          remarks: none, 
          table-fun: table,
          ..args) = {
  let a = args.pos()
  let n = args.named()
  assert("columns" in n, message: "Must supply a `columns` argument")
  let ncols = if type(n.columns) == int {
    n.columns 
  } else {
    n.columns.len()
  }
  // split `a` into content and specs
  let content = ()
  let specs = ()
  for el in a {
    if is-type(el, "cells") or is-type(el, "apply") {
      specs.push(el)
    } else {
      content.push(el)
    }
  }
  let (matrix, lines, header-rows-in-content) = table-to-matrix(content, ncols)
  if header-rows == auto {
    header-rows = header-rows-in-content
  }
  let nrows = matrix.len()
  // process cell-level specs
  for s in specs.rev() {
    if is-type(s, "cells") {
      let positions = if s.within == "header" {
        expand-positions(s.cells, range(header-rows), range(ncols), 0)
      } else if s.within == "body" {
        expand-positions(s.cells, range(header-rows, nrows), range(ncols), 0)
      } else {
        expand-positions(s.cells, range(nrows), range(ncols), header-rows)
      }
      
      for (row, col) in positions {
        if "sets" in s {
          let (f, v) = s.sets
          matrix.at(row).at(col).body = {set f(..v); matrix.at(row).at(col).body}
        }
        if "hooks" in s {
          if type(s.hooks) == function {
            matrix.at(row).at(col).body = (s.hooks)(matrix.at(row).at(col).body)
          } else if type(s.hooks) == array {
            for f in s.hooks.rev() {
              matrix.at(row).at(col).body = f(matrix.at(row).at(col).body)
            }
          }
        }
        matrix.at(row).at(col).cell-fields = remove(s, ("cells", "sets", "hooks", "within", "_type_")) + matrix.at(row).at(col).at("cell-fields", default: (:))  
        let cs = matrix.at(row).at(col).at("cell-fields", default: (:)).at("colspan", default: 1)
        for i in range(col + 1, col + cs) {
          matrix.at(row).at(i).body = none
        }
        let rs = matrix.at(row).at(col).at("cell-fields", default: (:)).at("rowspan", default: 1)
        for i in range(row + 1, row + rs) {
          matrix.at(i).at(col).body = none
        }
      }
    }
    if is-type(s, "apply") {
      let col-positions = if s.within == "body" {
        expand-positions-by-col(s.cells, range(header-rows, nrows), range(ncols), 0)
      } else {
        expand-positions-by-col(s.cells, range(nrows), range(ncols), header-rows)
      }
      for posv in col-positions {
        // read
        let vec = (none,) * posv.len()
        for (i, (row,col)) in posv.enumerate() {
          vec.at(i) = matrix.at(row).at(col).body
        }
        vec = (s.fun)(vec)
        // write
        for (i, (row,col)) in posv.enumerate() {
          matrix.at(row).at(col).body = vec.at(i)
        }
      }
    }
  }
  // process lines
  let row-map = range(nrows)
  let line-output = ()
  for l in lines {
    if is-type(l, "hline") {
      if l.within == "header" {
        l.y = expand-position(l.y, range(header-rows)).at(0)
      } else {
        l.y = expand-position(l.y, range(nrows)).at(0)
      }
      l = remove(l, ("_type_", "within"))
      line-output.push(table.hline(..l))
    }
    if is-type(l, "vline") {
      line-output.push(table.vline(..remove(l, ("_type_",))))
    }
  }
  // return matrix
  // convert back to a table
  let (t, h) = matrix-to-table(matrix, header-rows)
  t = if h.len() > 0 {
    table-fun(..n, ..line-output, table.header(..h), ..t)
  } else {
    table-fun(..n, ..line-output, ..t)
  }
  if remarks != none {
    t = context block([#t #align(left,remarks)], width: measure(t).width)
  }
  if caption != none {
    t = figure(caption: caption, placement: placement, t, kind: table)
  }
  return t
}

/////////////// 
// Helper functions for users
///////////////

// Like `range` but lazy and can include indicators like `end`.
#let span(..args, step: 1) = {
  let pargs = args.pos()
  if pargs.len() == 2 {
    return (_type_: "span", start: pargs.at(0), stop: pargs.at(1), step: step)
  } else {
    return (_type_: "span", start: 0, stop: pargs.at(0), step: step)
  }
}  

// Directive to control formatting of cells.
// Positional arguments can be one or more row and column indicators or special types. 
// 
// Each indicator is specified by `(row,col)` array pair.
// Each `row` and `col` can be an integer or array of integers or indicators.
// 
// Accepted indicators include:
// * Positive integers -- normal row/column indicators starting at 0.
// * `end` -- the last row or column.
// * `auto` -- all rows or columns.
// * Negative integers -- indexing from the end; -1 is the last row/column.
// * `span(to)` or `span(from, to)` -- ranges of rows or columns.
// 
// Named arguments are passed to cells. These include normal arguments like `fill` and `colspan`.
// 
// Special arguments include directives that specify further processing. These include:
// `hooks` -- apply the given function to the cell contents.
// `sets` -- a list of `set` options to apply for that cell.
// `within` -- apply row ranges to "header" or "body" if supplied
//
#let cells(..args, within: auto) = {
  (_type_: "cells", within: within) + args.named() + (cells: args.pos())
}  

// Directive to control formatting of columns.
// Normal positional arguments are an array of column indicators.
#let cols(..args) = {
  cells(..args.named(), ..args.pos().map(x => (auto, x)))
}  

// Directive to control formatting of rows.
// Normal positional arguments are an array of column indicators.
#let rows(..args) = {
  cells(..args.named(), ..args.pos().map(x => (x, auto)))
}  

// Like `table.hline` but lazy and can include indicators like `end`.
#let hline(y: none, within: auto, ..args) = {
  (_type_: "hline", within: within, ..((y: y,) + args.named()))
}  

// Like `table.vline` but lazy and can include indicators like `end`.
#let vline(x: none, ..args) = {
  (_type_: "vline", ..((x: x,) + args.named()))
}  

// Reserved for the future.
#let note(row, col, content) = {
}  

// Apply `fun` columnwise to cells provided.
#let apply(..cells, fun, within: none) = {
  (_type_: "apply", cells: cells.pos(), fun: fun, within: within)
}

// Like `apply`, but normal positional arguments are columns.
#let col-apply(..args, fun) = {
  apply(..args.named(), ..args.pos().map(x => (auto, x)), fun)
}

/////////////// 
// Decimal alignment
/////////////// 

// For an array `a`, return an array with contents aligned. Rules mostly
// follow tbl (https://typst.app/universe/package/tbl/):
// - One position after the leftmost occurrence of the non-printing
//   input token `marker` (default: `&`), if any is present.
// - Otherwise, the rightmost occurrence of the `decimal`. Defaults to
//   `.` just before a digit.
// - Otherwise, the rightmost digit.
// -  Otherwise, the content is aligned using `other-align` (default: `center`).
// NOTE: needs to be used in a context.
#let decimal-align(a, decimal: regex("\.\d"), marker: "&", other-align: center) = {
  let result = ()
  let max1 = 0pt
  let max2 = 0pt
  for x in a {
    let xt = to-text(x)
    let xs = ()
    if xt == none {
      result.push((align(other-align, x), none))
      continue
    } else if xt.contains(marker) {     // first marker location
      let p = xt.position(marker)
      xs = (xt.slice(0,p), xt.slice(p + marker.len(), xt.len())) 
    } else if xt.contains(decimal) {    // last decimal location
      let p = xt.matches(decimal).map(x => x.start).reduce((a,b) => calc.max(a,b))
      xs = (xt.slice(0,p), xt.slice(p, xt.len())) 
    } else if xt.contains(regex("\d")) { // last digit
      let p = xt.matches(regex("\d")).map(x => x.start).reduce((a,b) => calc.max(a,b))
      xs = (xt.slice(0,p + 1), xt.slice(p + 1, xt.len())) 
    } else {    // nothing to align so center it
      result.push((align(other-align, x), none))
      continue
    }
    if xs.len() == 1 {
      xs.push("")
    }
    let xw1 = measure(xs.at(0)).width
    if xw1 > max1 {
      max1 = xw1
    }
    let xw2 = measure(xs.at(1)).width
    if xw2 > max2 {
      max2 = xw2
    }
    result.push(xs)
  }
  for (i,x) in result.enumerate() {
    if x.at(1) == none {
      result.at(i) = x.at(0)
    } else {
      result.at(i) = stack(dir: ltr, box(width: max1, align(right, x.at(0))), box(width: max2, align(left, x.at(1))))
      
    }
  }
  result
}

