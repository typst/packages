#import "@preview/blockst:0.2.1": blockst, scratch

#set page(width: auto, height: auto, margin: 3mm, fill: none)

#let script = "when green flag clicked\ngo to (random position v)\nturn cw (30) degrees"


#blockst(inset-scale: 50%)[
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
