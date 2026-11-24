// B-trees (order m according to Knuth: at most m children and m − 1 keys per page).
//
// Notation: `none` or `()` (empty), a leaf `(keys)`, or `((keys), child1, child2, ...)`.
// Internally every page is `(keys: (...), children: (...), leaf: bool)`. An inner page
// without children (`((5,),)`) is possible, so `leaf` is not just `children == ()`.

#import "tree.typ": as-list, check-bool, check-keys
#import "colors.typ": palette, style
#import "draw.typ": dy, font-size, gap, inset, pad, radius

#let check-b-order(order) = assert(
  type(order) == int and order >= 3,
  message: "sapling: order must be an int of at least 3, got " + repr(order),
)

// Converts a tree from user notation to the internal form (`none` or a page).
// Only the shape is checked here; the keys are checked by the callers.
#let normalize-b(tree) = {
  if tree == none or tree == () { return none }
  assert(
    type(tree) == array and tree.len() > 0,
    message: "sapling: a page is (keys) or ((keys), child, ...), got " + repr(tree),
  )
  if type(tree.first()) == array {
    (keys: tree.first(), children: tree.slice(1).map(normalize-b), leaf: false)
  } else {
    (keys: tree, children: (), leaf: true)
  }
}

// The inverse of `normalize-b`.
#let to-notation(page) = {
  if page == none { return none }
  if page.leaf { return page.keys }
  (page.keys,) + page.children.map(to-notation)
}

// All keys of a page and its subtree.
#let page-keys(page) = page.children.fold(page.keys, (all, c) => all + page-keys(c))

// Height of a page (counting edges): 0 for a leaf.
#let page-height(page) = {
  if page.leaf { return 0 }
  1 + page.children.map(page-height).fold(0, calc.max)
}

// Inserts `key` below `page`. Returns `(page,)`, or `(left, median, right)` if the
// page overflowed (reached `order` keys) and was split; the median goes up.
// For an even order the median is the upper one of the two middle keys.
#let insert-below(page, key, order) = {
  let (keys, children, leaf) = page
  let i = keys.filter(k => k < key).len()
  if leaf {
    keys.insert(i, key)
  } else {
    let r = insert-below(children.at(i), key, order)
    children.at(i) = r.first()
    if r.len() == 3 {
      keys.insert(i, r.at(1))
      children.insert(i + 1, r.at(2))
    }
  }
  if keys.len() < order { return ((keys: keys, children: children, leaf: leaf),) }
  let m = calc.quo(order, 2)
  (
    (keys: keys.slice(0, m), children: if leaf { () } else { children.slice(0, m + 1) }, leaf: leaf),
    keys.at(m),
    (keys: keys.slice(m + 1), children: if leaf { () } else { children.slice(m + 1) }, leaf: leaf),
  )
}

// Inserts `key` into a tree in internal form. A key that is already there is left out.
#let b-insert(tree, key, order) = {
  if tree == none { return (keys: (key,), children: (), leaf: true) }
  if key in page-keys(tree) { return tree }
  let r = insert-below(tree, key, order)
  if r.len() == 1 { r.first() } else { (keys: (r.at(1),), children: (r.first(), r.at(2)), leaf: false) }
}

// Adds `error: true` to every page that breaks a B-tree rule, `false` to the others:
// - at most `order − 1` keys, at least 1 in the root and ⌈order / 2⌉ − 1 in the others
// - keys strictly ascending, and within the bounds set by the separators of the ancestors
// - an inner page with k keys has k + 1 children
// - all leaves are on the bottom level
// A page that breaks the key rules does not tighten the bounds for its children.
#let mark-errors(page, order, bottom, depth: 0, low: none, high: none) = {
  let (keys, children, leaf) = page
  let n = keys.len()
  let sorted = keys.windows(2).all(w => w.at(0) < w.at(1))
  let inside = keys.all(k => (low == none or k > low) and (high == none or k < high))
  let sound = sorted and inside
  let fewest = if depth == 0 { 1 } else { calc.quo(order + 1, 2) - 1 }
  let error = (
    not sound
      or n < fewest
      or n > order - 1
      or if leaf { depth != bottom } else { children.len() != n + 1 }
  )
  let child(i, c) = mark-errors(
    c,
    order,
    bottom,
    depth: depth + 1,
    low: if sound and 0 < i and i <= n { keys.at(i - 1) } else { low },
    high: if sound and i < n { keys.at(i) } else { high },
  )
  (keys: keys, children: children.enumerate().map(((i, c)) => child(i, c)), leaf: leaf, error: error)
}

