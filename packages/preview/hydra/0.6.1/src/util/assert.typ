#import "/src/util/core.typ" as _core
#import _core: queryable-functions as _queryable-functions

/// Assert that `value` is any of the given `expected-values`.
///
/// -> none
#let enum(
  /// The to name use for the value in the assertion message.
  ///
  /// -> str
  name,
  /// The value to check for.
  ///
  /// -> any
  value,
  /// The expected variants of `value`.
  ///
  /// -> type
  ..expected-values,
  /// The assertion message to use.
  ///
  /// -> str | auto
  message: auto,
) = {
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
/// -> none
#let types(
  /// The name to use for the value in the assertion message.
  ///
  /// -> str
  name,
  /// The value to check for.
  ///
  /// -> any
  value,
  /// The expected types of `value`.
  ///
  /// -> type
  ..expected-types,
  /// The assertion message to use.
  ///
  /// -> str | auto
  message: auto,
) = {
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
/// -> none
#let element(
  /// The name to use for the value in the assertion message.
  ///
  /// -> str
  name,
  /// The value to check for.
  ///
  /// -> any
  element,
  /// The assertion message to use.
  ///
  /// -> str | auto
  ..expected-funcs,
  /// The expected element functions of @cmd:element.element.
  ///
  /// -> type
  message: auto,
) = {
  let given-func = element.func()
  expected-funcs = expected-funcs.pos()
  let message = _core.or-default(check: auto, message, () => if expected-funcs.len() == 1 {
    _core.fmt("`{}` must be a `{}`, was `{}`", name, expected-funcs.first(), given-func)
  } else {
    _core.fmt(
      "`{}` must be one of a {}, was `{}`",
      name,
      expected-funcs.map(_core.fmt.with("`{}`")).join(", ", last: " or a"),
      given-func,
    )
  })

  types(name, element, content, message: message)
  assert(given-func in expected-funcs, message: message)
}

/// Assert that `value` can be used in `query`.
///
#let queryable(
  /// The name to use for the value in the assertion message.
  ///
  /// -> str
  name,
  /// The value to check for.
  ///
  /// -> any
  value,
  /// The assertion message to use.
  ///
  /// -> str | auto
  message: auto,
) = {
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

