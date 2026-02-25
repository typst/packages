#import "@preview/cetz:0.4.0": canvas,draw

#let steane-code(loc,size:4, color1:yellow, color2:aqua,color3:olive,name: "steane",point-radius:0.1) = {
  import draw: *
  let x = loc.at(0) 
  let y = loc.at(1)
  let locp-vec = ((x - calc.sqrt(3)*size/2,y  - size/2),(x,y - size/2),(x + calc.sqrt(3)*size/2,y  - size/2),(x,y + size),(x - calc.sqrt(3)*size/4,y + size/4),(x + calc.sqrt(3)*size/4,y + size/4),(x,y))
  for (i, locp) in locp-vec.enumerate() {
    circle(locp, radius: point-radius, fill: black, stroke: none, name: name + "-" + str(i + 1))
  }

  for ((i,j,k,l),color) in (((1,2,7,5),color1),((2,3,6,7),color2),((4,5,7,6),color3)) {
    line(name + "-" + str(i), name + "-" + str(j), name + "-" + str(k), name + "-" + str(l), name + "-" + str(i), fill: color)
  }

  for (i, locp) in locp-vec.enumerate() {
    circle(locp, radius: point-radius, fill: black, stroke: none)
  }
}

#let surface-code(
  loc,
  m,
  n,
  size: 1,
  color1: yellow,
  color2: aqua,
  name: "surface",
  type-tag: true,
  point-radius: 0.08,
  boundary-bulge: 0.7,
) = {
  import draw: *
  let x0 = loc.at(0)
  let y0 = loc.at(1)
  for i in range(m) {
    for j in range(n) {
      let x = x0 + i * size
      let y = y0 + j * size
      if (i != m - 1) and (j != n - 1) {
        // determine the color of the plaquette
        let (colora, colorb) = if (calc.rem(i + j, 2) == 0) {
          (color1, color2)
        } else {
          (color2, color1)
        }
        // four types of boundary plaquettes
        if type-tag == (calc.rem(i + j, 2) == 0) {
            if (i == 0) {
              bezier((x, y), (x, y + size), (x - size * boundary-bulge, y + size/2), fill: colorb, stroke: black)
            }
            if (i == m - 2) {
              bezier((x + size, y), (x + size, y + size), (x + size * (1 + boundary-bulge), y + size/2), fill: colorb, stroke: black)
            }
          } else {
            if (j == 0) {
              bezier((x, y), (x + size, y), (x + size/2, y - size * boundary-bulge), fill: colorb, stroke: black)
            }
            if (j == n - 2) {
              bezier((x, y + size), (x + size, y + size), (x + size/2, y + size * (1 + boundary-bulge)), fill: colorb, stroke: black)
            }
          }
          rect((x, y), (x + size, y + size), fill: colora, stroke: black, name: name + "-square" + "-" + str(i) + "-" + str(j))
      }
      circle((x, y), radius: point-radius * size, fill: black, stroke: none, name: name + "-" + str(i) + "-" + str(j))
    }
    }
  }
}

