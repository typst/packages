// Automatic sorting traces rendered as array diagrams.

#import "grid.typ": array-view
#import "@preview/cetz:0.5.2"
#import "style.typ": array-style, indices-style, cell-mark-style, resolve, scaled
#import "messages.typ": default-catalog, resolve-catalog, msg
#import cetz.draw: line, rect, content

#let _active = cell-mark-style(fill: rgb("#FFF3BF"), stroke: 1pt + rgb("#F08C00"))
#let _changed = cell-mark-style(fill: rgb("#E7F5FF"), stroke: 1pt + rgb("#1971C2"))
#let _current = cell-mark-style(fill: rgb("#FFE3E3"), stroke: 1pt + rgb("#E03131"))
#let _minimum = cell-mark-style(fill: rgb("#F3F0FF"), stroke: 1pt + rgb("#7048E8"))
#let _current-minimum = _current + (stripe-fill: rgb("#C4B5FD"))
#let _done = cell-mark-style(fill: rgb("#E6FCF5"), stroke: 1pt + rgb("#099268"))

#let _lt(a, b, order) = if order == "desc" { a > b } else { a < b }
#let _lte(a, b, order) = if order == "desc" { a >= b } else { a <= b }

#let _array-style(style, show-indices) = {
  if show-indices and "indices" not in style {
    return style + array-style(indices: indices-style(enabled: true, labels: auto))
  }
  style
}

#let _algorithm-caption(style, body, small: false) = {
  let spec = resolve(style).algorithm-label-text
  if small { spec.size = spec.at("size", default: 8pt) * 0.875 }
  text(..spec)[#body]
}

// Accepts either a plain array of values or an `array-view(...)` object and
// returns the values together with the style to carry through every step.
#let _array-input(arr) = {
  if type(arr) == dictionary and "values" in arr {
    return (arr.values, arr.at("style", default: (:)))
  }
  assert(type(arr) == array, message: "expects an array or an array-view()")
  (arr, (:))
}

#let _mark(indices, mark) = {
  let res = ()
  for i in indices {
    if i != none { res.push((i, mark)) }
  }
  res
}

#let _range-mark(start, end, mark) = {
  let res = ()
  for i in range(start, end) { res.push((i, mark)) }
  res
}

#let _panel(label, vals, marks, style, show-indices, pointers: (), reserve: false, labels: true) = {
  block(width: 100%, breakable: false)[
    #align(center)[
      #if labels [#_algorithm-caption(style, label) #v(0.25em)]
      #array-view(..vals, style: _array-style(style, show-indices), cell-customizations: marks, pointers: pointers, reserve-pointers: reserve).diagram
    ]
  ]
}

#let _step(label, vals, marks, style, show-indices, phase: none, diagram: none, pointers: (), reserve: false, labels: true) = (
  label: label,
  values: vals.map(value => value),
  phase: phase,
  diagram: if diagram == none { _panel(label, vals.map(value => value), marks, style, show-indices, pointers: pointers, reserve: reserve, labels: labels) } else { diagram },
)

// A role's mark style: the built-in default with an optional per-call override
// (a `cell-mark-style(...)` / `node-mark-style(...)`) merged over it.
#let _role(default, override) = if override == none { default } else { default + override }

// The arrow colour for a pointer: the mark's stroke accent when present,
// otherwise its fill.
#let _mark-color(role-style) = {
  if "stroke" in role-style {
    let s = role-style.stroke
    if type(s) == stroke { return s.paint }
    if type(s) == color { return s }
    if type(s) == dictionary { return s.at("paint", default: rgb("#333333")) }
  }
  role-style.at("fill", default: rgb("#333333"))
}

// Turns `(index, label)` items into pointer entries drawn above the array,
// coloured and labelled from the role's mark style.
#let _pointers(items, role-style) = items.map(it => (
  index: it.at(0),
  label: it.at(1),
  color: _mark-color(role-style),
  text: role-style.at("text", default: (:)),
))

// Resolves one marked step. Settled cells keep their sorted styling while
// `pointers` additionally draws labelled arrows above active cells.
#let _marked-step(label, arr, items, role-style, style, pointers, settled: (), labels: true) = {
  let marks = settled + _mark(items.map(it => it.at(0)), role-style)
  let pts = if pointers { _pointers(items, role-style) } else { () }
  _step(label, arr, marks, style, true, pointers: pts, labels: labels)
}

#let _array-row(parts, style, show-indices) = align(center)[
  #grid(columns: parts.len(), column-gutter: 0.45em, ..parts.map(part => array-view(..part, style: _array-style(style, show-indices)).diagram))
]

#let _tree-rows(levels, style, show-indices, start: 0) = align(center)[
  #for depth in range(start, levels.len()) [
    #_array-row(levels.at(depth), style, show-indices)
    #if depth < levels.len() - 1 [#v(0.6em)]
  ]
]

