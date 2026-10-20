#import "@preview/cetz:0.4.0": canvas,draw

#let steane-code(loc,size:4, color1:yellow, color2:aqua,color3:olive,name: "steane",point-radius:0.1) = {
  let params = (
    loc: loc,
    size: size,
    color1: color1,
    color2: color2,
    color3: color3,
    name: name,
    point-radius: point-radius,
  )

  let x = loc.at(0)
  let y = loc.at(1)
  let locp-vec = ((x - calc.sqrt(3)*size/2,y  - size/2),(x,y - size/2),(x + calc.sqrt(3)*size/2,y  - size/2),(x,y + size),(x - calc.sqrt(3)*size/4,y + size/4),(x + calc.sqrt(3)*size/4,y + size/4),(x,y))

  let qubit-name = (id) => name + "-" + str(id)
  let qubit-anchor = (id) => (name: (qubit-name)(id), anchor: "center")

  let qubits = ()
  for (i, locp) in locp-vec.enumerate() {
    qubits += (
      (
        id: i + 1,
        pos: locp,
        name: (qubit-name)(i + 1),
      ),
    )
  }

  let resolve-qubit = (id) => {
    let target-id = str(id)
    let found = none
    for qubit in qubits {
      if found == none and str(qubit.id) == target-id {
        found = qubit
      }
    }
    found
  }

  let draw-background = () => {
    import draw: circle, line
    for qubit in qubits {
      circle(qubit.pos, radius: point-radius, fill: black, stroke: none, name: qubit.name)
    }

    for ((i,j,k,l),color) in (((1,2,7,5),color1),((2,3,6,7),color2),((4,5,7,6),color3)) {
      line((qubit-name)(i), (qubit-name)(j), (qubit-name)(k), (qubit-name)(l), (qubit-name)(i), fill: color)
    }

    for qubit in qubits {
      circle(qubit.pos, radius: point-radius, fill: black, stroke: none)
    }
  }

  let highlight-qubit = (id, radius: none, fill: none, stroke: (paint: red, thickness: 1pt)) => {
    import draw: circle
    let qubit = (resolve-qubit)(id)
    assert(qubit != none, message: "Unknown Steane qubit id \"" + str(id) + "\".")
    circle(qubit.pos, radius: if radius == none { point-radius } else { radius }, fill: fill, stroke: stroke)
  }

  (
    params: params,
    qubits: qubits,
    draw-background: draw-background,
    qubit-anchor: qubit-anchor,
    highlight-qubit: highlight-qubit,
  )
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
  let params = (
    loc: loc,
    m: m,
    n: n,
    size: size,
    color1: color1,
    color2: color2,
    name: name,
    type-tag: type-tag,
    point-radius: point-radius,
    boundary-bulge: boundary-bulge,
  )

  let normalize-qubit-id = (id) => {
    if type(id) == array {
      assert(id.len() == 2, message: "Surface qubit id must be (i, j).")
      str(id.at(0)) + "-" + str(id.at(1))
    } else {
      str(id)
    }
  }

  let qubit-name = (id) => name + "-" + normalize-qubit-id(id)
  let qubit-anchor = (id) => (name: (qubit-name)(id), anchor: "center")

  let qubits = ()
  let x0 = loc.at(0)
  let y0 = loc.at(1)
  for i in range(m) {
    for j in range(n) {
      let x = x0 + i * size
      let y = y0 + j * size
      qubits += (
        (
          id: (i, j),
          pos: (x, y),
          name: (qubit-name)((i, j)),
          meta: (i: i, j: j),
        ),
      )
    }
  }

  let resolve-qubit = (id) => {
    let target-id = normalize-qubit-id(id)
    let found = none
    for qubit in qubits {
      if found == none and normalize-qubit-id(qubit.id) == target-id {
        found = qubit
      }
    }
    found
  }

  let draw-background = () => {
    import draw: rect, circle, bezier
    for i in range(m) {
      for j in range(n) {
        let x = x0 + i * size
        let y = y0 + j * size
        if (i != m - 1) and (j != n - 1) {
          let (colora, colorb) = if (calc.rem(i + j, 2) == 0) {
            (color1, color2)
          } else {
            (color2, color1)
          }
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
      }
    }
    for qubit in qubits {
      circle(qubit.pos, radius: point-radius * size, fill: black, stroke: none, name: qubit.name)
    }
  }

  let highlight-qubit = (id, radius: none, fill: none, stroke: (paint: red, thickness: 1pt)) => {
    import draw: circle
    let qubit = (resolve-qubit)(id)
    assert(qubit != none, message: "Unknown surface qubit id \"" + normalize-qubit-id(id) + "\".")
    circle(qubit.pos, radius: if radius == none { point-radius * size } else { radius }, fill: fill, stroke: stroke)
  }

  (
    params: params,
    qubits: qubits,
    draw-background: draw-background,
    qubit-anchor: qubit-anchor,
    highlight-qubit: highlight-qubit,
  )
}

