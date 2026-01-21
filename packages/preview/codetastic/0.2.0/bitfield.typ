
#import "bits.typ"

// TODO: This probably should be improved / optimized.


/// Creates a new bitfield of the given dimensions and
/// initializes its values with the given init function.
///
/// A bitfield stores bits in an array of arrays. The value
/// at `bitfield.at(i).at(j)` is the bit in row `i`, column `j`.
///
/// #arg[init] is a function that takes the row and column index of
/// of a bit and returns a #dtype("boolean") to initialize the bit.
#let new(n, m, init:(i,j) => false) = {
  return range(n).map(
    i => range(m).map(j => init(i,j))
  )
}

#let from-str(..str) = {
  return str.pos().map(bits.from-str)
}

#let at(field, i, j) = field.at(i).at(j)

#let map(a, func) = {
  return a.enumerate().map(((i, c)) => c.enumerate().map(((j, d)) => func(i, j, d)))
}

#let band(a, b) = {
  return a.enumerate().map(((i, c)) => bits.band(c, b.at(i)))
}

#let bor(a, b) = {
  return a.enumerate().map(((i, c)) => bits.bor(c, b.at(i)))
}

#let bxor(a, b) = {
  return a.enumerate().map(((i, c)) => bits.bxor(c, b.at(i)))
}

#let compose(a, b, at:(0,0), center:false) = {
  let (m,n) = (
    b.len(), b.first().len()
  )
  let (x,y) = at

  if center {
    (x, y) = (
      x - int(m/2), y - int(n/2)
    )
  }

  for i in range(m) {
    for j in range(n) {
      a.at(x + i).at(y + j) = b.at(i).at(j)
    }
  }

  return a
}
