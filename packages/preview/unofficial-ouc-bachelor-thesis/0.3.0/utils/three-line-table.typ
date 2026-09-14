#import "@preview/pointless-size:0.1.2": zh

// https://forum.typst.app/t/is-there-any-simple-way-of-creating-a-three-line-table-like-latex/1193/8

#let continue-table = state("continue-table")

#let header-attach-cell(columns) = table.cell(colspan: columns, {
  context if continue-table.get() != false {
    place(right + top, dy: -1.6em)[
      #set text(size: zh("五号"))
      续表#(query(figure.where(kind: table).before(here())).last().numbering)(none)
    ]
    v(-0.9em)
  } else {
    v(-0.9em)
    continue-table.update(true)
  }
})

#let three-line-table = it => {
  if it.children.any(c => c.func() == table.hline) {
    return it
  }

  let toprule = table.hline(stroke: 0.08em)
  let bottomrule = toprule
  let midrule = table.hline(stroke: 0.05em)

  let meta = it.fields()
  meta.stroke = (_, y) => if y == 1 { (bottom: 0.05em) } else { none }
  meta.remove("children")

  let header = it.children.filter(c => c.func() == table.header)
  let cells = it.children.filter(c => c.func() == table.cell)
  if header.len() == 0 {
    let columns = meta.columns.len()
    header = table.header(
      header-attach-cell(columns),
      ..cells.slice(0, columns),
    )
    cells = cells.slice(columns)
  } else {
    let columns = meta.columns.len()
    let children = if type(header) != array { header.children } else {
      header.map(h => h.children).flatten()
    }
    header = table.header(
      header-attach-cell(columns),
      ..children,
    )
  }

  return table(
    ..meta,
    toprule,
    header,
    ..cells,
    bottomrule,
  )
}
