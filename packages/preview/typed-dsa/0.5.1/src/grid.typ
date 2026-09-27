// Array and matrix diagrams.
//
// These helpers draw compact cell grids using the same linear-structure style
// keys as the rest of the package.

#import "@preview/cetz:0.5.2"
#import "style.typ": resolve, scaled, validate-style, check-cell-customization-options, check-text-style
#import "validate.typ": (
  check-array, check-bool, check-dictionary, check-enum, check-function,
  check-index, check-integer, check-known-keys, fail, show-value,
)
#import cetz.draw: rect, content, line

#let _cell-customization-key(key) = if type(key) == array {
  key.map(k => str(k)).join(",")
} else {
  str(key)
}

#let _resolve-cell-customization(customizations, key) = {
  let normalized-key = _cell-customization-key(key)
  if type(customizations) == dictionary {
    return customizations.at(normalized-key, default: none)
  }
  for customization-entry in customizations {
    let entry-has-options = customization-entry.len() >= 2
    let entry-matches-cell = entry-has-options and (
      _cell-customization-key(customization-entry.at(0)) == normalized-key
    )
    if entry-matches-cell { return customization-entry.at(1) }
  }
  none
}

#let _normalize-grid-text-style(style) = {
  let normalized-style = style
  if "color" in normalized-style {
    normalized-style.fill = normalized-style.color
    let _ = normalized-style.remove("color")
  }
  normalized-style
}

#let _render-grid-text(position, body, style) = {
  let normalized-text-style = _normalize-grid-text-style(style)
  let rotation = normalized-text-style.at("rotation", default: 0deg)
  if "rotation" in normalized-text-style {
    let _ = normalized-text-style.remove("rotation")
  }
  content(position, text(..normalized-text-style)[#body], angle: rotation)
}

#let _render-grid-cell(x, y, body, resolved-style, custom: none, fill: auto, w: auto, h: auto) = {
  let cell-width = if w == auto { resolved-style.box-w } else { w }
  let cell-height = if h == auto { resolved-style.box-h } else { h }
  let base-fill = if fill == auto { resolved-style.box-fill } else { fill }
  let cell-fill = if custom != none and "fill" in custom { custom.fill } else { base-fill }
  let cell-stroke = if custom != none and "stroke" in custom { custom.stroke } else { resolved-style.box-stroke }
  let stripe-fill = if custom != none { custom.at("stripe-fill", default: none) } else { none }
  let text-style = resolved-style.value-text
  if custom != none and "text" in custom { text-style = text-style + custom.text }
  text-style = _normalize-grid-text-style(text-style)
  let rotation = text-style.at("rotation", default: 0deg)
  if "rotation" in text-style { let _ = text-style.remove("rotation") }
  let corner-radius = if resolved-style.box-shape == "rounded" {
    20%
  } else if resolved-style.box-shape == "capsule" {
    50%
  } else {
    0%
  }
  rect(
    (x, y),
    (x + cell-width, y + cell-height),
    radius: corner-radius,
    fill: cell-fill,
    stroke: if stripe-fill == none { cell-stroke } else { none },
  )
  if stripe-fill != none {
    for offset in (0, 0.2, 0.4, 0.6, 0.8) {
      rect(
        (x + cell-width * offset, y),
        (x + cell-width * (offset + 0.1), y + cell-height),
        fill: stripe-fill,
        stroke: none,
      )
    }
    rect(
      (x, y),
      (x + cell-width, y + cell-height),
      radius: corner-radius,
      fill: none,
      stroke: cell-stroke,
    )
  }
  content(
    (x + cell-width / 2, y + cell-height / 2),
    text(..text-style)[#body],
    angle: rotation,
  )
}

#let _resolve-index-configuration(resolved-style) = {
  let index-options = resolved-style.at("indices", default: false)
  if index-options in (false, none) { return none }
  if type(index-options) == dictionary {
    let should-render-indices = index-options.at("enabled", default: true)
    if not should-render-indices { return none }
    let labels = index-options.at("labels", default: auto)
    let offset = index-options.at("offset", default: (0, -0.28))
    let text-style = resolved-style.index-text
    for key in ("size", "font", "weight", "style") {
      if key in index-options { text-style.insert(key, index-options.at(key)) }
    }
    if "color" in index-options {
      text-style.fill = index-options.color
    }
    if "text" in index-options {
      text-style = text-style + index-options.text
    }
    return (enabled: true, labels: labels, offset: offset, text: _normalize-grid-text-style(text-style))
  }
  none
}

