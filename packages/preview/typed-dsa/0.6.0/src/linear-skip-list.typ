// Skip-list state, algorithms, operations, layout, and rendering.
//
// Skip-list level selection and teaching traces are structure-specific and stay
// together rather than being forced through a generic linear-operation model.

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
