/// Compile resolved wiring into staged morphisms and evaluate their outputs.
#import "clone.typ"
#import "result.typ"

/// Fix the common carrier and lift each invocation without running policies.
/// Every stage retains prior results through projections and appends one
/// output per ready invocation. Shared predecessors are read, never rerun.
/// Wiring must be the successful result of assemble; contract comes from
/// semantic.contract. A program has no distinguished final output.
#let compile(wiring, contract) = {
  let count = wiring.inputs.len()
  let stages = ()
  for layer in wiring.layers {
    let retained = range(count).map(i => clone.projection(count, i))
    let outputs = layer.map(id => {
      let call = wiring.calls.at(id)
      let operation = result.lift(contract, id, call.definition)
      let arguments = clone.tuple(
        count,
        call.ports.map(port => clone.projection(count, port)),
      )
      clone.bind(operation, arguments)
    })
    stages.push(clone.tuple(count, retained + outputs))
    count += layer.len()
  }
  (wiring: wiring, contract: contract, stages: stages)
}

/// Interpret a multi-output morphism on one shared ordered input context.
#let apply(stage, arguments) = {
  assert(
    arguments.len() == stage.arity,
    message: "stage input count mismatch",
  )
  stage.outputs.map(operation => (operation.apply)(arguments))
}

/// External GraphStates enter as successes under the program's contract.
/// All declared vertices are evaluated and returned by identity, including
/// disconnected branches. Error propagation belongs entirely to lifted ops.
#let evaluate(program, inputs: ()) = {
  assert(type(inputs) == array, message: "policy inputs must be an array")
  assert(
    inputs.len() == program.wiring.inputs.len(),
    message: "policy input count does not match program",
  )
  let initial = inputs.map(state => result.success(program.contract, state))
  let values = program.stages.fold(initial, (values, stage) => apply(
    stage,
    values,
  ))
  let results = program
    .wiring
    .ids
    .zip(values)
    .fold((:), (table, pair) => {
      let (id, value) = pair
      table.insert(id, value)
      table
    })
  (results: results)
}
