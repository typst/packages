#import "../lib.typ": *
#set page(width: auto, height: auto, margin: 5pt)
#canvas({
  import draw: *
  let code = steane-code((0, 0), size: 3)
  (code.draw-background)()
  for j in range(7) {
    content((rel: (0, -0.3), to: (code.qubit-anchor)(j + 1)), [#(j)])
  }
})
