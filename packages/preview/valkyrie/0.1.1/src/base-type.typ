#import "ctx.typ": z-ctx

/// Asserts the presence of the magic number on the given object.
///
/// - arg (any):
/// - scope (scope): Array of strings containing information for error generation.
/// -> none
#let assert-base-type(arg, scope: ("arguments",)) = {
  assert("valkyrie-type" in arg,
    message: "Invalid valkyrie type in " + scope.join(".")
  )
}

/// Asserts the presence of the magic number on an array of object.
///
/// - arg (any):
/// - scope (scope): Array of strings containing information for error generation.
/// -> none
#let assert-base-type-array(arg, scope: ("arguments",)) = {
  for (name, value) in arg.enumerate() {
    assert-base-type(value, scope: (..scope, str(name)))
  }
}

/// Asserts the presence of the magic number in a dictionary of object.
///
/// - arg (any):
/// - scope (scope): Array of strings containing information for error generation.
/// -> none
#let assert-base-type-dictionary(arg, scope: ("arguments",)) = {
  for (name, value) in arg {
    assert-base-type(value, scope: (..scope, name))
  }
}

/// Asserts the presence of the magic number in an argument of object.
///
/// - arg (any):
/// - scope (scope): Array of strings containing information for error generation.
/// -> none
#let assert-base-type-arguments(arg, scope: ("arguments",)) = {
  for (name, value) in arg.named() {
    assert-base-type(value, scope: (..scope, name))
  }

  for (pos, value) in arg.pos().enumerate() {
    assert-base-type(value, scope: (..scope, "[" + pos + "]"))
  }
}

/// Schema generator. Provides default values for when defining custom types.
#let base-type() = (
  valkyrie-type: true,
  assert-type: (self, it, scope:(), ctx: z-ctx(), types: ()) => {
    if type(it) not in types {
      (self.fail-validation)(self, it, scope: scope, ctx: ctx,
        message: "Expected " + types.join(", ", last: " or ") + ". Got " + type(it))
      return false
    }

    true
  },
  validate: (self, it, scope: (), ctx: z-ctx()) => it,
  fail-validation: (self, it, scope: (), ctx: z-ctx(), message: "") => {
    let display = "Schema validation failed on " + scope.join(".")
    if message.len() > 0 { display += ": " + message}
    ctx.outcome = display
    if not ctx.soft-error {
      assert(false, message: display)
    }
  }
)
