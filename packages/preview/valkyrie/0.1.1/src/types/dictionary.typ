#import "../base-type.typ": base-type, assert-base-type-dictionary
#import "../ctx.typ": z-ctx

/// Valkyrie schema generator for dictionary types
///
/// - ..args (schema): Variadic named arguments, the values for which are schema types. *MUST* not
///   contain positional arguments.
/// -> schema
#let dictionary(
  ..args
) = {
  // Does not accept positional arguments
  assert(args.pos().len() == 0, message: "Dictionary only accepts named arguments")

  args = args.named()
  assert-base-type-dictionary(args)

  base-type() + (
    name: "dictionary",
    dictionary-schema: args,
    validate: (self, dict, ctx: z-ctx(), scope: ("arguments",) ) => {
      // assert type
      if not (self.assert-type)(self, dict, scope: scope, ctx: ctx, types: (type((:)),)) {
        return none
      }

      // If strict mode, ensure dictionary exactly matches schema
      if ctx.strict {
        for (key, value) in self.dictionary-schema {
          if ( key not in dict ){
            (self.fail-validation)(self, dict, ctx: ctx, scope: (..scope, key), message: "Missing expected dictionary entry")
          }
        }
      }

      // Check elements
      for (key, schema) in self.dictionary-schema{
        dict.at(key) = (schema.validate)(schema, dict.at(key), ctx: ctx, scope: (..scope, str(key)))
      }

      dict
    }
  )
}
