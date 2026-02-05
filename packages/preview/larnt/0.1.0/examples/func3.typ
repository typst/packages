// Takes about 7s to render.
#set page(height: auto, margin: 0pt)
#import "@preview/larnt:0.1.0": *

#{
  let f(x, y) = 0.7 * calc.sin(calc.sqrt(20 * (x * x + y * y)))
  let (min, max) = ((-4., -4., -4.), (4., 4., 4.))
  image(
    render(
      eye: (8., 8., 8.),
      step: 0.01,
      func(f, min, max),
    ),
    width: 100%,
  )
}
