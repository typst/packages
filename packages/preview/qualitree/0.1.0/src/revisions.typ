#import "stages.typ": _check-stage
#import "model.typ": _correlations

#let _indices(ids) = {
  let result = (:)
  for (i, id) in ids.enumerate() { result.insert(id, i) }
  result
}
#let _union(before, after) = after + before.filter(id => not (id in after))
#let _status(old, current, empty: none) = {
  if old == current { "unchanged" }
  else if old == empty { "added" }
  else if current == empty { "removed" }
  else { "changed" }
}
#let _aligned(values, ids, index, absent: none) = {
  if values == none { return none }
  ids.map(id => if id in index { values.at(index.at(id)) } else { absent })
}
#let _matrix-at(stage, rows, columns, row, column) = {
  if row in rows and column in columns { stage.matrix.at(rows.at(row)).at(columns.at(column)) }
  else { 0 }
}

// Compare current entities by stable ID, preserving after-order and appending
// removals in before-order. Historical cells are kept separately so removed
// rows/columns cannot influence current priority totals. Drawing options come
// from after; only labels, weights, targets, directions, relations and roof
// correlations participate in change detection. Positional custom basements
// and competitive profiles must be removed before diffing, rather than silently
// misaligning their data. A diff result is a display view, not another revision.
#let qfd-diff(before, after) = {
  let old = _check-stage(before)
  let current = _check-stage(after)
  for stage in (before, after) {
    assert(not ("changes" in stage), message: "qfd: compare source stages, not existing diffs")
    assert(stage.at("alternatives", default: ()).len() == 0,
      message: "qfd: revision comparison does not support competitive alternatives")
    assert(stage.at("basement", default: auto) == auto,
      message: "qfd: revision comparison requires automatic basement rows")
  }
  assert((old.importance == none) == (current.importance == none),
    message: "qfd: revision comparison requires weights on both stages or neither")
  let rows = _union(old.row-ids, current.row-ids)
  let columns = _union(old.column-ids, current.column-ids)
  let old-rows = _indices(old.row-ids)
  let new-rows = _indices(current.row-ids)
  let old-cols = _indices(old.column-ids)
  let new-cols = _indices(current.column-ids)
  let old-matrix = rows.map(row => columns.map(col => _matrix-at(old, old-rows, old-cols, row, col)))
  let matrix = rows.map(row => columns.map(col => _matrix-at(current, new-rows, new-cols, row, col)))
  let row-status = rows.map(id => {
    if not (id in old-rows) { return "added" }
    if not (id in new-rows) { return "removed" }
    let a = old-rows.at(id)
    let b = new-rows.at(id)
    if (old.whats.at(a) != current.whats.at(b) or
      (old.importance != none and old.importance.at(a) != current.importance.at(b))) { "changed" }
    else { "unchanged" }
  })
  let column-status = columns.map(id => {
    if not (id in old-cols) { return "added" }
    if not (id in new-cols) { return "removed" }
    let a = old-cols.at(id)
    let b = new-cols.at(id)
    if ((old.hows.at(a), old.targets.at(a), old.directions.at(a)) !=
      (current.hows.at(b), current.targets.at(b), current.directions.at(b))) { "changed" }
    else { "unchanged" }
  })
  let display(values-old, values-current, ids, index-old, index-current) = ids.map(id =>
    if id in index-current { values-current.at(index-current.at(id)) }
    else { values-old.at(index-old.at(id)) })
  let importance = _aligned(current.importance, rows, new-rows, absent: 0)
  let global-cols = _indices(columns)
  let roof(stage) = {
    let result = (:)
    for item in _correlations(stage.at("correlations", default: ()), stage.column-ids.len()) {
      let i = global-cols.at(stage.column-ids.at(item.i - 1)) + 1
      let j = global-cols.at(stage.column-ids.at(item.j - 1)) + 1
      let a = calc.min(i, j)
      let b = calc.max(i, j)
      result.insert(str(a) + ":" + str(b), (i: a, j: b, sign: item.sign))
    }
    result
  }
  let old-roof = roof(old)
  let new-roof = roof(current)
  let correlation-changes = _union(old-roof.keys(), new-roof.keys()).map(key => {
    let previous = old-roof.at(key, default: none)
    let current = new-roof.at(key, default: none)
    let position = if current == none { previous } else { current }
    let a = if previous == none { none } else { previous.sign }
    let b = if current == none { none } else { current.sign }
    (i: position.i, j: position.j, status: _status(a, b), previous: a, current: b)
  })
  let difficulty = (before.at("difficulty", default: none), after.at("difficulty", default: none))
  for (i, values) in difficulty.enumerate() {
    if values != none {
      assert(type(values) == array and values.len() == (old, current).at(i).column-ids.len(),
        message: "qfd: difficulty must align with column IDs")
    }
  }
  let aligned-difficulty = if difficulty.all(v => v == none) { none } else {
    let a = if difficulty.at(0) == none { old.column-ids.map(_ => none) } else { difficulty.at(0) }
    let b = if difficulty.at(1) == none { current.column-ids.map(_ => none) } else { difficulty.at(1) }
    display(a, b, columns, old-cols, new-cols)
  }
  after + (
    difficulty: aligned-difficulty,
    row-ids: rows, column-ids: columns,
    whats: display(old.whats, current.whats, rows, old-rows, new-rows),
    hows: display(old.hows, current.hows, columns, old-cols, new-cols),
    importance: importance, matrix: matrix,
    targets: display(old.targets, current.targets, columns, old-cols, new-cols),
    directions: display(old.directions, current.directions, columns, old-cols, new-cols),
    correlations: new-roof.values().map(item => (item.i, item.j, item.sign)),
    changes: (
      rows: row-status, columns: column-status,
      cells: range(rows.len()).map(r => range(columns.len()).map(c =>
        _status(old-matrix.at(r).at(c), matrix.at(r).at(c), empty: 0))),
      previous-matrix: old-matrix,
      previous-whats: _aligned(old.whats, rows, old-rows),
      previous-hows: _aligned(old.hows, columns, old-cols),
      previous-importance: _aligned(old.importance, rows, old-rows),
      previous-targets: _aligned(old.targets, columns, old-cols),
      previous-directions: _aligned(old.directions, columns, old-cols),
      correlations: correlation-changes,
    ),
  )
}
