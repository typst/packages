#import "model.typ": _dense, _nonnegative, _correlation-point

// Absolute weights: sum_i importance[i] * relation[i][j].
// Relative weights are percentages in 0..100, not Typst ratio values.
// Independent rounding is deliberate: rounded percentages may not sum to 100.
#let qfd-weights(importance, matrix, digits: 0) = {
  assert(type(matrix) == array and matrix.len() > 0,
    message: "qfd: matrix must not be empty")
  assert(type(matrix.first()) == array and matrix.first().len() > 0,
    message: "qfd: matrix must have at least one column")
  let rows = matrix.len()
  let columns = matrix.first().len()
  let matrix = _dense(matrix, rows, columns)
  assert(type(importance) == array and importance.len() == rows,
    message: "qfd: importance must have one number per WHAT")
  assert(importance.all(_nonnegative),
    message: "qfd: importance values must be finite, nonnegative numbers")
  assert(type(digits) == int and digits >= 0 and digits <= 10,
    message: "qfd: digits must be an integer from 0 to 10")
  let absolute = range(columns).map(c =>
    range(rows).map(r => importance.at(r) * matrix.at(r).at(c)).sum())
  let total = absolute.sum()
  let relative = absolute.map(v => if total == 0 { 0 } else { 100 * v / total })
  (
    absolute: absolute,
    total: total,
    relative: relative,
    rounded: relative.map(v => calc.round(v, digits: digits)),
  )
}

// Public geometry helper shares validation with normalized roof records.
#let qfd-correlation-point = _correlation-point
