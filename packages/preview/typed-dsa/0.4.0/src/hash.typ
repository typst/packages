// Hash tables with separate chaining or linear probing.

#import "@preview/cetz:0.5.2"
#import cetz.draw: line
#import "style.typ": resolve, scaled, resolve-mark-style, array-style, indices-style
#import "grid.typ": array-view
#import "linear.typ": _linked-render, _null
#import "tree.typ": trans-view
#import "messages.typ": default-catalog, resolve-catalog, msg

#let _entry(item, value: none) = {
  if value != none { return (key: item, value: value, pair: true) }
  if type(item) == array and item.len() == 2 {
    return (key: item.at(0), value: item.at(1), pair: true)
  }
  (key: item, value: none, pair: false)
}

#let _entry-body(entry) = {
  if entry == none { return [] }
  if entry.at("tombstone", default: false) { return $times$ }
  if entry.pair { [#entry.key: #entry.value] } else { entry.key }
}

#let _default-hash(key, size) = {
  if type(key) == int { return calc.rem(calc.abs(key), size) }
  let h = 0
  for byte in bytes(str(key)) { h = calc.rem(h * 31 + byte, size) }
  h
}

#let _hash-index(key, size, hash) = {
  let raw = if hash == auto { _default-hash(key, size) } else { hash(key) }
  assert(type(raw) == int, message: "hash-table hash functions must return an integer")
  calc.rem(calc.rem(raw, size) + size, size)
}

#let _empty(size) = range(size).map(_ => ())

#let _chain-put(buckets, entry, hash) = {
  let b = _hash-index(entry.key, buckets.len(), hash)
  let bucket = buckets.at(b)
  let p = bucket.position(item => item.key == entry.key)
  if p == none { bucket.push(entry) } else { bucket.at(p) = entry }
  buckets.at(b) = bucket
  (model: buckets, bucket: b, position: if p == none { bucket.len() - 1 } else { p }, added: p == none)
}

#let _chain-build(entries, size, hash) = {
  let buckets = _empty(size)
  for item in entries { buckets = _chain-put(buckets, _entry(item), hash).model }
  buckets
}

#let _tombstone = (tombstone: true)

#let _open-probe(slots, key, hash) = {
  let start = _hash-index(key, slots.len(), hash)
  let probes = ()
  let first-tombstone = none
  for offset in range(slots.len()) {
    let i = calc.rem(start + offset, slots.len())
    probes.push(i)
    let slot = slots.at(i)
    if slot == none {
      return (found: false, index: if first-tombstone == none { i } else { first-tombstone }, probes: probes)
    }
    if slot.at("tombstone", default: false) {
      if first-tombstone == none { first-tombstone = i }
    } else if slot.key == key {
      return (found: true, index: i, probes: probes)
    }
  }
  (found: false, index: first-tombstone, probes: probes)
}

#let _open-put(slots, entry, hash) = {
  let probe = _open-probe(slots, entry.key, hash)
  assert(probe.index != none, message: "hash-table is full")
  slots.at(probe.index) = entry
  (model: slots, index: probe.index, probes: probe.probes, added: not probe.found)
}

#let _open-build(entries, size, hash) = {
  let slots = range(size).map(_ => none)
  for item in entries { slots = _open-put(slots, _entry(item), hash).model }
  slots
}

#let _cell-custom(kind, th) = {
  let mark = resolve-mark-style(th, kind, base-fill: th.box-fill)
  (fill: mark.fill, stroke: mark.stroke, text: mark.text)
}

#let _open-render(slots, style, marks) = {
  let th = resolve(style)
  let customizations = ()
  for (key, kind) in marks { customizations.push((int(key), _cell-custom(kind, th))) }
  let indexed-style = style
  if "indices" not in indexed-style {
    indexed-style += array-style(indices: indices-style(enabled: true, labels: auto))
  }
  array-view(..slots.map(_entry-body), style: indexed-style, cell-customizations: customizations).diagram
}

#let _bucket-arrow(th) = scaled(th, cetz.canvas({
  line((0, 0), (0.45, 0), mark: (end: ">"), stroke: th.box-stroke)
}))

#let _chain-render(buckets, style, marks) = {
  let th = resolve((box-w: 1.5) + style)
  let cells = ()
  for (b, bucket) in buckets.enumerate() {
    let local = (:)
    for (key, kind) in marks {
      let parts = key.split(",")
      if int(parts.at(0)) == b { local.insert(parts.at(1), kind) }
    }
    cells.push(array-view(b, style: style).diagram)
    cells.push(_bucket-arrow(th))
    cells.push(if bucket.len() == 0 {
      text(..th.pointer-text)[#_null]
    } else {
      _linked-render(bucket.map(_entry-body), th, false, none, false, local)
    })
  }
  grid(columns: (auto, auto, auto), column-gutter: 0.15em, row-gutter: 0.35em, align: left + horizon, ..cells)
}

