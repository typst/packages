// Singly and doubly linked-list state, operations, and rendering.

#import "@preview/cetz:0.5.2"
#import "style.typ": resolve, scaled, resolve-mark-style, validate-style
#import "validate.typ": (
  check-array, check-bool, check-callback-result, check-comparable,
  check-comparable-with, check-function, check-index, check-integer,
  check-positive, check-unique, fail, show-list, show-value,
)
#import "messages.typ": default-catalog, resolve-catalog, msg
#import cetz.draw: line, rect, content
#import "linear-common.typ": (
  _validate-linear-list-arguments,
  _check-deletable-value,
  _check-non-empty-structure,
  _render-linear-annotation,
  _render-linear-node-content,
  _null,
  _render-linear-cell,
  _mark-at-index,
  _insert-sequence-value,
  _delete-sequence-value,
  _insert-address-placeholder,
  _delete-address,
  _create-linear-path-marks,
  _render-head-arrow,
  _create-linear-operation-step,
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
