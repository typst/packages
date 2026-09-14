#import "@preview/cetz:0.4.2": canvas, draw

#let graph-canvas(body, length: 0.72cm) = {
  canvas(length: length, {
    import draw: *
    body
  })
}
