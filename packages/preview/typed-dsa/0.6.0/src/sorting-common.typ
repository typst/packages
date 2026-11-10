// Shared sorting validation, trace records, styles, and panel rendering.
//
// These abstractions are used by merge, quick, and elementary sorting traces.
// Algorithm-specific state transitions remain in their owning modules.

#import "grid.typ": array-view
#import "@preview/cetz:0.5.2"
#import "style.typ": (
  array-style, indices-style, cell-mark-style, resolve, scaled, validate-style,
  check-cell-customization-options,
)
#import "validate.typ": (
  check-bool, check-comparable, check-enum, check-index, check-integer,
  check-non-empty, check-type, fail, show-value,
)
#import "messages.typ": default-catalog, msg
#import cetz.draw: line, content

// ── Validation ───────────────────────────────────────────────────────────────


#let _active = cell-mark-style(fill: rgb("#FFF3BF"), stroke: 1pt + rgb("#F08C00"))
#let _changed = cell-mark-style(fill: rgb("#E7F5FF"), stroke: 1pt + rgb("#1971C2"))
#let _current = cell-mark-style(fill: rgb("#FFE3E3"), stroke: 1pt + rgb("#E03131"))
#let _minimum = cell-mark-style(fill: rgb("#F3F0FF"), stroke: 1pt + rgb("#7048E8"))
#let _current-minimum = _current + (stripe-fill: rgb("#C4B5FD"))
#let _done = cell-mark-style(fill: rgb("#E6FCF5"), stroke: 1pt + rgb("#099268"))

#let _value-precedes(left-value, right-value, order) = if order == "desc" {
  left-value > right-value
} else {
  left-value < right-value
}

#let _value-precedes-or-equals(left-value, right-value, order) = (
  if order == "desc" {
    left-value >= right-value
  } else {
    left-value <= right-value
  }
)

#let _resolve-sorting-array-style(style, show-indices) = {
  if show-indices and "indices" not in style {
    return style + array-style(indices: indices-style(enabled: true, labels: auto))
  }
  style
}

#let _render-algorithm-caption(style, body, small: false) = {
  let caption-style = resolve(style).algorithm-label-text
  if small {
    caption-style.size = caption-style.at("size", default: 8pt) * 0.875
  }
  text(..caption-style)[#body]
}

// Accepts either a plain array of values or an `array-view(...)` object and
// returns the values together with the style to carry through every step.

#let _create-cell-marks(indices, mark-style) = {
  let cell-marks = ()
  for cell-index in indices {
    if cell-index != none { cell-marks.push((cell-index, mark-style)) }
  }
  cell-marks
}

#let _create-range-marks(start-index, end-index, mark-style) = {
  let cell-marks = ()
  for cell-index in range(start-index, end-index) {
    cell-marks.push((cell-index, mark-style))
  }
  cell-marks
}

#let _render-sorting-panel(label, values, marks, style, show-indices, pointers: (), reserve: false, labels: true) = {
  block(width: 100%, breakable: false)[
    #align(center)[
      #if labels [#_render-algorithm-caption(style, label) #v(0.25em)]
      #array-view(..values, style: _resolve-sorting-array-style(style, show-indices), cell-customizations: marks, pointers: pointers, reserve-pointers: reserve).diagram
    ]
  ]
}

#let _create-sorting-step(label, values, marks, style, show-indices, phase: none, diagram: none, pointers: (), reserve: false, labels: true) = (
  label: label,
  values: values.map(value => value),
  phase: phase,
  diagram: if diagram == none { _render-sorting-panel(label, values.map(value => value), marks, style, show-indices, pointers: pointers, reserve: reserve, labels: labels) } else { diagram },
)

// A role's mark style: the built-in default with an optional per-call override
// (a `cell-mark-style(...)` / `node-mark-style(...)`) merged over it.
#let _resolve-sort-role-style(default-style, override) = if override == none {
  default-style
} else {
  default-style + override
}

