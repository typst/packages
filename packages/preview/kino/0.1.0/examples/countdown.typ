#import "@preview/kino:0.1.0": *
#import "@preview/cetz:0.4.2"
#import "@preview/cetz-plot:0.1.3": chart
#set page(width: auto, height: auto)

#show: animation

#let duration = 5

#init(p: 0)
#animate(duration: duration, p: duration * 100)
#init(x: duration + 1)
#meanwhile(duration: duration, x: 1)

#context {
  place([#a("x")], dx: 1.9cm, dy: 1.9cm)
  cetz.canvas({
    chart.piechart(
      (calc.rem(a("p"), 100), 100 - calc.rem(a("p"), 100)),
      inner-radius: .5,
      radius: 2,
    )
  })
}
#finish()
