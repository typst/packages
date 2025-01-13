
#import "test.typ": is-empty

// =================================
//  Get default values
// =================================

/// Returns #arg[default] if #arg[test] is #value(true), #arg[value] otherwise.
///
/// If #arg[test] is #value(false) and #arg[do] is set to a function,
/// #arg[value] is passed to #arg[do], before being returned.
///
/// // Tests
/// #test(
///   `def.if-true(1 == 1, 2, 3) == 2`,
///   `def.if-true(1 == 2, 2, 3) == 3`,
///   `def.if-true(1 == 2, 2, 3, do: (n) => n+1) == 4`,
///   `def.if-true(1 == 1, 2, 3, do: (n) => n+1) == 2`,
/// )
///
/// - test (boolean): A test result.
/// - default (any): A default value.
/// - do (function): Post-processor for #arg[value]: #lambda("any", ret:"any")
/// - value (any): The value to test.
#let if-true(test, default, do: none, value) = if test {
  return default
} else if do == none {
  return value
} else {
  return do(value)
}

/// Returns #arg[default] if #arg[test] is #value(false), #arg[value] otherwise.
///
/// If #arg[test] is #value(true) and #arg[do] is set to a function,
/// #arg[value] is passed to #arg[do], before being returned.
///
/// // Tests
/// #test(
///   `def.if-false(1 == 1, 2, 3) == 3`,
///   `def.if-false(1 == 2, 2, 3) == 2`,
///   `def.if-false(1 == 1, 2, 3, do: (n) => n+1) == 4`,
///   `def.if-false(1 == 2, 2, 3, do: (n) => n+1) == 2`,
/// )
///
/// - test (boolean): A test result.
/// - default (any): A default value.
/// - do (function): Post-processor for #arg[value]: #lambda("any", ret:"any")
/// - value (any): The value to test.
#let if-false(test, default, do: none, value) = if not test {
  return default
} else if do == none {
  return value
} else {
  return do(value)
}

/// Returns #arg[default] if #arg[value] is #value(none), #arg[value] otherwise.
///
/// If #arg[value] is not #value(none) and #arg[do] is set to a function,
/// #arg[value] is passed to #arg[do], before being returned.
///
/// // Tests
/// #test(
///   `def.if-none(auto, none) == auto`,
///   `def.if-none(auto, 5) == 5`,
///   `def.if-none(auto, none, do: (v) => 1cm) == auto`,
///   `def.if-none(auto, 5, do: (v) => v*1cm) == 5cm`,
/// )
///
/// - default (any): A default value.
/// - do (function): Post-processor for #arg[value]: #lambda("any", ret:"any")
/// - value (any): The value to test.
#let if-none(default, do: none, value) = if value == none {
  return default
} else if do == none {
  return value
} else {
  return do(value)
}

/// Returns #arg[default] if #arg[value] is #value(auto), #arg[value] otherwise.
///
/// If #arg[value] is not #value(auto) and #arg[do] is set to a function,
/// #arg[value] is passed to #arg[do], before being returned.
///
/// // Tests
/// #test(
///   `def.if-auto(none, auto) == none`,
///   `def.if-auto(1mm, 5) == 5`,
///   `def.if-auto(1mm, auto, do: (v) => 1cm) == 1mm`,
///   `def.if-auto(1mm, 5, do: (v) => v*1cm) == 5cm`,
/// )
///
/// - default (any): A default value.
/// - do (function): Post-processor for #arg[value]: #lambda("any", ret:"any")
/// - value (any): The value to test.
#let if-auto(default, do: none, value) = if value == auto {
  return default
} else if do == none {
  return value
} else {
  return do(value)
}

/// Returns #arg[default] if #arg[value] is equal to any value in `compare`, #arg[value] otherwise.
///
/// ```typ
/// #def.if-any(
///   none, auto,     // ..compare
///   1pt,            // default
///   thickness       // value
/// )
/// ```
///
/// If #arg[value] is in `compare` and #arg[do] is set to a function,
/// #arg[value] is passed to #arg[do], before being returned.
///
/// // Tests
/// #test(
///   `def.if-any(none, auto, 1pt, none) == 1pt`,
///   `def.if-any(none, auto, 1pt, auto) == 1pt`,
///   `def.if-any(none, auto, 1pt, 2pt) == 2pt`,
///   `def.if-any(none, auto, 1pt, 2pt, do:(v)=>3mm) == 3mm`,
///   `def.if-any(none, auto, 1pt, none, do:(v)=>3mm) == 1pt`,
/// )
///
/// - ..compare (any): list of values to compare #arg[value] to
/// - default (any): A default value.
/// - do (function): Post-processor for #arg[value]: #lambda("any", ret:"any")
/// - value (any): value to test
#let if-any(..compare, default, do: none, value) = if value in compare.pos() {
  return default
} else if do == none {
  return value
} else {
  return do(value)
}

