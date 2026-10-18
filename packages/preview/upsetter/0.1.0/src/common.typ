/// Parse an intersection key into a dictionary of set identifiers,
/// allowing to compose calls by passing a dictionary as the `seen` argument.
///
/// ```examplec
/// >>> import upsetter: _parse-inter-key
/// let key = "a+b+c"
/// assert(
///   _parse-inter-key(key, "+") == (a: 0, b: 1, c: 2),
///   message: "Test shouldn't fail"
/// )
/// assert(
///   _parse-inter-key(key, "+", seen: (b: -1)) == (a: 1, b: -1, c: 2),
///   message: "Test shouldn't fail"
/// )
/// ```
///
/// -> array
#let _parse-inter-key(inter-key, delim, seen: (:)) = {
  if inter-key == "" {
    return seen
  }

  let sets = inter-key.split(delim)

  for s in sets {
    if s not in seen {
      seen.insert(s, seen.len())
    }
  }

  return seen
}
