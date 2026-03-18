// Copyright 2025 Ulrik Sverdrup "bluss" and rowmantic contributors.
// Distributed under the terms of the EUPL v1.2 or any later version.

/// rowtable module


#let sequence = [].func()
#let space = [ ].func()
#let mathsymbol = $,$.body.func()
#let align-point = $&$.body

/// Trim starting or ending space in an array of content
/// This removes the first single space (if any) in a sequence
///
/// - array (array): array of content
/// - reverse (bool): look from the end of strings. The array is still processed front-to-back (because it's convenient that way)
#let _trim(array, reverse: false) = {
// Inefficient but gets the job done.
  let done = false
  for elt in array {
    if done {
      (elt, )
      continue
    }
    if elt.func() == text and elt.text == "" {
      // skip and continue
    } else if elt.func() == space {
      done = true
      // skip
    } else if elt.func() == text {
      if not reverse and elt.text.starts-with(" ") {
        let new-text = elt.text.slice(1, none)
        (text(new-text), )
      } else if reverse and elt.text.ends-with(" ") {
        let new-text = elt.text.slice(0, -1)
        (text(new-text), )
      } else {
        (elt, )
      }
      done = true
    } else {
      (elt, )
      done = true
    }
  }
  ()
}

/// Trim first space in the front and from the back
#let trim-space(seq) = {
  sequence(_trim(_trim(seq.children).rev(), reverse: true).rev())
}

// is content with given element function (and not none)
// these are separate for performance concern (maybe silly?)
#let isfunc(arg, f) = arg != none and arg.func() == f
#let isfuncv(arg, ..fs) = arg != none and fs.pos().any(f => arg.func() == f)
#let iscell(arg) = arg != none and (arg.func() == table.cell or arg.func() == grid.cell)

#let expandcell-name = "__rowmantic_expandcell"
#let tombstone-name = "__rowmantic_tombstone"
#let row-name = "__rowmantic_row"
#let is-expandcell(elt) = (isfunc(elt, metadata)
  and type(elt.value) == dictionary and expandcell-name in elt.value)
#let is-row(elt) = (isfunc(elt, metadata)
  and type(elt.value) == dictionary and row-name in elt.value)
#let is-tombstone(elt) = isfunc(elt, metadata) and elt.value == tombstone-name
/// a tombstone is not user visible and it's a placeholder for space occupied
/// by a cell with rowspan in another row
#let tombstone() = metadata(tombstone-name)


/// Can split only text and sequence into array of sequence
/// - it (content): text or sequence or other content
/// - sep (str): separator
/// - strip-space (bool): Remove leading/trailing spaces from split sequences
/// -> array, any
#let _row-split(it, sep: "&", strip-space: true) = {
  let contentsep = type(sep) == content
  if it.func() == text {
    return _row-split(sequence((it, )), sep: sep)
  } else if it.func() == sequence {
    let res = ()
    let accum = ()
    for elt in it.children {
      if elt.func() == text {
        if not contentsep and sep in elt.text {
          let parts = elt.text.split(sep)
          accum.push(parts.at(0))
          res.push(accum)
          res += parts.slice(1, -1).map(x => (x, ))
          accum = (parts.at(-1), )
        } else {
          accum.push(elt)
        }
      } else if contentsep and isfunc(elt, sep.func()) and elt == sep {
        res.push(accum)
        accum = ()
      } else if (sep == " " or sep == "  ") and isfunc(elt, space) {
        res.push(accum)
        accum = ()
      } else {
        accum.push(elt)
      }
    }
    if accum.len() != 0 {
      res.push(accum)
      accum = ()
    }
    let result = res.map(sequence)
    if strip-space {
      result.map(trim-space)
    } else {
      result
    }
  } else if is-expandcell(it) {
    (it, )
  } else if isfunc(it, space) and strip-space {
    []
  } else {
    it
  }
}


/// Lift sequences of single items to the item
#let _lift-singles = it => {
  if isfunc(it, sequence) and it.children.len() == 1 {
    it.children.at(0)
  } else {
    it
  }
}

/// If the item is not already an array, wrap it in an array.
#let asarray(elt) = if type(elt) == array { elt } else { (elt, ) }

/// Take a sequence (content) and split it into an array by the given separator.
/// It's split only shallowly, not deeply; the separators must exist in the uppermost sequence's
/// content.
///
/// - it (content): Text or sequence or other content
/// - sep (str): Separator
/// - strip-space (bool): Remove leading/trailing spaces from split sequences
/// -> array
#let row-split(it, sep: "&", strip-space: true) = {
  asarray(_row-split(it, sep: sep, strip-space: strip-space)).map(_lift-singles)
}

