
#import "test.typ"

// =================================
//  Asserts
// =================================

#let lazy-message(
  user-message,
  ..args,
) = {
  if user-message == none {
    return ""
  }

  let lazy = user-message
  if type(lazy) != "function" {
    lazy = (..) => str(lazy)
  }
  return lazy(..args)
}

/// Asserts that #arg[test] is #value(true).
/// See #doc("foundations/assert").
///
/// - test (boolean): Assertion to test.
/// - message (string,function): A message to show if the assertion fails.
#let that(test, message: "Test returned false, should be true.") = assert(
  test,
  message: lazy-message(message, test),
)

/// Asserts that #arg[test] is #value(false).
///
/// - test (boolean): Assertion to test.
/// - message (string, function): A message to show if the assertion fails.
#let that-not(test, message: "Test returned true, should be false.") = assert(
  not test,
  message: lazy-message(message, test),
)

/// Asserts that two values are equal.
/// See #doc("foundations/assert", name:"assert.eq", anchor:"assert-eq").
///
/// - a (any): First value.
/// - b (any): Second value.
/// - message (string, function): A message to show if the assertion fails.
#let eq(a, b, message: (a, b) => "Value " + repr(a) + " was not equal to " + repr(b)) = assert.eq(
  a,
  b,
  message: lazy-message(message, a, b),
)

/// Asserts that two values are not equal.
/// See #doc("foundations/assert", name:"assert.ne", anchor:"assert-ne").
///
/// - a (any): First value.
/// - b (any): Second value.
/// - message (string, function): A message to show if the assertion fails.
#let ne(a, b, message: (a, b) => "Value " + repr(a) + " was equal to " + repr(b)) = assert.ne(
  a,
  b,
  message: lazy-message(message, a, b),
)

/// Alias for @@ne()
#let neq = assert.ne

/// Asserts that not one of #arg[values] is #value(none).
/// Positional and named arguments are tested if provided.
/// For named key-value pairs the value is tested.
///
/// // Tests
/// #assert.not-none(1)
/// #assert.not-none(..range(4))
///
/// - ..values (any): The values to test.
/// - message (string, function): A message to show if the assertion fails.
#let not-none(
  ..values,
  message: (..a) => "Values should not be none. Got " + repr(a),
) = {
  assert(
    values.pos().all(v => v != none) and values.named().values().all(v => v != none),
    message: lazy-message(message, ..values),
  )
}

/// Assert that #arg[value] is any one of #arg[values].
///
/// Tests
/// #assert.any(..range(4), 3)
///
/// - ..values (any): A set of values to compare #arg[value] to.
/// - value (any): Value to compare.
/// - message (string, function): A message to show if the assertion fails.
#let any(
  ..values,
  value,
  message: (..a) => "Value should be one of " + repr(a.pos().slice(1)) + ". Got " + repr(a.pos().first()),
) = assert(
  value in values.pos(),
  message: lazy-message(message, value, ..values),
)

/// Assert that #arg[value] is not any one of #arg[values].
///
/// // Tests
/// #assert.not-any(none, auto, 3)
///
/// - ..values (any): A set of values to compare `value` to.
/// - value (any): Value to compare.
/// - message (string, function): A message to show if the assertion fails.
#let not-any(
  ..values,
  value,
  message: (..a) => "Value should not be one of " + repr(a.pos().slice(1)) + ". Got " + repr(a.pos().first()),
) = assert(
  value not in values.pos(),
  message: lazy-message(message, value, ..values),
)

/// Assert that #arg[value]s type is any one of #arg[types].
///
/// // Tests
/// #assert.any-type("float", "integer", 3)
/// #assert.any-type("float", "integer", 3.3)
/// #assert.any-type("string", "boolean", true)
/// #assert.any-type("string", "boolean", "foo")
///
/// - ..types (string): A set of types to compare the type of `value` to.
/// - value (any): Value to compare.
/// - message (string, function): A message to show if the assertion fails.
#let any-type(
  ..types,
  value,
  message: (..a) => (
    "Value should have any type of " + repr(a.pos().slice(1)) + ". Got " + repr(a.pos().first()) + " (" + type(
      a.pos().first(),
    ) + ")"
  ),
) = assert(
  type(value) in types.pos(),
  message: lazy-message(message, value, ..types),
)

/// Assert that #arg[value]s type is not any one of #arg[types].
///
/// // Tests
/// #assert.not-any-type("float", "integer", "foo")
/// #assert.not-any-type("string", "boolean", 1%)
///
/// - ..types (string): A set of types to compare the type of `value` to.
/// - value (any): Value to compare.
/// - message (string, function): A message to show if the assertion fails.
#let not-any-type(
  ..types,
  value,
  message: (..a) => (
    "Value should not have any type of " + repr(a.pos().slice(1)) + ". Got " + repr(a.pos().first()) + " (" + type(
      a.pos().first(),
    ) + ")"
  ),
) = assert(
  type(value) not in types.pos(),
  message: lazy-message(message, value, ..types),
)

/// Assert that the types of all #arg[values] are equal to #arg[t].
///
/// // Tests
/// #assert.all-of-type("string", "a", "b")
/// #assert.all-of-type("length", 1pt, 3em, 4mm)
///
/// - t (string): The type to test against.
/// - ..values (any): Values to test.
/// - message (string, function): A message to show if the assertion fails.
#let all-of-type(
  t,
  ..values,
  message: (..a) => (
    "Values need to be of type " + repr(a.pos().first()) + ". Got " + repr(a.pos().slice(1)) + " / " + repr(
      a.pos().slice(1).map(type),
    )
  ),
) = assert(
  values.pos().all(v => std.type(v) == t),
  message: lazy-message(message, t, ..values),
)