#let _merge(left, right, order) = {
  let out = ()
  let i = 0
  let j = 0
  while i < left.len() and j < right.len() {
    if _lte(left.at(i), right.at(j), order) {
      out.push(left.at(i))
      i += 1
    } else {
      out.push(right.at(j))
      j += 1
    }
  }
  while i < left.len() {
    out.push(left.at(i))
    i += 1
  }
  while j < right.len() {
    out.push(right.at(j))
    j += 1
  }
  out
}

#let _sorted-for-merge(vals, order) = {
  for i in range(1, vals.len()) {
    if _lt(vals.at(i), vals.at(i - 1), order) { return false }
  }
  true
}

#let _merge-operation-panel(label, left, right, output, left-marks, right-marks, output-marks, style, show-indices, cursors: (:), reserve: false, labels: true, cat: default-catalog) = align(center)[
  #if labels [#_algorithm-caption(style, label) #v(0.25em)]
  #grid(
    columns: 3, column-gutter: 0.8em,
    align(center)[#if labels [#_algorithm-caption(style, msg(cat, "sort.left"), small: true) #v(0.15em)] #array-view(..left, style: _array-style(style, show-indices), cell-customizations: left-marks, pointers: cursors.at("left", default: ()), reserve-pointers: reserve).diagram],
    align(center)[#if labels [#_algorithm-caption(style, msg(cat, "sort.right"), small: true) #v(0.15em)] #array-view(..right, style: _array-style(style, show-indices), cell-customizations: right-marks, pointers: cursors.at("right", default: ()), reserve-pointers: reserve).diagram],
    align(center)[#if labels [#_algorithm-caption(style, msg(cat, "sort.result"), small: true) #v(0.15em)] #array-view(..output, style: _array-style(style, show-indices), cell-customizations: output-marks, pointers: cursors.at("output", default: ()), reserve-pointers: reserve).diagram],
  )
]

#let _merge-operation-step(label, left, right, output, left-marks, right-marks, output-marks, style, show-indices, cursors: (:), reserve: false, labels: true, cat: default-catalog) = (
  label: label,
  left: left.map(value => value),
  right: right.map(value => value),
  values: output.map(value => value),
  diagram: _merge-operation-panel(label, left, right, output.map(value => value), left-marks, right-marks, output-marks, style, show-indices, cursors: cursors, reserve: reserve, labels: labels, cat: cat),
)

#let _merge-cursors(i, j, k, left, right, output, pointers, input-style: _active, output-style: _changed) = (
  left: if pointers and i < left.len() { _pointers(((i, [i]),), input-style) } else { () },
  right: if pointers and j < right.len() { _pointers(((j, [j]),), input-style) } else { () },
  output: if pointers and k < output.len() { _pointers(((k, [i+j]),), output-style) } else { () },
)

#let _partition-marks(left, right, pivot, arr) = {
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

#let _partition-panel(label, arr, left, right, pivot, marks, style, show-indices, pointers: (), reserve: false, labels: true, cat: default-catalog) = align(center)[
  #if labels [#_algorithm-caption(style, label) #v(0.15em) #_algorithm-caption(style, msg(cat, "sort.pivot-info", arr.at(pivot), pivot, left, right), small: true) #v(0.2em)]
  #array-view(..arr, style: _array-style(style, show-indices), cell-customizations: marks, pointers: pointers, reserve-pointers: reserve).diagram
]

#let _partition-step(label, arr, left, right, pivot, marks, style, show-indices, pointers: (), reserve: false, labels: true, cat: default-catalog) = (
  label: label,
  values: arr.map(value => value),
  left: left,
  right: right,
  pivot: pivot,
  diagram: _partition-panel(label, arr.map(value => value), left, right, pivot, marks, style, show-indices, pointers: pointers, reserve: reserve, labels: labels, cat: cat),
)

#let _partition-cursors(i, j, pivot, arr, pointers) = {
  if not pointers { return () }
  let cursors = ()
  if i >= 0 and i < arr.len() { cursors += _pointers(((i, [i]),), _current) }
  if j >= 0 and j < arr.len() { cursors += _pointers(((j, [j]),), _active) }
  if pivot >= 0 and pivot < arr.len() { cursors += _pointers(((pivot, [pivot]),), _minimum) }
  cursors
}

