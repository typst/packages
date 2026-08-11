// README header banner
#import "@preview/blockst:0.2.1": blockst, scratch, set-blockst

#set page(width: auto, height: auto, margin: 0pt, fill: none)
#set text(font: "Helvetica Neue", fallback: true)

#v(-4em)

#block(inset: (x: 10mm, top: 9mm, bottom: 10mm))[
  #set-blockst(scale: 78%)

  #move(dy: 4em, text(40pt)[
    *_blockst_*
  ])
  #grid(
    columns: 4,
    column-gutter: 5mm,
    align: bottom,
    scratch("
when green flag clicked
move (10) steps
turn cw (15) degrees
say [Hello!]
"),
    scratch("
when [space v] key pressed
forever
  move (5) steps
  turn cw (3) degrees
end
"),
    scratch("
when I receive [start v]
set [score v] to (0)
if <touching [edge v]?> then
  turn cw (180) degrees
else
  change [score v] by (1)
end
"),
    [#scratch("
define jump (h) px
change y by (var [h]
")
      #scratch("call jump (50) px")
    ],
  )
]
