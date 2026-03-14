#import "@preview/unofficial-fhs-thesis:0.1.0": *

#show: project.with(
  logo: image("images/FH_Salzburg_Logo_DE.svg", height: 2.8cm),
  paper_type: "Protocol",
  title: "Title",
  subtitle: "Subtitle",
  studiengang: "Studiengang",
  authors: (
    "Vorname Nachname",
  ),
  bigboss: "Prof. Dr. Big Boss",
  betreuer: "Betreuer",
  abstract: lorem(59),
  show-subtitle: true,
  show-abstract: true,
  show-bigboss: true,
  show-betreuer: true,
)

#set heading(numbering: "1.1 ")

= Introduction
#lorem(600)

== In this paper
#lorem(20)

=== Contributions
#lorem(40)

= Related Work
#lorem(500)


#pagebreak()
= Another heading
