#import "@preview/simple-plot:0.8.0": plot
#import "@preview/distro:0.1.0": exponential

#set page(width: auto, height: auto, margin: 6mm)

#let Exp = exponential.new(1)

#grid(
  columns: 2,
  gutter: 4mm,
  plot(
    width: 5, height: 5,
    xmin: 0, xmax: 5, ymin: 0, ymax: 1.1,
    xlabel: $x$, ylabel: $f(x)$,
    axis-y-extend: 0,
    (fn: exponential.pdf(Exp)),
  ),
  plot(
    width: 5, height: 5,
    xmin: 0, xmax: 5, ymin: 0, ymax: 1.1,
    xlabel: $x$, ylabel: $F(x)$,
    axis-y-extend: 0,
    (fn: exponential.cdf(Exp)),
  ),
)
