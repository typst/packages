#import "@preview/simple-plot:0.8.0": plot, scatter
#import "@preview/distro:0.1.0": geometric

#set page(width: auto, height: auto, margin: 6mm)

#let Geom  = geometric.new(0.3)
#let ks = range(1, 11)

#grid(
  columns: 2,
  gutter: 4mm,
  plot(
    width: 5, height: 5,
    xmin: 0, xmax: 10, ymin: 0, ymax: 0.35,
    xlabel: $k$, ylabel: $p(k)$,
    axis-y-extend: 0,
    scatter(ks.map(k => (k, geometric.pmf(Geom)(k)))),
  ),
  plot(
    width: 5, height: 5,
    xmin: 0, xmax: 10, ymin: 0, ymax: 1.1,
    xlabel: $k$, ylabel: $F(k)$,
    axis-y-extend: 0,
    scatter(ks.map(k => (k, geometric.cdf(Geom)(k)))),
  ),
)
