// Automatic sorting traces rendered as array diagrams.

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
#import "messages.typ": default-catalog, resolve-catalog, msg
#import cetz.draw: line, rect, content

// ── Validation ───────────────────────────────────────────────────────────────

#let sort-orders = ("asc", "desc")

// Role overrides restyle the cells an algorithm marks, so they take the same
// options as any other cell customization.
#let _check-sort-role-override(where, what, override) = {
  if override == none { return }
  check-cell-customization-options(where, what, override)
}

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
#let _resolve-array-input(where, array-input) = {
  if type(array-input) == dictionary and "values" in array-input {
    return (
      array-input.values,
      array-input.at("style", default: (:)),
    )
  }
  if type(array-input) != array {
    fail(
      where,
      "input is " + show-value(array-input),
      expected: "an array of values, or an array-view(...)",
      fix: "pass the values as an array, for example (5, 3, 8)",
    )
  }
  (array-input, (:))
}

// A sorting trace orders values against each other and needs something to
// order, so both preconditions are checked before any step is generated.
#let _resolve-sorting-input(where, array-input) = {
  let (values, style) = _resolve-array-input(where, array-input)
  check-non-empty(where, "values", values, fix: "pass at least one value to sort")
  check-comparable(where, "values", values)
  validate-style(where, style)
  (values, style)
}

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

#let _merge-sorted-values(left, right, order) = {
  let merged-values = ()
  let left-index = 0
  let right-index = 0
  while left-index < left.len() and right-index < right.len() {
    if _value-precedes-or-equals(
      left.at(left-index),
      right.at(right-index),
      order,
    ) {
      merged-values.push(left.at(left-index))
      left-index += 1
    } else {
      merged-values.push(right.at(right-index))
      right-index += 1
    }
  }
  while left-index < left.len() {
    merged-values.push(left.at(left-index))
    left-index += 1
  }
  while right-index < right.len() {
    merged-values.push(right.at(right-index))
    right-index += 1
  }
  merged-values
}

// Merging assumes both inputs are already ordered; merging unsorted input
// would draw a "merged" array that is not in fact sorted.
#let _check-merge-input-sorted(where, what, values, order) = {
  for value-index in range(1, values.len()) {
    let value = values.at(value-index)
    let previous-value = values.at(value-index - 1)
    if not _value-precedes(value, previous-value, order) { continue }
    fail(
      where,
      what + " is not sorted: " + show-value(value) + " comes after " + show-value(previous-value),
      expected: "an array already sorted in \"" + order + "\" order",
      fix: "sort " + what + " before merging, or pass order: \"" + (if order == "asc" { "desc" } else { "asc" }) + "\"",
    )
  }
}

#let _values-are-sorted-for-merge(values, order) = {
  for value-index in range(1, values.len()) {
    if _value-precedes(
      values.at(value-index),
      values.at(value-index - 1),
      order,
    ) {
      return false
    }
  }
  true
}

#let _render-merge-operation-panel(label, left, right, output, left-marks, right-marks, output-marks, style, show-indices, cursors: (:), reserve: false, labels: true, message-catalog: default-catalog) = align(center)[
  #if labels [#_render-algorithm-caption(style, label) #v(0.25em)]
  #grid(
    columns: 3, column-gutter: 0.8em,
    align(center)[#if labels [#_render-algorithm-caption(style, msg(message-catalog, "sort.left"), small: true) #v(0.15em)] #array-view(..left, style: _resolve-sorting-array-style(style, show-indices), cell-customizations: left-marks, pointers: cursors.at("left", default: ()), reserve-pointers: reserve).diagram],
    align(center)[#if labels [#_render-algorithm-caption(style, msg(message-catalog, "sort.right"), small: true) #v(0.15em)] #array-view(..right, style: _resolve-sorting-array-style(style, show-indices), cell-customizations: right-marks, pointers: cursors.at("right", default: ()), reserve-pointers: reserve).diagram],
    align(center)[#if labels [#_render-algorithm-caption(style, msg(message-catalog, "sort.result"), small: true) #v(0.15em)] #array-view(..output, style: _resolve-sorting-array-style(style, show-indices), cell-customizations: output-marks, pointers: cursors.at("output", default: ()), reserve-pointers: reserve).diagram],
  )
]

#let _create-merge-operation-step(label, left, right, output, left-marks, right-marks, output-marks, style, show-indices, cursors: (:), reserve: false, labels: true, message-catalog: default-catalog) = (
  label: label,
  left: left.map(value => value),
  right: right.map(value => value),
  values: output.map(value => value),
  diagram: _render-merge-operation-panel(label, left, right, output.map(value => value), left-marks, right-marks, output-marks, style, show-indices, cursors: cursors, reserve: reserve, labels: labels, message-catalog: message-catalog),
)

#let _create-merge-cursors(
  left-index,
  right-index,
  output-index,
  left,
  right,
  output,
  pointers,
  input-style: _active,
  output-style: _changed,
) = (
  left: if pointers and left-index < left.len() {
    _create-sort-pointers(((left-index, [i]),), input-style)
  } else {
    ()
  },
  right: if pointers and right-index < right.len() {
    _create-sort-pointers(((right-index, [j]),), input-style)
  } else {
    ()
  },
  output: if pointers and output-index < output.len() {
    _create-sort-pointers(((output-index, [i+j]),), output-style)
  } else {
    ()
  },
)

