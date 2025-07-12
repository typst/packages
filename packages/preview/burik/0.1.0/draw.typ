#import "@preview/cetz:0.4.0": *
#import draw: line
#import "assert.typ" : *
#import "algo.typ" : *

#let draw-face(cube, face, origin : (x:0cm, y:0cm), side : "all", size : 0.5cm, spacing : 0cm, radius : 0.05cm, arrow:false) = {
  let f = if face == "F" {cube.f}
          else if face == "R" {cube.r}
          else if face == "L" {cube.l}
          else if face == "B" {cube.b}
          else if face == "D" {cube.d}
          else if face == "U" {cube.u}
          else { cube }
   if side == "top" {
    for col in range(3) {
      let index-face = col
      let x = origin.x + col * (size + spacing)
      let y = origin.y
      draw.rect(
        (x, y),
        (x + size, y - size/4),
        fill: f.at(index-face),
        stroke: black,
        radius: radius
        )
    }
  } else if side == "bottom" {
    for col in range(3) {
      let index-face = 3*2 + col
      let x = origin.x + col * (size + spacing)
      let y = origin.y - 2 * (size + spacing)
      draw.rect(
        (x, y - size),
        (x + size, y - 3*size/4),
        fill: f.at(index-face),
        stroke: black,
        radius: radius
        )
    }
  } else if side == "left" {
    for row in range(3) {
      let index-face = 3*row
      let x = origin.x
      let y = origin.y - row * (size + spacing)
      draw.rect(
        (x, y),
        (x + size/4, y - size),
        fill: f.at(index-face),
        stroke: black,
        radius: radius
        )
    }
  } else if side == "right" {
    for row in range(3) {
      let index-face = 3*row + 2
      let x = origin.x + 2 * (size + spacing)
      let y = origin.y - row * (size + spacing)
      draw.rect(
        (x+size, y),
        (x + 3*size/4, y - size),
        fill: f.at(index-face),
        stroke: black,
        radius: radius
        )
    } 
  } else {  
  for row in range(3) {
    for col in range(3) {
      let index-face = 3*row + col
      let x = origin.x + col * (size + spacing)
      let y = origin.y - row * (size + spacing)
      draw.rect(
        (x, y),
        (x + size, y - size),
        fill: f.at(index-face),
        stroke: black,
        radius: radius,
        )
      }
    }
  }
}

#let draw-arrows(cube, size, spacing)={
  // positions of corners
  let pos-ld = (size + size/6 + 3*spacing, size/6 - 2*spacing)
  let pos-lu = (size + size/6 + 3*spacing, size - size/6)
  let pos-ru = (2*size - size/6 + 5*spacing, size - size/6)
  let pos-rd = (2*size - size/6 + 5*spacing, size/6 - 2*spacing)

  //positions of edges
  let pos-u = (1.5*size + 4*spacing, size - size/6)
  let pos-l = (size + size/6 + 3*spacing, size/2 - spacing)
  let pos-r = (2*size - size/6 + 5*spacing, size/2 - spacing)
  let pos-d = (1.5*size + 4*spacing, size/6 - 2*spacing)

  let positions = (
    "U" : pos-u, "R" : pos-r, "L" : pos-l, "D" : pos-d,
    "LU" : pos-lu, "LD" : pos-ld, "RU" : pos-ru, "RD" : pos-rd
  )

  let permut = find-permutation(cube)
  for arrow in permut{
      line(
        positions.at(arrow.at(0)),
        positions.at(arrow.at(1)),
        stroke: (paint: black, thickness: 1.2pt),
        mark: (pos: 0, end: "stealth", fill: black),
      )
  }
}

#let draw-pattern(cube, size : 2cm, spacing : 0cm, radius : 0.1cm)={
  draw-face(cube, "L", origin:(x:0cm, y:size), size:size/3, spacing:spacing, radius:radius)
  draw-face(cube, "F", origin:(x:size+3*spacing, y:size), size:size/3, spacing:spacing, radius:radius)
  draw-face(cube, "R", origin:(x:2*size+6*spacing, y:size), size:size/3, spacing:spacing, radius:radius)
  draw-face(cube, "B", origin:(x:3*size+9*spacing, y:size), size:size/3, spacing:spacing, radius:radius)
  draw-face(cube, "U", origin:(x:size+3*spacing, y:2*size+3*spacing), size:size/3, spacing:spacing, radius:radius)
  draw-face(cube, "D", origin:(x:size+3*spacing, y:-3*spacing), size:size/3,spacing:spacing, radius:radius)
}

#let draw-last-layer(cube, size : 2cm, spacing : 0cm, radius : 0.1cm, arrows:false)={ draw-face(cube, "L", origin:(x:0cm, y:size), side:"right", size:size/3, spacing:spacing, radius:radius)
  draw-face(cube, "F", origin:(x:size+3*spacing, y:size), size:size/3, spacing:spacing, radius:radius)
  draw-face(cube, "R", origin:(x:2*size+6*spacing, y:size), side:"left", size:size/3, spacing:spacing, radius:radius)
  draw-face(cube, "U", origin:(x:size+3*spacing, y:2*size+3*spacing), side:"bottom",size:size/3, spacing:spacing, radius:radius)
  draw-face(cube, "D", origin:(x:size+3*spacing, y:-3*spacing), side:"top", size:size/3,spacing:spacing, radius:radius)
  if arrows {draw-arrows(cube, size, spacing)}
}

#let draw-tile = (x, y, fx, fy, color) => {
  draw.line((0,0), (x: 1))
  draw.line((0,0), (y: 1))
  draw.line((0,0), (z: 1))
}

