// Heaps: complete binary trees in heap order. The algorithms work on the
// level-order array, where index `i` has its parent at `(i − 1) / 2`.

#import "tree.typ": (
  above, as-list, check-bool, check-keys, check-order, from-level-order, keys, normalize, order-errors,
  to-level-order,
)
#import "colors.typ": palette
#import "draw.typ": draw

// Swaps the keys at index `i` and its parent while `i` belongs above its parent.
#let sift-up(a, i, order) = {
  let (a, i) = (a, i)
  while i > 0 {
    let p = calc.quo(i - 1, 2)
    if not above(a.at(i), a.at(p), order) { break }
    (a.at(i), a.at(p)) = (a.at(p), a.at(i))
    i = p
  }
  a
}

// Swaps the key at index `i` with its smaller (min) or larger (max) child
// while that child belongs above it.
#let sift-down(a, i, order) = {
  let (a, i) = (a, i)
  while 2 * i + 1 < a.len() {
    let c = 2 * i + 1
    if c + 1 < a.len() and above(a.at(c + 1), a.at(c), order) { c += 1 }
    if not above(a.at(c), a.at(i), order) { break }
    (a.at(i), a.at(c)) = (a.at(c), a.at(i))
    i = c
  }
  a
}

// Normalizes the input, checks the arguments and applies `sift` at `key`.
// A tree that is not complete, or does not contain `key`, is returned unchanged.
#let sift-at(tree, key, order, sift) = {
  check-order(order)
  let tree = normalize(tree)
  check-keys(keys(tree) + (key,))
  let a = to-level-order(tree)
  if a == none or key not in a { return tree }
  from-level-order(sift(a, a.position(k => k == key), order))
}

#let up-heap(tree, key, order: "min") = sift-at(tree, key, order, sift-up)
#let down-heap(tree, key, order: "min") = sift-at(tree, key, order, sift-down)

// Draws a heap exactly as given. If `show-errors` is `true`, nodes that break
// the heap order against their parent are marked. If `indices` is 0 or 1, every
// node shows its array index, starting at that number.
#let heap(tree, order: "min", marked: none, show-errors: true, indices: none) = {
  check-order(order)
  check-bool(show-errors, "show-errors")
  assert(
    indices == none or (type(indices) == int and indices in (0, 1)),
    message: "sapling: indices must be none, 0 or 1, got " + repr(indices),
  )
  let tree = normalize(tree)
  let marked = as-list(marked, "marked")
  check-keys(keys(tree) + marked)
  draw(
    tree,
    marked: marked,
    errors: if show-errors { order-errors(tree, order) } else { () },
    note: if indices != none { n => text(fill: palette().index)[#(n.index + indices)] },
  )
}

// Draws the heap built by adding the keys one after another: each key goes to
// the next free place in level order and then moves up with `up-heap`.
// Duplicates after the first occurrence are left out.
#let heap-from(keys, order: "min", marked: none, indices: none) = {
  check-order(order)
  let keys = as-list(keys, "keys").dedup()
  check-keys(keys)
  let add(tree, key) = up-heap(from-level-order(to-level-order(tree) + (key,)), key, order: order)
  heap(keys.fold(none, add), order: order, marked: marked, indices: indices)
}
