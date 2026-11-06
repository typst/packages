// =================================
//  Test functions for use in any(),
//  all() or find()
// =================================

/// Creates a new test function, that is #value(true), when #arg[test] is #value(false).
///
/// Can be used to create negations of tests like:
/// #codesnippet[```typ
/// #let not-raw = test.neg(test.raw)
/// ```]
///
/// // Tests
/// #test(
///   scope: (not-raw: test.neg(test.raw)),
///   `not-raw("foo")`,
///   `not not-raw(raw("foo"))`,
///   ```
///   not not-raw(`foo`)
///   ```
/// )
///
/// - test (function, boolean): Test to negate.
/// -> function
#let neg(test) = (
  (..args) => {
    not test(..args)
  }
)

/// Tests if values #arg[compare] and #arg[value] are equal.
///
/// // Tests
/// #test(
///   `test.eq("foo", "foo")`,
///   `not test.eq("foo", "bar")`
/// )
///
/// - compare (any): first value
/// - value (any): second value
/// -> boolean
#let eq(compare, value) = {
  return value == compare
}

/// Tests if #arg[compare] and #arg[value] are not equal.
///
/// // Tests
/// #test(
///   `test.neq(1, 2)`,
///   `test.neq("a", false)`,
///   `not test.neq(1, 1)`,
///   `not test.neq("1", "1")`,
/// )
///
/// - compare (any): First value.
/// - value (any): Second value.
/// -> boolean
#let neq(compare, value) = {
  return value != compare
}

/// Tests, if #arg[value] is _empty_.
///
/// A value is considered _empty_ if it is an empty array,
/// dictionary or string, or the value #value(none).
///
/// // Tests
/// #test(
///   `is-empty(none)`,
///   `is-empty(())`,
///   `is-empty((:))`,
///   `is-empty("")`,
///   `not is-empty(auto)`,
///   `not is-empty(" ")`,
///   `not is-empty((none,))`,
/// )
///
/// - value (any): value to test
/// -> boolean
#let is-empty(value) = {
  let empty-values = (
    array: (),
    dictionary: (:),
    string: "",
    content: [],
  )

  let t = str(type(value))
  if t in empty-values {
    return value == empty-values.at(t)
  } else {
    return value == none
  }
}

/// Tests, if at least one value in #arg[values] is not equal to
/// #value(none).
///
/// Useful for checking mutliple optional arguments for a
/// valid value:
/// ```typ
/// #if test.one-not-none(..args.pos()) [
///   #args.pos().find(test.not-none)
/// ]
/// ```
///
/// // Tests
/// #test(
///   `test.one-not-none(false)`,
///   `not test.one-not-none(none)`,
///   `test.one-not-none(none, none, none, 2, "none", none)`,
///   `test.one-not-none(1, 2, 3, "none")`,
///   `not test.one-not-none(none, none, none)`
/// )
///
/// - ..values (any): Values to test.
/// -> boolean
#let one-not-none(..values) = {
  return values.pos().any(v => v != none)
}

/// Tests, if any value of #sarg[compare] is equal to #arg[value].
///
/// See @@is-empty() for an explanation what _empty_ means.
///
/// // Tests
/// #test(
///   `test.any(2, 2)`,
///   `test.any(auto, auto)`,
///   `test.any(1, 2, 3, 4, 2)`,
///   `test.any(1, 2, none, 4, none)`,
///   `not test.any(1, 2, 3, 4, 5)`,
///   `not test.any(1, 2, 3, 4, none)`,
/// )
///
/// - value (any): value to test
/// -> boolean
#let any(..compare, value) = {
  return value in compare.pos()
}

/// Tests if #arg[value] is not equals to any one of the
/// other passed in values.
///
/// // Tests
/// #test(
///   `not test.not-any(2, 2)`,
///   `not test.not-any(auto, auto)`,
///   `not test.not-any(1, 2, 3, 4, 2)`,
///   `not test.not-any(1, 2, none, 4, none)`,
///   `test.not-any(1, 2, 3, 4, 5)`,
///   `test.not-any(1, 2, 3, 4, none)`,
/// )
///
/// - ..compare (any): values to compare to
/// - value (any): value to test
/// -> boolean
#let not-any(..compare, value) = {
  return not value in compare.pos()
}

