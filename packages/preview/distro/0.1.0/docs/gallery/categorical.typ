#import "@preview/simple-plot:0.8.0": plot, scatter
#import "@preview/distro:0.1.0": categorical

#set page(width: auto, height: auto, margin: 6mm)

#let C  = categorical.new((0.1, 0.3, 0.2, 0.4))
#let ks = range(0, C.weights.len())

#grid(
  columns: 2,
  gutter: 4mm,
  plot(
    width: 5, height: 5,
    xmin: -0.5, xmax: 3.5, ymin: 0, ymax: 0.5,
    xlabel: $k$, ylabel: $p(k)$,
    axis-y-extend: 0,
    scatter(ks.map(k => (k, categorical.pmf(C)(k)))),
  ),
  plot(
    width: 5, height: 5,
    xmin: -0.5, xmax: 3.5, ymin: 0, ymax: 1.1,
    xlabel: $k$, ylabel: $F(k)$,
    axis-y-extend: 0,
    scatter(ks.map(k => (k, categorical.cdf(C)(k)))),
  ),
)