/// Assert that none of the #arg[values] are of type #arg[t].
///
/// // Tests
/// #assert.none-of-type("integer", "a", "b", false, 1.2)
/// #assert.none-of-type("string", 1pt, 3%, true)
///
/// - t (string): The type to test against.
/// - ..values (any): Values to test.
/// - message (string, function): A message to show if the assertion fails.
#let none-of-type(
  t,
  ..values,
  message: (..a) => (
    "Values may not be of type " + repr(a.pos().first()) + ". Got " + repr(a.pos().slice(1)) + " / " + repr(
      a.pos().slice(1).map(type),
    )
  ),
) = assert(
  values.pos().all(v => std.type(v) != t),
  message: lazy-message(message, t, ..values),
)

/// Assert that #arg[value] is not _empty_.
///
/// Depends on `test.is-empty()`. See there for an explanation
/// of _empty_.
///
/// // Tests
/// #assert.not-empty("string")
/// #assert.not-empty((1,))
/// #assert.not-empty((a:1))
///
/// - value (any): The value to test.
/// - message (string, function): A message to show if the assertion fails.
#let not-empty(
  value,
  message: (v, ..a) => {
    "Value may not be empty. Got " + repr(v)
  },
) = {
  assert(
    not test.is-empty(value),
    message: lazy-message(message, value),
  )
}

/// Assert that #arg[args] has positional arguments.
///
/// If #arg[n] is a value greater zero, exactly #arg[n]
/// positional arguments are required. Otherwise, at least
/// one argument is required.
/// #sourcecode[```typ
/// #let add(..args) = {
///   assert.has-pos(args)
///   return args.pos().fold(0, (s, v) => s+v)
/// }
/// ```]
///
/// // Tests
/// #let func(n:none, ..args) = {
///   assert.has-pos(n:n, args)
/// }
/// #func(..range(4))
/// #func(n:4, ..range(4))
///
/// - n (integer, none): The mandatory number of positional arguments or #value(none).
/// - args (arguments): The arguments to test.
/// - message (string,function): A message to show if the assertion fails.
#let has-pos(
  n: none,
  args,
  message: (n: none, ..a) => {
    if n == none {
      "At least one positional argument required."
    } else {
      "Exactly " + str(n) + " positional arguments required, got " + repr(a.pos())
    }
  },
) = {
  if n == none {
    assert.ne(args.pos(), (), message: lazy-message(message, n: n, ..args))
  } else {
    assert.eq(args.pos().len(), n, message: lazy-message(message, n: n, ..args))
  }
}

/// Assert that #arg[args] has no positional arguments.
/// #sourcecode[```typ
/// #let new-dict(..args) = {
///   assert.no-pos(args)
///   return args.named()
/// }
/// ```]
///
/// // Tests
/// #let func(..args) = {
///   assert.no-pos(args)
/// }
/// #func(a:1, b:2)
///
/// - args (arguments): The arguments to test.
/// - message (string,function): A message to show if the assertion fails.
#let no-pos(args, message: (..a) => "Unexpected positional arguments: " + repr(a)) = {
  assert.eq(args.pos(), (), message: lazy-message(message, ..args.pos()))
}

/// Assert that #arg[args] has named arguments.
///
/// If #arg[n] is a value greater zero, exactly #arg[n]
/// named arguments are required. Otherwise, at least one
/// argument is required.
///
/// // Tests
/// #let func(names:none, ..args) = {
///   assert.has-named(names:names, args)
/// }
/// #func(a:1, b:2)
/// #func(a:1, b:2, names:("a", "b"))
/// #func(a:1, b:2, c:3, names:("a", "b"))
///
/// - names (array, none): An array with required keys or #value(none).
/// - strict (boolean): If #value(true), only keys in #arg[names] are allowed.
/// - args (arguments): The arguments to test.
/// - message (string, function): A message to show if the assertion fails.
#let has-named(
  names: none,
  strict: false,
  args,
  message: (..a) => {
    let names = a.named().at("names", default: ())
    if names == () {
      "Missing named arguments."
    } else {
      let named = a.named()
      let keys = named.keys()
      names = names.filter(k => k != "names" and k not in keys)
      "Missing named arguments: " + names.join(", ")
    }
  },
) = {
  if names == none {
    assert.ne(args.named(), (:), message: lazy-message(message, names: (), ..args))
  } else {
    if type(names) != "array" {
      names = (names,)
    }
    let keys = args.named().keys()
    assert(names.all(v => v in keys), message: lazy-message(message, names: names, ..args))
  }
}

/// Assert that #arg[args] has no named arguments.
///
/// // Tests
/// #let func(..args) = {
///   assert.no-named(args)
/// }
/// #func(..range(4))
///
/// - args (arguments): The arguments to test.
/// - message (string,function): A message to show if the assertion fails.
#let no-named(args, message: (..a) => "Unexpected named arguments: " + repr(a.named())) = {
  assert.eq(args.named(), (:), message: lazy-message(message, ..args))
}

/// Creates a new assertion from `test`.
///
/// The new assertion will take any number of  `values` and pass them to `test`.
/// `test` should return a `boolean`.
/// #sourcecode[```typ
/// #let assert-numeric = assert.new(t4t.is-num)
///
/// #let diameter(radius) = {
///   assert-numeric(radius)
///   return 2*radius
/// }
/// ```]
///
/// // Tests
/// #let assert-numeric = assert.new(t4t.is-num)
/// #let diameter(radius) = {
///   assert-numeric(radius)
///   return 2*radius
/// }
/// #diameter(4.3)
/// #diameter(2)
///
/// - test (function): A test function: #lambda("..any", ret:true)
#let new(test, message: "") = (..v, message: message) => assert(test(..v), message: lazy-message(message, ..v))
