#import "../base-type.typ": base-type, assert-base-type
#import "../ctx.typ": z-ctx

/// Valkyrie schema generator for integer- and floating-point numbers
///
/// - name (internal):
/// - default (integer, float, none): Default value to set if none is provided. *MUST* respect all
///   other validation requirements.
/// - min (integer, none): If not none, the minimum value that satisfies the validation. The program
///   is *ILL-FORMED* if `min` is greater than `max`.
/// - max (integer, none): If not none, the maximum value that satisfies the validation. The program
///   is *ILL-FORMED* if `max` is less than `min`.
/// - custom (function, none): If not none, a function that, if itself returns none, will produce
///   the error set by `custom-error`.
/// - custom-error (string, none): If set, the error produced upon failure of `custom`.
/// - transform (function): a mapping function called after validation.
/// - types (internal):
/// -> schema
#let number(
  name: "number",
  default: none,
  min: none,
  max: none,
  custom: none,
  custom-error: auto,
  transform: it=>it,
  types: (float, int),
) = {
  // Type safety
  assert(type(default) in (..types, type(none)),
    message: "Default of number must be of type integer, float, or none (possibly narrowed)")
  assert(type(min) in (int, float, type(none)),
    message: "Minimum value must be an integer or float",
  )
  assert(type(max) in (int, float, type(none)),
    message: "Maximum value must be an integer or float",
  )

  assert(type(custom) in (function, type(none)), message: "Custom must be a function")
  assert(type(custom-error) in (str, type(auto)), message: "Custom-error must be a string")
  assert(type(transform) == function,
    message: "Transform must be a function that takes a single number and return a number",
  )

  base-type() + (
    name: name,
    default: default,
    min: min,
    max: max,
    custom: custom,
    custom-error: custom-error,
    transform: transform,
    types: types,
    validate: (self, it, ctx: z-ctx(), scope: ()) => {
      // TODO(james): Coercion

      // Default value
      if it == none { it = self.default }

      // Assert type
      if not (self.assert-type)(self, it, ctx: ctx, scope: scope, types: types) {
        return none
      }

      // Minimum value
      if self.min != none and it < self.min {
        return (self.fail-validation)(
          self,
          it,
          ctx: ctx,
          scope: scope,
          message: "Value less than specified minimum of " + str(self.min),
        )
      }

      // Maximum value
      if self.max != none and it > self.max {
        return (self.fail-validation)(
          self,
          it,
          ctx: ctx,
          scope: scope,
          message: "Value greater than specified maximum of " + str(self.max),
        )
      }

      // Custom
      if self.custom != none and not (self.custom)(it) {
        let message = "Failed on custom check: " + repr(self.custom)
        if self.custom-error != auto { message = self.custom-error }
        return (self.fail-validation)(self, it, ctx: ctx, scope: scope, message: message)
      }

      (self.transform)(it)
    }
  )
}

/// Specialization of @@number() that is only satisfied by whole numbers. Parameters of @@number remain available for further requirments.
#let integer = number.with( name: "integer", types: (int,))

/// Specialization of @@number() that is only satisfied by floating point numbers. Parameters of @@number remain available for further requirments.
#let floating-point = number.with( name: "float", types: (float,))

/// Specialization of @@integer() that is only satisfied by positive whole numbers. Parameters of @@number remain available for further requirments.
#let natural = number.with( name: "natural number", types: (int,), min: 0)
