// Booktabs-style tables with rule spacing and header tagging.

// The row strut is set through text metrics in body.typ, leaving vertical inset for rule spacing.
#let table-inset = (left: 0.6em, right: 0.6em, top: 0pt, bottom: 0pt)

#let heavy-rule = 0.08em
#let light-rule = 0.05em

// Libertinus Serif's x-height in em.
// Measuring it in context would hide the table from figure kind detection.
#let _ex = 0.429em
#let aboverulesep = 0.4 * _ex
#let belowrulesep = 0.65 * _ex

#let toprule(..a) = std.table.hline(stroke: heavy-rule, ..a)
#let midrule(..a) = std.table.hline(stroke: light-rule, ..a)
#let bottomrule(..a) = std.table.hline(stroke: heavy-rule, ..a)

// A wrapper avoids recursive table show rules while adding the space that horizontal strokes cannot reserve.
// Resolved hline row positions are unavailable here, so infer them from cell occupancy.
#let tabular(header-rows: 1, ..args) = {
  let cols = args.named().at("columns", default: 1)
  let ncols = if type(cols) == array { cols.len() } else if type(cols) == int { cols } else { 1 }

  let normalize-child(c) = if type(c) == content { c } else { [#c] }
  let positional = args.pos().map(normalize-child)

  let caller-inset = args.named().at("inset", default: table-inset)
  let inset-at(x, y) = {
    let value = if type(caller-inset) == function { caller-inset(x, y) } else { caller-inset }
    if type(value) == dictionary {
      let side(name, axis) = value.at(name, default: value.at(axis, default: value.at("rest", default: 0pt)))
      (
        left: side("left", "x"), right: side("right", "x"),
        top: side("top", "y"), bottom: side("bottom", "y"),
      )
    } else { (left: value, right: value, top: value, bottom: value) }
  }

  let below-top = ()
  let above-bottom = ()
  let occupied = ()
  let cursor = 0
  let slot(x, y) = str(x) + ":" + str(y)
  let advance(position, cells) = {
    while slot(calc.rem(position, ncols), calc.quo(position, ncols)) in cells {
      position += 1
    }
    position
  }
  // Infer a header only when wrapping cannot move cells.
  // Inherited column settings require context and cannot be read here.
  let header-safe = "columns" in args.named()
  let header-start = none
  let header-end = none
  let walk = ()
  for (index, c) in positional.enumerate() {
    if c.func() == std.table.header or c.func() == std.table.footer {
      for inner in c.fields().at("children", default: ()) { walk.push((index, normalize-child(inner))) }
    } else {
      walk.push((index, c))
    }
  }
  for (index, c) in walk {
    if c.func() == std.table.hline {
      let y-field = c.fields().at("y", default: auto)
      let y = if y-field == auto { calc.quo(cursor, ncols) } else { y-field }
      below-top.push(y)
      if y > 0 { above-bottom.push(y - 1) }
    } else if c.func() != std.table.vline {
      let fields = if c.func() == std.table.cell { c.fields() } else { (:) }
      let colspan = fields.at("colspan", default: 1)
      let rowspan = fields.at("rowspan", default: 1)
      let cell-x = fields.at("x", default: auto)
      let cell-y = fields.at("y", default: auto)
      cursor = advance(cursor, occupied)
      let x = if cell-x == auto { calc.rem(cursor, ncols) } else { cell-x }
      let y = if cell-y == auto { calc.quo(cursor, ncols) } else { cell-y }
      for dy in range(rowspan) {
        for dx in range(colspan) { occupied.push(slot(x + dx, y + dy)) }
      }
      if cell-x != auto or cell-y != auto { header-safe = false }
      if y < header-rows and y + rowspan > header-rows { header-safe = false }
      if header-start == none { header-start = index }
      if header-end == none and y >= header-rows { header-end = index }
      if cell-x == auto and cell-y == auto { cursor = y * ncols + x + colspan }
      cursor = advance(cursor, occupied)
    }
  }

  let children = positional
  let stop = if header-end == none { children.len() } else { header-end }
  let plain(c) = (
    c.func() != std.table.header and c.func() != std.table.footer
      and c.func() != std.table.vline
  )
  let wrap = (
    header-safe and header-rows > 0 and header-start != none
      and children.all(c => c.func() != std.table.header)
      and children.slice(header-start, stop).all(plain)
  )
  let children = if wrap {
    let head = std.table.header(repeat: false, ..children.slice(header-start, stop))
    children.slice(0, header-start) + (head,) + children.slice(stop)
  } else { children }

  // LaTeX tabular moves as one box across page and column boundaries.
  block(breakable: false, spacing: 0pt, std.table(
    ..children,
    ..args.named(),
    inset: (x, y) => {
      let base = inset-at(x, y)
      (
        ..base,
        top: base.top + (if y in below-top { belowrulesep } else { 0pt }),
        bottom: base.bottom + (if y in above-bottom { aboverulesep } else { 0pt }),
      )
    },
  ))
}
