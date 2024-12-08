
#let slider(
  p,
  barHeight: 0.25cm,
  barWidth: 4cm,
  barGradientColors: (green.lighten(70%), yellow.lighten(70%), red.lighten(70%)),
  barRadius: 1pt,
  indicatorHeight: 0.5cm,
  indicatorWidth: 0.1cm,
  indicatorColor: black,
  indicatorRadius: 100%,
  labelSize: 8pt,
  labelColor: black,
  labelUnit: "",
  outerPadding: 0.1cm,
  spaceBetweenIndicatorAndLabel: 0.1cm,
) = context {
  let barGradient = gradient.linear(..barGradientColors, angle: 0deg)
  let indicatorXOffset = p * barWidth
  let pContent = text(size: labelSize, fill: labelColor)[
    #if labelUnit != "" {
      [#str(p) #str(labelUnit)]
    } else {
      [#str(p)]
    }
  ]
  let pWidth = measure(pContent).width
  let pHeight = measure(pContent).height

  box(
    width: barWidth + outerPadding * 2,
    height: calc.max(barHeight, indicatorHeight) + outerPadding * 2 + pHeight + spaceBetweenIndicatorAndLabel,
  )[
    #place(
      dx: outerPadding,
      dy: ((indicatorHeight - barHeight) / 2) + outerPadding,
    )[
      #box(fill: barGradient, width: barWidth, height: barHeight, radius: barRadius)[]
    ]
    #place(
      dx: indicatorXOffset - (indicatorWidth / 2) + outerPadding,
      dy: outerPadding,
    )[
      #box(fill: indicatorColor, width: indicatorWidth, height: indicatorHeight, radius: indicatorRadius)[]
      #place(
        dx: (indicatorWidth / 2) - (pWidth / 2),
        dy: spaceBetweenIndicatorAndLabel,
      )[
        #pContent
      ]
    ]
  ]
}