#let color-code-2d(
  loc,
  tiling: "6.6.6",
  shape: "rect",
  size: none,
  hex-orientation: "flat",
  scale: 1,
  color1: yellow,
  color2: aqua,
  color3: olive,
  name: "color-code",
  stroke: black,
  show-stabilizers: false,
  stabilizer-offset: 0.35,
  show-qubits: false,
  qubit-radius: 0.12,
  qubit-color: black,
) = {
  import draw: line, content, circle
  assert(size != none, message: "color-code-2d requires size: (rows/cols or n).")
  let x0 = loc.at(0)
  let y0 = loc.at(1)
  let s = scale
  let pick-color = (color-index) => {
    if (color-index == 0) { color1 } else if (color-index == 1) { color2 } else { color3 }
  }
  let mod3 = (value) => {
    let m = calc.rem(value, 3)
    if m < 0 { m + 3 } else { m }
  }

  if tiling == "6.6.6" {
    let sqrt3 = calc.sqrt(3)
    let half = s / 2
    let diag = sqrt3 / 2 * s
    let qubit-r = qubit-radius * s
    assert(hex-orientation == "flat" or hex-orientation == "pointy", message: "hex-orientation must be \"flat\" or \"pointy\".")

    let axial-to-center = (q, r) => {
      if hex-orientation == "pointy" {
        (x0 + sqrt3 * s * (q + r / 2), y0 + 1.5 * s * r)
      } else {
        (x0 + 1.5 * s * q, y0 + sqrt3 * s * (r + q / 2))
      }
    }

    let offset-to-axial = (col, row) => {
      if hex-orientation == "pointy" {
        (col - (row - calc.rem(row, 2)) / 2, row)
      } else {
        (col, row - (col - calc.rem(col, 2)) / 2)
      }
    }

    let draw-face = (x, y, q, r, color-index) => {
      if hex-orientation == "pointy" {
        line(
          (x, y + s),
          (x + diag, y + half),
          (x + diag, y - half),
          (x, y - s),
          (x - diag, y - half),
          (x - diag, y + half),
          (x, y + s),
          fill: pick-color(color-index),
          stroke: stroke,
          name: name + "-face-" + str(q) + "-" + str(r),
        )
        if show-qubits {
          circle((x, y + s), radius: qubit-r, fill: qubit-color, stroke: none)
          circle((x + diag, y + half), radius: qubit-r, fill: qubit-color, stroke: none)
          circle((x + diag, y - half), radius: qubit-r, fill: qubit-color, stroke: none)
          circle((x, y - s), radius: qubit-r, fill: qubit-color, stroke: none)
          circle((x - diag, y - half), radius: qubit-r, fill: qubit-color, stroke: none)
          circle((x - diag, y + half), radius: qubit-r, fill: qubit-color, stroke: none)
        }
      } else {
        line(
          (x + s, y),
          (x + half, y + diag),
          (x - half, y + diag),
          (x - s, y),
          (x - half, y - diag),
          (x + half, y - diag),
          (x + s, y),
          fill: pick-color(color-index),
          stroke: stroke,
          name: name + "-face-" + str(q) + "-" + str(r),
        )
        if show-qubits {
          circle((x + s, y), radius: qubit-r, fill: qubit-color, stroke: none)
          circle((x + half, y + diag), radius: qubit-r, fill: qubit-color, stroke: none)
          circle((x - half, y + diag), radius: qubit-r, fill: qubit-color, stroke: none)
          circle((x - s, y), radius: qubit-r, fill: qubit-color, stroke: none)
          circle((x - half, y - diag), radius: qubit-r, fill: qubit-color, stroke: none)
          circle((x + half, y - diag), radius: qubit-r, fill: qubit-color, stroke: none)
        }
      }
      if show-stabilizers {
        content((x, y + stabilizer-offset * s), [X])
        content((x, y - stabilizer-offset * s), [Z])
      }
    }

    if shape == "rect" {
      assert(size.rows != none and size.cols != none, message: "shape \"rect\" requires size: (rows: ..., cols: ...).")
      for r in range(size.rows) {
        for q in range(size.cols) {
          let (aq, ar) = offset-to-axial(q, r)
          let (x, y) = axial-to-center(aq, ar)
          let color-index = calc.rem(aq + 2 * ar, 3)
          draw-face(x, y, q, r, color-index)
        }
      }
    } else if shape == "para" or shape == "parallelogram" {
      assert(size.rows != none and size.cols != none, message: "shape \"para\" requires size: (rows: ..., cols: ...).")
      for r in range(size.rows) {
        for q in range(size.cols) {
          let (x, y) = axial-to-center(q, r)
          let color-index = calc.rem(q + 2 * r, 3)
          draw-face(x, y, q, r, color-index)
        }
      }
    } else if shape == "tri" {
      assert(size.n != none, message: "shape \"tri\" requires size: (n: ...).")
      for r in range(size.n) {
        for q in range(size.n - r) {
          let (x, y) = axial-to-center(q, r)
          let color-index = calc.rem(q + 2 * r, 3)
          draw-face(x, y, q, r, color-index)
        }
      }
    } else if shape == "tri-cut" {
      assert(hex-orientation == "flat", message: "shape \"tri-cut\" requires hex-orientation: \"flat\".")
      assert(size.n != none, message: "shape \"tri-cut\" requires size: (n: ...).")
      let n = size.n
      let tri-a = (x0, y0)
      let base-len = 3 * s * n
      let tri-b = (x0 + base-len, y0)
      let tri-c = ((tri-a.at(0) + tri-b.at(0)) / 2, y0 + base-len * sqrt3 / 2)
      let tri-center = ((tri-a.at(0) + tri-b.at(0) + tri-c.at(0)) / 3, (tri-a.at(1) + tri-b.at(1) + tri-c.at(1)) / 3)
      let ox = x0 + half
      let oy = y0 + diag
      let axial-to-center-cut = (q, r) => (ox + 1.5 * s * q, oy + sqrt3 * s * (r + q / 2))

      let pt-x = (p) => p.at(0)
      let pt-y = (p) => p.at(1)
      let add = (a, b) => (pt-x(a) + pt-x(b), pt-y(a) + pt-y(b))
      let sub = (a, b) => (pt-x(a) - pt-x(b), pt-y(a) - pt-y(b))
      let mul = (a, k) => (pt-x(a) * k, pt-y(a) * k)
      let dot = (a, b) => pt-x(a) * pt-x(b) + pt-y(a) * pt-y(b)

      let line-normal = (p1, p2) => {
        let d = sub(p2, p1)
        let n0 = (pt-y(d), -pt-x(d))
        if dot(sub(tri-center, p1), n0) < 0 {
          (-pt-x(n0), -pt-y(n0))
        } else {
          n0
        }
      }

      let intersect = (p1, p2, p0, n) => {
        let d = sub(p2, p1)
        let denom = dot(d, n)
        if denom == 0 { p2 } else {
          let t = dot(sub(p0, p1), n) / denom
          add(p1, mul(d, t))
        }
      }

      let clip-poly = (poly, p0, n) => {
        let out = ()
        if poly.len() == 0 { return out }
        let prev = poly.last()
        let prev-in = dot(sub(prev, p0), n) >= 0
        for curr in poly {
          let curr-in = dot(sub(curr, p0), n) >= 0
          if curr-in != prev-in {
            out += (intersect(prev, curr, p0, n),)
          }
          if curr-in {
            out += (curr,)
          }
          prev = curr
          prev-in = curr-in
        }
        out
      }

      let n-base = line-normal(tri-a, tri-b)
      let n-right = line-normal(tri-b, tri-c)
      let n-left = line-normal(tri-c, tri-a)
      let eps = 1e-6
      let inside-tri = (p) => dot(sub(p, tri-a), n-base) >= -eps and dot(sub(p, tri-b), n-right) >= -eps and dot(sub(p, tri-c), n-left) >= -eps

      let q-min = -2
      let q-max = 2 * n + 2
      let r-min = -n - 2
      let r-max = 2 * n + 2

      for q in range(q-min, q-max + 1) {
        for r in range(r-min, r-max + 1) {
          let (x, y) = axial-to-center-cut(q, r)
          let poly = (
            (x + s, y),
            (x + half, y + diag),
            (x - half, y + diag),
            (x - s, y),
            (x - half, y - diag),
            (x + half, y - diag),
          )
          let clipped = clip-poly(poly, tri-a, n-base)
          let clipped = clip-poly(clipped, tri-b, n-right)
          let clipped = clip-poly(clipped, tri-c, n-left)
          if clipped.len() >= 3 {
            line(..clipped, close: true, fill: pick-color(mod3(q + 2 * r)), stroke: stroke, name: name + "-face-" + str(q) + "-" + str(r))
            if show-stabilizers {
              content((x, y + stabilizer-offset * s), [X])
              content((x, y - stabilizer-offset * s), [Z])
            }
          }
        }
      }
      if show-qubits {
        for q in range(q-min, q-max + 1) {
          for r in range(r-min, r-max + 1) {
            let (x, y) = axial-to-center-cut(q, r)
            let verts = (
              (x + s, y),
              (x + half, y + diag),
              (x - half, y + diag),
              (x - s, y),
              (x - half, y - diag),
              (x + half, y - diag),
            )
            for pt in verts {
              if inside-tri(pt) {
                circle(pt, radius: qubit-r, fill: qubit-color, stroke: none)
              }
            }
          }
        }
      }
    } else {
      assert(false, message: "color-code-2d: unsupported shape \"" + shape + "\" for tiling \"6.6.6\".")
    }
  } else if tiling == "4.6.12" {
    assert(shape == "rect", message: "tiling \"4.6.12\" currently supports only shape \"rect\".")
    assert(size.rows != none and size.cols != none, message: "shape \"rect\" requires size: (rows: ..., cols: ...).")
    let sqrt3 = calc.sqrt(3)
    let a4 = s / 2
    let a6 = s * sqrt3 / 2
    let a12 = s * (1 + sqrt3 / 2)
    let qubit-r = qubit-radius * s

    let vx = (p) => p.at(0)
    let vy = (p) => p.at(1)
    let add = (a, b) => (vx(a) + vx(b), vy(a) + vy(b))
    let sub = (a, b) => (vx(a) - vx(b), vy(a) - vy(b))
    let mul = (a, k) => (vx(a) * k, vy(a) * k)
    let mid = (a, b) => mul(add(a, b), 0.5)
    let square-angle-v1 = 180deg
    let square-angle-v2 = 240deg
    let square-angle-v3 = 300deg
    let hex-angle = 30deg

    let poly-verts = (center, sides, normal-angle) => {
      let radius = s / (2 * calc.sin(180deg / sides))
      let start = normal-angle - 180deg / sides
      let verts = ()
      for k in range(sides) {
        let ang = start + 360deg * k / sides
        verts += ((vx(center) + radius * calc.cos(ang), vy(center) + radius * calc.sin(ang)),)
      }
      verts
    }

    let draw-poly = (center, sides, normal-angle, fill-color, tag, prefix) => {
      let verts = poly-verts(center, sides, normal-angle)
      line(..verts, close: true, fill: fill-color, stroke: stroke, name: name + "-" + prefix + "-" + tag)
      if show-qubits {
        for pt in verts {
          circle(pt, radius: qubit-r, fill: qubit-color, stroke: none)
        }
      }
    }

    let L = 2 * (a12 + a4)
    let v1 = (L, 0)
    let v2 = (L / 2, L * sqrt3 / 2)
    let center = (i, j) => (x0 + i * vx(v1) + j * vx(v2), y0 + i * vy(v1) + j * vy(v2))

    // Dodecagons
    for j in range(size.rows) {
      for i in range(size.cols) {
        let c = center(i, j)
        draw-poly(c, 12, 0deg, color2, str(i) + "-" + str(j), "dod")
      }
    }

    // Squares on lattice edges (three directions)
    for j in range(size.rows) {
      for i in range(size.cols - 1) {
        let a = center(i, j)
        let b = center(i + 1, j)
        let c = mid(a, b)
        draw-poly(c, 4, square-angle-v1, color3, str(i) + "-" + str(j) + "-v1", "sq")
      }
    }
    for j in range(size.rows - 1) {
      for i in range(size.cols) {
        let a = center(i, j)
        let b = center(i, j + 1)
        let c = mid(a, b)
        draw-poly(c, 4, square-angle-v2, color3, str(i) + "-" + str(j) + "-v2", "sq")
      }
    }
    for j in range(size.rows - 1) {
      for i in range(size.cols - 1) {
        let a = center(i + 1, j)
        let b = center(i, j + 1)
        let c = mid(a, b)
        draw-poly(c, 4, square-angle-v3, color3, str(i) + "-" + str(j) + "-v3", "sq")
      }
    }

    // Hexagons at triangle centroids
    for j in range(size.rows - 1) {
      for i in range(size.cols - 1) {
        let a = center(i, j)
        let b = center(i + 1, j)
        let c = center(i, j + 1)
        let cent = mul(add(add(a, b), c), 1 / 3)
        draw-poly(cent, 6, hex-angle, color1, str(i) + "-" + str(j) + "-up", "hex")

        let a2 = center(i + 1, j + 1)
        let cent2 = mul(add(add(b, c), a2), 1 / 3)
        draw-poly(cent2, 6, hex-angle, color1, str(i) + "-" + str(j) + "-down", "hex")
      }
    }
  } else if tiling == "4.8.8" {
    assert(shape == "rect", message: "tiling \"4.8.8\" currently supports only shape \"rect\".")
    assert(size.rows != none and size.cols != none, message: "shape \"rect\" requires size: (rows: ..., cols: ...).")
    let half = s / 2
    let inv-sqrt2 = 1 / calc.sqrt(2)
    let apothem = s * (0.5 + inv-sqrt2)
    let step = apothem + half
    let qubit-r = qubit-radius * s

    let draw-oct = (x, y, q, r, color-index) => {
      line(
        (x - half, y + apothem),
        (x + half, y + apothem),
        (x + apothem, y + half),
        (x + apothem, y - half),
        (x + half, y - apothem),
        (x - half, y - apothem),
        (x - apothem, y - half),
        (x - apothem, y + half),
        (x - half, y + apothem),
        fill: if (color-index == 0) { color1 } else { color2 },
        stroke: stroke,
        name: name + "-oct-" + str(q) + "-" + str(r),
      )
      if show-qubits {
        circle((x - half, y + apothem), radius: qubit-r, fill: qubit-color, stroke: none)
        circle((x + half, y + apothem), radius: qubit-r, fill: qubit-color, stroke: none)
        circle((x + apothem, y + half), radius: qubit-r, fill: qubit-color, stroke: none)
        circle((x + apothem, y - half), radius: qubit-r, fill: qubit-color, stroke: none)
        circle((x + half, y - apothem), radius: qubit-r, fill: qubit-color, stroke: none)
        circle((x - half, y - apothem), radius: qubit-r, fill: qubit-color, stroke: none)
        circle((x - apothem, y - half), radius: qubit-r, fill: qubit-color, stroke: none)
        circle((x - apothem, y + half), radius: qubit-r, fill: qubit-color, stroke: none)
      }
      if show-stabilizers {
        content((x, y + stabilizer-offset * s), [X])
        content((x, y - stabilizer-offset * s), [Z])
      }
    }

    let draw-square = (x, y, tag) => {
      line(
        (x - half, y + half),
        (x + half, y + half),
        (x + half, y - half),
        (x - half, y - half),
        (x - half, y + half),
        fill: color3,
        stroke: stroke,
        name: name + "-" + tag,
      )
      if show-qubits {
        circle((x - half, y + half), radius: qubit-r, fill: qubit-color, stroke: none)
        circle((x + half, y + half), radius: qubit-r, fill: qubit-color, stroke: none)
        circle((x + half, y - half), radius: qubit-r, fill: qubit-color, stroke: none)
        circle((x - half, y - half), radius: qubit-r, fill: qubit-color, stroke: none)
      }
      if show-stabilizers {
        content((x, y + stabilizer-offset * s), [X])
        content((x, y - stabilizer-offset * s), [Z])
      }
    }

    let grid-rows = size.rows * 2 - 1
    let grid-cols = size.cols * 2 - 1
    for r in range(grid-rows) {
      for q in range(grid-cols) {
        let x = x0 + q * step
        let y = y0 + r * step
        if calc.rem(q + r, 2) == 0 {
          let color-index = calc.rem(q, 2)
          draw-oct(x, y, q, r, color-index)
        } else {
          draw-square(x, y, "sq-" + str(q) + "-" + str(r))
        }
      }
    }
  } else {
    assert(false, message: "color-code-2d: unsupported tiling \"" + tiling + "\".")
  }
}