// Places a page above its children, which are placed side by side. `w` is the width
// of a cell, `slots` the number of cells of a full page (order − 1). Returns the width of the subtree, the x of the page's centre, the placed
// pages and the edges `(x-from, depth, x-to)`; all x are relative to the subtree's left edge.
#let layout(page, depth, w, slots) = {
  let k = page.keys.len()
  // every page is drawn at full size; an overfull page is as wide as its keys
  let width = calc.max(k, slots) * w
  let subs = page.children.map(c => layout(c, depth + 1, w, slots))
  if subs.len() == 0 {
    return (width: width, x: width / 2, pages: ((page: page, x: width / 2, depth: depth),), edges: ())
  }
  let offsets = ()
  let at = 0pt
  for s in subs {
    offsets.push(at)
    at += s.width + gap
  }
  // the page is centred above its first and last child, and may stick out
  let mid = (offsets.first() + subs.first().x + offsets.last() + subs.last().x) / 2
  let left = calc.min(0pt, mid - width / 2)
  let right = calc.max(at - gap, mid + width / 2)
  let x = mid - left
  let pages = ((page: page, x: x, depth: depth),)
  let edges = ()
  for (i, s) in subs.enumerate() {
    let o = offsets.at(i) - left
    pages += s.pages.map(p => (page: p.page, x: p.x + o, depth: p.depth))
    edges += s.edges.map(e => (e.at(0) + o, e.at(1), e.at(2) + o))
    // child i hangs from the i-th boundary between the cells of the page
    edges.push((x - width / 2 + calc.min(i, k) * w, depth, o + s.x))
  }
  (width: right - left, x: x, pages: pages, edges: edges)
}

// Draws a B-tree exactly as given. Every page has order − 1 cells, unused ones stay
// empty. A key in `marked` colors its cell; if
// `show-errors` is `true`, pages that break the B-tree rules are marked (this wins over `marked`).
#let b-tree(tree, order, marked: none, show-errors: true) = {
  check-b-order(order)
  check-bool(show-errors, "show-errors")
  let tree = normalize-b(tree)
  let marked = as-list(marked, "marked")
  check-keys((if tree == none { () } else { page-keys(tree) }) + marked)
  if tree == none { return text(size: font-size)[∅] }

  let tree = mark-errors(tree, order, page-height(tree))
  let shown(key) = text(size: font-size)[#key]

  context {
    let c = palette()
    let w = calc.max(2 * radius, page-keys(tree).map(k => measure(shown(k)).width).fold(0pt, calc.max) + 2 * inset)
    let l = layout(tree, 0, w, order - 1)
    let max-depth = l.pages.map(p => p.depth).fold(0, calc.max)
    block(
      width: 2 * pad + l.width,
      height: 2 * (pad + radius) + max-depth * dy,
      breakable: false,
      {
        // edges first, so the pages cover their ends
        for (x0, depth, x1) in l.edges {
          place(top + left, line(
            start: (pad + x0, pad + 2 * radius + depth * dy),
            end: (pad + x1, pad + (depth + 1) * dy),
            stroke: 0.6pt + c.border,
          ))
        }
        for p in l.pages {
          // unused slots of the page are empty cells
          let keys = p.page.keys + (none,) * calc.max(0, order - 1 - p.page.keys.len())
          let x0 = pad + p.x - keys.len() * w / 2
          for (i, key) in keys.enumerate() {
            let (stroke, fill) = style(c, error: show-errors and p.page.error, marked: key in marked)
            place(top + left, dx: x0 + i * w, dy: pad + p.depth * dy, rect(
              width: w,
              height: 2 * radius,
              inset: 0pt,
              fill: fill,
              stroke: stroke,
              align(center + horizon, if key != none { shown(key) }),
            ))
          }
        }
      },
    )
  }
}

// Draws the B-tree built by inserting the keys one after another: a key goes into
// its leaf, and a page that reaches `order` keys is split, moving its median up.
// Duplicates after the first occurrence are left out.
#let b-tree-from(keys, order, marked: none) = {
  check-b-order(order)
  let keys = as-list(keys, "keys").dedup()
  check-keys(keys)
  b-tree(to-notation(keys.fold(none, (t, k) => b-insert(t, k, order))), order, marked: marked)
}
