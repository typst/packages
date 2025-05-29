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

#let assequence(elt) = {
  if type(elt) == array { sequence(elt) } else { sequence((elt, )) }
}

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
  } else {
    it
  }
}

/// Lift sequences of single items to the item
#let _lift-singles = it => {
  if it != none and it.func() == sequence and it.children.len() == 1 {
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


#let expandcell-name = "__rowmantic_expandcell"

/// Compute row length of array of elements, taking table.cell.colspan into account
#let _row-len(row) = {
  let len = 0
  for elt in row {
    if elt != none and elt.func() == table.cell and elt.has("colspan") {
      len += elt.colspan
    } else if elt != none and (elt.func() == table.hline or elt.func() == table.vline) {
      len += 0
    } else {
      // this case includes expandcell
      len += 1
    }
  }
  len
}

#let is-expandcell(elt) = {
  (elt != none and type(elt) == content and elt.func() == metadata and type(elt.value) == dictionary
  and expandcell-name in elt.value)
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

/// Table which takes cell input row-by row, see examples.
///
/// - args (arguments): Rows like `[A & B & C]` and other positional or named table function parameters.
///   Arguments to `table` pass through.
/// - separator (str): configurable cell separator in a row. Good choices are `&`, `,`, or `;`.
///   Escape the separator using e.g. `\&`
/// - row-filler (any): object used to fill rows that are too short
#let rowtable(..args, separator: "&", row-filler: none) = {
  let procarg = () // processed positional arguments

  for arg in args.pos() {
    if type(arg) == content and (arg.func() == sequence or arg.func() == text) {
      procarg.push((row: row-split(arg, sep: separator)))
    } else if is-expandcell(arg) {
      procarg.push((row: (arg, )))
    } else {
      procarg.push((posarg: arg))
    }
  }

  let columns-arg = args.at("columns", default: 0)
  if type(columns-arg) == array { columns-arg = columns-arg.len() }

  let rows = procarg.filter(elt => "row" in elt).map(elt => elt.row)
  let max-len = calc.max(columns-arg, ..rows.map(r => _row-len(r)))
  let rows = rows.map(r => _expand-cells(r, max-len))
  let rows = rows.map(r => r + (row-filler, ) * (max-len - _row-len(r)))

  let targs = ()
  let row-index = 0
  for parg in procarg {
    if "row" in parg {
      targs += rows.at(row-index)
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
/// - args (arguments): table.cell arguments. colspan and rowspan are not permitted.
/// - body (content): cell body
#let expandcell(..args, body) = {
  assert("colspan" not in args.named())
  assert("rowspan" not in args.named())
  metadata(((expandcell-name): (args, body)))
}
