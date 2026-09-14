// Takes about 1s to render.
#set page(height: auto, margin: 0pt)
#import "@preview/larnt:0.1.0": *

#{
  let (min, max) = ((-1., -1., -1.), (1., 1., 1.))
  image(
    render(
      eye: (3., 0.5, 3.),
      func((x, y) => x * y, min, max, texture: "Spiral", step: 0.01),
      func((x, y) => 0.0, min, max, step: 0.01),
      sphere((0., -0.6, 0.), 0.25, texture: "RandomCircles"),
    ),
    width: 100%,
  )
}
