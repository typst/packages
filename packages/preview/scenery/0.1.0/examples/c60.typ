// C60 fullerene as an exact truncated icosahedron, constructed entirely in
// Typst. The topology assertions make this example a geometry regression test.
#import "/lib.typ": sphere, seg, build-scene, camera, render-scene
#import "/lib.typ": vsub, vlen, lerp

#set page(width: auto, height: auto, margin: 0.45cm)
#set text(font: "New Computer Modern", size: 9pt)

#let phi = (1 + calc.sqrt(5)) / 2
#let signs = (-1.0, 1.0)

// Twelve vertices of a regular icosahedron with edge length 2.
#let ico = ()
#for a in signs {
  for b in signs {
    ico.push((0.0, a, b * phi))
    ico.push((a, b * phi, 0.0))
    ico.push((b * phi, 0.0, a))
  }
}
#assert(ico.len() == 12)

// Its 30 edges are exactly the vertex pairs at distance 2.
#let ico-edges = ()
#for i in range(ico.len()) {
  for j in range(i + 1, ico.len()) {
    if calc.abs(vlen(vsub(ico.at(i), ico.at(j))) - 2) < 1e-10 {
      ico-edges.push((i, j))
    }
  }
}
#assert(ico-edges.len() == 30, message: "icosahedron must have 30 edges")

// Truncate each oriented edge one third of the way from either endpoint. Every
// original edge contributes two carbon sites, giving the 60 C60 vertices.
#let carbons = ()
#for e in ico-edges {
  let u = ico.at(e.at(0))
  let v = ico.at(e.at(1))
  carbons.push(lerp(u, v, 1 / 3))
  carbons.push(lerp(u, v, 2 / 3))
}
#assert(carbons.len() == 60, message: "C60 must have 60 carbon sites")
#for i in range(carbons.len()) {
  for j in range(i + 1, carbons.len()) {
    assert(vlen(vsub(carbons.at(i), carbons.at(j))) > 1e-9,
      message: "truncation produced duplicate carbon sites")
  }
}

// Every edge of the truncated solid has length 2/3. Nearest-neighbour search
// therefore recovers all 90 C-C bonds without a hard-coded connectivity table.
#let bond-length = 2 / 3
#let bonds = ()
#for i in range(carbons.len()) {
  for j in range(i + 1, carbons.len()) {
    let d = vlen(vsub(carbons.at(i), carbons.at(j)))
    if calc.abs(d - bond-length) < 1e-9 { bonds.push((i, j)) }
  }
}
#assert(bonds.len() == 90, message: "C60 must have 90 C-C bonds")
#let degrees = range(carbons.len()).map(i =>
  bonds.filter(e => i == e.at(0) or i == e.at(1)).len()
)
#assert(degrees.all(d => d == 3), message: "every C60 carbon must have degree 3")
#assert(bonds.all(e =>
  calc.abs(vlen(vsub(carbons.at(e.at(0)), carbons.at(e.at(1)))) - bond-length) < 1e-9
), message: "C60 bonds must share one length")

#let atom-color = rgb("#526979")
#let bond-color = rgb("#777d82")
#let prims = ()
#for e in bonds {
  prims.push(seg(
    carbons.at(e.at(0)), carbons.at(e.at(1)),
    color: bond-color, w: 0.055,
  ))
}
#for p in carbons {
  prims.push(sphere(p, 0.14, color: atom-color))
}

#align(center)[
  #render-scene(
    build-scene(..prims),
    // Threefold view: looks down an icosahedral face, exposing a central
    // fullerene hexagon and the surrounding pentagonal regions.
    camera(azimuth: -45deg, elevation: 35.26439deg),
    width: 8.2cm,
  )
  #v(0.2em)
  #text(size: 9pt, fill: luma(65))[Idealized $C_60$ fullerene --- 60 carbon atoms, 90 bonds]
]
