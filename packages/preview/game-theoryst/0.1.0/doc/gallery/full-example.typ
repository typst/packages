#import "../../src/lib.typ": *
#set page(
  width: auto, 
  height: auto,
  margin: 0.25em
)

#nfg(
  players: ([A\ Joe], [Bas Pro]),
  s1: ([$x$], [a]),
  s2: ("x", "aaaa", [$a$]),
  pad: ("x": 12pt, "y": 10pt),
  eliminations: ("s11", "s21", "s22"),
  ejust: (
    s11: (x: (0pt, 36pt), y: (-3pt, -3.5pt)),
    s22: (x: (-10pt, -12pt), y: (-10pt, 10pt)),
    s21: (x: (-3pt, -9pt), y: (-10pt, 10pt)),
  ),
  mixings: (hmix: ($p$, $1-p$), vmix: ($q$, $r$, $1-q-r$)),
  custom-fills: (hp: maroon, vp: navy, hm: purple, vm: fuchsia, he: gray, ve: gray),
  [$0,vul(100000000)$], [$0,1$], [$0,0$],
  [$hul(1),1$], [$0, -1$], table.cell(fill: yellow.lighten(30%), [$hful(0),vful(0)$])
)