#let _create-partition-marks(left, right, pivot, arr) = {
  let marks = ()
  if left != none and left < arr.len() {
    marks.push((left, if left == pivot { _current-minimum } else { _current }))
  }
  if right != none and right >= 0 and right < arr.len() {
    marks.push((right, if right == pivot { _minimum + (stripe-fill: _active.fill) } else { _active }))
  }
  if pivot != none and pivot >= 0 and pivot < arr.len() and pivot not in (left, right) {
    marks.push((pivot, _minimum))
  }
  marks
}

#let _render-partition-panel(label, arr, left, right, pivot, marks, style, show-indices, pointers: (), reserve: false, labels: true, message-catalog: default-catalog) = align(center)[
  #if labels [#_render-algorithm-caption(style, label) #v(0.15em) #_render-algorithm-caption(style, msg(message-catalog, "sort.pivot-info", arr.at(pivot), pivot, left, right), small: true) #v(0.2em)]
  #array-view(..arr, style: _resolve-sorting-array-style(style, show-indices), cell-customizations: marks, pointers: pointers, reserve-pointers: reserve).diagram
]

#let _create-partition-step(label, arr, left, right, pivot, marks, style, show-indices, pointers: (), reserve: false, labels: true, message-catalog: default-catalog) = (
  label: label,
  values: arr.map(value => value),
  left: left,
  right: right,
  pivot: pivot,
  diagram: _render-partition-panel(label, arr.map(value => value), left, right, pivot, marks, style, show-indices, pointers: pointers, reserve: reserve, labels: labels, message-catalog: message-catalog),
)

#let _create-partition-cursors(left-index, right-index, pivot-index, values, pointers) = {
  if not pointers { return () }
  let cursors = ()
  if left-index >= 0 and left-index < values.len() {
    cursors += _create-sort-pointers(((left-index, [i]),), _current)
  }
  if right-index >= 0 and right-index < values.len() {
    cursors += _create-sort-pointers(((right-index, [j]),), _active)
  }
  if pivot-index >= 0 and pivot-index < values.len() {
    cursors += _create-sort-pointers(((pivot-index, [pivot]),), _minimum)
  }
  cursors
}

#let partition-step(arr, order: "asc", pivot: "middle", pointers: false, labels: true, language: "en", messages: (:)) = {
  let _where = "partition-step()"
  check-enum(_where, "order:", order, sort-orders)
  check-enum(_where, "pivot:", pivot, ("middle", "last"))
  check-bool(_where, "pointers:", pointers)
  check-bool(_where, "labels:", labels)
  let message-catalog = resolve-catalog(language: language, messages: messages)
  let _create-partition-step = _create-partition-step.with(message-catalog: message-catalog)
  let pivot-mode = pivot
  let (values, style) = _resolve-sorting-input(_where, arr)
  let show-indices = true
  let partition-values = values.map(value => value)
  let pivot = calc.floor(partition-values.len() / 2)
  let pivot-value = if partition-values.len() == 0 { none } else { partition-values.at(pivot) }
  let left = 0
  let right = partition-values.len() - 1
  let steps = ()
  if pivot-mode == "last" {
    let pivot = partition-values.len() - 1
    let pivot-value = partition-values.at(pivot)
    let i = 0
    steps.push(_create-partition-step(msg(message-catalog, "sort.start"), partition-values, i, 0, pivot, _create-partition-marks(i, 0, pivot, partition-values), style, show-indices, pointers: _create-partition-cursors(i, 0, pivot, partition-values, pointers), reserve: pointers, labels: labels))
    steps.push(_create-partition-step(msg(message-catalog, "sort.select-last-pivot", pivot-value), partition-values, i, 0, pivot, _create-partition-marks(i, 0, pivot, partition-values), style, show-indices, pointers: _create-partition-cursors(i, 0, pivot, partition-values, pointers), reserve: pointers, labels: labels))
    for j in range(0, pivot) {
      steps.push(_create-partition-step(msg(message-catalog, "sort.compare-pivot", partition-values.at(j), pivot-value), partition-values, i, j, pivot, _create-partition-marks(i, j, pivot, partition-values), style, show-indices, pointers: _create-partition-cursors(i, j, pivot, partition-values, pointers), reserve: pointers, labels: labels))
      if _value-precedes-or-equals(partition-values.at(j), pivot-value, order) {
        let a = partition-values.at(i)
        let b = partition-values.at(j)
        partition-values.at(i) = b
        partition-values.at(j) = a
        steps.push(_create-partition-step(msg(message-catalog, "sort.swap", a, b), partition-values, i, j, pivot, _create-cell-marks((i, j), _changed) + _create-cell-marks((pivot,), _minimum), style, show-indices, pointers: _create-partition-cursors(i, j, pivot, partition-values, pointers), reserve: pointers, labels: labels))
        i += 1
        steps.push(_create-partition-step(msg(message-catalog, "sort.advance-i", i), partition-values, i, j, pivot, _create-partition-marks(i, j, pivot, partition-values), style, show-indices, pointers: _create-partition-cursors(i, j, pivot, partition-values, pointers), reserve: pointers, labels: labels))
      }
    }
    let a = partition-values.at(i)
    partition-values.at(i) = partition-values.at(pivot)
    partition-values.at(pivot) = a
    steps.push(_create-partition-step(msg(message-catalog, "sort.place-pivot", pivot-value), partition-values, i, pivot, i, _create-cell-marks((i, pivot), _changed), style, show-indices, pointers: _create-partition-cursors(i, pivot, i, partition-values, pointers), reserve: pointers, labels: labels))
    steps.push(_create-partition-step(msg(message-catalog, "sort.partitioned"), partition-values, i, pivot, i, _create-cell-marks((i,), _done), style, show-indices, reserve: pointers, labels: labels))
    return (steps: steps, result: partition-values, left: i, right: pivot, pivot: i, diagram: grid(columns: 1, row-gutter: 0.8em, ..steps.map(step => step.diagram)))
  }
  steps.push(_create-partition-step(msg(message-catalog, "sort.start"), partition-values, left, right, pivot, _create-partition-marks(left, right, pivot, partition-values), style, show-indices, labels: labels))
  steps.push(_create-partition-step(msg(message-catalog, "sort.select-pivot", pivot-value), partition-values, left, right, pivot, _create-partition-marks(left, right, pivot, partition-values), style, show-indices, labels: labels))
  while left <= right {
    while left <= right and _value-precedes(partition-values.at(left), pivot-value, order) {
      steps.push(_create-partition-step(msg(message-catalog, "sort.i-satisfies", partition-values.at(left)), partition-values, left, right, pivot, _create-partition-marks(left, right, pivot, partition-values), style, show-indices, labels: labels))
      left += 1
    }
    while left <= right and _value-precedes(pivot-value, partition-values.at(right), order) {
      steps.push(_create-partition-step(msg(message-catalog, "sort.j-satisfies", partition-values.at(right)), partition-values, left, right, pivot, _create-partition-marks(left, right, pivot, partition-values), style, show-indices, labels: labels))
      right -= 1
    }
    if left <= right {
      steps.push(_create-partition-step(msg(message-catalog, "sort.compare", partition-values.at(left), partition-values.at(right)), partition-values, left, right, pivot, _create-partition-marks(left, right, pivot, partition-values), style, show-indices, labels: labels))
      let a = partition-values.at(left)
      let b = partition-values.at(right)
      partition-values.at(left) = b
      partition-values.at(right) = a
      if pivot == left { pivot = right }
      else if pivot == right { pivot = left }
      steps.push(_create-partition-step(msg(message-catalog, "sort.swap", a, b), partition-values, left, right, pivot, _create-cell-marks((left, right), _changed), style, show-indices, labels: labels))
      left += 1
      right -= 1
    }
  }
  steps.push(_create-partition-step(msg(message-catalog, "sort.partitioned"), partition-values, left, right, pivot, _create-range-marks(0, partition-values.len(), _done), style, show-indices, labels: labels))
  (
    steps: steps,
    result: partition-values,
    left: left,
    right: right,
    pivot: pivot,
    diagram: grid(columns: 1, row-gutter: 0.8em, ..steps.map(step => step.diagram)),
  )
}

