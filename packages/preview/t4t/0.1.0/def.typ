// Defaults
#let if-true( test, default, value ) = if test {
  return default
} else {
  return value
}

#let if-false( test, default, value ) = if not test {
  return default
} else {
  return value
}

#let if-none( default, value ) = if value == none {
  return default
} else {
  return value
}

#let if-auto( default, value ) = if value == auto {
  return default
} else {
  return value
}

#let if-any( ..compare, default, value ) = if value in compare.pos() {
  return default
} else {
  return value
}

#let if-not-any( ..compare, default, value ) = if value not in compare.pos() {
  return default
} else {
  return value
}

#let if-empty( default, value ) = if is-empty(value) {
  return default
} else {
  return value
}
