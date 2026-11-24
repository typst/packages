/// Carrier-independent operations and their Lawvere-theory morphisms.
///
/// Operation: (arity: n, apply: array<A> -> A).
/// Morphism m -> n: (arity: m, outputs: array<Operation> of length n).
/// All operations share one carrier by convention. Values remain opaque;
/// equality of operations means equality of results, not closure identity.

#import "schema.typ"

#let require-arity(n) = {
  let _ = schema.checked(n, schema.arity, scope: ("arity",))
}

/// Introduce a generator. The implementation receives one argument array.
/// This constructor adds no composition or carrier-specific semantics.
#let operation(n, implementation) = {
  require-arity(n)
  let implementation = schema.checked(
    implementation,
    schema.callable,
    scope: ("implementation",),
  )
  (
    arity: n,
    apply: arguments => {
      let arguments = schema.checked(arguments, schema.arguments)
      assert(arguments.len() == n, message: "operation arity mismatch")
      implementation(arguments)
    },
  )
}

/// The i-th projection in an n-input context; indices are zero-based.
#let projection(n, i) = {
  require-arity(n)
  let i = schema.checked(i, schema.index, scope: ("index",))
  assert(
    i < n,
    message: "projection index is outside its input context",
  )
  operation(n, arguments => arguments.at(i))
}

/// An ordered list of operations sharing an m-input context.
/// Explicit m also determines the source of the empty-output morphism.
/// A morphism is not an operation whose carrier value happens to be an array.
#let tuple(m, operations) = {
  require-arity(m)
  let operations = schema.checked(operations, schema.operations)
  assert(
    operations.all(op => op.arity == m),
    message: "outputs must be operations with the same input arity",
  )
  (arity: m, outputs: operations)
}

/// Substitute G's outputs into f's ports: $f \triangleright i.G_i$.
/// G: n -> m and f in T(m) yield an operation in T(n).
/// Empty substitution retains G's input context for nullary operations.
#let bind(f, G) = {
  let f = schema.checked(f, schema.operation, scope: ("operation",))
  let G = schema.checked(G, schema.morphism, scope: ("substitutions",))
  let substitutions = tuple(G.arity, G.outputs)
  assert(
    substitutions.outputs.len() == f.arity,
    message: "substitution output count must match operation arity",
  )
  operation(substitutions.arity, arguments => (
    (f.apply)(substitutions.outputs.map(g => (g.apply)(arguments)))
  ))
}
