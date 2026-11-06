#import "@preview/zero:0.1.0": ztable

/////////////// 
// Utilities
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

/////////////// 
// Conversion back and forth between table arguments and a matrix
///////////////

#let table-to-matrix(a, ncols) = {
  let matrix = ((ncols * ((body: none),)),)
  let lines = ()
  let current-row-spans = (ncols * (0,))
  let row = 0   // row counter
  let col = 0   // column counter
  for (k, val) in a.enumerate() {
    if type(val) == content and val.func() == table.header {
      (matrix, lines) = table-to-matrix(val.fields().children, ncols)
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
  (matrix, lines)
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
    return range(expand-position(x.start, rng, extras: extras).at(0), expand-position(x.stop, rng, extras: extras).at(0), step: x.step)
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
// These include `cells()`, `cols()`, `rows()`, `header-rows()`, ...
// 
// Named arguments specific to `tblr` include:
// `header-rows` (default: 0): Number of header rows in the content.
// `remarks`: Content to include as a comment below the table.
// `caption`: If provided, wrap the `table` in a `figure`.
// `placement` (default: `auto`): Passed to figure.
// `table-fun` (default: `ztable`): Specifies the table-creation function to use.

#let tblr(header-rows: 0, 
          caption: none, 
          placement: auto, 
          remarks: none, 
          table-fun: ztable,
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
    if is-type(el, "cells") or is-type(el, "body-cells") or is-type(el, "header-cells") {
      specs.push(el)
    } else {
      content.push(el)
    }
  }
  let (matrix, lines) = table-to-matrix(content, ncols)
  let nrows = matrix.len()
  // process cell-level specs
  for s in specs.rev() {
    if s._type_ in ("cells", "header-cells", "body-cells") {
      let positions = if s._type_ == "cells" {
        expand-positions(s.cells, range(nrows), range(ncols), header-rows)
      } else if s._type_ == "header-cells" {
        expand-positions(s.cells, range(header-rows), range(ncols), 0)
      } else if s._type_ == "body-cells" {
        expand-positions(s.cells, range(header-rows, nrows), range(ncols), 0)
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
        matrix.at(row).at(col).cell-fields = remove(s, ("cells", "sets", "hooks", "_type_")) + matrix.at(row).at(col).at("cell-fields", default: (:))  
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
  }
  // process lines
  let row-map = range(nrows)
  let line-output = ()
  for l in lines {
    if is-type(l, "hline") {
      l = remove(l, ("_type_",))
      l.y = expand-position(l.y, range(nrows)).at(0)
      line-output.push(table.hline(..l))
    }
    if is-type(l, "header-hline") {
      l = remove(l, ("_type_",))
      l.y = expand-position(l.y, range(header-rows)).at(0)
      line-output.push(table.hline(..l))
    }
    if is-type(l, "vline") {
      line-output.push(table.vline(..remove(l, ("_type_",))))
    }
  }
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
//
#let cells(..args) = {
  (_type_: "cells") + args.named() + (cells: args.pos())
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

// Directive to control formatting of cells within a header.
// Like `cells` but only applies to header cells.
#let header-cells(..args) = {
  (_type_: "header-cells") + args.named() + (cells: args.pos())
}  

// Directive to control formatting of columns within a header.
// Like `cols` but only applies to columns in the header.
#let header-cols(..args) = {
  header-cells(..args.named(), ..args.pos().map(x => (auto, x)))
}  

// Directive to control formatting of columns within a header.
// Like `cols` but only applies to columns in the header.
#let header-rows(..args) = {
  header-cells(..args.named(), ..args.pos().map(x => (x, auto)))
}  

// Directive to control formatting of cells within the table body.
// Like `cells` but only applies to cells within the table body.
#let body-cells(..args) = {
  (_type_: "body-cells") + args.named() + (cells: args.pos())
}  

// Directive to control formatting of columns within the table body.
// Like `cols` but only applies to columns in the body.
#let body-cols(..args) = {
  body-cells(..args.named(), ..args.pos().map(x => (auto, x)))
}  

// Directive to control formatting of rows within the table body.
// Like `rows` but only applies to rows in the body.
#let body-rows(..args) = {
  body-cells(..args.named(), ..args.pos().map(x => (x, auto)))
}  

// Like `table.hline` but lazy and can include indicators like `end`.
#let hline(y: none, ..args) = {
  (_type_: "hline", ..((y: y,) + args.named()))
}  

// Like `hline` but for use in headers.
#let header-hline(y: none, ..args) = {
  (_type_: "header-hline", ..((y: y,) + args.named()))
}  

// Like `table.vline` but lazy and can include indicators like `end`.
#let vline(x: none, ..args) = {
  (_type_: "vline", ..((x: x,) + args.named()))
}  

// Reserved for the future.
#let note(row, col, content) = {
}  