#let color-code-2d-render(
  loc,
  tiling: "6.6.6",
  shape: "rect",
  size: none,
  orientation: "flat",
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
    assert(orientation == "flat" or orientation == "pointy", message: "orientation must be \"flat\" or \"pointy\".")

    let axial-to-center = (q, r) => {
      if orientation == "pointy" {
        (x0 + sqrt3 * s * (q + r / 2), y0 + 1.5 * s * r)
      } else {
        (x0 + 1.5 * s * q, y0 + sqrt3 * s * (r + q / 2))
      }
    }

    let offset-to-axial = (col, row) => {
      if orientation == "pointy" {
        (col - (row - calc.rem(row, 2)) / 2, row)
      } else {
        (col, row - (col - calc.rem(col, 2)) / 2)
      }
    }

    let draw-face = (x, y, q, r, color-index) => {
      if orientation == "pointy" {
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
          circle((x, y + s), radius: qubit-r, fill: qubit-color, stroke: none, name: name + "-qubit-" + str(q) + "-" + str(r) + "-0")
          circle((x + diag, y + half), radius: qubit-r, fill: qubit-color, stroke: none, name: name + "-qubit-" + str(q) + "-" + str(r) + "-1")
          circle((x + diag, y - half), radius: qubit-r, fill: qubit-color, stroke: none, name: name + "-qubit-" + str(q) + "-" + str(r) + "-2")
          circle((x, y - s), radius: qubit-r, fill: qubit-color, stroke: none, name: name + "-qubit-" + str(q) + "-" + str(r) + "-3")
          circle((x - diag, y - half), radius: qubit-r, fill: qubit-color, stroke: none, name: name + "-qubit-" + str(q) + "-" + str(r) + "-4")
          circle((x - diag, y + half), radius: qubit-r, fill: qubit-color, stroke: none, name: name + "-qubit-" + str(q) + "-" + str(r) + "-5")
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
          circle((x + s, y), radius: qubit-r, fill: qubit-color, stroke: none, name: name + "-qubit-" + str(q) + "-" + str(r) + "-0")
          circle((x + half, y + diag), radius: qubit-r, fill: qubit-color, stroke: none, name: name + "-qubit-" + str(q) + "-" + str(r) + "-1")
          circle((x - half, y + diag), radius: qubit-r, fill: qubit-color, stroke: none, name: name + "-qubit-" + str(q) + "-" + str(r) + "-2")
          circle((x - s, y), radius: qubit-r, fill: qubit-color, stroke: none, name: name + "-qubit-" + str(q) + "-" + str(r) + "-3")
          circle((x - half, y - diag), radius: qubit-r, fill: qubit-color, stroke: none, name: name + "-qubit-" + str(q) + "-" + str(r) + "-4")
          circle((x + half, y - diag), radius: qubit-r, fill: qubit-color, stroke: none, name: name + "-qubit-" + str(q) + "-" + str(r) + "-5")
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
      assert(orientation == "flat", message: "shape \"tri-cut\" requires orientation: \"flat\".")
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
      let geom-eps = 1e-6
      let close-pt = (a, b) => calc.abs(pt-x(a) - pt-x(b)) <= geom-eps and calc.abs(pt-y(a) - pt-y(b)) <= geom-eps
      let cross = (a, b) => pt-x(a) * pt-y(b) - pt-y(a) * pt-x(b)
      let clean-poly = (poly) => {
        let dedup = ()
        for pt in poly {
          if dedup.len() == 0 or not close-pt(dedup.last(), pt) {
            dedup += (pt,)
          }
        }
        if dedup.len() > 1 and close-pt(dedup.at(0), dedup.last()) {
          dedup = dedup.slice(0, dedup.len() - 1)
        }
        if dedup.len() <= 2 {
          return dedup
        }
        let cleaned = ()
        for i in range(dedup.len()) {
          let prev = if i == 0 { dedup.last() } else { dedup.at(i - 1) }
          let curr = dedup.at(i)
          let next = if i + 1 == dedup.len() { dedup.at(0) } else { dedup.at(i + 1) }
          let v1 = sub(curr, prev)
          let v2 = sub(next, curr)
          let collinear = calc.abs(cross(v1, v2)) <= geom-eps and dot(v1, v2) > 0
          if not collinear {
            cleaned += (curr,)
          }
        }
        cleaned
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
          let clipped = clean-poly(clipped)
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

#let color-code-666-canonical(
  loc,
  shape: "rect",
  size: none,
  orientation: "flat",
  scale: 1,
) = {
  assert(size != none, message: "color-code-2d requires size: (rows/cols or n).")
  assert(orientation == "flat" or orientation == "pointy", message: "orientation must be \"flat\" or \"pointy\".")
  let x0 = loc.at(0)
  let y0 = loc.at(1)
  let s = scale
  let sqrt3 = calc.sqrt(3)
  let half = s / 2
  let diag = sqrt3 / 2 * s

  let mod3 = (value) => {
    let m = calc.rem(value, 3)
    if m < 0 { m + 3 } else { m }
  }

  let pt-x = (p) => p.at(0)
  let pt-y = (p) => p.at(1)
  let add = (a, b) => (pt-x(a) + pt-x(b), pt-y(a) + pt-y(b))
  let sub = (a, b) => (pt-x(a) - pt-x(b), pt-y(a) - pt-y(b))
  let mul = (a, k) => (pt-x(a) * k, pt-y(a) * k)
  let dot = (a, b) => pt-x(a) * pt-x(b) + pt-y(a) * pt-y(b)
  let add-int = (a, b) => (a.at(0) + b.at(0), a.at(1) + b.at(1))

  let axial-to-center = (q, r) => {
    if orientation == "pointy" {
      (x0 + sqrt3 * s * (q + r / 2), y0 + 1.5 * s * r)
    } else {
      (x0 + 1.5 * s * q, y0 + sqrt3 * s * (r + q / 2))
    }
  }

  let offset-to-axial = (col, row) => {
    if orientation == "pointy" {
      (col - (row - calc.rem(row, 2)) / 2, row)
    } else {
      (col, row - (col - calc.rem(col, 2)) / 2)
    }
  }

  let vertex-offsets = if orientation == "pointy" {
    (
      (0, s),
      (diag, half),
      (diag, -half),
      (0, -s),
      (-diag, -half),
      (-diag, half),
    )
  } else {
    (
      (s, 0),
      (half, diag),
      (-half, diag),
      (-s, 0),
      (-half, -diag),
      (half, -diag),
    )
  }

  let vertex-key-offsets = if orientation == "pointy" {
    (
      (0, 2),
      (1, 1),
      (1, -1),
      (0, -2),
      (-1, -1),
      (-1, 1),
    )
  } else {
    (
      (2, 0),
      (1, 1),
      (-1, 1),
      (-2, 0),
      (-1, -1),
      (1, -1),
    )
  }

  let center-key = (q, r) => {
    if orientation == "pointy" {
      (2 * q + r, 3 * r)
    } else {
      (3 * q, 2 * r + q)
    }
  }

  let all-corners = (0, 1, 2, 3, 4, 5)
  let face-seeds = ()
  let hex-bounds = none

  if shape == "rect" {
    assert(size.rows != none and size.cols != none, message: "shape \"rect\" requires size: (rows: ..., cols: ...).")
    for row in range(size.rows) {
      for col in range(size.cols) {
        let (aq, ar) = offset-to-axial(col, row)
        let center = axial-to-center(aq, ar)
        let verts = all-corners.map((corner) => add(center, vertex-offsets.at(corner)))
        face-seeds += ((
          aq: aq,
          ar: ar,
          center: center,
          vertices: verts,
          "qubit-corners": all-corners,
          kind: "hex",
          meta: (shape: "rect", row: row, col: col),
        ),)
      }
    }
  } else if shape == "para" or shape == "parallelogram" {
    assert(size.rows != none and size.cols != none, message: "shape \"para\" requires size: (rows: ..., cols: ...).")
    for row in range(size.rows) {
      for col in range(size.cols) {
        let aq = col
        let ar = row
        let center = axial-to-center(aq, ar)
        let verts = all-corners.map((corner) => add(center, vertex-offsets.at(corner)))
        face-seeds += ((
          aq: aq,
          ar: ar,
          center: center,
          vertices: verts,
          "qubit-corners": all-corners,
          kind: "hex",
          meta: (shape: "para", row: row, col: col),
        ),)
      }
    }
  } else if shape == "tri" {
    assert(size.n != none, message: "shape \"tri\" requires size: (n: ...).")
    for row in range(size.n) {
      for col in range(size.n - row) {
        let aq = col
        let ar = row
        let center = axial-to-center(aq, ar)
        let verts = all-corners.map((corner) => add(center, vertex-offsets.at(corner)))
        face-seeds += ((
          aq: aq,
          ar: ar,
          center: center,
          vertices: verts,
          "qubit-corners": all-corners,
          kind: "hex",
          meta: (shape: "tri", row: row, col: col),
        ),)
      }
    }
  } else if shape == "hex" {
    assert(type(size) == dictionary and size.lx != none and size.ly != none and size.lz != none, message: "shape \"hex\" requires size: (lx: ..., ly: ..., lz: ...).")
    assert(size.lx > 0 and size.ly > 0 and size.lz > 0, message: "shape \"hex\" requires positive lx, ly, lz.")
    let lx = size.lx
    let ly = size.ly
    let lz = size.lz

    let x-min = -(ly - 1)
    let x-max = lz - 1
    let y-min = -(lz - 1)
    let y-max = lx - 1
    let z-min = -(lx - 1)
    let z-max = ly - 1
    hex-bounds = (
      "x+": x-max,
      "y+": y-max,
      "z+": z-max,
      "x-": x-min,
      "y-": y-min,
      "z-": z-min,
    )

    for aq in range(x-min, x-max + 1) {
      for ar in range(z-min, z-max + 1) {
        let x = aq
        let z = ar
        let y = -x - z
        if y >= y-min and y <= y-max {
          let center = axial-to-center(aq, ar)
          let verts = all-corners.map((corner) => add(center, vertex-offsets.at(corner)))
          face-seeds += ((
            aq: aq,
            ar: ar,
            center: center,
            vertices: verts,
            "qubit-corners": all-corners,
            kind: "hex",
            meta: (shape: "hex", cube: (x: x, y: y, z: z)),
          ),)
        }
      }
    }
  } else if shape == "tri-cut" {
    assert(orientation == "flat", message: "shape \"tri-cut\" requires orientation: \"flat\".")
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

    let line-normal = (p1, p2) => {
      let d = sub(p2, p1)
      let n0 = (pt-y(d), -pt-x(d))
      if dot(sub(tri-center, p1), n0) < 0 {
        (-pt-x(n0), -pt-y(n0))
      } else {
        n0
      }
    }

    let intersect = (p1, p2, p0, n0) => {
      let d = sub(p2, p1)
      let denom = dot(d, n0)
      if denom == 0 {
        p2
      } else {
        let t = dot(sub(p0, p1), n0) / denom
        add(p1, mul(d, t))
      }
    }

    let clip-poly = (poly, p0, n0) => {
      let out = ()
      if poly.len() == 0 { return out }
      let prev = poly.last()
      let prev-in = dot(sub(prev, p0), n0) >= 0
      for curr in poly {
        let curr-in = dot(sub(curr, p0), n0) >= 0
        if curr-in != prev-in {
          out += (intersect(prev, curr, p0, n0),)
        }
        if curr-in {
          out += (curr,)
        }
        prev = curr
        prev-in = curr-in
      }
      out
    }
    let geom-eps = 1e-6
    let close-pt = (a, b) => calc.abs(pt-x(a) - pt-x(b)) <= geom-eps and calc.abs(pt-y(a) - pt-y(b)) <= geom-eps
    let cross = (a, b) => pt-x(a) * pt-y(b) - pt-y(a) * pt-x(b)
    let clean-poly = (poly) => {
      let dedup = ()
      for pt in poly {
        if dedup.len() == 0 or not close-pt(dedup.last(), pt) {
          dedup += (pt,)
        }
      }
      if dedup.len() > 1 and close-pt(dedup.at(0), dedup.last()) {
        dedup = dedup.slice(0, dedup.len() - 1)
      }
      if dedup.len() <= 2 {
        return dedup
      }
      let cleaned = ()
      for i in range(dedup.len()) {
        let prev = if i == 0 { dedup.last() } else { dedup.at(i - 1) }
        let curr = dedup.at(i)
        let next = if i + 1 == dedup.len() { dedup.at(0) } else { dedup.at(i + 1) }
        let v1 = sub(curr, prev)
        let v2 = sub(next, curr)
        let collinear = calc.abs(cross(v1, v2)) <= geom-eps and dot(v1, v2) > 0
        if not collinear {
          cleaned += (curr,)
        }
      }
      cleaned
    }

    let n-base = line-normal(tri-a, tri-b)
    let n-right = line-normal(tri-b, tri-c)
    let n-left = line-normal(tri-c, tri-a)
    let eps = 1e-6
    let inside-tri = (p) => {
      let inside-base = dot(sub(p, tri-a), n-base) >= -eps
      let inside-right = dot(sub(p, tri-b), n-right) >= -eps
      let inside-left = dot(sub(p, tri-c), n-left) >= -eps
      inside-base and inside-right and inside-left
    }

    let q-min = -2
    let q-max = 2 * n + 2
    let r-min = -n - 2
    let r-max = 2 * n + 2

    for aq in range(q-min, q-max + 1) {
      for ar in range(r-min, r-max + 1) {
        let center = axial-to-center-cut(aq, ar)
        let full-verts = all-corners.map((corner) => add(center, vertex-offsets.at(corner)))
        let clipped = clip-poly(full-verts, tri-a, n-base)
        let clipped = clip-poly(clipped, tri-b, n-right)
        let clipped = clip-poly(clipped, tri-c, n-left)
        let clipped = clean-poly(clipped)
        if clipped.len() >= 3 {
          let qubit-corners = ()
          for corner in all-corners {
            if inside-tri(full-verts.at(corner)) {
              qubit-corners += (corner,)
            }
          }
          face-seeds += ((
            aq: aq,
            ar: ar,
            center: center,
            vertices: clipped,
            "qubit-corners": qubit-corners,
            kind: "clipped-hex",
            meta: (shape: "tri-cut"),
          ),)
        }
      }
    }
  } else {
    assert(false, message: "color-code-2d: unsupported shape \"" + shape + "\" for tiling \"6.6.6\".")
  }

  let append-unique = (items, value) => if value in items { items } else { items + (value,) }
  let qubit-by-key = (:)
  let qubit-by-id = (:)
  let qubit-order = ()
  let face-cube-by-id = (:)
  let faces = ()

  for seed in face-seeds {
    let face-id = "f-" + str(seed.aq) + "-" + str(seed.ar)
    let cube-x = seed.aq
    let cube-z = seed.ar
    let cube-y = -cube-x - cube-z
    face-cube-by-id.insert(face-id, (x: cube-x, y: cube-y, z: cube-z))
    let ckey = center-key(seed.aq, seed.ar)
    let face-qubits = ()
    for corner in seed.at("qubit-corners") {
      let key-vec = add-int(ckey, vertex-key-offsets.at(corner))
      let vertex-key = str(key-vec.at(0)) + "-" + str(key-vec.at(1))
      let vertex-pos = add(seed.center, vertex-offsets.at(corner))
      let qid = if vertex-key in qubit-by-key {
        qubit-by-key.at(vertex-key)
      } else {
        let new-id = "q-" + vertex-key
        qubit-by-key.insert(vertex-key, new-id)
        qubit-order.push(new-id)
        qubit-by-id.insert(new-id, (
          id: new-id,
          pos: vertex-pos,
          "incident-faces": (),
          "boundary-tags": (),
          meta: (vertex-key: vertex-key),
        ))
        new-id
      }
      let current = qubit-by-id.at(qid)
      let incidents = append-unique(current.at("incident-faces"), face-id)
      qubit-by-id.insert(qid, (
        id: current.id,
        pos: current.pos,
        "incident-faces": incidents,
        "boundary-tags": current.at("boundary-tags"),
        meta: current.meta,
      ))
      face-qubits = append-unique(face-qubits, qid)
    }
    let color-index = mod3(seed.aq + 2 * seed.ar)
    let color-tag = if color-index == 0 { "c0" } else if color-index == 1 { "c1" } else { "c2" }
    faces.push((
      id: face-id,
      kind: seed.kind,
      color: color-tag,
      center: seed.center,
      vertices: seed.vertices,
      qubits: face-qubits,
      meta: (
        aq: seed.aq,
        ar: seed.ar,
        cube: (x: cube-x, y: cube-y, z: cube-z),
        color-index: color-index,
        shape: shape,
        source: seed.meta,
      ),
    ))
  }

  let boundary-x-plus = ()
  let boundary-y-plus = ()
  let boundary-z-plus = ()
  let boundary-x-minus = ()
  let boundary-y-minus = ()
  let boundary-z-minus = ()
  for qid in qubit-order {
    let qubit = qubit-by-id.at(qid)
    let degree = qubit.at("incident-faces").len()
    let boundary-tags = if degree < 3 and shape == "hex" and hex-bounds != none {
      let tags = ()
      let on-x-plus = false
      let on-y-plus = false
      let on-z-plus = false
      let on-x-minus = false
      let on-y-minus = false
      let on-z-minus = false
      for fid in qubit.at("incident-faces") {
        let cube = face-cube-by-id.at(fid)
        if cube.x == hex-bounds.at("x+") { on-x-plus = true }
        if cube.y == hex-bounds.at("y+") { on-y-plus = true }
        if cube.z == hex-bounds.at("z+") { on-z-plus = true }
        if cube.x == hex-bounds.at("x-") { on-x-minus = true }
        if cube.y == hex-bounds.at("y-") { on-y-minus = true }
        if cube.z == hex-bounds.at("z-") { on-z-minus = true }
      }
      if on-x-plus { tags = append-unique(tags, "x+") }
      if on-y-plus { tags = append-unique(tags, "y+") }
      if on-z-plus { tags = append-unique(tags, "z+") }
      if on-x-minus { tags = append-unique(tags, "x-") }
      if on-y-minus { tags = append-unique(tags, "y-") }
      if on-z-minus { tags = append-unique(tags, "z-") }
      tags
    } else if degree < 3 {
      ("boundary",)
    } else {
      ()
    }
    if "x+" in boundary-tags { boundary-x-plus = append-unique(boundary-x-plus, qid) }
    if "y+" in boundary-tags { boundary-y-plus = append-unique(boundary-y-plus, qid) }
    if "z+" in boundary-tags { boundary-z-plus = append-unique(boundary-z-plus, qid) }
    if "x-" in boundary-tags { boundary-x-minus = append-unique(boundary-x-minus, qid) }
    if "y-" in boundary-tags { boundary-y-minus = append-unique(boundary-y-minus, qid) }
    if "z-" in boundary-tags { boundary-z-minus = append-unique(boundary-z-minus, qid) }
    qubit-by-id.insert(qid, (
      id: qubit.id,
      pos: qubit.pos,
      "incident-faces": qubit.at("incident-faces"),
      "boundary-tags": boundary-tags,
      meta: (
        vertex-key: qubit.meta.vertex-key,
        degree: degree,
      ),
    ))
  }

  let qubits = qubit-order.map((qid) => qubit-by-id.at(qid))
  let boundary-qubits = qubits.filter((qubit) => qubit.at("boundary-tags").len() > 0).map((qubit) => qubit.id)
  let boundaries = if shape == "hex" and hex-bounds != none {
    (
      qubits: boundary-qubits,
      "x+": boundary-x-plus,
      "y+": boundary-y-plus,
      "z+": boundary-z-plus,
      "x-": boundary-x-minus,
      "y-": boundary-y-minus,
      "z-": boundary-z-minus,
    )
  } else {
    (
      qubits: boundary-qubits,
    )
  }

  (
    faces: faces,
    qubits: qubits,
    boundaries: boundaries,
    basis: (
      orientation: orientation,
      scale: scale,
      axial: (
        center-key: if orientation == "pointy" { "u=2q+r,v=3r" } else { "u=3q,v=2r+q" },
      ),
      vertex-key-offsets: vertex-key-offsets,
    ),
  )
}

#let color-code-4612-canonical(
  loc,
  shape: "rect",
  size: none,
  scale: 1,
) = {
  assert(shape == "rect", message: "tiling \"4.6.12\" currently supports only shape \"rect\".")
  assert(type(size) == dictionary and size.rows != none and size.cols != none, message: "shape \"rect\" requires size: (rows: ..., cols: ...).")

  let x0 = loc.at(0)
  let y0 = loc.at(1)
  let sqrt3 = calc.sqrt(3)
  let a4 = 0.5
  let a12 = 1 + sqrt3 / 2
  let L = 2 * (a12 + a4)
  let square-angle-v1 = 180deg
  let square-angle-v2 = 240deg
  let square-angle-v3 = 300deg
  let hex-angle = 30deg

  let vx = (p) => p.at(0)
  let vy = (p) => p.at(1)
  let add = (a, b) => (vx(a) + vx(b), vy(a) + vy(b))
  let mul = (a, k) => (vx(a) * k, vy(a) * k)
  let mid = (a, b) => mul(add(a, b), 0.5)
  let append-unique = (items, value) => if value in items { items } else { items + (value,) }
  let map-point = (pt) => (
    x0 + vx(pt) * scale,
    y0 + vy(pt) * scale,
  )
  let quantize = (value) => calc.round(value * 1000000)
  let vertex-key = (pt) => str(quantize(vx(pt))) + "-" + str(quantize(vy(pt)))

  let poly-verts-local = (center, sides, normal-angle) => {
    let radius = 1 / (2 * calc.sin(180deg / sides))
    let start = normal-angle - 180deg / sides
    let verts = ()
    for k in range(sides) {
      let ang = start + 360deg * k / sides
      verts += ((vx(center) + radius * calc.cos(ang), vy(center) + radius * calc.sin(ang)),)
    }
    verts
  }

  let v1 = (L, 0)
  let v2 = (L / 2, L * sqrt3 / 2)
  let center = (i, j) => (
    i * vx(v1) + j * vx(v2),
    i * vy(v1) + j * vy(v2),
  )

  let qubit-by-key = (:)
  let qubit-by-id = (:)
  let qubit-order = ()
  let faces = ()
  let face-seeds = ()

  for j in range(size.rows) {
    for i in range(size.cols) {
      let c = center(i, j)
      let id = "f-dod-" + str(i) + "-" + str(j)
      let verts = poly-verts-local(c, 12, 0deg)
      face-seeds += ((id: id, kind: "dodec", color: "c1", center: c, vertices: verts, meta: (i: i, j: j, role: "dodec")),)
    }
  }

  for j in range(size.rows) {
    for i in range(size.cols - 1) {
      let c = mid(center(i, j), center(i + 1, j))
      let id = "f-sq-" + str(i) + "-" + str(j) + "-v1"
      let verts = poly-verts-local(c, 4, square-angle-v1)
      face-seeds += ((id: id, kind: "square", color: "c2", center: c, vertices: verts, meta: (i: i, j: j, role: "sq", edge: "v1")),)
    }
  }
  for j in range(size.rows - 1) {
    for i in range(size.cols) {
      let c = mid(center(i, j), center(i, j + 1))
      let id = "f-sq-" + str(i) + "-" + str(j) + "-v2"
      let verts = poly-verts-local(c, 4, square-angle-v2)
      face-seeds += ((id: id, kind: "square", color: "c2", center: c, vertices: verts, meta: (i: i, j: j, role: "sq", edge: "v2")),)
    }
  }
  for j in range(size.rows - 1) {
    for i in range(size.cols - 1) {
      let c = mid(center(i + 1, j), center(i, j + 1))
      let id = "f-sq-" + str(i) + "-" + str(j) + "-v3"
      let verts = poly-verts-local(c, 4, square-angle-v3)
      face-seeds += ((id: id, kind: "square", color: "c2", center: c, vertices: verts, meta: (i: i, j: j, role: "sq", edge: "v3")),)
    }
  }

  for j in range(size.rows - 1) {
    for i in range(size.cols - 1) {
      let a = center(i, j)
      let b = center(i + 1, j)
      let c = center(i, j + 1)
      let up-center = mul(add(add(a, b), c), 1 / 3)
      let up-id = "f-hex-" + str(i) + "-" + str(j) + "-up"
      let up-verts = poly-verts-local(up-center, 6, hex-angle)
      face-seeds += ((id: up-id, kind: "hex", color: "c0", center: up-center, vertices: up-verts, meta: (i: i, j: j, role: "hex", orient: "up")),)

      let a2 = center(i + 1, j + 1)
      let down-center = mul(add(add(b, c), a2), 1 / 3)
      let down-id = "f-hex-" + str(i) + "-" + str(j) + "-down"
      let down-verts = poly-verts-local(down-center, 6, hex-angle)
      face-seeds += ((id: down-id, kind: "hex", color: "c0", center: down-center, vertices: down-verts, meta: (i: i, j: j, role: "hex", orient: "down")),)
    }
  }

  for seed in face-seeds {
    let face-qubits = ()
    let verts-world = ()
    for local in seed.vertices {
      let key = vertex-key(local)
      let qid = if key in qubit-by-key {
        qubit-by-key.at(key)
      } else {
        let new-id = "q-" + key
        qubit-by-key.insert(key, new-id)
        qubit-order.push(new-id)
        qubit-by-id.insert(new-id, (
          id: new-id,
          pos: map-point(local),
          "incident-faces": (),
          "boundary-tags": (),
          meta: (vertex-key: key),
        ))
        new-id
      }
      let current = qubit-by-id.at(qid)
      let incidents = append-unique(current.at("incident-faces"), seed.id)
      qubit-by-id.insert(qid, (
        id: current.id,
        pos: current.pos,
        "incident-faces": incidents,
        "boundary-tags": current.at("boundary-tags"),
        meta: current.meta,
      ))
      face-qubits = append-unique(face-qubits, qid)
      verts-world += (map-point(local),)
    }
    faces.push((
      id: seed.id,
      kind: seed.kind,
      color: seed.color,
      center: map-point(seed.center),
      vertices: verts-world,
      qubits: face-qubits,
      meta: (
        tiling: "4.6.12",
        shape: "rect",
        source: seed.meta,
      ),
    ))
  }

  let boundary-qubits = ()
  for qid in qubit-order {
    let qubit = qubit-by-id.at(qid)
    let degree = qubit.at("incident-faces").len()
    let tags = if degree < 3 { ("boundary",) } else { () }
    if tags.len() > 0 {
      boundary-qubits = append-unique(boundary-qubits, qid)
    }
    qubit-by-id.insert(qid, (
      id: qubit.id,
      pos: qubit.pos,
      "incident-faces": qubit.at("incident-faces"),
      "boundary-tags": tags,
      meta: (
        vertex-key: qubit.meta.vertex-key,
        degree: degree,
      ),
    ))
  }

  (
    faces: faces,
    qubits: qubit-order.map((qid) => qubit-by-id.at(qid)),
    boundaries: (
      qubits: boundary-qubits,
    ),
    basis: (
      origin: map-point((0, 0)),
      x: (
        map-point(v1).at(0) - map-point((0, 0)).at(0),
        map-point(v1).at(1) - map-point((0, 0)).at(1),
      ),
      y: (
        map-point(v2).at(0) - map-point((0, 0)).at(0),
        map-point(v2).at(1) - map-point((0, 0)).at(1),
      ),
      scale: scale,
      lattice: "4.6.12",
    ),
  )
}

#let color-code-488-canonical(
  loc,
  shape: "rect",
  size: none,
  orientation: "flat",
  scale: 1,
) = {
  assert(shape == "rect", message: "tiling \"4.8.8\" currently supports only shape \"rect\".")
  assert(type(size) == dictionary and size.rows != none and size.cols != none, message: "shape \"rect\" requires size: (rows: ..., cols: ...).")
  assert(orientation == "flat" or orientation == "pointy", message: "orientation must be \"flat\" or \"pointy\".")

  let x0 = loc.at(0)
  let y0 = loc.at(1)
  let s = scale
  let sqrt2 = calc.sqrt(2)
  let inv-sqrt2 = 1 / sqrt2
  let half = s / 2
  let apothem = s * (0.5 + inv-sqrt2)
  let append-unique = (items, value) => if value in items { items } else { items + (value,) }

  if orientation == "pointy" {
    let pitch = s * (1 + sqrt2)
    let basis-step = pitch / 2
    let diamond-radius = s * inv-sqrt2

    let map-point = (pt) => (
      x0 + pt.at(0),
      y0 + pt.at(1),
    )

    let oct-local-offsets = (
      (-half, -apothem),
      (half, -apothem),
      (apothem, -half),
      (apothem, half),
      (half, apothem),
      (-half, apothem),
      (-apothem, half),
      (-apothem, -half),
    )
    let square-local-offsets = (
      (0, -diamond-radius),
      (diamond-radius, 0),
      (0, diamond-radius),
      (-diamond-radius, 0),
    )

    let oct-key-offsets = (
      (-2, -4),
      (2, -4),
      (4, -2),
      (4, 2),
      (2, 4),
      (-2, 4),
      (-4, 2),
      (-4, -2),
    )
    let square-key-offsets = (
      (0, -2),
      (2, 0),
      (0, 2),
      (-2, 0),
    )

    let add-int = (a, b) => (a.at(0) + b.at(0), a.at(1) + b.at(1))

    let qubit-by-key = (:)
    let qubit-by-id = (:)
    let qubit-order = ()
    let faces = ()
    let face-seeds = ()

    for row in range(size.rows + 1) {
      for col in range(size.cols + 1) {
        let fq = 2 * col
        let fr = 2 * row
        let center-local = (col * pitch, row * pitch)
        face-seeds += ((
          fq: fq,
          fr: fr,
          center_local: center-local,
          local_offsets: square-local-offsets,
          key_offsets: square-key-offsets,
          kind: "square",
          color: "c2",
        ),)
      }
    }

    for row in range(size.rows) {
      for col in range(size.cols) {
        let fq = 2 * col + 1
        let fr = 2 * row + 1
        let center-local = ((col + 0.5) * pitch, (row + 0.5) * pitch)
        face-seeds += ((
          fq: fq,
          fr: fr,
          center_local: center-local,
          local_offsets: oct-local-offsets,
          key_offsets: oct-key-offsets,
          kind: "oct",
          color: if calc.rem(col + row, 2) == 0 { "c0" } else { "c1" },
        ),)
      }
    }

    for seed in face-seeds {
      let face-id = "f-" + str(seed.fq) + "-" + str(seed.fr)
      let key-origin = (4 * seed.fq, 4 * seed.fr)
      let face-qubits = ()
      let face-verts = ()
      for i in range(seed.local_offsets.len()) {
        let rel = seed.local_offsets.at(i)
        let local-pos = (seed.center_local.at(0) + rel.at(0), seed.center_local.at(1) + rel.at(1))
        let world-pos = map-point(local-pos)
        let key-vec = add-int(key-origin, seed.key_offsets.at(i))
        let vertex-key = str(key-vec.at(0)) + "-" + str(key-vec.at(1))

        let qid = if vertex-key in qubit-by-key {
          qubit-by-key.at(vertex-key)
        } else {
          let new-id = "q-" + vertex-key
          qubit-by-key.insert(vertex-key, new-id)
          qubit-order.push(new-id)
          qubit-by-id.insert(new-id, (
            id: new-id,
            pos: world-pos,
            "incident-faces": (),
            "boundary-tags": (),
            meta: (vertex-key: vertex-key),
          ))
          new-id
        }

        let current = qubit-by-id.at(qid)
        let incidents = append-unique(current.at("incident-faces"), face-id)
        qubit-by-id.insert(qid, (
          id: current.id,
          pos: current.pos,
          "incident-faces": incidents,
          "boundary-tags": current.at("boundary-tags"),
          meta: current.meta,
        ))
        face-qubits = append-unique(face-qubits, qid)
        face-verts += (qubit-by-id.at(qid).pos,)
      }

      faces.push((
        id: face-id,
        kind: seed.kind,
        color: seed.color,
        center: map-point(seed.center_local),
        vertices: face-verts,
        qubits: face-qubits,
        meta: (
          grid: (q: seed.fq, r: seed.fr),
          shape: "rect",
          tiling: "4.8.8",
          orientation: orientation,
        ),
      ))
    }

    let boundary-qubits = ()
    for qid in qubit-order {
      let qubit = qubit-by-id.at(qid)
      let degree = qubit.at("incident-faces").len()
      let tags = if degree < 3 { ("boundary",) } else { () }
      if tags.len() > 0 {
        boundary-qubits = append-unique(boundary-qubits, qid)
      }
      qubit-by-id.insert(qid, (
        id: qubit.id,
        pos: qubit.pos,
        "incident-faces": qubit.at("incident-faces"),
        "boundary-tags": tags,
        meta: (
          vertex-key: qubit.meta.vertex-key,
          degree: degree,
        ),
      ))
    }

    let qubits = qubit-order.map((qid) => qubit-by-id.at(qid))
    let has-diagonal-basis = size.cols >= 1 and size.rows >= 1
    let basis-origin-local = if has-diagonal-basis {
      ((size.cols - 1) * basis-step, 0)
    } else {
      (0, 0)
    }
    let basis-origin = map-point(basis-origin-local)
    let basis-x-point = if has-diagonal-basis {
      map-point((basis-origin-local.at(0) + basis-step, basis-step))
    } else {
      map-point((basis-step, basis-step))
    }
    let basis-y-point = if has-diagonal-basis {
      map-point((basis-origin-local.at(0) - basis-step, basis-step))
    } else {
      map-point((-basis-step, basis-step))
    }
    (
      faces: faces,
      qubits: qubits,
      boundaries: (
        qubits: boundary-qubits,
      ),
      basis: (
        origin: basis-origin,
        x: (
          basis-x-point.at(0) - basis-origin.at(0),
          basis-x-point.at(1) - basis-origin.at(1),
        ),
        y: (
          basis-y-point.at(0) - basis-origin.at(0),
          basis-y-point.at(1) - basis-origin.at(1),
        ),
        scale: scale,
        orientation: orientation,
        reading: "45deg",
        "center-step": basis-step,
      ),
    )
  } else {
    let step = apothem + half

    let map-point = (pt) => (
      x0 + pt.at(0),
      y0 + pt.at(1),
    )
    let quantize = (value) => calc.round(value * 1000000)
    let vertex-key = (pt) => str(quantize(pt.at(0) / s)) + "-" + str(quantize(pt.at(1) / s))

    let oct-local-offsets = (
      (-half, apothem),
      (half, apothem),
      (apothem, half),
      (apothem, -half),
      (half, -apothem),
      (-half, -apothem),
      (-apothem, -half),
      (-apothem, half),
    )
    let square-local-offsets = (
      (-half, half),
      (half, half),
      (half, -half),
      (-half, -half),
    )

    let qubit-by-key = (:)
    let qubit-by-id = (:)
    let qubit-order = ()
    let faces = ()
    let grid-rows = size.rows * 2 - 1
    let grid-cols = size.cols * 2 - 1

    for r in range(grid-rows) {
      for q in range(grid-cols) {
        let is-oct = calc.rem(q + r, 2) == 0
        let center-local = (q * step, r * step)
        let face-id = "f-" + str(q) + "-" + str(r)
        let face-qubits = ()
        let face-verts = ()
        let local-offsets = if is-oct { oct-local-offsets } else { square-local-offsets }

        for rel in local-offsets {
          let local-pos = (center-local.at(0) + rel.at(0), center-local.at(1) + rel.at(1))
          let world-pos = map-point(local-pos)
          let qkey = vertex-key(local-pos)

          let qid = if qkey in qubit-by-key {
            qubit-by-key.at(qkey)
          } else {
            let new-id = "q-" + qkey
            qubit-by-key.insert(qkey, new-id)
            qubit-order.push(new-id)
            qubit-by-id.insert(new-id, (
              id: new-id,
              pos: world-pos,
              "incident-faces": (),
              "boundary-tags": (),
              meta: (vertex-key: qkey),
            ))
            new-id
          }

          let current = qubit-by-id.at(qid)
          let incidents = append-unique(current.at("incident-faces"), face-id)
          qubit-by-id.insert(qid, (
            id: current.id,
            pos: current.pos,
            "incident-faces": incidents,
            "boundary-tags": current.at("boundary-tags"),
            meta: current.meta,
          ))
          face-qubits = append-unique(face-qubits, qid)
          face-verts += (qubit-by-id.at(qid).pos,)
        }

        faces.push((
          id: face-id,
          kind: if is-oct { "oct" } else { "square" },
          color: if is-oct {
            if calc.rem(q, 2) == 0 { "c0" } else { "c1" }
          } else {
            "c2"
          },
          center: map-point(center-local),
          vertices: face-verts,
          qubits: face-qubits,
          meta: (
            grid: (q: q, r: r),
            parity: calc.rem(q + r, 2),
            shape: "rect",
            tiling: "4.8.8",
            orientation: orientation,
          ),
        ))
      }
    }

    let boundary-qubits = ()
    for qid in qubit-order {
      let qubit = qubit-by-id.at(qid)
      let degree = qubit.at("incident-faces").len()
      let tags = if degree < 3 { ("boundary",) } else { () }
      if tags.len() > 0 {
        boundary-qubits = append-unique(boundary-qubits, qid)
      }
      qubit-by-id.insert(qid, (
        id: qubit.id,
        pos: qubit.pos,
        "incident-faces": qubit.at("incident-faces"),
        "boundary-tags": tags,
        meta: (
          vertex-key: qubit.meta.vertex-key,
          degree: degree,
        ),
      ))
    }

    let qubits = qubit-order.map((qid) => qubit-by-id.at(qid))
    (
      faces: faces,
      qubits: qubits,
      boundaries: (
        qubits: boundary-qubits,
      ),
      basis: (
        origin: map-point((0, 0)),
        x: (step, 0),
        y: (0, step),
        scale: scale,
        orientation: orientation,
        reading: "axis",
        "center-step": step,
      ),
    )
  }
}