// Draw labeled arrows above the cells they mark. Each entry is a dictionary
// with `index`, `label`, `color`, and an optional `text` style. Several
// pointers on the same cell spread evenly across its width instead of
// overlapping.
#let _render-array-pointers(pointers, resolved-style) = {
  let pointers-by-cell = (:)
  for pointer in pointers {
    let cell-key = str(pointer.index)
    pointers-by-cell.insert(
      cell-key,
      pointers-by-cell.at(cell-key, default: ()) + (pointer,),
    )
  }
  for (cell-key, cell-pointers) in pointers-by-cell {
    let cell-index = int(cell-key)
    let pointer-count = cell-pointers.len()
    for (pointer-offset, pointer) in cell-pointers.enumerate() {
      let pointer-x = (
        cell-index * resolved-style.box-w
          + resolved-style.box-w * (pointer-offset + 1) / (pointer-count + 1)
      )
      line(
        (pointer-x, resolved-style.box-h + 0.5),
        (pointer-x, resolved-style.box-h + 0.08),
        stroke: (paint: pointer.color, thickness: 1pt),
        mark: (end: ">", fill: pointer.color),
      )
      let pointer-text-style = (
        resolved-style.pointer-text
          + (fill: pointer.color)
          + pointer.at("text", default: (:))
      )
      _render-grid-text(
        (pointer-x, resolved-style.box-h + 0.72),
        pointer.label,
        pointer-text-style,
      )
    }
  }
}

#let _render-array(values, resolved-style, cell-customizations, pointers: (), reserve-pointers: false) = scaled(resolved-style, cetz.canvas({
  let index-configuration = _resolve-index-configuration(resolved-style)
  for (cell-index, cell-value) in values.enumerate() {
    _render-grid-cell(
      cell-index * resolved-style.box-w,
      0,
      cell-value,
      resolved-style,
      custom: _resolve-cell-customization(cell-customizations, cell-index),
    )
    if index-configuration != none {
      let index-labels = index-configuration.labels
      let index-label = if index-labels == auto { cell-index }
        else if type(index-labels) == array and cell-index < index-labels.len() { index-labels.at(cell-index) }
        else { none }
      if index-label != none {
        let offset-x = index-configuration.offset.at(0)
        let offset-y = index-configuration.offset.at(1)
        _render-grid-text(
          (
            cell-index * resolved-style.box-w
              + resolved-style.box-w / 2
              + offset-x,
            offset-y,
          ),
          index-label,
          index-configuration.text,
        )
      }
    }
  }
  _render-array-pointers(pointers, resolved-style)
  // Keep the pointer row's height even when this array has no pointers, so a
  // row of panels stays vertically aligned.
  if reserve-pointers and pointers.len() == 0 {
    content(
      (resolved-style.box-w / 2, resolved-style.box-h + 0.72),
      hide[0],
    )
  }
}))

// ── Validation ───────────────────────────────────────────────────────────────
//
// A cell customization or a pointer that names a cell outside the sequence
// would simply never be drawn, so its target is checked against the actual
// cell count.

#let _check-cell-index(where, what, cell-index, cell-count) = check-index(
  where, what, cell-index, cell-count, subject: "array",
)

#let _validate-array-cell-customizations(where, cell-customizations, cell-count) = {
  if type(cell-customizations) == dictionary {
    for (cell-key, options) in cell-customizations {
      let cell-index = int(cell-key)
      _check-cell-index(where, "cell-customizations: key \"" + cell-key + "\"", cell-index, cell-count)
      check-cell-customization-options(where, "cell-customizations.\"" + cell-key + "\"", options)
    }
    return
  }
  check-array(
    where, "cell-customizations:", cell-customizations,
    fix: "pass an array of (index, options) pairs",
  )
  for (entry-index, entry) in cell-customizations.enumerate() {
    let entry-name = "cell-customizations: entry " + str(entry-index)
    if type(entry) != array or entry.len() != 2 {
      fail(
        where,
        entry-name + " is " + show-value(entry),
        expected: "an (index, options) pair",
        fix: "write it as (0, (fill: rgb(\"#E7F5FF\")))",
      )
    }
    _check-cell-index(where, entry-name + " index", entry.at(0), cell-count)
    check-cell-customization-options(where, entry-name + " options", entry.at(1))
  }
}

