#import "../lib.typ": *
#set page(width: auto, height: auto, margin: 5pt)

#canvas({
  import draw: *
  let n = 3
  let code1 = surface-code((0, 0), n, n, size: 1.5, name: "surface1")
  (code1.draw-background)()
  for i in range(n) {
    for j in range(n) {
      content((rel: (0.3, 0.3), to: (code1.qubit-anchor)((i, j))), [#(i*n+j+1)])
    }
  }
  let code2 = surface-code((4, 0), 15, 7, color1: red, color2: green, size: 0.5, type-tag: false)
  (code2.draw-background)()
  })
