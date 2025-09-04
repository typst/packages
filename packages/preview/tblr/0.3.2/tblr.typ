
/////////////// 
// Utilities for internal use
/////////////// 

#let is-type(x, ..type-arg) = {
  if type-arg.pos().len() > 0 {
    type(x) == dictionary and "_type_" in x and x._type_ == type-arg.pos().at(0)
  } else {
    type(x) == dictionary and "_type_" in x
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
  if type(x) == str {
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
      (matrix, _, _) = table-to-matrix(val.fields().children, ncols)
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
    while col < ncols and current-row-spans.at(col) > 0 {   // skip over prior rowspans
      col = col + 1
    }
    if col == ncols {
      row = row + 1
      col = 0
      matrix.push((ncols * ((body: none),)),)
      current-row-spans = current-row-spans.map(x => x - 1)
    }
    while col < ncols and current-row-spans.at(col) > 0 {   // skip over prior rowspans
      col = col + 1
    }
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
  if rng.len() == 0 {return ()}
  let max = rng.at(rng.len() - 1)
  if type(x) == int {
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
  if type(x) == function {
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
    let row-expanded = expand-position(row, row-range) 
    if row-expanded.len() == 0 {continue}
    for irow in row-expanded {
      let col-expanded = expand-position(col, col-range) 
      if col-expanded.len() == 0 {continue}
      for icol in col-expanded {
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
// `note-numbering` (default: "a"): Numbering for table notes.
// `note-fun` (default: `super`): Formatting function for note indicators. 
// `ret`: If provided, the function returns a dictionary with 
//    components. Options include:
//      "components": includes "table", "remarks", and more
//      "arguments": as above but includes arguments passed to `table-fun`

#let tblr(header-rows: auto, 
          caption: none, 
          placement: auto, 
          remarks: none, 
          table-fun: table,
          note-numbering: "a",
          note-fun: super,
          ret: auto,
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
    if is-type(el, "cells") or is-type(el, "apply") or is-type(el, "note") {
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
  let note-num = specs.filter(x => is-type(x, "note")).len() // weird handling due to reverse processing of specs
  let notes = ()
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
    if is-type(s, "note") {
      let positions = expand-positions(s.cells, range(nrows), range(ncols), 0)
      let num = note-fun(if s.num != none {s.num} else {numbering(note-numbering, note-num)})
      notes.insert(0, (num, s.body))
      for (row, col) in positions {
        matrix.at(row).at(col).body = matrix.at(row).at(col).body + num
      }
      note-num = note-num - 1
    }
  }
  // process lines
  let row-map = range(nrows)
  let line-output = ()
  for l in lines {
    if is-type(l, "hline") {
      if l.within == "header" {
        let l-expanded = expand-position(l.y, range(header-rows))
        if l-expanded.len() > 0 {
          l.y = l-expanded.at(0)
        } else {
          l.y = 0
        }
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
  let args = if h.len() > 0 {
    arguments(..n, ..line-output, table.header(..h), ..t)
  } else {
    arguments(..n, ..line-output, ..t)
  }
  if ret == "arguments" {
    return (arguments: args, remarks: remarks, notes: notes, 
            caption: caption, placement: placement)
  }
  t = table-fun(..args)
  if ret == "components" {
    return (table: t, remarks: remarks, notes: notes, 
            caption: caption, placement: placement)
  }
  if remarks != none or notes.len() > 0 {
    if type(n.columns) == array and n.columns.any(x => type(x) == fraction) {
      t = stack(t, v(0.3em),
        align(left, 
          grid(columns: 2, ..notes.flatten(), 
               [], remarks, inset: (y: 0.3em)))) 
    } else {
      // absolute widths, so fit the remarks within the table width
      t = context stack(t, v(0.3em),
        align(left, 
          box(width: measure(t).width, 
            grid(columns: 2, ..notes.flatten(), 
                 [], remarks, inset: (y: 0.3em))))) 
    }
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

// Add a note to cells given. The note is positioned at the bottom of the table before remarks.
// Positional arguments given as arrays are the positional indicators as with `cells`.
// If one argument positional argument has content, it's taken as the body of the note.
// If two positional arguments have content, the first is the marker for the note, and the second is the body of the note.
#let note(..args) = {
  let cells = args.pos().filter(x => type(x) == array)
  let content = args.pos().filter(x => type(x) != array)
  let body = content.last()
  let num = if content.len() == 2 {content.first()} else {none}
  (_type_: "note", cells: cells, body: body, num: num)
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

// Returns an array with two components.
// If there's nothing to split, the content is returned as the first with none as the second.
#let split-content(x, marker: "&", direction: ltr, hide: false, split: "before") = {
  let sc = split-content.with(marker: marker, direction: direction, hide: hide, split: split)
  if type(x) == str {
    if x.contains(marker) {
      let p = x.matches(marker).map(y => if split == "before" {y.start} else {y.end}).reduce((a,b) => if direction == ltr {calc.min(a,b)} else {calc.max(a,b)})
      return (x.slice(0,p), x.slice(p + if hide {marker.len()} else {0}, x.len())) 
    } else {
      return (x, none)
    }
  }
  if type(x) == content {
    if x.has("body") {
      let xf = x.fields()
      let xb = xf.remove("body")
      let (one, two) = sc(xb)
      if two != none {
        return ((x.func())(one, ..xf), (x.func())(two, ..xf))
      } else {
        return (x, none)
      }
    } else if x.has("text") {
      return sc(x.text)
    } else if x.has("child") {
      let (one, two) = sc(x.child)
      if two != none {
        return ((x.func())(one, x.styles), (x.func())(two, x.styles))
      } else {
        return (x, none)
      }
    } else if x.has("children") {
      let (one, two) = sc(x.children)
      if two != none {
        return ((x.func())(one), (x.func())(two))
      } else {
        return (x, none)
      }
    } 
  }
  if type(x) == array {
    let splits = x.map(el => sc(el))
    let idx = if direction == ltr {
      splits.position(el => el.at(1) != none)
    } else {
      let last = none
      for (i, el) in splits.enumerate() {
        if el.at(1) != none {
          last = i
        }
      }
      last
    }
    if idx != none {
      let (one, two) = sc(x.at(idx))
      let a0 = x.slice(0, idx)
      if one != "" {a0.push(one)}
      let a1 = x.slice(idx + 1, x.len())
      if two != "" {a1.insert(0, two)}
      return (a0, a1)
    } else {
      return (x, none)
    }
  }
  return (x, none)
}

// General splitting utility
// `format` is a list of regex strings.
// Each string is the point at which the content is split 
// (on the right side of the regex).  
// Each of these splits `x` from left to right.
// `format` can also be a dictionary with `marker` and 
// `split` where `split` can be "before" or "after" to
// designate which side of the regex to split on.
#let split-at(x, format: ()) = {
  let something-found = false
  let res = ()
  let y = x
  for a in format {
    let split = "after"
    let marker = a
    if type(a) == dictionary {
      split = "before"
      marker = a.before
    }
    let (one, two) = split-content(y, marker: regex(marker), split: split)
    if two != none {
      res.push(one)
      y = two
      something-found = true
    } else {
      res.push(none)
    }
  } 
  if something-found {
    res.push(y)
    return res
  } else {
    return x
  }
}

// Aligns array `x` where each element of `x` is an array 
// of content to be merged and aligned.
// `alignments` is an array of `left` or `right` designations 
// designating how each component should be aligned.
#let align-at(x, alignments) = {
  let result = ()
  let widths = (0pt,) * alignments.len()
  for row in x {
    if type(row) != array {
      continue
    }
    for (i, col) in row.enumerate() {
      let w = measure(col).width
      if w > widths.at(i) {
        widths.at(i) = w
      }
    }
  }
  for row in x {
    let row-content = ()
    if type(row) != array {
      result.push(row)
      continue
    }
    for (i, val) in row.enumerate() {
      row-content.push(box(width: widths.at(i), align(alignments.at(i), val)))
    }
    result.push(stack(dir: ltr, ..row-content))
  }
  result
}

// Given an array of content `x`, split it according to `format`, and then align based on `align`.
// `format` is an array of regex strings.
// Each string is the point at which the content is split 
// (on the right side of the regex).  
// Each of these splits `x` from left to right.
// `align` is an array of `left` or `right` designations for each component.
// The length of `align` should be one longer than the length of `format`.
#let split-and-align(x, format: (), align: ()) = {
  assert(align.len() == format.len() + 1, message: "Length mismatch: the length of `align` should be one longer than the length of `format`")
  align-at(x.map(y => split-at(y, format: format)), align)
}

// For an array `a`, return an array with contents aligned. Rules mostly
// follow tbl (https://typst.app/universe/package/tbl/):
// - One position after the leftmost occurrence of the non-printing
//   input token `marker` (default: `&`), if any is present.
// - Otherwise, the rightmost occurrence of the `decimal`. Defaults to
//   `.` just before a digit.
// - Otherwise, the rightmost digit.
// - Otherwise, the content is aligned using `other-align` (default: `center`).
// NOTE: needs to be used in a context.
#let decimal-align(a, decimal: regex("\.\d"), marker: "&", other-align: center) = {
  let result = ()
  for x in a {
    let xs = ()
    let xs-try = split-content(x, direction: ltr, hide: true, marker: marker)
    if xs-try.at(1) != none {       // found first marker
        xs = xs-try
    } else {           
      xs-try = split-content(x, direction: rtl, hide: false, marker: decimal)
      if xs-try.at(1) != none {     // found last decimal location
        xs = xs-try
      } else {
        xs-try = split-content(x, direction: rtl, hide: false, marker: regex("\d"), split: "after")
        if xs-try.at(1) != none {   // found last digit
          xs = xs-try
        } else {                    // nothing found, so center
          if x == none {
            result.push(none)
          } else {
            result.push(align(other-align, x))
          }
          continue
        }
      }
    }
    result.push(xs)
  }
  return align-at(result, (right, left))
}


// Convert `df` from a dataframe to a flat array suitable to passing to `table`.
// `df` is expected to be a dictionary in dataframe style where each component is a columnar array.
// If `include-headers` is `true`, the keys of the dictionary are included on the first row. 
#let dataframe-to-table(df, include-header: true) = {
  let result = ()
  if include-header {
    for col in df.keys() {
      result.push(col)
    }
  }
  for row in range(df.at(df.keys().at(0)).len()) {
    for col in df.keys() {
      result.push(df.at(col).at(row))
    }
  }
  return result
}

// Converts string `x` into an array. 
// This is a thin wrapper over `csv`.
// Options include:
// - `delimiter`: default: ","
// - `flatten`: default: `true`: Flatten the result.
// - `trim`: default: `true`: Trim each string.
// - `evaluate`: default: `false`: `eval` each string to convert each to content.
#let from-csv(x, delimiter: ",", flatten: true, trim: true, evaluate: false) = {
  let result = csv(bytes(x), delimiter: delimiter)
  if flatten {
    result = result.flatten()
  }
  if trim {
    result = result.map(x => x.trim())
  }
  if evaluate {
    result = result.map(eval.with(mode: "markup"))
  }
  return result
}