#import "src/formula.typ": open, close, assume

#let proof(

framing: (
  length: 3em,
  thickness: .05em,
  stroke: black,
  assume-length: 2.25em,
  assume-thickness: .05em,
  assume-stroke: black
  ),
assumption-mode: "fixed",
indexation: "1",
proof
) = {

let framing-customizables = ("length", "thickness", "stroke", "assume-length", "assume-thickness", "assume-stroke")

let framing-default = (
  length: 3em,
  thickness: .05em,
  stroke: luma(20%),
  assume-length: 2.25em,
  assume-thickness: .05em,
  assume-stroke: black
  )

  for (key, value) in framing-default {
    if key not in framing.keys() {
      framing.insert(key, value)
    }
  }

assert(
  framing.keys().all(key => key in framing-customizables),
  message: "framing can only take " + framing-customizables.join(", ") + "."
)

let framing-model = framing

import "src/framing.typ": framing


let framing = framing(
  framing-model.length,
  framing-model.thickness,
  framing-model.stroke,
  false, // is-short
  false, // isassume
  framing-model.assume-length,
  framing-model.assume-thickness,
  framing-model.assume-stroke
  )

// 1.1
//let assumption-modes = ("fixed", "widest", "dynamic", "dynamic-single")

// 1.0
let assumption-modes = ("fixed", "widest", "dynamic-single")

let assumption-mode-error = "Invalid assumption mode! Can only be" + assumption-modes.join(" or ") + "."

assert(assumption-mode in assumption-modes, message: assumption-mode-error)


import "src/diagram.typ": diagram
import "src/formula.typ": parse

diagram(framing, assumption-mode, parse(proof, indexation))
}