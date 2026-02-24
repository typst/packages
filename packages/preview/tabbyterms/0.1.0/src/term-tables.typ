
#import "style.typ" as style

// is content with given element function (and not none)
// these are separate for performance concern (maybe silly?)
#let isfunc(arg, f) = arg != none and arg.func() == f

#let row-len(row, colspan: "colspan") = {
  row.map(elt => if isfunc(elt, table.cell) { elt.at(colspan, default: 1) } else { 1 }).sum()
}

/// Given a list of arrays, extend them all with `none` to their maximum length
/// The given `max-len` is the initial length
#let even-arrays(arr, max-len: 1) = {
  for elt in arr {
    let row = if type(elt) == array { elt } else { (elt, ) }
    max-len = calc.max(max-len, row-len(row))
  }
  for elt in arr {
    let row = if type(elt) == array { elt } else { (elt, ) }
    (row + (none, ) * (max-len - row-len(row)), )
  }
}

#let sequence = [].func()
#let space = [ ].func()
#let is-space-func(x) = x.func() in (space, parbreak, linebreak)

// Get array of `list.item.body` out of content
// If there's no list, return the whole input
#let unpack(it) = {
  if it == none {
    return it
  } else if it.func() == sequence and it.children.len() > 0 {
    // multiple list items
    let li = it.children.filter(elt => elt.func() == list.item).map(item => item.body)
    if li.len() > 0 {
      let everything = it.children
        .filter(elt => not is-space-func(elt))
        .map(elt => {
          if elt.func() == list.item { elt.body } else {
            panic("Stray content outside list. Expected list item, found " + repr(elt))
          }
        })
      return everything
    }
  // single list item
  } else if it.func() == list.item {
    return it.body
  }
  // no list items, take whole content
  it
}

/// Convert a term list element (`terms`) to a table
///
/// By default, the terms are the first column and the descriptions are the second column.
/// Multiple columns can be added by using lists in the descriptions.
/// Table headers and footers are supported. The headers and footers expand to span the width of
/// the whole table, if they consist of just one item.
///
/// Additional arguments are forwarded to the `table` function.
///
/// - column-width (length, array, auto): Default column width (can also specify regular `columns` argument); if it is an array, extend the array by repeating the last element to cover all columns.
/// - header-mark (str): Name of table header marker row, `none` to disable.
/// - footer-mark (str): Name of table footer marker row, `none` to disable.
/// - lists-to-columns (bool): Whether to expand lists into columns (rows if transposed).
/// - transpose (bool): If false, terms and descriptions form separate columns, if true, they form rows.
/// - label (label): Which label to apply to the resulting table element
/// - table (function): Table function to use to create the table
/// - ..args (arguments): Additional arguments for the table function.
/// - body (terms, content): Should be a `terms` element or any content where terms should be converted
#let terms-table(
  column-width: auto,
  header-mark: "-table-header",
  footer-mark: "-table-footer",
  lists-to-columns: true,
  transpose: false,
  label: style.plain,
  table: std.table,
  ..args,
  body,
) = {
  // This function works both as direct terms -> table converter
  // but also as a show rule good for `show terms: rule` to convert all `terms` in a document
  // Because we want to avoid having those two very similar things as separate functions
  if not (type(body) == content and isfunc(body, terms)) {
    let rule = terms-table.with(
      column-width: column-width,
      header-mark: header-mark,
      footer-mark: footer-mark,
      lists-to-columns: lists-to-columns,
      transpose: transpose,
      label: label,
      table: table,
      ..args,
    )
    return { show terms: rule; body }
  }

  // Search the item and children for labels
  for ch in (body, ) + body.children {
    if ch.has("label") and ch.label == style.revoke {
      return body
    }
    if ch.has("label") {
      label = ch.label
    }
  }

  let term = body.children.map(ch => ch.term)
  let unpack = if lists-to-columns { unpack } else { x => x }
  let description = body.children.map(ch => ch.description)

  // find hlines in the left hand side (terms)
  let hlines = ()
  while true {
    let pos = term.position(elt => elt.func() == std.table.hline or elt == [--])
    if pos != none {
      let index = pos
      let hline = term.remove(index)
      let hline-desc = description.remove(pos)
      if hline-desc != [] {
        panic("Description for hline must be empty, error on row: " + str(index))
      }
      let fields = if hline.func() == std.table.hline { hline.fields() } else { () }
      let make-line(index, ..fields) = if transpose {
        std.table.vline(x: index, ..fields)
      } else {
        std.table.hline(y: index, ..fields)
      }
      hlines.push(make-line(index, ..fields))
    } else {
      break
    }
  }

  let header = if header-mark != none and [#header-mark] in term {
    let pos = term.position(elt => elt == [#header-mark])
    let _ = term.remove(pos)
    let headers = unpack(description.remove(pos))
    if type(headers) != array { (headers, ) } else { headers }
  }
  let footer = if footer-mark != none and [#footer-mark] in term {
    let pos = term.position(elt => elt == [#footer-mark])
    let _ = term.remove(pos)
    let footers = unpack(description.remove(pos))
    if type(footers) != array { (footers, ) } else { footers }
  }

  let col-arg = args.at("columns", default: none)
  let max-cols = 1
  if col-arg != none {
    if type(col-arg) == int {
      max-cols = col-arg - 1
    } else if type(col-arg) == array {
      max-cols = col-arg.len() - 1
    }
  }

  let term = term.map(t => [#t#style.term])
  let desc-unpack = even-arrays(description.map(unpack), max-len: if not transpose { max-cols } else { 1})
  let rows = term.zip(desc-unpack).map(
    ((term, desc)) => ((term, ..desc.map(d => [#d#style.description]))))

  let width = if not transpose { row-len(rows.at(0)) } else { term.len() }
  let cell-data = if not transpose {
    rows.flatten()
  } else {
    array.zip(..rows).flatten()
  }
  // Single items as header/footer expand to cover the whole table
  let expand-colspan(arr) = {
    if arr != none and arr.len() == 1 {
      (std.table.cell(colspan: width, arr.at(0)), )
    } else {
      arr
    }
  }

  // Expand column-width
  let columns = if type(column-width) == array {
    if column-width.len() > width {
      column-width.slice(0, width)
    } else {
      let last = column-width.at(-1)
      column-width + (last, ) * (width - column-width.len())
    }
  } else { (column-width, ) * width }

  [#table(
    columns: columns,
    ..args,
    ..if header != none { (std.table.header(..expand-colspan(header)), ) },
    ..cell-data,
    ..if footer != none { (std.table.footer(..expand-colspan(footer)), ) },
    ..hlines,
  )#label]
}


