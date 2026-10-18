#import "./preamble.typ": *

#show: bmim.lecture(
  lang: "de",
  course: ("Vorlesung", "VL"),
  authors: ("John Doe", "Jane Doe", "Max Mustermann"),
  date: datetime(day: 1, month: 3, year: 2024),
)

// various environments
#import "@preview/theorion:0.6.0": *
#import cosmos.clouds: *
#show: show-theorion

= Ein Kapitel

#lorem(100)

== Ein Abschnitt

=== Ein Unterabschnitt

#lorem(50)

==== Ein Untertunterabschnitt

#lorem(50)

===== Ein Absatz
#lorem(100)

===== Ein anderer Absatz
#lorem(150)

==== Noch ein Untertunterabschnitt

#lorem(150)

=== Noch ein Unterabschnitt

#lorem(50)

== Noch ein Abschnitt

#lorem(150)

= Strukturen

== Auflistungen

+ #lorem(40)
+ #lorem(40)
+ #lorem(40)

- #lorem(30)
- #lorem(30)
- #lorem(30)

== Umgebungen

Für alle Umgebungen wird das `theorion` Paket (https://typst.app/universe/package/theorion/) genutzt.

#definition[
  Eine wichtige Definition.
]

#theorem[
  #lorem(50)
]

#proof[
  #lorem(50)
]

#example[
  #lorem(150)
]


= Jetzt was neues

#lorem(250)@netwok2020
#lorem(250)
#lorem(250)

== Erstmal Grundlagen

#lorem(500)

#lorem(500)

#lorem(500)

= Jetzt was anderes neues

#lorem(400)

#lorem(400)

== Keine Grundlagen

#lorem(250)

#lorem(250)

#lorem(250)

== Doch Grundlagen

#lorem(250)

#lorem(250)

#show: backmatter

= Details

#lorem(100)


== Mehr Details

Wir haben den Beweis:
#proof[
  #lorem(150)
]

#lorem(100)

== Andere Details

#lorem(500)

= Das ließt niemand mehr


#bibliography("sources.bib", title: "Literatur")
