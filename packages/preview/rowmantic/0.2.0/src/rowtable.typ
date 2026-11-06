// Copyright 2025 Ulrik Sverdrup "bluss" and rowmantic contributors.
// Distributed under the terms of the EUPL v1.2 or any later version.


#let sequence = [].func()
#let space = [ ].func()
#let mathsymbol = $,$.body.func()
#let align-point = $&$.body

/// Trim starting or ending space in an array of content
/// This removes the first single space (if any) in a sequence
///
/// - array (array): array of content
/// - reverse (bool): look from the end of strings. The array is still processed front-to-back (because it's convenient that way)
// Inefficient but gets the job done.
#let _trim(array, reverse: false) = {
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

#let expandcell-name = "__rowmantic_expandcell"
#let tombstone-name = "__rowmantic_tombstone"
#let is-expandcell(elt) = (isfunc(elt, metadata)
  and type(elt.value) == dictionary and expandcell-name in elt.value)
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

#let asarray(elt) = if type(elt) == array { elt } else { (elt, ) }
/// Take a sequence (content) and split it into an array by the given separator.
/// It's split only shallowly, not deeply; the separators must exist in the uppermost sequence's
/// content.
///
/// - it (content): text or sequence or other content
/// - sep (str): separator
/// - strip-space (bool): Remove leading/trailing spaces from split sequences
/// -> array
#let row-split(it, sep: "&", strip-space: true) = {
  asarray(_row-split(it, sep: sep, strip-space: strip-space)).map(_lift-singles)
}

#let _as-equations(eqs, block: false) = {
  if type(eqs) == array { eqs.map(math.equation.with(block: block)) } else { (math.equation(block: block, eqs), ) }
}


/// Compute row length of array of elements, taking table.cell.colspan into account
#let _row-len(row) = {
  let len = 0
  for elt in row {
    if isfunc(elt, table.cell) {
      len += elt.at("colspan", default: 1)
    } else if isfuncv(elt, table.hline, table.vline) {
      len += 0
    } else {
      // this case includes expandcell
      len += 1
    }
  }
  len
}


/// Handle any expandcell
#let _expand-cells(row, max-len) = {
  let free = max-len - _row-len(row)
  for elt in row {
    if is-expandcell(elt) {
      (table.cell(
        ..elt.value.at(expandcell-name).at(0),
        colspan: 1 + free,
        elt.value.at(expandcell-name).at(1)), )
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


/// Table which takes cell input row-by row
///
/// Each row is passed as one markup block (`{[...]}` syntax) which is split internally on
/// the separator. Rows that are shorter than the longest row (or the configured `columns`)
/// will be filled to be the same length as all other rows.
///
/// Rows can also be passed as equations (`$...$`) and they are then split into cells
/// by `separator-eq`.
///
/// Leading/trailing spaces are removed from each table element in a row.
/// To preserve such spaces, use `~`.
///
/// This function wraps the standard `table` function and passes through all its regular arguments.
///
/// Passing `{table.cell}` outside rows is possible but not recommended. Passing `[#table.cell[]]`
/// inside a row, between separators, is supported and can be used with `colspan` >= 1 and/or
/// `rowspan >= 1`. Successive rows will take rowspans into account when computing their length.
///
/// It is supported to input rows inside `table.header` and `table.footer`.
///
/// - args (arguments): Rows like `{[A & B & C]}` and other positional or named table function parameters.
///   Arguments to `table` pass through. A `columns` argument to the table is possible but not
///   mandatory.
/// - separator (str): configurable cell separator in a row. Good choices are `&`, `,`, or `;`.
///   Escape the separator using e.g. `[\&]`
/// - separator-eq (none, auto, equation): cell separator for equations, must be single symbol.
///   By default depends on `separator` if possible otherwise falls back to `$&$`.
///   Set to `{none}` to disable splitting equations.
/// - row-filler (any): value used to fill rows that are too short
/// - column-width (length, relative, array): set column width without specifying number of columns.
///   A single length is repeated for all columns. An array of lengths is repeated by extending with
///   the last item.
/// - table (function): Table function to use to build the final table. Intended for use with
///   table wrappers from other packages. (The function `{arguments}` can be used for
///   argument pass-through.)
#let rowtable(..args, separator: "&", separator-eq: auto, row-filler: none, column-width: none, table: std.table) = {
  // type check parameters
  assert(type(separator) == str, message: "Separator must be string")
  assert(
    separator-eq == none or
    separator-eq == auto or
    type(separator-eq) == content and isfuncv(separator-eq, math.equation, align-point, mathsymbol),
    message: "separator-eq must be none, auto, & or math symbol")
  // processed positional arguments
  // dictionary with either of these:
  //  (row: array, wrap: function?)
  //  (posarg: any)
  let procarg = ()

  /// Create a row from content ([] or $$ argument)
  /// return row as array or none
  /// - arg (any):
  /// -> (array, none)
  let maybe-makerow(arg) = {
    if isfunc(arg, sequence) or isfunc(arg, text) or is-expandcell(arg) {
      row-split(arg, sep: separator)
    } else if isfunc(arg, math.equation) and separator-eq != none {
      let separator-eq = _normalize-equation-sep(separator, separator-eq)
      _as-equations(row-split(arg.body, sep: separator-eq), block: arg.block)
    }
  }

  for arg in args.pos() {
    // regular row
    let row = maybe-makerow(arg)
    if row != none {
      procarg.push((row: row))
      continue
    }
    // row inside header/footer
    if isfuncv(arg, std.table.header, std.table.footer) and arg.children.len() == 1 {
      let body = arg.children.at(0).body
      let row = maybe-makerow(body)
      if row != none {
        procarg.push((row: row, wrap: _headfootwrap(arg)))
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
      if isfunc(elt, std.table.cell) and elt.at("rowspan", default: 1) > 1 {
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
    let r = _expand-cells(r, max-len)
    r.filter(elt => not is-tombstone(elt)) + (row-filler, ) * (max-len - _row-len(r))
  })

  // arrange final table arguments
  let targs = ()
  let row-index = 0
  for (pindex, parg) in procarg.enumerate() {
    if "row" in parg {
      if "wrap" in parg {
        targs.push((parg.wrap)(rows.at(row-index)))
      } else {
        targs += rows.at(row-index)
      }
      row-index += 1
    } else {
      targs.push(parg.posarg)
    }
  }

  // create column widths
  let columns = if column-width != none {
    assert(type(column-width) in (length, relative, array), message: "Unexpected column-width type")
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

/// An expandcell is a `table.cell` that expands its colspan to available width
/// The expandcell can be passed alone as a row, or should be placed inside a row markup block.
///
/// - args (arguments): `{table.cell}` arguments. colspan and rowspan are not permitted.
/// - body (content): cell body
#let expandcell(..args, body) = {
  assert("colspan" not in args.named())
  assert("rowspan" not in args.named())
  metadata(((expandcell-name): (args, body)))
}
