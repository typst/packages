// Stack and queue state, operations, and rendering.

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
