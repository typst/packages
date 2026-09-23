#import "model.typ": qfd-matrix, _dense, _nonnegative, _correlations
#import "calculations.typ": qfd-weights

// IDs are nonempty strings scoped to an axis. Labels remain native Typst content.
#let _records(records, axis, fields) = {
  assert(type(records) == array and records.len() > 0,
    message: "qfd: " + axis + " must be a nonempty array of records")
  let ids = ()
  for item in records {
    assert(type(item) == dictionary and "id" in item and "label" in item,
      message: "qfd: each " + axis + " record needs id and label")
    assert(item.keys().all(key => key in fields),
      message: "qfd: unsupported " + axis + " record field")
    assert(type(item.id) == str and item.id != "",
      message: "qfd: stable IDs must be nonempty strings")
    assert(not (item.id in ids), message: "qfd: duplicate " + axis + " ID: " + item.id)
    ids.push(item.id)
  }
  ids
}

// The return value is directly spreadable into qfd. Sparse relations use the
// same one-based indices as qfd-matrix; identities are for deployment/revision.
// Missing weights remain absent: manufacturing invented priorities is unsafe.
#let qfd-stage(rows: (), columns: (), relations: (), matrix: none,
  importance: auto, ..options) = {
  assert(options.pos().len() == 0, message: "qfd: stage options must be named")
  let options = options.named()
  let reserved = ("whats", "hows", "row-ids", "column-ids", "targets", "directions", "changes")
  assert(options.keys().all(key => not (key in reserved)),
    message: "qfd: stage identity, target, and direction fields must come from records")
  let row-ids = _records(rows, "row", ("id", "label", "weight"))
  let column-ids = _records(columns, "column", ("id", "label", "direction", "target"))
  let weights = rows.map(item => item.at("weight", default: none))
  assert(weights.all(value => value == none or _nonnegative(value)),
    message: "qfd: row weights must be finite, nonnegative numbers")
  if importance == auto {
    assert(weights.all(value => value == none) or weights.all(value => value != none),
      message: "qfd: supply all row weights or an explicit importance array")
    importance = if weights.all(value => value == none) { none } else { weights }
  }
  if importance != none {
    assert(type(importance) == array and importance.len() == rows.len() and importance.all(_nonnegative),
      message: "qfd: importance must contain one finite nonnegative number per row")
  }
  let directions = columns.map(item => item.at("direction", default: "none"))
  assert(directions.all(value => value in ("maximize", "minimize", "target", "none")),
    message: "qfd: direction must be maximize, minimize, target, or none")
  assert(type(relations) == array, message: "qfd: relations must be an array")
  assert(matrix == none or relations.len() == 0,
    message: "qfd: provide matrix or relations, not both")
  let matrix = if matrix == none { qfd-matrix(rows.len(), columns.len(), relations: relations) }
    else { _dense(matrix, rows.len(), columns.len()) }
  let correlations = options.at("correlations", default: ())
  let validated = _correlations(correlations, columns.len())
  options + (
    row-ids: row-ids, column-ids: column-ids,
    whats: rows.map(item => item.label), hows: columns.map(item => item.label),
    importance: importance, matrix: matrix,
    targets: columns.map(item => item.at("target", default: none)),
    directions: directions,
  )
}

// Validate the public, transparent stage dictionary before indexing it. This
// also supports a caller editing its values between construction and use.
#let _check-stage(stage) = {
  assert(type(stage) == dictionary, message: "qfd: expected a stage dictionary")
  for key in ("row-ids", "column-ids", "whats", "hows", "matrix", "importance", "targets", "directions") {
    assert(key in stage, message: "qfd: stage is missing " + key)
  }
  assert(type(stage.row-ids) == array and type(stage.column-ids) == array,
    message: "qfd: stage IDs must be arrays")
  for (ids, labels) in ((stage.row-ids, stage.whats), (stage.column-ids, stage.hows)) {
    assert(type(labels) == array and ids.len() == labels.len(), message: "qfd: IDs and labels must align")
  }
  assert(type(stage.targets) == array and stage.targets.len() == stage.column-ids.len(),
    message: "qfd: targets must align with column IDs")
  assert(type(stage.directions) == array and stage.directions.len() == stage.column-ids.len(),
    message: "qfd: directions must align with column IDs")
  let normalized = qfd-stage(
    rows: stage.row-ids.enumerate().map(((i, id)) => (id: id, label: stage.whats.at(i))),
    columns: stage.column-ids.enumerate().map(((i, id)) =>
      (id: id, label: stage.hows.at(i), target: stage.targets.at(i), direction: stage.directions.at(i))),
    matrix: stage.matrix, importance: stage.importance,
    correlations: stage.at("correlations", default: ()),
  )
  normalized
}

// Propagate full-precision relative priorities. Rounding belongs to display;
// even a small early rounding error would otherwise compound across stages.
#let qfd-deploy(previous-stage, columns: (), relations: (), matrix: none, ..options) = {
  let previous = _check-stage(previous-stage)
  assert(previous.importance != none,
    message: "qfd: deployment needs explicit importance in the previous stage")
  assert(not ("importance" in options.named()),
    message: "qfd: deployment importance is derived from the previous stage")
  let weights = qfd-weights(previous.importance, previous.matrix).relative
  let rows = previous.column-ids.enumerate().map(((i, id)) =>
    (id: id, label: previous.hows.at(i), weight: weights.at(i)))
  qfd-stage(rows: rows, columns: columns, relations: relations, matrix: matrix, ..options)
}