#let partition-step(arr, order: "asc", pivot: "middle", pointers: false, labels: true, language: "en", messages: (:)) = {
  assert(order in ("asc", "desc"), message: "order must be \"asc\" or \"desc\"")
  assert(pivot in ("middle", "last"), message: "pivot must be \"middle\" or \"last\"")
  let cat = resolve-catalog(language: language, messages: messages)
  let _partition-step = _partition-step.with(cat: cat)
  let pivot-mode = pivot
  let (values, style) = _array-input(arr)
  let show-indices = true
  let arr = values.map(value => value)
  let pivot = calc.floor(arr.len() / 2)
  let pivot-value = if arr.len() == 0 { none } else { arr.at(pivot) }
  let left = 0
  let right = arr.len() - 1
  let steps = ()
  if arr.len() == 0 {
    steps.push(_step(msg(cat, "sort.partitioned"), arr, (), style, show-indices, labels: labels))
    return (steps: steps, result: arr, left: left, right: right, pivot: none, diagram: grid(columns: 1, row-gutter: 0.8em, ..steps.map(step => step.diagram)))
  }
  if pivot-mode == "last" {
    let pivot = arr.len() - 1
    let pivot-value = arr.at(pivot)
    let i = 0
    steps.push(_partition-step(msg(cat, "sort.start"), arr, i, 0, pivot, _partition-marks(i, 0, pivot, arr), style, show-indices, pointers: _partition-cursors(i, 0, pivot, arr, pointers), reserve: pointers, labels: labels))
    steps.push(_partition-step(msg(cat, "sort.select-last-pivot", pivot-value), arr, i, 0, pivot, _partition-marks(i, 0, pivot, arr), style, show-indices, pointers: _partition-cursors(i, 0, pivot, arr, pointers), reserve: pointers, labels: labels))
    for j in range(0, pivot) {
      steps.push(_partition-step(msg(cat, "sort.compare-pivot", arr.at(j), pivot-value), arr, i, j, pivot, _partition-marks(i, j, pivot, arr), style, show-indices, pointers: _partition-cursors(i, j, pivot, arr, pointers), reserve: pointers, labels: labels))
      if _lte(arr.at(j), pivot-value, order) {
        let a = arr.at(i)
        let b = arr.at(j)
        arr.at(i) = b
        arr.at(j) = a
        steps.push(_partition-step(msg(cat, "sort.swap", a, b), arr, i, j, pivot, _mark((i, j), _changed) + _mark((pivot,), _minimum), style, show-indices, pointers: _partition-cursors(i, j, pivot, arr, pointers), reserve: pointers, labels: labels))
        i += 1
        steps.push(_partition-step(msg(cat, "sort.advance-i", i), arr, i, j, pivot, _partition-marks(i, j, pivot, arr), style, show-indices, pointers: _partition-cursors(i, j, pivot, arr, pointers), reserve: pointers, labels: labels))
      }
    }
    let a = arr.at(i)
    arr.at(i) = arr.at(pivot)
    arr.at(pivot) = a
    steps.push(_partition-step(msg(cat, "sort.place-pivot", pivot-value), arr, i, pivot, i, _mark((i, pivot), _changed), style, show-indices, pointers: _partition-cursors(i, pivot, i, arr, pointers), reserve: pointers, labels: labels))
    steps.push(_partition-step(msg(cat, "sort.partitioned"), arr, i, pivot, i, _mark((i,), _done), style, show-indices, reserve: pointers, labels: labels))
    return (steps: steps, result: arr, left: i, right: pivot, pivot: i, diagram: grid(columns: 1, row-gutter: 0.8em, ..steps.map(step => step.diagram)))
  }
  steps.push(_partition-step(msg(cat, "sort.start"), arr, left, right, pivot, _partition-marks(left, right, pivot, arr), style, show-indices, labels: labels))
  steps.push(_partition-step(msg(cat, "sort.select-pivot", pivot-value), arr, left, right, pivot, _partition-marks(left, right, pivot, arr), style, show-indices, labels: labels))
  while left <= right {
    while left <= right and _lt(arr.at(left), pivot-value, order) {
      steps.push(_partition-step(msg(cat, "sort.i-satisfies", arr.at(left)), arr, left, right, pivot, _partition-marks(left, right, pivot, arr), style, show-indices, labels: labels))
      left += 1
    }
    while left <= right and _lt(pivot-value, arr.at(right), order) {
      steps.push(_partition-step(msg(cat, "sort.j-satisfies", arr.at(right)), arr, left, right, pivot, _partition-marks(left, right, pivot, arr), style, show-indices, labels: labels))
      right -= 1
    }
    if left <= right {
      steps.push(_partition-step(msg(cat, "sort.compare", arr.at(left), arr.at(right)), arr, left, right, pivot, _partition-marks(left, right, pivot, arr), style, show-indices, labels: labels))
      let a = arr.at(left)
      let b = arr.at(right)
      arr.at(left) = b
      arr.at(right) = a
      if pivot == left { pivot = right }
      else if pivot == right { pivot = left }
      steps.push(_partition-step(msg(cat, "sort.swap", a, b), arr, left, right, pivot, _mark((left, right), _changed), style, show-indices, labels: labels))
      left += 1
      right -= 1
    }
  }
  steps.push(_partition-step(msg(cat, "sort.partitioned"), arr, left, right, pivot, _range-mark(0, arr.len(), _done), style, show-indices, labels: labels))
  (
    steps: steps,
    result: arr,
    left: left,
    right: right,
    pivot: pivot,
    diagram: grid(columns: 1, row-gutter: 0.8em, ..steps.map(step => step.diagram)),
  )
}

