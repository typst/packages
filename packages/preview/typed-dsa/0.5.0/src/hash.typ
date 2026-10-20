// Hash tables with separate chaining or linear probing.

#import "@preview/cetz:0.5.2"
#import cetz.draw: line
#import "style.typ": resolve, scaled, resolve-mark-style, array-style, indices-style, validate-style
#import "validate.typ": (
  check-callback-result, check-enum, check-function, check-integer, fail,
  show-value,
)
#import "grid.typ": array-view
#import "linear.typ": _render-linked-list, _null
#import "tree.typ": trans-view
#import "messages.typ": default-catalog, resolve-catalog, msg

// An entry is a bare key, a `(key, value)` pair, or a key with a separate
// `value:`. Any other array shape would silently be stored as one opaque key.
#let _normalize-hash-entry(where, entry-value, value: none) = {
  if value != none {
    return (key: entry-value, value: value, pair: true)
  }
  if type(entry-value) == array {
    if entry-value.len() == 2 {
      return (key: entry-value.at(0), value: entry-value.at(1), pair: true)
    }
    fail(
      where,
      "entry " + show-value(entry-value) + " has " + str(entry-value.len()) + " elements",
      expected: "a key, or a (key, value) pair",
      fix: "write it as (\"k\", \"v\")",
    )
  }
  (key: entry-value, value: none, pair: false)
}

#let _hash-entry-content(entry) = {
  if entry == none { return [] }
  if entry.at("tombstone", default: false) { return $times$ }
  if entry.pair { [#entry.key: #entry.value] } else { entry.key }
}

#let _calculate-default-hash(key, size) = {
  if type(key) == int { return calc.rem(calc.abs(key), size) }
  let hash-value = 0
  for byte in bytes(str(key)) {
    hash-value = calc.rem(hash-value * 31 + byte, size)
  }
  hash-value
}

// A custom hash must land inside the table on its own: silently folding an
// out-of-range result would hide the bug in the hash function being taught.
#let _calculate-hash-index(key, size, hash) = {
  if hash == auto { return _calculate-default-hash(key, size) }
  let raw-hash = hash(key)
  check-callback-result("hash-table()", "hash:", raw-hash, (int,))
  if raw-hash >= 0 and raw-hash < size {
    return raw-hash
  }
  fail(
    "hash-table()",
    "hash: returned " + str(raw-hash) + " for key " + show-value(key) + ", which is not a slot in this table",
    expected: "0 to " + str(size - 1) + ", for a table of size " + str(size),
    fix: "reduce the hash modulo the table size, for example key => calc.rem(key, " + str(size) + ")",
  )
}

#let _create-empty-chain-buckets(size) = range(size).map(_ => ())

#let _put-chained-entry(buckets, entry, hash) = {
  let bucket-index = _calculate-hash-index(entry.key, buckets.len(), hash)
  let bucket = buckets.at(bucket-index)
  let entry-position = bucket.position(
    bucket-entry => bucket-entry.key == entry.key,
  )
  if entry-position == none {
    bucket.push(entry)
  } else {
    bucket.at(entry-position) = entry
  }
  buckets.at(bucket-index) = bucket
  (
    model: buckets,
    bucket: bucket-index,
    position: if entry-position == none {
      bucket.len() - 1
    } else {
      entry-position
    },
    added: entry-position == none,
  )
}

#let _build-chained-hash-table(where, entries, size, hash) = {
  let buckets = _create-empty-chain-buckets(size)
  for entry-value in entries {
    buckets = _put-chained-entry(
      buckets,
      _normalize-hash-entry(where, entry-value),
      hash,
    ).model
  }
  buckets
}

#let _tombstone = (tombstone: true)

#let _find-linear-probe-slot(slots, key, hash) = {
  let start-index = _calculate-hash-index(key, slots.len(), hash)
  let probed-indices = ()
  let first-tombstone-index = none
  for offset in range(slots.len()) {
    let slot-index = calc.rem(start-index + offset, slots.len())
    probed-indices.push(slot-index)
    let slot = slots.at(slot-index)
    if slot == none {
      return (
        found: false,
        index: if first-tombstone-index == none {
          slot-index
        } else {
          first-tombstone-index
        },
        probes: probed-indices,
      )
    }
    if slot.at("tombstone", default: false) {
      if first-tombstone-index == none {
        first-tombstone-index = slot-index
      }
    } else if slot.key == key {
      return (found: true, index: slot-index, probes: probed-indices)
    }
  }
  (found: false, index: first-tombstone-index, probes: probed-indices)
}

