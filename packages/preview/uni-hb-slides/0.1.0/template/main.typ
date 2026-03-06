#import "@preview/polylux:0.4.0": *
#import "@preview/uni-hb-slides:0.1.0": *

#show: theme.with(
  title: "Titel der Präsentation",
  author: "Vorname Nachname",
  date: datetime.today()
)

#slide[
  #set align(horizon)
  #text(size: 48pt, weight: "bold", "Titel der Präsentation")

  #text(size: 24pt, "Untertitel der Präsentation")
]

#slide[
  #outline(depth: 1, title: "Agenda", )
]

#slide[
  = Überschrift
  Fließtext. Wahrscheinlich sitzen Sie gerade in einer Präsentation und lesen sich diesen Text hier durch. Dabei stellen Sie langsam aber sicher fest, dass dies eigentlich nur ein Blindtext ist und mit Ihrem Produkt überhaupt nichts zu tun hat. Sie fühlen sich ertappt, lesen aber trotzdem unauffällig weiter. 
  
  #important[Eine farbige Hervorhebung]
]

#slide[
  #toolbox.side-by-side()[
    == Überschrift und Bild
    Fließtext. Wahrscheinlich sitzen Sie gerade in einer Präsentation und lesen sich diesen Text hier durch. Dabei stellen Sie langsam aber sicher fest, dass dies eigentlich nur ein Blindtext ist. 

    === Eine Zwischenüberschrift
    Wie Sie wissen, hat ein Blindtext eigentlich nur zwei Funktionen.
  ][
    #figure(
      emoji.camera,
      caption: [Ein Bild mit einem Untertitel]
    )
  ]
]
