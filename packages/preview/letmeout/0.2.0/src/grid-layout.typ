// Resolve logical cells independently of browser pixels. CSS owns track sizing.
#import "css.typ": fold-sides, fold-alignment

#let field(it, name, default) = it.fields().at(name, default: default)

#let flatten(children, group: "body", repeat: false, level: 0) = {
  let result = ()
  for child in children {
    if child.func() in (std.grid.header, std.grid.footer) {
      let kind = if child.func() == std.grid.header { "header" } else { "footer" }
      result.push((kind: "group-start", group: kind))
      result += flatten(child.children, group: kind, repeat: field(child, "repeat", true), level: if kind == "header" { field(child, "level", 1) } else { 0 })
      result.push((kind: "group-end", group: kind))
    } else {
      result.push((kind: if child.func() == std.grid.hline { "hline" }
        else if child.func() == std.grid.vline { "vline" } else { "cell" },
        node: child, group: group, repeat: repeat, level: level))
    }
  }
  result
}

#let available(occupied, x, y, w, h, columns) = {
  if x < 0 or y < 0 or x + w > columns { return false }
  for yy in range(y, y + h) {
    for xx in range(x, x + w) {
      if str(yy * columns + xx) in occupied { return false }
    }
  }
  true
}

#let resolve(children, columns, min-rows) = {
  let occupied = (:)
  let cells = ()
  let lines = ()
  let cursor = 0
  let last-auto = none
  let rows = min-rows
  for record in flatten(children) {
    if record.kind in ("group-start", "group-end") {
      // Group boundaries belong to rows, never split an existing row.
      let end = if cells.len() == 0 { 0 } else {
        cells.map(c => c.y + c.h).fold(0, calc.max)
      }
      cursor = calc.max(cursor, end * columns)
      continue
    }
    let node = record.node
    if record.kind != "cell" {
      let horizontal = record.kind == "hline"
      let index = field(node, if horizontal { "y" } else { "x" }, auto)
      if index == auto {
        index = if last-auto == none { 0 }
          else if horizontal { last-auto.y + 1 } else { last-auto.x + 1 }
      }
      lines.push((kind: record.kind, node: node, index: index))
      continue
    }
    let x = field(node, "x", auto)
    let y = field(node, "y", auto)
    let w = field(node, "colspan", 1)
    let h = field(node, "rowspan", 1)
    assert(w > 0 and h > 0 and w <= columns,
      message: "letmeout: cell spans must be positive and fit the grid's columns")
    if x == auto and y == auto {
      while not available(occupied, calc.rem(cursor, columns), calc.quo(cursor, columns), w, h, columns) {
        cursor += 1
      }
      x = calc.rem(cursor, columns)
      y = calc.quo(cursor, columns)
      cursor += w
      last-auto = (x: x, y: y)
    } else if x == auto {
      x = 0
      while x < columns and not available(occupied, x, y, w, h, columns) { x += 1 }
    } else if y == auto {
      assert(x >= 0 and x + w <= columns, message: "letmeout: cell column is outside the grid")
      y = 0
      while not available(occupied, x, y, w, h, columns) { y += 1 }
    }
    assert(available(occupied, x, y, w, h, columns),
      message: "letmeout: grid cells overlap or extend beyond the grid")
    for yy in range(y, y + h) {
      for xx in range(x, x + w) { occupied.insert(str(yy * columns + xx), cells.len()) }
    }
    cells.push((node: node, x: x, y: y, w: w, h: h,
      group: record.group, repeat: record.repeat, level: record.level))
    rows = calc.max(rows, y + h)
  }
  // Empty cells are real layout cells, so fills/strokes and row sizes apply.
  for y in range(rows) {
    for x in range(columns) {
      if str(y * columns + x) not in occupied {
        cells.push((node: std.grid.cell[], x: x, y: y, w: 1, h: 1,
          group: "body", repeat: false, level: 0))
      }
    }
  }
  (cells: cells.sorted(key: c => c.y * columns + c.x), lines: lines, rows: rows)
}

// Capture set rules on the native subelements as well as explicit arguments.
// Reading contextual native fields avoids inventing a second set-rule API.
#let normalize(children) = children.map(node => {
  let func = node.func()
  let defaults = if func == std.grid.cell {
    (x: std.grid.cell.x, y: std.grid.cell.y,
     colspan: std.grid.cell.colspan, rowspan: std.grid.cell.rowspan,
     inset: std.grid.cell.inset, align: std.grid.cell.align,
     fill: std.grid.cell.fill, stroke: std.grid.cell.stroke,
     breakable: std.grid.cell.breakable)
  } else if func == std.grid.hline {
    (y: std.grid.hline.y, start: std.grid.hline.start, end: std.grid.hline.end,
     stroke: std.grid.hline.stroke, position: std.grid.hline.position)
  } else if func == std.grid.vline {
    (x: std.grid.vline.x, start: std.grid.vline.start, end: std.grid.vline.end,
     stroke: std.grid.vline.stroke, position: std.grid.vline.position)
  } else if func == std.grid.header {
    (repeat: std.grid.header.repeat, level: std.grid.header.level)
  } else { (repeat: std.grid.footer.repeat) }
  let explicit = node.fields()
  let fields = defaults + explicit
  if func == std.grid.cell {
    if "inset" in explicit { fields.inset = fold-sides(defaults.inset, explicit.inset) }
    if "stroke" in explicit { fields.stroke = fold-sides(defaults.stroke, explicit.stroke, strokes: true) }
    if "align" in explicit { fields.align = fold-alignment(defaults.align, explicit.align) }
  }
  if func == std.grid.cell {
    let body = fields.remove("body")
    func(body, ..fields)
  } else if func in (std.grid.header, std.grid.footer) {
    let nested = fields.remove("children")
    func(..normalize(nested), ..fields)
  } else { func(..fields) }
})
