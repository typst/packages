#import "@preview/fc-thesis:0.1.0": thesis

#show: thesis.with(
  titulo: [Titulo],
  autor: [Autor],
  asesor: [Asesor],
  bibliography: bibliography("references.bib"),
)

#include "capitulo1.typ"