#let merge-operation(left, right, order: "asc", pointers: true, labels: true, language: "en", messages: (:)) = {
  let _where = "merge-operation()"
  check-enum(_where, "order:", order, sort-orders)
  check-bool(_where, "pointers:", pointers)
  check-bool(_where, "labels:", labels)
  let message-catalog = resolve-catalog(language: language, messages: messages)
  let _create-merge-operation-step = _create-merge-operation-step.with(message-catalog: message-catalog)
  let (left, left-style) = _resolve-array-input(_where, left)
  let (right, right-style) = _resolve-array-input(_where, right)
  let style = if left-style != (:) { left-style } else { right-style }
  validate-style(_where, style)
  let show-indices = true
  check-non-empty(_where, "left and right", left + right, fix: "pass at least one value to merge")
  check-comparable(_where, "left and right values", left + right)
  _check-merge-input-sorted(_where, "left", left, order)
  _check-merge-input-sorted(_where, "right", right, order)
  let output = ()
  for _ in range(left.len() + right.len()) { output.push([]) }
  let i = 0
  let j = 0
  let k = 0
  let steps = (_create-merge-operation-step(
    msg(message-catalog, "sort.start-merge"), left, right, output, (), (), (), style, show-indices,
    cursors: _create-merge-cursors(i, j, k, left, right, output, pointers), reserve: pointers, labels: labels,
  ),)
  while i < left.len() and j < right.len() {
    steps.push(_create-merge-operation-step(
      msg(message-catalog, "sort.compare", left.at(i), right.at(j)), left, right, output,
      _create-cell-marks((i,), _active), _create-cell-marks((j,), _active), (), style, show-indices,
      cursors: _create-merge-cursors(i, j, k, left, right, output, pointers), reserve: pointers, labels: labels,
    ))
    if _value-precedes-or-equals(left.at(i), right.at(j), order) {
      output.at(k) = left.at(i)
      steps.push(_create-merge-operation-step(
        msg(message-catalog, "sort.take", left.at(i)), left, right, output,
        _create-cell-marks((i,), _changed), (), _create-cell-marks((k,), _changed), style, show-indices,
        cursors: _create-merge-cursors(i, j, k, left, right, output, pointers, input-style: _changed), reserve: pointers, labels: labels,
      ))
      i += 1
    } else {
      output.at(k) = right.at(j)
      steps.push(_create-merge-operation-step(
        msg(message-catalog, "sort.take", right.at(j)), left, right, output,
        (), _create-cell-marks((j,), _changed), _create-cell-marks((k,), _changed), style, show-indices,
        cursors: _create-merge-cursors(i, j, k, left, right, output, pointers, input-style: _changed), reserve: pointers, labels: labels,
      ))
      j += 1
    }
    k += 1
  }
  while i < left.len() {
    output.at(k) = left.at(i)
    steps.push(_create-merge-operation-step(
      msg(message-catalog, "sort.take-remaining", left.at(i)), left, right, output,
      _create-cell-marks((i,), _changed), (), _create-cell-marks((k,), _changed), style, show-indices,
      cursors: _create-merge-cursors(i, j, k, left, right, output, pointers, input-style: _changed), reserve: pointers, labels: labels,
    ))
    i += 1
    k += 1
  }
  while j < right.len() {
    output.at(k) = right.at(j)
    steps.push(_create-merge-operation-step(
      msg(message-catalog, "sort.take-remaining", right.at(j)), left, right, output,
      (), _create-cell-marks((j,), _changed), _create-cell-marks((k,), _changed), style, show-indices,
      cursors: _create-merge-cursors(i, j, k, left, right, output, pointers, input-style: _changed), reserve: pointers, labels: labels,
    ))
    j += 1
    k += 1
  }
  steps.push(_create-merge-operation-step(
    msg(message-catalog, "sort.merged"), left, right, output,
    (), (), _create-range-marks(0, output.len(), _done), style, show-indices, reserve: pointers, labels: labels,
  ))
  (
    steps: steps,
    result: output,
    diagram: grid(columns: 1, row-gutter: 0.8em, ..steps.map(step => step.diagram)),
  )
}

