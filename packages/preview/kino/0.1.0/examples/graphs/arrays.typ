#import "@preview/kino:0.1.0": *
#import "@preview/lilaq:0.5.0" as lq
#set page(width: 7cm, height: 7cm)
#set align(center + horizon)

#show: animation

#let xs = range(6)
#let y0 = (8., 6., 4., 5., 3., 6.)
#let y1 = (4, 5, 3, 4, 2, 1)
#let y2 = (1, 1, 2, 3, 2, 0)

#init(v0: y0)
#init(v1: y0)
#init(v2: y0)
#animate(v0: y1, v1: y1)
#animate(v0: y2)

#context {
  lq.diagram(
    xlim: (0, 5),
    ylim: (0, 10),
    xaxis: (ticks: none),
    yaxis: (ticks: none),
    grid: none,
    ..range(3).map(i => {
      lq.plot(smooth: true, mark: none, xs, a("v" + str(i)))
    }),
  )
}

#finish()
