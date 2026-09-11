#import "@preview/cetz:0.5.2": canvas, draw, matrix
#import draw: circle, content, line, on-layer, rotate, scale, set-style, set-transform, translate

= Funciones extras de typst

== Diagramas con CETZ

Typst cuenta con un paquete para hacer esquemas tipo tikz: https://typst.app/universe/package/cetz/

#let radius-domain = (0.0, 1.25)
#let angle-steps = 84
#let radius-steps = 24
#let x-limits = (-1.6, 1.6)
#let y-limits = (-1.6, 1.6)
#let z-limits = (0.0, 1.3)

#let mexican-hat-height(radius-val) = {
  calc.pow(radius-val * radius-val - 1.0, 2)
}

#let surface-point(radius-val, theta-deg) = {
  let theta = theta-deg * 1deg
  (
    calc.sin(theta) * radius-val,
    calc.cos(theta) * radius-val,
    mexican-hat-height(radius-val),
  )
}

#canvas({
  set-transform(matrix.transform-rotate-dir((2.5, 0.6, -2), (0, 1, 0.3)))
  // z must scale positive: negating it turns the hat's central bump into a pit, which
  // puts the symmetric vacuum below the broken one and points the downhill arrow uphill
  scale(x: 3, y: 3, z: 2.5)
  rotate(z: -5deg)
  translate((0, -0.02, 0))

  // Surface mesh, drawn first.
  let (radius-min, radius-max) = radius-domain
  let radius-step = (radius-max - radius-min) / radius-steps
  let angle-step = 360.0 / angle-steps
  set-style(stroke: rgb("#1a1a1a") + 0.22pt, fill: white)
  for radius-rev-idx in range(radius-steps) {
    let radius-idx = radius-steps - 1 - radius-rev-idx
    let radius-inner = radius-min + radius-idx * radius-step
    let radius-outer = radius-inner + radius-step
    for angle-idx in range(angle-steps) {
      let theta-left = angle-idx * angle-step
      let theta-right = theta-left + angle-step

      line(
        surface-point(radius-inner, theta-left),
        surface-point(radius-inner, theta-right),
        surface-point(radius-outer, theta-right),
        surface-point(radius-outer, theta-left),
        close: true,
      )
    }
  }
  let apex-point = surface-point(0.0, 0.0)
  let first-ring-radius = radius-step
  for angle-idx in range(angle-steps) {
    let theta-left = angle-idx * angle-step
    let theta-right = theta-left + angle-step
    line(
      apex-point,
      surface-point(first-ring-radius, theta-left),
      surface-point(first-ring-radius, theta-right),
      close: true,
    )
  }
  // Axis lines centered at the origin.
  let (x-min, x-max) = x-limits
  let (y-min, y-max) = y-limits
  let (z-min, z-max) = z-limits
  on-layer(-2, {
    set-style(stroke: rgb("#1f1f1f") + 0.22pt, mark: (
      fill: rgb("#1f1f1f"),
      stroke: rgb("#1f1f1f"),
      scale: 0.52,
      end: "stealth",
    ))
    line((x-min, 0, 0), (x-max, 0, 0))
    line((0, y-min, 0), (0, y-max, 0))
    line((0, 0, z-min), (0, 0, z-max))
  })

  on-layer(8, {
    set-style(fill: black)
    content((1.42, 0.6, 0.02), [$phi_1$], anchor: "west")
    content((-0.7, -0.95, -0.02), [$phi_2$], anchor: "north")
    content((0.02, 0.02, 1.47), [$U_(k)(rho)$], anchor: "south")
  })

  // Highlighted states.
  let center-point = surface-point(0.0, 0.0)
  let minimum-point = surface-point(1.0, 30.0)
  circle(center-point, radius: 0.09, fill: rgb("#00008b"), stroke: none)
  circle(minimum-point, radius: 0.09, fill: rgb("#8b0000"), stroke: none)

  // Double downhill arrow that follows the surface profile.
  let arrow-color = rgb("#c4c4c4")
  let arrow-steps = 40
  let arrow-radius-start = 0.03
  let arrow-radius-stop = 1.02
  let arrow-clearance = 0.05
  let downhill-point(radius-val, theta-deg) = {
    let theta = theta-deg * 1deg
    (
      calc.sin(theta) * radius-val,
      calc.cos(theta) * radius-val,
      mexican-hat-height(radius-val) + arrow-clearance,
    )
  }
  on-layer(9, {
    // sample the surface profile at a fixed bearing, lifted clear of the mesh
    let downhill-arrow(theta-deg) = line(
      ..range(arrow-steps + 1).map(step => {
        let t = step / arrow-steps
        let span = arrow-radius-stop - arrow-radius-start
        downhill-point(arrow-radius-start + t * span, theta-deg)
      }),
    )

    // stroked twice: a thick pale body, then a thin dark core to crisp the edges
    for (paint, thickness, scale) in (
      (arrow-color, 1.1pt, 0.56),
      (rgb("#575757"), 0.42pt, 0.44),
    ) {
      set-style(
        stroke: (paint: paint, thickness: thickness),
        fill: none,
        mark: (fill: paint, stroke: paint, scale: scale, end: "stealth"),
      )
      for theta in (28.8, 32.8) { downhill-arrow(theta) }
    }
  })
})


== Algoritmos

#pagebreak()

#import "@preview/algorithmic:1.0.7"
#import algorithmic: algorithm-figure, style-algorithm
#show: style-algorithm
#algorithm-figure(
  "Binary Search",
  vstroke: .5pt + luma(200),
  {
    import algorithmic: *
    Procedure(
      "Binary-Search",
      ("A", "n", "v"),
      {
        Comment[Initialize the search range]
        Assign[$l$][$1$]
        Assign[$r$][$n$]
        LineBreak
        While(
          $l <= r$,
          {
            Assign([mid], FnInline[floor][$(l + r) / 2$])
            IfElseChain(
              $A ["mid"] < v$,
              {
                Assign[$l$][$"mid" + 1$]
              },
              [$A ["mid"] > v$],
              {
                Assign[$r$][$"mid" - 1$]
              },
              Return[mid],
            )
          },
        )
        Return[*null*]
      },
    )
  },
)

#pagebreak()

== Figuras en general

En typst también se pueden agregar figuras y hacer sus referencias: @gato

#figure(
  image("cat.jpg", width: 80%),
  caption: [A curious figure.],
)<gato>
