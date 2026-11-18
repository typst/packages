// Treaps: binary search trees by key whose priorities follow heap order.
// In long form a node's key slot holds the pair: `((key, prio), left, right)`.

#import "tree.typ": above, as-list, check-bool, check-keys, check-order, keys, normalize, order-errors
#import "binary.typ": bst-errors
#import "rotate.typ"
#import "colors.typ": palette
#import "draw.typ": draw

// Checks the `(key, prio)` pairs and `marked`: keys as usual, priorities all
// numbers or all single characters.
#let check-pairs(pairs, marked: ()) = {
  for pair in pairs {
    assert(
      type(pair) == array and pair.len() == 2,
      message: "sapling: a treap node is (key, prio), got " + repr(pair),
    )
  }
  check-keys(pairs.map(p => p.at(0)) + marked)
  let prios = pairs.map(p => p.at(1))
  for prio in prios {
    assert(
      type(prio) in (int, float) or (type(prio) == str and prio.clusters().len() == 1),
      message: "sapling: a priority must be a number or a single character, got " + repr(prio),
    )
  }
  assert(
    prios.map(p => type(p) == str).dedup().len() <= 1,
    message: "sapling: priorities must be all numbers or all characters, not mixed",
  )
}

// Inserts the `(key, prio)` pair into a treap in long form: as in a BST, then
// rotated up while its priority belongs above its parent's.
// A key that is already there is left out.
#let treap-insert(tree, pair, order) = {
  if tree == none { return (pair, none, none) }
  let (node, left, right) = tree
  if pair.at(0) < node.at(0) {
    let left = treap-insert(left, pair, order)
    let tree = (node, left, right)
    if above(left.at(0).at(1), node.at(1), order) { rotate.right(tree) } else { tree }
  } else if pair.at(0) > node.at(0) {
    let right = treap-insert(right, pair, order)
    let tree = (node, left, right)
    if above(right.at(0).at(1), node.at(1), order) { rotate.left(tree) } else { tree }
  } else {
    tree
  }
}

// Draws a treap exactly as given, nodes as "key,prio". If `show-errors` is
// `true`, nodes that break the BST order of the keys or the heap order of the
// priorities are marked.
#let treap(tree, order: "min", marked: none, show-errors: true, parens: false) = {
  check-order(order)
  check-bool(show-errors, "show-errors")
  check-bool(parens, "parens")
  let tree = normalize(tree)
  let marked = as-list(marked, "marked")
  check-pairs(keys(tree), marked: marked)
  let errors = if show-errors {
    bst-errors(tree) + order-errors(tree, order, by: pair => pair.at(1))
  } else { () }
  let label(((key, prio))) = {
    let pair = [#key,#text(fill: palette().priority)[#prio]]
    if parens [(#pair)] else { pair }
  }
  draw(tree, marked: marked, errors: errors, label: label)
}

// Draws the treap built by inserting the `(key, prio)` pairs one after another.
// Duplicate keys after the first occurrence are left out.
#let treap-from(keys, order: "min", marked: none, parens: false) = {
  check-order(order)
  let keys = as-list(keys, "keys")
  check-pairs(keys)
  let tree = keys.fold(none, (tree, pair) => treap-insert(tree, pair, order))
  treap(tree, order: order, marked: marked, parens: parens)
}
