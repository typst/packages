// Copyright 2025 Ulrik Sverdrup "bluss" and rowmantic contributors.
// Distributed under the terms of the EUPL v1.2 or any later version.


#let sequence = [].func()
#let space = [ ].func()

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
#let is-expandcell(elt) = (isfunc(elt, metadata)
  and type(elt.value) == dictionary and expandcell-name in elt.value)


/// Can split only text and sequence into array of sequence
/// - it (content): text or sequence or other content
/// - sep (str): separator
/// - strip-space (bool): Remove leading/trailing spaces from split sequences
/// -> array, any
#let _row-split(it, sep: "&", strip-space: true) = {
  if it.func() == text {
    return _row-split(sequence((it, )), sep: sep)
  } else if it.func() == sequence {
    let res = ()
    let accum = ()
    for elt in it.children {
      if elt.func() == text {
        if sep in elt.text {
          let parts = elt.text.split(sep)
          accum.push(parts.at(0))
          res.push(accum)
          res += parts.slice(1, -1).map(x => (x, ))
          accum = (parts.at(-1), )
        } else {
          accum.push(elt)
        }
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

/// Take a sequence (content) and split it into an array by the given separator.
/// It's split only shallowly, not deeply; the separators must exist in the uppermost sequence's
/// content.
///
/// - it (content): text or sequence or other content
/// - sep (str): separator
/// - strip-space (bool): Remove leading/trailing spaces from split sequences
/// -> array
#let row-split(it, sep: "&", strip-space: true) = {
  _row-split(it, sep: sep, strip-space: strip-space).map(_lift-singles)
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


/// Table which takes cell input row-by row
///
/// Each row is passed as one markup block (`{[...]}` syntax) which is split internally on
/// the separator. Rows that are shorter than the longest row (or the configured `columns`)
/// will be filled to be the same length as all other rows.
///
/// Leading/trailing spaces are removed from each table element in a row.
/// To preserve such spaces, use `~`.
///
/// This function wraps the standard `table` function and passes through all its regular arguments.
///
/// Passing `{table.cell}` outside rows is possible but not recommended. Passing `[#table.cell[]]`
/// inside a row, between separators, is supported and can be used with `colspan` >= 1.
///
/// It is supported to input rows inside `table.header` and `table.footer`.
///
/// - args (arguments): Rows like `{[A & B & C]}` and other positional or named table function parameters.
///   Arguments to `table` pass through. A `columns` argument to the table is possible but not
///   mandatory.
/// - separator (str): configurable cell separator in a row. Good choices are `&`, `,`, or `;`.
///   Escape the separator using e.g. `[\&]`
/// - row-filler (any): value used to fill rows that are too short
/// - table (function): Table function to use to build the final table. Intended for use with
///   table wrappers from other packages. (The function `{arguments}` can be used for
///   argument pass-through.)
#let rowtable(..args, separator: "&", row-filler: none, table: std.table) = {
  // processed positional arguments
  // dictionary with either of these:
  //  (row: array, wrap: function?)
  //  (posarg: any)
  let procarg = ()

  for arg in args.pos() {
    if isfunc(arg, sequence) or isfunc(arg, text) or is-expandcell(arg) {
      procarg.push((row: row-split(arg, sep: separator)))
    } else if isfuncv(arg, std.table.header, std.table.footer) and arg.children.len() == 1 {
      let body = arg.children.at(0).body
      procarg.push((row: row-split(body, sep: separator), wrap: _headfootwrap(arg)))
    } else {
      procarg.push((posarg: arg))
    }
  }

  let columns-arg = args.at("columns", default: 0)
  if type(columns-arg) == array { columns-arg = columns-arg.len() }

  let rows = procarg.filter(elt => "row" in elt).map(elt => elt.row)
  let max-len = calc.max(1, calc.max(columns-arg, ..rows.map(r => _row-len(r))))
  let rows = rows.map(r => _expand-cells(r, max-len))
  let rows = rows.map(r => r + (row-filler, ) * (max-len - _row-len(r)))

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

  table(
    columns: max-len,
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
