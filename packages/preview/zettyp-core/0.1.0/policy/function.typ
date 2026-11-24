/// Pure policy functions and local invocation declarations.
///
/// A policy consumes an ordered list of GraphStates and returns one GraphState.
/// The declared arity is checked here; the implementation's actual signature
/// and result are checked when evaluated.

/// Declare a named implementation. Registration is local and immutable.
///
/// (p.invoke)(inputs: ("left", "right"), output: "result") declares a call;
/// it does not execute run. Input position identifies the argument port.
#let function(name, run, inputs: 1, check: none) = {
  assert(
    type(name) == str and name != "",
    message: "policy name must be a non-empty string",
  )
  // Compare types without referring to the shadowed built-in `function` name.
  assert(
    type(run) == type(() => none),
    message: "policy implementation must be a function",
  )
  assert(
    type(inputs) == int and inputs >= 0,
    message: "policy input count must be a non-negative integer",
  )

  assert(
    check == none or type(check) == type(() => none),
    message: "policy check must be a function or none",
  )

  let definition = (name: name, run: run, inputs: inputs, check: check)
  let invoke(inputs: (), output: none) = {
    assert(type(inputs) == array, message: "policy inputs must be an array")
    assert(
      inputs.len() == definition.inputs,
      message: "policy "
        + name
        + " expects "
        + str(definition.inputs)
        + " inputs",
    )
    assert(
      inputs.all(id => type(id) == str and id != ""),
      message: "input product identities must be non-empty strings",
    )
    assert(
      type(output) == str and output != "",
      message: "output product identity must be a non-empty string",
    )
    (policy: definition, inputs: inputs, output: output)
  }

  definition + (invoke: invoke)
}

/// Check ordered arguments before running; issues are local to this call.
#let apply(policy, inputs) = {
  assert(inputs.len() == policy.inputs, message: "policy input count mismatch")
  let issues = if policy.check == none { () } else { (policy.check)(..inputs) }
  assert(
    type(issues) == array,
    message: "policy check must return an issue array",
  )
  if issues.len() > 0 {
    return (status: "failure", issues: issues)
  }
  (status: "success", value: (policy.run)(..inputs))
}
