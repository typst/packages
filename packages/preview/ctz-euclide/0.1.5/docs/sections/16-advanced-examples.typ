// Advanced Examples
#import "../helpers.typ": *

= Advanced Examples

#full-figure(
  "Ellipse and Circles Tangency",
  {
    import cetz.draw: *
    ctz-init()

    let a = 3
    let b = 2

    let blue-stroke = (paint: blue, thickness: 0.8pt)
    let green-stroke = (paint: green, thickness: 0.8pt)
    let red-stroke = (paint: red, thickness: 0.8pt)

    // Axes
    ctz-def-points(O: (0, 0), X1: (-5, 0), X2: (5, 0), Y1: (0, -5), Y2: (0, 5))
    ctz-draw(line: ("X1", "X2"), stroke: (paint: black, thickness: 0.6pt))
    ctz-draw(line: ("Y1", "Y2"), stroke: (paint: black, thickness: 0.6pt))

    // Circles and ellipse
    ctz-def-circle("C", "O", radius: a)
    ctz-def-circle("Cp", "O", radius: b)
    ctz-draw("C", stroke: blue-stroke)
    ctz-draw("Cp", stroke: green-stroke)
    ctz-draw(ellipse: ("O", b, a, 0deg), stroke: red-stroke)

    // Key points H, H'
    ctz-def-points(H: (a / 2, 0), Hp: (0, -b / 2))

    // Lines through H and H'
    ctz-def-perp("L1a", "L1b", ("X1", "X2"), "H")
    ctz-def-para("L2a", "L2b", ("X1", "X2"), "Hp")

    // Intersections with circles
    ctz-def-lc(("M", "M2"), ("L1a", "L1b"), "C", near: "H")
    ctz-def-lc(("N", "N2"), ("L2a", "L2b"), "Cp", near: "Hp")

    // Project M, N onto ellipse
    ctz-def-ellipse-project("Mp", "O", b, a, "M")
    ctz-def-ellipse-project("Np", "O", b, a, "N")

    // Dashed construction
    ctz-draw(line: ("H", "M"), stroke: (paint: black, thickness: 0.6pt, dash: "dashed"))
    ctz-draw(line: ("Hp", "Np"), stroke: (paint: black, thickness: 0.6pt, dash: "dashed"))

    // Radii
    ctz-draw(line: ("O", "M"), stroke: blue-stroke)
    ctz-draw(line: ("O", "N"), stroke: green-stroke)

    // Tangents at M and N
    ctz-def-tangent-at("TgM1", "TgM2", "M", "O")
    ctz-def-tangent-at("TgN1", "TgN2", "N", "O")
    ctz-draw(line: ("TgM1", "TgM2"), stroke: blue-stroke)
    ctz-draw(line: ("TgN1", "TgN2"), stroke: green-stroke)

    // Intersections with axes
    ctz-def-ll("P", ("TgM1", "TgM2"), ("X1", "X2"))
    ctz-def-ll("Pp", ("TgN1", "TgN2"), ("Y1", "Y2"))

    // Perpendicular marks
    ctz-draw-mark-right-angle("TgM1", "M", "O", color: blue)
    ctz-draw-mark-right-angle("TgN1", "N", "O", color: green)

    // Ellipse tangents from P, P'
    ctz-def-ellipse-tangent-from("Tp1", "Tp2", "O", b, a, "P", "Mp")
    ctz-def-ellipse-tangent-from("Tpp1", "Tpp2", "O", b, a, "Pp", "Np")
    ctz-draw(line: ("Tp1", "Tp2"), stroke: red-stroke, mark: (end: ">", start: ">"))
    ctz-draw(line: ("Tpp1", "Tpp2"), stroke: red-stroke, mark: (end: ">", start: ">"))

    // Labels
    ctz-draw(points: ("O", "H", "Hp", "M", "Mp", "N", "Np", "P", "Pp"), labels: (
      O: (pos: "below left", offset: (-0.15, -0.15)),
      H: "below", Hp: "left", M: "above right", Mp: "above",
      N: "left", Np: "below left", P: "right", Pp: "below"
    ))
  },
  code: [```typst
#ctz-canvas(length: 0.8cm, {
  import cetz.draw: *
  ctz-init()

  let a = 3
  let b = 2

  let blue-stroke = (paint: blue, thickness: 0.8pt)
  let green-stroke = (paint: green, thickness: 0.8pt)
  let red-stroke = (paint: red, thickness: 0.8pt)

  // Axes
  ctz-def-points(O: (0, 0), X1: (-5, 0), X2: (5, 0), Y1: (0, -5), Y2: (0, 5))
  ctz-draw(line: ("X1", "X2"), stroke: (paint: black, thickness: 0.6pt))
  ctz-draw(line: ("Y1", "Y2"), stroke: (paint: black, thickness: 0.6pt))

  // Circles and ellipse
  ctz-def-circle("C", "O", radius: a)
  ctz-def-circle("Cp", "O", radius: b)
  ctz-draw("C", stroke: blue-stroke)
  ctz-draw("Cp", stroke: green-stroke)
  ctz-draw(ellipse: ("O", b, a, 0deg), stroke: red-stroke)

  // Key points H, H'
  ctz-def-points(H: (a / 2, 0), Hp: (0, -b / 2))

  // Lines through H and H'
  ctz-def-perp("L1a", "L1b", ("X1", "X2"), "H")
  ctz-def-para("L2a", "L2b", ("X1", "X2"), "Hp")

  // Intersections with circles
  ctz-def-lc(("M", "M2"), ("L1a", "L1b"), "C", near: "H")
  ctz-def-lc(("N", "N2"), ("L2a", "L2b"), "Cp", near: "Hp")

  // Project M, N onto ellipse
  ctz-def-ellipse-project("Mp", "O", b, a, "M")
  ctz-def-ellipse-project("Np", "O", b, a, "N")

  // Dashed construction
  ctz-draw(line: ("H", "M"), stroke: (paint: black, thickness: 0.6pt, dash: "dashed"))
  ctz-draw(line: ("Hp", "Np"), stroke: (paint: black, thickness: 0.6pt, dash: "dashed"))

  // Radii
  ctz-draw(line: ("O", "M"), stroke: blue-stroke)
  ctz-draw(line: ("O", "N"), stroke: green-stroke)

  // Tangents at M and N
  ctz-def-tangent-at("TgM1", "TgM2", "M", "O")
  ctz-def-tangent-at("TgN1", "TgN2", "N", "O")
  ctz-draw(line: ("TgM1", "TgM2"), stroke: blue-stroke)
  ctz-draw(line: ("TgN1", "TgN2"), stroke: green-stroke)

  // Intersections with axes
  ctz-def-ll("P", ("TgM1", "TgM2"), ("X1", "X2"))
  ctz-def-ll("Pp", ("TgN1", "TgN2"), ("Y1", "Y2"))

  // Perpendicular marks
  ctz-draw-mark-right-angle("TgM1", "M", "O", color: blue)
  ctz-draw-mark-right-angle("TgN1", "N", "O", color: green)

  // Ellipse tangents from P, P'
  ctz-def-ellipse-tangent-from("Tp1", "Tp2", "O", b, a, "P", "Mp")
  ctz-def-ellipse-tangent-from("Tpp1", "Tpp2", "O", b, a, "Pp", "Np")
  ctz-draw(line: ("Tp1", "Tp2"), stroke: red-stroke, mark: (end: ">", start: ">"))
  ctz-draw(line: ("Tpp1", "Tpp2"), stroke: red-stroke, mark: (end: ">", start: ">"))

  // Labels
  ctz-draw(points: ("O", "H", "Hp", "M", "Mp", "N", "Np", "P", "Pp"), labels: (
    O: (pos: "below left", offset: (-0.15, -0.15)),
    H: "below", Hp: "left", M: "above right", Mp: "above",
    N: "left", Np: "below left", P: "right", Pp: "below"
  ))
})
```],
  length: 0.8cm,
)

