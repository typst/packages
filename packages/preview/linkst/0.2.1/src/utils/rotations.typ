#import "@preview/cetz:0.4.0"
#import cetz.vector: *

#let rot-90(v) = {
  return (v.at(1), -v.at(0))
}

#let rot--90(v) = {
  return (-v.at(1), v.at(0))
}

#let rot-around(origin, v, angle) = {
  let d = sub(v, origin)
  d = rotate-z(d, angle)
  return add(origin, d)
}