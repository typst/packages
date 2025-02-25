#import "../base-type.typ": base-type
#import "../assertions-util.typ": assert-base-type
#import "../ctx.typ": z-ctx

#let to-args-type(..args) = args

#let sink(
  positional: none,
  named: none,
  ..args,
) = {

  if positional != none {
    assert-base-type(positional)
  }
  if named != none {
    assert-base-type(named)
  }

  base-type(
    name: "argument-sink",
    types: (arguments,),
    ..args,
  ) + (
    positional-schema: positional,
    named-schema: named,
    handle-descendents: (self, it, ctx: z-ctx(), scope: ()) => {

      let positional = it.pos()
      if self.positional-schema == none {
        if positional.len() > 0 {
          (self.fail-validation)(
            self,
            it,
            scope: scope,
            ctx: ctx,
            message: "Unexpected positional arguments.",
          )
        }
      } else {
        positional = (self.positional-schema.validate)(
          self.positional-schema,
          it.pos(),
          ctx: ctx,
          scope: (..scope, "positional"),
        )
      }

      let named = it.named()
      if self.named-schema == none {
        if named.len() > 0 {
          (self.fail-validation)(
            self,
            it,
            scope: scope,
            ctx: ctx,
            message: "Unexpected named arguments.",
          )
        }
      } else {
        named = (self.named-schema.validate)(
          self.named-schema,
          it.named(),
          ctx: ctx,
          scope: (..scope, "named"),
        )
      }

      to-args-type(..positional, ..named)
    },
  )

}