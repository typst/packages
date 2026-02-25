#import "../lib.typ": *
#set page(width: auto, height: auto, margin: 5pt)

#canvas({
  import draw: *
  toric-code((0, 0), 7, 7, size: 1)
  plaquette-code-label((0, 0),2,4,ver-vec:((-1,0),(2,1),(3,1)),hor-vec:((0,0),(-1,-4),(-1,-3)), size: 1)
  vertex-code-label((0, 0),6,1,ver-vec:((-1,0),(0,4),(0,3)),hor-vec:((-4,-1),(0,0),(-3,-1)), size: 1)
  stabilizer-label((10, -3))
})