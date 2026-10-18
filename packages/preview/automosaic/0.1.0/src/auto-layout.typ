// Auto-layout
//
// Given a flat list of content (each with an optional relative-area `weight`,
// default 1), automatically searches every possible way to nest it into a
// horizontal/vertical layout tree (alternating axis, exactly like layout.typ's
// content-dicts), scores each tree, and lets the caller step through the
// ranked results with a selector string ("1", "1.", "1..", "2", ...).
//
// ── Model ────────────────────────────────────────────────────────────────────
//
// For n items, every way to recursively split the *ordered* sequence into
// k>=2 contiguous chunks, alternating axis by depth, is enumerated (the
// standard construction for the little Schröder numbers: n=1:1, 2:1, 3:3,
// 4:11, 5:45, 6:197, 7:903, 8:4279, ...) — once starting from a horizontal
// root and once from a vertical root, since the top-level axis isn't fixed
// either. Each item is measured exactly once into an "atom"; combining atoms
// into group aggregates during the search is pure arithmetic (the same
// formulas as layout.typ's resolve-aspect), so no further `measure()` calls
// happen while enumerating.
//
// Permuting the child order at any group node — in any way, not just
// reversing it — never changes any leaf's area or the tree's cost (group
// aggregates are sums / harmonic sums, and a child's own box size never
// depends on its siblings' order). So the enumeration only ever builds one
// canonical (original-order) representative per such equivalence class, and
// cost is computed exactly once per class. A ranked tree's number of
// cost-free orderings is the product of k! over its internal nodes (k =
// that node's child count — the earlier "just reverse it" scheme only ever
// covered 2 of those k! orderings, so odd/uneven-sized groups mostly missed
// theirs); stepping through them via the selector's trailing dots just
// re-orders `bodies` arrays, it never re-scores anything.
//
// ── Usage ────────────────────────────────────────────────────────────────────
//
//   #context box(width: 100%, height: 6cm)[
//     #display-auto-layout(
//       (
//         image("a.jpg"),
//         (body: image("b.jpg"), weight: 2),
//         image("c.jpg"),
//         (body: [caption], aspect: 1.0),
//       ),
//       gap: 0.5em,
//       selector: "1.",
//     )
//   ]

#import "layout.typ": resolve-stretchable, fit-content-dict

// ── Atoms ─────────────────────────────────────────────────────────────────────

/// Measure one input item into an atom. Items follow the same per-item
/// convention as `parse-content-tree`: raw `content`, or a dict
/// `(body:, aspect:, constant-size:, stretchable_:, weight:)`.
///
/// Unlike a leaf content-dict, an atom does not yet commit to `_c_h`/`_c_w`:
/// whether `constant-size` means a fixed width or fixed height depends on
/// the immediate parent's axis, which varies across candidate trees (the
/// same atom can sit under a horizontal parent in one tree and a vertical
/// parent in another). `materialize-leaf` resolves that once an axis is
/// known.
///
/// -> dictionary
#let make-atom(item, id) = {
  let weight = 1.0
  let aspect = auto
  let constant-size = 0pt
  let stretchable_ = false
  let body = item

  if type(item) == dictionary {
    body = item.body
    aspect = item.at("aspect", default: auto)
    constant-size = item.at("constant-size", default: 0pt)
    stretchable_ = item.at("stretchable_", default: false)
    weight = item.at("weight", default: 1.0)
  }

  let a = if aspect != auto {
    aspect
  } else if type(body) == content {
    let sz = measure(body)
    if sz.height != 0pt { sz.width / sz.height } else { 1.0 }
  } else {
    panic("Cannot auto-detect aspect for non-content body; pass aspect explicitly")
  }

  (
    body: body,
    _id: id,
    _aspect: a,
    _constant-size: constant-size,
    stretchable_: stretchable_,
    weight: weight,
  )
}

/// Turn an atom into a leaf content-dict for a specific parent axis.
/// -> dictionary
#let materialize-leaf(atom, axis) = (
  bodies: (atom.body,),
  gap: 0pt,
  _a: atom._aspect,
  _c_h: if axis == "vertical" { atom._constant-size } else { 0pt },
  _c_w: if axis == "horizontal" { atom._constant-size } else { 0pt },
  _layout-axis: none,
  stretchable_: atom.stretchable_,
  _h-stretchable: 0,
  _v-stretchable: 0,
  _id: atom._id,
)

