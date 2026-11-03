#import "@preview/simple-plot:0.8.0": plot, scatter
#import "@preview/distro:0.1.0": discrete-uniform

#set page(width: auto, height: auto, margin: 6mm)

#let DU  = discrete-uniform.new(0, 5)
#let ks = range(DU.a, DU.b + 1)

#grid(
  columns: 2,
  gutter: 4mm,
  plot(
    width: 5, height: 5,
    xmin: -0.5, xmax: 5.5, ymin: 0, ymax: 0.25,
    xlabel: $k$, ylabel: $p(k)$,
    axis-y-extend: 0,
    scatter(ks.map(k => (k, discrete-uniform.pmf(DU)(k)))),
  ),
  plot(
    width: 5, height: 5,
    xmin: -0.5, xmax: 5.5, ymin: 0, ymax: 1.1,
    xlabel: $k$, ylabel: $F(k)$,
    axis-y-extend: 0,
    scatter(ks.map(k => (k, discrete-uniform.cdf(DU)(k)))),
  ),
)
