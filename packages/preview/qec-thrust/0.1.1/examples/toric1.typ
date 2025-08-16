#import "../lib.typ": *
#set page(width: auto, height: auto, margin: 5pt)

#canvas({
  import draw: *
  let m = 5
  let n = 3
  let size = 2
  let circle-radius = 0.4
  toric-code((0, 0), m, n, size: size, circle-radius: circle-radius)
  plaquette-code-label((0, 0),2,0, size: size, circle-radius: circle-radius)
  vertex-code-label((0, 0),3,2, size: size, circle-radius: circle-radius)
  stabilizer-label((12, -2))
  for i in range(m){
    for j in range(n){
      content( "toric-point-vertical-" + str(i) + "-" + str(j), [#(i*n+j+1)])
      content( "toric-point-horizontal-" + str(i) + "-" + str(j), [#(i*n+j+1+m*n)])
    }
  }
})