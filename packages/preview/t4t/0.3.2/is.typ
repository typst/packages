#import "alias.typ"

// =================================
//  Test functions for use in any(),
//  all() or find()
// =================================

/// Creates a new test function, that is #value(true), when #arg[test] is #value(false).
///
/// Can be used to create negations of tests like:
/// #codesnippet[```typ
/// #let not-raw = is.neg(is.raw)
/// ```]
///
/// // Tests
/// #test(
///   scope: (not-raw: is.neg(is.raw)),
///   `not-raw("foo")`,
///   `not not-raw(raw("foo"))`,
///   ```
///   not not-raw(`foo`)
///   ```
/// )
///
/// - test (function, boolean): Test to negate.
/// -> function
#let neg( test ) = (..args) => { not test(..args) }

/// Tests if values #arg[compare] and #arg[value] are equal.
///
/// // Tests
/// #test(
///   `is.eq("foo", "foo")`,
///   `not is.eq("foo", "bar")`
/// )
///
/// - compare (any): first value
/// - value (any): second value
/// -> boolean
#let eq( compare, value ) = {
  return value == compare
}

/// Tests if #arg[compare] and #arg[value] are not equal.
///
/// // Tests
/// #test(
///   `is.neq(1, 2)`,
///   `is.neq("a", false)`,
///   `not is.neq(1, 1)`,
///   `not is.neq("1", "1")`,
/// )
///
/// - compare (any): First value.
/// - value (any): Second value.
/// -> boolean
#let neq( compare, value ) = {
  return value != compare
}

/// Tests if any one of #arg[values] is equal to #value(none).
///
/// // Tests
/// #test(
///   `is.n(none)`,
///   `not is.n("a")`,
///   `is.n(1, false, none, "none")`,
///   `not is.n(1, false, "none")`
/// )
///
/// - ..values (any): Values to test.
/// -> boolean
#let n( ..values ) = {
  return none in values.pos()
}

/// Alias for @@n().
#let non = n

/// Tests if none of #arg[values] is equal to #value(none).
///
/// // Tests
/// #test(
///   `not is.not-none(none)`,
///   `is.not-none("a")`,
///   `not is.not-none(1, false, none, "none")`,
///   `is.not-none(1, false, "none")`
/// )
///
/// - ..values (any): Values to test.
/// -> boolean
#let not-none( ..values ) = {
  return none not in values.pos()
}

/// Alias for @@not-none()
#let not-n = not-none


/// Tests, if at least one value in #arg[values] is not equal to
/// #value(none).
///
/// Useful for checking mutliple optional arguments for a
/// valid value:
/// ```typ
/// #if is.one-not-none(..args.pos()) [
///   #args.pos().find(is.not-none)
/// ]
/// ```
///
/// // Tests
/// #test(
///   `is.one-not-none(false)`,
///   `not is.one-not-none(none)`,
///   `is.one-not-none(none, none, none, 2, "none", none)`,
///   `is.one-not-none(1, 2, 3, "none")`,
///   `not is.one-not-none(none, none, none)`
/// )
///
/// - ..values (any): Values to test.
/// -> boolean
#let one-not-none( ..values ) = {
  return values.pos().any((v) => v != none)
}

/// Tests if any one of #arg[values] is equal to #value(auto).
///
/// // Tests
/// #test(
///   `is.a(auto)`,
///   `not is.a("auto")`,
///   `is.a(1, false, auto, "auto")`,
///   `not is.a(1, false, "auto")`
/// )
///
/// - ..values (any): Values to test.
/// -> boolean
#let a( ..values ) = {
  return auto in values.pos()
}
/// Alias for @@a()
#let aut = a

/// Tests if none of #arg[values] is equal to #value(auto).
///
/// // Tests
/// #test(
///   `not is.not-auto(auto)`,
///   `is.not-auto("auto")`,
///   `not is.not-auto(1, false, auto, "auto")`,
///   `is.not-auto(1, false, "auto")`
/// )
///
/// - ..values (any): Values to test.
/// -> boolean
#let not-auto( ..values ) = {
  return auto not in values.pos()
}

/// Alias for @@not-auto()
#let not-a = not-auto

/// Tests, if #arg[value] is _empty_.
///
/// A value is considered _empty_ if it is an empty array,
/// dictionary or string, or the value #value(none).
///
/// // Tests
/// #test(
///   `is.empty(none)`,
///   `is.empty(())`,
///   `is.empty((:))`,
///   `is.empty("")`,
///   `not is.empty(auto)`,
///   `not is.empty(" ")`,
///   `not is.empty((none,))`,
/// )
///
/// - value (any): value to test
/// -> boolean
#let empty( value ) = {
  let empty-values = (
    array: (),
    dictionary: (:),
    string: "",
    content: []
  )

  let t = str(type(value))
  if t in empty-values {
    return value == empty-values.at(t)
  } else {
    return value == none
  }
}