#let merge-operation(left, right, order: "asc", pointers: true, labels: true, language: "en", messages: (:)) = {
  assert(order in ("asc", "desc"), message: "order must be \"asc\" or \"desc\"")
  let cat = resolve-catalog(language: language, messages: messages)
  let _merge-operation-step = _merge-operation-step.with(cat: cat)
  let (left, left-style) = _array-input(left)
  let (right, right-style) = _array-input(right)
  let style = if left-style != (:) { left-style } else { right-style }
  let show-indices = true
  assert(_sorted-for-merge(left, order), message: "left array must already be sorted")
  assert(_sorted-for-merge(right, order), message: "right array must already be sorted")
  let output = ()
  for _ in range(left.len() + right.len()) { output.push([]) }
  let i = 0
  let j = 0
  let k = 0
  let steps = (_merge-operation-step(
    msg(cat, "sort.start-merge"), left, right, output, (), (), (), style, show-indices,
    cursors: _merge-cursors(i, j, k, left, right, output, pointers), reserve: pointers, labels: labels,
  ),)
  while i < left.len() and j < right.len() {
    steps.push(_merge-operation-step(
      msg(cat, "sort.compare", left.at(i), right.at(j)), left, right, output,
      _mark((i,), _active), _mark((j,), _active), (), style, show-indices,
      cursors: _merge-cursors(i, j, k, left, right, output, pointers), reserve: pointers, labels: labels,
    ))
    if _lte(left.at(i), right.at(j), order) {
      output.at(k) = left.at(i)
      steps.push(_merge-operation-step(
        msg(cat, "sort.take", left.at(i)), left, right, output,
        _mark((i,), _changed), (), _mark((k,), _changed), style, show-indices,
        cursors: _merge-cursors(i, j, k, left, right, output, pointers, input-style: _changed), reserve: pointers, labels: labels,
      ))
      i += 1
    } else {
      output.at(k) = right.at(j)
      steps.push(_merge-operation-step(
        msg(cat, "sort.take", right.at(j)), left, right, output,
        (), _mark((j,), _changed), _mark((k,), _changed), style, show-indices,
        cursors: _merge-cursors(i, j, k, left, right, output, pointers, input-style: _changed), reserve: pointers, labels: labels,
      ))
      j += 1
    }
    k += 1
  }
  while i < left.len() {
    output.at(k) = left.at(i)
    steps.push(_merge-operation-step(
      msg(cat, "sort.take-remaining", left.at(i)), left, right, output,
      _mark((i,), _changed), (), _mark((k,), _changed), style, show-indices,
      cursors: _merge-cursors(i, j, k, left, right, output, pointers, input-style: _changed), reserve: pointers, labels: labels,
    ))
    i += 1
    k += 1
  }
  while j < right.len() {
    output.at(k) = right.at(j)
    steps.push(_merge-operation-step(
      msg(cat, "sort.take-remaining", right.at(j)), left, right, output,
      (), _mark((j,), _changed), _mark((k,), _changed), style, show-indices,
      cursors: _merge-cursors(i, j, k, left, right, output, pointers, input-style: _changed), reserve: pointers, labels: labels,
    ))
    j += 1
    k += 1
  }
  steps.push(_merge-operation-step(
    msg(cat, "sort.merged"), left, right, output,
    (), (), _range-mark(0, output.len(), _done), style, show-indices, reserve: pointers, labels: labels,
  ))
  (
    steps: steps,
    result: output,
    diagram: grid(columns: 1, row-gutter: 0.8em, ..steps.map(step => step.diagram)),
  )
}

#let _sort-text(pos, body, text-style) = {
  let style = text-style
  let rotation = style.at("rotation", default: 0deg)
  if "rotation" in style { let _ = style.remove("rotation") }
  content(pos, text(..style)[#body], angle: rotation)
}

#let _tree-depth(vals) = if vals.len() <= 1 { 0 } else {
  let middle = calc.floor(vals.len() / 2)
  1 + calc.max(_tree-depth(vals.slice(0, middle)), _tree-depth(vals.slice(middle)))
}

#let _node-center(start, end, pitch) = (start + end) / 2 * pitch

