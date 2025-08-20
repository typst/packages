#import "types.typ": *
#import "ctx.typ": z-ctx
#import "base-type.typ" as advanced

/// This is the main function for validating an object against a schema. *WILL* return the given
/// object after validation if successful, or none and *MAY* throw a failed assertion error.
///
/// - object (any): Object to validate against provided schema. Object *SHOULD* statisfy the schema
///   requirements. An error *MAY* be produced if not.
/// - schema (schema): Schema against which `object` is validated. *MUST* be a valid valkyrie schema
///   type.
/// - ctx (ctx): ctx passed to schema validator function, containing flags that *MAY* alter
///   behaviour.
/// - scope (scope): An array of strings used to generate the string representing the location of a
///   failed requirement within `object`. *MUST* be an array of strings of length greater than or
///   equal to `1`.
/// -> any, none
#let parse(
  object, schema,
  ctx: z-ctx(),
  scope: ("argument",),
) = {
  // don't expose to external
  import "base-type.typ": assert-base-type

  // Validate named arguments
  assert-base-type(schema, scope: scope)

  // Validate arguments per schema
  object = (schema.validate)(
      schema,
      ctx: ctx,
      scope: scope,
      object,
  )

  // Require arguments match schema exactly in strict mode
  if ctx.strict {
    for (argument-name, argument-value) in object {
      assert(argument-name in schema, message: "Unexpected argument " + argument-name)
    }
  }

  object
}

