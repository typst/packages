// Shared bucket-by-x + sort-by-group-key + cumulate scaffold used by
// `position-stack` and `position-fill`. The caller supplies a `slice`
// closure that turns `(cum, yv, tot)` into `(ymin, ymax)`, plus an
// optional `shift` closure mapping a bucket's sorted entries and total to
// a baseline offset added to both bounds (streamgraph offsets); everything
// else (bucketing, sorting, splicing rows back into input order) is
// identical between the adjustments.
//
// `drop-empty` removes the rows of zero-total buckets from the output.
// A shifted baseline has no meaningful position for a bucket with nothing
// in it (`stat-align`'s zero-pad rows just outside the data range would
// pinch the stream to y = 0 while the bands float elsewhere), so the
// streamgraph offsets drop them; plain stacking keeps them at zero.
//
// `levels` is `none` or `(col: str, order: array)`: the column of the
// aesthetic whose discrete scale has explicit limits, and those limits. When
// set, each bucket sorts by the position of the row's value of `col` in
// `order` (values it does not list come last, alphabetically by group key),
// so the first level sits on top, as the first legend key does.

#import "../utils/bucket.typ": bucket-index
#import "../utils/group.typ": group-plan, plan-key
#import "../utils/types.typ": (
  axis-discrete, cell-key, is-missing, level-key, missing-last-key,
  parse-number,
)

#let cumulate-by-x(
  data,
  mapping,
  slice,
  shift: none,
  drop-empty: false,
  levels: none,
  discrete: none,
) = {
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  if x-col == none or y-col == none { return (data: data, mapping: mapping) }

  // The plan is the mapping's, not the row's, so it is resolved once here
  // rather than rebuilt for every row.
  let plan = group-plan(mapping)
  // A missing x is the missing level of a discrete x, which stacks as a bucket of
  // its own. On a continuous x it has no position, so its row is left alone.
  let discrete-x = axis-discrete(discrete, "x", data, x-col)
  let entries = data
    .enumerate()
    .map(((i, row)) => (
      i: i,
      row: row,
      key: plan-key(plan, row),
      x: row.at(x-col, default: none),
      y: parse-number(row.at(y-col, default: none)),
    ))
    .filter(e => e.y != none and (discrete-x or not is-missing(e.x)))
  let (keys: bucket-order, buckets: cells) = bucket-index(
    entries,
    e => level-key(e.x),
  )
  let buckets = (:)
  for (i, bk) in bucket-order.enumerate() {
    let rows = cells.at(i)
    buckets.insert(bk, (entries: rows, tot: rows.fold(0.0, (a, e) => a + e.y)))
  }

  // Written in place, one index at a time. `out` is a uniquely owned local
  // after the first write, so the assignment does not clone the array, and
  // collecting the rewritten rows in a patch dict to map over instead measured
  // slower: 3.6 s against 3.1 s over 200000 rows in five buckets.
  // A missing group sorts after every real one, as its legend key does.
  let rank = if levels == none {
    e => missing-last-key(e.key)
  } else {
    let ranks = (:)
    for (i, level) in levels.order.enumerate() {
      let k = cell-key(level)
      if k not in ranks { ranks.insert(k, i) }
    }
    e => (
      ranks.at(
        cell-key(e.row.at(levels.col, default: none)),
        default: levels.order.len(),
      ),
      e.key,
    )
  }
  let out = data
  let drop = ()
  for bk in bucket-order {
    let bucket = buckets.at(bk)
    let tot = bucket.tot
    if drop-empty and tot == 0 {
      for e in bucket.entries { drop.push(e.i) }
      continue
    }
    let sorted = bucket.entries.sorted(key: rank)
    let base = if shift == none { 0.0 } else { shift(sorted, tot) }
    let cum = 0.0
    for e in sorted {
      let (ymin, ymax) = slice(cum, e.y, tot)
      cum += e.y
      let new-row = e.row
      new-row.insert("ymin", base + ymin)
      new-row.insert("ymax", base + ymax)
      new-row.insert(y-col, base + ymax)
      out.at(e.i) = new-row
    }
  }
  if drop.len() > 0 {
    out = out
      .enumerate()
      .filter(((i, row)) => i not in drop)
      .map(((i, row)) => row)
  }

  let new-mapping = mapping
  new-mapping.insert("ymin", "ymin")
  new-mapping.insert("ymax", "ymax")
  (data: out, mapping: new-mapping)
}