#let _tree-array(vals, start, end, y, th, pitch, show-indices, mark: none) = {
  let x = _node-center(start, end, pitch) - vals.len() * th.box-w / 2
  let fill = if mark == none { th.box-fill } else { mark.fill }
  let stroke = if mark == none { th.box-stroke } else { mark.stroke }
  for (i, value) in vals.enumerate() {
    let cell-x = x + i * th.box-w
    rect((cell-x, y), (cell-x + th.box-w, y + th.box-h), fill: fill, stroke: stroke)
    _sort-text((cell-x + th.box-w / 2, y + th.box-h / 2), value, th.value-text)
    if show-indices {
      _sort-text((cell-x + th.box-w / 2, y - 0.28), i, th.index-text)
    }
  }
}

#let _phase-brace(label, bottom, top, x, th) = {
  let middle = (bottom + top) / 2
  line(
    (x, top), (x - 0.18, top - 0.18), (x - 0.18, middle + 0.25),
    (x - 0.42, middle), (x - 0.18, middle - 0.25), (x - 0.18, bottom + 0.18), (x, bottom),
    stroke: th.box-stroke,
  )
  if label != none { _sort-text((x - 1.05, middle), label, th.algorithm-label-text + (weight: "bold")) }
}

#let _phase-indicator(label, levels, style) = {
  let th = resolve(style)
  let height = calc.max(1, levels.len()) * (th.box-h + 0.7)
  scaled(th, cetz.canvas({ _phase-brace(label, 0, height, 0, th) }))
}

#let _divide-edges(vals, start, end, depth, max-depth, th, pitch, row-gap) = {
  if vals.len() <= 1 { return }
  let middle = calc.floor(vals.len() / 2)
  let split = start + middle
  let parent = (_node-center(start, end, pitch), (max-depth - depth) * row-gap)
  for child in ((start, split), (split, end)) {
    let child-center = _node-center(child.at(0), child.at(1), pitch)
    let child-y = (max-depth - depth - 1) * row-gap
    line(parent, (child-center, child-y + th.box-h), stroke: th.box-stroke, mark: (end: ">"))
  }
  _divide-edges(vals.slice(0, middle), start, split, depth + 1, max-depth, th, pitch, row-gap)
  _divide-edges(vals.slice(middle), split, end, depth + 1, max-depth, th, pitch, row-gap)
}

#let _divide-nodes(vals, start, end, depth, max-depth, th, pitch, row-gap, show-indices) = {
  _tree-array(vals, start, end, (max-depth - depth) * row-gap, th, pitch, show-indices)
  if vals.len() <= 1 { return }
  let middle = calc.floor(vals.len() / 2)
  let split = start + middle
  _divide-nodes(vals.slice(0, middle), start, split, depth + 1, max-depth, th, pitch, row-gap, show-indices)
  _divide-nodes(vals.slice(middle), split, end, depth + 1, max-depth, th, pitch, row-gap, show-indices)
}

#let _divide-tree(vals, style, show-indices, labels: true, cat: default-catalog) = {
  let th = resolve(style)
  let depth = _tree-depth(vals)
  let pitch = th.box-w * 1.45
  let row-gap = th.box-h + 0.8
  scaled(th, cetz.canvas({
    _phase-brace(if labels { msg(cat, "sort.divide-phase") } else { none }, 0, depth * row-gap + th.box-h, 0, th)
    _divide-edges(vals, 0, vals.len(), 0, depth, th, pitch, row-gap)
    _divide-nodes(vals, 0, vals.len(), 0, depth, th, pitch, row-gap, show-indices)
  }))
}

#let _merge-model(vals, order, start: 0) = {
  let end = start + vals.len()
  if vals.len() <= 1 { return (values: vals, start: start, end: end, height: 0, left: none, right: none) }
  let middle = calc.floor(vals.len() / 2)
  let left = _merge-model(vals.slice(0, middle), order, start: start)
  let right = _merge-model(vals.slice(middle), order, start: start + middle)
  (
    values: _merge(left.values, right.values, order),
    start: start,
    end: end,
    height: calc.max(left.height, right.height) + 1,
    left: left,
    right: right,
  )
}

#let _merge-edges(model, max-height, th, pitch, row-gap) = {
  if model.left == none { return }
  for child in (model.left, model.right) {
    _merge-edges(child, max-height, th, pitch, row-gap)
    let child-y = (max-height - child.height) * row-gap
    let parent-y = (max-height - model.height) * row-gap
    line(
      (_node-center(child.start, child.end, pitch), child-y),
      (_node-center(model.start, model.end, pitch), parent-y + th.box-h),
      stroke: th.box-stroke,
      mark: (end: ">"),
    )
  }
}

#let _merge-nodes(model, max-height, th, pitch, row-gap, show-indices, final: false) = {
  if model.left != none {
    _merge-nodes(model.left, max-height, th, pitch, row-gap, show-indices)
    _merge-nodes(model.right, max-height, th, pitch, row-gap, show-indices)
  }
  _tree-array(model.values, model.start, model.end, (max-height - model.height) * row-gap, th, pitch, show-indices, mark: if final { _done } else { none })
}

