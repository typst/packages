// Linear structures: linked lists, stacks, and queues.
//
// These are laid out by counting cells, so no layout pass is needed: a linked
// list and queue are a row of boxes, a stack is a column. Each builder takes a
// `style:` dict merged over the defaults and returns an object that is both
// the drawing (`diagram`) and the thing you operate on: operation fields
// return a step `(label, before, after, diagram, result)`, like the trees.
// `marks` maps `str(index)` to a highlight kind ("new"/"remove"), resolved
// against `resolved-style`'s `<kind>-style` at draw time — so a per-call
// `style:` override actually reaches the mark, not just the theme default.

#import "@preview/cetz:0.5.2"
#import "style.typ": resolve, scaled, resolve-mark-style, validate-style
#import "tree.typ": trans-view
#import "validate.typ": (
  check-array, check-bool, check-callback-result, check-comparable,
  check-comparable-with, check-function, check-index, check-integer,
  check-positive, check-unique, fail, show-list, show-value,
)
#import "messages.typ": default-catalog, resolve-catalog, msg
#import cetz.draw: line, rect, content

// ── Validation ───────────────────────────────────────────────────────────────

// Addresses annotate one cell each, so a mismatched array would silently
// leave the trailing cells unlabelled or drop the extra entries.
#let _validate-linear-list-arguments(where, values, style, pointer, addresses, head) = {
  validate-style(where, style)
  check-bool(where, "pointer:", pointer)
  check-bool(where, "head:", head)
  if addresses == none { return }
  check-array(
    where, "addresses:", addresses,
    fix: "pass one address per value, or none",
  )
  if addresses.len() == values.len() { return }
  fail(
    where,
    "addresses: has " + str(addresses.len()) + " entries but the list has " + str(values.len()) + " values",
    expected: "one address per value",
    fix: "pass " + str(values.len()) + " addresses, or none",
  )
}

// Removing a value that is not in the list cannot be drawn as a before/after
// step. An unsuccessful *search* is a different matter and stays legal.
#let _check-deletable-value(where, values, value) = {
  if values.contains(value) { return }
  fail(
    where,
    "value " + show-value(value) + " is not in the list, so there is nothing to delete",
    expected: "one of the values: " + show-list(values),
    fix: "delete a value the list holds; use search(value) to show an unsuccessful lookup",
  )
}

#let _check-non-empty-structure(where, values, operation, subject) = {
  if values.len() > 0 { return }
  fail(
    where,
    "the " + subject + " is empty, so " + operation + " has nothing to remove",
    expected: "a " + subject + " with at least one value",
    fix: "add a value first, or drop this operation",
  )
}

#let _render-linear-annotation(position, body, resolved-style) = {
  let text-style = resolved-style.pointer-text
  let rotation = text-style.at("rotation", default: 0deg)
  if "rotation" in text-style { let _ = text-style.remove("rotation") }
  content(position, text(..text-style)[#body], angle: rotation)
}

#let _render-linear-node-content(position, body, resolved-style) = {
  let text-style = resolved-style.value-text
  let rotation = text-style.at("rotation", default: 0deg)
  if "rotation" in text-style { let _ = text-style.remove("rotation") }
  content(position, text(..text-style)[#body], angle: rotation)
}

// Shared terminator for linked structures and chained hash buckets.
#let _null = $nothing$

// A cell with its lower-left corner at `(x, y)`. `w` and `fill` default to
// the theme's box width and fill; `mark`, when set, overrides fill/stroke via
// `mark-style` and takes priority over a plain `fill:`.
#let _render-linear-cell(x, y, body, resolved-style, fill: auto, mark: none, w: auto) = {
  let cell-width = if w == auto { resolved-style.box-w } else { w }
  let base-fill = if fill == auto { resolved-style.box-fill } else { fill }
  let mark-style = if mark != none {
    resolve-mark-style(resolved-style, mark, base-fill: base-fill)
  } else {
    none
  }
  let cell-fill = if mark-style != none { mark-style.fill } else { base-fill }
  let cell-stroke = if mark-style != none { mark-style.stroke } else { resolved-style.box-stroke }
  let text-style = if mark-style != none { mark-style.text } else { resolved-style.value-text }
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
    (x + cell-width, y + resolved-style.box-h),
    radius: corner-radius,
    stroke: cell-stroke,
    fill: cell-fill,
  )
  content(
    (x + cell-width / 2, y + resolved-style.box-h / 2),
    text(..text-style)[#body],
    angle: rotation,
  )
}

#let _mark-at-index(marks, index) = marks.at(str(index), default: none)

#let _insert-sequence-value(values, index, value) = (
  values.slice(0, index) + (value,) + values.slice(index)
)
#let _delete-sequence-value(values, index) = (
  values.slice(0, index) + values.slice(index + 1)
)
#let _insert-address-placeholder(addresses, index) = if addresses == none { none } else { _insert-sequence-value(addresses, calc.min(index, addresses.len()), none) }
#let _delete-address(addresses, index) = if addresses == none or index >= addresses.len() { addresses } else { _delete-sequence-value(addresses, index) }
#let _create-linear-path-marks(length) = {
  let marks = (:)
  for visited-index in range(length) {
    marks.insert(str(visited-index), "path")
  }
  marks
}

