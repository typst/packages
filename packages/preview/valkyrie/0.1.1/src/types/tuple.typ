#import "../base-type.typ": base-type, assert-base-type-array
#import "../ctx.typ": z-ctx

/// Valkyrie schema generator for an array type with positional type reqruiements. If all entries
/// have the same type, see @@array.
///
/// - name (internal):
/// - ..args (schema): Type requirments. Position of argument *MUST* match position of entry in
///   tuple being validated. *SHOULD* not contain named arguments.
/// -> schema
#let tuple(
  name: "tuple",
  ..args
) = {
  // Does not accept named arguments
  assert(args.named().len() == 0, message: "Dictionary only accepts named arguments")
  args = args.pos()

  assert-base-type-array(args)

  base-type() + (
    name: name,
    tuple-schema: args,
    validate: (self, tuple, ctx: z-ctx(), scope: ()) => {
      // assert type
      if not (self.assert-type)(self, tuple, scope: scope, ctx: ctx, types: (type(()),)) {
        return none
      }

      // Check elements
      for (key, schema) in self.tuple-schema.enumerate() {
        tuple.at(key) = (schema.validate)(
          schema,
          tuple.at(key),
          ctx: ctx,
          scope: (..scope, str(key))
        )
      }

      tuple
    }
  )
}
