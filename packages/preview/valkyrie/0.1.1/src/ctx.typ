#let ctx-proto = (
  strict: false,
  soft-error: false,
  // TODO(james)
  coerce: false,
)

/// Appends options to a context. Used for setting the context of child parses.
///
/// - parent (ctx, none): Current context (if present), to which contextual
///   flags passed in variadic arguments are appended.
/// - ..args (arguments): Variadic contextual flags to set. Positionala rguments are discarded.
#let z-ctx(parent: (:), ..args) = ctx-proto + parent + args.named()
