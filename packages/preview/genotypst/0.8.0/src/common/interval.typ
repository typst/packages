/// Validates an optional integer lower-bounded by `min`.
///
/// - value (int, none): Value to validate.
/// - name (str): Parameter name for error messages.
/// - min (int): Minimum allowed value.
/// -> none
#let _validate-optional-int-at-least(value, name, min) = {
  if value == none { return }
  assert(type(value) == int, message: name + " must be an integer.")
  assert(
    value >= min,
    message: name + " must be >= " + str(min) + ".",
  )
}

/// Validates an optional integer window with inclusive bounds.
///
/// - start (int, none): Optional start value.
/// - end (int, none): Optional end value.
/// - start-name (str): Name for start in error messages.
/// - end-name (str): Name for end in error messages.
/// - min (int): Minimum allowed value for both bounds.
/// -> none
#let _validate-interval(
  start,
  end,
  start-name: "start",
  end-name: "end",
  min: 1,
) = {
  _validate-optional-int-at-least(start, start-name, min)
  _validate-optional-int-at-least(end, end-name, min)
  if start != none and end != none {
    assert(
      start <= end,
      message: start-name + " must be <= " + end-name + ".",
    )
  }
}

/// Resolves a 1-indexed inclusive window to 0-indexed [start, end).
///
/// - start (int, none): Optional 1-indexed inclusive start.
/// - end (int, none): Optional 1-indexed inclusive end.
/// - max-len (int): Maximum valid 1-indexed position.
/// - window-name (str): Name used in error messages.
/// -> dictionary with keys:
///   - actual-start: int, 0-indexed inclusive start
///   - actual-end: int, 0-indexed exclusive end
#let _resolve-1indexed-window(start, end, max-len, window-name: "window") = {
  assert(type(max-len) == int, message: "max-len must be an integer.")
  assert(max-len >= 0, message: "max-len must be non-negative.")
  _validate-interval(start, end)

  let actual-start = if start == none { 0 } else { calc.max(0, start - 1) }
  let actual-end = if end == none { max-len } else { calc.min(end, max-len) }
  let start-label = if start == none { "none" } else { str(start) }
  let end-label = if end == none { "none" } else { str(end) }

  assert(
    actual-start < actual-end,
    message: (
      "Resolved "
        + window-name
        + " window is empty. Check start/end (1-indexed, inclusive). "
        + "Received start="
        + start-label
        + ", end="
        + end-label
        + "; resolved start="
        + str(actual-start + 1)
        + ", end="
        + str(actual-end)
        + "."
    ),
  )

  (actual-start: actual-start, actual-end: actual-end)
}