#let _render-head-arrow(resolved-style, arrow-end-x, message-catalog) = {
  let cell-midpoint-y = resolved-style.box-h / 2
  _render-linear-annotation(
    (-resolved-style.box-gap - 1.0, cell-midpoint-y),
    msg(message-catalog, "list.head"),
    resolved-style,
  )
  line(
    (-resolved-style.box-gap - 0.55, cell-midpoint-y),
    (arrow-end-x, cell-midpoint-y),
    mark: (end: ">"),
    stroke: resolved-style.box-stroke,
  )
}

// Assemble an operation step from the rendered states and the next object.
#let _create-linear-operation-step(label, before, after, result, style: (:)) = (
  label: label,
  before: before,
  after: after,
  diagram: trans-view(before, label, after, style: style),
  result: result,
)

// ── Linked list ──────────────────────────────────────────────────────────────

#let _render-simple-linked-list(values, resolved-style, should-render-head, marks, message-catalog) = {
  let node-step = resolved-style.box-w + resolved-style.box-gap
  cetz.canvas({
    for (node-index, node-value) in values.enumerate() {
      _render-linear-cell(
        node-index * node-step,
        0,
        node-value,
        resolved-style,
        mark: _mark-at-index(marks, node-index),
      )
      line(
        (
          node-index * node-step + resolved-style.box-w,
          resolved-style.box-h / 2,
        ),
        ((node-index + 1) * node-step, resolved-style.box-h / 2),
        mark: (end: ">"),
        stroke: resolved-style.box-stroke,
      )
    }
    _render-linear-annotation(
      (values.len() * node-step + 0.18, resolved-style.box-h / 2),
      _null,
      resolved-style,
    )
    if should-render-head and values.len() > 0 {
      _render-head-arrow(resolved-style, -0.05, message-catalog)
    }
  })
}

// Each node is a data cell plus a tinted next-pointer cell. Optional per-node
// `addresses` are drawn underneath.
#let _render-pointer-linked-list(values, resolved-style, addresses, should-render-head, marks, message-catalog) = {
  let data-cell-width = resolved-style.box-w
  let pointer-cell-width = resolved-style.box-w * 0.85
  let node-width = data-cell-width + pointer-cell-width
  let node-step = node-width + resolved-style.box-gap
  cetz.canvas({
    for (node-index, node-value) in values.enumerate() {
      let node-x = node-index * node-step
      _render-linear-cell(
        node-x,
        0,
        node-value,
        resolved-style,
        mark: _mark-at-index(marks, node-index),
      )
      let pointer-body = if node-index == values.len() - 1 {
        text(size: 0.72em)[NULL]
      } else {
        []
      }
      _render-linear-cell(
        node-x + data-cell-width,
        0,
        pointer-body,
        resolved-style,
        fill: resolved-style.ptr-fill,
        w: pointer-cell-width,
      )
      if node-index < values.len() - 1 {
        line(
          (node-x + node-width, resolved-style.box-h / 2),
          (node-x + node-step, resolved-style.box-h / 2),
          mark: (end: ">"),
          stroke: resolved-style.box-stroke,
        )
      }
      if addresses != none and node-index < addresses.len() {
        _render-linear-annotation(
          (node-x + node-width / 2, -0.32),
          addresses.at(node-index),
          resolved-style,
        )
      }
    }
    if should-render-head and values.len() > 0 {
      _render-head-arrow(resolved-style, -0.05, message-catalog)
    }
  })
}

#let _render-linked-list(values, resolved-style, uses-pointer-cells, addresses, should-render-head, marks, cat: default-catalog) = scaled(resolved-style,
  if uses-pointer-cells {
    _render-pointer-linked-list(
      values,
      resolved-style,
      addresses,
      should-render-head,
      marks,
      cat,
    )
  } else {
    _render-simple-linked-list(
      values,
      resolved-style,
      should-render-head,
      marks,
      cat,
    )
  }
)

