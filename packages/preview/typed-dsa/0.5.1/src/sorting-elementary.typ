// Bubble, insertion, and selection sorting teaching traces.

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
  sort-sequence,
  _create-sort-result,
)


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
