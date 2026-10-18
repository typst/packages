// Example 1 – German blocks
#import "@preview/blockst:0.1.0": blockst, scratch

#set page(width: auto, height: auto, margin: 3mm, fill: white)

#blockst[
  #import scratch.de: *

  #wenn-gruene-flagge-geklickt[
    #setze-variable("Punkte", 0)
    #wiederhole(anzahl: 5)[
      #gehe(schritte: 10)
      #falls-sonst(
        wird-beruehrt("Rand"),
        drehe-rechts(grad: 180),
        aendere-variable("Punkte", 1),
      )
    ]
    #sage-fuer-sekunden(eigene-eingabe("Punkte"), sekunden: 2)
  ]
]
