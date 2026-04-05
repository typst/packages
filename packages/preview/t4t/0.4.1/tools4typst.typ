

#import "def.typ"
#import "assert.typ"

#import "get.typ"
#import "math.typ"


#import "test.typ"

/// Tests if any one of #arg[values] is equal to #value(none).
///
/// // Tests
/// #utest(
///   `t4t.is-none(none)`,
///   `not t4t.is-none("a")`,
///   `t4t.is-none(1, false, none, "none")`,
///   `not t4t.is-none(1, false, "none")`
/// )
///
/// - ..values (any): Values to test.
/// -> boolean
#let is-none(..values) = {
  return none in values.pos()
}

/// Tests if none of #arg[values] is equal to #value(none).
///
/// // Tests
/// #utest(
///   `not not-none(none)`,
///   `t4t.not-none("a")`,
///   `not not-none(1, false, none, "none")`,
///   `t4t.not-none(1, false, "none")`
/// )
///
/// - ..values (any): Values to test.
/// -> boolean
#let not-none(..values) = {
  return none not in values.pos()
}

/// Tests if any one of #arg[values] is equal to #value(auto).
///
/// // Tests
/// #utest(
///   `t4t.is-auto(auto)`,
///   `not t4t.is-auto("a")`,
///   `t4t.is-auto(1, false, auto, "auto")`,
///   `not t4t.is-auto(1, false, "auto")`
/// )
///
/// - ..values (any): Values to test.
/// -> boolean
#let is-auto(..values) = {
  return auto in values.pos()
}

/// Tests if none of #arg[values] is equal to #value(auto).
///
/// // Tests
/// #utest(
///   `not not-auto(auto)`,
///   `t4t.not-auto("a")`,
///   `not not-auto(1, false, auto, "auto")`,
///   `t4t.not-auto(1, false, "auto")`
/// )
///
/// - ..values (any): Values to test.
/// -> boolean
#let not-auto(..values) = {
  return auto not in values.pos()
}

/// Tests, if #arg[value] is _empty_.
///
/// A value is considered _empty_ if it is an empty array,
/// dictionary or string, or the value #value(none).
///
/// // Tests
/// #utest(
///   `t4t.is-empty(none)`,
///   `t4t.is-empty(())`,
///   `t4t.is-empty((:))`,
///   `t4t.is-empty("")`,
///   `not t4t.is-empty(auto)`,
///   `not t4t.is-empty(" ")`,
///   `not t4t.is-empty((none,))`,
/// )
///
/// - value (any): value to test
/// -> boolean
#let is-empty = test.is-empty

/// Tests, if #arg[value] is not _empty_.
///
/// See @@empty() for an explanation what _empty_ means.
///
/// // Tests
/// #utest(
///   `not not-empty(none)`,
///   `not not-empty(())`,
///   `not not-empty((:))`,
///   `not not-empty("")`,
///   `t4t.not-empty(auto)`,
///   `t4t.not-empty(" ")`,
///   `t4t.not-empty((none,))`,
/// )
///
/// - value (any): value to test
/// -> boolean
#let not-empty(value) = not is-empty(value)

/// Tests if #arg[value] is of type dictionary.
///
/// // Tests
/// #utest(
///   `t4t.is-dict((a:1, b:2, c:3))`,
///   `t4t.is-dict((:))`,
///   `not t4t.is-dict(())`,
///   `not t4t.is-dict(false)`,
///   `not t4t.is-dict(5)`,
/// )
///
/// - value (any): value to test
#let is-dict(value) = std.type(value) == dictionary

/// Tests if #arg[value] is of type array.
///
/// // Tests
/// #utest(
///   `t4t.is-arr(())`,
///   `t4t.is-arr((1, 2, 3))`,
///   `t4t.is-arr(range(5))`,
///   `not t4t.is-arr((:))`,
///   `not t4t.is-arr(false)`,
///   `not t4t.is-arr(5)`,
/// )
///
/// - value (any): value to test
#let is-arr(value) = std.type(value) == array

/// Tests if #arg[value] is of type content.
///
/// // Tests
/// #utest(
///   `t4t.is-content([])`,
///   `t4t.is-content(raw("foo"))`,
///   `not t4t.is-content(false)`,
///   `not t4t.is-content(1)`,
///   `not t4t.is-content(())`,
/// )
///
/// - value (any): value to test
#let is-content(value) = std.type(value) == content

/// Tests if #arg[value] is of type label.
///
/// // Tests
/// #utest(
///   `t4t.is-label(label("one"))`,
///   `t4t.is-label(<one>)`,
///   `not t4t.is-label(false)`,
///   `not t4t.is-label(1)`,
///   `not t4t.is-label(())`,
/// )
///
/// - value (any): value to test
#let is-label(value) = std.type(value) == label

/// Tests if #arg[value] is of type color.
///
/// // Tests
/// #utest(
///   `t4t.is-color(red)`,
///   `t4t.is-color(rgb(10%,10%,10%))`,
///   `t4t.is-color(luma(10%))`,
///   `not t4t.is-color(1)`,
///   `not t4t.is-color(())`,
/// )
///
/// - value (any): value to test
#let is-color(value) = std.type(value) == color

/// Tests if #arg[value] is of type stroke.
///
/// // Tests
/// #utest(
///   `t4t.is-stroke(red + 1pt)`,
///   `not t4t.is-stroke(1)`,
///   `not t4t.is-stroke(())`,
/// )
///
/// - value (any): value to test
#let is-stroke(value) = std.type(value) == stroke

/// Tests if #arg[value] is of type location.
///
/// // Tests
/// #locate(loc => test(
///   scope: (loc:loc),
///   `t4t.is-loc(loc)`,
///   `not t4t.is-loc(<a-label>)`,
/// ))
///
/// - value (any): value to test
#let is-loc(value) = std.type(value) == location

/// Tests if #arg[value] is of type boolean.
///
/// // Tests
/// #utest(
///   `t4t.is-bool(true)`,
///   `t4t.is-bool(false)`,
///   `not t4t.is-bool(1)`,
///   `not t4t.is-bool(())`,
/// )
///
/// - value (any): value to test
#let is-bool(value) = std.type(value) == bool
#let is-str(value) = std.type(value) == str
#let is-int(value) = std.type(value) == "integer"
#let is-float(value) = std.type(value) == "float"
#let is-num(value) = std.type(value) in ("float", "integer")
#let is-frac(value) = std.type(value) == "fraction"
#let is-length(value) = std.type(value) == "length"
#let is-rlength(value) = std.type(value) == "relative length"
#let is-ratio(value) = std.type(value) == "ratio"
#let is-angle(value) = std.type(value) == "angle"
#let is-align(value) = std.type(value) == alignment
#let is-align2d(value) = std.type(value) == alignment
#let is-func(value) = std.type(value) == "function"
