#import "@preview/modern-hsh-thesis:1.0.0": *

#show: project.with(
  title: "Beispiel-Titel",
  subtitle: "Bachelorarbeit im Studiengang Mediendesigninformatik",
  author: "Vorname Nachname",
  author-email: "vorname@nachname.tld",
  matrikelnummer: 1234567,
  prof: [
    Prof. Dr. Vorname Nachname\
    Abteilung Informatik, Fakultät IV\
    Hochschule Hannover\
    #link("mailto:vorname.nachname@hs-hannover.de")
  ],
  second-prof: [
    Prof. Dr. Vorname Nachname\
    Abteilung Informatik, Fakultät IV\
    Hochschule Hannover\
    #link("mailto:vorname.nachname@hs-hannover.de")
  ],
  date: "01. August 2024",
  glossary-columns: 1,
  bibliography: bibliography(("sources.bib", "sources.yaml"), style: "institute-of-electrical-and-electronics-engineers", title: "Literaturverzeichnis")
)

#include "chapters/1-einleitung.typ"
