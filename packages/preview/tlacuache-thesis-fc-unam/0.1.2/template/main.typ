#import "@preview/tlacuache-thesis-fc-unam:0.1.2": thesis

#show: thesis.with(
  titulo: [Titulo],
  autor: [Autor],
  asesor: [Asesor],
  bibliography: bibliography("references.bib"),
)

#include "capitulo1.typ"