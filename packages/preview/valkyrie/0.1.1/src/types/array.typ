#import "../base-type.typ": base-type, assert-base-type
#import "../ctx.typ": z-ctx
#import "any.typ": any

/// Valkyrie schema generator for array types. Array entries are validated by a single schema. For
/// arrays with positional requirements, see @@tuple.
///
/// - name (internal):
/// - default (array, none): Default value to set if no value is provided. *MUST* itself pass
///   validation.
/// - min (integer, none): If not none, the minimum array length that satisfies the validation.
///   *MUST* be a positive integer. The program is *ILL-FORMED* if `min` is greater than `max`.
/// - max (integer, none): If not none, the maximum array length that satisfies the validation.
///   *MUST* be a positive integer. The program is *ILL-FORMED* if `max` is less than `min`.
/// - length (integer, auto): If not auto, the exact array length that satisfies validation. *MUST*
///   be a positiive integer. The program *MAY* be *ILL-FORMED* is concurrently set with either
///   `min` or `max`.
/// - custom (function, none): If not none, a function that, if itself returns none, will produce
///   the error set by `custom-error`.
/// - custom-error (string, none): If set, the error produced upon failure of `custom`.
/// - transform (function): a mapping function called after validation.
/// - ..args (schema, none): Variadic positional arguments of length `0` or `1`. *SHOULD* not
///   contain named arguments. If no arguments are given, schema defaults to array of @@any
/// -> schema
#let array(
  name: "array",
  default: (),
  min: none,
  max: none,
  length: auto,
  custom: none,
  custom-error: auto,
  transform: it=>it,
  ..args
) = {
  // assert default is array
  assert(type(min) in (int, type(none)), message: "Minimum length must be an integer")
  if min != none { assert(min >= 0, message: "Minimum length must be a positive integer") }

  assert(type(max) in (int, type(none)), message: "Maximum length must be an integer")
  if max != none { assert(max >= 0, message: "Maximum length must be a positive integer") }

  assert(type(length) in (int, type(auto)), message: "Length must be an integer")
  if length != auto { assert(length >= 0, message: "Maximum length must be a positive integer") }

  assert(type(custom) in (function, type(none)), message: "Custom must be a function")
  assert(type(custom-error) in (str, type(auto)), message: "Custom-error must be a string")
  assert(type(transform) == function,
    message: "Transform must be a function that takes a single string and return a string",
  )

  let positional-arguments = args.pos()

  let valkyrie-array-typ
  if positional-arguments.len() < 1 {
    valkyrie-array-typ = any()
  } else {
    valkyrie-array-typ = positional-arguments.first()
    assert-base-type(valkyrie-array-typ, scope: ("arguments",))
  }

  let name = name + "[" + (valkyrie-array-typ.name) +"]"

  base-type() + (
    name: name,
    default: default,
    min: min,
    max: max,
    length: length,
    valkyrie-array-typ: valkyrie-array-typ,
    custom: custom,
    custom-error: custom-error,
    transform: transform,
    validate: (self, it, ctx: z-ctx(), scope: ()) => {
      // Default value
      if it == none { it = self.default }

      // Array must be an array
      if not (self.assert-type)(self, it, scope: scope, ctx: ctx, types: (type(()),)){
        return none
      }

      // Minimum length
      if (self.min != none) and (it.len() < self.min) {
        return (self.fail-validation)(
          self,
          it,
          ctx: ctx,
          scope: scope,
          message: "Array length less than specified minimum of " + str(self.min),
        )
      }

      // Minimum length
      if (self.max != none) and (it.len() > self.max) {
        return (self.fail-validation)(
          self,
          it,
          ctx: ctx,
          scope: scope,
          message: "Array length greater than specified maximum of " + str(self.max),
        )
      }

      // Exact length
      if (self.length != auto) and (it.len() != self.length) {
        return (self.fail-validation)(
          self,
          it,
          ctx: ctx,
          scope: scope,
          message: "Array length must exactly equal " + str(self.length),
        )
      }

      // Check elements
      for (key, value) in it.enumerate(){
        it.at(key) = (valkyrie-array-typ.validate)(
          valkyrie-array-typ,
          value,
          ctx: ctx,
          scope: (..scope, str(key)),
        )
      }

      // Custom
      if ( self.custom != none ) and ( not (self.custom)(it) ){
        let message = "Failed on custom check: " + repr(self.custom)
        if ( self.custom-error != auto ){ message = self.custom-error }
        return (self.fail-validation)(self, it, ctx: ctx, scope: scope, message: message)
      }

      (self.transform)(it)
    }
  )
}
