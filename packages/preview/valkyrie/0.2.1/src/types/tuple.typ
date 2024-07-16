#import "../base-type.typ": base-type
#import "../assertions-util.typ": assert-base-type-array
#import "../ctx.typ": z-ctx
#import "../assertions-util.typ": *

/// Valkyrie schema generator for an array type with positional type reqruiements. If all entries
/// have the same type, see @@array.
/// exact (bool): Requires a tuple to match in length
///
/// -> schema
#let tuple(
  exact: true,
  ..args,
) = {
  assert-base-type-array(args.pos())

  base-type(
    name: "tuple",
    types: (type(()),),
    ..args.named(),
  ) + (
    tuple-exact: exact,
    tuple-schema: args.pos(),
    handle-descendents: (self, it, ctx: z-ctx(), scope: ()) => {
      if (self.tuple-exact and self.tuple-schema.len() != it.len()){
        (self.fail-validation)(self, it, ctx: ctx, scope: scope, 
          message: "Expected " + str(self.tuple-schema.len())  + " values, but got " + str(it.len())
        )
      }
      for (key, schema) in self.tuple-schema.enumerate() {
        it.at(key) = (schema.validate)(
          schema,
          it.at(key),
          ctx: ctx,
          scope: (..scope, str(key)),
        )
      }
      it
    },
  )
}