#let _render-sorting-text(pos, body, text-style) = {
  let style = text-style
  let rotation = style.at("rotation", default: 0deg)
  if "rotation" in style { let _ = style.remove("rotation") }
  content(pos, text(..style)[#body], angle: rotation)
}

#let _calculate-merge-tree-depth(values) = if values.len() <= 1 { 0 } else {
  let middle = calc.floor(values.len() / 2)
  1 + calc.max(_calculate-merge-tree-depth(values.slice(0, middle)), _calculate-merge-tree-depth(values.slice(middle)))
}

#let _calculate-array-node-center(start, end, pitch) = (start + end) / 2 * pitch

#let _render-tree-array(values, start, end, y, resolved-style, pitch, show-indices, mark: none) = {
  let x = _calculate-array-node-center(start, end, pitch) - values.len() * resolved-style.box-w / 2
  let fill = if mark == none { resolved-style.box-fill } else { mark.fill }
  let stroke = if mark == none { resolved-style.box-stroke } else { mark.stroke }
  for (i, value) in values.enumerate() {
    let cell-x = x + i * resolved-style.box-w
    rect((cell-x, y), (cell-x + resolved-style.box-w, y + resolved-style.box-h), fill: fill, stroke: stroke)
    _render-sorting-text((cell-x + resolved-style.box-w / 2, y + resolved-style.box-h / 2), value, resolved-style.value-text)
    if show-indices {
      _render-sorting-text((cell-x + resolved-style.box-w / 2, y - 0.28), i, resolved-style.index-text)
    }
  }
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

#let _render-merge-divide-edges(values, start, end, depth, max-depth, resolved-style, pitch, row-gap) = {
  if values.len() <= 1 { return }
  let middle = calc.floor(values.len() / 2)
  let split = start + middle
  let parent = (_calculate-array-node-center(start, end, pitch), (max-depth - depth) * row-gap)
  for child in ((start, split), (split, end)) {
    let child-center = _calculate-array-node-center(child.at(0), child.at(1), pitch)
    let child-y = (max-depth - depth - 1) * row-gap
    line(parent, (child-center, child-y + resolved-style.box-h), stroke: resolved-style.box-stroke, mark: (end: ">"))
  }
  _render-merge-divide-edges(values.slice(0, middle), start, split, depth + 1, max-depth, resolved-style, pitch, row-gap)
  _render-merge-divide-edges(values.slice(middle), split, end, depth + 1, max-depth, resolved-style, pitch, row-gap)
}

#let _render-merge-divide-nodes(values, start, end, depth, max-depth, resolved-style, pitch, row-gap, show-indices) = {
  _render-tree-array(values, start, end, (max-depth - depth) * row-gap, resolved-style, pitch, show-indices)
  if values.len() <= 1 { return }
  let middle = calc.floor(values.len() / 2)
  let split = start + middle
  _render-merge-divide-nodes(values.slice(0, middle), start, split, depth + 1, max-depth, resolved-style, pitch, row-gap, show-indices)
  _render-merge-divide-nodes(values.slice(middle), split, end, depth + 1, max-depth, resolved-style, pitch, row-gap, show-indices)
}

#let _render-merge-divide-tree(values, style, show-indices, labels: true, message-catalog: default-catalog) = {
  let resolved-style = resolve(style)
  let depth = _calculate-merge-tree-depth(values)
  let pitch = resolved-style.box-w * 1.45
  let row-gap = resolved-style.box-h + 0.8
  scaled(resolved-style, cetz.canvas({
    _render-sort-phase-brace(if labels { msg(message-catalog, "sort.divide-phase") } else { none }, 0, depth * row-gap + resolved-style.box-h, 0, resolved-style)
    _render-merge-divide-edges(values, 0, values.len(), 0, depth, resolved-style, pitch, row-gap)
    _render-merge-divide-nodes(values, 0, values.len(), 0, depth, resolved-style, pitch, row-gap, show-indices)
  }))
}

#let _build-merge-tree-model(values, order, start: 0) = {
  let end = start + values.len()
  if values.len() <= 1 { return (values: values, start: start, end: end, height: 0, left: none, right: none) }
  let middle = calc.floor(values.len() / 2)
  let left = _build-merge-tree-model(values.slice(0, middle), order, start: start)
  let right = _build-merge-tree-model(values.slice(middle), order, start: start + middle)
  (
    values: _merge-sorted-values(left.values, right.values, order),
    start: start,
    end: end,
    height: calc.max(left.height, right.height) + 1,
    left: left,
    right: right,
  )
}

