// src/tables.typ - reusable thesis table primitives

#import "@preview/booktabs:0.0.4": bottomrule, midrule, toprule

#let table-rule = rgb("#d8dee8")
#let table-header-fill = rgb("#f3f6fa")
#let table-zebra-fill = rgb("#fbfcfe")

#let thesis-table-stroke = (x: none, y: 0.45pt + table-rule)
#let thesis-table-inset = (x: 4.4pt, y: 4.2pt)
#let thesis-table-compact-inset = (x: 3.2pt, y: 3pt)

#let thesis-table-fill(x, y) = if y == 0 {
  table-header-fill
} else if calc.odd(y) {
  table-zebra-fill
} else {
  none
}

#let thesis-table-align = left + top

#let thesis-table(..args) = table(
  stroke: thesis-table-stroke,
  inset: thesis-table-inset,
  fill: thesis-table-fill,
  align: thesis-table-align,
  ..args,
)

#let thesis-readable-table(size: 8.2pt, inset: thesis-table-inset, ..args) = {
  show table.cell: it => {
    set par(justify: false, first-line-indent: 0pt, leading: 0.52em)
    set text(size: size, hyphenate: true)
    it
  }

  show table.cell.where(y: 0): it => {
    set text(weight: "semibold")
    it
  }

  table(
    stroke: thesis-table-stroke,
    inset: inset,
    fill: thesis-table-fill,
    align: thesis-table-align,
    ..args,
  )
}

#let descriptive-table-rule = rgb("#d9d9d9")
#let descriptive-table-header-fill = rgb("#f3f3f3")

#let thesis-descriptive-table(
  size: 8.2pt,
  inset: (x: 4.8pt, y: 4.4pt),
  columns: auto,
  align: thesis-table-align,
  header: (),
  ..body
) = {
  show table.cell: it => {
    set par(justify: false, first-line-indent: 0pt, leading: 0.52em)
    set text(size: size, hyphenate: true)
    it
  }

  show table.cell.where(y: 0): it => {
    set text(weight: "semibold")
    it
  }

  let descriptive-fill(x, y) = if y == 0 {
    descriptive-table-header-fill
  } else {
    none
  }

  let descriptive-stroke = (x: none, y: 0.45pt + descriptive-table-rule)

  if header.len() == 0 {
    table(
      columns: columns,
      align: align,
      inset: inset,
      stroke: descriptive-stroke,
      fill: descriptive-fill,
      ..body.pos(),
    )
  } else {
    table(
      columns: columns,
      align: align,
      inset: inset,
      stroke: descriptive-stroke,
      fill: descriptive-fill,
      table.header(..header),
      ..body.pos(),
    )
  }
}

#let thesis-compact-table(size: 7.5pt, inset: thesis-table-compact-inset, ..args) = {
  show table.cell: it => {
    set par(justify: false, first-line-indent: 0pt, leading: 0.48em)
    set text(size: size, hyphenate: true)
    it
  }

  show table.cell.where(y: 0): it => {
    set text(weight: "semibold")
    it
  }

  table(
    stroke: thesis-table-stroke,
    inset: inset,
    fill: thesis-table-fill,
    align: thesis-table-align,
    ..args,
  )
}

#let thesis-schema-table(size: 8.1pt, inset: thesis-table-inset, ..args) = {
  show table.cell: it => {
    set par(justify: false, first-line-indent: 0pt, leading: 0.50em)
    set text(size: size, hyphenate: true)
    it
  }

  show table.cell.where(y: 0): it => {
    set text(weight: "semibold")
    it
  }

  table(
    stroke: thesis-table-stroke,
    inset: inset,
    fill: thesis-table-fill,
    align: thesis-table-align,
    ..args,
  )
}

#let thesis-wide-table(size: 7.8pt, inset: thesis-table-compact-inset, ..args) = {
  show table.cell: it => {
    set par(justify: false, first-line-indent: 0pt, leading: 0.49em)
    set text(size: size, hyphenate: true)
    it
  }

  show table.cell.where(y: 0): it => {
    set text(weight: "semibold")
    it
  }

  table(
    stroke: thesis-table-stroke,
    inset: inset,
    fill: thesis-table-fill,
    align: thesis-table-align,
    ..args,
  )
}

#let thesis-booktabs-table(
  size: 8pt,
  inset: thesis-table-compact-inset,
  columns: auto,
  align: thesis-table-align,
  header: (),
  ..body
) = {
  show table.cell: it => {
    set par(justify: false, first-line-indent: 0pt, leading: 0.50em)
    set text(size: size, hyphenate: true)
    it
  }

  show table.cell.where(y: 0): it => {
    set text(weight: "semibold")
    it
  }

  if header.len() == 0 {
    table(
      columns: columns,
      align: align,
      inset: inset,
      stroke: none,
      fill: none,
      toprule(),
      ..body.pos(),
      bottomrule(),
    )
  } else {
    table(
      columns: columns,
      align: align,
      inset: inset,
      stroke: none,
      fill: none,
      toprule(),
      table.header(..header),
      midrule(),
      ..body.pos(),
      bottomrule(),
    )
  }
}

#let table-code(body) = text(font: ("Consolas", "Courier New", "DejaVu Sans Mono"), size: 0.92em)[#body]

#let table-code-lines(..items) = {
  let values = items.pos()
  for (idx, item) in values.enumerate() {
    table-code(item)
    if idx + 1 < values.len() {
      linebreak()
    }
  }
}

#let table-lines(..items) = {
  let values = items.pos()
  for (idx, item) in values.enumerate() {
    item
    if idx + 1 < values.len() {
      linebreak()
    }
  }
}

#let thesis-legacy-table(..args) = {
  table(
    stroke: thesis-table-stroke,
    inset: thesis-table-inset,
    fill: thesis-table-fill,
    align: thesis-table-align,
    ..args,
  )
}