#let color-code-2d(
  loc,
  tiling: "6.6.6",
  shape: "rect",
  size: none,
  orientation: "flat",
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
  let params = (
    loc: loc,
    tiling: tiling,
    shape: shape,
    size: size,
    orientation: orientation,
    scale: scale,
    color1: color1,
    color2: color2,
    color3: color3,
    name: name,
    stroke: stroke,
    show-stabilizers: show-stabilizers,
    stabilizer-offset: stabilizer-offset,
    show-qubits: show-qubits,
    qubit-radius: qubit-radius,
    qubit-color: qubit-color,
  )

  let canonical = if tiling == "6.6.6" {
    color-code-666-canonical(
      loc,
      shape: shape,
      size: size,
      orientation: orientation,
      scale: scale,
    )
  } else if tiling == "4.8.8" {
    color-code-488-canonical(
      loc,
      shape: shape,
      size: size,
      orientation: orientation,
      scale: scale,
    )
  } else if tiling == "4.6.12" {
    color-code-4612-canonical(
      loc,
      shape: shape,
      size: size,
      scale: scale,
    )
  } else {
    none
  }

  let faces = if canonical == none { () } else { canonical.faces }
  let qubits = if canonical == none { () } else { canonical.qubits }
  let boundaries = if canonical == none { () } else { canonical.boundaries }
  let basis = if canonical == none {
    (
      orientation: orientation,
      scale: scale,
    )
  } else {
    canonical.basis
  }

  let format-id = (id) => {
    if type(id) == array and id.len() > 0 {
      str(id.at(0)) + id.slice(1).fold("", (acc, part) => acc + "-" + str(part))
    } else {
      str(id)
    }
  }

  let normalize-face-id = (id) => {
    let id-text = format-id(id)
    if canonical != none and not id-text.starts-with("f-") {
      "f-" + id-text
    } else {
      id-text
    }
  }

  let normalize-qubit-id = (id) => {
    let id-text = format-id(id)
    if canonical != none and not id-text.starts-with("q-") {
      "q-" + id-text
    } else {
      id-text
    }
  }

  let face-name = (id) => name + "-face-" + normalize-face-id(id)
  let qubit-name = (id) => name + "-qubit-" + normalize-qubit-id(id)
  let face-anchor-name = (id) => name + "-face-anchor-" + normalize-face-id(id)
  let qubit-anchor-name = (id) => name + "-qubit-anchor-" + normalize-qubit-id(id)
  let face-anchor = (id) => (name: (face-anchor-name)(id), anchor: "center")
  let qubit-anchor = (id) => (name: (qubit-anchor-name)(id), anchor: "center")

  let pick-face-color = (face) => {
    if face.color == "c0" {
      color1
    } else if face.color == "c1" {
      color2
    } else {
      color3
    }
  }

  let resolve-face = (id) => {
    let target-id = normalize-face-id(id)
    let found = none
    for face in faces {
      if found == none and face.id == target-id {
        found = face
      }
    }
    found
  }

  let resolve-qubit = (id) => {
    let target-id = normalize-qubit-id(id)
    let found = none
    for qubit in qubits {
      if found == none and qubit.id == target-id {
        found = qubit
      }
    }
    found
  }

  let draw-background = () => {
    import draw: line, content, circle
    if canonical != none {
      let qubit-r = qubit-radius * scale
      for face in faces {
        line(..face.vertices, close: true, fill: pick-face-color(face), stroke: stroke, name: (face-name)(face.id))
        circle(face.center, radius: 0, fill: none, stroke: none, name: (face-anchor-name)(face.id))
        if show-stabilizers {
          content((face.center.at(0), face.center.at(1) + stabilizer-offset * scale), [X])
          content((face.center.at(0), face.center.at(1) - stabilizer-offset * scale), [Z])
        }
      }
      for qubit in qubits {
        circle(qubit.pos, radius: 0, fill: none, stroke: none, name: (qubit-anchor-name)(qubit.id))
        if show-qubits {
          circle(qubit.pos, radius: qubit-r, fill: qubit-color, stroke: none, name: (qubit-name)(qubit.id))
        }
      }
    } else {
      color-code-2d-render(
        loc,
        tiling: tiling,
        shape: shape,
        size: size,
        orientation: orientation,
        scale: scale,
        color1: color1,
        color2: color2,
        color3: color3,
        name: name,
        stroke: stroke,
        show-stabilizers: show-stabilizers,
        stabilizer-offset: stabilizer-offset,
        show-qubits: show-qubits,
        qubit-radius: qubit-radius,
        qubit-color: qubit-color,
      )
    }
  }

  let highlight-face = (id, radius: none, fill: none, stroke: (paint: red, thickness: 1pt)) => {
    import draw: line, circle
    if canonical != none {
      let face = (resolve-face)(id)
      assert(face != none, message: "Unknown face id \"" + normalize-face-id(id) + "\".")
      line(..face.vertices, close: true, fill: fill, stroke: stroke)
      if radius != none {
        circle(face.center, radius: radius, fill: none, stroke: stroke)
      }
    } else {
      circle((face-anchor)(id), radius: if radius == none { scale * 0.42 } else { radius }, fill: fill, stroke: stroke)
    }
  }

  let highlight-qubit = (id, radius: none, fill: none, stroke: (paint: red, thickness: 1pt)) => {
    import draw: circle
    if canonical != none {
      let qubit = (resolve-qubit)(id)
      assert(qubit != none, message: "Unknown qubit id \"" + normalize-qubit-id(id) + "\".")
      circle(qubit.pos, radius: if radius == none { scale * 0.2 } else { radius }, fill: fill, stroke: stroke)
    } else {
      circle((qubit-anchor)(id), radius: if radius == none { scale * 0.2 } else { radius }, fill: fill, stroke: stroke)
    }
  }

  (
    tiling: tiling,
    shape: shape,
    params: params,
    faces: faces,
    qubits: qubits,
    boundaries: boundaries,
    basis: basis,
    face-anchor: face-anchor,
    qubit-anchor: qubit-anchor,
    draw-background: draw-background,
    highlight-face: highlight-face,
    highlight-qubit: highlight-qubit,
  )
}

