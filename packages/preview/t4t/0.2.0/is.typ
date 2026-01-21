// Test functions for use in any(), all() or find()

#import "alias.typ"

#let neg( test ) = (..args) => { not test(..args) }

#let eq( compare, value ) = {
  return value == compare
}

#let neq( compare, value ) = {
  return value != compare
}

#let n( ..values ) = {
  return none in values.pos()
}
#let non = n

#let not-none( ..values ) = {
  return none not in values.pos()
}
#let not-n = not-none

#let one-not-none( ..values ) = {
  return values.pos().any((v) => v != none)
}

#let a( ..values ) = {
  return auto in values.pos()
}
#let aut = a

#let not-auto( ..values ) = {
  return auto not in values.pos()
}
#let not-a = not-auto

#let empty( value ) = {
  if alias.type(value) == "array" {
    return value == ()
  } else if alias.type(value) == "dictionary" {
    return value == (:)
  } else if alias.type(value) == "string" {
    return value == ""
  } else {
    return value == none
  }
}

#let not-empty( value ) = {
  if alias.type(value) == "array" {
    return value != ()
  } else if alias.type(value) == "dictionary" {
    return value != (:)
  } else if alias.type(value) == "string" {
    return value != ""
  } else {
    return value != none
  }
}

#let any( ..compare, value ) = {
  // return compare.pos().any((v) => v == value)
  return value in compare.pos()
}

#let not-any( ..compare, value) = {
  // return not compare.pos().any((v) => v == value)
  return not value in compare.pos()
}

#let has( ..keys, value ) = {
  if type(value) in ("dictionary", "array") {
    return keys.pos().all((k) => k in value)
  } else {
    return false
  }
}

// Types
#let type( t, value ) = alias.type(value) == t

#let dict( value ) = alias.type(value) == "dictionary"

#let arr( value ) = alias.type(value) == "array"

#let content( value ) = alias.type(value) == "content"

#let label( value ) = alias.type(value) == "label"

#let color( value ) = alias.type(value) == "color"

#let stroke( value ) = alias.type(value) == "stroke"

#let loc( value ) = alias.type(value) == "location"

#let bool( value ) = alias.type(value) == "boolean"

#let str( value ) = alias.type(value) == "string"

#let int( value ) = alias.type(value) == "integer"

#let float( value ) = alias.type(value) == "float"

#let num( value ) = alias.type(value) in ("float", "integer")

#let frac( value ) = alias.type(value) == "fraction"

#let length( value ) = alias.type(value) == "length"

#let rlength( value ) = alias.type(value) == "relative length"

#let ratio( value ) = alias.type(value) == "ratio"

#let align( value ) = alias.type(value) == "alignment"

#let align2d( value ) = alias.type(value) == "2dalignment"

#let func( value ) = alias.type(value) == "function"

#let any-type( ..types, value ) = {
  return alias.type(value) in types.pos()
}

#let same-type( ..values ) = {
  let t = alias.type(values.pos().first())
  return values.pos().all((v) => alias.type(v) == t)
}

#let all-of-type( t, ..values ) = values.pos().all((v) => alias.type(v) == t)

#let none-of-type( t, ..values ) = values.pos().all((v) => alias.type(v) != t)

#let elem( func, value ) = if alias.type(value) == "content" {
  if alias.type(func) == "String" {
    return repr(value.func()) == func
  } else {
    return value.func() == func
  }
} else {
  return false
}

#let sequence( value ) = if alias.type(value) == "content" {
  return repr(value.func()) == "sequence"
} else {
  return false
}

#let raw( value ) = if alias.type(value) == "content" {
  return value.func() == alias.raw
} else {
  return false
}

#let table( value ) = if alias.type(value) == "content" {
  return value.func() == alias.table
} else {
  return false
}

#let list( value ) = if alias.type(value) == "content" {
  return value.func() == alias.list
} else {
  return false
}

#let enum( value ) = if alias.type(value) == "content" {
  return value.func() == alias.enum
} else {
  return false
}

#let terms( value ) = if alias.type(value) == "content" {
  return value.func() == alias.terms
} else {
  return false
}

#let cols( value ) = if alias.type(value) == "content" {
  return value.func() == alias.columns
} else {
  return false
}

#let grid( value ) = if alias.type(value) == "content" {
  return value.func() == alias.grid
} else {
  return false
}

#let stack( value ) = if alias.type(value) == "content" {
  return value.func() == alias.stack
} else {
  return false
}
