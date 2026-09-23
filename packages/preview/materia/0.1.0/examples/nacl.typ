#import "/lib.typ": prototypes, crystal
#set page(width: auto, height: auto, margin: 0.4cm)
#crystal(
  prototypes.rocksalt("Na", "Cl", a: 5.64),
  colors: (Na: rgb("#4477aa"), Cl: rgb("#cc8963")),
  width: 8cm,
)
