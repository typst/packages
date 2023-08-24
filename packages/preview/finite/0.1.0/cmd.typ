#import "@preview/t4t:0.3.0": is, assert, def
#import "@preview/cetz:0.0.2"

#import "./draw.typ"
#import "./layout.typ"


/// Draw an automaton from a transition table.
///
/// - states (dictionary): A dictionary of dictionaries, defining the transition table of an automaton.
/// - start (string, auto, none): The name of the initial state. For #value(auto), the first state in #arg[states] is used.
/// - stop (array, auto, none): A list of final state names. For #value(auto), the last state in #arg[states] is used.
/// - style (dictionary): A dictionary with styles for states and transitions.
/// - label-format (function): A function #lambda("string", "boolean", ret:"string") to format labels.
/// - layout (function: A layout function.
/// - ..canvas-styles (any): Arguments for #cmd-(module:"cetz")[canvas]
#let automaton(
  states,
  start: auto,
  stop: auto,
  style: (:),
  label-format: (label, state:true) => if state and is.str(label) and label.starts-with("q") {
    [q#sub(label.slice(1))]
  } else {
    label
  },
  layout: layout.linear,
  ..canvas-styles
) = {
  assert.that(is.dict(states),
    message: (v) => "Need a dictionary with state and transition information. Got " + repr(v))
  if is.a(start) {
    start = states.keys().first()
  }
  if is.a(stop) {
    stop = (states.keys().last(), )
  } else if is.n(stop) {
    stop = ()
  }
  let positions = layout(states, start, stop)

  cetz.canvas(..canvas-styles, {
    import cetz.draw: set-style
    import draw: state, transition

    set-style(
      state: style.at("state", default:(:)),
      transition: style.at("transition", default:(:))
    )

    for (name, pos) in positions {
      state(
        pos,
        name,
        label: label-format(name, state:true),
        start: (name == start),
        stop: (name in stop),
        ..style.at(name, default:(:))
      )
    }
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
            label: label-format(label, state:false),
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
///   q0: (q1: 0, q0: 1),
///   q1: (q0: 1, q2: 0),
///   q2: (q0: 1, q2: 0),
/// ))
/// ```]
///
/// - states (dictionary): A dictionary of dictionaries, defining the transition table of an automaton.
/// - start (string, auto, none): The name of the initial state. For #value(auto), the first state in #arg[states] is used.
/// - stop (array, auto, none): A list of final state names. For #value(auto), the last state in #arg[states] is used.
#let transition-table(
  states,
  start: auto,
  stop: auto,
  format: (col, v) => raw(str(v))
) = {
  assert.that(is.dict(states),
    message: (v) => "Need a dictionary with state and transition information. Got " + repr(v))

  if is.a(start) {
    start = states.keys().first()
  }
  if is.a(stop) {
    stop = (states.keys().last(), )
  } else if is.n(stop) {
    stop = ()
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
        table-cnt.push(to.join(", "))
      }
    }
  }

  table(
    columns: 1 + inputs.len(),
    [], ..inputs,
    ..table-cnt
  )
}


#let transition-table2(
  states,
  start: auto,
  stop: auto,
  format: (col, v) => raw(str(v))
) = {
  assert.that(is.dict(states),
    message: (v) => "Need a dictionary with state and transition information. Got " + repr(v))

  if is.a(start) {
    start = states.keys().first()
  }
  if is.a(stop) {
    stop = (states.keys().last(), )
  } else if is.n(stop) {
    stop = ()
  }

  let table-cnt = ()
  for (state, transitions) in states {
    if is.dict(transitions) {
      for (name, label) in transitions {
        if is.str(label) {
          label = label.split(",")
        }

        for char in def.as-arr(label) {
          table-cnt.push(format(0, state))
          table-cnt.push(format(1, char))
          table-cnt.push(format(2, name))
        }
      }
    }
  }

  table(
    columns: 3,
    ..table-cnt
  )
}
