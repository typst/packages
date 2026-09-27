// This is the ulreport (lab/course report) example.
// Writing a thesis or dissertation instead? See main.typ — delete
// whichever of the two you don't need (and rename this one to main.typ
// if you keep it), and remove the unused sample chapters
// (chapters/showcase.typ vs. chapters/chapter_0*.typ).
#import "@preview/mkuipers-ulusofona:0.1.0": *

#show: ulreport.with(
  title: "Relatório de Laboratório 3",
  subtitle: "Medição de Tempos de Resposta",
  date: "Maio 2025",
  authors: ((name:"Goro Akechi", number: "p8094", course: "LIG"), (name: "Flavio Barisi", number: "p8095", course: "LIG")),
  course-unit: "Sistemas Operativos",
  group: "3",
  professors: ("Daniel Silveira",),
  //department: "Departamento de Engenharia Informática e Sistemas de Informação",
  glossary-data: yaml("glossary.yaml"),  // Set to none if you don't want a glossary
  glossary-unused: true,      // Show every glossary entry, not just the ones used below
)

// Chapters
#include("chapters/showcase.typ")


// Aftermatter

#my-bibliography( bibliography("bibliography.yaml"))

#show: appendices.with("Anexos")

#chapter("Anexo com Dados Brutos")

== Tabela de Medições

#lorem(50)
