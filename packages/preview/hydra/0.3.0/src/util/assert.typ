#import "/src/util/core.typ" as _core
#import "/src/util/queryable-functions.typ": queryable-functions as _queryable-functions

/// Assert that `value` is any of the given `expected-values`.
///
/// - name (str): The name use for the value in the assertion message.
/// - value (any): The value to check for.
/// - message (str, auto): The assertion message to use.
/// - ..expected-values (type): The expected variants of `value`.
#let enum(name, value, ..expected-values, message: auto) = {
  expected-values = expected-values.pos()
  let message = _core.or-default(check: auto, message, () => if expected-values.len() == 1 {
    _core.fmt("`{}` must be `{}`, was `{}`", name, expected-values.first(), value)
  } else {
    _core.fmt(
      "`{}` must be one of {}, was `{}`",
      name,
      expected-values.map(_core.fmt.with("`{}`")).join(", ", last: " or "),
      value,
    )
  })

  assert(value in expected-values, message: message)
}

/// Assert that `value` is of any of the given `expected-types`.
///
/// - name (str): The name use for the value in the assertion message.
/// - value (any): The value to check for.
/// - message (str, auto): The assertion message to use.
/// - ..expected-types (type): The expected types of `value`.
#let types(name, value, ..expected-types, message: auto) = {
  let given-type = type(value)
  expected-types = expected-types.pos().map(t => if t == none {
    type(none)
  } else if t == auto {
    type(auto)
  } else {
    t
  })
  let message = _core.or-default(check: auto, message, () => if expected-types.len() == 1 {
    _core.fmt("`{}` must be a `{}`, was `{}`", name, expected-types.first(), given-type)
  } else {
    _core.fmt(
      "`{}` must be one of a {}, was `{}`",
      name,
      expected-types.map(_core.fmt.with("`{}`")).join(", ", last: " or "),
      given-type,
    )
  })

  assert(given-type in expected-types, message: message)
}

/// Assert that `element` is an element creatd by one of the given `expected-funcs`.
///
/// - name (str): The name use for the value in the assertion message.
/// - element (any): The value to check for.
/// - message (str, auto): The assertion message to use.
/// - ..expected-funcs (type): The expected element functions of `element`.
#let element(name, element, ..expected-funcs, message: auto) = {
  let given-func = element.func()
  expected-funcs = expected-funcs.pos()
  let message = _core.or-default(check: auto, message, () => if expected-funcs.len() == 1 {
    _core.fmt("`{}` must be a `{}`, was `{}`", name, expected-funcs.first(), given-type)
  } else {
    _core.fmt(
      "`{}` must be one of a {}, was `{}`",
      name,
      expected-funcs.map(_core.fmt.with("`{}`")).join(", ", last: " or a"),
      given-type,
    )
  })

  types(name, element, content, message: message)
  assert(given-func in expected-funcs, message: message)
}

/// Assert that `value` can be used in `query`.
///
/// - name (str): The name use for the value in the assertion message.
/// - value (any): The value to check for.
/// - message (str, auto): The assertion message to use.
#let queryable(name, value, message: auto) = {
  let given-type = type(value)
  let message = _core.or-default(check: auto, message, () => _core.fmt(
    "`{}` must be queryable, such as an element function, selector or label, `{}` is not queryable",
    name,
    given-type,
  ))

  types(name, value, label, function, selector, message: message)

  if type(value) == function {
    let message = _core.or-default(check: auto, message, () => {
      _core.fmt("`{}` is not an element function, was `{}`", name, value)
    })
    assert(value in _queryable-functions, message: message)
  }
}

