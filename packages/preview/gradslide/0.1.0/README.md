# `gradslide`

Simple component to show a value between 0 and 1 on a nice, customizable gradient slider.
Here is an example:

```typ
#import "@preview/gradslide:0.1.0": *

#slider(0.6,
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
  labelUnit: "%",
  outerPadding: 0.1cm,
  spaceBetweenIndicatorAndLabel: 0.1cm,
)
```

![Example](examples/example_1.svg)