/// Tests if #arg[value] contains all the passed #sarg[keys].
///
/// Either as keys in a dictionary or elements in an array.
/// If #arg[value] is neither of those types, #value(false) is returned.
///
/// // Tests
/// #test(
///   `test.has(4, range(5))`,
///   `not test.has(5, range(5))`,
///   `not test.has(5, 5)`,
///   `test.has("b", (a:1, b:2, c:3))`,
///   `test.has("b", "c", (a:1, b:2, c:3))`,
///   `not test.has("d", (a:1, b:2, c:3))`,
///   `not test.has("a", "d", (a:1, b:2, c:3))`,
/// )
///
/// - ..keys (any): keys or values to look for
/// - value (any): value to test
/// -> boolean
#let has(..keys, value) = {
  if type(value) in (dictionary, array) {
    return keys.pos().all(k => k in value)
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
///   `test.is-type("string", "test")`,
///   `test.is-type("boolean", false)`,
///   `test.is-type("length", 1em)`,
///   `not test.is-type("integer", "test")`,
///   `not test.is-type("dictionary", false)`,
///   `not test.is-type("alignment", 1em)`,
/// )
///
/// - t (string): name of the type
/// - value (any): value to test
#let is-type(t, value) = std.type(value) == t

/// Tests if types #arg[value] is any one of `types`.
///
/// // Tests
/// #test(
///   `test.any-type("string", "integer", 1)`,
///   `test.any-type("string", "integer", "1")`,
///   `not test.any-type("string", "integer", false)`
/// )
///
/// - ..types (string): type names to check against
/// - value (any): value to test
#let any-type(..types, value) = {
  return std.type(value) in types.pos()
}

/// Tests if all passed in values have the same type.
///
/// // Tests
/// #test(
///   `test.same-type(..range(5))`,
///   `test.same-type(true, false)`,
///   `test.same-type(none, none, none)`,
///   `not test.same-type(..range(5), "a")`,
///   `not test.same-type(true, false, auto)`,
///   `not test.same-type(none, none, none, auto)`
/// )
///
/// - ..values (any): Values to test.
#let same-type(..values) = {
  let t = std.type(values.pos().first())
  return values.pos().all(v => std.type(v) == t)
}

/// Tests if all of the passed in values have the type `t`.
///
/// // Tests
/// #test(
///   `test.all-of-type("boolean", true, false)`,
///   `test.all-of-type("none", none)`,
///   `test.all-of-type("length", 1pt, 1cm, 1in)`,
///   `not test.all-of-type("boolean", true, false, 1)`,
/// )
///
/// - t (string): type to test against
/// - ..values (any): Values to test.
#let all-of-type(t, ..values) = values.pos().all(v => std.type(v) == t)

/// Tests if none of the passed in values has the type `t`.
///
/// // Tests
/// #test(
///   `not test.none-of-type("boolean", true, false)`,
///   `not test.none-of-type("none", none)`,
///   `test.none-of-type("boolean", 1pt, 1cm, 1in)`,
///   `test.none-of-type("boolean", 1, 1mm, red)`,
/// )
///
/// - t (string): type to test against
/// - ..values (any): Values to test.
#let none-of-type(t, ..values) = values.pos().all(v => std.type(v) != t)

/// Tests if #arg[value] is a content element with `value.func() == func`.
///
/// If `func` is a string, #arg[value] will be compared to `repr(value.func())`, instead.
/// Both of these effectively do the same:
/// ```js
/// #test.is-elem(raw, some_content)
/// #test.is-elem("raw", some_content)
/// ```
///
/// // Tests
/// #test(
///   `test.is-elem(raw, raw("code"))`,
///   `test.is-elem(table, table())`,
///   `test.is-elem("table", table())`,
///   `not test.is-elem(table, grid())`,
///   `not test.is-elem("table", grid())`,
/// )
///
/// - func (function): element function
/// - value (any): value to test
#let is-elem(func, value) = if std.type(value) == content {
  if std.type(func) == "string" {
    return repr(value.func()) == func
  } else {
    return value.func() == func
  }
} else {
  return false
}

/// Tests if #arg[value] is a `sequence` of content.
///
/// // Tests
/// #test(
///   `test.is-sequence([])`,
///   `not test.is-sequence(grid())`,
///   `test.is-sequence([
///     a b
///   ])`,
/// )
#let is-sequence(value) = if std.type(value) == content {
  return repr(value.func()) == "sequence"
} else {
  return false
}

#let is-raw(value) = if std.type(value) == content {
  return value.func() == std.raw
} else {
  return false
}

#let is-table(value) = if std.type(value) == content {
  return value.func() == std.table
} else {
  return false
}

#let is-list(value) = if std.type(value) == content {
  return value.func() == std.list
} else {
  return false
}

#let is-enum(value) = if std.type(value) == content {
  return value.func() == std.enum
} else {
  return false
}

#let is-terms(value) = if std.type(value) == content {
  return value.func() == std.terms
} else {
  return false
}

#let is-cols(value) = if std.type(value) == content {
  return value.func() == std.columns
} else {
  return false
}

#let is-grid(value) = if std.type(value) == content {
  return value.func() == std.grid
} else {
  return false
}

#let is-stack(value) = if std.type(value) == content {
  return value.func() == std.stack
} else {
  return false
}