#let _render-merge-tree-edges(model, max-height, resolved-style, pitch, row-gap) = {
  if model.left == none { return }
  for child in (model.left, model.right) {
    _render-merge-tree-edges(child, max-height, resolved-style, pitch, row-gap)
    let child-y = (max-height - child.height) * row-gap
    let parent-y = (max-height - model.height) * row-gap
    line(
      (_calculate-array-node-center(child.start, child.end, pitch), child-y),
      (_calculate-array-node-center(model.start, model.end, pitch), parent-y + resolved-style.box-h),
      stroke: resolved-style.box-stroke,
      mark: (end: ">"),
    )
  }
}

#let _render-merge-tree-nodes(model, max-height, resolved-style, pitch, row-gap, show-indices, final: false) = {
  if model.left != none {
    _render-merge-tree-nodes(model.left, max-height, resolved-style, pitch, row-gap, show-indices)
    _render-merge-tree-nodes(model.right, max-height, resolved-style, pitch, row-gap, show-indices)
  }
  _render-tree-array(model.values, model.start, model.end, (max-height - model.height) * row-gap, resolved-style, pitch, show-indices, mark: if final { _done } else { none })
}

#let _render-merge-tree-diagram(values, order, style, show-indices, labels: true, message-catalog: default-catalog) = {
  let resolved-style = resolve(style)
  let pitch = resolved-style.box-w * 1.45
  let row-gap = resolved-style.box-h + 0.8
  let model = _build-merge-tree-model(values, order)
  scaled(resolved-style, cetz.canvas({
    _render-sort-phase-brace(if labels { msg(message-catalog, "sort.merge-phase") } else { none }, 0, model.height * row-gap + resolved-style.box-h, 0, resolved-style)
    _render-merge-tree-edges(model, model.height, resolved-style, pitch, row-gap)
    _render-merge-tree-nodes(model, model.height, resolved-style, pitch, row-gap, show-indices, final: true)
  }))
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

#let _build-merge-sort-levels(values, order) = {
  if values.len() <= 1 { return (values, ((values,),), ()) }
  let middle = calc.floor(values.len() / 2)
  let (left, left-divide, left-merge) = _build-merge-sort-levels(values.slice(0, middle), order)
  let (right, right-divide, right-merge) = _build-merge-sort-levels(values.slice(middle), order)
  let merged = _merge-sorted-values(left, right, order)
  let divide = ((values,),)
  for depth in range(calc.max(left-divide.len(), right-divide.len())) {
    let row = ()
    if depth < left-divide.len() {
      for part in left-divide.at(depth) { row.push(part) }
    } else {
      for part in left-divide.last() { row.push(part) }
    }
    if depth < right-divide.len() {
      for part in right-divide.at(depth) { row.push(part) }
    } else {
      for part in right-divide.last() { row.push(part) }
    }
    divide.push(row)
  }
  let merge = ()
  for depth in range(calc.max(left-merge.len(), right-merge.len())) {
    let row = ()
    if depth < left-merge.len() {
      for part in left-merge.at(depth) { row.push(part) }
    } else if left-merge.len() > 0 {
      for part in left-merge.last() { row.push(part) }
    }
    if depth < right-merge.len() {
      for part in right-merge.at(depth) { row.push(part) }
    } else if right-merge.len() > 0 {
      for part in right-merge.last() { row.push(part) }
    }
    if row.len() > 0 { merge.push(row) }
  }
  merge.push((merged,))
  (merged, divide, merge)
}

#let merge-sort(arr, order: "asc", labels: true, language: "en", messages: (:)) = {
  let _where = "merge-sort()"
  check-enum(_where, "order:", order, sort-orders)
  check-bool(_where, "labels:", labels)
  let message-catalog = resolve-catalog(language: language, messages: messages)
  let _render-merge-divide-tree = _render-merge-divide-tree.with(message-catalog: message-catalog)
  let _render-merge-tree-diagram = _render-merge-tree-diagram.with(message-catalog: message-catalog)
  let (values, style) = _resolve-sorting-input(_where, arr)
  let (result, divide-levels, merge-levels) = _build-merge-sort-levels(values, order)
  let steps = (
    (label: msg(message-catalog, "sort.original"), values: values, diagram: _render-sorting-panel(msg(message-catalog, "sort.original"), values, (), style, true, labels: labels)),
  )
  for depth in range(1, divide-levels.len()) {
    let level = divide-levels.at(depth)
    steps.push((label: msg(message-catalog, "sort.divide"), values: level, diagram: _render-sorting-array-row(level, style, true)))
  }
  for depth in range(0, calc.max(merge-levels.len() - 1, 0)) {
    let level = merge-levels.at(depth)
    if level.len() > 0 {
      steps.push((label: msg(message-catalog, "sort.merge"), values: level, diagram: _render-sorting-array-row(level, style, true)))
    }
  }
  steps.push(_create-sorting-step(msg(message-catalog, "sort.sorted"), result, _create-range-marks(0, result.len(), _done), style, true, labels: labels))
  let diagram = align(center)[
    #if labels [#_render-algorithm-caption(style, msg(message-catalog, "sort.original")) #v(0.25em)]
    #_render-merge-divide-tree(values, style, true, labels: labels)
    #v(1em)
    #_render-merge-tree-diagram(values, order, style, true, labels: labels)
  ]
  _create-sort-result(steps, result, 3, 1em, 1em, diagram: diagram)
}