// `insert` appends by default or inserts at `index`; `delete` removes the first
// matching value. `prepend`, `delete-at`, and `search` cover the other common
// teaching operations without changing the original call shapes.
#let _create-linked-list-object(values, style, pointer, addresses, head, message-catalog) = {
  let resolved-style = resolve(style)
  let render-values(current-values, marks) = _render-linked-list(
    current-values,
    resolved-style,
    pointer,
    addresses,
    head,
    marks,
    cat: message-catalog,
  )
  (
    diagram: render-values(values, (:)),
    insert: (v, index: none, step-label: none) => {
      let insertion-index = if index == none { values.len() } else { index }
      check-index(
        "linked-list insert()", "index:", insertion-index, values.len(),
        inclusive: true, subject: "list",
      )
      let values-after-insertion = _insert-sequence-value(values, insertion-index, v)
      let addresses-after-insertion = _insert-address-placeholder(addresses, insertion-index)
      _create-linear-operation-step(
        if step-label == none {
          if index == none {
            msg(message-catalog, "list.insert", v)
          } else {
            msg(message-catalog, "list.insert-at", v, insertion-index)
          }
        } else {
          step-label
        },
        render-values(values, (:)),
        _render-linked-list(
          values-after-insertion,
          resolved-style,
          pointer,
          addresses-after-insertion,
          head,
          (str(insertion-index): "new"),
          cat: message-catalog,
        ),
        _create-linked-list-object(
          values-after-insertion,
          style,
          pointer,
          addresses-after-insertion,
          head,
          message-catalog,
        ),
        style: style,
      )
    },
    prepend: (v, step-label: none) => {
      let values-after-prepend = (v,) + values
      let addresses-after-prepend = _insert-address-placeholder(addresses, 0)
      _create-linear-operation-step(
        if step-label == none {
          msg(message-catalog, "list.prepend", v)
        } else {
          step-label
        },
        render-values(values, (:)),
        _render-linked-list(
          values-after-prepend,
          resolved-style,
          pointer,
          addresses-after-prepend,
          head,
          ("0": "new"),
          cat: message-catalog,
        ),
        _create-linked-list-object(
          values-after-prepend,
          style,
          pointer,
          addresses-after-prepend,
          head,
          message-catalog,
        ),
        style: style,
      )
    },
    delete: (v, step-label: none) => {
      _check-deletable-value("linked-list delete()", values, v)
      let deletion-index = values.position(node-value => node-value == v)
      let values-after-deletion = _delete-sequence-value(values, deletion-index)
      let before-marks = (str(deletion-index): "remove")
      let addresses-after-deletion = _delete-address(addresses, deletion-index)
      _create-linear-operation-step(
        if step-label == none {
          msg(message-catalog, "list.delete", v)
        } else {
          step-label
        },
        render-values(values, before-marks),
        _render-linked-list(
          values-after-deletion,
          resolved-style,
          pointer,
          addresses-after-deletion,
          head,
          (:),
          cat: message-catalog,
        ),
        _create-linked-list-object(
          values-after-deletion,
          style,
          pointer,
          addresses-after-deletion,
          head,
          message-catalog,
        ),
        style: style,
      )
    },
    delete-at: (index, step-label: none) => {
      check-index("linked-list delete-at()", "index", index, values.len(), subject: "list")
      let values-after-deletion = _delete-sequence-value(values, index)
      let addresses-after-deletion = _delete-address(addresses, index)
      _create-linear-operation-step(
        if step-label == none {
          msg(message-catalog, "list.delete-at", index)
        } else {
          step-label
        },
        render-values(values, (str(index): "remove")),
        _render-linked-list(
          values-after-deletion,
          resolved-style,
          pointer,
          addresses-after-deletion,
          head,
          (:),
          cat: message-catalog,
        ),
        _create-linked-list-object(
          values-after-deletion,
          style,
          pointer,
          addresses-after-deletion,
          head,
          message-catalog,
        ),
        style: style,
      )
    },
    search: (v, step-label: none) => {
      let found-index = values.position(node-value => node-value == v)
      let visited-count = if found-index == none {
        values.len()
      } else {
        found-index + 1
      }
      _create-linear-operation-step(
        if step-label == none {
          msg(message-catalog, "list.search", v)
        } else {
          step-label
        },
        render-values(values, (:)),
        render-values(values, _create-linear-path-marks(visited-count)),
        _create-linked-list-object(
          values,
          style,
          pointer,
          addresses,
          head,
          message-catalog,
        ),
        style: style,
      ) + (found: found-index != none, index: found-index)
    },
  )
}

#let linked-list(style: (:), pointer: false, addresses: none, head: false, language: "en", messages: (:), ..vals) = {
  _validate-linear-list-arguments("linked-list()", vals.pos(), style, pointer, addresses, head)
  _create-linked-list-object(vals.pos(), style, pointer, addresses, head, resolve-catalog(language: language, messages: messages))
}

// ── Doubly linked list ───────────────────────────────────────────────────────

#let _render-doubly-linked-arrows(left-x, right-x, resolved-style) = {
  let forward-arrow-y = resolved-style.box-h * 0.68
  let backward-arrow-y = resolved-style.box-h * 0.32
  line(
    (left-x, forward-arrow-y),
    (right-x, forward-arrow-y),
    mark: (end: ">"),
    stroke: resolved-style.box-stroke,
  )
  line(
    (right-x, backward-arrow-y),
    (left-x, backward-arrow-y),
    mark: (end: ">"),
    stroke: resolved-style.box-stroke,
  )
}

#let _render-simple-doubly-linked-list(values, resolved-style, should-render-head, marks, message-catalog) = {
  let node-step = resolved-style.box-w + resolved-style.box-gap
  cetz.canvas({
    for (node-index, node-value) in values.enumerate() {
      let node-x = node-index * node-step
      _render-linear-cell(
        node-x,
        0,
        node-value,
        resolved-style,
        mark: _mark-at-index(marks, node-index),
      )
      if node-index < values.len() - 1 {
        _render-doubly-linked-arrows(
          node-x + resolved-style.box-w,
          (node-index + 1) * node-step,
          resolved-style,
        )
      }
    }
    if values.len() > 0 {
      let last-node-x = (values.len() - 1) * node-step
      line(
        (
          last-node-x + resolved-style.box-w,
          resolved-style.box-h * 0.68,
        ),
        (
          last-node-x + node-step,
          resolved-style.box-h * 0.68,
        ),
        mark: (end: ">"),
        stroke: resolved-style.box-stroke,
      )
      _render-linear-annotation(
        (
          last-node-x + node-step + 0.18,
          resolved-style.box-h / 2,
        ),
        _null,
        resolved-style,
      )
      if should-render-head {
        _render-head-arrow(resolved-style, -0.05, message-catalog)
      }
    } else {
      _render-linear-annotation(
        (resolved-style.box-w / 2, resolved-style.box-h / 2),
        _null,
        resolved-style,
      )
    }
  })
}

