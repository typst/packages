#import "utility.typ"
#import "decorations.typ": lstick, rstick, midstick, nwire, annotate, slice, setwire, gategroup
#import "gates.typ": gate, mqgate, ctrl, swap, targ, meter, phantom, permute, phase, targX
#import "quantum-circuit.typ": quantum-circuit


#let help(..args) = {
  import "@preview/tidy:0.3.0"

  let namespace = (
    ".": (
      read.with("/src/quantum-circuit.typ"), 
      read.with("/src/gates.typ"),
      read.with("/src/decorations.typ"),
    ),
    "gates": read.with("/src/gates.typ"),
  )
  tidy.generate-help(namespace: namespace, package-name: "quill")(..args)
}