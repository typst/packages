// Defaults
#let if-true( test, default, do:none, value ) = if test {
  return default
} else if do == none {
  return value
} else {
  return do(value)
}

#let if-false( test, default, do:none, value ) = if not test {
  return default
} else if do == none {
  return value
} else {
  return do(value)
}

#let if-none( default, do:none, value ) = if value == none {
  return default
} else if do == none {
  return value
} else {
  return do(value)
}

#let if-auto( default, do:none, value ) = if value == auto {
  return default
} else if do == none {
  return value
} else {
  return do(value)
}

#let if-any( ..compare, default, do:none, value ) = if value in compare.pos() {
  return default
} else if do == none {
  return value
} else {
  return do(value)
}

#let if-not-any( ..compare, default, do:none, value ) = if value not in compare.pos() {
  return default
} else if do == none {
  return value
} else {
  return do(value)
}

#let if-empty( default, do:none, value ) = if is-empty(value) {
  return default
} else if do == none {
  return value
} else {
  return do(value)
}

#let if-arg( default, do:none, args, key ) = if key not in args.named() {
  return default
} else if do == none {
  args.named().at(key)
} else {
  do(args.named().at(key))
}

#let as-arr( ..values ) = (..values.pos(),).flatten()

