#import "@preview/cetz:0.4.2"
#import "@preview/cetz-plot:0.1.3": chart

#set page(width: auto, height: auto, margin: .5cm)

#let data = (
  ([Belgium],     24),
  ([Germany],     31),
  ([Greece],      18),
  ([Spain],       21),
  ([France],      23),
  ([Hungary],     18),
  ([Netherlands], 27),
  ([Romania],     17),
  ([Finland],     26),
  ([Turkey],      13),
)

#cetz.canvas({
  let colors = gradient.linear(red, blue, green, yellow)

  chart.piechart(
    data,
    value-key: 1,
    label-key: none,
    radius: 4,
    stroke: none,
    slice-style: colors,
    inner-radius: 1,
    outset: 3,
    inner-label: (content: (value, label) => [#text(white, str(value))], radius: 110%),
    outer-label: (content: "%", radius: 110%))
})
