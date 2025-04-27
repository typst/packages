#import "../lib.typ": *
#set page(width: auto, height: auto, margin: 5pt)

#canvas({
  import draw: *
  toric_code((0, 0), 7, 7, size: 1)
  plaquette_code_label((0, 0),2,4,ver_vec:((-1,0),(2,1),(3,1)),hor_vec:((0,0),(-1,-4),(-1,-3)), size: 1)
  vertex_code_label((0, 0),6,1,ver_vec:((-1,0),(0,4),(0,3)),hor_vec:((-4,-1),(0,0),(-3,-1)), size: 1)
  stabilizer_label((10, -3))
})