#set page(height: auto, margin: 0pt)
#import "../lib.typ": *

#{
  let (min, max) = ((-1., -1., -1.), (1., 1., 1.))
  render(
    eye: (3., 0.5, 3.),
    func((x, y) => x * y, min, max, texture: "Spiral"),
    func((x, y) => 0.0, min, max),
    sphere((0., -0.6, 0.), 0.25, texture: "RandomCircles"),
  )
}