// Position of the pivot within a subarray of the given length. "first" and
// "last" select the ends; an integer selects that position, clamped to the
// last index for subarrays shorter than the requested position.
#let _resolve-pivot-position(subarray-length, pivot) = {
  if pivot == "first" { 0 }
  else if pivot == "last" { subarray-length - 1 }
  else { calc.min(pivot, subarray-length - 1) }
}

#let _partition-quick-range(values, lower-index, upper-index, order, pivot, steps, style, show-indices, labels: true, message-catalog: default-catalog) = {
  let selected-pivot-index = (
    lower-index
      + _resolve-pivot-position(upper-index - lower-index + 1, pivot)
  )
  if selected-pivot-index != upper-index {
    let selected-pivot-value = values.at(selected-pivot-index)
    values.at(selected-pivot-index) = values.at(upper-index)
    values.at(upper-index) = selected-pivot-value
  }
  let pivot-value = values.at(upper-index)
  let partition-index = lower-index
  for scan-index in range(lower-index, upper-index) {
    if _value-precedes-or-equals(
      values.at(scan-index),
      pivot-value,
      order,
    ) {
      let partition-value = values.at(partition-index)
      values.at(partition-index) = values.at(scan-index)
      values.at(scan-index) = partition-value
      partition-index += 1
    }
  }
  let partition-value = values.at(partition-index)
  values.at(partition-index) = values.at(upper-index)
  values.at(upper-index) = partition-value
  let partition-diagram = align(center)[
    #if labels [#_render-algorithm-caption(style, msg(message-catalog, "sort.partition-around", pivot-value)) #v(0.25em)]
    #_render-sorting-array-row((
      values.slice(lower-index, partition-index),
      (pivot-value,),
      values.slice(partition-index + 1, upper-index + 1),
    ), style, show-indices)
  ]
  steps.push(_create-sorting-step(
    msg(message-catalog, "sort.partition-pivot", pivot-value),
    values,
    _create-cell-marks((partition-index,), _active),
    style,
    show-indices,
    diagram: partition-diagram,
    labels: labels,
  ))
  (values, partition-index, steps)
}

#let _partition-quick-sort-values(values, order, pivot) = {
  if values.len() <= 1 { return (values, none, ()) }
  let partitioned-values = values.map(value => value)
  let last-index = partitioned-values.len() - 1
  let selected-pivot-index = _resolve-pivot-position(
    partitioned-values.len(),
    pivot,
  )
  if selected-pivot-index != last-index {
    let selected-pivot-value = partitioned-values.at(selected-pivot-index)
    partitioned-values.at(selected-pivot-index) = (
      partitioned-values.at(last-index)
    )
    partitioned-values.at(last-index) = selected-pivot-value
  }
  let pivot-value = partitioned-values.at(last-index)
  let partition-index = 0
  for scan-index in range(0, last-index) {
    if _value-precedes-or-equals(
      partitioned-values.at(scan-index),
      pivot-value,
      order,
    ) {
      let partition-value = partitioned-values.at(partition-index)
      partitioned-values.at(partition-index) = (
        partitioned-values.at(scan-index)
      )
      partitioned-values.at(scan-index) = partition-value
      partition-index += 1
    }
  }
  let partition-value = partitioned-values.at(partition-index)
  partitioned-values.at(partition-index) = partitioned-values.at(last-index)
  partitioned-values.at(last-index) = partition-value
  (
    partitioned-values.slice(0, partition-index),
    pivot-value,
    partitioned-values.slice(partition-index + 1),
  )
}

#let _build-quick-sort-levels(values, order, pivot) = {
  if values.len() <= 1 { return (values, ((values,),)) }
  let (lower, pivot-value, upper) = _partition-quick-sort-values(values, order, pivot)
  let (lower-result, lower-levels) = _build-quick-sort-levels(lower, order, pivot)
  let (upper-result, upper-levels) = _build-quick-sort-levels(upper, order, pivot)
  let first = ()
  if lower.len() > 0 { first.push(lower) }
  first.push((pivot-value,))
  if upper.len() > 0 { first.push(upper) }
  let levels = (first,)
  let deeper = calc.max(
    if lower.len() > 1 { lower-levels.len() } else { 0 },
    if upper.len() > 1 { upper-levels.len() } else { 0 },
  )
  for depth in range(deeper) {
    let row = ()
    if lower.len() > 1 {
      let parts = if depth < lower-levels.len() { lower-levels.at(depth) } else { lower-levels.last() }
      for part in parts { row.push(part) }
    } else if lower.len() == 1 {
      row.push(lower)
    }
    row.push((pivot-value,))
    if upper.len() > 1 {
      let parts = if depth < upper-levels.len() { upper-levels.at(depth) } else { upper-levels.last() }
      for part in parts { row.push(part) }
    } else if upper.len() == 1 {
      row.push(upper)
    }
    levels.push(row)
  }
  (lower-result + (pivot-value,) + upper-result, levels)
}

#let _sort-quick-range(values, lower-index, upper-index, order, pivot, steps, style, show-indices, labels: true, message-catalog: default-catalog) = {
  if lower-index >= upper-index { return (values, steps) }
  let (partitioned-values, partition-index, partition-steps) = (
    _partition-quick-range(
      values,
      lower-index,
      upper-index,
      order,
      pivot,
      steps,
      style,
      show-indices,
      labels: labels,
      message-catalog: message-catalog,
    )
  )
  let (left-sorted-values, left-steps) = _sort-quick-range(
    partitioned-values,
    lower-index,
    partition-index - 1,
    order,
    pivot,
    partition-steps,
    style,
    show-indices,
    labels: labels,
    message-catalog: message-catalog,
  )
  _sort-quick-range(
    left-sorted-values,
    partition-index + 1,
    upper-index,
    order,
    pivot,
    left-steps,
    style,
    show-indices,
    labels: labels,
    message-catalog: message-catalog,
  )
}