#full-figure(
  "Parabola Tangents from Circle",
  {
    import cetz.draw: *
    import "@preview/ctz-euclide:0.1.0": *
    ctz-init()

    let F = (0, 0)
    let p = 0.35
    let theta = 25deg

    ctz-draw-parabola-focus(F, p, angle: theta, extent: 2.8, stroke: (paint: black, thickness: 1pt))

    let (D1, D2, V) = parabola-directrix-raw(F, p, angle: theta)

    // Circle positioned to be tangent to the parabola
    let C = (V.at(0) + 10 * (V.at(0) - F.at(0)), V.at(1) + 10 * (V.at(1) - F.at(1)))
    let r = 1.4
    ctz-draw(circle-r: (C, r), stroke: (paint: black, thickness: 0.6pt))

    // Points on circle for tangent construction
    let M1 = (C.at(0) + r * calc.cos(150deg), C.at(1) + r * calc.sin(150deg))
    let M2 = (C.at(0) + r * calc.cos(210deg), C.at(1) + r * calc.sin(210deg))
    let M3 = (C.at(0) + r * calc.cos(250deg), C.at(1) + r * calc.sin(250deg))

    // Draw tangents from each M point to parabola
    for M in (M1, M2, M3) {
      let tangents = parabola-tangents-from-point-raw(F, D1, D2, M, length: 1.5)
      for t in tangents {
        let (p1, p2, tp) = t
        ctz-draw(line: (p1, p2), stroke: (paint: red, thickness: 0.8pt))
        ctz-draw(points: (tp,), style: (shape: "dot", size: 2pt, fill: blue))
      }
    }

    // Label points
    ctz-def-points(C: C, M1: M1, M2: M2, M3: M3)
    ctz-draw(points: ("C", "M1", "M2", "M3"), labels: (
      C: (pos: "below", offset: (0, -0.25)),
      M1: (pos: "above left", offset: (-0.2, 0.15)),
      M2: (pos: "left", offset: (-0.2, 0)),
      M3: (pos: "below right", offset: (0.2, -0.15)),
    ))
  },
  code: [```typst
#ctz-canvas(length: 0.7cm, clip-canvas: (-4, -4, 12, 12), {
  import cetz.draw: *
  import "@preview/ctz-euclide:0.1.0": *
  ctz-init()

  let F = (0, 0)
  let p = 0.35
  let theta = 25deg

  // Draw parabola
  ctz-draw-parabola-focus(F, p, angle: theta, extent: 2.8,
    stroke: (paint: black, thickness: 1pt))

  let (D1, D2, V) = parabola-directrix-raw(F, p, angle: theta)

  // Circle positioned to be tangent to parabola
  let C = (V.at(0) + 10 * (V.at(0) - F.at(0)),
           V.at(1) + 10 * (V.at(1) - F.at(1)))
  let r = 1.4
  ctz-draw(circle-r: (C, r), stroke: (paint: black, thickness: 0.6pt))

  // Three points on circle
  let M1 = (C.at(0) + r * calc.cos(150deg), C.at(1) + r * calc.sin(150deg))
  let M2 = (C.at(0) + r * calc.cos(210deg), C.at(1) + r * calc.sin(210deg))
  let M3 = (C.at(0) + r * calc.cos(250deg), C.at(1) + r * calc.sin(250deg))

  // Draw tangent lines from each M point to parabola
  for M in (M1, M2, M3) {
    let tangents = parabola-tangents-from-point-raw(
      F, D1, D2, M, length: 1.5)
    for t in tangents {
      let (p1, p2, tp) = t
      ctz-draw(line: (p1, p2), stroke: (paint: red, thickness: 0.8pt))
      ctz-draw(points: (tp,), style: (shape: "dot", size: 2pt, fill: blue))
    }
  }

  // Label points
  ctz-def-points(C: C, M1: M1, M2: M2, M3: M3)
  ctz-draw(points: ("C", "M1", "M2", "M3"), labels: (
    C: (pos: "below", offset: (0, -0.25)),
    M1: (pos: "above left", offset: (-0.2, 0.15)),
    M2: (pos: "left", offset: (-0.2, 0)),
    M3: (pos: "below right", offset: (0.2, -0.15)),
  ))
})
```],
  clip-canvas: (-4, -4, 12, 12),
  length: 0.7cm,
)
