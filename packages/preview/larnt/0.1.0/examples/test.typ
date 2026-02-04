// Takes about 20s to render.
#set page(margin: 0pt, height: auto)
#import "@preview/suiji:0.5.1"
#import "../lib.typ": *

#let rng = suiji.gen-rng-f(42)

#{
  let n = 8
  let shapes = ()
  for x in range(-n, n + 1) {
    for y in range(-n, n + 2) {
      let seed
      (rng, seed) = suiji.integers-f(rng)
      shapes.push(
        sphere(
          (float(x), float(y), 0.),
          0.45,
          texture: "RandomCircles",
          seed: seed,
        ),
      )
    }
  }
  render(
    eye: (8.0, 8.0, 1.0),
    center: (0., 0., -4.25),
    ..shapes,
  )
}