#let _put-linear-probe-entry(slots, entry, hash) = {
  let probe-result = _find-linear-probe-slot(slots, entry.key, hash)
  if probe-result.index == none {
    fail(
      "hash-table insert()",
      "every slot is occupied, so key " + show-value(entry.key) + " cannot be placed",
      expected: "a free slot; linear probing cannot grow the table",
      fix: "raise size: above " + str(slots.len()) + ", or use collision: \"chaining\"",
    )
  }
  slots.at(probe-result.index) = entry
  (
    model: slots,
    index: probe-result.index,
    probes: probe-result.probes,
    added: not probe-result.found,
  )
}

#let _build-linear-probing-table(where, entries, size, hash) = {
  let slots = range(size).map(_ => none)
  for entry-value in entries {
    slots = _put-linear-probe-entry(
      slots,
      _normalize-hash-entry(where, entry-value),
      hash,
    ).model
  }
  slots
}

#let _resolve-hash-cell-customization(kind, resolved-style) = {
  let mark-style = resolve-mark-style(
    resolved-style,
    kind,
    base-fill: resolved-style.box-fill,
  )
  (fill: mark-style.fill, stroke: mark-style.stroke, text: mark-style.text)
}

#let _render-linear-probing-table(slots, style, marks) = {
  let resolved-style = resolve(style)
  let customizations = ()
  for (slot-key, kind) in marks {
    customizations.push((
      int(slot-key),
      _resolve-hash-cell-customization(kind, resolved-style),
    ))
  }
  let indexed-style = style
  if "indices" not in indexed-style {
    indexed-style += array-style(indices: indices-style(enabled: true, labels: auto))
  }
  array-view(..slots.map(_hash-entry-content), style: indexed-style, cell-customizations: customizations).diagram
}

#let _render-bucket-arrow(resolved-style) = scaled(resolved-style, cetz.canvas({
  line(
    (0, 0),
    (0.45, 0),
    mark: (end: ">"),
    stroke: resolved-style.box-stroke,
  )
}))

#let _render-chained-hash-table(buckets, style, marks) = {
  let resolved-style = resolve((box-w: 1.5) + style)
  let grid-cells = ()
  for (bucket-index, bucket) in buckets.enumerate() {
    let bucket-marks = (:)
    for (mark-key, kind) in marks {
      let key-parts = mark-key.split(",")
      if int(key-parts.at(0)) == bucket-index {
        bucket-marks.insert(key-parts.at(1), kind)
      }
    }
    grid-cells.push(array-view(bucket-index, style: style).diagram)
    grid-cells.push(_render-bucket-arrow(resolved-style))
    grid-cells.push(if bucket.len() == 0 {
      text(..resolved-style.pointer-text)[#_null]
    } else {
      _render-linked-list(
        bucket.map(_hash-entry-content),
        resolved-style,
        false,
        none,
        false,
        bucket-marks,
      )
    })
  }
  grid(
    columns: (auto, auto, auto),
    column-gutter: 0.15em,
    row-gutter: 0.35em,
    align: left + horizon,
    ..grid-cells,
  )
}

#let _render-hash-table(model, collision, style, marks: (:)) = if collision == "chaining" {
  _render-chained-hash-table(model, style, marks)
} else {
  _render-linear-probing-table(model, style, marks)
}

#let _create-hash-operation-step(label, before, after, result, style, extra: (:)) = (
  label: label,
  before: before,
  after: after,
  diagram: trans-view(before, label, after, style: style),
  result: result,
) + extra

#let _create-chain-search-marks(bucket, end, found) = {
  let marks = (:)
  let visited-count = if end == none { bucket.len() } else { end + 1 }
  for bucket-position in range(visited-count) {
    let kind = if found and bucket-position == end { "current" } else { "path" }
    marks.insert(str(bucket-position), kind)
  }
  marks
}

#let _prefix-chain-marks-with-bucket(bucket-index, bucket-marks) = {
  let marks = (:)
  for (bucket-position, kind) in bucket-marks {
    marks.insert(str(bucket-index) + "," + bucket-position, kind)
  }
  marks
}