#let _render-pointer-doubly-linked-list(values, resolved-style, addresses, should-render-head, marks, message-catalog) = {
  let pointer-cell-width = resolved-style.box-w * 0.72
  let data-cell-width = resolved-style.box-w
  let node-width = pointer-cell-width + data-cell-width + pointer-cell-width
  let node-step = node-width + resolved-style.box-gap
  cetz.canvas({
    for (node-index, node-value) in values.enumerate() {
      let node-x = node-index * node-step
      _render-linear-cell(
        node-x,
        0,
        if node-index == 0 { text(size: 0.62em)[NULL] } else { [] },
        resolved-style,
        fill: resolved-style.prev-ptr-fill,
        w: pointer-cell-width,
      )
      _render-linear-cell(
        node-x + pointer-cell-width,
        0,
        node-value,
        resolved-style,
        mark: _mark-at-index(marks, node-index),
        w: data-cell-width,
      )
      _render-linear-cell(
        node-x + pointer-cell-width + data-cell-width,
        0,
        if node-index == values.len() - 1 {
          text(size: 0.62em)[NULL]
        } else {
          []
        },
        resolved-style,
        fill: resolved-style.next-ptr-fill,
        w: pointer-cell-width,
      )
      if node-index < values.len() - 1 {
        _render-doubly-linked-arrows(
          node-x + node-width,
          (node-index + 1) * node-step,
          resolved-style,
        )
      }
      if addresses != none and node-index < addresses.len() {
        _render-linear-annotation(
          (node-x + node-width / 2, -0.32),
          addresses.at(node-index),
          resolved-style,
        )
      }
    }
    if should-render-head and values.len() > 0 {
      _render-head-arrow(resolved-style, -0.05, message-catalog)
    }
  })
}

#let _render-doubly-linked-list(
  values,
  resolved-style,
  uses-pointer-cells,
  addresses,
  should-render-head,
  marks,
  cat: default-catalog,
) = scaled(resolved-style,
  if uses-pointer-cells {
    _render-pointer-doubly-linked-list(
      values,
      resolved-style,
      addresses,
      should-render-head,
      marks,
      cat,
    )
  } else {
    _render-simple-doubly-linked-list(
      values,
      resolved-style,
      should-render-head,
      marks,
      cat,
    )
  }
)

#let _create-doubly-linked-list-object(values, style, pointer, addresses, head, message-catalog) = {
  let resolved-style = resolve(style)
  let render-values(current-values, marks) = _render-doubly-linked-list(
    current-values,
    resolved-style,
    pointer,
    addresses,
    head,
    marks,
    cat: message-catalog,
  )
  (
    diagram: render-values(values, (:)),
    insert: (v, index: none, step-label: none) => {
      let insertion-index = if index == none { values.len() } else { index }
      check-index(
        "doubly-linked-list insert()", "index:", insertion-index, values.len(),
        inclusive: true, subject: "list",
      )
      let values-after-insertion = _insert-sequence-value(
        values,
        insertion-index,
        v,
      )
      let addresses-after-insertion = _insert-address-placeholder(
        addresses,
        insertion-index,
      )
      _create-linear-operation-step(
        if step-label == none {
          if index == none {
            msg(message-catalog, "list.insert", v)
          } else {
            msg(message-catalog, "list.insert-at", v, insertion-index)
          }
        } else {
          step-label
        },
        render-values(values, (:)),
        _render-doubly-linked-list(
          values-after-insertion,
          resolved-style,
          pointer,
          addresses-after-insertion,
          head,
          (str(insertion-index): "new"),
          cat: message-catalog,
        ),
        _create-doubly-linked-list-object(
          values-after-insertion,
          style,
          pointer,
          addresses-after-insertion,
          head,
          message-catalog,
        ),
        style: style,
      )
    },
    prepend: (v, step-label: none) => {
      let values-after-prepend = (v,) + values
      let addresses-after-prepend = _insert-address-placeholder(addresses, 0)
      _create-linear-operation-step(
        if step-label == none {
          msg(message-catalog, "list.prepend", v)
        } else {
          step-label
        },
        render-values(values, (:)),
        _render-doubly-linked-list(
          values-after-prepend,
          resolved-style,
          pointer,
          addresses-after-prepend,
          head,
          ("0": "new"),
          cat: message-catalog,
        ),
        _create-doubly-linked-list-object(
          values-after-prepend,
          style,
          pointer,
          addresses-after-prepend,
          head,
          message-catalog,
        ),
        style: style,
      )
    },
    delete: (v, step-label: none) => {
      _check-deletable-value("doubly-linked-list delete()", values, v)
      let deletion-index = values.position(node-value => node-value == v)
      let values-after-deletion = _delete-sequence-value(values, deletion-index)
      let before-marks = (str(deletion-index): "remove")
      let addresses-after-deletion = _delete-address(addresses, deletion-index)
      _create-linear-operation-step(
        if step-label == none {
          msg(message-catalog, "list.delete", v)
        } else {
          step-label
        },
        render-values(values, before-marks),
        _render-doubly-linked-list(
          values-after-deletion,
          resolved-style,
          pointer,
          addresses-after-deletion,
          head,
          (:),
          cat: message-catalog,
        ),
        _create-doubly-linked-list-object(
          values-after-deletion,
          style,
          pointer,
          addresses-after-deletion,
          head,
          message-catalog,
        ),
        style: style,
      )
    },
    delete-at: (index, step-label: none) => {
      check-index("doubly-linked-list delete-at()", "index", index, values.len(), subject: "list")
      let values-after-deletion = _delete-sequence-value(values, index)
      let addresses-after-deletion = _delete-address(addresses, index)
      _create-linear-operation-step(
        if step-label == none {
          msg(message-catalog, "list.delete-at", index)
        } else {
          step-label
        },
        render-values(values, (str(index): "remove")),
        _render-doubly-linked-list(
          values-after-deletion,
          resolved-style,
          pointer,
          addresses-after-deletion,
          head,
          (:),
          cat: message-catalog,
        ),
        _create-doubly-linked-list-object(
          values-after-deletion,
          style,
          pointer,
          addresses-after-deletion,
          head,
          message-catalog,
        ),
        style: style,
      )
    },
    search: (v, step-label: none) => {
      let found-index = values.position(node-value => node-value == v)
      let visited-count = if found-index == none {
        values.len()
      } else {
        found-index + 1
      }
      _create-linear-operation-step(
        if step-label == none {
          msg(message-catalog, "list.search", v)
        } else {
          step-label
        },
        render-values(values, (:)),
        render-values(values, _create-linear-path-marks(visited-count)),
        _create-doubly-linked-list-object(
          values,
          style,
          pointer,
          addresses,
          head,
          message-catalog,
        ),
        style: style,
      ) + (found: found-index != none, index: found-index)
    },
  )
}

