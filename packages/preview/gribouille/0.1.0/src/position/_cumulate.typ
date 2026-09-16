// Shared bucket-by-x + sort-by-group-key + cumulate scaffold used by
// `position-stack` and `position-fill`. The caller supplies a `slice`
// closure that turns `(cum, yv, tot)` into `(ymin, ymax)`; everything
// else (bucketing, sorting, splicing rows back into input order) is
// identical between the two adjustments.

#import "../utils/group.typ": group-key
#import "../utils/types.typ": parse-number

#let cumulate-by-x(data, mapping, slice) = {
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  if x-col == none or y-col == none { return (data: data, mapping: mapping) }

  let buckets = (:)
  let bucket-order = ()
  for (i, row) in data.enumerate() {
    let xv = row.at(x-col, default: none)
    let yv = parse-number(row.at(y-col, default: none))
    if xv == none or yv == none { continue }
    let bk = str(xv)
    if bk not in buckets {
      buckets.insert(bk, (entries: (), tot: 0.0))
      bucket-order.push(bk)
    }
    let bucket = buckets.at(bk)
    bucket.entries.push((i: i, row: row, key: group-key(row, mapping), y: yv))
    bucket.tot += yv
    buckets.insert(bk, bucket)
  }

  let out = data
  for bk in bucket-order {
    let bucket = buckets.at(bk)
    let tot = bucket.tot
    let cum = 0.0
    for e in bucket.entries.sorted(key: e => e.key) {
      let (ymin, ymax) = slice(cum, e.y, tot)
      cum += e.y
      let new-row = e.row
      new-row.insert("ymin", ymin)
      new-row.insert("ymax", ymax)
      new-row.insert(y-col, ymax)
      out.at(e.i) = new-row
    }
  }

  let new-mapping = mapping
  new-mapping.insert("ymin", "ymin")
  new-mapping.insert("ymax", "ymax")
  (data: out, mapping: new-mapping)
}
