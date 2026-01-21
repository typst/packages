

#import "def.typ"
#import "assert.typ"

#import "get.typ"
#import "math.typ"


#import "test.typ"

/// Tests if any one of #arg[values] is equal to #value(none).
///
/// // Tests
/// #test(
///   `is-none(none)`,
///   `not is-none("a")`,
///   `is-none(1, false, none, "none")`,
///   `not is-none(1, false, "none")`
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
/// #test(
///   `not not-none(none)`,
///   `not-none("a")`,
///   `not not-none(1, false, none, "none")`,
///   `not-none(1, false, "none")`
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
/// #test(
///   `is-auto(auto)`,
///   `not is-auto("a")`,
///   `is-auto(1, false, auto, "auto")`,
///   `not is-auto(1, false, "auto")`
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
/// #test(
///   `not not-auto(auto)`,
///   `not-auto("a")`,
///   `not not-auto(1, false, auto, "auto")`,
///   `not-auto(1, false, "auto")`
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
#let is-empty = test.is-empty

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
#let not-empty(value) = not is-empty(value)

/// Tests if #arg[value] is of type dictionary.
///
/// // Tests
/// #test(
///   `is-dict((a:1, b:2, c:3))`,
///   `is-dict((:))`,
///   `not is-dict(())`,
///   `not is-dict(false)`,
///   `not is-dict(5)`,
/// )
///
/// - value (any): value to test
#let is-dict(value) = std.type(value) == dictionary

/// Tests if #arg[value] is of type array.
///
/// // Tests
/// #test(
///   `is-arr(())`,
///   `is-arr((1, 2, 3))`,
///   `is-arr(range(5))`,
///   `not is-arr((:))`,
///   `not is-arr(false)`,
///   `not is-arr(5)`,
/// )
///
/// - value (any): value to test
#let is-arr(value) = std.type(value) == array

/// Tests if #arg[value] is of type content.
///
/// // Tests
/// #test(
///   `is-content([])`,
///   `is-content(raw("foo"))`,
///   `not is-content(false)`,
///   `not is-content(1)`,
///   `not is-content(())`,
/// )
///
/// - value (any): value to test
#let is-content(value) = std.type(value) == content

/// Tests if #arg[value] is of type label.
///
/// // Tests
/// #test(
///   `is-label(label("one"))`,
///   `is-label(<one>)`,
///   `not is-label(false)`,
///   `not is-label(1)`,
///   `not is-label(())`,
/// )
///
/// - value (any): value to test
#let is-label(value) = std.type(value) == label

/// Tests if #arg[value] is of type color.
///
/// // Tests
/// #test(
///   `is-color(red)`,
///   `is-color(rgb(10%,10%,10%))`,
///   `is-color(luma(10%))`,
///   `not is-color(1)`,
///   `not is-color(())`,
/// )
///
/// - value (any): value to test
#let is-color(value) = std.type(value) == color

/// Tests if #arg[value] is of type stroke.
///
/// // Tests
/// #test(
///   `is-stroke(red + 1pt)`,
///   `not is-stroke(1)`,
///   `not is-stroke(())`,
/// )
///
/// - value (any): value to test
#let is-stroke(value) = std.type(value) == stroke

/// Tests if #arg[value] is of type location.
///
/// // Tests
/// #locate(loc => test(
///   scope: (loc:loc),
///   `is-loc(loc)`,
///   `not is-loc(<a-label>)`,
/// ))
///
/// - value (any): value to test
#let is-loc(value) = std.type(value) == location

/// Tests if #arg[value] is of type boolean.
///
/// // Tests
/// #test(
///   `is-bool(true)`,
///   `is-bool(false)`,
///   `not is-bool(1)`,
///   `not is-bool(())`,
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
