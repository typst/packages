#set page(margin: 0pt, height: auto)
#import "@preview/larnt:0.1.0": *

#{
  let n = 8
  let shapes = ()
  for x in range(-n, n + 1) {
    for y in range(-n, n + 2) {
      shapes.push(
        outline(sphere(
          (float(x), float(y), 0.),
          0.45,
        )),
      )
    }
  }
  image(
    render(
      eye: (8.0, 8.0, 1.0),
      center: (0., 0., -4.25),
      ..shapes,
    ),
    width: 100%,
  )
}