#let _merge-tree-diagram(vals, order, style, show-indices, labels: true, cat: default-catalog) = {
  let th = resolve(style)
  let pitch = th.box-w * 1.45
  let row-gap = th.box-h + 0.8
  let model = _merge-model(vals, order)
  scaled(th, cetz.canvas({
    _phase-brace(if labels { msg(cat, "sort.merge-phase") } else { none }, 0, model.height * row-gap + th.box-h, 0, th)
    _merge-edges(model, model.height, th, pitch, row-gap)
    _merge-nodes(model, model.height, th, pitch, row-gap, show-indices, final: true)
  }))
}

#let sort-sequence(steps, columns: 3, gap: 1em, row-gap: 1em) = {
  let cells = ()
  for step in steps {
    cells.push(if type(step) == dictionary and "diagram" in step { step.diagram } else { step })
  }
  grid(columns: columns, column-gutter: gap, row-gutter: row-gap, ..cells)
}

#let _finish(steps, result, columns, gap, row-gap, diagram: auto) = (
  steps: steps,
  result: result,
  diagram: if diagram == auto { sort-sequence(steps, columns: columns, gap: gap, row-gap: row-gap) } else { diagram },
)

#let _merge-tree(vals, order) = {
  if vals.len() <= 1 { return (vals, ((vals,),), ()) }
  let middle = calc.floor(vals.len() / 2)
  let (left, left-divide, left-merge) = _merge-tree(vals.slice(0, middle), order)
  let (right, right-divide, right-merge) = _merge-tree(vals.slice(middle), order)
  let merged = _merge(left, right, order)
  let divide = ((vals,),)
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
  assert(order in ("asc", "desc"), message: "order must be \"asc\" or \"desc\"")
  let cat = resolve-catalog(language: language, messages: messages)
  let _divide-tree = _divide-tree.with(cat: cat)
  let _merge-tree-diagram = _merge-tree-diagram.with(cat: cat)
  let (values, style) = _array-input(arr)
  let (result, divide-levels, merge-levels) = _merge-tree(values, order)
  let steps = (
    (label: msg(cat, "sort.original"), values: values, diagram: _panel(msg(cat, "sort.original"), values, (), style, true, labels: labels)),
  )
  for depth in range(1, divide-levels.len()) {
    let level = divide-levels.at(depth)
    steps.push((label: msg(cat, "sort.divide"), values: level, diagram: _array-row(level, style, true)))
  }
  for depth in range(0, calc.max(merge-levels.len() - 1, 0)) {
    let level = merge-levels.at(depth)
    if level.len() > 0 {
      steps.push((label: msg(cat, "sort.merge"), values: level, diagram: _array-row(level, style, true)))
    }
  }
  steps.push(_step(msg(cat, "sort.sorted"), result, _range-mark(0, result.len(), _done), style, true, labels: labels))
  let diagram = align(center)[
    #if labels [#_algorithm-caption(style, msg(cat, "sort.original")) #v(0.25em)]
    #_divide-tree(values, style, true, labels: labels)
    #v(1em)
    #_merge-tree-diagram(values, order, style, true, labels: labels)
  ]
  _finish(steps, result, 3, 1em, 1em, diagram: diagram)
}

// Position of the pivot within a subarray of the given length. "first" and
// "last" select the ends; an integer selects that position, clamped to the
// last index for subarrays shorter than the requested position.
#let _pivot-pos(len, pivot) = {
  if pivot == "first" { 0 }
  else if pivot == "last" { len - 1 }
  else { calc.min(pivot, len - 1) }
}

#let _partition(arr, lo, hi, order, pivot, steps, style, show-indices, labels: true, cat: default-catalog) = {
  let p = lo + _pivot-pos(hi - lo + 1, pivot)
  if p != hi {
    let swap = arr.at(p)
    arr.at(p) = arr.at(hi)
    arr.at(hi) = swap
  }
  let pivot-value = arr.at(hi)
  let i = lo
  for j in range(lo, hi) {
    if _lte(arr.at(j), pivot-value, order) {
      let tmp = arr.at(i)
      arr.at(i) = arr.at(j)
      arr.at(j) = tmp
      i += 1
    }
  }
  let tmp = arr.at(i)
  arr.at(i) = arr.at(hi)
  arr.at(hi) = tmp
  let partition-diagram = align(center)[
    #if labels [#_algorithm-caption(style, msg(cat, "sort.partition-around", pivot-value)) #v(0.25em)]
    #_array-row((arr.slice(lo, i), (pivot-value,), arr.slice(i + 1, hi + 1)), style, show-indices)
  ]
  steps.push(_step(msg(cat, "sort.partition-pivot", pivot-value), arr, _mark((i,), _active), style, show-indices, diagram: partition-diagram, labels: labels))
  (arr, i, steps)
}

