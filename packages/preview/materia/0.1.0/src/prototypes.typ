// Named structure prototypes. Wyckoff letters follow data/*.json (pyxtal, standard settings).
#import "core/structure.typ": structure

/// Simple-cubic elemental structure.
#let sc(el, a: none) = structure(spacegroup: 221, lattice: (a: a),
  sites: ((element: el, wyckoff: "a"),))
/// Face-centred-cubic elemental structure.
#let fcc(el, a: none) = structure(spacegroup: 225, lattice: (a: a),
  sites: ((element: el, wyckoff: "a"),))
/// Body-centred-cubic elemental structure.
#let bcc(el, a: none) = structure(spacegroup: 229, lattice: (a: a),
  sites: ((element: el, wyckoff: "a"),))
// hcp: 2-fold site c at (1/3, 2/3, 1/4) in SG 194.
/// Hexagonal-close-packed elemental structure.
#let hcp(el, a: none, c: none) = structure(spacegroup: 194, lattice: (a: a, c: c),
  sites: ((element: el, wyckoff: "c"),))
/// Diamond-cubic elemental structure.
#let diamond(el, a: none) = structure(spacegroup: 227, lattice: (a: a),
  sites: ((element: el, wyckoff: "a"),))
/// Rocksalt binary structure.
#let rocksalt(A, B, a: none) = structure(spacegroup: 225, lattice: (a: a),
  sites: ((element: A, wyckoff: "a"), (element: B, wyckoff: "b")))
/// Caesium-chloride binary structure.
#let cesium-chloride(A, B, a: none) = structure(spacegroup: 221, lattice: (a: a),
  sites: ((element: A, wyckoff: "a"), (element: B, wyckoff: "b")))
/// Zincblende binary structure.
#let zincblende(A, B, a: none) = structure(spacegroup: 216, lattice: (a: a),
  sites: ((element: A, wyckoff: "a"), (element: B, wyckoff: "c")))
/// Wurtzite binary structure.
#let wurtzite(A, B, a: none, c: none, u: 0.375) = structure(spacegroup: 186, lattice: (a: a, c: c),
  sites: ((element: A, wyckoff: "b", z: 0.0), (element: B, wyckoff: "b", z: u)))
/// Fluorite binary structure.
#let fluorite(A, B, a: none) = structure(spacegroup: 225, lattice: (a: a),
  sites: ((element: A, wyckoff: "a"), (element: B, wyckoff: "c")))
/// Rutile binary structure.
#let rutile(A, B, a: none, c: none, x: 0.305) = structure(spacegroup: 136, lattice: (a: a, c: c),
  sites: ((element: A, wyckoff: "a"), (element: B, wyckoff: "f", x: x)))
/// Cubic perovskite structure.
#let perovskite(A, B, X, a: none) = structure(spacegroup: 221, lattice: (a: a),
  sites: ((element: A, wyckoff: "a"), (element: B, wyckoff: "b"), (element: X, wyckoff: "c")))
// graphene: 2-fold site b at (1/3, 2/3, 0) in LG 80.
/// Graphene monolayer.
#let graphene(el: "C", a: 2.46) = structure(layergroup: 80, lattice: (a: a),
  sites: ((element: el, wyckoff: "b"),))
// hBN: two 1-fold sites b (1/3, 2/3, 0) and c (2/3, 1/3, 0) in LG 78.
/// Hexagonal boron-nitride monolayer.
#let hexagonal-bn(a: 2.50) = structure(layergroup: 78, lattice: (a: a),
  sites: ((element: "B", wyckoff: "b"), (element: "N", wyckoff: "c")))
// TMD: metal on 1-fold site b (1/3, 2/3, 0); chalcogen on 2-fold site f (2/3, 1/3, z) in LG 78.
/// 1H transition-metal dichalcogenide monolayer.
#let tmd(M, X, a: none, z: none) = structure(layergroup: 78, lattice: (a: a),
  sites: ((element: M, wyckoff: "b"), (element: X, wyckoff: "f", z: z)))