/// Returns #arg[default] if #arg[value] is not equal to any value in `compare`, #arg[value] otherwise.
///
/// ```typ
/// #def.if-not-any(
///   left, right, top, bottom,   // ..compare
///   left,                       // default
///   position                    // value
/// )
/// ```
///
/// If #arg[value] is in `compare` and #arg[do] is set to a function,
/// #arg[value] is passed to #arg[do], before being returned.
///
/// // Tests
/// #test(
///   `def.if-auto(none, auto) == none`,
///   `def.if-auto(1mm, 5) == 5`,
///   `def.if-auto(1mm, auto, do: (v) => 1cm) == 1mm`,
///   `def.if-auto(1mm, 5, do: (v) => v*1cm) == 5cm`,
/// )
///
/// - ..compare (any): list of values to compare #arg[value] to
/// - default (any): A default value.
/// - do (function): Post-processor for #arg[value]: #lambda("any", ret:"any")
/// - value (any): value to test
#let if-not-any(..compare, default, do: none, value) = if value not in compare.pos() {
  return default
} else if do == none {
  return value
} else {
  return do(value)
}

/// Returns #arg[default] if #arg[value] is empty, #arg[value] otherwise.
///
/// If #arg[value] is not empty and #arg[do] is set to a function,
/// #arg[value] is passed to #arg[do], before being returned.
///
/// Depends on `is.empty()`. See there for an explanation
/// of _empty_.
///
/// // Tests
/// #test(
///   `def.if-empty("a", "") == "a"`,
///   `def.if-empty("a", none) == "a"`,
///   `def.if-empty("a", ()) == "a"`,
///   `def.if-empty("a", (:)) == "a"`,
/// )
///
/// - default (any): A default value.
/// - do (function): Post-processor for #arg[value]: #lambda("any", ret:"any")
/// - value (any): value to test
#let if-empty(default, do: none, value) = if is-empty(value) {
  return default
} else if do == none {
  return value
} else {
  return do(value)
}

/// Returns #arg[default] if `key` is not an existing key in `args.named()`, `args.named().at(key)` otherwise.
///
/// If #arg[value] is not in `args` and #arg[do] is set to a function,
/// the value is passed to #arg[do], before being returned.
///
/// // Tests
/// #test(
///   scope: (fun: (..args) => def.if-arg(100%, args, "width")),
///   `fun(a:1, b:2, c:30%) == 100%`,
///   `fun(a:1, b:2, width:30%) == 30%`,
/// )
///
/// - default (any): A default value.
/// - do (function): Post-processor for #arg[value]: #lambda("any", ret:"any")
/// - args (any): arguments to test
/// - key (any): key to look for
#let if-arg(default, do: none, args, key) = if key not in args.named() {
  return default
} else if do == none {
  args.named().at(key)
} else {
  do(args.named().at(key))
}

/// Always returns an array containing all `values`.
/// Any arrays in #arg[values] are unpacked into the resulting
/// array.
///
/// This is useful for arguments, that can have one element
/// or an array of elements:
/// ```typ
/// #def.as-arr(author).join(", ")
/// ```
///
/// // Tests
/// #test(
///   `def.as-arr("a") == ("a",)`,
///   `def.as-arr(("a",)) == ("a",)`,
///   `def.as-arr("a", "b", "c") == ("a", "b", "c")`,
///   `def.as-arr(("a", "b"), "c") == ("a", "b", "c")`,
///   `def.as-arr(("a", "b", "c")) == ("a", "b", "c")`,
///   `def.as-arr(("a",), ("b",), "c") == ("a", "b", "c")`,
///   `def.as-arr(("a",), (("b",), "c")) == ("a", ("b", ), "c")`,
/// )
#let as-arr(..values) = values.pos().fold(
  (),
  (arr, v) => {
    if type(v) == "array" {
      arr += v
    } else {
      arr.push(v)
    }
    arr
  },
)

