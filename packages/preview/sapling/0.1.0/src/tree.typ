// Shared input handling for binary-shaped trees.
//
// Internally every tree is in long form: `none` (empty) or `(key, left, right)`,
// where `left` and `right` are again trees in long form.

// Whether `value` can be used as a key.
#let is-key(value) = type(value) == int or type(value) == str

// Checks that all keys are valid and of one type (all `int` or all `string`).
#let check-keys(keys) = {
  for k in keys {
    assert(is-key(k), message: "sapling: keys must be int or string, got " + repr(k))
  }
  assert(
    keys.map(type).dedup().len() <= 1,
    message: "sapling: keys must be all int or all string, not mixed",
  )
}

// Checks that a flag argument (`show-errors`, `show-bf`, `parens`) is a bool.
#let check-bool(value, name) = assert(
  type(value) == bool,
  message: "sapling: " + name + " must be true or false, got " + repr(value),
)

// Turns an optional list argument (`keys`, `marked`) into an array.
// `name` is the argument's name, used in the error message.
#let as-list(value, name) = {
  if value == none { return () }
  assert(
    type(value) == array,
    message: "sapling: " + name + " must be an array or none, got " + repr(value)
      + " (a single key needs a trailing comma: (3,))",
  )
  value
}

// Converts a tree from user notation to long form.
// Accepts `none`, `()`, a key (leaf) or `(key, left, right)`.
// Only the shape is checked here; each caller checks the keys (`check-keys`),
// since in a treap the key slot holds a `(key, prio)` pair.
#let normalize(tree) = {
  if tree == none or tree == () { return none }
  if type(tree) != array { return (tree, none, none) }
  assert(
    tree.len() == 3,
    message: "sapling: a node is (key, left, right), got " + repr(tree),
  )
  let (key, left, right) = tree
  (key, normalize(left), normalize(right))
}

// The key of a node's value: the value itself, or the first element of a
// treap's `(key, prio)` pair.
#let key-of(value) = {
  if type(value) == array and value.len() == 2 { value.at(0) } else { value }
}

// All keys of a tree in long form, in in-order.
#let keys(tree) = {
  if tree == none { return () }
  let (key, left, right) = tree
  keys(left) + (key,) + keys(right)
}

// Height of a tree in long form (counting edges): −1 for the empty tree, 0 for a leaf.
#let height(tree) = {
  if tree == none { return -1 }
  1 + calc.max(height(tree.at(1)), height(tree.at(2)))
}

// Builds a complete tree from keys in level order:
// index `i` has its children at `2i + 1` and `2i + 2`.
#let from-level-order(keys, i: 0) = {
  if i >= keys.len() { return none }
  (
    keys.at(i),
    from-level-order(keys, i: 2 * i + 1),
    from-level-order(keys, i: 2 * i + 2),
  )
}

// Level-order index of every node, as `(index, key)` pairs: the root has
// index `i`, and the children of index `i` are at `2i + 1` and `2i + 2`.
#let positions(tree, i: 0) = {
  if tree == none { return () }
  let (key, left, right) = tree
  ((i, key),) + positions(left, i: 2 * i + 1) + positions(right, i: 2 * i + 2)
}

// The keys of a complete tree in level order (the inverse of
// `from-level-order`), or `none` if the tree is not complete.
#let to-level-order(tree) = {
  let pairs = positions(tree).sorted(key: p => p.at(0))
  // complete means the indices are exactly 0, 1, ..., n − 1
  if pairs.enumerate().any(((j, (i, _))) => i != j) { return none }
  pairs.map(p => p.at(1))
}

// Heap order, used by heaps (on the keys) and treaps (on the priorities).

#let check-order(order) = assert(
  order in ("min", "max"),
  message: "sapling: order must be \"min\" or \"max\", got " + repr(order),
)

// Whether `a` belongs strictly above `b`: smaller in a min-heap, larger in a max-heap.
#let above(a, b, order) = if order == "min" { a < b } else { a > b }

// Keys of the nodes that break the heap order against their parent.
// `by` maps a node's value to the compared value (a treap compares priorities).
#let order-errors(tree, order, by: value => value, parent: none) = {
  if tree == none { return () }
  let (value, left, right) = tree
  let v = by(value)
  (
    (if parent != none and above(v, parent, order) { (key-of(value),) } else { () })
      + order-errors(left, order, by: by, parent: v)
      + order-errors(right, order, by: by, parent: v)
  )
}
