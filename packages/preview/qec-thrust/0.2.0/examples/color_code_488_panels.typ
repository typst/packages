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
#let orange-fill = rgb("#f3b341")
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

#let old-488-oct-id(code, face, idx) = face.qubits.at(idx)
#let old-488-oct-pos(code, face, idx) = find-qubit(code, old-488-oct-id(code, face, idx)).pos

#let label-dot(pos, body, fill: white, stroke: black) = {
  import draw: content
  content(pos, body, frame: "circle", fill: fill, stroke: stroke)
}

#let make-488(loc: (0, 0), name: "obj-488") = color-code-2d(
  loc,
  tiling: "4.8.8",
  shape: "rect",
  size: (rows: 3, cols: 3),
  orientation: "pointy",
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

#let draw-488-basis(loc: (0, 0), name: "obj-488-basis") = {
  import draw: *
  let code = make-488(loc: loc, name: name)
  draw-base(code)

  let square = find-face(code, (2, 2))
  let oct = find-face(code, (3, 3))
  let origin = square.center
  let px = find-face(code, (4, 2)).center
  let py = find-face(code, (2, 4)).center

  line(origin, px, stroke: arrow-stroke, mark: (end: "stealth", fill: black, stroke: (dash: "solid"), scale: 0.7))
  line(origin, py, stroke: arrow-stroke, mark: (end: "stealth", fill: black, stroke: (dash: "solid"), scale: 0.7))
  content(px, anchor: "west", padding: 5pt, text(size: 18pt)[$x$])
  content(py, anchor: "south", padding: 5pt, text(size: 18pt)[$y$])

  let q1 = face-qubit-id(code, square, 1)
  let q3 = face-qubit-id(code, square, 2)
  let q2 = old-488-oct-id(code, oct, 1)
  let q4 = old-488-oct-id(code, oct, 6)

  (code.highlight-qubit)(q1, radius: 0.17, fill: cyan-fill, stroke: (paint: black, thickness: 0.8pt))
  (code.highlight-qubit)(q3, radius: 0.17, fill: rgb("#37b7c7"), stroke: (paint: black, thickness: 0.8pt))
  (code.highlight-qubit)(q2, radius: 0.17, fill: aqua, stroke: (paint: black, thickness: 0.8pt))
  (code.highlight-qubit)(q4, radius: 0.17, fill: magenta-fill, stroke: (paint: black, thickness: 0.8pt))

  label-dot(find-qubit(code, q3).pos, text(size: 14pt)[$3$], fill: rgb("#37b7c7"))
  label-dot(find-qubit(code, q1).pos, text(size: 14pt)[$1$], fill: cyan-fill)
  label-dot(find-qubit(code, q2).pos, text(size: 14pt)[$2$], fill: aqua)
  label-dot(find-qubit(code, q4).pos, text(size: 14pt)[$4$], fill: magenta-fill)
}

