#import "@preview/classic-unipi-thesis:0.1.0": *

#show: thesis.with(
  title: "Un fantastico titolo\n per la tua tesi di laurea",
  author: "Nome Cognome",
  department: "Dipartimento di Informatica",
  degree: "Laurea in Informatica",
  supervisors: (
    "Prof. Marco Rossi",
    "Prof. Giulio Bianchi",
    "Dott. Matteo Danesi"
  ),
  academic-year: "202X/202X",
  lang: "it", // o "en"
  // Il logo dell'Università (Cherubino) è già incluso. Per usarne un altro:
  // logo: image("assets/images/mio-logo.svg"), oppure logo: none per toglierlo.
  // dedication: [
  //   a ... \
  //   \
  //   dedica, \
  //   magica.
  // ],
  tableofcontents: true,
  lof: true,
)

// Capitoli
#include "chapters/01-introduzione.typ"
#include "chapters/02-figure-tabelle-codice.typ"
#include "chapters/03-matematica.typ"
#include "chapters/04-conclusioni.typ"

// Ringraziamenti (commentare la riga per toglierli)
#include "chapters/Ringraziamenti.typ"

// // Appendici
#show: appendix
#include "utils/AppendiceA.typ"

// Bibliografia
#bibliography("utils/Bibliografia.bib", style: "ieee")
