#import "@local/tlacuache-thesis-msc-pcm-unam:0.1.0": thesis
#import "./utils.typ": *
#show: thmrules // IMPORTANTE

#show: thesis.with(
  titulo: [Foundations for a general theory of functions of a variable complex quantity],
  autor: [Bernhard Riemmnn],
  asesor: [Carl Frederich Gauss],
  generoAsesor: "director",
  lugar: [Gottinga, Alemania],
  agno: [1851],
  bibliography: bibliography("references.bib"),
  agradecimientos: include "agradecimientos.typ",
  abstract: include "abstract.typ",
)
#include "capitulo1.typ"
#include "capitulo2.typ"