#let draw-488-stabilizers(loc: (0, 0), name: "obj-488-stabilizers") = {
  import draw: *
  let code = make-488(loc: loc, name: name)
  draw-base(code)

  let sq1 = find-face(code, (2, 2))
  let sq2 = find-face(code, (4, 4))
  let oct = find-face(code, (3, 3))
  let left-legend = find-face(code, (1, 3)).center
  let right-legend = find-face(code, (5, 5)).center
  let sq-up = find-face(code, (2, 4))

  let sq1-q1 = face-qubit-pos(code, sq1, 1)
  let sq1-q2 = face-qubit-pos(code, sq1, 2)
  let sq2-q0 = face-qubit-id(code, sq2, 0)
  let sq2-q1 = face-qubit-id(code, sq2, 1)
  let sq2-q2 = face-qubit-id(code, sq2, 2)
  let sq2-q3 = face-qubit-id(code, sq2, 3)
  let sq-up-q1 = face-qubit-pos(code, sq-up, 1)

  let oct-q1 = old-488-oct-pos(code, oct, 1)
  let oct-q2 = old-488-oct-pos(code, oct, 2)
  let oct-q3 = old-488-oct-pos(code, oct, 3)
  let oct-q4 = old-488-oct-pos(code, oct, 4)
  let oct-q5 = old-488-oct-pos(code, oct, 5)
  let oct-q6 = old-488-oct-pos(code, oct, 6)
  let oct-q7 = old-488-oct-pos(code, oct, 7)

  line(pt-lerp(sq1-q1, sq-up-q1, 0.08), pt-lerp(sq1-q1, sq-up-q1, 0.92), stroke: dashed-stroke, mark: (end: "stealth", fill: black, stroke: (dash: "solid"), scale: 0.5))
  line(pt-lerp(oct-q1, oct-q4, 0.08), pt-lerp(oct-q1, oct-q4, 0.92), stroke: dashed-stroke, mark: (end: "stealth", fill: black, stroke: (dash: "solid"), scale: 0.5))
  line(pt-lerp(oct-q6, oct-q3, 0.08), pt-lerp(oct-q6, oct-q3, 0.92), stroke: dashed-stroke, mark: (end: "stealth", fill: black, stroke: (dash: "solid"), scale: 0.5))
  line(pt-lerp(oct-q7, oct-q2, 0.08), pt-lerp(oct-q7, oct-q2, 0.92), stroke: dashed-stroke, mark: (end: "stealth", fill: black, stroke: (dash: "solid"), scale: 0.5))
  line(pt-lerp(sq1-q1, face-qubit-pos(code, sq2, 1), 0.05), pt-lerp(sq1-q1, face-qubit-pos(code, sq2, 1), 0.95), stroke: dashed-stroke, mark: (end: "stealth", fill: black, stroke: (dash: "solid"), scale: 0.5))
  line(pt-lerp(sq1-q2, face-qubit-pos(code, sq2, 2), 0.05), pt-lerp(sq1-q2, face-qubit-pos(code, sq2, 2), 0.95), stroke: dashed-stroke, mark: (end: "stealth", fill: black, stroke: (dash: "solid"), scale: 0.5))

  content(oct-q4, anchor: "south", padding: 8pt, text(size: 18pt)[$y$])
  content(oct-q5, anchor: "south", padding: 8pt, text(size: 18pt)[$y$])
  content(oct-q2, anchor: "west", padding: 8pt, text(size: 18pt)[$x$])
  content(oct-q3, anchor: "west", padding: 8pt, text(size: 18pt)[$x$])
  content(face-qubit-pos(code, sq2, 2), anchor: "south", padding: 8pt, text(size: 18pt)[$x y$])
  content(face-qubit-pos(code, sq2, 1), anchor: "west", padding: 8pt, text(size: 18pt)[$x y$])

  (code.highlight-qubit)(sq2-q0, radius: 0.17, fill: magenta-fill, stroke: (paint: black, thickness: 0.8pt))
  (code.highlight-qubit)(sq2-q1, radius: 0.17, fill: cyan-fill, stroke: (paint: black, thickness: 0.8pt))
  (code.highlight-qubit)(sq2-q2, radius: 0.17, fill: orange-fill, stroke: (paint: black, thickness: 0.8pt))
  (code.highlight-qubit)(sq2-q3, radius: 0.17, fill: aqua, stroke: (paint: black, thickness: 0.8pt))
  for idx in (0, 1, 2, 5, 6, 7) {
    let old-fill = if idx == 0 or idx == 5 {
      cyan-fill
    } else if idx == 1 {
      aqua
    } else if idx == 6 {
      magenta-fill
    } else {
      orange-fill
    }
    (code.highlight-qubit)(old-488-oct-id(code, oct, idx), radius: 0.17, fill: old-fill, stroke: (paint: black, thickness: 0.8pt))
  }

  content(left-legend, text(size: 15pt)[$vec(#text(fill: cyan-fill)[$1 + y$], #text(fill: aqua)[$1 + y$], #text(fill: orange-fill)[$1 + x$], #text(fill: magenta-fill)[$1 + x$])$])
  content(right-legend, text(size: 15pt)[$vec(#text(fill: cyan-fill)[$x y$], #text(fill: aqua)[$y$], #text(fill: orange-fill)[$x y$], #text(fill: magenta-fill)[$x$])$])
}

#let draw-488-anyon(loc: (0, 0), name: "obj-488-anyon") = {
  import draw: *
  let code = make-488(loc: loc, name: name)
  draw-base(code)

  let a = find-face(code, (1, 3)).center
  let b = find-face(code, (5, 3)).center
  let c = find-face(code, (3, 5)).center

  for pos in (a, b, c) {
    circle(pos, radius: 0.28, fill: anyon-fill, stroke: (paint: black, thickness: 0.8pt))
  }
  line(pt-lerp(a, b, 0.05), pt-lerp(a, b, 0.94), stroke: arrow-stroke, mark: (end: "stealth", fill: black, stroke: (dash: "solid"), scale: 0.5))
  line(pt-lerp(a, c, 0.05), pt-lerp(a, c, 0.92), stroke: arrow-stroke, mark: (end: "stealth", fill: black, stroke: (dash: "solid"), scale: 0.5))
  content(pt-scale(pt-add(a, b), 0.5), anchor: "north", padding: 10pt, text(size: 16pt)[$x^2 = 1$])
  content(pt-scale(pt-add(a, c), 0.5), anchor: "south-east", padding: 10pt, text(size: 16pt)[$x y = 1$])
}

#let draw-488-label(loc: (0, 0), name: "obj-488-label") = {
  import draw: *
  let code = make-488(loc: loc, name: name)
  draw-base(code)

  for face in code.faces {
    content(face.center, text(size: 7pt)[#face.id])
  }
  for qubit in code.qubits {
    content(qubit.pos, text(size: 4.5pt, fill: gray)[#qubit.id])
  }
}

#let draw-488-panels(loc: (0, 0), gap-x: 12.2, gap-y: 11.0) = {
  let p00 = loc
  let p10 = pt-add(loc, (gap-x, 0))
  let p01 = pt-add(loc, (0, -gap-y))
  let p11 = pt-add(loc, (gap-x, -gap-y))

  draw-488-basis(loc: p00, name: "obj-488-basis-panel")
  draw-488-stabilizers(loc: p10, name: "obj-488-stabilizers-panel")
  draw-488-anyon(loc: p01, name: "obj-488-anyon-panel")
  draw-488-label(loc: p11, name: "obj-488-label-panel")
}

#canvas({
  draw-488-panels()
})