/// Turn content item into equation
/// For `table.cell(body)` we produce `table.cell(math.equation(body))`,
/// For `body` we produce `math.equation(body)`
#let _as-equation(elt, block: false) = {
  // if we get a table cell here, we need to invert the order
  // so that the cell is the outermost layer
  if iscell(elt) {
    let fields = elt.fields()
    let body = fields.remove("body")
    elt.func()(..fields, _as-equation(body, block: block))
  } else {
    math.equation(block: block, elt)
  }
}

/// Turn array of content into array of equations
/// - eqs (array, equation):
/// -> array
#let _as-equations(eqs, block: false) = {
  let mapper = _as-equation.with(block: block)
  if type(eqs) == array { eqs.map(mapper) } else { (mapper(eqs), ) }
}


/// Compute the length of a single element
#let _elt-len(elt) = {
  if iscell(elt) {
    elt.at("colspan", default: 1)
  } else if isfuncv(elt, table.hline, table.vline, grid.hline, grid.vline) {
    0
  } else {
    // this case includes expandcell
    1
  }
}

/// Compute row length of array of elements, taking table.cell.colspan into account
#let _row-len(row) = {
  let len = 0
  for elt in row { len += _elt-len(elt) }
  len
}


/// Handle any expandcell
#let _expand-cells(row, max-len, cell-function: none) = {
  let free = max-len - _row-len(row)
  for elt in row {
    if is-expandcell(elt) {
      (cell-function(
        ..elt.value.args,
        colspan: 1 + free,
        elt.value.body), )
      free = 0
    } else {
      (elt, )
    }
  }
  () // ensures empty row maps to empty row
}

/// wrap table.header/footer function
#let _headfootwrap(elt) = rows => {
  let fields = elt.fields()
  let _ = fields.remove("children")
  (elt.func())(..rows, ..fields)
}

/// Return equation separator
#let _normalize-equation-sep(separator, separator-eq) = {
  if separator-eq == auto {
    if separator == "&" { align-point }
    else if separator.len() == 1 { mathsymbol(separator) }
    else { align-point }
  } else {
    // normalize
    if isfunc(separator-eq, math.equation) {
      separator-eq.body
    } else {
      separator-eq
    }
  }
}

/// Add 1 to the given key in the dictionary
///
/// - dict (dictionary):
/// - key (str):
#let dictadd(dict, key, add: 1) = {
  let value = dict.at(key, default: 0)
  dict.insert(key, value + add)
  dict
}


