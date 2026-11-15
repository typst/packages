// Inspired by TimeTravelPenguin/symbolic-eval:
// https://github.com/TimeTravelPenguin/symbolic-eval/blob/79c6588351603b85b11b6c92b1fbff3faf478215/examples/phase_portrait.typ
#import "@preview/symbolica:0.1.0": init

#set document(title: "A complex-function phase portrait")
#set page(paper: "a4", margin: 18mm)
#set text(size: 9.5pt)

= A complex phase portrait

The hue below records the phase of

#align(center)[
  $ f(z) = (z^2 - 1 - i) / (z^2 + 1 + i), $
]

while lightness records its magnitude. All complex values are evaluated in one
batch; Typst then turns the returned grid into coloured cells.

#let sym = init(namespace: "symbolica")
#let parse = sym.math
#let symbol = sym.symbol
#let evaluate-many = sym.evaluate-many

#let z = symbol("z")
#let imaginary-unit = symbol("i")
#let expression = parse($(z^2 - 1 - i) / (z^2 + 1 + i)$)

#let x-min = -calc.pi
#let x-max = calc.pi
#let y-min = -2.5
#let y-max = 2.5
#let x-samples = 96
#let y-samples = 76
#let cell-size = 2pt

#let sample(minimum, maximum, count, index) = {
  if index + 1 == count {
    maximum
  } else {
    minimum + (maximum - minimum) * index / (count - 1)
  }
}

#let points = {
  let rows = ()
  for row in range(y-samples) {
    let y = sample(y-min, y-max, y-samples, row)
    for column in range(x-samples) {
      let x = sample(x-min, x-max, x-samples, column)
      rows.push(((re: x, im: y), (re: 0.0, im: 1.0)))
    }
  }
  rows
}

#let values = evaluate-many(expression, (z, imaginary-unit), points).map(row => row.first())

#let phase-color(value) = {
  let magnitude = calc.sqrt(value.re * value.re + value.im * value.im)
  let log-magnitude = calc.ln(calc.max(magnitude, 1e-12))
  let lightness = calc.min(
    74%,
    calc.max(26%, 50% + 18% * calc.tanh(log-magnitude)),
  )
  color.hsl(calc.atan2(value.re, value.im), 88%, lightness)
}

#let pixels = ()
#for display-row in range(y-samples) {
  let source-row = y-samples - display-row - 1
  for column in range(x-samples) {
    let index = source-row * x-samples + column
    pixels.push(box(
      width: cell-size,
      height: cell-size,
      fill: phase-color(values.at(index)),
    ))
  }
}

#align(center)[
  #grid(
    columns: (cell-size,) * x-samples,
    column-gutter: 0pt,
    row-gutter: 0pt,
    ..pixels,
  )
]

#v(3mm)
#text(size: 8pt, fill: luma(40%))[
  Independently adapted for Symbolica from the phase-portrait example in
  #link("https://github.com/TimeTravelPenguin/symbolic-eval")[`symbolic-eval`].
]
