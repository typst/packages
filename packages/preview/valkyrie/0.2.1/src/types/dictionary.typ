#import "../base-type.typ": base-type
#import "../assertions-util.typ": assert-base-type-dictionary, assert-base-type
#import "../ctx.typ": z-ctx
#import "../assertions-util.typ": *

#let dictionary-type = type((:))

/// Valkyrie schema generator for dictionary types. Named arguments define validation schema for entries. Dictionaries can be nested.
///
/// -> schema
#let dictionary(
  dictionary-schema,
  name: "dictionary",
  default: (:),
  pre-transform: (self, it) => it,
  aliases: (:),
  ..args,
) = {

  assert-base-type-dictionary(dictionary-schema)

  base-type(
    name: name,
    default: default,
    types: (dictionary-type,),
    pre-transform: (self, it) => {
      it = pre-transform(self, it)
      for (src, dst) in aliases {
        let value = it.at(src, default: none)
        if (value != none) {
          it.insert(dst, value)
          let _ = it.remove(src)
        }
      }
      return it
    },
    ..args.named()
  ) + (
    dictionary-schema: dictionary-schema,
    handle-descendents: (self, it, ctx: z-ctx(), scope: ()) => {

      if (it.len() == 0 and self.optional) {
        return none
      }

      // Check `it` if strict
      if (ctx.strict == true) {
        for (key, value) in it {
          if (key not in self.dictionary-schema) {
            return (self.fail-validation)(
              self,
              it,
              ctx: ctx,
              scope: scope,
              message: "Unknown key `" + key + "` in dictionary",
            )
          }
        }
      }


      for (key, schema) in self.dictionary-schema {

        let entry = (
          schema.validate
        )(
          schema,
          it.at(key, default: none), // implicitly handles missing entries
          ctx: ctx,
          scope: (..scope, str(key))
        )

        if (entry != none or ctx.remove-optional-none == false) {
          it.insert(key, entry)
        }

      }
      return it
    },
  )
}