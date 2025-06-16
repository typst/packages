#import "./draw.typ"
#import "./layout.typ"
#let _layout = layout
#import "./util.typ" as util: to-spec, cetz


/// Draw an automaton from a specification.
///
/// #arg[spec] is a dictionary with a specification for a
/// finite automaton. See above for a description of the
/// specification dictionaries.
///
/// The following example defines three states `q0`, `q1` and `q2`.
/// For the input `0`, `q0` transitions to `q1` and for the inputs `0` and `1` to `q2`.
/// `q1` transitions to `q0` for `0` and `1` and to `q2` for `0`. `q2` has no transitions.
/// #codesnippet[```typ
/// #automaton((
///   q0: (q1:0, q0:(0, 1)),
///   q1: (q0:(0, 1), q2:0),
///   q2: none
/// ))
/// ```]
///
/// #arg[inital] and #arg[final] can be used to customize the initial and final states.
/// #info-alert[The #arg[inital] and #arg[final] will be removed in future
///   versions in favor of automaton specs.
/// ]
///
/// - spec (spec): Automaton specification.
/// - initial (string, auto, none): The name of the initial state. For #value(auto), the first state in #arg[spec] is used.
/// - final (array, auto, none): A list of final state names. For #value(auto), the last state in #arg[spec] is used.
/// - labels (dictionary): A dictionary with labels for states and transitions.
///   #example[```
///   #finite.automaton(
///     (q0: (q1:none), q1: none),
///     labels: (q0: [START], q1: [END])
///   )
///   ```]
/// - style (dictionary): A dictionary with styles for states and transitions.
/// - state-format (function): A function #lambda("string", ret:"content") to format state labels.
///    The function will get the states name as a string and should return the final label as #dtype("content").
///   #example[```
///   #finite.automaton(
///     (q0: (q1:none), q1: none),
///     state-format: (label) => upper(label)
///   )
///   ```]
/// - input-format (function): A function #lambda("array", ret:"content")
///   to generate transition labels from input values. The functions will be
///   called with the array of inputs and should return the final label for
///   the transition. This is only necessary, if no label is specified.
///   #example[```
///   #finite.automaton(
///     (q0: (q1:(3,0,2,1,5)), q1: none),
///     input-format: (inputs) => inputs.sorted().rev().map(str).join("|")
///   )
///   ```]
/// - layout (dictionary,function): Either a dictionary with (`state`: `coordinate`)
///   pairs, or a layout function. See below for more information on layouts.
///   #example[```
///   #finite.automaton(
///     (q0: (q1:none), q1: none),
///     layout: (q0: (0,0), q1: (rel:(-2,1)))
///   )
///   ```]
/// - ..canvas-styles (any): Arguments for #cmd-(module:"cetz")[canvas]
/// -> content
#let automaton(
  spec,
  initial: auto,
  final: auto,
  labels: (:),
  style: (:),
  state-format: label => {
    let m = label.match(regex(`^(\D+)(\d+)$`.text))
    if m != none {
      [#m.captures.at(0)#sub(m.captures.at(1))]
    } else {
      label
    }
  },
  input-format: inputs => inputs.map(str).join(","),
  layout: layout.linear,
  ..canvas-styles,
) = {
  spec = to-spec(spec, initial: initial, final: final)

  // use a dict with coordinates as custom layout
  if util.is.dict(layout) {
    layout = _layout.custom.with(positions: layout)
  }

  let layout-name(p) = ("aut", p).filter(util.is.not-none).join(".")

  cetz.canvas(
    ..canvas-styles,
    {
      import cetz.draw: set-style
      import draw: state, transition

      set-style(..style)

      layout(
        (0, 0),
        name: layout-name(none),
        {
          for name in spec.states {
            state(
              (),
              name,
              label: labels.at(name, default: state-format(name)),
              initial: (name == spec.initial),
              final: (name in spec.final),
              ..style.at(name, default: (:)),
            )
          }
        },
      )

      // Transitions don't need to be positioned
      for (from, transitions) in spec.transitions {
        if util.is.dict(transitions) {
          for (to, inputs) in transitions {
            let name = from + "-" + to

            // prepare inputs (may be a string or int)
            if inputs == none {
              inputs = ()
            } else if not util.is.arr(inputs) {
              inputs = str(inputs).split(",")
            }

            // prepare label
            let label = labels.at(
              name,
              default: input-format(inputs),
            )
            if util.is.dict(label) and "text" not in label {
              label.text = input-format(inputs)
            }

            // create transition
            transition(
              layout-name(from),
              layout-name(to),
              inputs: inputs,
              label: label,
              ..style.at(name, default: (:)),
            )
          }
        }
      }
    },
  )
}