#let doubly-linked-list(style: (:), pointer: false, addresses: none, head: false, language: "en", messages: (:), ..vals) = {
  _validate-linear-list-arguments("doubly-linked-list()", vals.pos(), style, pointer, addresses, head)
  _create-doubly-linked-list-object(vals.pos(), style, pointer, addresses, head, resolve-catalog(language: language, messages: messages))
}

// ── Stack ────────────────────────────────────────────────────────────────────

// First value is the top of the stack.
#let _render-stack(values, resolved-style, marks, top-label) = {
  let cell-step = resolved-style.box-h + resolved-style.box-gap * 0.35
  let label-gap = if resolved-style.box-gap > 0.45 {
    resolved-style.box-gap
  } else {
    0.45
  }
  scaled(resolved-style, cetz.canvas({
    for (cell-index, cell-value) in values.enumerate() {
      _render-linear-cell(
        0,
        -cell-index * cell-step,
        cell-value,
        resolved-style,
        mark: _mark-at-index(marks, cell-index),
      )
    }
    if values.len() > 0 {
      _render-linear-annotation(
        (
          resolved-style.box-w + label-gap,
          resolved-style.box-h / 2,
        ),
        top-label,
        resolved-style,
      )
    }
  }))
}

#let _create-stack-object(values, style, top-label, message-catalog) = {
  let resolved-style = resolve((box-gap: 0) + style)
  (
    diagram: _render-stack(values, resolved-style, (:), top-label),
    push: (v, step-label: none) => _create-linear-operation-step(
      if step-label == none {
        msg(message-catalog, "stack.push", v)
      } else {
        step-label
      },
      _render-stack(values, resolved-style, (:), top-label),
      _render-stack((v,) + values, resolved-style, ("0": "new"), top-label),
      _create-stack-object(
        (v,) + values,
        style,
        top-label,
        message-catalog,
      ),
      style: style,
    ),
    pop: (step-label: none) => {
      _check-non-empty-structure("stack pop()", values, "pop()", "stack")
      let values-after-pop = values.slice(1)
      _create-linear-operation-step(
        if step-label == none {
          msg(message-catalog, "stack.pop")
        } else {
          step-label
        },
        _render-stack(values, resolved-style, ("0": "remove"), top-label),
        _render-stack(values-after-pop, resolved-style, (:), top-label),
        _create-stack-object(
          values-after-pop,
          style,
          top-label,
          message-catalog,
        ),
        style: style,
      )
    },
  )
}

// `top-label: auto` uses the localized default; pass any content to override it.
#let stack(style: (:), top-label: auto, language: "en", messages: (:), ..vals) = {
  validate-style("stack()", style)
  let message-catalog = resolve-catalog(language: language, messages: messages)
  let resolved-top-label = if top-label == auto {
    msg(message-catalog, "stack.top")
  } else {
    top-label
  }
  _create-stack-object(
    vals.pos(),
    style,
    resolved-top-label,
    message-catalog,
  )
}

// ── Queue ────────────────────────────────────────────────────────────────────