/// Tests, if #arg[value] is not _empty_.
///
/// See @@empty() for an explanation what _empty_ means.
///
/// // Tests
/// #test(
///   `not is.not-empty(none)`,
///   `not is.not-empty(())`,
///   `not is.not-empty((:))`,
///   `not is.not-empty("")`,
///   `is.not-empty(auto)`,
///   `is.not-empty(" ")`,
///   `is.not-empty((none,))`,
/// )
///
/// - value (any): value to test
/// -> boolean
#let not-empty( value ) = {
  let empty-values = (
    array: (),
    dictionary: (:),
    string: "",
    content: []
  )

  let t = str(type(value))
  if t in empty-values {
    return value != empty-values.at(t)
  } else {
    return value != none
  }
}

/// Tests, if #arg[value] is not _empty_.
///
/// See @@empty() for an explanation what _empty_ means.
///
/// // Tests
/// #test(
///   `is.any(2, 2)`,
///   `is.any(auto, auto)`,
///   `is.any(1, 2, 3, 4, 2)`,
///   `is.any(1, 2, none, 4, none)`,
///   `not is.any(1, 2, 3, 4, 5)`,
///   `not is.any(1, 2, 3, 4, none)`,
/// )
///
/// - value (any): value to test
/// -> boolean
#let any( ..compare, value ) = {
  // return compare.pos().any((v) => v == value)
  return value in compare.pos()
}

/// Tests if #arg[value] is not equals to any one of the
/// other passed in values.
///
/// // Tests
/// #test(
///   `not is.not-any(2, 2)`,
///   `not is.not-any(auto, auto)`,
///   `not is.not-any(1, 2, 3, 4, 2)`,
///   `not is.not-any(1, 2, none, 4, none)`,
///   `is.not-any(1, 2, 3, 4, 5)`,
///   `is.not-any(1, 2, 3, 4, none)`,
/// )
///
/// - ..compare (any): values to compare to
/// - value (any): value to test
/// -> boolean
#let not-any( ..compare, value) = {
  // return not compare.pos().any((v) => v == value)
  return not value in compare.pos()
}

/// Tests if #arg[value] contains all the passed `keys`.
///
/// Either as keys in a dictionary or elements in an array.
/// If #arg[value] is neither of those types, #value(false) is returned.
///
/// // Tests
/// #test(
///   `is.has(4, range(5))`,
///   `not is.has(5, range(5))`,
///   `not is.has(5, 5)`,
///   `is.has("b", (a:1, b:2, c:3))`,
///   `is.has("b", "c", (a:1, b:2, c:3))`,
///   `not is.has("d", (a:1, b:2, c:3))`,
///   `not is.has("a", "d", (a:1, b:2, c:3))`,
/// )
///
/// - ..keys (any): keys or values to look for
/// - value (any): value to test
/// -> boolean
#let has( ..keys, value ) = {
  if type(value) in (dictionary, array) {
    return keys.pos().all((k) => k in value)
  } else {
    return false
  }
}

// =================================
//  Types
// =================================

/// Tests if #arg[value] is of type `t`.
///
/// // Tests
/// #test(
///   `is.type("string", "test")`,
///   `is.type("boolean", false)`,
///   `is.type("length", 1em)`,
///   `not is.type("integer", "test")`,
///   `not is.type("dictionary", false)`,
///   `not is.type("alignment", 1em)`,
/// )
///
/// - t (string): name of the type
/// - value (any): value to test
#let type( t, value ) = alias.type(value) == t

/// Tests if #arg[value] is of type dictionary.
///
/// // Tests
/// #test(
///   `is.dict((a:1, b:2, c:3))`,
///   `is.dict((:))`,
///   `not is.dict(())`,
///   `not is.dict(false)`,
///   `not is.dict(5)`,
/// )
///
/// - value (any): value to test
#let dict( value ) = alias.type(value) == "dictionary"

/// Tests if #arg[value] is of type array.
///
/// // Tests
/// #test(
///   `is.arr(())`,
///   `is.arr((1, 2, 3))`,
///   `is.arr(range(5))`,
///   `not is.arr((:))`,
///   `not is.arr(false)`,
///   `not is.arr(5)`,
/// )
///
/// - value (any): value to test
#let arr( value ) = alias.type(value) == "array"

/// Tests if #arg[value] is of type content.
///
/// // Tests
/// #test(
///   `is.content([])`,
///   `is.content(raw("foo"))`,
///   `not is.content(false)`,
///   `not is.content(1)`,
///   `not is.content(())`,
/// )
///
/// - value (any): value to test
#let content( value ) = alias.type(value) == "content"

/// Tests if #arg[value] is of type label.
///
/// // Tests
/// #test(
///   `is.label(label("one"))`,
///   `is.label(<one>)`,
///   `not is.label(false)`,
///   `not is.label(1)`,
///   `not is.label(())`,
/// )
///
/// - value (any): value to test
#let label( value ) = alias.type(value) == "label"

