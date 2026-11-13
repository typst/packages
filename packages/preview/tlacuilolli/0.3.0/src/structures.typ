/// Create a native enumeration with Roman or decimal markers.
#let roman-list(..items, style: "upper", start: 1, full: false, tight: true) = {
  let patterns = (upper: "I.", lower: "i.", decimal: "1.")
  enum(numbering: patterns.at(style), start: start, full: full, tight: tight, ..items)
}

/// Create a native table with a repeating semantic header and optional caption.
#let note-table(
  ..cells,
  columns: auto,
  header: (),
  caption: none,
  align: start,
  placement: center,
  font-size: 0.93em,
  inset: (x: 0.75em, y: 0.38em),
  rule: true,
) = {
  let heading = if header.len() > 0 {
    let divider = if rule { (table.hline(stroke: 0.45pt + rgb("#a0a0a0")),) } else { () }
    (table.header(..header.map(strong), ..divider),)
  } else { () }
  let tracks = if columns == auto { calc.max(header.len(), 1) } else { columns }
  let data = {
    show table.cell: set text(size: font-size, number-width: "tabular")
    table(columns: tracks, stroke: none, inset: inset, align: align, ..heading, ..cells)
  }
  if caption == none {
    std.align(placement, data)
  } else {
    show figure: set std.align(placement)
    show figure: set block(breakable: true)
    show figure.caption: set block(sticky: true)
    show figure.caption: set std.align(placement)
    show figure.caption: set text(style: "italic")
    set figure.caption(position: top)
    figure(data, kind: table, caption: caption, numbering: none)
  }
}
