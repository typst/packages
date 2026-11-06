#import "../assertions-util.typ": assert-positive-type

/// Asserts that tested value is greater than or equal to argument
#let min(rhs) = {
  assert-positive-type(rhs, types: (int,), name: "Minimum")

  return (
    condition: (self, it) => it >= rhs,
    message: (self, it) => "Must be at least " + str(rhs),
  )
}

/// Asserts that tested value is less than or equal to argument
#let max(rhs) = {
  assert-positive-type(rhs, types: (int,), name: "Maximum")

  return (
    condition: (self, it) => it <= rhs,
    message: (self, it) => "Must be at most " + str(rhs),
  )
}

/// Asserts that tested value is exactly equal to argument
#let eq(rhs) = {
  assert-positive-type(rhs, types: (int,), name: "Equality")

  return (
    condition: (self, it) => it == rhs,
    message: (self, it) => "Must be exactly " + str(rhs),
  )
}