// ── Pure aggregation (mirrors layout.typ's resolve-aspect, no measuring) ─────

#let combine-horizontal(children, gap) = {
  let n = children.len()
  let A = 0.0
  let C_w = gap * (n - 1)
  for c in children {
    A = A + c._a
    C_w = C_w + c._c_w - c._a * c._c_h
  }
  (_a: A, _c_h: 0pt, _c_w: C_w)
}

// Returns `none` if every child is constant-size (_a == 0) — such a group has
// no well-defined aspect (infinite width for any height), which can only
// arise here because the search tries every grouping blindly, including ones
// a human would never build by hand. Callers must skip `none` results.
#let combine-vertical(children, gap) = {
  let n = children.len()
  let inv_A = 0.0
  let C_h = gap * (n - 1)
  for c in children {
    if c._a != 0 {
      inv_A = inv_A + 1.0 / c._a
      C_h = C_h + c._c_h - c._c_w / c._a
    } else {
      C_h = C_h + c._c_h
    }
  }
  if inv_A == 0 {
    none
  } else {
    (_a: 1.0 / inv_A, _c_h: C_h, _c_w: 0pt)
  }
}

// ── Combinatorics helpers ─────────────────────────────────────────────────────

// All compositions of n into >=1 parts (order matters), e.g. all-compositions(3)
// = ((3,), (1,2), (1,1,1), (2,1)).
#let all-compositions(n) = {
  if n == 1 { return ((1,),) }
  let results = ((n,),)
  for p in range(1, n) {
    let rest = n - p
    for comp in all-compositions(rest) {
      results.push((p,) + comp)
    }
  }
  results
}

// All compositions of n into k>=2 parts (contiguous chunk sizes for one
// grouping level).
#let compositions-k2(n) = {
  let results = ()
  for p in range(1, n) {
    let rest = n - p
    for comp in all-compositions(rest) {
      results.push((p,) + comp)
    }
  }
  results
}

#let cartesian-product(lists) = {
  if lists.len() == 0 { return ((),) }
  let first = lists.at(0)
  let rest-product = cartesian-product(lists.slice(1))
  let results = ()
  for item in first {
    for combo in rest-product {
      results.push((item,) + combo)
    }
  }
  results
}

#let split-by-sizes(arr, sizes) = {
  let chunks = ()
  let idx = 0
  for s in sizes {
    chunks.push(arr.slice(idx, idx + s))
    idx += s
  }
  chunks
}

// ── Tree enumeration ──────────────────────────────────────────────────────────

#let enumerate-subtrees(atoms, axis, gap) = {
  let n = atoms.len()
  if n == 1 {
    return (materialize-leaf(atoms.at(0), axis),)
  }
  let opposite = if axis == "horizontal" { "vertical" } else { "horizontal" }
  let results = ()
  for composition in compositions-k2(n) {
    let chunks = split-by-sizes(atoms, composition)
    let choice-lists = chunks.map(chunk => {
      if chunk.len() == 1 {
        (materialize-leaf(chunk.at(0), axis),)
      } else {
        enumerate-subtrees(chunk, opposite, gap)
      }
    })
    for combo in cartesian-product(choice-lists) {
      let agg = if axis == "horizontal" {
        combine-horizontal(combo, gap)
      } else {
        combine-vertical(combo, gap)
      }
      if agg == none { continue }
      results.push((
        bodies: combo,
        gap: gap,
        _a: agg._a,
        _c_h: agg._c_h,
        _c_w: agg._c_w,
        _layout-axis: axis,
        stretchable_: false,
        _h-stretchable: 0,
        _v-stretchable: 0,
      ))
    }
  }
  results
}

/// Enumerate every distinct layout tree (one canonical representative per
/// reflection-equivalence class) for a flat list of items. The top-level
/// axis is not fixed — both a horizontal-rooted and a vertical-rooted search
/// are run and their results merged, so the search picks whichever
/// orientation fits the page better on its own.
///
/// - items (array): Flat content / per-item dicts, see `make-atom`.
/// - gap (length): Uniform gap applied at every level.
/// - max-items (int): Safety cap — the tree count grows very fast (little
///   Schröder numbers) with item count.
///
/// -> array of (tree: dictionary, axis: string)
#let enumerate-trees(items, gap: 0.5em, max-items: 8) = {
  let n = items.len()
  assert(n >= 1, message: "auto-layout needs at least one item")
  assert(
    n <= max-items,
    message: "auto-layout: " + str(n) + " items exceeds max-items (" + str(max-items)
      + "); the number of possible layouts grows very fast (little Schröder numbers) "
      + "-- raise max-items explicitly if you really want this, or pre-group some items by hand first",
  )
  let atoms = items.enumerate().map(pair => make-atom(pair.at(1), pair.at(0)))
  let horizontal = enumerate-subtrees(atoms, "horizontal", gap).map(t => (tree: t, axis: "horizontal"))
  let vertical = enumerate-subtrees(atoms, "vertical", gap).map(t => (tree: t, axis: "vertical"))
  horizontal + vertical
}

