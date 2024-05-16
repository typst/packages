#import "../base-type.typ": base-type, assert-base-type
#import "../ctx.typ": z-ctx

/// Valkyrie schema generator for objects that can be any of multiple types.
///
/// - ..options (schema): Variadic position arguments for possible types. *MUST* have at least `1`
///   positional argument. Schemas *SHOULD* be given in order of "preference".
/// -> schema
#let either(..options) = {
  let options = options.pos()

  assert(options.len() > 0 , message: "z.either requires 1 or more arguments.")

  for option in options {
    assert-base-type(option, scope: ("arguments",))
  }

  let name = "[" + options.map(it => it.name).join( ", ", last: " or ") + "]"

  base-type() + (
    name: name,
    validate: (self, it, ctx: z-ctx(), scope: ()) => {
      for option in options {
        let ret = (option.validate)(option, it, ctx: z-ctx(ctx, soft-error: true), scope: scope)
        if ret != none { return ret }
      }

      let message = ("Type failed to match any of possible options: "
        + options.map(it => it.name).join(", ", last: " or "))

      // TODO(james): Somehow handle error? Not sure how to retrieve from ctx
      (self.fail-validation)(self, it, ctx: ctx, scope: scope, message: message)
    }
  )
}
