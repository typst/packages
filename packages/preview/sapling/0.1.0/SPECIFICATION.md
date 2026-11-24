# General Rules
- Required arguments are positional, optional arguments are always named: `bst-from((1, 2, 3), marked: (3,))`.
- Keys within one tree are either all `int` or all `string`. Mixing them is an error.
- Invalid arguments (wrong type, unknown values such as `order: "foo"`, mixed key types) raise an error.
- Strings are compared alphabetically.
- Functions ending in `-from` (e.g. `bst-from`) insert the given keys one after another into an empty tree, so the tree is always valid, and draw it.
- Functions without `-from` (e.g. `bst`) draw the tree exactly as given. Invalid nodes are marked if `show-errors` is `true`.
- All drawing functions return content. The algorithms (rotations, `up-heap`, `down-heap`) take and return tree values, not content.
- Limit for now: trees are processed recursively, and Typst limits how deeply function calls can nest (about 80 levels). A tree deeper than that fails with "maximum function call depth exceeded". This only affects degenerate trees, e.g. `bst-from` with 100 keys in sorted order; balanced trees (AVL, heaps, B-trees) are far below the limit.
- Keys are unique. Where a list of keys is inserted, the first occurrence is inserted and later duplicates are left out. Functions that draw a given tree (e.g. `bst`) draw it exactly as given, so duplicate keys in it are drawn too.

# Colors
## set-colors
Draws `body` with changed colors. The change is scoped: it only applies to the trees inside `body`, and nested calls build on each other. Colors not named keep the value of the surrounding scope (the defaults at the top). Only colors can be changed, nothing else about the drawing. Use it as a show rule to change the colors for the rest of the current scope (e.g. the whole document), or with a content block for a part of it.
```typ
#let set-colors(body, ..colors)
```
- `body` (content, required): the content to draw with the changed colors; a show rule passes the rest of its scope here
- `border` (color, optional): outline of nodes and cells, and the edges
- `fill` (color, optional): fill of normal nodes and cells
- `marked` (color, optional): outline of nodes in `marked`, and the notes next to nodes (balance factors, array indices)
- `marked-fill` (color, optional): fill of nodes in `marked`
- `error` (color, optional): outline of nodes that break the rules of their tree (`show-errors`, `show-bf`)
- `error-fill` (color, optional): fill of those nodes
- `priority` (color, optional): the priority in treap nodes
- `index` (color, optional): the array indices of heap nodes (`indices`)

**Edge-Cases:**
- an unknown name, a second positional argument or a value that is not a color: error
- no colors given: `body` is drawn unchanged
- no `body` (called without a content block or show rule): error
- when a node is both marked and an error, the error color wins

**Example:** `set-colors(marked: green, error: orange)[#bst((5, 8, 3), marked: (3,))]`, or `#show: set-colors.with(marked: green)`

# Binary Trees
## binary-tree-from
Generates a binary tree, as if the nodes were added to the tree in the given order.
```typ
#let binary-tree-from(keys, marked: none)
```
- `keys` (none|int[]|string[], required): list of all keys that end up in the tree
- `marked` (none|int[]|string[], optional): list of all keys whose nodes will be marked

**Edge-Cases:**
- `keys` is `none` or `()`: draw only ∅
- duplicate keys: ignore after first insertion
- key in `marked` is not in `keys`: ignore marked key

**Example:** `binary-tree-from((1, 2, 3, 4), marked: (3, 4))`

## binary-tree
Generates a binary tree from the tree given.
```typ
#let binary-tree(tree, marked: none)
```
- `tree` (tree, required): `none`, a key (leaf), or `(key, left, right)`, where `left` and `right` are trees
- `marked` (none|int[]|string[], optional): list of all keys whose nodes will be marked

**Edge-Cases:**
- `tree` is `none` or `()`: draw only ∅
- key in `marked` is not in `tree`: ignore marked key

