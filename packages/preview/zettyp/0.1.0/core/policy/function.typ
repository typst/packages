/// Pure policy definitions and identified invocation declarations.
#import "schema.typ"

/// A policy consumes one ordered array of states and produces one state.
/// Check consumes the same array and returns an array of issues.
/// Neither function is executed during declaration or structural assembly.
/// The shared semantic contract is supplied when the definition is lifted.
#let definition(arity, run, check: arguments => ()) = schema.checked(
  (arity: arity, check: check, run: run),
  schema.definition,
)

/// Declare one invocation; its identity also addresses its single result.
/// Definitions may be reused, but invocation identities must be unique.
/// Input order and repetitions specify ports, not scheduling dependencies.
/// Assembly resolves references and checks port counts and acyclicity.
#let invocation(id, definition, inputs: (), origin: none) = schema.checked(
  (id: id, definition: definition, inputs: inputs, origin: origin),
  schema.invocation,
)