#let _render(model, collision, style, marks: (:)) = if collision == "chaining" {
  _chain-render(model, style, marks)
} else {
  _open-render(model, style, marks)
}

#let _step(label, before, after, result, style, extra: (:)) = (
  label: label,
  before: before,
  after: after,
  diagram: trans-view(before, label, after, style: style),
  result: result,
) + extra

#let _chain-path(bucket, end, found) = {
  let marks = (:)
  let count = if end == none { bucket.len() } else { end + 1 }
  for p in range(count) { marks.insert(str(p), if found and p == end { "current" } else { "path" }) }
  marks
}

#let _prefix-bucket-marks(bucket-index, local) = {
  let marks = (:)
  for (p, kind) in local { marks.insert(str(bucket-index) + "," + p, kind) }
  marks
}

#let _hash-obj(model, collision, hash, style, cat) = {
  let draw(m, marks: (:)) = _render(m, collision, style, marks: marks)
  (
    diagram: draw(model),
    collision: collision,
    insert: (key, value: none, step-label: none) => {
      let entry = _entry(key, value: value)
      if collision == "chaining" {
        let placed = _chain-put(model, entry, hash)
        let mark = (str(placed.bucket) + "," + str(placed.position): if placed.added { "new" } else { "current" })
        let label = if step-label == none { msg(cat, "hash.insert", entry.key) } else { step-label }
        _step(label, draw(model), draw(placed.model, marks: mark), _hash-obj(placed.model, collision, hash, style, cat), style)
      } else {
        let placed = _open-put(model, entry, hash)
        let marks = (:)
        for i in placed.probes { marks.insert(str(i), "path") }
        marks.insert(str(placed.index), if placed.added { "new" } else { "current" })
        let label = if step-label == none { msg(cat, "hash.insert", entry.key) } else { step-label }
        _step(label, draw(model), draw(placed.model, marks: marks), _hash-obj(placed.model, collision, hash, style, cat), style)
      }
    },
    delete: (key, step-label: none) => {
      let label = if step-label == none { msg(cat, "hash.delete", key) } else { step-label }
      if collision == "chaining" {
        let b = _hash-index(key, model.len(), hash)
        let bucket = model.at(b)
        let p = bucket.position(item => item.key == key)
        let after = model
        if p != none { after.at(b) = bucket.slice(0, p) + bucket.slice(p + 1) }
        let before-marks = if p == none { _prefix-bucket-marks(b, _chain-path(bucket, none, false)) } else { (str(b) + "," + str(p): "remove") }
        _step(label, draw(model, marks: before-marks), draw(after), _hash-obj(after, collision, hash, style, cat), style, extra: (found: p != none,))
      } else {
        let probe = _open-probe(model, key, hash)
        let after = model
        if probe.found { after.at(probe.index) = _tombstone }
        let marks = (:)
        for i in probe.probes { marks.insert(str(i), "path") }
        if probe.found { marks.insert(str(probe.index), "remove") }
        _step(label, draw(model, marks: marks), draw(after), _hash-obj(after, collision, hash, style, cat), style, extra: (found: probe.found, index: if probe.found { probe.index } else { none }))
      }
    },
    search: (key, step-label: none) => {
      let label = if step-label == none { msg(cat, "hash.search", key) } else { step-label }
      if collision == "chaining" {
        let b = _hash-index(key, model.len(), hash)
        let bucket = model.at(b)
        let p = bucket.position(item => item.key == key)
        let marks = _prefix-bucket-marks(b, _chain-path(bucket, p, p != none))
        _step(label, draw(model), draw(model, marks: marks), _hash-obj(model, collision, hash, style, cat), style,
          extra: (found: p != none, bucket: b, position: p))
      } else {
        let probe = _open-probe(model, key, hash)
        let marks = (:)
        for i in probe.probes { marks.insert(str(i), "path") }
        if probe.found { marks.insert(str(probe.index), "current") }
        _step(label, draw(model), draw(model, marks: marks), _hash-obj(model, collision, hash, style, cat), style,
          extra: (found: probe.found, index: if probe.found { probe.index } else { none }))
      }
    },
  )
}

#let hash-table(size: 7, collision: "chaining", hash: auto, style: (:), language: "en", messages: (:), ..entries) = {
  assert(type(size) == int and size > 0, message: "hash-table size must be a positive integer")
  let mode = if collision == "chain" { "chaining" } else { collision }
  assert(mode in ("chaining", "linear"), message: "hash-table collision must be \"chaining\" or \"linear\"")
  let model = if mode == "chaining" { _chain-build(entries.pos(), size, hash) } else { _open-build(entries.pos(), size, hash) }
  _hash-obj(model, mode, hash, style, resolve-catalog(language: language, messages: messages))
}
