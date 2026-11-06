#import "@preview/fletcher:0.5.3": diagram, node, edge

#let get-node-label(state, automat-type, sf) = {
  if automat-type == "MOORE" {
    return par(spacing: sf * 4pt)[#{state.Name + line(length: sf * state.Radius * 0.7pt, stroke: sf * 0.5pt) + state.at("Output", default: "")}]
  } else {
    return state.Name
  }
}

#let get-edge-label(labels, automat-type) = {
  if automat-type == "MEALY" {
    return labels.map(lbl => lbl.join(" / ")).join("\n")
  } else if automat-type == "TM" {
    return labels.map(lbl => lbl.at(0) + ":" + lbl.at(1) + "," + lbl.at(2)).join("\n")
  } else {
    return labels.join(", ")
  }
}

#let flautomat(data, scaling-factor: 1) = {
let automat = data.automaton
if data.type not in ("DEA", "NEA", "MEALY", "MOORE", "TM") {return "Sorry, this type of automata is not supported."}
let sf = scaling-factor

diagram(
  spacing: sf * 3.5em,
  debug: 0,
  edge-stroke: sf * 0.5pt,
  node-stroke: sf * 0.5pt,
  node-shape: circle,
  mark-scale: sf * 200%,
  {

  for state in automat.States {
    let coords = (sf * state.x / 100, sf * state.y / 100)
    if state.Final {
      node(coords, get-node-label(state, data.type, sf),  name: str(state.ID), radius: sf * state.Radius * 0.5pt, extrude: (0pt, sf * 4pt), outset: sf * 4pt)
    } else {
      node(coords, get-node-label(state, data.type, sf),  name: str(state.ID), radius: sf * state.Radius * 0.5pt)
    }
  }

  for state in automat.States {
    for trans in state.Transitions {
      if trans.Target != trans.Source {
        edge(label(str(trans.Source)), label(str(trans.Target)), "->", label: get-edge-label(trans.Labels, data.type), bend: if trans.x != 0 or trans.y != 0 {18deg} else {0deg})
      } else {
        edge(label(str(trans.Source)), label(str(trans.Target)), "->", label: get-edge-label(trans.Labels, data.type), loop-angle: -calc.atan2(trans.x, trans.y), bend: 120deg)
      }
    }
  }

  for state in automat.States {
    if state.Start {
      node((sf * state.x / 100 - 1, sf * state.y / 100), name: "start")
      edge(label("start"), label(str(state.ID)), "->", label: "Start")
    }
  }

})
}