#let _create-hash-table-object(model, collision, hash, style, message-catalog) = {
  let render-model(current-model, marks: (:)) = (
    _render-hash-table(current-model, collision, style, marks: marks)
  )
  (
    diagram: render-model(model),
    collision: collision,
    insert: (key, value: none, step-label: none) => {
      let entry = _normalize-hash-entry("hash-table insert()", key, value: value)
      if collision == "chaining" {
        let insertion = _put-chained-entry(model, entry, hash)
        let after-marks = (
          str(insertion.bucket) + "," + str(insertion.position):
            if insertion.added { "new" } else { "current" }
        )
        let label = if step-label == none {
          msg(message-catalog, "hash.insert", entry.key)
        } else {
          step-label
        }
        _create-hash-operation-step(
          label,
          render-model(model),
          render-model(insertion.model, marks: after-marks),
          _create-hash-table-object(
            insertion.model,
            collision,
            hash,
            style,
            message-catalog,
          ),
          style,
        )
      } else {
        let insertion = _put-linear-probe-entry(model, entry, hash)
        let marks = (:)
        for slot-index in insertion.probes { marks.insert(str(slot-index), "path") }
        marks.insert(str(insertion.index), if insertion.added { "new" } else { "current" })
        let label = if step-label == none {
          msg(message-catalog, "hash.insert", entry.key)
        } else {
          step-label
        }
        _create-hash-operation-step(
          label,
          render-model(model),
          render-model(insertion.model, marks: marks),
          _create-hash-table-object(
            insertion.model,
            collision,
            hash,
            style,
            message-catalog,
          ),
          style,
        )
      }
    },
    delete: (key, step-label: none) => {
      let label = if step-label == none {
        msg(message-catalog, "hash.delete", key)
      } else {
        step-label
      }
      if collision == "chaining" {
        let bucket-index = _calculate-hash-index(key, model.len(), hash)
        let bucket = model.at(bucket-index)
        let entry-position = bucket.position(entry => entry.key == key)
        let model-after-deletion = model
        if entry-position != none {
          model-after-deletion.at(bucket-index) = (
            bucket.slice(0, entry-position) + bucket.slice(entry-position + 1)
          )
        }
        let before-marks = if entry-position == none {
          _prefix-chain-marks-with-bucket(
            bucket-index,
            _create-chain-search-marks(bucket, none, false),
          )
        } else {
          (str(bucket-index) + "," + str(entry-position): "remove")
        }
        _create-hash-operation-step(
          label,
          render-model(model, marks: before-marks),
          render-model(model-after-deletion),
          _create-hash-table-object(
            model-after-deletion,
            collision,
            hash,
            style,
            message-catalog,
          ),
          style,
          extra: (found: entry-position != none,),
        )
      } else {
        let probe-result = _find-linear-probe-slot(model, key, hash)
        let model-after-deletion = model
        if probe-result.found { model-after-deletion.at(probe-result.index) = _tombstone }
        let marks = (:)
        for slot-index in probe-result.probes { marks.insert(str(slot-index), "path") }
        if probe-result.found { marks.insert(str(probe-result.index), "remove") }
        _create-hash-operation-step(
          label,
          render-model(model, marks: marks),
          render-model(model-after-deletion),
          _create-hash-table-object(
            model-after-deletion,
            collision,
            hash,
            style,
            message-catalog,
          ),
          style,
          extra: (
            found: probe-result.found,
            index: if probe-result.found { probe-result.index } else { none },
          ),
        )
      }
    },
    search: (key, step-label: none) => {
      let label = if step-label == none {
        msg(message-catalog, "hash.search", key)
      } else {
        step-label
      }
      if collision == "chaining" {
        let bucket-index = _calculate-hash-index(key, model.len(), hash)
        let bucket = model.at(bucket-index)
        let entry-position = bucket.position(entry => entry.key == key)
        let marks = _prefix-chain-marks-with-bucket(
          bucket-index,
          _create-chain-search-marks(
            bucket,
            entry-position,
            entry-position != none,
          ),
        )
        _create-hash-operation-step(
          label,
          render-model(model),
          render-model(model, marks: marks),
          _create-hash-table-object(
            model,
            collision,
            hash,
            style,
            message-catalog,
          ),
          style,
          extra: (
            found: entry-position != none,
            bucket: bucket-index,
            position: entry-position,
          ),
        )
      } else {
        let probe-result = _find-linear-probe-slot(model, key, hash)
        let marks = (:)
        for slot-index in probe-result.probes {
          marks.insert(str(slot-index), "path")
        }
        if probe-result.found {
          marks.insert(str(probe-result.index), "current")
        }
        _create-hash-operation-step(
          label,
          render-model(model),
          render-model(model, marks: marks),
          _create-hash-table-object(
            model,
            collision,
            hash,
            style,
            message-catalog,
          ),
          style,
          extra: (
            found: probe-result.found,
            index: if probe-result.found { probe-result.index } else { none },
          ),
        )
      }
    },
  )
}

#let hash-table(size: 7, collision: "chaining", hash: auto, style: (:), language: "en", messages: (:), ..entries) = {
  check-integer("hash-table()", "size:", size, min: 1)
  check-enum("hash-table()", "collision:", collision, ("chaining", "chain", "linear"))
  validate-style("hash-table()", style)
  if hash != auto { check-function("hash-table()", "hash:", hash) }
  let collision-strategy = if collision == "chain" { "chaining" } else { collision }
  let model = if collision-strategy == "chaining" {
    _build-chained-hash-table("hash-table()", entries.pos(), size, hash)
  } else {
    _build-linear-probing-table("hash-table()", entries.pos(), size, hash)
  }
  _create-hash-table-object(
    model,
    collision-strategy,
    hash,
    style,
    resolve-catalog(language: language, messages: messages),
  )
}