// Cells are contiguous (array view). The `enqueue`/`dequeue` builder arguments
// draw an external element entering at the rear or leaving the front in a
// single frame; the object's operations render a before → after step instead.
#let _render-queue(values, resolved-style, marks, enqueue-value, dequeue-value, front-label, rear-label, message-catalog) = {
  let cell-width = resolved-style.box-w
  let cell-count = values.len()
  let queue-width = cell-count * cell-width
  let operation-fill = rgb("#DCE5FB")
  scaled(resolved-style, cetz.canvas({
    for (cell-index, cell-value) in values.enumerate() {
      _render-linear-cell(
        cell-index * cell-width,
        0,
        cell-value,
        resolved-style,
        mark: _mark-at-index(marks, cell-index),
      )
    }
    if cell-count == 1 {
      _render-linear-annotation(
        (cell-width / 2, resolved-style.box-h + 0.38),
        [#front-label, #rear-label],
        resolved-style,
      )
    } else if cell-count > 1 {
      _render-linear-annotation(
        (cell-width / 2, resolved-style.box-h + 0.38),
        front-label,
        resolved-style,
      )
      _render-linear-annotation(
        (
          queue-width - cell-width / 2,
          resolved-style.box-h + 0.38,
        ),
        rear-label,
        resolved-style,
      )
    }
    let cell-midpoint-y = resolved-style.box-h / 2
    if enqueue-value != none {
      let external-cell-x = queue-width + 0.95
      _render-linear-cell(
        external-cell-x,
        0,
        enqueue-value,
        resolved-style,
        fill: operation-fill,
      )
      line(
        (external-cell-x, cell-midpoint-y),
        (queue-width, cell-midpoint-y),
        mark: (end: ">"),
        stroke: resolved-style.box-stroke,
      )
      _render-linear-annotation(
        (external-cell-x + cell-width / 2, -0.42),
        msg(message-catalog, "queue.enqueue-label"),
        resolved-style,
      )
    }
    if dequeue-value != none {
      let external-cell-x = -0.95 - cell-width
      _render-linear-cell(
        external-cell-x,
        0,
        dequeue-value,
        resolved-style,
        fill: operation-fill,
      )
      line(
        (0, cell-midpoint-y),
        (external-cell-x + cell-width, cell-midpoint-y),
        mark: (end: ">"),
        stroke: resolved-style.box-stroke,
      )
      _render-linear-annotation(
        (external-cell-x + cell-width / 2, -0.42),
        msg(message-catalog, "queue.dequeue-label"),
        resolved-style,
      )
    }
  }))
}

#let _create-queue-object(values, style, enqueue-value, dequeue-value, front-label, rear-label, message-catalog) = {
  let resolved-style = resolve(style)
  let render-values(current-values, marks) = _render-queue(
    current-values,
    resolved-style,
    marks,
    none,
    none,
    front-label,
    rear-label,
    message-catalog,
  )
  (
    diagram: _render-queue(
      values,
      resolved-style,
      (:),
      enqueue-value,
      dequeue-value,
      front-label,
      rear-label,
      message-catalog,
    ),
    enqueue: (v, step-label: none) => _create-linear-operation-step(
      if step-label == none {
        msg(message-catalog, "queue.enqueue", v)
      } else {
        step-label
      },
      render-values(values, (:)),
      render-values(values + (v,), (str(values.len()): "new")),
      _create-queue-object(
        values + (v,),
        style,
        enqueue-value,
        dequeue-value,
        front-label,
        rear-label,
        message-catalog,
      ),
      style: style,
    ),
    dequeue: (step-label: none) => {
      _check-non-empty-structure("queue dequeue()", values, "dequeue()", "queue")
      let values-after-dequeue = values.slice(1)
      _create-linear-operation-step(
        if step-label == none {
          msg(message-catalog, "queue.dequeue")
        } else {
          step-label
        },
        render-values(values, ("0": "remove")),
        render-values(values-after-dequeue, (:)),
        _create-queue-object(
          values-after-dequeue,
          style,
          enqueue-value,
          dequeue-value,
          front-label,
          rear-label,
          message-catalog,
        ),
        style: style,
      )
    },
  )
}

// `front-label`/`rear-label: auto` use the localized defaults; pass any content
// to override either one.
#let queue(
  style: (:),
  enqueue: none,
  dequeue: none,
  front-label: auto,
  rear-label: auto,
  language: "en",
  messages: (:),
  ..vals,
) = {
  validate-style("queue()", style)
  let message-catalog = resolve-catalog(language: language, messages: messages)
  let resolved-front-label = if front-label == auto {
    msg(message-catalog, "queue.front")
  } else {
    front-label
  }
  let resolved-rear-label = if rear-label == auto {
    msg(message-catalog, "queue.rear")
  } else {
    rear-label
  }
  _create-queue-object(
    vals.pos(),
    style,
    enqueue,
    dequeue,
    resolved-front-label,
    resolved-rear-label,
    message-catalog,
  )
}

// `marks` is an array of `(level, index, kind)` triples, so one physical
// node can carry the same highlight kind across every level it appears at.
#let _skip-list-mark-at(marks, level, node-index) = {
  for mark in marks {
    let mark-matches-node = (
      mark.at(0) == level and mark.at(1) == node-index
    )
    if mark-matches-node { return mark.at(2) }
  }
  none
}