#let quick-sort(arr, order: "asc", pivot: "last", labels: true, language: "en", messages: (:)) = {
  let _where = "quick-sort()"
  check-enum(_where, "order:", order, sort-orders)
  check-bool(_where, "labels:", labels)
  let message-catalog = resolve-catalog(language: language, messages: messages)
  let _sort-quick-range = _sort-quick-range.with(message-catalog: message-catalog)
  let (values, style) = _resolve-sorting-input(_where, arr)
  if type(pivot) == int {
    check-index(_where, "pivot:", pivot, values.len(), subject: "array")
  } else {
    check-enum(
      _where, "pivot:", pivot, ("first", "last"),
      fix: "use \"first\", \"last\", or an index into the array",
    )
  }
  let steps = (_create-sorting-step(msg(message-catalog, "sort.start"), values, (), style, true, labels: labels),)
  let (result, generated) = _sort-quick-range(values, 0, values.len() - 1, order, pivot, steps, style, true, labels: labels)
  generated.push(_create-sorting-step(msg(message-catalog, "sort.sorted"), result, _create-range-marks(0, result.len(), _done), style, true, labels: labels))
  let (_, levels) = _build-quick-sort-levels(values, order, pivot)
  let diagram = align(center)[
    #if labels [#_render-algorithm-caption(style, msg(message-catalog, "sort.original")) #v(0.25em)]
    #array-view(..values, style: _resolve-sorting-array-style(style, true)).diagram
    #v(0.8em)
    #grid(columns: (auto, auto), column-gutter: 0.8em, _render-sort-phase-indicator(if labels { msg(message-catalog, "sort.partition-phase") } else { none }, levels, style), _render-partition-tree-rows(levels, style, true))
    #v(0.8em)
    #if labels [#_render-algorithm-caption(style, msg(message-catalog, "sort.sorted-array")) #v(0.25em)]
    #array-view(..result, style: _resolve-sorting-array-style(style, true), cell-customizations: _create-range-marks(0, result.len(), _done)).diagram
  ]
  _create-sort-result(generated, result, 1, 1em, 0.8em, diagram: diagram)
}

#let bubble-sort(arr, order: "asc", pointers: true, labels: true, compare: none, swap: none, language: "en", messages: (:)) = {
  let _where = "bubble-sort()"
  check-enum(_where, "order:", order, sort-orders)
  check-bool(_where, "pointers:", pointers)
  check-bool(_where, "labels:", labels)
  _check-sort-role-override(_where, "compare:", compare)
  _check-sort-role-override(_where, "swap:", swap)
  let message-catalog = resolve-catalog(language: language, messages: messages)
  let (values, style) = _resolve-sorting-input(_where, arr)
  let sorted-values = values.map(value => value)
  let comparison-style = _resolve-sort-role-style(_active, compare)
  let swap-style = _resolve-sort-role-style(_changed, swap)
  let steps = (_create-sorting-step(
    msg(message-catalog, "sort.start"),
    sorted-values,
    (),
    style,
    true,
    reserve: pointers,
    labels: labels,
  ),)
  for pass-index in range(sorted-values.len()) {
    let settled-marks = _create-range-marks(
      sorted-values.len() - pass-index,
      sorted-values.len(),
      _done,
    )
    for comparison-index in range(
      0,
      sorted-values.len() - pass-index - 1,
    ) {
      let left-value = sorted-values.at(comparison-index)
      let right-value = sorted-values.at(comparison-index + 1)
      let compared-items = (
        (comparison-index, [j]),
        (comparison-index + 1, [j+1]),
      )
      steps.push(_create-marked-sorting-step(
        msg(message-catalog, "sort.compare", left-value, right-value),
        sorted-values,
        compared-items,
        comparison-style,
        style,
        pointers,
        settled: settled-marks,
        labels: labels,
      ))
      if _value-precedes(right-value, left-value, order) {
        sorted-values.at(comparison-index) = right-value
        sorted-values.at(comparison-index + 1) = left-value
        steps.push(_create-marked-sorting-step(
          msg(message-catalog, "sort.swap", left-value, right-value),
          sorted-values,
          compared-items,
          swap-style,
          style,
          pointers,
          settled: settled-marks,
          labels: labels,
        ))
      }
    }
    if pass-index < sorted-values.len() - 1 {
      let settled-index = sorted-values.len() - pass-index - 1
      steps.push(_create-sorting-step(
        msg(
          message-catalog,
          "sort.settled",
          sorted-values.at(settled-index),
        ),
        sorted-values,
        _create-range-marks(settled-index, sorted-values.len(), _done),
        style,
        true,
        reserve: pointers,
        labels: labels,
      ))
    }
  }
  steps.push(_create-sorting-step(
    msg(message-catalog, "sort.sorted"),
    sorted-values,
    _create-range-marks(0, sorted-values.len(), _done),
    style,
    true,
    reserve: pointers,
    labels: labels,
  ))
  _create-sort-result(steps, sorted-values, 3, 1em, 1em)
}