/// Tests if #arg[value] is of type color.
///
/// // Tests
/// #test(
///   `is.color(red)`,
///   `is.color(rgb(10%,10%,10%))`,
///   `is.color(luma(10%))`,
///   `not is.color(1)`,
///   `not is.color(())`,
/// )
///
/// - value (any): value to test
#let color( value ) = alias.type(value) == "color"

/// Tests if #arg[value] is of type stroke.
///
/// // Tests
/// #test(
///   `is.stroke(red + 1pt)`,
///   `not is.stroke(1)`,
///   `not is.stroke(())`,
/// )
///
/// - value (any): value to test
#let stroke( value ) = alias.type(value) == "stroke"

/// Tests if #arg[value] is of type location.
///
/// // Tests
/// #locate(loc => test(
///   scope: (loc:loc),
///   `is.loc(loc)`,
///   `not is.loc(<a-label>)`,
/// ))
///
/// - value (any): value to test
#let loc( value ) = alias.type(value) == "location"

/// Tests if #arg[value] is of type boolean.
///
/// // Tests
/// #test(
///   `is.bool(true)`,
///   `is.bool(false)`,
///   `not is.bool(1)`,
///   `not is.bool(())`,
/// )
///
/// - value (any): value to test
#let bool( value ) = alias.type(value) == "boolean"

#let str( value ) = alias.type(value) == "string"

#let int( value ) = alias.type(value) == "integer"

#let float( value ) = alias.type(value) == "float"

#let num( value ) = alias.type(value) in ("float", "integer")

#let frac( value ) = alias.type(value) == "fraction"

#let length( value ) = alias.type(value) == "length"

#let rlength( value ) = alias.type(value) == "relative length"

#let ratio( value ) = alias.type(value) == "ratio"

#let angle( value ) = alias.type(value) == "angle"

#let align( value ) = alias.type(value) == "alignment"

#let align2d( value ) = alias.type(value) == "alignment"

#let func( value ) = alias.type(value) == "function"

/// Tests if types #arg[value] is any one of `types`.
///
/// // Tests
/// #test(
///   `is.any-type("string", "integer", 1)`,
///   `is.any-type("string", "integer", "1")`,
///   `not is.any-type("string", "integer", false)`
/// )
///
/// - ..types (string): type names to check against
/// - value (any): value to test
#let any-type( ..types, value ) = {
  return alias.type(value) in types.pos()
}

/// Tests if all passed in values have the same type.
///
/// // Tests
/// #test(
///   `is.same-type(..range(5))`,
///   `is.same-type(true, false)`,
///   `is.same-type(none, none, none)`,
///   `not is.same-type(..range(5), "a")`,
///   `not is.same-type(true, false, auto)`,
///   `not is.same-type(none, none, none, auto)`
/// )
///
/// - ..values (any): Values to test.
#let same-type( ..values ) = {
  let t = alias.type(values.pos().first())
  return values.pos().all((v) => alias.type(v) == t)
}

/// Tests if all of the passed in values have the type `t`.
///
/// // Tests
/// #test(
///   `is.all-of-type("boolean", true, false)`,
///   `is.all-of-type("none", none)`,
///   `is.all-of-type("length", 1pt, 1cm, 1in)`,
///   `not is.all-of-type("boolean", true, false, 1)`,
/// )
///
/// - t (string): type to test against
/// - ..values (any): Values to test.
#let all-of-type( t, ..values ) = values.pos().all((v) => alias.type(v) == t)

/// Tests if none of the passed in values has the type `t`.
///
/// // Tests
/// #test(
///   `not is.none-of-type("boolean", true, false)`,
///   `not is.none-of-type("none", none)`,
///   `is.none-of-type("boolean", 1pt, 1cm, 1in)`,
///   `is.none-of-type("boolean", 1, 1mm, red)`,
/// )
///
/// - t (string): type to test against
/// - ..values (any): Values to test.
#let none-of-type( t, ..values ) = values.pos().all((v) => alias.type(v) != t)

/// Tests if #arg[value] is a content element with `value.func() == func`.
///
/// If `func` is a string, #arg[value] will be compared to `repr(value.func())`, instead.
/// Both of these effectively do the same:
/// ```js
/// #is.elem(raw, some_content)
/// #is.elem("raw", some_content)
/// ```
///
/// // Tests
/// #test(
///   `is.elem(raw, raw("code"))`,
///   `is.elem(table, table())`,
///   `is.elem("table", table())`,
///   `not is.elem(table, grid())`,
///   `not is.elem("table", grid())`,
/// )
///
/// - func (function): element function
/// - value (any): value to test
#let elem( func, value ) = if alias.type(value) == "content" {
  if alias.type(func) == "string" {
    return repr(value.func()) == func
  } else {
    return value.func() == func
  }
} else {
  return false
}

/// Tests if #arg[value] is a sequence of content.
///
/// // Tests
/// #test(
///   `is.sequence([])`,
///   `not is.sequence(grid())`,
///   `is.sequence([
///     a b
///   ])`,
/// )
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
