#import "@preview/cetz:0.4.0": canvas
#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 5pt)
#set text(font: "New Computer Modern")
#show math.equation: set text(font: "New Computer Modern Math")

#let soft-red = red.lighten(80%)
#let soft-green = green.lighten(80%)
#let soft-blue = blue.lighten(80%)
#let anyon-fill = green
#let cyan-fill = rgb("#40b8cc")
#let magenta-fill = rgb("#c02dd8")
#let lattice-stroke = (paint: rgb("#bcbcbc"), thickness: 1pt)
#let qubit-stroke = (paint: rgb("#bcbcbc"), thickness: 0.8pt)
#let arrow-stroke = (paint: black, thickness: 1pt)
#let dashed-stroke = (paint: black, thickness: 1pt, dash: "dashed")
#let qubit-radius = 0.14

#let pt-add(a, b) = (a.at(0) + b.at(0), a.at(1) + b.at(1))
#let pt-scale(p, s) = (p.at(0) * s, p.at(1) * s)
#let pt-lerp(a, b, t) = (
  a.at(0) + (b.at(0) - a.at(0)) * t,
  a.at(1) + (b.at(1) - a.at(1)) * t,
)

#let format-id(id) = {
  if type(id) == array and id.len() > 0 {
    str(id.at(0)) + id.slice(1).fold("", (acc, part) => acc + "-" + str(part))
  } else {
    str(id)
  }
}

#let face-id(id) = {
  let text = format-id(id)
  if text.starts-with("f-") { text } else { "f-" + text }
}

#let qubit-id(id) = {
  let text = format-id(id)
  if text.starts-with("q-") { text } else { "q-" + text }
}

#let find-face(code, id) = {
  let target = face-id(id)
  let found = none
  for face in code.faces {
    if found == none and face.id == target {
      found = face
    }
  }
  assert(found != none, message: "Unknown face id " + target + ".")
  found
}

#let find-qubit(code, id) = {
  let target = qubit-id(id)
  let found = none
  for qubit in code.qubits {
    if found == none and qubit.id == target {
      found = qubit
    }
  }
  assert(found != none, message: "Unknown qubit id " + target + ".")
  found
}

#let draw-open-qubits(code, radius: qubit-radius) = {
  import draw: circle
  for qubit in code.qubits {
    circle(qubit.pos, radius: radius, fill: white, stroke: qubit-stroke)
  }
}

#let face-qubit-id(code, face, idx) = face.qubits.at(idx)
#let face-qubit-pos(code, face, idx) = find-qubit(code, face-qubit-id(code, face, idx)).pos

#let label-dot(pos, body, fill: white, stroke: black) = {
  import draw: content
  content(pos, body, frame: "circle", fill: fill, stroke: stroke)
}

#let highlight-pos(pos, fill, radius: 0.17) = {
  import draw: circle
  circle(pos, radius: radius, fill: fill, stroke: (paint: black, thickness: 0.8pt))
}

#let make-666(loc: (0, 0), name: "obj-666") = color-code-2d(
  loc,
  tiling: "6.6.6",
  shape: "hex",
  size: (lx: 3, ly: 3, lz: 3),
  orientation: "flat",
  scale: 1.0,
  color1: soft-red,
  color2: soft-green,
  color3: soft-blue,
  name: name,
  stroke: lattice-stroke,
  show-qubits: false,
)

#let draw-base(code) = {
  (code.draw-background)()
  draw-open-qubits(code)
}

#let draw-666-basis(loc: (0, 0), name: "obj-666-basis") = {
  import draw: *
  let code = make-666(loc: loc, name: name)
  draw-base(code)

  let face = find-face(code, (0, 0))
  let y-face = find-face(code, (-1, 1))
  let q1 = face-qubit-pos(code, face, 3)
  let q2 = face-qubit-pos(code, face, 4)
  let qx = face-qubit-pos(code, face, 5)
  let qy = face-qubit-pos(code, y-face, 1)

  highlight-pos(q1, cyan-fill)
  highlight-pos(q2, magenta-fill)
  line(q1, qx, stroke: arrow-stroke, mark: (end: "stealth", fill: black, stroke: (dash: "solid"), scale: 0.7))
  line(q1, qy, stroke: arrow-stroke, mark: (end: "stealth", fill: black, stroke: (dash: "solid"), scale: 0.7))

  label-dot(q1, text(size: 14pt)[$1$], fill: cyan-fill)
  label-dot(q2, text(size: 14pt)[$2$], fill: magenta-fill)
  content(qx, anchor: "north-west", padding: 3pt, text(size: 18pt)[$x$])
  content(qy, anchor: "south", padding: 5pt, text(size: 18pt)[$y$])
}