/// Displays a transition table for an automaton.
///
/// #arg[spec] is a dictionary with a specification for a
/// finite automaton. See above for a description of the
/// specification dictionaries.
///
/// The table will show states in rows and inputs in columns:
/// #example(```
/// #finite.transition-table((
///   q0: (q1: 0, q0: (1,0)),
///   q1: (q0: 1, q2: (1,0)),
///   q2: (q0: 1, q2: 0),
/// ))
/// ```)
///
/// #info-alert[The #arg[inital] and #arg[final] will be removed in future
///   versions in favor of automaton specs.
/// ]
///
/// - spec (spec): Automaton specification.
/// - initial (string, auto, none): The name of the initial state. For #value(auto), the first state in #arg[states] is used.
/// - final (array, auto, none): A list of final state names. For #value(auto), the last state in #arg[states] is used.
/// - format (function): A function to format the value in a table column. The function takes a column index and
///   a string and generates content: #lambda("integer", "string", ret:"content").
///   #example[```
///   #finite.transition-table((
///     q0: (q1: 0, q0: (1,0)),
///     q1: (q0: 1, q2: (1,0)),
///     q2: (q0: 1, q2: 0),
///   ), format: (col, value) => if col == 1 { strong(value) } else [#value])
///   ```]
/// - format-list (function): Formats a list of states for display in a table cell. The function takes an array of state names and generates a string to be passed to #arg[format]:
/// #lambda("array", ret:"string")
///   #example[```
///   #finite.transition-table((
///     q0: (q1: 0, q0: (1,0)),
///     q1: (q0: 1, q2: (1,0)),
///     q2: (q0: 1, q2: 0),
///   ), format-list: (states) => "[" + states.join(" | ") + "]")
///   ```]
/// - ..table-style (any): Arguments for #builtin("table").
/// -> content
#let transition-table(
  spec,
  initial: auto,
  final: auto,
  format: (col, v) => raw(str(v)),
  format-list: states => states.join(", "),
  ..table-style,
) = {
  spec = to-spec(spec, initial: initial, final: final)

  let table-cnt = ()
  for (state, transitions) in spec.transitions {
    table-cnt.push(format(0, state))
    if util.is.dict(transitions) {
      for (i, char) in spec.inputs.enumerate() {
        let to = ()
        for (name, label) in transitions {
          if util.is.str(label) {
            label = label.split(",")
          }
          label = util.def.as-arr(label).map(str)

          if char in label {
            to.push(format(i + 1, name))
          }
        }
        table-cnt.push(format-list(to))
      }
    }
  }

  table(
    columns: 1 + spec.inputs.len(),
    fill: (c, r) => if r == 0 or c == 0 {
      luma(240)
    },
    align: center + horizon,
    ..table-style,
    [], ..spec.inputs.map(raw),
    ..table-cnt
  )
}


/// Creates a deterministic finite automaton from a nondeterministic one by using powerset construction.
///
/// See #link("https://en.wikipedia.org/wiki/Powerset_construction")[the Wikipedia article on powerset construction] for further
/// details on the algorithm.
///
/// #arg[spec] is a dictionary with a specification for a
/// finite automaton. See above for a description of the
/// specification dictionaries.
///
/// - spec (spec): Automaton specification.
/// - initial (string, auto, none): The name of the initial state. For #value(auto), the first state in #arg[states] is used.
/// - final (array, auto, none): A list of final state names. For #value(auto), the last state in #arg[states] is used.
/// - state-format (function): A function to generate the new state names from a list of states.
///   The function takes an array of strings and returns a string: #lambda("array", ret:"string").
#let powerset(
  spec,
  initial: auto,
  final: auto,
  state-format: states => "{" + states.sorted().join(",") + "}",
) = {
  spec = to-spec(spec, initial: initial, final: final)

  let table = util.transpose-table(spec.transitions)

  let (new-initial, new-final) = (
    state-format((spec.initial,)),
    (),
  )

  let powerset = (:)
  let queue = ((spec.initial,),)
  while queue.len() > 0 {
    let cur = queue.remove(0)
    let key = state-format(cur)

    if key not in powerset {
      powerset.insert(key, (:))

      if cur.any(s => s in spec.final) {
        new-final.push(key)
      }

      for inp in spec.inputs {
        let trans = ()
        for s in cur {
          let s-trans = table.at(s)
          if inp in s-trans {
            trans += s-trans.at(inp)
          }
        }
        trans = trans.dedup().sorted()
        powerset.at(key).insert(inp, trans)
        queue.push(trans)
      }
    }
  }

  for (s, t) in powerset {
    for (i, states) in t {
      powerset.at(s).at(i) = state-format(states)
    }
  }

  return to-spec(
    util.transpose-table(powerset),
    initial: new-initial,
    final: new-final,
    inputs: spec.inputs,
  )
}

