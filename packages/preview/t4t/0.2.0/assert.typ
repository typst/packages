// Asserts

#import "alias.typ"

#let that = assert
#let that-not( test, message:"" ) = assert(not test, message:message)
#let eq = assert.eq
#let ne = assert.ne
#let neq = assert.ne

#let not-none = assert.ne.with(none)

#let any( ..values, value, message:"" ) = assert(value in values.pos(), message:message)
#let not-any( ..values, value, message:"" ) = assert(value not in values.pos(), message:message)
#let any-type( ..types, value, message:"") = assert(type(value) in types.pos(), message:message)
#let not-any-type( ..types, value, message:"" ) = assert(type(value) not in types.pos(), message:message)
#let all-of-type( t, ..values, message:"") = assert(values.pos().all((v) => alias.type(v) == t), message:message)
#let none-of-type( t, ..values, message:"") = assert(values.pos().all((v) => alias.type(v) != t), message:message)

#let not-empty( value, message:"" ) = {
  if type(value) == "array" {
    assert.ne(value, (), message:message)
  } else if type(value) == "dictionary" {
    assert.ne(value, (:), message:message)
  } else if type(value) == "string" {
    assert.ne(value, "", message:message)
  } else {
    assert.ne(value, none, message:message)
  }
}

#let new( test ) = (v, message:"") => assert(test(v), message:message)
