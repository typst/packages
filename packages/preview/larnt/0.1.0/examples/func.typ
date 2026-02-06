// Takes about 2s to render.
#set page(height: auto, margin: 0pt)
#import "@preview/larnt:0.1.0": *

#{
  let (min, max) = ((-3., -3., -4.), (3., 3., 2.))
  image(
    render(
      eye: (3., 0., 3.),
      center: (1.1, 0., 0.),
      step: 0.01,
      func((x, y) => -1 / (x * x + y * y), min, max, texture: "Swirl", n: 201),
    ),
    width: 100%,
  )
}
