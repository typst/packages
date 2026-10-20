#import "@preview/simple-plot:0.8.0": line-plot, plot
#import "@preview/distro:0.1.0": continuous-uniform

#set page(width: auto, height: auto, margin: 6mm)

#let CU = continuous-uniform.new(0, 1)

#grid(
  columns: 2,
  gutter: 4mm,
  plot(
    width: 5, height: 5,
    xmin: -0.5, xmax: 1.5, ymin: 0, ymax: 1.3,
    xlabel: $x$, ylabel: $f(x)$,
    axis-y-extend: 0,
    // Explicit breakpoints for the discontinuities.
    line-plot(((-0.5, 0), (0, 0), (0, 1), (1, 1), (1, 0), (1.5, 0))),
  ),
  plot(
    width: 5, height: 5,
    xmin: -0.5, xmax: 1.5, ymin: 0, ymax: 1.1,
    xlabel: $x$, ylabel: $F(x)$,
    axis-y-extend: 0,
    // Explicit breakpoints for the discontinuities.
    line-plot(((-0.5, 0), (0, 0), (1, 1), (1.5, 1))),
  ),
)
