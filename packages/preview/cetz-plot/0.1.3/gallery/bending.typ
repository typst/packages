#import "@preview/cetz:0.4.2" as cetz: draw
#import "/src/lib.typ": smartart

#set page(width: auto, height: auto, margin: .5cm)

#let steps = (
  [Step 1],
  [Step 2],
  [Step 3],
  [Step 4],
  [Step 5],
  [Step 6],
)

#let colors = (
  red, orange, yellow.mix(green), green, green.mix(blue), blue
).map(c => c.lighten(40%))

#cetz.canvas({
  smartart.process.bending(
    steps,
    step-style: colors,
    equal-width: true,
    name: "chart",
    layout: (
      flow: (ltr, btt),
      max-stride: 2
    )
  )
})

/*
#let flows = (
  (ltr, ttb),
  (ltr, btt),
  (rtl, ttb),
  (rtl, btt),
  (ttb, ltr),
  (btt, ltr),
  (ttb, rtl),
  (btt, rtl),
)

#for flow in flows {
  cetz.canvas({
    smartart.process.bending(
      steps,
      step-style: colors,
      equal-width: true,
      name: "chart",
      layout: (
        flow: flow,
        max-stride: 3
      )
    )
  })
  pagebreak(weak: true)
}
*/
