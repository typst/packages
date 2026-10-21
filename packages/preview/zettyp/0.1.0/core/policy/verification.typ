/// Explicit checking of observation reuse along every relevant dependency path.
#import "preservation.typ"
#import "schema.typ"

/// A claim adds no execution dependency and performs no proof work.
#let claim(binding, target, origin: none) = schema.checked(
  (binding: binding, target: target, origin: origin),
  schema.claim,
)

// Each port is a separate edge, even when several ports share a source.
#let edges(wiring) = (
  wiring
    .ids
    .filter(id => id in wiring.calls)
    .map(id => (
      wiring
        .calls
        .at(id)
        .ports
        .enumerate()
        .map(((port, slot)) => (
          source: wiring.ids.at(slot),
          invocation: id,
          port: port,
        ))
    ))
    .flatten()
)

#let closure(order, edges, start, reverse: false) = order.fold((start,), (
  seen,
  id,
) => {
  let reached = edges.any(edge => {
    if reverse {
      edge.source == id and edge.invocation in seen
    } else {
      edge.invocation == id and edge.source in seen
    }
  })
  if id in seen or not reached { seen } else { seen + (id,) }
})

#let check-claim(program, edges, claim) = {
  let wiring = program.wiring
  let binding = claim.binding
  let downstream = closure(wiring.ids, edges, binding.at)
  if claim.target not in downstream {
    return (evidence: none, issues: ((kind: "no-preservation-path"),))
  }
  let upstream = closure(wiring.ids.rev(), edges, claim.target, reverse: true)
  let relevant = edges.filter(edge => (
    edge.source in downstream and edge.invocation in upstream
  ))
  let checks = relevant.map(edge => (
    edge: edge,
    result: preservation.check(
      wiring.calls.at(edge.invocation).definition,
      binding.definition.observe,
      program.contract,
      port: edge.port,
    ),
  ))
  let issues = checks
    .map(item => item.result.issues.map(issue => (
      issue
        + item.edge
        + (
          invocation-origin: wiring.origins.at(item.edge.invocation),
        )
    )))
    .flatten()
  (
    evidence: if issues.len() > 0 { none } else {
      (
        binding: binding,
        target: claim.target,
        origin: claim.origin,
        steps: checks.map(item => item.edge + (evidence: item.result.evidence)),
      )
    },
    issues: issues,
  )
}

/// Validate all addresses before any exhaustive work. Returns evidence only
/// when every claim passes. A reflexive claim needs no local steps; unrelated
/// vertices have no preservation path. Only success semantics are proved:
/// neither availability nor invariance of error diagnostics is promised.
#let verify(program, claims) = {
  let claims = schema.checked(claims, schema.claims)
  let location(claim) = (
    observation: claim.binding.name,
    at: claim.binding.at,
    target: claim.target,
    origin: claim.origin,
    binding-origin: claim.binding.origin,
  )
  let issues = ()
  for claim in claims {
    if claim.binding.at not in program.wiring.slots {
      issues.push(location(claim) + (kind: "missing-preservation-source"))
    }
    if claim.target not in program.wiring.slots {
      issues.push(location(claim) + (kind: "missing-preservation-target"))
    }
  }
  if issues.len() > 0 { return (evidence: none, issues: issues) }
  let edges = edges(program.wiring)
  let checked = claims.map(claim => (
    claim: claim,
    result: check-claim(program, edges, claim),
  ))
  let issues = checked
    .map(item => item.result.issues.map(issue => (
      issue + location(item.claim)
    )))
    .flatten()
  (
    evidence: if issues.len() > 0 { none } else {
      (
        contract: program.contract,
        claims: checked.map(item => item.result.evidence),
      )
    },
    issues: issues,
  )
}
