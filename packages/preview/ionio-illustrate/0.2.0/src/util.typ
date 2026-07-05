/// Merge dictionary a and b and return the result
/// Prefers values of b.
///
/// - a (dictionary): Dictionary a
/// - b (dictionary): Dictionary b
/// -> dictionary
#let merge-dictionary(a, b, overwrite: true) = {
  if type(a) == dictionary and type(b) == dictionary {
    let c = a
    for (k, v) in b {
      if not k in c {
        c.insert(k, v)
      } else {
        c.at(k) = merge-dictionary(a.at(k), v, overwrite: overwrite)
      }
    }
    return c
  } else {
    return if overwrite {b} else {a}
  }
}