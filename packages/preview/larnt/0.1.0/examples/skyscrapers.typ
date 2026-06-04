#set page(margin: 0pt, height: auto)
#import "@preview/suiji:0.5.1"
#import "@preview/larnt:0.1.0": *

#let rng = suiji.gen-rng-f(42)

#{
  let n = 15
  let cubes = ()
  for x in range(-n, n + 1) {
    for y in range(-n, n + 1) {
      let p
      let fz
      (rng, (p, fz)) = suiji.random-f(rng, size: 2)
      let (fx, fy, fz, p) = (float(x), float(y), fz * 3 + 1, p * 0.25 + 0.2)
      if x == 2 and y == 1 {
        continue
      }
      cubes.push(
        cube(
          (fx - p, fy - p, 0.),
          (fx + p, fy + p, fz),
          texture: "Stripes",
          stripes: 7,
        ),
      )
    }
  }
  image(
    render(
      eye: (1.75, 1.25, 6.0),
      fovy: 100.0,
      ..cubes,
    ),
    width: 100%,
  )
}
