#import "test.typ": is-empty
#import "def-compat.typ" as compat

// =================================
//  Get default values
// =================================

/// Returns #arg[default] if #arg[test] is #value(true), #arg[value] otherwise.
///
/// If #arg[test] is #value(false) and #arg[do] is set to a function,
/// #arg[value] is passed to #arg[do], before being returned.
///
/// // Tests
/// #utest(
///   `def.if-true(1 == 1, 2, def:3) == 3`,
///   `def.if-true(1 == 2, 2, def:3) == 2`,
///   `def.if-true(1 == 2, 2, def:3, do: (n) => n+1) == 3`,
///   `def.if-true(1 == 1, 2, def:3, do: (n) => n+1) == 3`,
/// )
///
/// - test (boolean): A test result.
/// - value (any): The value to test.
/// - def (any): The default value.
/// - do (function): Post-processor for #arg[value]: #lambda("any", ret:"any")
#let if-true(test, value, def: none, do: none) = if test {
  return def
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
/// #utest(
///   `def.if-false(1 == 1, 2, def:3) == 2`,
///   `def.if-false(1 == 2, 2, def:3) == 3`,
///   `def.if-false(1 == 1, 2, def:3, do: (n) => n+1) == 3`,
///   `def.if-false(1 == 2, 2, def:3, do: (n) => n+1) == 3`,
/// )
///
/// - test (boolean): A test result.
/// - value (any): The value to test.
/// - def (any): The default value.
/// - do (function): Post-processor for #arg[value]: #lambda("any", ret:"any")
#let if-false(test, value, def: none, do: none) = if not test {
  return def
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
/// #utest(
///   `def.if-none(none, def:auto) == auto`,
///   `def.if-none(5, def:auto) == 5`,
///   `def.if-none(none, def:auto, do: (v) => v*1cm) == auto`,
///   `def.if-none(5, def:auto, do: (v) => v*1cm) == 5cm`,
/// )
///
/// - value (any): The value to test.
/// - def (any): The default value.
/// - do (function): Post-processor for #arg[value]: #lambda("any", ret:"any")
#let if-none(value, def: none, do: none) = if value == none {
  return def
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
/// #utest(
///   `def.if-auto(auto, def:none) == none`,
///   `def.if-auto(5, def:1mm) == 5`,
///   `def.if-auto(auto, def:1mm, do: (v) => v*1cm) == 1mm`,
///   `def.if-auto(5, def:1mm, do: (v) => v*1cm) == 5cm`,
/// )
///
/// - value (any): The value to test.
/// - def (any): A default value.
/// - do (function): Post-processor for #arg[value]: #lambda("any", ret:"any")
#let if-auto(value, def: none, do: none) = if value == auto {
  return def
} else if do == none {
  return value
} else {
  return do(value)
}

/// Returns #arg[def] if #arg[value] is equal to any value in `compare`, #arg[value] otherwise.
///
/// ```typ
/// #def.if-any(
///   thickness,      // value
///   none, auto,     // ..compare
///   def: 1pt,       // default
/// )
/// ```
///
/// If #arg[value] is in `compare` and #arg[do] is set to a function,
/// #arg[value] is passed to #arg[do], before being returned.
///
/// // Tests
/// #utest(
///   `def.if-any(none, none, auto, def:1pt) == 1pt`,
///   `def.if-any(auto, none, auto, def:1pt) == 1pt`,
///   `def.if-any(2pt, none, auto, def:1pt) == 2pt`,
///   `def.if-any(2pt, none, auto, def:1pt, do:(v)=>3mm) == 3mm`,
///   `def.if-any(none, none, auto, def:1pt, do:(v)=>3mm) == 1pt`,
/// )
///
/// - value (any): value to test
/// - ..compare (any): list of values to compare #arg[value] to
/// - def (any): The default value.
/// - do (function): Post-processor for #arg[value]: #lambda("any", ret:"any")
#let if-any(value, ..compare, def: none, do: none) = if value in compare.pos() {
  return def
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
/// #utest(
///   `def.if-auto(def:none, auto) == none`,
///   `def.if-auto(def:1mm, 5) == 5`,
///   `def.if-auto(def:1mm, auto, do: (v) => 1cm) == 1mm`,
///   `def.if-auto(def:1mm, 5, do: (v) => v*1cm) == 5cm`,
/// )
///
/// - value (any): value to test
/// - ..compare (any): list of values to compare #arg[value] to
/// - def (any): The default value.
/// - do (function): Post-processor for #arg[value]: #lambda("any", ret:"any")
#let if-not-any(value, ..compare, def: none, do: none) = if value not in compare.pos() {
  return def
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
/// Depends on `t4t.is-empty()`. See there for an explanation
/// of _empty_.
///
/// // Tests
/// #utest(
///   `def.if-empty(def:"a", "") == "a"`,
///   `def.if-empty(def:"a", none) == "a"`,
///   `def.if-empty(def:"a", ()) == "a"`,
///   `def.if-empty(def:"a", (:)) == "a"`,
/// )
///
/// - value (any): value to test
/// - def (any): The default value.
/// - do (function): Post-processor for #arg[value]: #lambda("any", ret:"any")
#let if-empty(value, def: none, do: none) = if is-empty(value) {
  return def
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
/// #utest(
///   scope: (fun: (..args) => def.if-arg("width", args, def:100%)),
///   `fun(a:1, b:2, c:30%) == 100%`,
///   `fun(a:1, b:2, width:30%) == 30%`,
/// )
///
/// - key (any): key to look for
/// - def (any): The default value.
/// - do (function): Post-processor for #arg[value]: #lambda("any", ret:"any")
/// - args (arguments): arguments to test
#let if-arg(key, def: none, do: none, args) = if key not in args.named() {
  return def
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
/// #utest(
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

