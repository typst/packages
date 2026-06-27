#import "@preview/simple-plot:0.8.0": plot
#import "@preview/distro:0.1.0": normal

#set page(width: auto, height: auto, margin: 6mm)

#let Z = normal.new(mean: 0, std: 1)

#grid(
  columns: 2,
  gutter: 4mm,
  plot(
    width: 5, height: 5,
    xmin: -4, xmax: 4, ymin: 0, ymax: 0.45,
    xlabel: $x$, ylabel: $f(x)$,
    axis-y-extend: 0,
    (fn: normal.pdf(Z)),
  ),
  plot(
    width: 5, height: 5,
    xmin: -4, xmax: 4, ymin: 0, ymax: 1.1,
    xlabel: $x$, ylabel: $F(x)$,
    axis-y-extend: 0,
    (fn: normal.cdf(Z)),
  ),
)
