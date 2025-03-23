

/// Computes the value at a rational index into an array by performing linear 
/// interpolation. If the index is an integer, the exact value at the index is 
/// returned. 
///
/// -> int | float
#let linear(
  
  /// Data values to interpolate from. 
  /// -> array
  values, 

  /// Rational index into the array. 
  /// -> int | float
  index
  
) = {
  let n = values.len()
  assert(n > 0, message: "An array with at least one element is required for interpolation")
  assert(0 <= index and index <= n - 1, message: "Index " + str(index) + " out of range for interpolation with array of length " + str(n))
  if index < 0 { return values.first() }
  if index >= n - 1 { return values.last() }
  let lower = calc.floor(index)
  let upper = lower + 1
  let t = calc.fract(index)
  values.at(lower) * (1 - t) + values.at(upper) * t
}



#assert.eq(linear((1,2,8), 0), 1)
#assert.eq(linear((1,2,8), 0.5), 1.5)
#assert.eq(linear((1,2,8), 1.5), 5)
#assert.eq(linear((1,2,8), 1), 2)
#assert.eq(linear((1,2,8), 2), 8)