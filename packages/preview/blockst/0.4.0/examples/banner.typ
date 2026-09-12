// README banner: the logo, the name, and the four block languages side by
// side. Rendered to blockst-banner.svg (a new file name whenever the picture
// changes, GitHub caches the old one otherwise).
#import "@preview/blockst:0.4.0": blockst, scratch, blockly, makecode, nepo, set-blockst

#set page(width: auto, height: auto, margin: 0pt, fill: none)
#set text(font: "Helvetica Neue", fallback: true)

#block(inset: (x: 10mm, top: 6mm, bottom: 8mm))[
  #set-blockst(scale: 78%)

  #grid(columns: 2, column-gutter: 4mm, align: horizon,
    image("logo.svg", height: 11mm),
    text(40pt)[*_blockst_*],
  )
  #v(1mm)
  #let caption(body) = text(9pt, fill: luma(110), tracking: 0.08em, upper(body))
  #grid(
    columns: 4,
    column-gutter: 7mm,
    row-gutter: 2.5mm,
    align: left + top,
    scratch("
when green flag clicked
repeat (4)
  move (10) steps
  if <touching [edge v]?> then
    turn cw (90) degrees
  end
end
"),
    blockly("
Roboter-Programm
wiederhole (4) mal:
  gehe nach rechts
  falls <auf Kiste>
    hebe Murmel auf ::aktionen
  ende
ende
", profile: "jwinf"),
    makecode("
wenn Knopf [A v] geklickt
  zeige Symbol [Herz v]
  wenn <(Lichtstärke) > (100)> dann
    zeige Zahl (zähler)
  ende
ende
"),
    nepo("
Start
  Zeige Text \"Hallo\"
  Wiederhole unendlich oft
    Schalte RGB LED an (#ff0000)
  Ende
", scale: 100%),
    caption[Scratch], caption[Blockly · jwinf], caption[MakeCode · micro:bit], caption[NEPO · Open Roberta],
  )
]