#let _validate-array-pointers(where, pointers, cell-count) = {
  check-array(
    where, "pointers:", pointers,
    fix: "pass an array of (index: 0, label: [i], color: blue) dictionaries",
  )
  for (pointer-index, pointer) in pointers.enumerate() {
    let pointer-name = "pointers: entry " + str(pointer-index)
    check-dictionary(where, pointer-name, pointer)
    check-known-keys(where, pointer-name, pointer, ("index", "label", "color", "text"))
    for required-key in ("index", "label", "color") {
      if required-key in pointer { continue }
      fail(
        where,
        pointer-name + " has no \"" + required-key + "\" entry",
        expected: "index:, label:, and color: on every pointer",
        fix: "write it as (index: 0, label: [i], color: blue)",
      )
    }
    _check-cell-index(where, pointer-name + " index", pointer.index, cell-count)
    if "text" in pointer { check-text-style(where, pointer-name + " text", pointer.text) }
  }
}

#let array-view(style: (:), cell-customizations: (), pointers: (), reserve-pointers: false, ..vals) = {
  validate-style("array-view()", style)
  check-bool("array-view()", "reserve-pointers:", reserve-pointers)
  _validate-array-cell-customizations("array-view()", cell-customizations, vals.pos().len())
  _validate-array-pointers("array-view()", pointers, vals.pos().len())
  (
    diagram: _render-array(vals.pos(), resolve(style), cell-customizations, pointers: pointers, reserve-pointers: reserve-pointers),
    values: vals.pos(),
    style: style,
  )
}

#let _render-matrix(rows, resolved-style, cell-customizations, row-labels, column-labels) = {
  let row-count = rows.len()
  let column-count = 0
  for row in rows { column-count = calc.max(column-count, row.len()) }
  scaled(resolved-style, cetz.canvas({
    for row-index in range(row-count) {
      let row = rows.at(row-index)
      for column-index in range(column-count) {
        let cell-body = if column-index < row.len() {
          row.at(column-index)
        } else {
          []
        }
        _render-grid-cell(
          column-index * resolved-style.box-w,
          -row-index * resolved-style.box-h,
          cell-body,
          resolved-style,
          custom: _resolve-cell-customization(
            cell-customizations,
            (row-index, column-index),
          ),
        )
      }
      if row-labels != none and row-index < row-labels.len() {
        _render-grid-text(
          (
            -0.42,
            -row-index * resolved-style.box-h + resolved-style.box-h / 2,
          ),
          row-labels.at(row-index),
          resolved-style.index-text,
        )
      }
    }
    if column-labels != none {
      for column-index in range(calc.min(column-labels.len(), column-count)) {
        _render-grid-text(
          (
            column-index * resolved-style.box-w + resolved-style.box-w / 2,
            resolved-style.box-h + 0.32,
          ),
          column-labels.at(column-index),
          resolved-style.index-text,
        )
      }
    }
  }))
}

// A matrix is drawn as a rectangular grid, so a ragged row would silently gain
// blank cells it never declared.
#let _validate-matrix-rows(where, rows) = {
  check-array(
    where, "rows", rows,
    fix: "pass an array of equal-length rows, for example ((1, 2), (3, 4))",
  )
  if rows.len() == 0 {
    fail(
      where,
      "rows is empty",
      expected: "at least one row",
      fix: "pass ((1, 2), (3, 4)) or similar",
    )
  }
  let column-count = none
  for (row-index, row) in rows.enumerate() {
    check-array(where, "rows entry " + str(row-index), row)
    if column-count == none { column-count = row.len() }
    if row.len() == column-count { continue }
    fail(
      where,
      "row " + str(row-index) + " has " + str(row.len()) + " cells but row 0 has " + str(column-count),
      expected: "every row to have the same number of cells",
      fix: "pad the short rows, or draw them as separate matrices",
    )
  }
  (rows: rows.len(), columns: column-count)
}

