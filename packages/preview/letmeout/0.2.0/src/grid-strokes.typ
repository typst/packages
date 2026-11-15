// Resolve edge ownership before producing HTML. In particular, a `none` line
// must erase a cell stroke, rather than painting a transparent overlay over it.
#import "css.typ": sides, stroke-value, direction
#import "grid-layout.typ": field

#let per-cell(value, x, y) = {
  if type(value) == function { value(x, y) }
  else if type(value) == array {
    if value.len() == 0 { (:) } else { value.at(calc.rem(x, value.len())) }
  } else { value }
}

#let cell-strokes(cell, style) = {
  let own = sides(field(cell.node, "stroke", (:)), default: auto)
  let outer = sides(per-cell(style, cell.x, cell.y))
  let result = (:)
  for side in own.keys() {
    let base = stroke-value(outer.at(side))
    let inner = own.at(side)
    result.insert(side, (stroke: if inner == auto { base } else { stroke-value(inner, base: base) },
      priority: if inner == auto { 0 } else { 1 }))
  }
  result
}

#let resolve-strokes(layout, style, columns, col-gutter, row-gutter) = {
  let candidates = ()
  let row-collapse = row-gutter.all(v => v == 0pt)
  let col-collapse = col-gutter.all(v => v == 0pt)
  let rtl = direction() == "rtl"
  for (i, cell) in layout.cells.enumerate() {
    let strokes = cell-strokes(cell, style)
    for (kind, index, after, first, last, side) in (
      ("hline", cell.y, false, cell.x, cell.x + cell.w, "top"),
      ("hline", cell.y + cell.h - 1, true, cell.x, cell.x + cell.w, "bottom"),
      ("vline", cell.x, false, cell.y, cell.y + cell.h, if rtl { "right" } else { "left" }),
      ("vline", cell.x + cell.w - 1, true, cell.y, cell.y + cell.h, if rtl { "left" } else { "right" }),
    ) {
      let value = strokes.at(side)
      candidates.push((kind: kind, index: index, after: after, first: first, last: last,
        stroke: value.stroke, priority: value.priority, source: i))
    }
  }
  for (i, line) in layout.lines.enumerate() {
    let horizontal = line.kind == "hline"
    let pos = field(line.node, "position", if horizontal { top } else { start })
    let after = if horizontal { pos == bottom }
      else if pos == right { not rtl } else if pos == left { rtl } else { pos == end }
    let count = if horizontal { layout.rows } else { columns }
    let cross-count = if horizontal { columns } else { layout.rows }
    let first = field(line.node, "start", 0)
    let last = field(line.node, "end", none)
    if last == none { last = cross-count }
    assert(line.index >= 0 and line.index <= count and (not after or line.index < count),
      message: "letmeout: grid line is outside the grid")
    assert(first >= 0 and first < last and last <= cross-count,
      message: "letmeout: grid line range must fit the grid")
    candidates.push((kind: line.kind, index: line.index, after: after, first: first, last: last,
      stroke: stroke-value(field(line.node, "stroke", 1pt + black)),
      priority: 2, source: layout.cells.len() + i))
  }
  let edges = (:)
  for edge in candidates {
    let collapse = if edge.kind == "hline" { row-collapse } else { col-collapse }
    if collapse and edge.after { edge.index += 1; edge.after = false }
    for segment in range(edge.first, edge.last) {
      let key = edge.kind + ":" + str(edge.index) + ":" + repr(edge.after) + ":" + str(segment)
      let old = edges.at(key, default: none)
      let win = old == none or edge.priority > old.priority
      if old != none and edge.priority == old.priority {
        // A later explicit separator replaces earlier separators, even with none.
        if edge.priority == 2 { win = true }
        else if edge.stroke != none {
          win = old.stroke == none or edge.stroke.thickness.to-absolute() >= old.stroke.thickness.to-absolute()
        }
      }
      if win { edges.insert(key, edge + (first: segment, last: segment + 1)) }
    }
  }
  let stride = calc.max(columns, layout.rows) + 2
  let ordered = edges.values().sorted(key: e => (
    if e.kind == "hline" { 0 } else { 1 }) * stride * stride * 2
      + e.index * stride * 2 + (if e.after { stride } else { 0 }) + e.first)
  let merged = ()
  for edge in ordered {
    if edge.stroke == none { continue }
    if merged.len() > 0 {
      let previous = merged.last()
      if (previous.kind == edge.kind and previous.index == edge.index and previous.after == edge.after
        and previous.source == edge.source and previous.last == edge.first) {
        previous.last = edge.last
        let _ = merged.pop()
        merged.push(previous)
        continue
      }
    }
    merged.push(edge)
  }
  merged
}