#let draw-3d-corner(cube, origin: (x: 0cm, y: 0cm), size: 1cm) = {
  // Vecteurs isométriques
  let dx = size * 0.866  // cos(30°)
  let dy = size * 0.5    // sin(30°)

  // Dessiner les 9 facettes de chaque face
  for row in range(3) {
    for col in range(3) {
      let i = 3 * row + col
      let f-col = origin.x + col * size
      let f-row = origin.y - row * size

      // Face F (front) — parallèle à l'écran
      draw.rect(
        (f-col, f-row),
        (f-col + size, f-row - size),
        fill: cube.f.at(i),
        stroke: black
      )

      // Face U (top) — inclinaison isométrique vers le haut
      let ux = origin.x + col * dx + row * (-dy)
      let uy = origin.y + col * dy + row * (-dx)
      draw-tile(ux, uy, dx, dy, cube.u.at(i))

      // Face R (right) — inclinaison isométrique vers la droite
      let rx = origin.x + 3 * size + col * (-dy) + row * dx
      let ry = origin.y - col * dx + row * (-dy)
      draw-tile(rx, ry, dy, dx, cube.r.at(i))
    }
  }
}


#let draw-tile(p1, p2, p3, p4, color) = {
  draw.merge-path({
    line(p1, p2, p3, p4, p1)
  }, 
  fill: color,
  stroke: black,)
}

#let draw-3d-face(face, origin, hvec, vvec, size, spacing) = {
  for row in range(3) {
    for col in range(3) {
      let index = 3 * col + row
      let x = origin.x +  col * (size + spacing) * vvec.at(0) +  row * (size + spacing) * hvec.at(0)
      let y = origin.y +  col * (size + spacing) * vvec.at(1) +  row * (size + spacing) * hvec.at(1)

      // Calcule les coins de la tile dans le repère local
      let p1 = (x, y)
      let p2 = (x + size * vvec.at(0), y+ size* vvec.at(1))
      let p3 = (x + size * vvec.at(0) + size * hvec.at(0), y+ size * vvec.at(1) + size * hvec.at(1))
      let p4 = (x + size * hvec.at(0),y + size* hvec.at(1))

      draw-tile(p1, p2, p3, p4, face.at(index))
    }
  }
}

#let draw-3d-cube(cube, size, spacing, vangle : 15deg, hangle : 40deg) = {
  let origin-f = (x:0cm, y:0cm)
  let origin-r = (x : (3*size + 2*spacing) * calc.cos(hangle), y : -(3*size + 2*spacing) * calc.sin(vangle))
  let origin-u = (x : (3*size + 2*spacing) * calc.sin(hangle), y : (3*size + 2*spacing)*calc.sin(vangle))
  draw-3d-face(cube.f, origin-f, (calc.cos(hangle), -calc.sin(vangle)), (0, -1), size, spacing)
  draw-3d-face(cube.r, origin-r, (calc.sin(hangle), calc.sin(vangle)), (0, -1), size, spacing)
  draw-3d-face(cube.u, origin-u, (calc.cos(hangle), -calc.sin(vangle)), (-calc.sin(hangle), -calc.sin(vangle)),  size, spacing)
}


#let oll = (algo, prealgo:"x2 y2", postalgo:"x'") =>{
  
  let premoves = prealgo.split(" ")
  let inverted-premoves = invert-algo(premoves)
  
  let postmoves = postalgo.split(" ")

  let algo = simplify(algo)
  let moves = algo.split(" ")
  let inverted-moves = invert-algo(moves)
  
  let initial-cube = apply-sequence(oll-cube, premoves)
  let cube-after-algo = apply-sequence(initial-cube, inverted-moves)
  let cube-ready-to-display = apply-sequence(cube-after-algo, postmoves)
  let cube-ready-to-assert = apply-sequence(cube-after-algo, inverted-premoves)

  assert(assert-oll(cube-ready-to-assert), message: "The cube is not is an valid state after the algorithm")

  box(width:5cm)[
    #set align(center)
    #canvas(draw-last-layer(cube-ready-to-display))
    #raw(algo)
    #v(1cm)
  ]
}

#let pll = (algo, prealgo:"x2 y2", postalgo:"x'") =>{
  
  let premoves = prealgo.split(" ")  
  let postmoves = postalgo.split(" ")
  let inverted-premoves = invert-algo(premoves)

  let algo = simplify(algo)
  let moves = algo.split(" ")
  let inverted-moves = invert-algo(moves)
  
  let initial-cube = apply-sequence(pll-cube, premoves)
  let cube-after-algo = apply-sequence(initial-cube, inverted-moves)
  let cube-ready-to-display = apply-sequence(cube-after-algo, postmoves)
  let cube-ready-to-assert = apply-sequence(cube-after-algo, inverted-premoves)
  
  assert(assert-pll(cube-ready-to-assert), message: "The cube is not is an valid state after the algorithm")
  box(width:5cm)[
    #set align(center)
    #canvas(draw-last-layer(cube-ready-to-display, arrows:true))
    #box(width:4cm)[
    #raw(algo)]
    #v(1cm)
  ]
}

#let f2l = (algo, prealgo:"x2 y2") =>{
  let premoves = prealgo.split(" ")  
  let inverted-premoves = invert-algo(premoves)

  let moves = algo.split(" ")
  let inverted-moves = invert-algo(moves)
  
  let initial-cube = apply-sequence(f2l-cube, premoves)
  let cube-ready-to-display = apply-sequence(initial-cube, inverted-moves)
  
  box(width:5cm)[
    #set align(center)
    #canvas(draw-3d-cube(cube-ready-to-display, 0.7cm, 0cm))
    #box(width:4cm)[
    #raw(algo)]
    #v(1cm)
  ]
}

