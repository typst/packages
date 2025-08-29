#import "@preview/marina-uol-thesis:1.0.0" as thesis

#show: thesis.thesis.with(
  title: "Space Ranger or Martian? Cultural Differences Across Extraterrestrial Colonies",
  name: "Juno Teo Minh",
  studentid: "JUN20082024",
  degree: "MSc",
  programme: "Cultural Studies",
  school: "School of Journalism",
  supervisor: "Dr Winston S. Paceape",
  header-text: "Masters Thesis",
  date: 2024,
  // bib: bibliography("references.yml")
)

#thesis.acknowledgements()[
  #lorem(200)
]

#thesis.abstract()[
  #lorem(200)
]

= Introduction
#lorem(100)
== Aims
#lorem(100)
== Background
#lorem(100)

= Lucheng Interstellar
== Project Red Promise
#lorem(100)

#thesis.appendix()[
  = Martian Colony Schematics
  #lorem(100)

  = Shipment Manifest
  #lorem(100)
]