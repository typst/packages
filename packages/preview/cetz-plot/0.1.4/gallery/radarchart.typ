#import "@preview/cetz:0.5.2"
#import "/src/lib.typ": chart

#set page(width: auto, height: auto, margin: .5cm)

#cetz.canvas({
  chart.radarchart(
    (
      [A],
      [B],
      [C],
      [D],
      [E],
      [F],
    ),
    (
      (0.3, 1, 0.3, 0.8, 0.8, 1),
      (0.9, 0.3, 0.9, 0.5, 0.5, 0.4),
    ),
    radius: 3,
    web-label-offset: 0.6,
    data-style: (
      blue.transparentize(10%),
      red.transparentize(30%),
    ),
  )
})

