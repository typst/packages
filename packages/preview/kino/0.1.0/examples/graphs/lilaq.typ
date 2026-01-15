#import "@preview/kino:0.1.0": *
#import "@preview/lilaq:0.5.0" as lq
#set page(width: 8cm, height: 8cm)
#set align(center + horizon)

#show: animation

#init(e: .0)
#animate(duration: 3, e: 2 * calc.pi)

#context {
  let xs = lq.linspace(0, 4)
  lq.diagram(xlim: (0, 4), ylim: (-2, 2), lq.fill-between(
    xs,
    xs.map(calc.sin),
    y2: xs.map(t => calc.cos(t + a("e"))),
  ))
}

#finish()