**Example:** `binary-tree((1, 2, (3, (4, 5, 6), 7)))`


# Binary Search Trees
## bst-from
Generates a binary search tree, as if the nodes were added to the tree in the given order.
```typ
#let bst-from(keys, marked: none)
```
- `keys` (none|int[]|string[], required): list of all keys that end up in the tree
- `marked` (none|int[]|string[], optional): list of all keys whose nodes will be marked

**Edge-Cases:**
- `keys` is `none` or `()`: draw only ∅
- duplicate keys: ignore after first insertion
- key in `marked` is not in `keys`: ignore marked key

**Example:** `bst-from((1, 2, 3, 4), marked: (3, 4))`

## bst
Generates a binary tree from the tree given. Does not have to be a valid binary search tree, will mark all nodes that do not conform if `show-errors` is true.
```typ
#let bst(tree, marked: none, show-errors: true)
```
- `tree` (tree, required): `none`, a key (leaf), or `(key, left, right)`, where `left` and `right` are trees
- `marked` (none|int[]|string[], optional): list of all keys whose nodes will be marked (different color from `show-errors` markings)
- `show-errors` (bool, optional): if `true` mark all nodes that do not conform to bst, if `false` ignore wrong nodes

**Edge-Cases:**
- `tree` is `none` or `()`: draw only ∅
- key in `marked` is not in `tree`: ignore marked key

**Example:** `bst((1, 2, (3, (4, 5, 6), 7)))`

# AVL Trees
## avl-tree-from
Generates an AVL-Tree, as if the nodes were added to the tree in the given order. If `show-bf` is true, show balance factors of all nodes with `−−`, `−`, `0`, `+`, `++`. `−` means left-heavy, `+` means right-heavy.
```typ
#let avl-tree-from(keys, marked: none, show-bf: true)
```
- `keys` (none|int[]|string[], required): list of all keys that end up in the tree
- `marked` (none|int[]|string[], optional): list of all keys whose nodes will be marked
- `show-bf` (bool, optional): if `true` annotate all nodes with their balance factors using `−−`, `−`, `0`, `+`, `++` and mark nodes with `−−` or `++`, `false` ignore

**Edge-Cases:**
- `keys` is `none` or `()`: draw only ∅
- duplicate keys: ignore after first insertion
- key in `marked` is not in `keys`: ignore marked key

**Example:** `avl-tree-from((1, 2, 3, 4), marked: (3, 4))`

## avl-tree
Generates an AVL-Tree from the tree given. If `show-bf` is true, show balance factors of all nodes with `−−`, `−`, `0`, `+`, `++`. `−` means left-heavy, `+` means right-heavy.
```typ
#let avl-tree(tree, marked: none, show-bf: true)
```
- `tree` (tree, required): `none`, a key (leaf), or `(key, left, right)`, where `left` and `right` are trees
- `marked` (none|int[]|string[], optional): list of all keys whose nodes will be marked (different color from `show-bf` markings)
- `show-bf` (bool, optional): if `true` annotate all nodes with their balance factors using `−−`, `−`, `0`, `+`, `++` and mark nodes with `−−` or `++`, `false` ignore

**Edge-Cases:**
- `tree` is `none` or `()`: draw only ∅
- key in `marked` is not in `tree`: ignore marked key

**Example:** `avl-tree((1, 2, (3, (4, 5, 6), 7)))`

# Heaps
## heap-from
Generates a heap, as if the nodes were added to the tree in the given order.
```typ
#let heap-from(keys, order: "min", marked: none, indices: none)
```
- `keys` (none|int[]|string[], required): list of all keys that end up in the tree
- `order` ("min"|"max", optional): build a min-heap (parent ≤ child) or a max-heap (parent ≥ child)
- `marked` (none|int[]|string[], optional): list of all keys whose nodes will be marked
- `indices` (0|1|none, optional): `none` shows no array indices, `0` shows the array index at each node starting at 0, `1` starting at 1

