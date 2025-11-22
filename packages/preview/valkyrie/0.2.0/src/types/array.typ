#import "../base-type.typ": base-type
#import "../assertions-util.typ": assert-base-type
#import "../ctx.typ": z-ctx

#let array-type = type(())

#let array(
  name: "array",
  ..args,
) = {
  let descendents-schema = args.pos().at(0, default: base-type(name: "any"))
  assert-base-type(descendents-schema, scope: ("arguments",))

  base-type(
    name: "array[" + (descendents-schema.name) + "]",
    default: (),
    types: (array-type,),
    ..args.named(),
  ) + (
    descendents-schema: descendents-schema,
    handle-descendents: (self, it, ctx: z-ctx(), scope: ()) => {
      for (key, value) in it.enumerate() {
        it.at(key) = (descendents-schema.validate)(
          descendents-schema,
          value,
          ctx: ctx,
          scope: (..scope, str(key)),
        )
      }
      it
    },
  )
}