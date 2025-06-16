#import "../base-type.typ": base-type, assert-base-type
#import "../ctx.typ": z-ctx

/// Validation schema representing all types. *SHOULD* never produce an error.
///
/// - name (internal):
/// - default (any, none): Default value to validate is none is provided.
/// - custom (function): Function that maps an input to an output. If the function returns `none`,
///   then an error *WILL* be generated using `custom-error`.
/// - custom-error (string): Error to return if custom function returns none.
/// - transform (function): Function that maps an input to an output, called after validation.
/// -> schema
#let any(
  name: "any",
  default: none,
  custom: none,
  custom-error: auto,
  transform: it => it,
) = {
  assert(type(custom) in (function, type(none)), message: "Custom must be a function")
  assert(type(custom-error) in (str, type(auto)), message: "Custom-error must be a string")
  assert(type(transform) == function,
    message: "Transform must be a function that maps an input to an output",
  )

  base-type() + (
    name: name,
    default: default,
    custom: custom,
    custom-error: custom-error,
    transform: transform,

    validate: (self, it, ctx: z-ctx(), scope: ()) => {
      // Default value
      if (it == none){ it = self.default }

      // Custom
      if self.custom != none and not (self.custom)(it) {
        let message = "Failed on custom check: " + repr(self.custom)
        if ( self.custom-error != auto ){ message = self.custom-error }
        return (self.fail-validation)(self, it, ctx: ctx, scope: scope, message: message)
      }

      (self.transform)(it)
    }
  )
}