#let stabilizer-label(loc, size:1, color1:yellow, color2:aqua) = {
  import draw: *
  let x = loc.at(0)
  let y = loc.at(1)
  content((x, y), box(stroke: black, inset: 10pt, [$X$ stabilizers],fill: color2, radius: 4pt))
  content((x, y - 1.5*size), box(stroke: black, inset: 10pt, [$Z$ stabilizers],fill: color1, radius: 4pt))
}

#let toric-code(loc, m, n, size:1,circle-radius:0.2,color1:white,color2:gray,line-thickness:1pt,name: "toric") = {
  let params = (
    loc: loc,
    m: m,
    n: n,
    size: size,
    circle-radius: circle-radius,
    color1: color1,
    color2: color2,
    line-thickness: line-thickness,
    name: name,
  )

  let mod-index = (value, modulus) => {
    let wrapped = calc.rem(value, modulus)
    if wrapped < 0 { wrapped + modulus } else { wrapped }
  }

  let normalize-qubit-id = (id) => {
    if type(id) == array {
      assert(id.len() == 3, message: "Toric qubit id must be (\"vertical\"|\"horizontal\", i, j).")
      let family = str(id.at(0))
      assert(family == "vertical" or family == "horizontal", message: "Unknown toric qubit family \"" + family + "\".")
      family + "-" + str((mod-index)(id.at(1), m)) + "-" + str((mod-index)(id.at(2), n))
    } else {
      str(id)
    }
  }

  let normalize-plaquette-id = (id) => {
    if type(id) == array {
      if id.len() == 2 {
        "plaquette-" + str((mod-index)(id.at(0), m)) + "-" + str((mod-index)(id.at(1), n))
      } else {
        assert(id.len() == 3, message: "Toric plaquette id must be (i, j) or (\"plaquette\", i, j).")
        let family = str(id.at(0))
        assert(family == "plaquette", message: "Unknown toric plaquette family \"" + family + "\".")
        "plaquette-" + str((mod-index)(id.at(1), m)) + "-" + str((mod-index)(id.at(2), n))
      }
    } else {
      let id-text = str(id)
      if id-text.starts-with("plaquette-") {
        id-text
      } else {
        "plaquette-" + id-text
      }
    }
  }

  let normalize-vertex-id = (id) => {
    if type(id) == array {
      if id.len() == 2 {
        "vertex-" + str((mod-index)(id.at(0), m)) + "-" + str((mod-index)(id.at(1), n))
      } else {
        assert(id.len() == 3, message: "Toric vertex id must be (i, j) or (\"vertex\", i, j).")
        let family = str(id.at(0))
        assert(family == "vertex", message: "Unknown toric vertex family \"" + family + "\".")
        "vertex-" + str((mod-index)(id.at(1), m)) + "-" + str((mod-index)(id.at(2), n))
      }
    } else {
      let id-text = str(id)
      if id-text.starts-with("vertex-") {
        id-text
      } else {
        "vertex-" + id-text
      }
    }
  }

  let qubit-name = (id) => name + "-point-" + normalize-qubit-id(id)
  let plaquette-anchor-name = (id) => name + "-plaquette-anchor-" + normalize-plaquette-id(id)
  let vertex-anchor-name = (id) => name + "-vertex-anchor-" + normalize-vertex-id(id)
  let qubit-anchor = (id) => (name: (qubit-name)(id), anchor: "center")
  let plaquette-anchor = (id) => (name: (plaquette-anchor-name)(id), anchor: "center")
  let vertex-anchor = (id) => (name: (vertex-anchor-name)(id), anchor: "center")

  let qubits = ()
  for i in range(m) {
    for j in range(n) {
      let x = loc.at(0) + i * size
      let y = loc.at(1) - j * size
      qubits += (
        (
          id: ("vertical", i, j),
          pos: (x + size / 2, y),
          color: color1,
          name: (qubit-name)(("vertical", i, j)),
        ),
      )
      qubits += (
        (
          id: ("horizontal", i, j),
          pos: (x, y - size / 2),
          color: color2,
          name: (qubit-name)(("horizontal", i, j)),
        ),
      )
    }
  }

  let plaquettes = ()
  for i in range(m) {
    for j in range(n) {
      let x = loc.at(0) + i * size
      let y = loc.at(1) - j * size
      plaquettes += (
        (
          id: ("plaquette", i, j),
          center: (x + size / 2, y - size / 2),
          vertices: ((x, y), (x + size, y), (x + size, y - size), (x, y - size)),
          qubits: (
            ("vertical", i, j),
            ("vertical", i, j + 1),
            ("horizontal", i + 1, j),
            ("horizontal", i, j),
          ),
          meta: (i: i, j: j),
        ),
      )
    }
  }

  let vertices = ()
  for i in range(m) {
    for j in range(n) {
      let x = loc.at(0) + i * size
      let y = loc.at(1) - j * size
      vertices += (
        (
          id: ("vertex", i, j),
          center: (x, y),
          qubits: (
            ("vertical", i - 1, j),
            ("vertical", i, j),
            ("horizontal", i, j),
            ("horizontal", i, j - 1),
          ),
          meta: (i: i, j: j),
        ),
      )
    }
  }

  let resolve-qubit = (id) => {
    let target-id = normalize-qubit-id(id)
    let found = none
    for qubit in qubits {
      if found == none and normalize-qubit-id(qubit.id) == target-id {
        found = qubit
      }
    }
    found
  }

  let resolve-plaquette = (id) => {
    let target-id = normalize-plaquette-id(id)
    let found = none
    for plaquette in plaquettes {
      if found == none and normalize-plaquette-id(plaquette.id) == target-id {
        found = plaquette
      }
    }
    found
  }

  let resolve-vertex = (id) => {
    let target-id = normalize-vertex-id(id)
    let found = none
    for vertex in vertices {
      if found == none and normalize-vertex-id(vertex.id) == target-id {
        found = vertex
      }
    }
    found
  }

  let draw-background = () => {
    import draw: rect, circle
    for plaquette in plaquettes {
      rect(
        plaquette.vertices.at(0),
        plaquette.vertices.at(2),
        fill: color1,
        stroke: black,
        name: name + "-square" + "-" + str(plaquette.meta.i) + "-" + str(plaquette.meta.j),
      )
      circle(plaquette.center, radius: 0, fill: none, stroke: none, name: (plaquette-anchor-name)(plaquette.id))
    }
    for vertex in vertices {
      circle(vertex.center, radius: 0, fill: none, stroke: none, name: (vertex-anchor-name)(vertex.id))
    }
    for qubit in qubits {
      circle(qubit.pos, radius: circle-radius, fill: qubit.color, stroke: (thickness: line-thickness), name: qubit.name)
    }
  }

  let highlight-qubit = (id, radius: none, fill: none, stroke: (paint: red, thickness: 1pt)) => {
    import draw: circle
    let qubit = (resolve-qubit)(id)
    assert(qubit != none, message: "Unknown toric qubit id \"" + normalize-qubit-id(id) + "\".")
    circle(qubit.pos, radius: if radius == none { circle-radius } else { radius }, fill: fill, stroke: stroke)
  }

  let highlight-plaquette = (
    id,
    fill: yellow,
    stroke: black,
    qubit-fill: yellow,
    qubit-stroke: (thickness: line-thickness),
    qubit-radius: circle-radius,
    selected-qubits: none,
  ) => {
    import draw: line, circle
    let plaquette = (resolve-plaquette)(id)
    assert(plaquette != none, message: "Unknown toric plaquette id \"" + normalize-plaquette-id(id) + "\".")
    line(..plaquette.vertices, close: true, fill: fill, stroke: stroke)
    if selected-qubits != none {
      for qid in plaquette.qubits {
        let qubit = (resolve-qubit)(qid)
        assert(qubit != none, message: "Unknown toric qubit id \"" + normalize-qubit-id(qid) + "\".")
        circle(qubit.pos, radius: qubit-radius, fill: qubit.color, stroke: (thickness: line-thickness))
      }
    }
    let qubit-ids = if selected-qubits == none { plaquette.qubits } else { selected-qubits }
    for qid in qubit-ids {
      let qubit = (resolve-qubit)(qid)
      assert(qubit != none, message: "Unknown toric qubit id \"" + normalize-qubit-id(qid) + "\".")
      circle(qubit.pos, radius: qubit-radius, fill: qubit-fill, stroke: qubit-stroke)
    }
  }

  let highlight-vertex = (
    id,
    fill: aqua,
    stroke: black,
    marker-radius: circle-radius,
    qubit-fill: aqua,
    qubit-stroke: (thickness: line-thickness),
    qubit-radius: circle-radius,
    selected-qubits: none,
  ) => {
    import draw: rect, circle
    let vertex = (resolve-vertex)(id)
    assert(vertex != none, message: "Unknown toric vertex id \"" + normalize-vertex-id(id) + "\".")
    rect(
      (vertex.center.at(0) - marker-radius, vertex.center.at(1) - marker-radius),
      (vertex.center.at(0) + marker-radius, vertex.center.at(1) + marker-radius),
      fill: fill,
      stroke: stroke,
    )
    let qubit-ids = if selected-qubits == none { vertex.qubits } else { selected-qubits }
    for qid in qubit-ids {
      let qubit = (resolve-qubit)(qid)
      assert(qubit != none, message: "Unknown toric qubit id \"" + normalize-qubit-id(qid) + "\".")
      circle(qubit.pos, radius: qubit-radius, fill: qubit-fill, stroke: qubit-stroke)
    }
  }

  (
    params: params,
    qubits: qubits,
    plaquettes: plaquettes,
    vertices: vertices,
    draw-background: draw-background,
    qubit-anchor: qubit-anchor,
    plaquette-anchor: plaquette-anchor,
    vertex-anchor: vertex-anchor,
    highlight-qubit: highlight-qubit,
    highlight-plaquette: highlight-plaquette,
    highlight-vertex: highlight-vertex,
  )
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
