// AVL trees: binary search trees annotated with balance factors.

#import "tree.typ": as-list, check-bool, check-keys, height, keys, normalize
#import "rotate.typ"
#import "draw.typ": draw

// Balance factor: height of the right subtree minus height of the left one.
#let balance(node) = height(node.at(2)) - height(node.at(1))

// Balance factor as text: 0, +, ++, −, −− (one sign per level of difference).
#let symbol(bf) = {
  if bf == 0 { "0" } else if bf > 0 { "+" * bf } else { "−" * -bf }
}

// Keys of the nodes whose balance factor is −− or ++ (or worse).
#let unbalanced(tree) = {
  if tree == none { return () }
  let (key, left, right) = tree
  (
    (if calc.abs(balance(tree)) >= 2 { (key,) } else { () })
      + unbalanced(left)
      + unbalanced(right)
  )
}

// Restores the balance of a node whose subtrees are AVL trees
// and differ in height by at most 2.
#let rebalance(node) = {
  let bf = balance(node)
  if bf >= 2 {
    if balance(node.at(2)) < 0 { rotate.right-left(node) } else { rotate.left(node) }
  } else if bf <= -2 {
    if balance(node.at(1)) > 0 { rotate.left-right(node) } else { rotate.right(node) }
  } else {
    node
  }
}

// Inserts `key` into an AVL tree in long form. A key that is already there is left out.
#let avl-insert(tree, key) = {
  if tree == none { return (key, none, none) }
  let (k, left, right) = tree
  if key < k {
    rebalance((k, avl-insert(left, key), right))
  } else if key > k {
    rebalance((k, left, avl-insert(right, key)))
  } else {
    tree
  }
}

// Draws an AVL tree exactly as given. If `show-bf` is `true`, every node shows
// its balance factor and nodes with −− or ++ are marked.
#let avl-tree(tree, marked: none, show-bf: true) = {
  check-bool(show-bf, "show-bf")
  let tree = normalize(tree)
  let marked = as-list(marked, "marked")
  check-keys(keys(tree) + marked)
  if show-bf {
    draw(tree, marked: marked, errors: unbalanced(tree), note: n => symbol(balance(n.tree)))
  } else {
    draw(tree, marked: marked)
  }
}

// Draws the AVL tree built by inserting the keys one after another.
// Duplicates after the first occurrence are left out.
#let avl-tree-from(keys, marked: none, show-bf: true) = {
  let keys = as-list(keys, "keys")
  check-keys(keys)
  avl-tree(keys.fold(none, avl-insert), marked: marked, show-bf: show-bf)
}
