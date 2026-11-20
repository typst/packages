// The four rotations. The node-level versions (`left`, `right`, ...) take a
// subtree in long form whose root is `x` and are reused by AVL and treap
// insertion; the public versions find `x` by its key first.

#import "tree.typ": check-keys, key-of, keys, normalize

// x with right child y  →  y with left child x
#let left(x) = {
  let (xk, a, y) = x
  if y == none { return x }
  let (yk, b, c) = y
  (yk, (xk, a, b), c)
}

// x with left child y  →  y with right child x
#let right(x) = {
  let (xk, y, c) = x
  if y == none { return x }
  let (yk, a, b) = y
  (yk, a, (xk, b, c))
}

// rotate left at the left child, then right at x
#let left-right(x) = {
  let (xk, y, d) = x
  if y == none or y.at(2) == none { return x }
  right((xk, left(y), d))
}

// rotate right at the right child, then left at x
#let right-left(x) = {
  let (xk, a, y) = x
  if y == none or y.at(1) == none { return x }
  left((xk, a, right(y)))
}

// Applies `rotation` to the node with key `key`. Searches the whole tree,
// since a plain binary tree has no order to follow. Treap nodes are found by
// their key; the priority moves with the node.
#let at(tree, key, rotation) = {
  if tree == none { return none }
  let (k, l, r) = tree
  if key-of(k) == key { return rotation(tree) }
  (k, at(l, key, rotation), at(r, key, rotation))
}

// Normalizes the input, checks the keys and rotates at `key`.
#let rotate(tree, key, rotation) = {
  let tree = normalize(tree)
  check-keys(keys(tree).map(key-of) + (key,))
  at(tree, key, rotation)
}

#let rotate-left(tree, key) = rotate(tree, key, left)
#let rotate-right(tree, key) = rotate(tree, key, right)
#let rotate-left-right(tree, key) = rotate(tree, key, left-right)
#let rotate-right-left(tree, key) = rotate(tree, key, right-left)
