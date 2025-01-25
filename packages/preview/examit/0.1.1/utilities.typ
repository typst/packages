#import "@preview/cetz:0.2.2"

#let underline-thickness = 0.4pt
#let underline-offset = 1.3pt
#set underline(stroke: underline-thickness, offset: underline-offset)

#let choicebox(choice) = box(
  [
    
    // #sym.circle.big
    #box(width: 1em, height: 1em, stroke: 0.2mm)
    // #sym.square.stroked
    #h(0.3em) #box([#move(dy: -0.2em, [#choice])]) #h(0.3em)
  ]
)

#let writingline(width: 1fr) = box(
  width: width,
  stroke: (bottom: underline-thickness),
  outset: (bottom: underline-offset),
  none
)

#let writingbox(height: 1in) = {
  box(width: 100%, height: height, stroke: black + 0.2mm)
}

#let graphgrid(width: 10, height: 10, unitlength: 4mm) = {
  [
    #cetz.canvas(
      length: unitlength, {
        import cetz.draw: *
        grid((0, 0), (width, height), step: 1, stroke: gray + 0.2pt)
      }
    )
  ]
}
#let graphpolar(radius: 5, unitlength: 6mm, radials: (15, )) = [
  #cetz.canvas(
    length: unitlength, {
      import cetz.draw: *
      // line((0, 0), (width, 0), step: 1, stroke: 0.2pt)
      for anglestep in radials {
        for ang in range(360,step: anglestep) {
          line(stroke:0.2mm+luma(50%), (0,0), (angle: (2 * calc.pi) * ang / 360, radius: radius+0.5))
          // draw(stroke:0.2mm+lightgray, (0,0) -- (ang * 180 / 16:4))
        }
      }
      
      for r in range(radius, step:2) {
        circle((0,0),radius: r, stroke: 0.2mm+luma(50%))
      }
      
      for r in range(1, radius+1, step:2) {
        circle((0,0),radius: r, stroke: 0.2mm+luma(20%))
      }
    }
  )
]
#let graphline(width: 20, unitlength: 4mm) = {
  [
    #cetz.canvas(
      length: unitlength, {
        import cetz.draw: *
        line((0, 0), (width, 0), step: 1, stroke: 0.2pt, mark: (end: ">", start: ">"))
      }
    )
  ]
}

#let img(im, sc: 0.5, align: "b", boxes: false) = style(styles => {
  let size = measure(image(im), styles)
  set image(width: size.width * sc, height: size.height * sc)
  let va = if align == "t" {0.5} else if align == "m" {0.25} else if align == "b" {0}
  box(stroke: if boxes {black}, baseline: size.height * va, image(im))
})