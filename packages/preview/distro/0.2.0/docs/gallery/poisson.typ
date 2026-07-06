#import "@preview/simple-plot:0.8.0": plot, scatter
#import "@preview/distro:0.2.0": poisson

#set page(width: auto, height: auto, margin: 6mm)

#let Pois  = poisson.new(3)
#let ks    = range(0, 12)

#grid(
  columns: 2,
  gutter: 4mm,
  plot(
    width: 5, height: 5,
    xmin: 0, xmax: 11, ymin: 0, ymax: 0.28,
    xlabel: $k$, ylabel: $p(k)$,
    axis-y-extend: 0,
    scatter(ks.map(k => (k, poisson.pmf(Pois)(k)))),
  ),
  plot(
    width: 5, height: 5,
    xmin: 0, xmax: 11, ymin: 0, ymax: 1.1,
    xlabel: $k$, ylabel: $F(k)$,
    axis-y-extend: 0,
    scatter(ks.map(k => (k, poisson.cdf(Pois)(k)))),
  ),
)
