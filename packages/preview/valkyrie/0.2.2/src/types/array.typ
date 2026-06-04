#import "../base-type.typ": base-type
#import "../assertions-util.typ": assert-base-type, assert-positive-type
#import "../ctx.typ": z-ctx

#let array-type = type(())

#let array(
  name: "array",
  assertions: (),
  min: none,
  max: none,
  ..args,
) = {
  let descendents-schema = args.pos().at(0, default: base-type(name: "any"))

  assert-base-type(descendents-schema, scope: ("arguments",))
  assert-positive-type(min, types: (int,), name: "Minimum length")
  assert-positive-type(max, types: (int,), name: "Maximum length")

  base-type(
    name: name,
    description: name + "[" + (descendents-schema.description) + "]",
    default: (),
    types: (array-type,),
    ..args.named(),
  ) + (
    min: min,
    max: max,
    assertions: (
      (
        precondition: "min",
        condition: (self, it) => it.len() >= self.min,
        message: (self, it) => "Length must be at least " + str(self.min),
      ),
      (
        precondition: "max",
        condition: (self, it) => it.len() <= self.max,
        message: (self, it) => "Length must be at most " + str(self.max),
      ),
      ..assertions,
    ),
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