// ── Cost evaluation ───────────────────────────────────────────────────────────

// Own (width, height) of a resolved node (leaf or group) given one known
// dimension. Mirrors make-row's base_widths formula (given: "height") and
// make-col's base_heights formula (given: "width") from layout.typ.
#let node-size(node, dimension, given) = {
  if given == "height" {
    let h = dimension
    let w = (node._a * (h - node._c_h) + node._c_w).to-absolute()
    (w, h)
  } else {
    let w = dimension
    let h = if node._a == 0 { node._c_h } else { (w - node._c_w) / node._a + node._c_h }
    (w, h.to-absolute())
  }
}

// Recursively attribute area to every leaf (indexed by _id), mirroring
// render-content-dict's make-row/make-col recursion but computing plain
// numbers instead of building any content/grid. Stretch budgets are
// intentionally not modeled here (search-time simplification); the final
// chosen tree still goes through the real resolve-stretchable/fit-content-dict.
#let accumulate-areas(node, dimension, given, results) = {
  let (w, h) = node-size(node, dimension, given)
  if node._layout-axis == none {
    results.at(node._id) = (w / 1pt) * (h / 1pt)
    return results
  } else if node._layout-axis == "horizontal" {
    for child in node.bodies {
      results = accumulate-areas(child, h, "height", results)
    }
    return results
  } else {
    for child in node.bodies {
      results = accumulate-areas(child, w, "width", results)
    }
    return results
  }
}

/// Score one tree: how well each leaf's area fraction matches its weight
/// fraction, minus a reward for how much of the page the tree fills. Lower
/// is better.
///
/// - tree (dictionary): A tree produced by `enumerate-trees`.
/// - size (dictionary): Available space (from a `layout` callback).
/// - weights (array): Per-item weights, indexed the same as the input items.
/// - fill-weight (float): How strongly page-fill is rewarded.
///
/// -> float
#let compute-cost(tree, size, weights, fill-weight) = {
  let page-w = size.width.to-absolute()
  let page-h = size.height.to-absolute()

  let height = page-h
  let width = (tree._a * (height - tree._c_h) + tree._c_w).to-absolute()
  let (given, dimension) = if width > page-w {
    ("width", page-w)
  } else {
    ("height", height)
  }

  let (final-w, final-h) = node-size(tree, dimension, given)
  let fill-fraction = ((final-w / 1pt) * (final-h / 1pt)) / ((page-w / 1pt) * (page-h / 1pt))

  let n = weights.len()
  let areas = accumulate-areas(tree, dimension, given, (0.0,) * n)
  let total-area = areas.sum()
  let total-weight = weights.sum()

  let error = range(n).map(i => {
    let area-frac = if total-area == 0 { 0.0 } else { areas.at(i) / total-area }
    let weight-frac = weights.at(i) / total-weight
    calc.pow(area-frac - weight-frac, 2.0)
  }).sum()

  error - fill-weight * fill-fraction
}

// ── Symmetry stepping ─────────────────────────────────────────────────────────
//
// A group's own aggregate (_a, _c_h, _c_w) is a sum / harmonic sum over its
// children, and each child's own box size never depends on its siblings —
// so *any* permutation of a node's children (not just reversal) leaves every
// leaf's area, and thus the whole tree's cost, unchanged. A node with k
// children therefore has k! cost-free orderings, not just 2 — for k > 2 that
// is far more than reflection alone covers (e.g. k=3 gives 6 orderings, but
// only 2 of them are a plain reverse), which is what made odd/uneven-sized
// groups miss most of their equal-cost variants before. The total number of
// variants for a whole tree is the product of k! over all its internal
// nodes.

#let factorial(n) = {
  if n <= 1 { 1 } else { n * factorial(n - 1) }
}

