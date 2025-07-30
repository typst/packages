#import "types.typ": *
#import "ctx.typ": z-ctx
#import "base-type.typ": base-type
#import "assertions-util.typ" as advanced
#import "assertions.typ" as assert
#import "coercions.typ" as coerce
#import "schemas.typ"

#let parse(
  object,
  schemas,
  ctx: z-ctx(),
  scope: ("argument",),
) = {
  // don't expose to external
  import "assertions-util.typ": assert-base-type


  // Validate named arguments

  if (type(schemas) != type(())) {
    schemas = (schemas,)
  }
  advanced.assert-base-type-array(schemas, scope: scope)

  for schema in schemas {
    object = (schema.validate)(
      schema,
      ctx: ctx,
      scope: scope,
      object,
    )
  }

  return object
}