#let _skip-list-row(values, marks, resolved-style, level-filter, level, level-spacing) = {
  let node-step = resolved-style.box-w + resolved-style.box-gap
  let level-offset = level-spacing * level

  for (node-index, node-value) in values.enumerate() {
    if not level-filter.at(node-index) {
      continue
    }
    _render-linear-cell(
      node-index * node-step,
      level-offset,
      node-value,
      resolved-style,
      mark: _skip-list-mark-at(marks, level, node-index),
    )

    // Upper-level nodes link to the same node in the level below.
    if level != 0 {
      line(
        (node-index * node-step + resolved-style.box-w / 2, level-offset),
        (
          node-index * node-step + resolved-style.box-w / 2,
          resolved-style.box-h + (level-offset - level-spacing),
        ),
        mark: (end: ">"),
        stroke: resolved-style.box-stroke,
      )
    }

    let next-visible-index = level-filter.enumerate().position(
      indexed-visibility => (
        indexed-visibility.at(0) > node-index
          and indexed-visibility.at(1)
      ),
    )
    if next-visible-index == none {
      next-visible-index = values.len()
    }
    line(
      (
        node-index * node-step + resolved-style.box-w,
        resolved-style.box-h / 2 + level-offset,
      ),
      (
        next-visible-index * node-step,
        resolved-style.box-h / 2 + level-offset,
      ),
      mark: (end: ">"),
      stroke: resolved-style.box-stroke,
    )
  }
  _render-linear-node-content(
    (
      values.len() * node-step + resolved-style.box-w / 2,
      resolved-style.box-h / 2 + level-offset,
    ),
    $nothing$,
    resolved-style,
  )
}

#let _render-skip-list(values, marks, resolved-style, level-filters, level-spacing) = {
  scaled(resolved-style, cetz.canvas({
    for (level, level-filter) in level-filters.enumerate() {
      _skip-list-row(
        values,
        marks,
        resolved-style,
        level-filter,
        int(level),
        level-spacing,
      )
    }
  }))
}

// Which node indices are present at each level, level 0 first. A node is
// present at every level up to its own assigned height.
// The tallest element is conventionally a sentinel head that spans every
// level on its own, not a promoted data value (see the skip list article's
// "Implementation details"). This library has no separate head box, so the
// first real value stands in for it and is always drawn at every level,
// regardless of what its own height would otherwise be.
#let _skip-list-top(nodes) = calc.max(
  0,
  ..nodes.map(skip-list-node => skip-list-node.level),
)

#let _skip-list-height(nodes, node-index) = if node-index == 0 {
  _skip-list-top(nodes)
} else {
  nodes.at(node-index).level
}

#let _skip-list-level-filters(nodes) = {
  let top-level = _skip-list-top(nodes)
  range(top-level + 1).map(level => nodes.enumerate().map(
    ((node-index, skip-list-node)) => (
      node-index == 0 or skip-list-node.level >= level
    ),
  ))
}

// A cheap, deterministic stand-in for a coin flip: Typst has no RNG, and
// diagrams need to stay reproducible across recompiles, so the same value
// always hashes the same way regardless of how many other nodes exist.
#let _skip-list-hash(value, salt) = {
  let hash-value = 0
  for byte in bytes(str(value) + "#" + str(salt)) {
    hash-value = calc.rem(hash-value * 31 + byte, 1000000007)
  }
  hash-value
}

// Default `decision-fn`: promotes `value` to `level` about half the time.
// It depends only on the value and the level being tested, never on the
// value's position or how many other nodes exist, so a node's height stays
// fixed once assigned — inserting or deleting elsewhere never reshuffles it.
#let default-decision-fn(level, value) = calc.rem(_skip-list-hash(value, level), 2) == 0

// The height for one node: keeps promoting while `decision-fn` says yes,
// capped at `max-level`.
#let _skip-list-node-level(value, decision-fn, max-level) = {
  let level = 0
  while level < max-level {
    let should-promote = decision-fn(level + 1, value)
    check-callback-result("skip-list()", "decision-fn:", should-promote, (bool,))
    if not should-promote { break }
    level += 1
  }
  level
}

#let _skip-list-values(nodes) = nodes.map(skip-list-node => skip-list-node.value)

// A skip list searches by comparing keys, so its values must be mutually
// comparable, unique, and already in ascending order — the invariant the
// levels are built on.
#let _validate-skip-list-values(where, values) = {
  check-comparable(where, "values", values, subject: "value")
  check-unique(where, "values", values, subject: "value")
  for value-index in range(1, values.len()) {
    let previous-value = values.at(value-index - 1)
    let value = values.at(value-index)
    if previous-value < value { continue }
    fail(
      where,
      "value " + show-value(value) + " comes after " + show-value(previous-value) + ", so the values are not ascending",
      expected: "strictly ascending values",
      fix: "sort the values before passing them",
    )
  }
}

#let _validate-skip-list-insert(where, nodes, value, level, max-level) = {
  let existing-values = _skip-list-values(nodes)
  check-comparable-with(where, "value", value, existing-values, subject: "value")
  if value in existing-values {
    fail(
      where,
      "value " + show-value(value) + " is already in the skip list",
      expected: "a value that is not present yet",
      fix: "insert a different value; a skip list holds each value once",
    )
  }
  if level == auto { return }
  check-integer(where, "level:", level, min: 0, max: max-level)
}

#let _validate-skip-list-key(where, nodes, key) = {
  check-comparable-with(where, "key", key, _skip-list-values(nodes), subject: "value")
}

