#import "@preview/blockst:0.2.0": blockst, scratch

#set page(width: auto, height: auto, margin: 3mm, fill: white)

#let script = "when green flag clicked\ngo to (random position v)\nturn cw (30) degrees"

#blockst[
  #scratch(script)
]

#v(5mm)

#blockst(theme: "high-contrast")[
  #scratch(script)
]

#v(5mm)

#blockst(theme: "print")[
  #scratch(script)
]
