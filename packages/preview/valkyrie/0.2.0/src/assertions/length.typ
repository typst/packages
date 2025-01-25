#import "../assertions-util.typ": assert-positive-type

/// Asserts that tested value's length is greater than or equal to argument
#let min(rhs) = {
  assert-positive-type(rhs, types: (int,), name: "Minimum length")

  return (
    condition: (self, it) => it.len() >= rhs,
    message: (self, it) => "Length must be at least " + str(rhs),
  )
}

/// Asserts that tested value's length is less than or equal to argument
#let max(rhs) = {
  assert-positive-type(rhs, types: (int,), name: "Maximum length")

  return (
    condition: (self, it) => it.len() <= rhs,
    message: (self, it) => "Length must be at most " + str(rhs),
  )
}

/// Asserts that tested value's length is exactly equal to argument
#let equals(rhs) = {
  assert-positive-type(rhs, types: (int,), name: "Exact length")

  return (
    condition: (self, it) => it.len() == rhs,
    message: (self, it) => "Length must equal " + str(rhs),
  )
}