// Returns the list of `(level, column-index, "path")` marks tracing the
// search path down to `key`, or to its predecessor when it is absent.
#let _skip-list-search-marks(values, level-filters, key) = {
  let predecessor-index = 0
  for (node-index, node-value) in values.enumerate() {
    if node-value <= key {
      predecessor-index = node-index
    } else {
      break
    }
  }

  let marks = ()
  let current-column = 0
  for (current-level, level-filter) in level-filters.enumerate().rev() {
    let next-entry-indices = level-filter.enumerate()
      .filter(indexed-visibility => (
        indexed-visibility.at(0) >= current-column
          and indexed-visibility.at(1)
      ))
      .map(indexed-visibility => indexed-visibility.at(0))
    if next-entry-indices.len() == 0 { continue }
    let next-entry-index = next-entry-indices.remove(0)

    while next-entry-index != none and next-entry-index <= predecessor-index {
      marks.push((current-level, next-entry-index, "path"))
      current-column = next-entry-index

      if predecessor-index == next-entry-index or next-entry-indices.len() == 0 {
        break
      }
      next-entry-index = next-entry-indices.remove(0)
    }
  }

  marks
}

// Skip-list state is an array of `(value:, level:)` nodes, sorted by
// value. Keeping each node's assigned level explicit (rather than
// re-deriving it from array position on every render) is what lets insert
// and delete touch only the node that actually changed.
#let _create-skip-list-object(nodes, style, decision-fn, level-spacing, max-level, message-catalog) = {
  let resolved-style = resolve(style)
  let render-nodes(current-nodes, marks) = _render-skip-list(
    current-nodes.map(skip-list-node => skip-list-node.value),
    marks,
    resolved-style,
    _skip-list-level-filters(current-nodes),
    level-spacing,
  )

  (
    diagram: render-nodes(nodes, ()),
    search: (key, step-label: none) => {
      _validate-skip-list-key("skip-list search()", nodes, key)
      _create-linear-operation-step(
        if step-label == none {
          msg(message-catalog, "skip.search", key)
        } else {
          step-label
        },
        render-nodes(nodes, ()),
        render-nodes(
          nodes,
          _skip-list-search-marks(
            nodes.map(skip-list-node => skip-list-node.value),
            _skip-list-level-filters(nodes),
            key,
          ),
        ),
        _create-skip-list-object(
          nodes,
          style,
          decision-fn,
          level-spacing,
          max-level,
          message-catalog,
        ),
        style: style,
      ) + (
        found: key in nodes.map(skip-list-node => skip-list-node.value),
        index: nodes.position(skip-list-node => skip-list-node.value == key),
      )
    },
    // `level: auto` assigns the new value's height with `decision-fn`;
    // pass an explicit level to force a specific tower height instead.
    insert: (value, level: auto, step-label: none) => {
      _validate-skip-list-insert("skip-list insert()", nodes, value, level, max-level)
      let assigned-level = if level == auto {
        _skip-list-node-level(value, decision-fn, max-level)
      } else {
        level
      }
      let insertion-index = 0
      while insertion-index < nodes.len() and nodes.at(insertion-index).value < value {
        insertion-index += 1
      }
      let nodes-after-insertion = (
        nodes.slice(0, insertion-index)
          + ((value: value, level: assigned-level),)
          + nodes.slice(insertion-index)
      )
      let marks = range(
        _skip-list-height(nodes-after-insertion, insertion-index) + 1,
      ).map(level => (level, insertion-index, "new"))
      _create-linear-operation-step(
        if step-label == none {
          msg(message-catalog, "skip.insert", value)
        } else {
          step-label
        },
        render-nodes(nodes, ()),
        render-nodes(nodes-after-insertion, marks),
        _create-skip-list-object(
          nodes-after-insertion,
          style,
          decision-fn,
          level-spacing,
          max-level,
          message-catalog,
        ),
        style: style,
      )
    },
    delete: (value, step-label: none) => {
      _validate-skip-list-key("skip-list delete()", nodes, value)
      let deletion-index = nodes.position(
        skip-list-node => skip-list-node.value == value,
      )
      if deletion-index == none {
        fail(
          "skip-list delete()",
          "value " + show-value(value) + " is not in the skip list, so there is nothing to delete",
          expected: "one of the values: " + show-list(_skip-list-values(nodes)),
          fix: "delete a value the list holds; use search(value) to show an unsuccessful lookup",
        )
      }
      let marks = range(
        _skip-list-height(nodes, deletion-index) + 1,
      ).map(level => (level, deletion-index, "remove"))
      let nodes-after-deletion = (
        nodes.slice(0, deletion-index) + nodes.slice(deletion-index + 1)
      )
      _create-linear-operation-step(
        if step-label == none {
          msg(message-catalog, "skip.delete", value)
        } else {
          step-label
        },
        render-nodes(nodes, marks),
        render-nodes(nodes-after-deletion, ()),
        _create-skip-list-object(
          nodes-after-deletion,
          style,
          decision-fn,
          level-spacing,
          max-level,
          message-catalog,
        ),
        style: style,
      )
    },
  )
}

#let skip-list(style: (:), decision-fn: default-decision-fn, level-spacing: 1.4, max-level: 4, language: "en", messages: (:), ..vals) = {
  let values = vals.pos()
  validate-style("skip-list()", style)
  check-function("skip-list()", "decision-fn:", decision-fn)
  check-integer("skip-list()", "max-level:", max-level, min: 0)
  check-positive("skip-list()", "level-spacing:", level-spacing)
  _validate-skip-list-values("skip-list()", values)
  let nodes = values.map(v => (value: v, level: _skip-list-node-level(v, decision-fn, max-level)))
  _create-skip-list-object(nodes, style, decision-fn, level-spacing, max-level, resolve-catalog(language: language, messages: messages))
}