**Edge-Cases:**
- `keys` is `none` or `()`: draw only ∅
- duplicate keys: ignore after first insertion
- key in `marked` is not in `keys`: ignore marked key

**Example:** `heap-from((1, 2, 3, 4), marked: (3, 4))`

## heap
Generates a heap from the tree given. Does not have to be a valid heap, will mark all nodes that do not conform if `show-errors` is true. If `indices` is `0` or `1`, show the array index of each node, starting at that number.
```typ
#let heap(tree, order: "min", marked: none, show-errors: true, indices: none)
```
- `tree` (tree, required): `none`, a key (leaf), or `(key, left, right)`, where `left` and `right` are trees
- `order` ("min"|"max", optional): states whether the tree is meant to be a min-heap (parent ≤ child) or a max-heap (parent ≥ child); used for `show-errors`, pass the same value to the heap algorithms
- `marked` (none|int[]|string[], optional): list of all keys whose nodes will be marked (different color from `show-errors` markings)
- `show-errors` (bool, optional): if `true` mark all nodes that violate the heap order given by `order`
- `indices` (0|1|none, optional): `none` shows no array indices, `0` shows the array index at each node starting at 0, `1` starting at 1

**Edge-Cases:**
- `tree` is `none` or `()`: draw only ∅
- key in `marked` is not in `tree`: ignore marked key

**Example:** `heap((1, 2, (3, (4, 5, 6), 7)))`

# Treaps
## treap-from
Generates a treap, as if the nodes were added to the tree in the given order.
```typ
#let treap-from(keys, order: "min", marked: none, parens: false)
```
- `keys` (none|(int|string, int|float|string)[], required): list of all `(key,prio)` pairs that end up in the tree. `prio` is a number or a single character (string of length 1); characters are compared alphabetically
- `order` ("min"|"max", optional): the priority order, `"min"` puts the smallest priority at the root (parent ≤ child), `"max"` the largest (parent ≥ child)
- `marked` (none|int[]|string[], optional): list of all keys whose nodes will be marked
- `parens` (bool, optional): if `true` show nodes as `(1,2)`, if `false` show `1,2` for the nodes

**Edge-Cases:**
- `keys` is `none` or `()`: draw only ∅
- duplicate keys: ignore after first insertion
- key in `marked` is not in `keys`: ignore marked key
- `prio` is a string with more than one character, or numbers and characters are mixed: error

**Example:** `treap-from(((5, 3), (2, 8), (7, 1)), marked: (7,))`

## treap
Generates a treap from the tree given. Does not have to be a valid treap, will mark all nodes that do not conform if `show-errors` is true.
```typ
#let treap(tree, order: "min", marked: none, show-errors: true, parens: false)
```
- `tree` (tree, required): `none` or `((key, prio), left, right)`, where `left` and `right` are trees. `prio` is a number or a single character, as in `treap-from`
- `order` ("min"|"max", optional): the priority order the tree is meant to follow, `"min"` (parent ≤ child) or `"max"` (parent ≥ child); used for `show-errors`
- `marked` (none|int[]|string[], optional): list of all keys whose nodes will be marked (different color from `show-errors` markings)
- `show-errors` (bool, optional): if `true` mark all nodes that do not conform to treap conditions
- `parens` (bool, optional): if `true` show nodes as `(1,2)`, if `false` show `1,2` for the nodes

**Edge-Cases:**
- `tree` is `none` or `()`: draw only ∅
- key in `marked` is not in `tree`: ignore marked key

**Example:** `treap(((1,2), none, ((3,4), none, none)))`

# B Tree
## b-tree-from
Generates a B-Tree, as if the nodes were added to the tree in the given order. Pages are drawn at full size, as in `b-tree`.
```typ
#let b-tree-from(keys, order, marked: none)
```
- `keys` (none|int[]|string[], required): list of all keys that end up in the tree
- `order` (int, required): sets the order of the tree (according to Knuth)
- `marked` (none|int[]|string[], optional): list of all keys whose nodes will be marked

