#import "@preview/tlacuache-thesis-fc-unam:0.1.1": chapter

// completamente opcional cargar la bibliografía, compilar el capítulo
#show: chapter.with(bibliography: bibliography("references.bib"))

= Mi primer capítulo

Introducción al primer cápitulo.

#include "seccion1.typ"