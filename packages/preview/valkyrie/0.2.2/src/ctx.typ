#let ctx-proto = (
  strict: false,
  soft-error: false,
  remove-optional-none: false,
)

/// This is a utility function for setting contextual flags that are used during validation of objects against schemas.
///
/// Currently, the following flags are described within the API:
/// / strict: If set, this flag adds the requirement that there are no entries in dictionary types that are not described by the validation schema.
/// / soft-error: If set, this flag silences errors from failed validation parses. It is used internally for types that should not error on validation failures. See @@either
///
/// - parent (z-ctx, none): Current context (if present), to which contextual
///   flags passed in variadic arguments are appended.
/// - ..args (arguments): Variadic contextual flags to set. Positional arguments are discarded.
/// -> z-ctx
#let z-ctx(parent: (:), ..args) = ctx-proto + parent + args.named()
