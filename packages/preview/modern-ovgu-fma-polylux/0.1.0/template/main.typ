#import "@preview/modern-ovgu-fma-polylux:0.1.0" : *
//#import "../modern-ovgu-fma-polylux.typ" : *

#show: ovgu-fma-theme.with(
  author: [Vorname Nachname],
  title: [Titel der Präsentation],
  affilation: [affilation],
  date: ez-today.today(),
  text-lang: "de",
)

#show: document => conf-equations(document)

#title-slide(
  subtitle: [Hier könnte ihr Subtitel stehen]
)

#outline-slide()[]

#header-slide()[
  Verwenden mathematischer Umgebungen
]

#folie()[
  == Verwendung von Gleichungen
  Wir können Gleichungen definieren:
    $ a/b = c/d $
  Diese werden nummeriert, wenn sie mit einem Label markiert werden.
    $ a^2 + b^2 = c^2 $ <pythagoras>
  Entsprechend seht ihr, dass @pythagoras Pythagoras ist. Ein Beweis findet sich in @gerwig2021satz.
]

#header-slide()[Beispiele für den Inhalt]

#folie(
  heading: [Multi-Column-Folien]
)[
  #toolbox.side-by-side()[#lorem(39)][#lorem(30)][#lorem(35)]
]

#set footnote.entry(clearance: 0.25em)
#folie()[
  
  #figure(
    caption: [Beispielgrafik#footnote([Erstellt von Malte])]
  )[#image("example-image.jpg",height: 80%)]
]

#header-slide()[nützliche Features]

#folie()[
  Keine Idee wie man dieses mathematische Symbol in Typst schreibt?
  
  #align(center)[
    #block(
      stroke: 2.5pt + fma,
      fill: fma-lighter,
      radius: 0.5em,
      inset: 0.5em, 
    )[
      #set text(fill: rgb(0, 0, 255, 255))
      #set align(center+horizon)
      #link("https://detypify.quarticcat.com/")
    ]
  ]
  
  #show: later

  Welche Funktionen bietet eigentlich Polylux noch?
  #align(center)[
    #block(
      stroke: 2.5pt + fma,
      fill: fma-lighter,
      radius: 0.5em,
      inset: 0.5em, 
    )[
      #set text(fill: rgb(0, 0, 255, 255))
      #set align(center+horizon)
      #link("https://polylux.dev/book/getting-started/getting-started.html")
    ]
  ]
  
  #show: later

  Wie erstelle ich aus meiner Präsentation ein Handout? ("Animationen" ausschalten)
  #align(center)[
    #block(
      stroke: 2.5pt + fma,
      fill: fma-lighter,
      radius: 0.5em,
      inset: 0.5em, 
    )[
      #set text(fill: rgb(0, 0, 255, 255))
      #set align(center+horizon)
      Setze an den Anfang deines Codes den Befehl: 
      ```typ 
        #enable-handout-mode(true)
      ```
    ]
  ]
]

#folie(
  heading: ["Animationen"]
)[
  Ist es dir aufgefallen? Auf der vorherigen Folie haben wir die Items mit
  #align(center)[
    #block(
      stroke: 2.5pt + fma,
      fill: fma-lighter,
      radius: 0.5em,
      inset: 0.5em, 
    )[
      #set text(fill: rgb(0, 0, 255, 255))
      #set align(center+horizon)
      ```typ
        #show: later  
      ```
    ]
  ]

  nacheinander erscheinen lassen. Es gibt viele weitere alternative Hilfsfunktionen. Details könnt ihr hier:
  #align(center)[
    #block(
      stroke: 2.5pt + fma,
      fill: fma-lighter,
      radius: 0.5em,
      inset: 0.5em, 
    )[
      #set text(fill: rgb(0, 0, 255, 255))
      #set align(center+horizon)
      #link("https://polylux.dev/book/dynamic/helper.html")
    ]
  ]
  nachlesen.
]

#header-slide()[Bibliographie]

#slide-base(
  show-section: false,
)[
  #bibliography(
    "example.bib",
    style: "institute-of-electrical-and-electronics-engineers",
  )
]