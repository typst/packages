// Validate figure semantics before measuring or drawing anything. The returned
// record is shared by panels; they never reinterpret weights or visibility.
#import "model.typ": qfd-matrix, _dense, _correlations, _alternatives
#import "calculations.typ": qfd-weights
#import "labels.typ": _labels

#let prepare-figure(
  whats, hows, relations, matrix, importance, correlations, targets, difficulty,
  directions, basement, alternatives, score-range, legend-order, labels,
  show-roof, show-importance, show-basement, show-competitive, show-legend,
  show-rel-legend, show-corr-legend, show-eval-legend, relative-digits, changes,
) = {
  assert(type(whats) == array and whats.len() > 0,
    message: "qfd: whats must be a nonempty array")
  assert(type(hows) == array and hows.len() > 0,
    message: "qfd: hows must be a nonempty array")
  let nr = whats.len()
  let nc = hows.len()
  let rel = if matrix == none {
    qfd-matrix(nr, nc, relations: relations)
  } else {
    assert(type(relations) == array and relations.len() == 0,
      message: "qfd: pass either matrix or relations, not both")
    _dense(matrix, nr, nc)
  }
  let corr = _correlations(correlations, nc)
  let weights = if importance == none { none } else {
    qfd-weights(importance, rel, digits: relative-digits)
  }
  if targets != none {
    assert(type(targets) == array and targets.len() == nc,
      message: "qfd: targets must have one entry per HOW")
  }
  assert(type(labels) == dictionary, message: "qfd: labels must be a dictionary")
  for key in labels.keys() {
    assert(key in _labels, message: "qfd: unknown label key: " + key)
  }
  let labels = _labels + labels
  assert(type(score-range) == array and score-range.len() == 2,
    message: "qfd: score-range must contain two integer endpoints")
  let (score-min, score-max) = score-range
  assert(type(score-min) == int and type(score-max) == int and score-min < score-max,
    message: "qfd: score-range must contain increasing integer endpoints")
  let alternatives = _alternatives(alternatives, nr, score-range)
  let show-importance = if show-importance == auto { importance != none } else { show-importance }
  let show-competitive = if show-competitive == auto { alternatives.len() > 0 } else { show-competitive }
  assert(not show-importance or importance != none,
    message: "qfd: show-importance requires importance data")
  for flag in (show-roof, show-importance, show-basement, show-competitive,
    show-legend, show-rel-legend, show-corr-legend, show-eval-legend) {
    assert(type(flag) == bool, message: "qfd: visibility flags must be booleans")
  }
  let order = if legend-order == auto { range(1, alternatives.len() + 1) } else { legend-order }
  assert(type(order) == array and order.sorted() == range(1, alternatives.len() + 1),
    message: "qfd: legend-order must be a permutation of the 1-based alternative indices")

  if difficulty != none {
    assert(type(difficulty) == array and difficulty.len() == nc,
      message: "qfd: difficulty must have one entry per HOW")
  }
  let directions = if directions == none { range(nc).map(_ => none) } else { directions }
  assert(type(directions) == array and directions.len() == nc and
    directions.all(d => d == none or d in ("maximize", "minimize", "target", "none")),
    message: "qfd: directions must contain one maximize/minimize/target/none per HOW")
  let basement = if basement == auto {
    let rows = ()
    if targets != none and targets.any(v => v != none) { rows.push((label: labels.target, values: targets)) }
    if difficulty != none { rows.push((label: labels.difficulty, values: difficulty)) }
    if weights != none {
      rows.push((label: labels.absolute, values: weights.absolute, computed: true))
      rows.push((label: labels.relative, values: weights.rounded, bold: true))
    }
    rows
  } else { basement }
  assert(type(basement) == array, message: "qfd: basement must be auto or an array of rows")
  for row in basement {
    assert(type(row) == dictionary and "label" in row and "values" in row,
      message: "qfd: each basement row requires label and values")
    assert(type(row.values) == array and row.values.len() == nc,
      message: "qfd: each basement row must have one value per HOW")
  }
  let basement = if show-basement { basement } else { () }

  if changes != none {
    let statuses = ("unchanged", "added", "removed", "changed")
    assert(type(changes) == dictionary, message: "qfd: changes must be a revision dictionary")
    assert(changes.rows.len() == nr and changes.columns.len() == nc,
      message: "qfd: revision dimensions must match the figure")
    assert(changes.rows.all(s => s in statuses) and changes.columns.all(s => s in statuses),
      message: "qfd: unknown revision status")
    assert(changes.cells.len() == nr and changes.cells.all(r => r.len() == nc and r.all(s => s in statuses)),
      message: "qfd: revision cells must match the matrix")
    let previous = _dense(changes.previous-matrix, nr, nc)
  }
  (whats: whats, hows: hows, nr: nr, nc: nc, matrix: rel, importance: importance,
   correlations: corr, targets: targets, directions: directions, basement: basement,
   alternatives: alternatives, score-range: score-range, legend-order: order,
   labels: labels, changes: changes, weights: weights,
   show-roof: show-roof, show-importance: show-importance, show-competitive: show-competitive,
   show-legend: show-legend, show-rel-legend: show-rel-legend,
   show-corr-legend: show-corr-legend, show-eval-legend: show-eval-legend)
}
