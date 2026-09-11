#import "@preview/tlacuache-thesis-msc-pcm-unam:0.1.0": thesis
#import "./utils.typ": * // Aqui se guardan los comandos regulares
#show: thmrules // IMPORTANTE


// La siguiente template tiene todo lo necesario para poder empezar 
// tu tesis

#show: thesis.with(
  titulo: [Foundations for a general theory of functions of a variable complex quantity],
  autor: [Bernhard Riemmnn],
  asesor: [Carl Frederich Gauss],
  asesor-genero: "director",
  lugar: [Gottinga, Alemania],
  agno: [1851],
  bibliografia: bibliography("references.bib"),
  agradecimientos: include "agradecimientos.typ",
  resumen: include "abstract.typ",
)
#include "capitulo1.typ"
#include "capitulo2.typ"
