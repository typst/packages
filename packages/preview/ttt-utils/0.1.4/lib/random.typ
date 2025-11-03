/// create a hash value from a seed for some content
#let hash(value, seed) = {
  array(bytes(repr(value))).fold(seed, (a,b) => (a.bit-lshift(1)).bit-xor(b))
}

/// shuffle an array.
///
/// - arr (array): the array to randomize
/// - seed (int): a seed to start with. if auto the current date will be used (default).
/// -> array
#let shuffle(arr, seed: auto) = arr.sorted(key: it => {
  let now = datetime.today()
  let rand = if (seed == auto) { int(now.year() + now.month() * 256 * now.day() * 65535) } else { seed }
  hash(it,rand)
})

