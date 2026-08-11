#import "@preview/showybox:2.0.4": showybox


#let nonum(eq) = math.equation(block: true, numbering: none, eq)

#let mybox(it, color, width: auto) = {
  context {
    showybox(
      it,
      frame: (
        // title-color: red.darken(30%),
        inset: (x: 0.4em, y: 0.55em),
        border-color: color.darken(30%),
        body-color: color.lighten(95%),
      ),
      width: width,
      // width: 90%,
      // title: [*比热容*]
    )
    v(-0.2em)
  }
}

#let box-blue(it) = mybox(it, blue)

#let box-green(it) = mybox(it, green)

#let box-red(it) = mybox(it, red)

#let beamer-block(value, color: black.lighten(10%)) = {
  let margin = -0.4em
  v(margin)

  let mar = 0.25em
  pad(left: mar)[
    #block(fill: luma(240), inset: (x: 0.4em, y: 0.6em), outset: 0em, stroke: (left: mar + color))[#value]
  ]

  v(margin)
}
