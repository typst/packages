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

#import "../utils/bucket.typ": bucket-index
#import "../utils/group.typ": group-plan, plan-key
#import "../utils/types.typ": parse-number

#let cumulate-by-x(data, mapping, slice, shift: none, drop-empty: false) = {
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  if x-col == none or y-col == none { return (data: data, mapping: mapping) }

  // The plan is the mapping's, not the row's, so it is resolved once here
  // rather than rebuilt for every row.
  let plan = group-plan(mapping)
  let entries = data
    .enumerate()
    .map(((i, row)) => (
      i: i,
      row: row,
      key: plan-key(plan, row),
      x: row.at(x-col, default: none),
      y: parse-number(row.at(y-col, default: none)),
    ))
    .filter(e => e.x != none and e.y != none)
  let (keys: bucket-order, buckets: cells) = bucket-index(
    entries,
    e => str(e.x),
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
  let out = data
  let drop = ()
  for bk in bucket-order {
    let bucket = buckets.at(bk)
    let tot = bucket.tot
    if drop-empty and tot == 0 {
      for e in bucket.entries { drop.push(e.i) }
      continue
    }
    let sorted = bucket.entries.sorted(key: e => e.key)
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
