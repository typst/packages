#import "../../src/lib.typ": *
#set page(
  width: auto, 
  height: auto,
  margin: 0.25em
)

#let just-arr = (
    "s12": (x: (0pt, 10pt), y: (-3pt, -3pt)),
    "s13": (x: (0pt, 10pt), y: (-3pt, -3pt)),
    "s14": (x: (0pt, 10pt), y: (-3pt, -3pt)),
    "s21": (x: (-6pt, -8pt), y: (3pt, 8pt)),
    "s22": (x: (-4pt, -8pt), y: (3pt, 8pt)),
    "s23": (x: (-4pt, -8pt), y: (3pt, 8pt)),
)

#nfg(
  players: ("A", "B"),
  s1: ([$N$], [$S$], [$E$], [$W$] ),
  s2: ([$W$], [$E$], [$F$], [$A$]),
  eliminations: ("s12", "s13", "s14", "s21", "s22", "s23"),
  ejust: just-arr,
  [$6,4$], [$7,3$], [$5,5$], [$6,6$],
  [$7,3$], [$2,7$], [$4,6$], [$5,5$],
  [$8,2$], [$6,4$], [$3,7$], [$2,8$],
  [$3,7$], [$5,5$], [$4,6$], [$5,5$],
)