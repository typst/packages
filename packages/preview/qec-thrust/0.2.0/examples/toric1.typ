#import "../lib.typ": *
#set page(width: auto, height: auto, margin: 5pt)

#canvas({
  import draw: *
  let m = 5
  let n = 3
  let size = 2
  let circle-radius = 0.4
  let code = toric-code((0, 0), m, n, size: size, circle-radius: circle-radius)
  (code.draw-background)()
  (code.highlight-plaquette)((1, 0))
  (code.highlight-vertex)((3, 2))
  stabilizer-label((12, -2))
  for i in range(m){
    for j in range(n){
      content((code.qubit-anchor)(("vertical", i, j)), [#(i*n+j+1)])
      content((code.qubit-anchor)(("horizontal", i, j)), [#(i*n+j+1+m*n)])
    }
  }
})
