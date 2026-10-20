// Merge operations, merge-sort state transitions, layout, and rendering.

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
#import "sorting-validation.typ": (
  sort-orders, _check-sort-role-override, _resolve-array-input,
  _resolve-sorting-input,
)
#import "sorting-common.typ": (
  _active,
  _changed,
  _current,
  _minimum,
  _current-minimum,
  _done,
  _value-precedes,
  _value-precedes-or-equals,
  _resolve-sorting-array-style,
  _render-algorithm-caption,
  _create-cell-marks,
  _create-range-marks,
  _render-sorting-panel,
  _create-sorting-step,
  _resolve-sort-role-style,
  _sort-role-color,
  _create-sort-pointers,
  _create-marked-sorting-step,
  _render-sorting-array-row,
  _render-partition-tree-rows,
  _render-sorting-text,
  _render-sort-phase-brace,
  _render-sort-phase-indicator,
  sort-sequence,
  _create-sort-result,
)

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
