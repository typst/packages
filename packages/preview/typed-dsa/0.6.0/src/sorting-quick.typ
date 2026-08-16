// Quick-sort partition operations, recursive traces, and teaching views.

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
  _render-sort-phase-indicator,
  sort-sequence,
  _create-sort-result,
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
