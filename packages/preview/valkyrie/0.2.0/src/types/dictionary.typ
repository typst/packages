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
  default: (:),
  optional: false,
  assertions: (),
  pre-transform: (self, it) => it,
  post-transform: (self, it) => it,
  aliases: (:),
) = {

  assert-base-type-dictionary(dictionary-schema)

  base-type(
    name: "dictionary",
    optional: optional,
    default: default,
    types: (dictionary-type,),
    assertions: assertions,
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
    post-transform: post-transform,
  ) + (
    dictionary-schema: dictionary-schema,
    handle-descendents: (self, it, ctx: z-ctx(), scope: ()) => {

      if (it.len() == 0 and self.optional) {
        return none
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

        it.insert(key, entry)

        if (
          entry == none and (
            it.at(
              key,
              default: none,
            ) != none or ctx.remove-optional-none == true
          )
        ) {
          it.remove(key, default: none)
        }

      }
      return it
    },
  )
}