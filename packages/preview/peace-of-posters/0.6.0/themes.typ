#let _state-poster-theme = state("poster-theme", (
  "body-box-args": (
    inset: 0.6em,
    width: 100%,
  ),
  "body-text-args": (:),
  "heading-box-args": (
    inset: 0.6em,
    width: 100%,
    fill: rgb(50, 50, 50),
    stroke: rgb(25, 25, 25),
  ),
  "heading-text-args": (
    fill: white,
  ),
))

#let uni-fr = (
  "body-box-args": (
    inset: 0.6em,
    width: 100%,
  ),
  "body-text-args": (:),
  "heading-box-args": (
    inset: 0.6em,
    width: 100%,
    fill: rgb("#1d154d"),
    stroke: rgb("#1d154d"),
  ),
  "heading-text-args": (
    fill: white,
  ),
)

#let psi-ch = (
  "body-box-args": (
    inset: (x: 0.0em, y: 0.6em),
    width: 100%,
    stroke: none,
  ),
  "body-text-args": (:),
  "heading-box-args": (
    inset: 0em,
    width: 100%,
    stroke: none,
  ),
  "heading-text-args": (
    fill: rgb("#dc005a"),
    weight: "bold",
  ),
)

#let uq = (
  "body-box-args": (
    inset: 0.6em,
    width: 100%,
    stroke: none,
    fill: rgb("#efedea"),
  ),
  "body-text-args": (:),
  "heading-box-args": (
    inset: 0.6em,
    width: 100%,
    fill: rgb("#e6e2e0"),
  ),
  "heading-text-args": (
    fill: gradient.linear(rgb("#51247a"), rgb("#962a8b")),
  ),
  "title-text-args": (
    fill: gradient.linear(rgb("#51247a"), rgb("#962a8b")),
  ),
)

#let tu-graz = (
  "body-box-args": (
    inset: 1em,
    width: 100%,
    stroke: none,
    fill: rgb("#eeece1"),
  ),
  "body-text-args": (
    font: ("Arial", "Libertinus Serif"),
  ),
  "heading-box-args": (
    inset: (left: 1em, rest: 0.6em),
    width: 100%,
    fill: rgb("#e4154b"),
    stroke: none,
  ),
  "heading-text-args": (
    fill: white,
    font: ("Arial", "Libertinus Serif"),
  ),
  "title-box-args": (
    inset: (left: 2em, rest: 1em),
    fill: white,
    stroke: (
      left: 1em + rgb("#e4154b"),
    ),
    outset: (left: -0.5em),
  ),
  "title-text-args": (
    fill: black,
    font: ("Arial", "Libertinus Serif"),
  ),
)

#let black-white = (
  "body-box-args": (
    inset: 0.6em,
    width: 100%,
    fill: white,
    stroke: none,
  ),
  "body-text-args": (
    fill: black,
  ),
  "heading-box-args": (
    inset: 0.6em,
    width: 100%,
    fill: white,
    stroke: none,
  ),
  "heading-text-args": (
    fill: black,
    weight: "bold",
  ),
  "title-box-args": (
    inset: (x: 2em, y: 2em),
    width: 100%,
    fill: black,
    stroke: none,
  ),
  "title-text-args": (
    fill: white,
    weight: "bold",
  ),
)


#let update-theme(..args) = {
  for (arg, val) in args.named() {
    _state-poster-theme.update(pt => {
      pt.insert(arg, val)
      pt
    })
  }
}

#let set-theme(theme) = {
  _state-poster-theme.update(pt => {
    pt = theme
    pt
  })
}
