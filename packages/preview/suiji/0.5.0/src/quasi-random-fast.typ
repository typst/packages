//==============================================================================
// Quasi-Random generator (fast version)
//
// Public functions:
//     haltonset-f
//==============================================================================


#let plg = plugin("core.wasm")


//----------------------------------------------------------
// Public functions
//----------------------------------------------------------

// Return a Halton sequence point set
//
// Arguments:
//     dim: number of dimensions in the set, effective value is an integer from [1, 30]
//     size: returned points array size, must be none or non-negative integer, optional
//     skip: number of initial points to omit, optional
//     leap: number of points to miss out between returned points, optional
//     permutation: whether use permutations of coefficients in each of the radical inverse functions, optional
//
// Returns:
//     arr: array of points
#let haltonset-f(dim, size: none, skip: 0, leap: 0, permutation: true) = {
  assert(type(dim) == int and dim >= 1 and dim <= 30, message: "`dim` should be in range [1, 30]")
  assert((size == none) or (type(size) == int and size >= 0), message: "`size` should be non-negative")
  assert(type(skip) == int and skip >= 0, message: "`skip` should be non-negative")
  assert(type(leap) == int and leap >= 0, message: "`leap` should be non-negative")
  assert(type(permutation) == bool, message: "`permutation` should be bool")

  let n = if size == none {1} else {size}
  let enc = cbor.encode((dim, n, skip, leap, permutation))
  let arr = cbor(plg.haltonset_fn(enc))

  if dim == 1 or n == 1 {
    return arr
  } else {
    return arr.chunks(dim)
  }
}
