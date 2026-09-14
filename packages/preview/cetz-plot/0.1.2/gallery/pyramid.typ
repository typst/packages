#import "@preview/cetz:0.4.0"
#import "@preview/cetz-plot:0.1.2": chart

#set page(width: auto, height: auto, margin: .5cm)

#let data = (
  ([Cash],     768),
  ([Funds],    1312),
  ([Stocks],   3812),
  ([Bonds],    7167),
)
#let total = data.map(i => i.last()).sum()

#cetz.canvas({
  let colors = gradient.linear(red, yellow)

  chart.pyramid(
    data,
    value-key: 1,
    label-key: 0,
    mode: "AREA-HEIGHT",
    stroke: none,
    level-style: colors,
    inner-label: (
      content: (value, label) => align(center, stack(
        label + "\n",
        str(calc.round(value / total * 10000) / 100) + "%",
        spacing: 2pt,
        dir: ttb
      ))
    ),
    side-label: (
      content: (value, label) => "$" + str(value)
    ),
    gap: 10%
  )
})