// The arrow colour for a pointer: the mark's stroke accent when present,
// otherwise its fill.
#let _sort-role-color(role-style) = {
  if "stroke" in role-style {
    let role-stroke = role-style.stroke
    if type(role-stroke) == stroke { return role-stroke.paint }
    if type(role-stroke) == color { return role-stroke }
    if type(role-stroke) == dictionary {
      return role-stroke.at("paint", default: rgb("#333333"))
    }
  }
  role-style.at("fill", default: rgb("#333333"))
}

// Turns `(index, label)` items into pointer entries drawn above the array,
// coloured and labelled from the role's mark style.
#let _create-sort-pointers(items, role-style) = items.map(pointer-item => (
  index: pointer-item.at(0),
  label: pointer-item.at(1),
  color: _sort-role-color(role-style),
  text: role-style.at("text", default: (:)),
))

// Resolves one marked step. Settled cells keep their sorted styling while
// `pointers` additionally draws labelled arrows above active cells.
#let _create-marked-sorting-step(label, values, items, role-style, style, pointers, settled: (), labels: true) = {
  let cell-marks = (
    settled
      + _create-cell-marks(
        items.map(pointer-item => pointer-item.at(0)),
        role-style,
      )
  )
  let pointer-marks = if pointers {
    _create-sort-pointers(items, role-style)
  } else {
    ()
  }
  _create-sorting-step(
    label,
    values,
    cell-marks,
    style,
    true,
    pointers: pointer-marks,
    labels: labels,
  )
}

#let _render-sorting-array-row(parts, style, show-indices) = align(center)[
  #grid(columns: parts.len(), column-gutter: 0.45em, ..parts.map(part => array-view(..part, style: _resolve-sorting-array-style(style, show-indices)).diagram))
]

#let _render-partition-tree-rows(levels, style, show-indices, start: 0) = align(center)[
  #for depth in range(start, levels.len()) [
    #_render-sorting-array-row(levels.at(depth), style, show-indices)
    #if depth < levels.len() - 1 [#v(0.6em)]
  ]
]

#let _render-sorting-text(pos, body, text-style) = {
  let style = text-style
  let rotation = style.at("rotation", default: 0deg)
  if "rotation" in style { let _ = style.remove("rotation") }
  content(pos, text(..style)[#body], angle: rotation)
}

#let _render-sort-phase-brace(label, bottom, top, x, resolved-style) = {
  let middle = (bottom + top) / 2
  line(
    (x, top), (x - 0.18, top - 0.18), (x - 0.18, middle + 0.25),
    (x - 0.42, middle), (x - 0.18, middle - 0.25), (x - 0.18, bottom + 0.18), (x, bottom),
    stroke: resolved-style.box-stroke,
  )
  if label != none { _render-sorting-text((x - 1.05, middle), label, resolved-style.algorithm-label-text + (weight: "bold")) }
}

#let _render-sort-phase-indicator(label, levels, style) = {
  let resolved-style = resolve(style)
  let height = calc.max(1, levels.len()) * (resolved-style.box-h + 0.7)
  scaled(resolved-style, cetz.canvas({ _render-sort-phase-brace(label, 0, height, 0, resolved-style) }))
}


#let sort-sequence(steps, columns: 3, gap: 1em, row-gap: 1em) = {
  check-type(
    "sort-sequence()", "steps", steps, (array,),
    fix: "pass the steps array of a sorting result, for example merge-sort(values).steps",
  )
  check-integer("sort-sequence()", "columns:", columns, min: 1)
  let cells = ()
  for step in steps {
    cells.push(if type(step) == dictionary and "diagram" in step { step.diagram } else { step })
  }
  grid(columns: columns, column-gutter: gap, row-gutter: row-gap, ..cells)
}

#let _create-sort-result(steps, result, columns, gap, row-gap, diagram: auto) = (
  steps: steps,
  result: result,
  diagram: if diagram == auto { sort-sequence(steps, columns: columns, gap: gap, row-gap: row-gap) } else { diagram },
)