#let stabilizer-label(loc, size:1, color1:yellow, color2:aqua) = {
  import draw: *
  let x = loc.at(0)
  let y = loc.at(1)
  content((x, y), box(stroke: black, inset: 10pt, [$X$ stabilizers],fill: color2, radius: 4pt))
  content((x, y - 1.5*size), box(stroke: black, inset: 10pt, [$Z$ stabilizers],fill: color1, radius: 4pt))
}

#let toric-code(loc, m, n, size:1,circle-radius:0.2,color1:white,color2:gray,line-thickness:1pt,name: "toric") = {
  import draw: *
    for i in range(m){
    for j in range(n){
            let x = loc.at(0) + i * size
      let y = loc.at(1) - j * size
 rect((x, y), (x + size, y - size), fill: color1, stroke: black,name: name + "-square" + "-" + str(i) + "-" + str(j))
    }}
  for i in range(m){
    for j in range(n){
      let x = loc.at(0) + i * size
      let y = loc.at(1) - j * size

      circle((x + size/2, y), radius: circle-radius, fill: color1, stroke: (thickness: line-thickness),name: name + "-point-vertical-" + str(i) +"-" + str(j))
      circle((x, y - size/2), radius: circle-radius, fill: color2, stroke: (thickness: line-thickness),name: name + "-point-horizontal-" + str(i) +"-" + str(j))
    }
  }
}

