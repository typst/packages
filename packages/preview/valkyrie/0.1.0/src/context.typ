
#let context-proto = (
  strict: false,
  soft-error: false,
  coerce: false, // TO DO
)

/// Appends setting to context. Used for setting the context of child parses.
///
/// - ctx (context, none): Current context (if present, or undefined if not), to which contextual flags passed in variadic arguments are appended.
/// - ..args (arguments): Variadic contextual flags to set. While it accepts positional arguments, only named contextual flags are used throughout the codebase.
#let context(ctx: (:), ..args) = {
  return (:..context-proto, ..ctx, ..args.named())
}