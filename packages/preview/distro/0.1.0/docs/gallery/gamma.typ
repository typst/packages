#import "@preview/simple-plot:0.8.0": plot
#import "@preview/distro:0.1.0": gamma

#set page(width: auto, height: auto, margin: 6mm)

#let Gamma = gamma.new(shape: 2, rate: 0.5)

#grid(
  columns: 2,
  gutter: 4mm,
  plot(
    width: 5, height: 5,
    xmin: 0, xmax: 12, ymin: 0, ymax: 0.22,
    xlabel: $x$, ylabel: $f(x)$,
    axis-y-extend: 0,
    (fn: gamma.pdf(Gamma)),
  ),
  plot(
    width: 5, height: 5,
    xmin: 0, xmax: 12, ymin: 0, ymax: 1.1,
    xlabel: $x$, ylabel: $F(x)$,
    axis-y-extend: 0,
    (fn: gamma.cdf(Gamma)),
  ),
)
