// Bucketing items by a key, in first-appearance order.
//
// Typst arrays are refcounted persistent vectors, so `push` is amortised O(1)
// only while the array is uniquely owned. Reading a bucket out of a dictionary
// to push to it shares that array, which makes the push copy the whole bucket:
// a run that puts every item in one bucket then costs a copy per item.
//
// Holding the buckets in a plain array and appending through `at` keeps each
// one uniquely owned, so the append stays in place.

// Bucket `items` by the key `key-of` answers for each, keeping the order the
// keys first appear in.
//
// `key-of` answers `none` for an item that belongs in no bucket, which is how a
// caller drops an item without walking the array twice.
//
// Returns `(keys, buckets)`, one bucket per key at the same index. A caller
// that needs a dictionary builds it from the pair; most walk them together and
// never need one.
#let bucket-index(items, key-of) = {
  let index = (:)
  let keys = ()
  let buckets = ()
  for item in items {
    let key = (key-of)(item)
    if key == none { continue }
    let at = index.at(key, default: none)
    if at == none {
      at = buckets.len()
      index.insert(key, at)
      keys.push(key)
      buckets.push(())
    }
    buckets.at(at).push(item)
  }
  (keys: keys, buckets: buckets)
}

// The same bucketing, answered as a dictionary for a caller that looks its
// buckets up by key rather than walking them in order.
#let bucket-dict(items, key-of) = {
  let (keys, buckets) = bucket-index(items, key-of)
  let out = (:)
  for (i, key) in keys.enumerate() { out.insert(key, buckets.at(i)) }
  out
}
