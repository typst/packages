#import "/lib.typ": prototypes, crystal
#set page(width: auto, height: auto, margin: 0.4cm)
// Explicit bond rule: the auto rule (1.15 x covalent-radii sum) would also
// draw Mo-Mo contacts at a = 3.16 Angstrom; restrict bonds to Mo-S.
#crystal(
  prototypes.tmd("Mo", "S", a: 3.16, z: 1.56),
  view: (azimuth: 20deg, elevation: 35deg),
  bonds: ((elements: ("Mo", "S"), max: 2.6),),
  colors: (Mo: rgb("#4477aa"), S: rgb("#cc8963")),
  supercell: (4, 4, 1),
  width: 10cm,
)
