/// Fixed assignment shapes inferred from a registered initial GraphState.
#import "vocabulary.typ"

#let same-keys(value, keys) = (
  type(value) == dictionary and value.keys().sorted() == keys.sorted()
)

// `variant` is reserved for enum values, including malformed ones.
#let infer(value, registry, record: false) = {
  if not record and type(value) == bool { return (kind: "boolean") }
  assert(
    type(value) == dictionary,
    message: "semantic values must be booleans, enums, or records",
  )
  if not record and "variant" in value {
    assert(
      vocabulary.contains(registry, value),
      message: "unregistered semantic enum value",
    )
    return (kind: "enum", type: value.type)
  }
  let fields = value
    .pairs()
    .fold((:), (fields, pair) => {
      fields.insert(pair.at(0), infer(pair.at(1), registry))
      fields
    })
  (kind: "record", fields: fields)
}

#let matches(shape, value, registry) = {
  if shape.kind == "boolean" { return type(value) == bool }
  if shape.kind == "enum" {
    return (
      vocabulary.enum-value(value)
        and value.type == shape.type
        and vocabulary.contains(registry, value)
    )
  }
  (
    same-keys(value, shape.fields.keys())
      and shape
        .fields
        .pairs()
        .all(((key, field)) => (
          matches(field, value.at(key), registry)
        ))
  )
}

/// Initial must use a topology from graph.assemble and a vocabulary.registry.
#let contract(initial, registry: (:)) = {
  assert(
    same-keys(initial, ("graph", "values")),
    message: "expected a GraphState",
  )
  assert(
    same-keys(initial.values, ("nodes", "edges")),
    message: "expected node and edge assignments",
  )
  assert(
    same-keys(initial.values.nodes, initial.graph.nodes),
    message: "initial node assignments do not match topology",
  )
  assert(
    same-keys(initial.values.edges, initial.graph.edges.keys()),
    message: "initial edge assignments do not match topology",
  )
  (
    topology: initial.graph,
    registry: registry,
    shape: (
      kind: "record",
      fields: (
        nodes: infer(initial.values.nodes, registry, record: true),
        edges: infer(initial.values.edges, registry, record: true),
      ),
    ),
  )
}

#let contains(contract, state) = (
  same-keys(state, ("graph", "values"))
    and state.graph == contract.topology
    and matches(contract.shape, state.values, contract.registry)
)

#let enumerate-values(shape, registry) = {
  if shape.kind == "boolean" { return (false, true) }
  if shape.kind == "enum" { return registry.at(shape.type).values() }
  shape
    .fields
    .pairs()
    .fold(((:),), (partials, pair) => {
      let (key, field) = pair
      let choices = enumerate-values(field, registry)
      partials.fold((), (next, partial) => (
        next
          + choices.map(value => {
            let record = partial
            record.insert(key, value)
            record
          })
      ))
    })
}

/// Enumerate every assignment permitted by the fixed contract.
#let states(contract) = enumerate-values(contract.shape, contract.registry).map(
  values => (
    graph: contract.topology,
    values: values,
  ),
)

/// Values may change; topology, field shapes, and enum types may not.
#let checked(contract, state) = {
  assert(
    contains(contract, state),
    message: "GraphState violates its finite semantic contract",
  )
  state
}
