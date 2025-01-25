
#let assert-base-type(arg, scope: ("arguments",)) = {
  assert(
    "valkyrie-type" in arg,
    message: "Invalid valkyrie type in " + scope.join("."),
  )
}

#let assert-base-type-array(arg, scope: ("arguments",)) = {
  for (name, value) in arg.enumerate() {
    assert-base-type(value, scope: (..scope, str(name)))
  }
}

#let assert-base-type-dictionary(arg, scope: ("arguments",)) = {
  for (name, value) in arg {
    assert-base-type(value, scope: (..scope, name))
  }
}

#let assert-base-type-arguments(arg, scope: ("arguments",)) = {
  for (name, value) in arg.named() {
    assert-base-type(value, scope: (..scope, name))
  }

  for (pos, value) in arg.pos().enumerate() {
    assert-base-type(value, scope: (..scope, "[" + pos + "]"))
  }
}

#let assert-types(var, types: (), default: none, name: "") = {
  assert(
    type(var) in (type(default), ..types),
    message: "" + name + " must be of type " + types.join(
      ", ",
      last: " or ",
    ) + ". Got " + type(var),
  )
}

#let assert-soft(var, condition: () => true, message: "") = {
  if (var != none) {
    assert(condition(var), message: message)
  }
}

#let assert-positive(var, name: "") = {
  assert-soft(
    var,
    condition: var => var >= 0,
    message: name + " must be positive",
  )
}

#let assert-positive-type(var, name: "", types: (), default: none) = {
  assert-types(var, types: types, default: default, name: name)
  assert-positive(var, name: name)
}

#let assert-boilerplate-params(
  default: none,
  assertions: none,
  pre-transform: none,
  post-transform: none,
) = {
  if (assertions != none) {
    assert-types(assertions, types: (type(()),), name: "Assertions")
  }
  if (pre-transform != none) {
    assert-types(pre-transform, types: (function,), name: "Pre-transform")
  }
  if (post-transform != none) {
    assert-types(post-transform, types: (function,), name: "Post-transform")
  }
}