/// Table which takes table cell inputs in rows.
///
/// Each row is passed as one markup block ```typc  [...] ``` which is split internally on
/// the separator. Rows that are shorter than the longest row (or the configured `columns`)
/// will be filled to be the same length as all other rows.
///
/// Rows can also be passed as equations (```typc $...$```) and they are then split into cells
/// by `separator-eq`.
///
/// Leading/trailing spaces are removed from each table element in rows.
/// To preserve such spaces, use ```typst ~```.
///
/// This function wraps the standard `table` function and passes through all its regular arguments.
///
/// Passing ```typc table.cell``` outside rows is possible but not recommended. Passing ```typst #table.cell[]```
/// inside a row, between separators, is supported and can be used with `colspan` >= 1 and/or
/// `rowspan >= 1`. Successive rows will take rowspans into account when computing their length.
///
/// It is supported to input rows inside `table.header` and `table.footer`.
///
/// - ..args (arguments): Rows like ```typc [A & B & C]``` and other positional or named table function parameters.
///   Arguments to `table` pass through. A `columns` argument to the table is possible but not
///   mandatory.
/// - separator (str): Configurable cell separator in rows. Good choices are `"&"`, `","` or `";"`.
///   Escape the separator using e.g. ```typst \&```.
///   As a special case `" "` will split on consecutive whitespace (one or more spaces, tabs or a newline).
///   Additionally, using `"  "` (two spaces) will only split on
/// - separator-eq (none, auto, equation): Cell separator for equations, must be single symbol.
///   By default depends on `separator` if possible otherwise falls back to ```typst $&$```.
///   Set to ```typc none``` to disable splitting equations.
/// - row-filler (none, content): Value used to fill rows that are too short.
/// - column-width (length, relative, fraction, array): Set column width without specifying number of columns.
///   A single length is repeated for all columns. An array of lengths is repeated by extending with
///   the last item.
/// - table (function): Table function to use to build the final table. Intended for use with
///   table wrappers from other packages. (The function ```typst arguments``` can be used for
///   argument pass-through.)
/// - cell-function (function): Cell function to use (either `table.cell` or `grid.cell`). You normally do not need to specify this argument.
/// -> table, content
#let rowtable(..args, separator: "&", separator-eq: auto, row-filler: none, column-width: none, table: std.table, cell-function: auto) = {
  // type check parameters
  assert(type(separator) == str, message: "Separator must be string")
  assert(
    separator-eq == none or
    separator-eq == auto or
    type(separator-eq) == content and isfuncv(separator-eq, math.equation, align-point, mathsymbol),
    message: "separator-eq must be none, auto, & or math symbol")
  let cell-function = if cell-function == auto {
    if table == std.grid { std.grid.cell } else { std.table.cell }
  } else { cell-function }

  // processed positional arguments
  // dictionary with either of these:
  //  (row: array, wrap: function?)
  //  (posarg: any)
  let procarg = ()

  /// Create a row from content ([] or $$ argument)
  /// return `(row: row)` or none, row being an array, with optional `fmtmap` key.
  /// -> dictionary, none
  let maybe-makerow(arg) = {
    // unwrap row() function
    let isrow = is-row(arg)
    let (arg, fmtrec) = if isrow {
      let fmtrec = if arg.value.func != none { (fmtmap: arg.value.func) }
      (arg.value.body, fmtrec)
    } else {
      (arg, none)
    }

    let row = if isfuncv(arg, sequence, text, space) or is-expandcell(arg) {
      row-split(arg, sep: separator)
    } else if isfunc(arg, math.equation) and separator-eq != none {
      let separator-eq = _normalize-equation-sep(separator, separator-eq)
      _as-equations(row-split(arg.body, sep: separator-eq), block: arg.block)
    } else if isrow {
      panic("item in row() is not a valid row, got: " + repr(arg) + ". Hint: add a separator.")
    }
    if row != none {
      (row: row) + fmtrec
    }
  }

  for arg in args.pos() {
    // regular row
    let row = maybe-makerow(arg)
    if row != none {
      procarg.push(row)
      continue
    }
    // row inside header/footer
    if isfuncv(arg, std.table.header, std.table.footer, std.grid.header, std.grid.footer) and arg.children.len() == 1 {
      let body = arg.children.at(0).body
      let row = maybe-makerow(body)
      if row != none {
        procarg.push((..row, wrap: _headfootwrap(arg)))
        continue
      }
    }
    // other arguments
    procarg.push((posarg: arg))
  }

  let columns-arg = args.at("columns", default: 0)
  if type(columns-arg) == array { columns-arg = columns-arg.len() }

  // Handle rowspan in table cells by inserting tombstones (padding row lengths)
  let rows = procarg.filter(elt => "row" in elt)
  let (rows, _info) = rows.enumerate().fold(((), (:)), ((rows, info), (index, rowrec)) => {
    // fold to rows: array of rows
    //         info: dictionary mapping row index -> extra length
    let row = rowrec.row
    let extralen = info.at(str(index), default: 0)
    for elt in row {
      if iscell(elt) and elt.at("rowspan", default: 1) > 1 {
        assert("wrap" not in rowrec, message: "rowspan not supported inside table header/footer")
        let rowspan = elt.rowspan
        let colspan = elt.at("colspan", default: 1)
        for k in range(1, rowspan) {
          info = dictadd(info, str(index + k), add: colspan)
        }
      }
    }
    // reserve space for rowspans using tombstones
    if extralen > 0 { row += (tombstone(), ) * extralen }
    rows.push(row)
    (rows, info)
  })
  // colspan space inside a single row is handled here by _row-len
  // expand expandcells, fill rows, remove tombstones
  let max-len = calc.max(1, calc.max(columns-arg, ..rows.map(r => _row-len(r))))
  let rows = rows.map(r => {
    let r = _expand-cells(r, max-len, cell-function: cell-function)
    r.filter(elt => not is-tombstone(elt)) + (row-filler, ) * (max-len - _row-len(r))
  })

  // arrange final table arguments
  let targs = ()
  let row-index = 0
  for (pindex, parg) in procarg.enumerate() {
    if "row" in parg {
      let row = rows.at(row-index)
      // apply row map functions
      if "fmtmap" in parg {
        row = row.enumerate().map(parg.fmtmap.with(cell-function: cell-function))
      }
      // apply row wrap functions
      if "wrap" in parg {
        targs.push((parg.wrap)(row))
      } else {
        targs += row
      }
      row-index += 1
    } else {
      targs.push(parg.posarg)
    }
  }

  // create column widths
  let columns = if column-width != none {
    assert(type(column-width) in (fraction, length, relative, array), message: "Unexpected column-width type")
    if type(column-width) == array {
      // repeat last item
      if column-width.len() > max-len {
        column-width.slice(0, max-len)
      } else {
        column-width + (column-width.at(-1), ) * (max-len - column-width.len())
      }
    } else {
      (column-width, ) * max-len
    }
  } else { max-len }

  table(
    columns: columns,
    ..args.named(),
    ..targs,
  )
}