/// Adds a trap state to a partial DFA and completes it.
///
/// Deterministic automata need to specify a transition for every
/// possible input. If those inputs don't transition to another
/// state, a trap-state is introduced, that is not final
/// and can't be left by any input. To simplify
/// transition diagrams, these trap-states are oftentimes
/// not drawn. This function adds a trap-state to such a
/// partial automaton and thus completes it.
///
/// #example[```
/// #finite.transition-table(finite.add-trap((
///   q0: (q1: 0),
///   q1: (q0: 1)
/// )))
/// ```]
///
/// // >>> finite.add-trap((transitions: (q0: (q1: ())), inputs: (0,1))) == finite.to-spec((transitions: (q0: (TRAP:("0","1")), TRAP: (TRAP: ("0","1"))), inputs: ("0","1")))
///
/// - spec (spec): Automaton specification.
/// - trap-name (string): Name for the new trap-state.
#let add-trap(spec, trap-name: "TRAP") = {
  spec = to-spec(spec)

  let table = util.transpose-table(spec.transitions)

  let trap-added = false
  for (s, values) in table {
    for inp in spec.inputs {
      if inp not in values {
        values.insert(inp, (trap-name,))
        trap-added = true
      }
    }
    table.at(s) = values
  }

  if trap-added {
    table.insert(
      trap-name,
      spec.inputs.fold(
        (:),
        (d, i) => {
          d.insert(i, (trap-name,))
          return d
        },
      ),
    )
  }

  spec.at("transitions") = util.transpose-table(table)
  return spec
}


/// Tests if a #arg[word] is accepted by a given automaton.
///
/// The result if either #value(false) or an array of tuples
/// with a state name and the input used to transition to the
/// next state. The array is a possible path to an accepting
/// final state. The last tuple always has #value(none) as
/// an input.
/// #example[```
/// #let aut = (
///   q0: (q1: 0),
///   q1: (q0: 1)
/// )
/// #finite.accepts(aut, "01010")
///
/// #finite.accepts(aut, "0101")
/// ```]
///
/// - spec (spec): Automaton specification.
/// - word (string): A word to test.
/// - format (function): A function to format the result.
#let accepts(
  spec,
  word,
  format: states => states.map(((s, i)) => if i != none [
    #s #box[#sym.arrow.r#place(top + center, dy: -88%)[#text(.88em, raw(i))]]
  ] else [#s]).join(),
) = {
  spec = to-spec(spec)

  let (transitions, initial, final) = (
    spec.at("transitions", default: (:)),
    spec.at("initial", default: none),
    spec.at("final", default: ()),
  )
  transitions = util.transpose-table(transitions)

  util.assert.not-empty(transitions)
  util.assert.not-empty(initial)
  util.assert.not-empty(final)

  let traverse(word, state) = {
    if word.len() > 0 {
      let symbol = word.at(0)
      if state in transitions {
        if symbol in transitions.at(state) {
          for next-state in transitions.at(state).at(symbol) {
            let states = traverse(word.slice(1), next-state)
            if states != false {
              return ((state, symbol),) + states
            }
          }
        }
      }
      return false
    }
    // Word accepted?
    if state in final {
      return ((state, none),)
    } else {
      return false
    }
  }

  let result = traverse(word, initial)
  if result == false {
    return false
  } else {
    return format(result)
  }
}