**Edge-Cases:**
- `keys` is `none` or `()`: draw only ∅
- key in `marked` is not in `keys`: ignore marked key

**Example:** `b-tree-from((1, 2, 3, 4), 3)`

## b-tree
Generates a B-Tree with the structure given in `tree`, does not have to be a valid B-Tree. If `show-errors` is `true` mark incorrect nodes. Every page is drawn at full size with `order − 1` cells; unused cells stay empty.
```typ
#let b-tree(tree, order, marked: none, show-errors: true)
```
- `tree` (tree, required): `none`, a leaf `(keys)`, or `((keys), child1, child2, ...)`, where `keys` is the list of keys in the page and each child is a tree. A page with k keys has k+1 children. A page is an inner page if its first element is an array
- `order` (int, required): sets the order of the tree (according to Knuth), used to check the nodes if `show-errors` is `true`
- `marked` (none|int[]|string[], optional): list of all keys whose nodes will be marked (different color from `show-errors` markings)
- `show-errors` (bool, optional): if `true` mark all nodes that do not conform to b-tree conditions

**Edge-Cases:**
- `tree` is `none` or `()`: draw only ∅
- key in `marked` is not in `tree`: ignore marked key
- inner page does not have exactly k+1 children for k keys: draw as given, mark the page if `show-errors` is `true`
- page with more than `order − 1` keys: draw all its keys (wider than a full page), mark the page if `show-errors` is `true`
- page without keys: draw `order − 1` empty cells

**Example:** `b-tree(((20, 40), (5, 10), (25, 30), (45, 50)), 4, marked: (30,), show-errors: false)`

# Walkthrough
## walkthrough
Arranges several trees (or any other content) next to each other to show how a tree evolves. Plain trees can be passed directly, no `step` is needed. Wrap an item in `step` only if it should get a caption.
```typ
#let walkthrough(..items, columns: auto, arrows: false, gutter: 12pt)
```
- `..items` (content, optional): the pictures, in order
- `columns` (auto|int, optional): `auto` puts everything in one row; a number wraps to a new row after that many items
- `arrows` (bool|content, optional): `true` draws an arrow between consecutive items; content replaces the default arrow (e.g. `$arrow.r.double$`)
- `gutter` (length, optional): spacing between items

**Edge-Cases:**
- no items: draw nothing
- exactly one item: draw it without arrow
- `columns` larger than item count: same as `auto`
- `arrows` with wrapped rows: the arrow is omitted at the end of a row; reading order is left-to-right, top-to-bottom

**Example:** `walkthrough(bst-from((2, 1)), bst-from((2, 1, 3)), arrows: true)`

**Example with algorithms:** `walkthrough(bst(t), bst(rotate-left(t, 1)), arrows: true)`

## step
Optional helper: a single labelled picture, a title above any drawn tree (or any content). Only needed for captions in `walkthrough`.
```typ
#let step(title, content)
```
- `title` (string|content|none, required): caption shown above the content; `none` for no caption
- `content` (content, required): anything, usually the result of a tree function

**Edge-Cases:**
- `title` is `none`: render only the content, no gap

**Example:** `step("insert 7", bst-from((5, 3, 7)))`

# Basic Tree Algorithms
Rotations are applicable to `binary-tree`, `bst`, `avl-tree` and `treap`. They are not applicable to `heap` (would break the shape) or `b-tree` (different node type).

The result is always returned in long form: every node is `(key, left, right)` and missing children are `none`, leaves are never collapsed to a bare key. The input may use any form. "Unchanged" means the same tree, also in long form.

Nodes are always addressed by `key`. For treaps, `key` is the first element of the `(key, prio)` pair: the node is rotated by its key and its priority moves with it.

Terms: `x` is the node with key `key`; `A`, `B`, `C`, `D` are subtrees.

