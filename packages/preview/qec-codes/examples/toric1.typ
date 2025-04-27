#import "../lib.typ": *
#set page(width: auto, height: auto, margin: 5pt)

#canvas({
  import draw: *
  let m = 5
  let n = 3
  let size = 2
  let circle_radius = 0.4
  toric_code((0, 0), m, n, size: size, circle_radius: circle_radius)
  plaquette_code_label((0, 0),2,0, size: size, circle_radius: circle_radius)
  vertex_code_label((0, 0),3,2, size: size, circle_radius: circle_radius)
  stabilizer_label((12, -2))
  for i in range(m){
    for j in range(n){
      content( "toric_point_vertical_" + str(i) + "_" + str(j), [#(i*n+j+1)])
      content( "toric_point_horizontal_" + str(i) + "_" + str(j), [#(i*n+j+1+m*n)])
    }
  }
})