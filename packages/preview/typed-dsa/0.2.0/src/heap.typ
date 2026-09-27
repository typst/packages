// Binary heaps (min and max), array-backed complete binary trees.
//
// A heap is stored as a plain array; index `i`'s children live at `2i+1` and
// `2i+2`. Drawing reuses `tree.typ`'s node shape and `_place`/`_render`
// pipeline, which lays out any binary tree by structure alone — converting
// the array to that shape is all a heap needs to be drawable for free.

#import "style.typ": resolve
#import "tree.typ": _node, _render, _marks, trans-view

#let _array-to-tree(arr, i) = {
  if i >= arr.len() { return none }
  let n = _node(i)
  n.label = arr.at(i)
  n.left = _array-to-tree(arr, 2 * i + 1)
  n.right = _array-to-tree(arr, 2 * i + 2)
  n
}

#let _better(variant) = if variant == "max" { (a, b) => a > b } else { (a, b) => a < b }

// Sifts the last element up until the heap property holds. Returns the
// indices visited, root first, so the caller can mark the swap path.
#let _sift-up(arr, variant) = {
  let better = _better(variant)
  let i = arr.len() - 1
  let path = (i,)
  while i > 0 {
    let p = calc.floor((i - 1) / 2)
    if not better(arr.at(i), arr.at(p)) { break }
    let tmp = arr.at(p)
    arr.at(p) = arr.at(i)
    arr.at(i) = tmp
    i = p
    path.push(i)
  }
  (arr, path)
}

// Sifts the root down until the heap property holds. Returns the indices
// visited, root first.
#let _sift-down(arr, variant) = {
  let better = _better(variant)
  let n = arr.len()
  let i = 0
  let path = (0,)
  while true {
    let l = 2 * i + 1
    let r = 2 * i + 2
    let m = i
    if l < n and better(arr.at(l), arr.at(m)) { m = l }
    if r < n and better(arr.at(r), arr.at(m)) { m = r }
    if m == i { break }
    let tmp = arr.at(i)
    arr.at(i) = arr.at(m)
    arr.at(m) = tmp
    i = m
    path.push(i)
  }
  (arr, path)
}

#let _build(variant, keys) = {
  let arr = ()
  for k in keys {
    arr.push(k)
    let (a, _) = _sift-up(arr, variant)
    arr = a
  }
  arr
}

// ── Operations ───────────────────────────────────────────────────────────────
//
// A binary heap only supports inserting and extracting the root efficiently,
// so — unlike `bst`/`avl` — there is no key-based `delete` or `search`.
// Named `heap-insert`/`heap-extract` (rather than `insert`/`delete`) to avoid
// colliding with the tree operations when both are imported.

// `_marks` keys by node value, not position, so a swap path (a list of array
// indices) has to be read back through the post-sift array to the keys now
// sitting at those positions before it can be turned into a mark map. `kind`
// is a highlight kind string, resolved against the caller's `style:` at draw
// time (see `tree.typ`'s `mark-style`).
#let _index-marks(path, kind) = _marks(path, kind)

#let heap-insert(key, step-label: none) = (variant, arr) => {
  let a = arr + (key,)
  let (after, path) = _sift-up(a, variant)
  let inserted = path.last()
  let ma = _index-marks(path, "path") + _index-marks((inserted,), "new")
  (after, (:), ma, if step-label == none { "insert " + str(key) } else { step-label })
}

// Removes and returns the root: the smallest key for a min-heap, largest for
// a max-heap.
#let _heap-extract-op(step-label: none) = (variant, arr) => {
  let label = if step-label == none { "extract" } else { step-label }
  let mb = _index-marks((0,), "remove")
  if arr.len() <= 1 { return ((), mb, (:), label) }
  let a = arr
  a.at(0) = a.at(a.len() - 1)
  a = a.slice(0, a.len() - 1)
  let (after, path) = _sift-down(a, variant)
  (after, mb, _index-marks(path, "path"), label)
}

#let heap-extract = _heap-extract-op()

// ── Public object ────────────────────────────────────────────────────────────

#let _heap-obj(variant, arr, style: (:)) = {
  let draw(a, marks) = _render(_array-to-tree(a, 0), marks: marks, th: resolve(style))
  let apply(op) = {
    let (after, mb, ma, label) = op(variant, arr)
    (
      label: label,
      before: draw(arr, mb),
      after: draw(after, ma),
      diagram: trans-view(draw(arr, mb), label, draw(after, ma)),
      result: _heap-obj(variant, after, style: style),
    )
  }
  (
    diagram: draw(arr, (:)),
    insert: (key, step-label: none) => apply(heap-insert(key, step-label: step-label)),
    extract: (step-label: none) => apply(_heap-extract-op(step-label: step-label)),
  )
}

#let min-heap(style: (:), ..keys) = _heap-obj("min", _build("min", keys.pos()), style: style)
#let max-heap(style: (:), ..keys) = _heap-obj("max", _build("max", keys.pos()), style: style)

// ── Transition ───────────────────────────────────────────────────────────────

#let _transition(variant, keys, op, style: (:)) = {
  let th = resolve(style)
  let before = _build(variant, keys)
  let (after, mb, ma, label) = op(variant, before)
  trans-view(
    _render(_array-to-tree(before, 0), marks: mb, th: th),
    label,
    _render(_array-to-tree(after, 0), marks: ma, th: th),
  )
}
