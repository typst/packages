#import "@preview/htl3r-da:2.0.0" as htl3r

#show: htl3r.diplomarbeit.with(
  title: "Mein DA-Titel",
  subtitle: "mit kreativem Untertitel",
  department: "ITN", // kann eine Auswahl sein aus: ITN, ITM, M
  school-year: "2024/2025",
  authors: (
    (name: "Max Mustermann", supervisor: "Peter Professor"),
    (name: "Andreas Arbeiter", supervisor: "Bernd Betreuer"),
    (name: "Theodor Template", supervisor: "Bernd Betreuer"),
  ),
  abstract-german: [#include "text/kurzfassung.typ"],
  abstract-english: [#include "text/abstract.typ"],
  supervisor-incl-ac-degree: (
    "Prof, Dipl.-Ing. Peter Professor",
    "Prof, Dipl.-Ing. Bernd Betreuer",
  ),
  sponsors: (
    "Scherzartikel GmbH",
    "Ottfried OT-Handels GmbH",
  ),
  date: datetime.today(),
  print-ref: true,
  generative-ai-clause: none,
  abbreviation: yaml("abbr.yml"),
  bibliography-content: bibliography("refs.yml", title: [Literaturverzeichnis]),
)

#include "chapter/example.typ"
