#import "@preview/unofficial-uninsubria-thesis:0.1.0": *
#import "glossary.typ": glossary-entries


#show: tesi-uninsubria.with(
  titolo: "Sviluppo di un sistema embedded per un razzo lunare",
  autore: "Mattia Rossi",
  matricola: "747053",
  bibliography: bibliography("sources.bib"),
  codice-corso: "F004",
  relatore: "Carlo Rossi",
  tutor: "Edoardo Neri",
  azienda: "NASA spa",
  anno-accademico: "2025/2026",
  corso: "CORSO DI STUDIO TRIENNALE IN INFORMATICA",
  dipartimento: "DIPARTIMENTO DI SCIENZE TEORICHE E APPLICATE",

  glossary: glossary-entries, // displays the glossary terms defined in "glossary.typ"
  language: "it", // en, de
)

#include "capitoli/introduzione.typ"
#include "capitoli/capitolo1.typ"
#include "capitoli/conclusione.typ"
