#set page(margin: 0pt, height: auto)
#import "@preview/suiji:0.5.1"
#import "@preview/larnt:0.1.0": *

#let rng = suiji.gen-rng-f(42)

#{
  let cubes = ()
  for x in range(-2, 3) {
    for y in range(-2, 3) {
      let z
      (rng, z) = suiji.random-f(rng)
      cubes.push(cube(
        (x - 0.5, y - 0.5, z - 0.5),
        (x + 0.5, y + 0.5, z + 0.5),
        texture: "Stripes",
        stripes: 7,
      ))
    }
  }
  render(step: 0.05, ..cubes)
}
