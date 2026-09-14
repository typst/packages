

/// Deeply merges two dictionaries into one.
///
/// Note: We modify `acc` directly, but since Typst is essentially pass-by-value
/// by default, this doesn't actually mutate the original dictionary outside
/// this function.
///
/// - acc (dictionary): The accumulator dictionary that will be modified.
/// - dict (dictionary): The dictionary to merge into `acc`. If a key in `dict`
///   conflicts with a key in `acc`, the value from `dict` will override the
///   value in `acc` unless the value in `dict` is `none` or the same as the
///   value in `acc`. In that case, the value in `acc` remains unchanged.
/// -> dictionary
#let merge-pair(acc, dict) = {
  if (type(acc) != dictionary or type(dict) != dictionary) {
    panic("merge-pair expects both arguments to be dictionaries")
  }
  for (k, v) in dict {
    // Check if we have a conflicting key
    if (k in acc) {
      // Save `acc.at(k)` to avoid multiple lookups
      let acc-v = acc.at(k)
      if v == none or acc-v == v {
        // Forbid overriding existing values with `none`, or with the same value
        continue
      } else if type(acc-v) == dictionary and type(v) == dictionary {
        acc.insert(k, merge-pair(acc-v, v))
      } else {
        acc.insert(k, v)
      }
    } else {
      // If `acc` didn't have the key (i.e., we didn't have a conflict), just
      // insert the new key-value pair
      acc.insert(k, v)
    }
  }
  acc
}


/// Deeply merges multiple dictionaries into one.
///
/// - args (arguments): Dictionaries to merge. Later dictionaries
///   (e.g., the last argument) /  will override earlier ones (e.g., the first
///   argument) if they have the same keys.
/// -> dictionary
#let merge(..args) = {
  assert(
    args.pos().len() > 0,
    message: "merge() expects at least one dictionary",
  )
  let acc = args.pos().first()
  for dict in args.pos().slice(1) {
    acc = merge-pair(acc, dict)
  }
  acc
}
