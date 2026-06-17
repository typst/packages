#import "@preview/simple-plot:0.8.0": plot, scatter
#import "@preview/distro:0.2.0": bernoulli

#set page(width: auto, height: auto, margin: 6mm)

#let B  = bernoulli.new(0.8)
#let ks = range(0, 2)

#grid(
  columns: 2,
  gutter: 4mm,
  plot(
    width: 5, height: 5,
    xmin: -0.5, xmax: 1.5, ymin: 0, ymax: 1.05,
    xlabel: $k$, ylabel: $p(k)$,
    axis-y-extend: 0,
    scatter(ks.map(k => (k, bernoulli.pmf(B)(k)))),
  ),
  plot(
    width: 5, height: 5,
    xmin: -0.5, xmax: 1.5, ymin: 0, ymax: 1.1,
    xlabel: $k$, ylabel: $F(k)$,
    axis-y-extend: 0,
    scatter(ks.map(k => (k, bernoulli.cdf(B)(k)))),
  ),
)
