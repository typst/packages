#import "range.typ" as rng
#import "util.typ"

#let make(
  name,
  bits,
  ranges,
  start: 0
) = {
  return (
    name: name,
    bits: bits,
    ranges: ranges,
    start: start
  )
}

#let load(id, data) = {
  let struct = (id: id)
  let ranges = (:)

  for (range-span, range-data) in data.ranges {
    let (start, end) = rng.parse-span(str(range-span))
    ranges.insert(
      rng.key(start, end),
      rng.load(start, end, range-data)
    )
  }

  let ranges2 = (:)
  for (k, range_) in ranges {
    if range_.values != none and range_.depends-on != none {
      let depends-key = rng.key(..range_.depends-on)
      let depends-range = ranges.at(depends-key)
      let bits = rng.bits(depends-range)
      let values = (:)
      for (v, d) in range_.values {
        v = util.z-fill(str(int(v)), bits)
        values.insert(v, d)
      }
      range_.values = values
    }
    ranges2.insert(k, range_)
  }

  return make(
    id,
    int(data.bits),
    ranges2,
    start: data.at("start", default: 0)
  )
}

#let get-sorted-ranges(struct) = {
  let ranges = struct.ranges.values()
  return ranges.sorted(key: r => r.end)
}