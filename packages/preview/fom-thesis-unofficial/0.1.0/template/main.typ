//#import "/lib.typ": * 
//#import "@local/fom-thesis-unofficial:0.1.0": *
//Für lokale Entwicklung bitte einkommentieren

#import "@preview/fom-thesis-unofficial:0.1.0": *

// META INFORMATIONEN FÜLLEN:
#show: project.with(
  title: "Hier könnte Ihr Titel stehen!",
  authors: "Max Mustermann",
  studiengang: "Wirtschaftsinformatik",
  akademischer-grad: "Bachelor of Science (B.Sc.)",
  dokumentart: "Seminararbeit",
  matrikelnummer: "361710",
  betreuer: "Prof. Dr. Maria Musterfrau",
  abgabedatum: "01.04.2026",

  
  date: "March 16, 2026",

  logo: "template/media/example-logo.png", // --!-REPLACE LOGO WITH YOUR FILE HERE-!--

  bib-file: bibliography("references.yaml", title: "Literaturverzeichnis"),
  bib-web-file: bibliography("references_web.yaml", title: "Internetquellen"),
  abbreviations: include "abkuerzungsverz.typ",
  list-of-figures: true,
  list-of-tables: true,
)

// INHALT

= Einleitung
#lorem(60)


== Problemstellung
#lorem(20)

== Zielsetzung
#figure(
  table(
    columns: 3,
    align: (left, center, right),
    table.header(
      [*Ziel*], [*Spalte 2*], [*Spalte 3*]
    ),
    [Super Note bekommen!], [Reihe 2], [...],
    [Reihe 3], [uvm.], [...]
  ),
  caption: [Ziele der wissenschaftlichen Arbeit]
) <academic_goals>
#lorem(20)

== Vorgehensweise
#lorem(20)

= Erste Ebene
#lorem(20)
#figure(
  image("media/Finn_Riedel_FOM_Koeln_Rheinauhafen.JPG", width: 60%),
  caption: [FOM Aussicht, Rheinauhafen, Köln (C) Finn Riedel]
) <fom_cgn>

Wie man an @fom_cgn sehen kann, kann man auch Abbildungen darstellen.

== Zweite Ebene
#lorem(20)

== Zweite Ebene
#lorem(20)
#figure(
  ```py
    x = 15
    y = 10
    print(x+y)
  ```,
  caption: [Addition in Python]
) <addition_py>
#lorem(20)

=== Dritte Ebene
#lorem(20)

=== Dritte Ebene
#lorem(20)

= Erste Ebene
#lorem(20)
#lorem(10)@unternehmensbewertung
#lorem(10)@personal
#lorem(10)@wissenschaftliches_arbeiten
#lorem(10)@investment_banking[S. 13]
#lorem(10)@private_equity
#lorem(10)@lemons
#lorem(10)@vw
#lorem(10)@theisen_ohnejahr

= Fazit
Fertig!