## rotate-left
`x` moves down-left, its right child `y` becomes the new root of this subtree. Requires a right child.
```
   x                y
  / \              / \
 A   y     →      x   C
    / \          / \
   B   C        A   B
```
```typ
#let rotate-left(tree, key)
```
- `tree` (tree, required): the whole tree
- `key` (int|string, required): key of the node `x` to rotate around

**Edge-Cases:**
- `key` not in `tree`: unchanged
- `x` has no right child: unchanged

**Example:** `rotate-left((1, none, (2, none, 3)), 1)` → `(2, (1, none, none), (3, none, none))`

## rotate-right
Mirror image of `rotate-left`. Requires a left child.
```typ
#let rotate-right(tree, key)
```
Arguments and edge cases as `rotate-left`, with "left child" required.

**Example:** `rotate-right((2, 1, none), 2)` → `(1, none, (2, none, none))`

## rotate-left-right
Double rotation for the left-right case: `rotate-left` at the left child of `x`, then `rotate-right` at `x`. Requires a left child that itself has a right child.
```
     x                x               z
    / \              / \             / \
   y   D    →       z   D    →      y   x
  / \              / \             / \ / \
 A   z            y   C           A  B C  D
    / \          / \
   B   C        A   B
```
```typ
#let rotate-left-right(tree, key)
```
- `tree`, `key`: as above, `key` is the topmost node `x`

**Edge-Cases:**
- `key` not in `tree`: unchanged
- `x` has no left child, or the left child has no right child: unchanged

**Example:** `rotate-left-right((3, (1, none, 2), none), 3)` → `(2, (1, none, none), (3, none, none))`

## rotate-right-left
Mirror image: `rotate-right` at the right child of `x`, then `rotate-left` at `x`. Requires a right child that itself has a left child. Arguments and edge cases as `rotate-left-right`, with the children swapped.
```
   x                x                 z
  / \              / \               / \
 A   y     →      A   z      →      x   y
    / \              / \           / \ / \
   z   D            B   y         A  B C  D
  / \                  / \
 B   C                C   D
```
```typ
#let rotate-right-left(tree, key)
```

**Example:** `rotate-right-left((1, none, (3, 2, none)), 1)` → `(2, (1, none, none), (3, none, none))`

# Basic Heap Algorithms
Operate on `heap`-style trees. Heaps must be complete trees (filled by level, left to right); the operations keep this shape and only move keys. If the tree is not complete, it is returned unchanged. Results are returned in long form, as described under rotations.

## up-heap
Moves the key at `key` upward (swap with parent) while it violates heap order against its parent.
```typ
#let up-heap(tree, key, order: "min")
```
- `tree` (tree, required): a heap that is valid except possibly at `key`
- `key` (int|string, required): the node to sift up
- `order` ("min"|"max", optional): min-heap (parent ≤ child) or max-heap (parent ≥ child); use the same value as for `heap`

**Edge-Cases:**
- `tree` is not a complete tree: unchanged
- `key` not in `tree`: unchanged
- `key` is the root: unchanged
- parent already fine: unchanged

**Example:** `up-heap((4, (2, 6, 5), 7), 2)` → `(2, (4, (6, none, none), (5, none, none)), (7, none, none))`

## down-heap
Moves the key at `key` downward, swapping with the smaller child (min-heap) or larger child (max-heap), until heap order holds or it is a leaf.
```typ
#let down-heap(tree, key, order: "min")
```
Arguments as `up-heap`. `tree` is a heap that is valid except possibly at `key`.

**Edge-Cases:**
- `tree` is not a complete tree: unchanged
- `key` not in `tree`, or `key` is a leaf: unchanged
- only one child: compare against that child

**Example:** `down-heap((8, (3, 6, 5), (2, 9, none)), 8)` → `(2, (3, (6, none, none), (5, none, none)), (8, (9, none, none), none))`