/// Grid which takes grid cell inputs as rows.
///
/// The `rowgrid` function has exactly the same interface as the `rowtable` function; refer to it for full documentation. The only difference is the different defaults for the `table` and `cell-function` arguments. Since `rowgrid` forwards to the `grid` function, cells must use `grid.cell` and lines `grid.hline` and so on, when applicable.
///
/// The `rowgrid` function produces a `grid`.
///
/// - table (function): The table function to use to build the table.
/// - cell-function (function): Cell function to use (either `table.cell` or `grid.cell`). You normally do not need to specify this argument.
/// - ..args (arguments): `rowtable` and `grid` arguments. Refer to the `rowtable` documentation for full description of all arguments.
#let rowgrid(table: std.grid, cell-function: std.grid.cell, ..args) = {
  rowtable(table: table, cell-function: cell-function, ..args)
}

/// An expandcell is a `table.cell` that expands its `colspan` to available width.
/// The expandcell can be passed alone as a whole row, or should be placed inside a row markup block to form part of a row.
///
/// - ..args (arguments): `table.cell` arguments, except `colspan` and `rowspan` which are not permitted.
/// - body (content): Cell body
/// -> content
#let expandcell(..args, body) = {
  assert("colspan" not in args.named(), message: "colspan not allowed for expandcell")
  assert("rowspan" not in args.named(), message: "rowspan not allowed for expandcell")
  metadata(((expandcell-name): true, args: args, body: body))
}

#let _invalid_cell_arg = ("x", "y", "rowspan", "colspan")
#let _check-cellargs(args) = {
  if args.len() != 0 {
    for inval in _invalid_cell_arg {
      assert(inval not in args, message: inval + " not allowed for row cells")
    }
  }
}

#let _setlabel(elt, label) = if label != none { [#elt#label] } else { elt }

/// "Flip" or ensure cell properties
/// - elt (any): If this is content, wrap it in a cell with the given extra fields.
///   if this is already a cell, unwrap the body and re-wrap it in a new cell, where `elt`'s fields override `fields` if they overlap.
/// - ..fields (arguments): Extra cell fields to add
/// _ cell-function (function): element function for the table cell
#let flipcell(..fields, elt, cell-function: table.cell) = {
  assert.eq(fields.pos().len(), 0, message: "expected no positional fields")
  let fields = fields.named()
  if type(elt) == content and isfunc(elt, cell-function) {
    let fi = elt.fields()
    let body = fi.remove("body")
    let label = fi.remove("label", default: fields.remove("label", default: none))
    _check-cellargs(fi)  // check the new custom args
    _setlabel(cell-function(..fields, ..fi, body), label)
  } else {
    let label = fields.remove("label", default: none)
    _setlabel(cell-function(..fields, elt), label)
  }
}

#let mapcell-adaptor(func, elt, set-cell: (:), cell-function: table.cell, use-index: false) = {
  let (index, body) = elt
  let iarg = if use-index { (index, ) } else { () }
  let flipcell = flipcell.with(cell-function: cell-function)
  let iscell(elt) = type(elt) == content and isfunc(elt, cell-function)
  if iscell(body) {
    let fields = body.fields()
    let cellbody = fields.remove("body")
    flipcell(..fields, ..set-cell, func(..iarg, cellbody))
  } else {
    let new-body = func(..iarg, body)
    if iscell(new-body) or set-cell.len() != 0 {
      flipcell(..set-cell, new-body)
    } else {
      new-body
    }
  }
}

#let _identity(x) = x
#let _typecheck(name, elt, type) = {
  if std.type(elt) != type { panic(name + " must be " + repr(type) + ", got: " + repr(std.type(elt))) }
}

/// Style a whole row at once
///
/// All arguments are optional. Only one of `map` or `imap` can be passed at the same time.
///
/// Cell properties are resolved in this order: 1. cell returned from map/imap, 2. cell properties
/// from `cell`. 3. cell properties from the cell in the row.
///
/// - map (none, function): apply this function to the content of each cell, after resolving row lengths and padding rows. Passing cell content, signature: function(any) -> any.
/// - imap (none, function): apply this function to the content of each cell,
///  after resolving row lengths and padding rows. Passing index and cell
///  content, signature: function(int, any) -> any. Note that this is just the index in the row,
///  which does not correspond to the column number in complex layouts.
/// - cell (dictionary): set these `table.cell` settings on each cell of the row, after resolving row lengths and padding rows. The properties `x`, `y`, `colspan`, `rowspan` are not allowed here.
#let row(body, map: none, imap: none, cell: (:)) = {
  assert(map == none or imap == none, message: "only one of map and imap can be passed")
  if map == none { map = imap }
  if map == none { map = _identity }
  _typecheck("map", map, function)
  _typecheck("cell", cell, dictionary)
  _check-cellargs(cell)
  let func = mapcell-adaptor.with(map, set-cell: cell, use-index: imap != none)
  metadata(((row-name): true, func: func, body: body))
}