#let plaquette-code-label(loc, posx,posy, ver-vec:((-1,0),(-1,1)), hor-vec:((0,0),(-1,0)), size:1,circle-radius:0.2, color1:white, color2:gray, color3:yellow,line-thickness:1pt,name: "toric") = {
  import draw: *
      let x = loc.at(0) + posx * size
      let y = loc.at(1) - posy * size
  rect((x, y), (x - size, y - size), fill: color3, stroke: black,name: name + "-plaquette")
  
  circle(name+"-point-vertical-" + str(posx - 1) + "-" + str(posy),radius: circle-radius, fill: color1, stroke: (thickness: line-thickness))
  circle(name+"-point-vertical-" + str(posx - 1) + "-" + str(posy+1),radius: circle-radius, fill: color1, stroke: (thickness: line-thickness))
  circle(name+"-point-horizontal-" + str(posx) + "-" + str(posy),radius: circle-radius, fill: color2, stroke: (thickness: line-thickness))
  circle(name+"-point-horizontal-" + str(posx - 1) + "-" + str(posy),radius: circle-radius, fill: color2, stroke: (thickness: line-thickness))

  for (i,j) in ver-vec {
    circle(name+"-point-vertical-" + str(i+posx) + "-" + str(j+posy),radius: circle-radius, fill: color3, stroke: (thickness: line-thickness))
  }
  for (i,j) in hor-vec {
    circle(name+"-point-horizontal-" + str(i+posx) + "-" + str(j+posy),radius: circle-radius, fill: color3, stroke: (thickness: line-thickness))
  }
}


#let vertex-code-label(loc, posx,posy, ver-vec:((-1,0),(0,0)), hor-vec:((0,0),(0,-1)), size:1, circle-radius:0.2, color1:white, color2:gray, color3:aqua,line-thickness:1pt,name: "toric") = {
  import draw: *
  let x = loc.at(0) + posx * size
  let y = loc.at(1) - posy * size
  rect((x - circle-radius, y - circle-radius), (x + circle-radius, y + circle-radius), fill: color3, stroke: black,name: name + "-vertex")

  for (i,j) in ver-vec {
    circle(name+"-point-vertical-" + str(i+posx) + "-" + str(j+posy),radius: circle-radius, fill: color3, stroke: (thickness: line-thickness))
  }
  for (i,j) in hor-vec {
    circle(name+"-point-horizontal-" + str(i+posx) + "-" + str(j+posy),radius: circle-radius, fill: color3, stroke: (thickness: line-thickness))}
}
