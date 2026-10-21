// Shared linear-structure validation, cell rendering, and operation records.
//
// This module contains only concepts used by multiple linear families. List,
// container, and skip-list semantics remain in their owning modules.

#import "@preview/cetz:0.5.2"
#import "style.typ": resolve-mark-style, validate-style
#import "transition-view.typ": trans-view
#import "validate.typ": (
  check-array, check-bool, check-index, fail, show-list, show-value,
)
#import "messages.typ": msg
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
