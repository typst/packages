
#let ion-colors = (
  y: color.red,
  b: color.blue,
  yp: color.red,
  ystar: color.red,
  "y*": color.red,
  yO: color.orange,
  x: color.orange,
  bstar: color.blue,
  "b*": color.blue,
  bO: rgb("#ff00ff"),
  a: color.green,
  astar: color.green,
  aO: color.green,
  c: color.blue,
  z: color.red,
  bp: color.blue
)

#let psm-ionlabel(name, size, charge) = [
  #let str_charge = ("", "+", "++", "+++")
  $#name _#size^#str_charge.at(charge)$
]
