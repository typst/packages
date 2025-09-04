/// Assert that two floats or arrays are equal up to a (configurable) epsilon.
#let approx(

  /// First value.
  a,

  /// Second value.
  b,

  /// Absolute tolerance.
  eps: 1e-20,

  // Relative tolerance
  rel-eps: 1e-09

) = {
  if type(a) == array and type(b) == array {
    assert(a.len() == b.len(), message: "Non-matching array lengths " + repr(a) + " / " + repr(b))
    for (x, y) in a.zip(b) {
      // if calc.abs(x - y) >= eps and calc.abs(1 - calc.abs(x / y)) >= eps {
      if calc.abs(x - y) > calc.max(rel-eps * calc.max(calc.abs(x), calc.abs(y)), eps) {
        assert(false, message: repr(x) + " was not approx equal to " + repr(y) )
        assert(false, message: repr(a) + " was not approx equal to " + repr(b) )
      }
    }
  } else {
    assert(calc.abs(a - b) < eps, message: str(a) + " and " + str(b) + " are not equal up to " + str(eps))

  }
}


#approx(1, 1)
#approx((5e45, 1e46, 1.4999999999999999e46, 2e46), (5e45, 1e46, 1.5e46, 2e46))