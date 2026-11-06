#import "../base-type.typ": base-type
#import "../assertions-util.typ": assert-base-type-array
#import "../ctx.typ": z-ctx

/// Valkyrie schema generator for objects that can be any of multiple types.
///
/// -> schema
#let either(
  strict: false,
  ..args,
) = {

  assert(
    args.pos().len() > 0,
    message: "z.either requires 1 or more arguments.",
  )
  assert-base-type-array(args.pos(), scope: ("arguments",))

  base-type(
    name: "either",
    description: "[" + args.pos().map(it => it.name).join(", ", last: " or ") + "]",
    ..args.named(),
  ) + (
    strict: strict,
    options: args.pos(),
    handle-descendents: (self, it, ctx: z-ctx(), scope: ()) => {
      for option in self.options {
        let ret = (option.validate)(
          option,
          it,
          ctx: z-ctx(ctx, strict: self.strict, soft-error: true),
          scope: scope,
        )
        if ret != none {
          return ret
        }
      }

      let message = (
        "Type failed to match any of possible options: " + self.options.map(it => it.description).join(
          ", ",
          last: " or ",
        ) + ". Got " + type(it)
      )

      return (self.fail-validation)(
        self,
        it,
        ctx: ctx,
        scope: scope,
        message: message,
      )
    },
  )
}
