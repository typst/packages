#let skew(angle, vscale: 1, body) = {
  let (a, b, c, d) = (1, vscale * calc.tan(angle), 0, vscale)
  let E = (a + d) / 2
  let F = (a - d) / 2
  let G = (b + c) / 2
  let H = (c - b) / 2
  let Q = calc.sqrt(E * E + H * H)
  let R = calc.sqrt(F * F + G * G)
  let sx = Q + R
  let sy = Q - R
  let a1 = calc.atan2(F, G)
  let a2 = calc.atan2(E, H)
  let theta = (a2 - a1) / 2
  let phi = (a2 + a1) / 2

  set rotate(origin: bottom + center)
  set scale(origin: bottom + center)

  rotate(phi, scale(x: sx * 100%, y: sy * 100%, rotate(theta, body)))
}

#let fake-italic(body) = skew(-12deg, body)

#let TeX = {
  [T]
  box(move(
    dx: -1.5pt,
    dy: 2.2pt,
    box(scale(100%)[E]),
  ))
  box(move(
    dx: -3.0pt,
    dy: 0pt,
    [X],
  ))
  h(-1.0pt)
}

#let LaTeX = {
  [L]
  box(move(
    dx: -4pt,
    dy: -1pt,
    box(scale(x: 80%, y: 70%, [A])),
  ))
  box(move(
    dx: -5.7pt,
    dy: 0pt,
    [T],
  ))
  box(move(
    dx: -7.0pt,
    dy: 2.3pt,
    box(scale(100%)[E]),
  ))
  box(move(
    dx: -8.0pt,
    dy: 0pt,
    [X],
  ))
  h(-8.0pt)
}

#let LaTeX2e = {
  [2]
  box(move(
    dx: -1pt,
    dy: 1.5pt,
    box(text(style: "italic")[#fake-italic("ε")]),
  ))
}

/// Draw TeX logo
/// text (string): the text to be typeset. Examples: "LaTeX", "TeX", "LaTeX2e", "LuaLaTeX", "XeLaTeX", "pdfLaTeX", "pdfTeX", "LaTeX2ε", etc.
#let draw-TeX(tex) = {
  set text(font: "New Computer Modern Math")
  box(
    if (tex == "LaTeX") {
      LaTeX
    } else if (tex == "TeX") {
      TeX
    } else {
      show "TeX": TeX
      show "2e": LaTeX2e
      tex
    },
  )
}

// #let LaTeX2e = {
//   LaTeX;box(move(
//     dx: -4.2pt, dy: -1.2pt,
//     box(scale(65%)[2])
//   ));box(move(
//   dx: -5.7pt, dy: 0pt,
//   [ε]
// ));h(-5.7pt)
// }
