/// Sets column width.
#let cwidth(..columns) = {
  ((
    _kind: "easytable.set_column",
    length: columns.pos().len(),
    value: columns.pos(),
  ),)
}

/// Sets column style.
#let cstyle(..columns) = {
  let layout_func = columns.pos().map((e) => {
    if type(e) == "alignment" {
      return _content => align(e, _content)
    } else {
      return e
    }
  })
  ((
    _kind: "easytable.set_layout",
    length: layout_func.len(),
    layout: layout_func,
  ),)
}

/// Add table row data.
#let tr(trans: none, trans_by_idx: none, cell_style: none, ..columns) = {
  let cell_trans = if trans != none {
    (x: none, y: none, c) => trans(c)
  } else if trans_by_idx != none {
    trans_by_idx
  } else {
    none
  }
  ((
    _kind: "easytable.push_row",
    length: columns.pos().len(),
    data: columns.pos(),
    cell_style: cell_style,
    cell_trans: cell_trans,
  ),)
}

/// Add table row data.
#let hline(..args) = ((_kind: "easytable.push_hline", args: args),)

/// Add table row data.
#let vline(..args) = ((_kind: "easytable.push_vline", args: args),)

/// Add table header.
#let th(
  trans: text.with(weight: 700),
  trans_by_idx: none,
  cell_style: none,
  ..columns,
) = (..tr(
  trans: trans,
  trans_by_idx: trans_by_idx,
  cell_style: cell_style,
  ..columns,
), ..hline(stroke: 0.5pt, expand: -2pt),)
