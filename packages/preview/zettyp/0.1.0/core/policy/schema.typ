/// Structural policy types; composition and contract checks remain separate.
#import "../graph-schema.typ" as graph
#import "../graph-schema.typ": checked

#let arity = graph.integer(min: 0)
#let index = arity
#let callable = graph.typed("function", (function,))
#let arguments = graph.array(graph.opaque)
#let identities = graph.array(graph.id)
#let tag = graph.one-of

#let operation = graph.record("Operation", (arity: arity, apply: callable))
#let operations = graph.array(operation)
#let morphism = graph.record("Morphism", (arity: arity, outputs: operations))
#let definition = graph.record("PolicyDefinition", (
  arity: arity,
  check: callable,
  run: callable,
))
#let invocation = graph.record("Invocation", (
  id: graph.id,
  definition: definition,
  inputs: identities,
  origin: graph.opaque,
))
#let invocations = graph.array(invocation)

#let sum = graph.record("Sum", (
  side: tag(("left", "right")),
  value: graph.opaque,
))
#let sums = graph.array(sum)
#let issues = arguments
#let failure = graph.record("Failure", (
  kind: tag(("failure",)),
  invocation: graph.id,
  issues: graph.array(graph.opaque, min: 1),
))
#let blocked = graph.record("Blocked", (
  kind: tag(("blocked",)),
  invocation: graph.id,
  dependencies: graph.array(graph.id, min: 1),
))
#let error = graph.tagged("InvocationError", "kind", (
  failure: failure,
  blocked: blocked,
))

#let observer = graph.record("ObservationDefinition", (
  observe: callable,
  on-error: callable,
))
#let binding = graph.record("ObservationBinding", (
  name: graph.id,
  definition: observer,
  at: graph.id,
  origin: graph.opaque,
))
#let bindings = graph.array(binding)
#let claim = graph.record("PreservationClaim", (
  binding: binding,
  target: graph.id,
  origin: graph.opaque,
))
#let claims = graph.array(claim)