// The `index`-th permutation (0-indexed, factorial-number-system order) of
// `arr`. `index` must be in [0, arr.len()!).
#let nth-permutation(arr, index) = {
  let items = arr
  let idx = index
  let result = ()
  let remaining = items.len()
  while remaining > 0 {
    let fact = factorial(remaining - 1)
    let pick = calc.quo(idx, fact)
    idx = calc.rem(idx, fact)
    result.push(items.at(pick))
    items = items.slice(0, pick) + items.slice(pick + 1)
    remaining -= 1
  }
  result
}

/// Total number of cost-free orderings of a tree: the product of k! over
/// every internal (group) node, where k is that node's child count.
///
/// -> int
#let count-variants(node) = {
  if node._layout-axis == none {
    1
  } else {
    node.bodies.map(count-variants).fold(1, (a, b) => a * b) * factorial(node.bodies.len())
  }
}

// Mixed-radix decode: each internal node consumes a `factorial(k)`-sized
// digit of `v` (least-significant digit first, in pre-order) to pick its own
// child permutation, independent of every other node's choice.
#let apply-variant-rec(node, v) = {
  if node._layout-axis == none {
    return (node, v)
  }
  let radix = factorial(node.bodies.len())
  let digit = calc.rem(v, radix)
  v = calc.quo(v, radix)
  let new-bodies = ()
  for child in node.bodies {
    let (new-child, next-v) = apply-variant-rec(child, v)
    new-bodies.push(new-child)
    v = next-v
  }
  node.bodies = nth-permutation(new-bodies, digit)
  (node, v)
}

/// Reorder a tree's group nodes (structure only, no cost recomputation) to
/// one of its cost-free variants (see `count-variants`). `variant-index`
/// wraps around modulo that count.
///
/// -> dictionary
#let apply-variant(tree, variant-index) = {
  let total = count-variants(tree)
  let v = calc.rem(variant-index, total)
  apply-variant-rec(tree, v).at(0)
}

/// Parse a selector like "1", "1.", "1..", "12..." into (rank, variant).
/// Leading digits are the 1-indexed rank; trailing dots are the cost-free
/// ordering variant index (see `count-variants`).
///
/// -> dictionary
#let parse-selector(sel) = {
  let s = str(sel)
  let dots = 0
  while s.len() > 0 and s.ends-with(".") {
    dots += 1
    s = s.slice(0, s.len() - 1)
  }
  (rank: int(s), variant: dots)
}

// ── Entry point ───────────────────────────────────────────────────────────────

/// Auto-generate and display a layout tree for a flat list of content.
///
/// Enumerates every possible layout tree — trying both a horizontal and a
/// vertical top-level axis, since neither is fixed in advance — scores each
/// by how well its leaves' area fractions match their given weights (plus a
/// page-fill reward), and renders the tree picked by `selector`.
///
/// - items (array): Flat content, or per-item dicts
///   `(body:, aspect:, constant-size:, stretchable_:, weight:)`. No nested
///   arrays — the nesting is exactly what gets generated.
/// - gap (length): Uniform gap applied at every level.
/// - selector (string): `"<rank>"` optionally followed by dots, e.g. `"1"`
///   (best), `"1."` (best, alternate cost-free ordering), `"2"` (2nd best), ...
/// - fill-weight (float): How strongly page-fill is rewarded relative to
///   matching the given weights.
/// - max-items (int): Safety cap on item count (tree count grows very fast).
///
/// -> content
#let display-auto-layout(
  items,
  gap: 0.5em,
  selector: "1",
  fill-weight: 1.0,
  max-items: 8,
) = {
  // [#items]
  // return
  if items.len() == 0 {
    return []
  }
  context {
    let trees = enumerate-trees(items, gap: gap, max-items: max-items)
    let weights = items.map(it => {
      if type(it) == dictionary { it.at("weight", default: 1.0) } else { 1.0 }
    })

    layout(size => {
      let scored = trees.map(t => (tree: t.tree, axis: t.axis, cost: compute-cost(t.tree, size, weights, fill-weight)))
      let ranked = scored.sorted(key: it => it.cost)
      let (rank, variant) = parse-selector(selector)
      let idx = calc.max(0, calc.min(rank - 1, ranked.len() - 1))
      let chosen = ranked.at(idx)
      let final-tree = resolve-stretchable(apply-variant(chosen.tree, variant), chosen.axis)
      fit-content-dict(final-tree, size)
    })
  }
}
