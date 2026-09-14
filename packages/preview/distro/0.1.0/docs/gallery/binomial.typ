#import "@preview/simple-plot:0.8.0": plot, scatter
#import "@preview/distro:0.1.0": binomial

#set page(width: auto, height: auto, margin: 6mm)

#let B  = binomial.new(10, 0.3)
#let ks = range(0, B.n + 1)

#grid(
  columns: 2,
  gutter: 4mm,
  plot(
    width: 5, height: 5,
    xmin: 0, xmax: B.n, ymin: 0, ymax: 0.32,
    xlabel: $k$, ylabel: $p(k)$,
    axis-y-extend: 0,
    scatter(ks.map(k => (k, binomial.pmf(B)(k)))),
  ),
  plot(
    width: 5, height: 5,
    xmin: 0, xmax: B.n, ymin: 0, ymax: 1.1,
    xlabel: $k$, ylabel: $F(k)$,
    axis-y-extend: 0,
    scatter(ks.map(k => (k, binomial.cdf(B)(k)))),
  ),
)