#let _quick-parts(vals, order, pivot) = {
  if vals.len() <= 1 { return (vals, none, ()) }
  let arr = vals.map(value => value)
  let last = arr.len() - 1
  let p = _pivot-pos(arr.len(), pivot)
  if p != last {
    let swap = arr.at(p)
    arr.at(p) = arr.at(last)
    arr.at(last) = swap
  }
  let pivot-value = arr.at(last)
  let i = 0
  for j in range(0, last) {
    if _lte(arr.at(j), pivot-value, order) {
      let temp = arr.at(i)
      arr.at(i) = arr.at(j)
      arr.at(j) = temp
      i += 1
    }
  }
  let temp = arr.at(i)
  arr.at(i) = arr.at(last)
  arr.at(last) = temp
  (arr.slice(0, i), pivot-value, arr.slice(i + 1))
}

#let _quick-levels(vals, order, pivot) = {
  if vals.len() <= 1 { return (vals, ((vals,),)) }
  let (lower, pivot-value, upper) = _quick-parts(vals, order, pivot)
  let (lower-result, lower-levels) = _quick-levels(lower, order, pivot)
  let (upper-result, upper-levels) = _quick-levels(upper, order, pivot)
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

#let _quick-sort-range(arr, lo, hi, order, pivot, steps, style, show-indices, labels: true, cat: default-catalog) = {
  if lo >= hi { return (arr, steps) }
  let (partitioned, p, partition-steps) = _partition(arr, lo, hi, order, pivot, steps, style, show-indices, labels: labels, cat: cat)
  let (left-sorted, left-steps) = _quick-sort-range(partitioned, lo, p - 1, order, pivot, partition-steps, style, show-indices, labels: labels, cat: cat)
  _quick-sort-range(left-sorted, p + 1, hi, order, pivot, left-steps, style, show-indices, labels: labels, cat: cat)
}

#let quick-sort(arr, order: "asc", pivot: "last", labels: true, language: "en", messages: (:)) = {
  assert(order in ("asc", "desc"), message: "order must be \"asc\" or \"desc\"")
  let cat = resolve-catalog(language: language, messages: messages)
  let _quick-sort-range = _quick-sort-range.with(cat: cat)
  let (values, style) = _array-input(arr)
  assert(
    pivot in ("first", "last") or type(pivot) == int,
    message: "pivot must be \"first\", \"last\", or an index",
  )
  if type(pivot) == int {
    assert(
      pivot >= 0 and pivot < values.len(),
      message: "pivot index " + str(pivot) + " is out of bounds for an array of length " + str(values.len()),
    )
  }
  let steps = (_step(msg(cat, "sort.start"), values, (), style, true, labels: labels),)
  let (result, generated) = _quick-sort-range(values, 0, values.len() - 1, order, pivot, steps, style, true, labels: labels)
  generated.push(_step(msg(cat, "sort.sorted"), result, _range-mark(0, result.len(), _done), style, true, labels: labels))
  let (_, levels) = _quick-levels(values, order, pivot)
  let diagram = align(center)[
    #if labels [#_algorithm-caption(style, msg(cat, "sort.original")) #v(0.25em)]
    #array-view(..values, style: _array-style(style, true)).diagram
    #v(0.8em)
    #grid(columns: (auto, auto), column-gutter: 0.8em, _phase-indicator(if labels { msg(cat, "sort.partition-phase") } else { none }, levels, style), _tree-rows(levels, style, true))
    #v(0.8em)
    #if labels [#_algorithm-caption(style, msg(cat, "sort.sorted-array")) #v(0.25em)]
    #array-view(..result, style: _array-style(style, true), cell-customizations: _range-mark(0, result.len(), _done)).diagram
  ]
  _finish(generated, result, 1, 1em, 0.8em, diagram: diagram)
}

