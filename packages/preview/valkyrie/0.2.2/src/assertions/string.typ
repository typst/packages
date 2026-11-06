/// Asserts that a tested value contains the argument (string)
#let contains(value) = {
  return (
    condition: (self, it) => it.contains(value),
    message: (self, it) => "Must contain " + str(value),
  )
}

/// Asserts that a tested value starts with the argument (string)
#let starts-with(value) = {
  return (
    condition: (self, it) => it.starts-with(value),
    message: (self, it) => "Must start with " + str(value),
  )
}

/// Asserts that a tested value ends with the argument (string)
#let ends-with(value) = {
  return (
    condition: (self, it) => it.ends-with(value),
    message: (self, it) => "Must end with " + str(value),
  )
}

/// Asserts that a tested value matches with the needle argument (string)
#let matches(needle, message: (self, it) => { }) = {
  return (
    condition: (self, it) => it.match(needle) != none,
    message: message,
  )
}