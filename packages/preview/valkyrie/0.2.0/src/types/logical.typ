#import "../base-type.typ": base-type
#import "../assertions-util.typ": assert-base-type-array
#import "../ctx.typ": z-ctx

/// Valkyrie schema generator for objects that can be any of multiple types.
///
/// -> schema
#let either(..args) = {

  assert(
    args.pos().len() > 0,
    message: "z.either requires 1 or more arguments.",
  )
  assert-base-type-array(args.pos(), scope: ("arguments",))

  base-type() + (
    name: "[" + args.pos().map(it => it.name).join(", ", last: " or ") + "]",
    ..args.named(),
    options: args.pos(),
    handle-descendents: (self, it, ctx: z-ctx(), scope: ()) => {
      for option in self.options {
        let ret = (option.validate)(
          option,
          it,
          ctx: z-ctx(ctx, soft-error: true),
          scope: scope,
        )
        if ret != none {
          return ret
        }
      }

      let message = (
        "Type failed to match any of possible options: " + self.options.map(it => it.name).join(
          ", ",
          last: " or ",
        ) + ". Got " + type(it)
      )

      (self.fail-validation)(self, it, ctx: ctx, scope: scope, message: message)
    },
  )
}
