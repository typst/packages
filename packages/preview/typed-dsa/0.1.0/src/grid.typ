// Array and matrix diagrams.
//
// These helpers draw compact cell grids using the same linear-structure style
// keys as the rest of the package.

#import "@preview/cetz:0.5.2"
#import "style.typ": resolve, scaled
#import cetz.draw: rect, content

#let _key-str(key) = if type(key) == array {
  key.map(k => str(k)).join(",")
} else {
  str(key)
}

#let _custom-at(customizations, key) = {
  let k = _key-str(key)
  if type(customizations) == dictionary { return customizations.at(k, default: none) }
  for item in customizations {
    if item.len() >= 2 and _key-str(item.at(0)) == k { return item.at(1) }
  }
  none
}

#let _text-style(style) = {
  let res = style
  if "color" in res {
    res.fill = res.color
    let _ = res.remove("color")
  }
  res
}

#let _cell(x, y, body, th, custom: none, fill: auto, w: auto, h: auto) = {
  let ww = if w == auto { th.box-w } else { w }
  let hh = if h == auto { th.box-h } else { h }
  let base-fill = if fill == auto { th.box-fill } else { fill }
  let f = if custom != none and "fill" in custom { custom.fill } else { base-fill }
  let s = if custom != none and "stroke" in custom { custom.stroke } else { th.box-stroke }
  let text-style = th.node-text
  if custom != none and "text" in custom { text-style = text-style + custom.text }
  text-style = _text-style(text-style)
  let rotation = text-style.at("rotation", default: 0deg)
  if "rotation" in text-style { let _ = text-style.remove("rotation") }
  rect((x, y), (x + ww, y + hh), fill: f, stroke: s)
  content((x + ww / 2, y + hh / 2), text(..text-style)[#body], angle: rotation)
}

#let _index-config(th) = {
  let spec = th.at("indices", default: false)
  if spec in (false, none) { return none }
  if type(spec) == dictionary {
    let enabled = spec.at("enabled", default: true)
    if not enabled { return none }
    let labels = spec.at("labels", default: auto)
    let offset = spec.at("offset", default: (0, -0.28))
    let text-style = th.label-text
    for key in ("size", "font", "weight", "style") {
      if key in spec { text-style.insert(key, spec.at(key)) }
    }
    if "color" in spec {
      text-style.fill = spec.color
    }
    if "text" in spec {
      text-style = text-style + spec.text
    }
    return (enabled: true, labels: labels, offset: offset, text: _text-style(text-style))
  }
  none
}

#let _array-render(vals, th, cell-customizations) = scaled(th, cetz.canvas({
  let index-config = _index-config(th)
  for (i, v) in vals.enumerate() {
    _cell(i * th.box-w, 0, v, th, custom: _custom-at(cell-customizations, i))
    if index-config != none {
      let labels = index-config.labels
      let label = if labels == auto { i }
        else if type(labels) == array and i < labels.len() { labels.at(i) }
        else { none }
      if label != none {
        let dx = index-config.offset.at(0)
        let dy = index-config.offset.at(1)
        content((i * th.box-w + th.box-w / 2 + dx, dy), text(..index-config.text)[#label])
      }
    }
  }
}))

#let array-view(style: (:), cell-customizations: (), ..vals) = (
  diagram: _array-render(vals.pos(), resolve(style), cell-customizations),
)

#let _matrix-render(rows, th, cell-customizations, row-labels, column-labels) = {
  let rcount = rows.len()
  let ccount = 0
  for row in rows { ccount = calc.max(ccount, row.len()) }
  scaled(th, cetz.canvas({
    for r in range(rcount) {
      let row = rows.at(r)
      for c in range(ccount) {
        let body = if c < row.len() { row.at(c) } else { [] }
        _cell(c * th.box-w, -r * th.box-h, body, th, custom: _custom-at(cell-customizations, (r, c)))
      }
      if row-labels != none and r < row-labels.len() {
        content((-0.42, -r * th.box-h + th.box-h / 2), text(..th.label-text)[#row-labels.at(r)])
      }
    }
    if column-labels != none {
      for c in range(calc.min(column-labels.len(), ccount)) {
        content((c * th.box-w + th.box-w / 2, th.box-h + 0.32), text(..th.label-text)[#column-labels.at(c)])
      }
    }
  }))
}

#let matrix(rows, style: (:), cell-customizations: (), row-labels: none, column-labels: none) = (
  diagram: _matrix-render(rows, resolve(style), cell-customizations, row-labels, column-labels),
)

#let _sequence-arrow(label) = align(horizon)[
  #set align(center)
  #if label != none [
    #text(size: 8pt, label) \
  ]
  #text(size: 1.3em, $arrow.r$)
]

#let _sequence-panel(step, mode) = {
  if type(step) == dictionary and mode == "result" and "result" in step {
    return step.result.diagram
  }
  if type(step) == dictionary and mode == "after" and "after" in step {
    return step.after
  }
  if type(step) == dictionary and mode == "before" and "before" in step {
    return step.before
  }
  if type(step) == dictionary and "diagram" in step {
    return step.diagram
  }
  step
}

#let sequence(columns: 1, gap: 1em, row-gap: 1em, mode: "all", ..steps) = {
  assert(mode in ("all", "diagram", "before", "after", "result"), message: "sequence mode must be \"all\", \"before\", \"after\", or \"result\"")
  let cells = ()
  for step in steps.pos() {
    let is-step = type(step) == dictionary and ("before" in step or "after" in step or "result" in step)
    if mode not in ("all", "diagram") and is-step {
      if cells.len() == 0 and "before" in step {
        cells.push(step.before)
      }
      cells.push(_sequence-arrow(step.at("label", default: none)))
      cells.push(_sequence-panel(step, mode))
    } else {
      cells.push(_sequence-panel(step, mode))
    }
  }
  grid(columns: columns, column-gutter: gap, row-gutter: row-gap, ..cells)
}
