#import "@preview/t4t:0.3.0": is, assert, def
#import "@preview/cetz:0.0.2"

#import "./draw.typ"
#import "./layout.typ"


/// Draw an automaton from a transition table.
///
/// The transition table #arg[states] has to be a dictionary of dictionaries, having
/// the names of all states as keys in the first level dictionary and names of states,
/// the state has a transition to as keys in the second level dictionaries. The values
/// in the second level dictionary are labels (inputs) for the transitions.
///
/// The following example, defines three states `q0`, `q1` and `q2`. For the input `0`
/// `q0` transitions to `q1` and to `q2` for the inputs `0` and `1`.
/// `q1` transitions to `q0` for `0` and `1` and `q2` for `0`. `q2` has no transitions.
/// #codesnippet[```typ
/// #automaton((
///   q0: (q1:0, q0:"0,1"),
///   q1: (q0:(0,1), q2:"0"),
///   q2: none
/// ))
/// ```]
/// If no initial and final states are defined, #cmd-[automaton] selects the first and last
/// state in the dictionary respectively (`q0` and `q2` in this example).
///
/// As you can see, the transition labels can be provided as a single value or an array.
/// Arrays are joined with a comma (`,`) to generate the final label.
/// #ibox[
///   For now, there is no difference in providing inputs as arrays or strings. Internally,
///   string are split on commas, to get atomic symbols, and later joined again.
///   Future versions might use these symbols, though, to actually simulate the automaton
///   and decide if a word is accepted or not.
/// ]
///
/// #arg[inital] and #arg[final] can be used to customize the initial and final states.
///
/// - states (dictionary): A dictionary of dictionaries, defining the transition table of an automaton.
/// - initial (string, auto, none): The name of the initial state. For #value(auto), the first state in #arg[states] is used.
/// - final (array, auto, none): A list of final state names. For #value(auto), the last state in #arg[states] is used.
/// - style (dictionary): A dictionary with styles for states and transitions.
/// - label-format (function): A function #lambda("string", "boolean", ret:"string") to format labels.
///    The function will get the label as a string and a boolean #arg[is-state], if the label is generated for a state (#value(true)) or a transition (#value(false)). It should return the final label as #dtype("content").
/// - layout (function): A layout function. See below for more information on layouts.
/// - ..canvas-styles (any): Arguments for #cmd-(module:"cetz")[canvas]
#let automaton(
  states,
  initial: auto,
  final: auto,
  style: (:),
  label-format: (label, is-state) => if is-state and is.str(label) and label.starts-with("q") {
    [q#sub(label.slice(1))]
  } else {
    label
  },
  layout: layout.linear,
  ..canvas-styles
) = {
  assert.that(is.dict(states),
    message: (v) => "Need a dictionary with state and transition information. Got " + repr(v))
  if is.a(initial) {
    initial = states.keys().first()
  }
  if is.a(final) {
    final = (states.keys().last(), )
  } else if is.n(final) {
    final = ()
  }

  cetz.canvas(..canvas-styles, {
    import cetz.draw: set-style
    import draw: state, transition

    set-style(..style)

    layout((0,0), {
      for name in states.keys() {
        state((),
          name,
          label: label-format(name, true),
          initial: (name == initial),
          final: (name in final),
          ..style.at(name, default:(:))
        )
      }
    })

    // Transitions don't need to be layed out
    for (from, transitions) in states {
      if is.dict(transitions) {
        for (to, label) in transitions {
          let name = from + "-" + to

          if is.arr(label) {
            label = label.map(str).join(",")
          } else if is.dict(label) and "text" in label and is.arr(label.text) {
            label.text = label.text.map(str).join(",")
          }

          transition(
            from,
            to,
            inputs: label,
            label: label-format(label, false),
            ..style.at(name, default:(:))
          )
        }
      }
    }
  })
}

/// Displays a transition table for an automaton.
///
/// The format for #arg[states] is the same as for @@automaton.
///
/// #example[```
/// #finite.transition-table((
///   q0: (q1: 0, q0: (1,0)),
///   q1: (q0: 1, q2: (1,0)),
///   q2: (q0: 1, q2: 0),
/// ))
/// ```]
///
/// - states (dictionary): A dictionary of dictionaries, defining the transition table of an automaton.
/// - initial (string, auto, none): The name of the initial state. For #value(auto), the first state in #arg[states] is used.
/// - final (array, auto, none): A list of final state names. For #value(auto), the last state in #arg[states] is used.
/// - format (function):
/// - format-list (function):
/// - ..table-style (any): Arguments for #doc("layout/table").
#let transition-table(
  states,
  initial: auto,
  final: auto,
  format: (col, v) => raw(str(v)),
  format-list: (states) => if states.len() > 1 { "{" + states.join(",") + "}"} else { states.join(",") },
  ..table-style
) = {
  assert.that(is.dict(states),
    message: (v) => "Need a dictionary with state and transition information. Got " + repr(v))

  if is.a(initial) {
    initial = states.keys().first()
  }
  if is.a(final) {
    final = (states.keys().last(), )
  } else if is.n(final) {
    final = ()
  }

  let inputs = ()
  for (state, transitions) in states {
    if is.dict(transitions) {
      for (name, label) in transitions {
        if is.str(label) {
          label = label.split(",")
        }
        inputs = inputs + def.as-arr(label)
      }
    }
  }
  inputs = inputs.dedup()
  inputs = inputs.map(str)

  let table-cnt = ()
  for (state, transitions) in states {
    table-cnt.push(format(0, state))
    if is.dict(transitions) {
      for (i, char) in inputs.enumerate() {
        let to = ()
        for (name, label) in transitions {
          if is.str(label) {
            label = label.split(",")
          }
          label = def.as-arr(label).map(str)

          if char in label {
            to.push(format(i+1, name))
          }
        }
        table-cnt.push(format-list(to))
      }
    }
  }

  table(
    columns: 1 + inputs.len(),
    fill: (c,r) => if r == 0 or c == 0 { luma(240) },
    align: center + horizon,
    ..table-style,
    [], ..inputs,
    ..table-cnt
  )
}
