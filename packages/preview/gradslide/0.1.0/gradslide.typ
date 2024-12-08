
#let slider(
  p,
  bar-height: 0.25cm,
  bar-width: 4cm,
  bar-gradient-colors: (green.lighten(70%), yellow.lighten(70%), red.lighten(70%)),
  bar-radius: 1pt,
  indicator-height: 0.5cm,
  indicator-width: 0.1cm,
  indicator-color: black,
  indicator-radius: 100%,
  label-size: 8pt,
  label-color: black,
  label-unit: "",
  outer-padding: 0.1cm,
  space-between-indicator-and-label: 0.1cm,
) = context {
  let barGradient = gradient.linear(..bar-gradient-colors, angle: 0deg)
  let indicatorXOffset = p * bar-width
  let pContent = text(size: label-size, fill: label-color)[
    #if label-unit != "" {
      [#str(p) #str(label-unit)]
    } else {
      [#str(p)]
    }
  ]
  let pWidth = measure(pContent).width
  let pHeight = measure(pContent).height

  box(
    width: bar-width + outer-padding * 2,
    height: calc.max(bar-height, indicator-height) + outer-padding * 2 + pHeight + space-between-indicator-and-label,
  )[
    #place(
      dx: outer-padding,
      dy: ((indicator-height - bar-height) / 2) + outer-padding,
    )[
      #box(fill: barGradient, width: bar-width, height: bar-height, radius: bar-radius)[]
    ]
    #place(
      dx: indicatorXOffset - (indicator-width / 2) + outer-padding,
      dy: outer-padding,
    )[
      #box(fill: indicator-color, width: indicator-width, height: indicator-height, radius: indicator-radius)[]
      #place(
        dx: (indicator-width / 2) - (pWidth / 2),
        dy: space-between-indicator-and-label,
      )[
        #pContent
      ]
    ]
  ]
}