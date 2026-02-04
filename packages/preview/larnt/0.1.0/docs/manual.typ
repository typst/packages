#import "@preview/tidy:0.4.3"
#import "@preview/suiji:0.5.1"
#set text(font: "Libertinus Serif")
#import "../lib.typ"

#let docs = tidy.parse-module(
  read("../lib.typ"),
  scope: (lib: lib),
  preamble: "#import lib: *;",
)

#set heading(numbering: none)
#align(center)[
  #text(size: 24pt)[larnt]\
  _3D line art engine._

  #underline[https://github.com/HellOwhatAs/larnt/]
]

#{
  let rng = suiji.gen-rng-f(42)
  let n = 8
  let shapes = ()
  for x in range(-n, n + 1) {
    for y in range(-n, n + 2) {
      let seed
      (rng, seed) = suiji.integers-f(rng)
      shapes.push(
        (
          lib.sphere(
            (float(x), float(y), 0.),
            0.45,
            texture: "RandomCircles",
            seed: seed,
          )
        ),
      )
    }
  }
  lib.render(
    eye: (8.0, 8.0, 1.0),
    center: (0., 0., -4.25),
    height: 800.,
    ..shapes,
  )
}

#outline(depth: 2)
#align(center)[
  Thanks to #underline[https://github.com/fogleman/ln/] for the original implementation in Go.
]

#pagebreak(weak: true)
#set page(numbering: "1")

#show heading.where(level: 2): it => [
  #colbreak(weak: true)
  #show raw: set text(size: 1.2em)
  #raw("#" + it.body.text + "(..)", block: true, lang: "typst")
]

= API Reference
#tidy.show-module(docs, first-heading-level: 1, show-outline: false, sort-functions: none)
