#import "@preview/cetz:0.3.4": canvas,draw

#let steane_code(loc,size:4, color1:yellow, color2:aqua,color3:olive,name: "steane",point_radius:0.1) = {
  import draw: *
  let x = loc.at(0) 
  let y = loc.at(1)
  let locp_vec = ((x - calc.sqrt(3)*size/2,y  - size/2),(x,y - size/2),(x + calc.sqrt(3)*size/2,y  - size/2),(x,y + size),(x - calc.sqrt(3)*size/4,y + size/4),(x + calc.sqrt(3)*size/4,y + size/4),(x,y))
  for (i, locp) in locp_vec.enumerate() {
    circle(locp, radius: point_radius, fill: black, stroke: none, name: name + "_" + str(i + 1))
  }

  for ((i,j,k,l),color) in (((1,2,7,5),color1),((2,3,6,7),color2),((4,5,7,6),color3)) {
    line(name + "_" + str(i), name + "_" + str(j), name + "_" + str(k), name + "_" + str(l), name + "_" + str(i), fill: color)
  }

  for (i, locp) in locp_vec.enumerate() {
    circle(locp, radius: point_radius, fill: black, stroke: none)
  }
}

#let surface_code(loc, m, n, size:1, color1:yellow, color2:aqua, name: "surface", type_tag:true) = {
  import draw: *
  for i in range(m){
    for j in range(n){
      let x = loc.at(0) + i * size
      let y = loc.at(1) + j * size
      if (i != m - 1) and (j != n - 1) {
        // determine the color of the plaquette
        let (colora, colorb) = if (calc.rem(i + j, 2) == 0) {
          (color1, color2)
        } else {
          (color2, color1)
        }
        // four types of boundary plaquettes
        if type_tag == (calc.rem(i + j, 2) == 0) {
          if (i == 0) {
              bezier((x, y), (x, y + size), (x - size * 0.7, y + size/2), fill: colorb, stroke: black)
            }
            if (i == m - 2) {
              bezier((x + size, y), (x + size, y + size), (x + size * 1.7, y + size/2), fill: colorb, stroke: black)
            }
          } else {
            if (j == 0) {
              bezier((x, y), (x + size, y), (x + size/2, y - size * 0.7), fill: colorb, stroke: black)
            }
            if (j == n - 2) {
              bezier((x, y + size), (x + size, y + size), (x + size/2, y + size * 1.7), fill: colorb, stroke: black)
            }
          }
          rect((x, y), (x + size, y + size), fill: colora, stroke: black, name: name + "_square" + "_" + str(i) + "_" + str(j))
      }
      circle((x, y), radius: 0.08 * size, fill: black, stroke: none, name: name + "_" + str(i) + "_" + str(j))
    }
    }
  }
}

#let stabilizer_label(loc, size:1, color1:yellow, color2:aqua) = {
  import draw: *
  let x = loc.at(0)
  let y = loc.at(1)
  content((x, y), box(stroke: black, inset: 10pt, [$X$ stabilizers],fill: color2, radius: 4pt))
  content((x, y - 1.5*size), box(stroke: black, inset: 10pt, [$Z$ stabilizers],fill: color1, radius: 4pt))
}

#let toric_code(loc, m, n, size:1,circle_radius:0.2,color1:white,color2:gray,line_thickness:1pt,name: "toric") = {
  import draw: *
    for i in range(m){
    for j in range(n){
            let x = loc.at(0) + i * size
      let y = loc.at(1) - j * size
 rect((x, y), (x + size, y - size), fill: color1, stroke: black,name: name + "_square" + "_" + str(i) + "_" + str(j))
    }}
  for i in range(m){
    for j in range(n){
      let x = loc.at(0) + i * size
      let y = loc.at(1) - j * size

      circle((x + size/2, y), radius: circle_radius, fill: color1, stroke: (thickness: line_thickness),name: name + "_point_vertical_" + str(i) +"_" + str(j))
      circle((x, y - size/2), radius: circle_radius, fill: color2, stroke: (thickness: line_thickness),name: name + "_point_horizontal_" + str(i) +"_" + str(j))
    }
  }
}

#let plaquette_code_label(loc, posx,posy, ver_vec:((-1,0),(-1,1)), hor_vec:((0,0),(-1,0)), size:1,circle_radius:0.2, color1:white, color2:gray, color3:yellow,line_thickness:1pt,name: "toric") = {
  import draw: *
      let x = loc.at(0) + posx * size
      let y = loc.at(1) - posy * size
  rect((x, y), (x - size, y - size), fill: color3, stroke: black,name: name + "_plaquette")
  
  circle(name+"_point_vertical_" + str(posx - 1) + "_" + str(posy),radius: circle_radius, fill: color1, stroke: (thickness: line_thickness))
  circle(name+"_point_vertical_" + str(posx - 1) + "_" + str(posy+1),radius: circle_radius, fill: color1, stroke: (thickness: line_thickness))
  circle(name+"_point_horizontal_" + str(posx) + "_" + str(posy),radius: circle_radius, fill: color2, stroke: (thickness: line_thickness))
  circle(name+"_point_horizontal_" + str(posx - 1) + "_" + str(posy),radius: circle_radius, fill: color2, stroke: (thickness: line_thickness))

  for (i,j) in ver_vec {
    circle(name+"_point_vertical_" + str(i+posx) + "_" + str(j+posy),radius: circle_radius, fill: color3, stroke: (thickness: line_thickness))
  }
  for (i,j) in hor_vec {
    circle(name+"_point_horizontal_" + str(i+posx) + "_" + str(j+posy),radius: circle_radius, fill: color3, stroke: (thickness: line_thickness))
  }
}


#let vertex_code_label(loc, posx,posy, ver_vec:((-1,0),(0,0)), hor_vec:((0,0),(0,-1)), size:1, circle_radius:0.2, color1:white, color2:gray, color3:aqua,line_thickness:1pt,name: "toric") = {
  import draw: *
  let x = loc.at(0) + posx * size
  let y = loc.at(1) - posy * size
  rect((x - circle_radius, y - circle_radius), (x + circle_radius, y + circle_radius), fill: color3, stroke: black,name: name + "_vertex")

  for (i,j) in ver_vec {
    circle(name+"_point_vertical_" + str(i+posx) + "_" + str(j+posy),radius: circle_radius, fill: color3, stroke: (thickness: line_thickness))
  }
  for (i,j) in hor_vec {
    circle(name+"_point_horizontal_" + str(i+posx) + "_" + str(j+posy),radius: circle_radius, fill: color3, stroke: (thickness: line_thickness))}
}
