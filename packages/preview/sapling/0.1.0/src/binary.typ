// Binary trees and binary search trees.

#import "tree.typ": as-list, check-bool, check-keys, from-level-order, key-of, keys, normalize
#import "draw.typ": draw

// Draws a binary tree exactly as given.
#let binary-tree(tree, marked: none) = {
  let tree = normalize(tree)
  let marked = as-list(marked, "marked")
  check-keys(keys(tree) + marked)
  draw(tree, marked: marked)
}

// Draws a binary tree filled with the keys in level order
// (top to bottom, left to right), so it is always a complete tree.
// Duplicates after the first occurrence are left out.
#let binary-tree-from(keys, marked: none) = {
  let keys = as-list(keys, "keys").dedup()
  binary-tree(from-level-order(keys), marked: marked)
}

// Inserts `key` into a BST in long form. A key that is already there is left out.
#let bst-insert(tree, key) = {
  if tree == none { return (key, none, none) }
  let (k, left, right) = tree
  if key < k {
    (k, bst-insert(left, key), right)
  } else if key > k {
    (k, left, bst-insert(right, key))
  } else {
    tree
  }
}

// Keys of the nodes that break the BST rule: every key must be greater than
// all keys in its left subtree and smaller than all keys in its right subtree.
// `low` and `high` are the bounds set by the ancestors (`none` = no bound).
// Also works on treaps, using the key of each `(key, prio)` pair.
#let bst-errors(tree, low: none, high: none) = {
  if tree == none { return () }
  let (value, left, right) = tree
  let key = key-of(value)
  let wrong = (low != none and key <= low) or (high != none and key >= high)
  // a wrong node does not tighten the bounds, so its subtrees are checked
  // against the valid ancestors only
  let (l, h) = if wrong { (low, high) } else { (key, key) }
  (
    (if wrong { (key,) } else { () })
      + bst-errors(left, low: low, high: h)
      + bst-errors(right, low: l, high: high)
  )
}

// Draws a binary search tree exactly as given. If `show-errors` is `true`,
// nodes that break the BST rule are marked.
#let bst(tree, marked: none, show-errors: true) = {
  check-bool(show-errors, "show-errors")
  let tree = normalize(tree)
  let marked = as-list(marked, "marked")
  check-keys(keys(tree) + marked)
  draw(tree, marked: marked, errors: if show-errors { bst-errors(tree) } else { () })
}

// Draws the binary search tree built by inserting the keys one after another.
// Duplicates after the first occurrence are left out.
#let bst-from(keys, marked: none) = {
  let keys = as-list(keys, "keys")
  check-keys(keys)
  bst(keys.fold(none, bst-insert), marked: marked)
}