#let draw-666-stabilizers(loc: (0, 0), name: "obj-666-stabilizers") = {
  import draw: *
  let code = make-666(loc: loc, name: name)
  draw-base(code)

  let face = find-face(code, (0, 0))
  let q0 = face-qubit-pos(code, face, 0)
  let q1 = face-qubit-pos(code, face, 1)
  let q2 = face-qubit-pos(code, face, 2)
  let q3 = face-qubit-pos(code, face, 3)
  let q4 = face-qubit-pos(code, face, 4)
  let q5 = face-qubit-pos(code, face, 5)
  for (i, qid) in face.qubits.enumerate() {
    let fill = if calc.even(i) { magenta-fill } else { cyan-fill }
    (code.highlight-qubit)(qid, radius: 0.17, fill: fill, stroke: (paint: black, thickness: 0.8pt))
  }

  line(pt-lerp(q3, q1, 0.1), pt-lerp(q3, q1, 0.9), stroke: dashed-stroke, mark: (end: "stealth", fill: black, stroke: (dash: "solid"), scale: 0.5))
  line(pt-lerp(q3, q5, 0.1), pt-lerp(q3, q5, 0.9), stroke: dashed-stroke, mark: (end: "stealth", fill: black, stroke: (dash: "solid"), scale: 0.5))
  line(pt-lerp(q4, q2, 0.1), pt-lerp(q4, q2, 0.9), stroke: dashed-stroke, mark: (end: "stealth", fill: black, stroke: (dash: "solid"), scale: 0.5))
  line(pt-lerp(q4, q0, 0.1), pt-lerp(q4, q0, 0.9), stroke: dashed-stroke, mark: (end: "stealth", fill: black, stroke: (dash: "solid"), scale: 0.5))

  content(q1, anchor: "south-west", padding: 5pt, text(size: 18pt)[$x y$])
  content(q5, anchor: "north-west", padding: 5pt, text(size: 18pt)[$x$])
  content(q2, anchor: "south-east", padding: 5pt, text(size: 18pt)[$y$])
  content(q0, anchor: "west", padding: 8pt, text(size: 18pt)[$x y$])
  content(q3, anchor: "east", padding: 10pt, text(size: 16pt)[$vec(#text(fill: cyan-fill)[$1 + x + x y$], #text(fill: magenta-fill)[$1 + y + x y$])$])
}

#let draw-666-anyon(loc: (0, 0), name: "obj-666-anyon") = {
  import draw: *
  let code = make-666(loc: loc, name: name)
  draw-base(code)

  let a = find-face(code, (-1, 1)).center
  let b = find-face(code, (1, 0)).center
  let c = find-face(code, (2, -2)).center

  for pos in (a, b, c) {
    circle(pos, radius: 0.28, fill: anyon-fill, stroke: (paint: black, thickness: 0.8pt))
  }
  line(pt-lerp(a, b, 0.1), pt-lerp(a, b, 0.9), stroke: arrow-stroke, mark: (end: "stealth", fill: black, stroke: (dash: "solid"), scale: 0.5))
  line(pt-lerp(a, c, 0.05), pt-lerp(a, c, 0.94), stroke: arrow-stroke, mark: (end: "stealth", fill: black, stroke: (dash: "solid"), scale: 0.5))
  content(pt-scale(pt-add(a, b), 0.5), anchor: "south", padding: 15pt, text(size: 16pt)[$x^2 y = 1$])
  content(pt-scale(pt-add(a, c), 0.5), anchor: "north", padding: 15pt, text(size: 16pt)[$x^3 = 1$])
}

#let draw-666-label(loc: (0, 0), name: "obj-666-label") = {
  import draw: *
  let code = make-666(loc: loc, name: name)
  draw-base(code)

  for face in code.faces {
    content(face.center, text(size: 7pt)[#face.id])
  }
  for qubit in code.qubits {
    content(qubit.pos, text(size: 4.5pt, fill: gray)[#qubit.id])
  }
}

#let draw-666-panels(loc: (0, 0), gap-x: 11.2, gap-y: 9.8) = {
  let p00 = loc
  let p10 = pt-add(loc, (gap-x, 0))
  let p01 = pt-add(loc, (0, -gap-y))
  let p11 = pt-add(loc, (gap-x, -gap-y))

  draw-666-basis(loc: p00, name: "obj-666-basis-panel")
  draw-666-stabilizers(loc: p10, name: "obj-666-stabilizers-panel")
  draw-666-anyon(loc: p01, name: "obj-666-anyon-panel")
  draw-666-label(loc: p11, name: "obj-666-label-panel")
}

#canvas({
  draw-666-panels()
})
