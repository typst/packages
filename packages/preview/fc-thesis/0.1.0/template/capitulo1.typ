#import "@preview/fc-thesis:0.1.0": chapter

// completamente opcional cargar la bibliografía, compilar el capítulo
#show: chapter.with(bibliography: bibliography("references.bib"))

= Mi primer capítulo

Introducción al primer cápitulo.

#include "seccion1.typ"