#import "../../core/policy/lib.typ" as policy
#import "../../core/policy/observation.typ" as observation
#import "../../core/semantic.typ"

/// Compile caller-declared wiring against the initial project's contract.
#let evaluate(project, registry: (:), program: none, inputs: none) = {
  assert(
    project.state != none,
    message: "resolve knowledge assembly issues before evaluation",
  )
  let assembled = program(project)
  assert.eq(assembled.issues, (), message: "invalid policy wiring")
  let compiled = policy.compile(
    assembled.wiring,
    semantic.contract(project.state, registry: registry),
  )
  (
    program: compiled,
    execution: policy.evaluate(compiled, inputs: inputs(project)),
  )
}

/// Read an explicitly bound observation without rerunning policies.
#let observe(program, execution, bindings: (), name: none) = {
  let compiled = observation.compile(program, bindings)
  assert.eq(compiled.issues, (), message: "invalid observation bindings")
  observation.query(observation.collect(compiled.plan, execution), name).value
}

#let evaluation-issues(execution) = (
  execution
    .results
    .values()
    .filter(it => it.side == "right" and it.value.kind == "failure")
    .map(it => it.value.issues)
    .flatten()
)