#let bubble-sort(arr, order: "asc", pointers: true, labels: true, compare: none, swap: none, language: "en", messages: (:)) = {
  assert(order in ("asc", "desc"), message: "order must be \"asc\" or \"desc\"")
  let cat = resolve-catalog(language: language, messages: messages)
  let (values, style) = _array-input(arr)
  let arr = values.map(value => value)
  let cmp = _role(_active, compare)
  let swp = _role(_changed, swap)
  let steps = (_step(msg(cat, "sort.start"), arr, (), style, true, reserve: pointers, labels: labels),)
  for pass in range(arr.len()) {
    let settled = _range-mark(arr.len() - pass, arr.len(), _done)
    for j in range(0, arr.len() - pass - 1) {
      steps.push(_marked-step(msg(cat, "sort.compare", arr.at(j), arr.at(j + 1)), arr, ((j, [j]), (j + 1, [j+1])), cmp, style, pointers, settled: settled, labels: labels))
      if _lt(arr.at(j + 1), arr.at(j), order) {
        let a = arr.at(j)
        let b = arr.at(j + 1)
        arr.at(j) = b
        arr.at(j + 1) = a
        steps.push(_marked-step(msg(cat, "sort.swap", a, b), arr, ((j, [j]), (j + 1, [j+1])), swp, style, pointers, settled: settled, labels: labels))
      }
    }
    if pass < arr.len() - 1 {
      steps.push(_step(msg(cat, "sort.settled", arr.at(arr.len() - pass - 1)), arr, _range-mark(arr.len() - pass - 1, arr.len(), _done), style, true, reserve: pointers, labels: labels))
    }
  }
  steps.push(_step(msg(cat, "sort.sorted"), arr, _range-mark(0, arr.len(), _done), style, true, reserve: pointers, labels: labels))
  _finish(steps, arr, 3, 1em, 1em)
}

#let insertion-sort(arr, order: "asc", pointers: true, labels: true, compare: none, swap: none, language: "en", messages: (:)) = {
  assert(order in ("asc", "desc"), message: "order must be \"asc\" or \"desc\"")
  let cat = resolve-catalog(language: language, messages: messages)
  let (values, style) = _array-input(arr)
  let arr = values.map(value => value)
  let cmp = _role(_active, compare)
  let swp = _role(_changed, swap)
  let steps = (_step(msg(cat, "sort.start"), arr, (), style, true, reserve: pointers, labels: labels),)
  for i in range(1, arr.len()) {
    let j = i
    while j > 0 {
      steps.push(_marked-step(msg(cat, "sort.compare", arr.at(j - 1), arr.at(j)), arr, ((j - 1, [j-1]), (j, [j])), cmp, style, pointers, labels: labels))
      if not _lt(arr.at(j), arr.at(j - 1), order) { break }
      let left = arr.at(j - 1)
      let right = arr.at(j)
      arr.at(j - 1) = right
      arr.at(j) = left
      steps.push(_marked-step(msg(cat, "sort.swap", left, right), arr, ((j - 1, [j-1]), (j, [j])), swp, style, pointers, labels: labels))
      j -= 1
    }
  }
  steps.push(_step(msg(cat, "sort.sorted"), arr, _range-mark(0, arr.len(), _done), style, true, reserve: pointers, labels: labels))
  _finish(steps, arr, 3, 1em, 1em)
}

#let selection-sort(arr, order: "asc", pointers: true, labels: true, compare: none, current: none, minimum: none, swap: none, language: "en", messages: (:)) = {
  assert(order in ("asc", "desc"), message: "order must be \"asc\" or \"desc\"")
  let cat = resolve-catalog(language: language, messages: messages)
  let (values, style) = _array-input(arr)
  let arr = values.map(value => value)
  let cur = _role(_current, current)
  let mn = _role(_minimum, minimum)
  let cmp = _role(_active, compare)
  let swp = _role(_changed, swap)
  let steps = (_step(msg(cat, "sort.start"), arr, (), style, true, reserve: pointers, labels: labels),)
  for i in range(arr.len()) {
    let settled = _range-mark(0, i, _done)
    let selected = i
    for j in range(i + 1, arr.len()) {
      let label = msg(cat, "sort.selection-status", i, selected, j)
      let i-mark = if i == selected { cur + (stripe-fill: rgb("#C4B5FD")) } else { cur }
      let marks = settled + _mark((i,), i-mark) + _mark((selected,), mn) + _mark((j,), cmp)
      let pts = if pointers { _pointers(((i, [i]),), cur) + _pointers(((selected, [min]),), mn) + _pointers(((j, [j]),), cmp) } else { () }
      steps.push(_step(label, arr, marks, style, true, pointers: pts, labels: labels))
      if _lt(arr.at(j), arr.at(selected), order) {
        selected = j
      }
    }
    if selected != i {
      let a = arr.at(i)
      let b = arr.at(selected)
      arr.at(i) = b
      arr.at(selected) = a
      steps.push(_marked-step(msg(cat, "sort.swap", a, b), arr, ((i, [i]), (selected, [min])), swp, style, pointers, settled: settled, labels: labels))
      steps.push(_step(msg(cat, "sort.settled", b), arr, _range-mark(0, i + 1, _done), style, true, reserve: pointers, labels: labels))
    }
  }
  steps.push(_step(msg(cat, "sort.sorted"), arr, _range-mark(0, arr.len(), _done), style, true, reserve: pointers, labels: labels))
  _finish(steps, arr, 3, 1em, 1em)
}