#let insertion-sort(arr, order: "asc", pointers: true, labels: true, compare: none, swap: none, language: "en", messages: (:)) = {
  let _where = "insertion-sort()"
  check-enum(_where, "order:", order, sort-orders)
  check-bool(_where, "pointers:", pointers)
  check-bool(_where, "labels:", labels)
  _check-sort-role-override(_where, "compare:", compare)
  _check-sort-role-override(_where, "swap:", swap)
  let message-catalog = resolve-catalog(language: language, messages: messages)
  let (values, style) = _resolve-sorting-input(_where, arr)
  let sorted-values = values.map(value => value)
  let comparison-style = _resolve-sort-role-style(_active, compare)
  let swap-style = _resolve-sort-role-style(_changed, swap)
  let steps = (_create-sorting-step(
    msg(message-catalog, "sort.start"),
    sorted-values,
    (),
    style,
    true,
    reserve: pointers,
    labels: labels,
  ),)
  for insertion-index in range(1, sorted-values.len()) {
    let current-index = insertion-index
    while current-index > 0 {
      let left-index = current-index - 1
      let left-value = sorted-values.at(left-index)
      let current-value = sorted-values.at(current-index)
      let compared-items = (
        (left-index, [j-1]),
        (current-index, [j]),
      )
      steps.push(_create-marked-sorting-step(
        msg(message-catalog, "sort.compare", left-value, current-value),
        sorted-values,
        compared-items,
        comparison-style,
        style,
        pointers,
        labels: labels,
      ))
      if not _value-precedes(current-value, left-value, order) { break }
      sorted-values.at(left-index) = current-value
      sorted-values.at(current-index) = left-value
      steps.push(_create-marked-sorting-step(
        msg(message-catalog, "sort.swap", left-value, current-value),
        sorted-values,
        compared-items,
        swap-style,
        style,
        pointers,
        labels: labels,
      ))
      current-index -= 1
    }
  }
  steps.push(_create-sorting-step(
    msg(message-catalog, "sort.sorted"),
    sorted-values,
    _create-range-marks(0, sorted-values.len(), _done),
    style,
    true,
    reserve: pointers,
    labels: labels,
  ))
  _create-sort-result(steps, sorted-values, 3, 1em, 1em)
}

#let selection-sort(arr, order: "asc", pointers: true, labels: true, compare: none, current: none, minimum: none, swap: none, language: "en", messages: (:)) = {
  let _where = "selection-sort()"
  check-enum(_where, "order:", order, sort-orders)
  check-bool(_where, "pointers:", pointers)
  check-bool(_where, "labels:", labels)
  _check-sort-role-override(_where, "compare:", compare)
  _check-sort-role-override(_where, "current:", current)
  _check-sort-role-override(_where, "minimum:", minimum)
  _check-sort-role-override(_where, "swap:", swap)
  let message-catalog = resolve-catalog(language: language, messages: messages)
  let (values, style) = _resolve-sorting-input(_where, arr)
  let sorted-values = values.map(value => value)
  let current-style = _resolve-sort-role-style(_current, current)
  let minimum-style = _resolve-sort-role-style(_minimum, minimum)
  let comparison-style = _resolve-sort-role-style(_active, compare)
  let swap-style = _resolve-sort-role-style(_changed, swap)
  let steps = (_create-sorting-step(
    msg(message-catalog, "sort.start"),
    sorted-values,
    (),
    style,
    true,
    reserve: pointers,
    labels: labels,
  ),)
  for selection-index in range(sorted-values.len()) {
    let settled-marks = _create-range-marks(0, selection-index, _done)
    let minimum-index = selection-index
    for scan-index in range(selection-index + 1, sorted-values.len()) {
      let label = msg(
        message-catalog,
        "sort.selection-status",
        selection-index,
        minimum-index,
        scan-index,
      )
      let selection-style = if selection-index == minimum-index {
        current-style + (stripe-fill: rgb("#C4B5FD"))
      } else {
        current-style
      }
      let cell-marks = (
        settled-marks
          + _create-cell-marks((selection-index,), selection-style)
          + _create-cell-marks((minimum-index,), minimum-style)
          + _create-cell-marks((scan-index,), comparison-style)
      )
      let pointer-marks = if pointers {
        (
          _create-sort-pointers(((selection-index, [i]),), current-style)
            + _create-sort-pointers(((minimum-index, [min]),), minimum-style)
            + _create-sort-pointers(((scan-index, [j]),), comparison-style)
        )
      } else {
        ()
      }
      steps.push(_create-sorting-step(
        label,
        sorted-values,
        cell-marks,
        style,
        true,
        pointers: pointer-marks,
        labels: labels,
      ))
      if _value-precedes(
        sorted-values.at(scan-index),
        sorted-values.at(minimum-index),
        order,
      ) {
        minimum-index = scan-index
      }
    }
    if minimum-index != selection-index {
      let selection-value = sorted-values.at(selection-index)
      let minimum-value = sorted-values.at(minimum-index)
      sorted-values.at(selection-index) = minimum-value
      sorted-values.at(minimum-index) = selection-value
      steps.push(_create-marked-sorting-step(
        msg(
          message-catalog,
          "sort.swap",
          selection-value,
          minimum-value,
        ),
        sorted-values,
        ((selection-index, [i]), (minimum-index, [min])),
        swap-style,
        style,
        pointers,
        settled: settled-marks,
        labels: labels,
      ))
      steps.push(_create-sorting-step(
        msg(message-catalog, "sort.settled", minimum-value),
        sorted-values,
        _create-range-marks(0, selection-index + 1, _done),
        style,
        true,
        reserve: pointers,
        labels: labels,
      ))
    }
  }
  steps.push(_create-sorting-step(
    msg(message-catalog, "sort.sorted"),
    sorted-values,
    _create-range-marks(0, sorted-values.len(), _done),
    style,
    true,
    reserve: pointers,
    labels: labels,
  ))
  _create-sort-result(steps, sorted-values, 3, 1em, 1em)
}