#let _validate-matrix-cell-customizations(where, cell-customizations, size) = {
  check-array(
    where, "cell-customizations:", cell-customizations,
    fix: "pass an array of ((row, column), options) pairs",
  )
  for (entry-index, entry) in cell-customizations.enumerate() {
    let entry-name = "cell-customizations: entry " + str(entry-index)
    let has-cell-key = (
      type(entry) == array
        and entry.len() == 2
        and type(entry.at(0)) == array
        and entry.at(0).len() == 2
    )
    if not has-cell-key {
      fail(
        where,
        entry-name + " is " + show-value(entry),
        expected: "a ((row, column), options) pair",
        fix: "write it as ((0, 1), (fill: rgb(\"#E7F5FF\")))",
      )
    }
    check-index(where, entry-name + " row", entry.at(0).at(0), size.rows, subject: "matrix")
    check-index(where, entry-name + " column", entry.at(0).at(1), size.columns, subject: "matrix row")
    check-cell-customization-options(where, entry-name + " options", entry.at(1))
  }
}

#let _validate-matrix-labels(where, what, labels, count, subject) = {
  if labels == none { return }
  check-array(where, what, labels, fix: "pass one label per " + subject + ", or none")
  if labels.len() <= count { return }
  fail(
    where,
    what + " has " + str(labels.len()) + " labels but the matrix has " + str(count) + " " + subject + "s",
    expected: "at most one label per " + subject,
    fix: "remove the extra labels",
  )
}

#let matrix(rows, style: (:), cell-customizations: (), row-labels: none, column-labels: none) = {
  validate-style("matrix()", style)
  let size = _validate-matrix-rows("matrix()", rows)
  _validate-matrix-cell-customizations("matrix()", cell-customizations, size)
  _validate-matrix-labels("matrix()", "row-labels:", row-labels, size.rows, "row")
  _validate-matrix-labels("matrix()", "column-labels:", column-labels, size.columns, "column")
  (
    diagram: _render-matrix(rows, resolve(style), cell-customizations, row-labels, column-labels),
  )
}

#let _render-sequence-arrow(label, style) = align(horizon)[
  #let resolved-style = resolve(style)
  #set align(center)
  #if label != none [
    #text(..resolved-style.operation-text, label) \
  ]
  #text(size: 1.3em, $arrow.r$)
]

#let _resolve-sequence-panel(step, mode) = {
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

#let sequence-modes = ("all", "diagram", "before", "after", "result")

#let sequence(columns: 1, gap: 1em, row-gap: 1em, mode: "all", style: (:), ..steps) = {
  check-enum("sequence()", "mode:", mode, sequence-modes)
  check-integer("sequence()", "columns:", columns, min: 1)
  validate-style("sequence()", style)
  let cells = ()
  for step in steps.pos() {
    let is-step = type(step) == dictionary and ("before" in step or "after" in step or "result" in step)
    if mode not in ("all", "diagram") and is-step {
      if cells.len() == 0 and "before" in step {
        cells.push(step.before)
      }
      cells.push(_render-sequence-arrow(step.at("label", default: none), style))
      cells.push(_resolve-sequence-panel(step, mode))
    } else {
      cells.push(_resolve-sequence-panel(step, mode))
    }
  }
  grid(columns: columns, column-gutter: gap, row-gutter: row-gap, ..cells)
}

// Applies operation closures to one live object and packages the resulting
// steps. Each closure receives the current object and returns an ordinary
// operation step, so this works across trees, heaps, lists, stacks, queues,
// and hash tables without a second operation-description language.
#let operation-sequence(initial, columns: 1, gap: 1em, row-gap: 1em, mode: "after", style: (:), ..operations) = {
  check-enum("operation-sequence()", "mode:", mode, sequence-modes)
  check-integer("operation-sequence()", "columns:", columns, min: 1)
  validate-style("operation-sequence()", style)
  let current = initial
  let steps = ()
  for (operation-index, operation) in operations.pos().enumerate() {
    check-function("operation-sequence()", "operation " + str(operation-index), operation)
    let step = operation(current)
    let is-operation-step = type(step) == dictionary and "result" in step
    if not is-operation-step {
      fail(
        "operation-sequence()",
        "operation " + str(operation-index) + " returned " + show-value(step),
        expected: "an operation step, the value an object's operation field returns",
        fix: "return the step, for example object => (object.insert)(5)",
      )
    }
    steps.push(step)
    current = step.result
  }
  (
    steps: steps,
    result: current,
    diagram: sequence(initial, ..steps, columns: columns, gap: gap, row-gap: row-gap, mode: mode, style: style),
  )
}
