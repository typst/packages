#import "../../../core/graph.typ"
#import "../../../core/policy/lib.typ" as policy
#import "../../../core/semantic.typ"
#import "../../../core/vocabulary.typ"
#import "../relations.typ": (
  dependency-groups, neighbor-index, neighbors, reachable,
)

#let issues(state, origins, colors) = {
  let groups = dependency-groups(state, colors)
  groups
    .map(group => {
      let kinds = group
        .occurrences
        .map(id => state.values.edges.at(id).relation)
        .dedup()
      let endpoints = repr(group.source) + " -> " + repr(group.target)
      let problems = ()
      if kinds.len() > 1 {
        problems.push((
          code: <zk.relation.color-conflict>,
          message: "conflicting dependency colors: " + endpoints,
        ))
      }
      // Diagnose cycle edges, not edges merely entering or leaving a cycle.
      if reachable(groups, group.target, group.source) {
        problems.push((
          code: <zk.relation.cycle>,
          message: "dependency graph contains a cycle through " + endpoints,
        ))
      }
      problems.map(issue => (
        issue
          + (
            occurrences: group.occurrences,
            origins: group.occurrences.map(id => origins.edges.at(id)),
          )
      ))
    })
    .flatten()
}

/// Bind one optional policy to its schema, vocabulary, and source origins.
#let lifecycle-policy(
  schema,
  origins,
  field: none,
  archived: none,
  legacy: none,
  replaces: none,
  evolves-from: none,
) = {
  assert(field in schema.value.shape.fields, message: "missing lifecycle field")
  let shape = schema.value.shape.fields.at(field)
  assert(
    (archived, legacy).all(value => semantic.matches(
      shape,
      value,
      schema.registry,
    )),
    message: "lifecycle states must match the declared field",
  )
  let colors = (replaces, evolves-from)
  assert(
    colors.all(color => (
      vocabulary.enum-value(color)
        and vocabulary.contains(schema.registry, color)
    ))
      and replaces != evolves-from,
    message: "lifecycle relations must be distinct registered colors",
  )
  let derive(state) = {
    let index = neighbor-index(state, (
      replaces: (color: replaces, direction: "incoming"),
      evolves-from: (color: evolves-from, direction: "incoming"),
    ))
    graph.assign(
      state,
      nodes: state
        .values
        .nodes
        .pairs()
        .map(((id, value)) => {
          let has(name) = neighbors(index, id, name).len() > 0
          let next = if has("replaces") { archived } else if has(
            "evolves-from",
          ) {
            legacy
          } else { value.at(field) }
          (id, value + ((field): next))
        })
        .to-dict(),
    )
  }
  policy.definition(
    1,
    states => derive(states.first()),
    check: states => issues(states.first(), origins, colors),
  )
}
