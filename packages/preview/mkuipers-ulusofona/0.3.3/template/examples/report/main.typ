// This is the ulreport (lab/course report) example. Chapters 1-4 show how
// to use the template's features (sectioning, in-text elements, maths,
// tables and figures); chapter 5 is a worked results section with formulas,
// images, tables and a block diagram. For the TFC report see ../../main.typ.
// To start from this one, copy this folder's contents over the template root.
#import "@preview/mkuipers-ulusofona:0.3.3": *

#show: ulreport.with(
  title: "Relatório de Laboratório 3",
  subtitle: "Medição de Tempos de Resposta",
  date: "Maio 2025",
  authors: ((name:"Goro Akechi", number: "p8094", course: "LIG"), (name: "Flavio Barisi", number: "p8095", course: "LIG")),
  course-unit: "Sistemas Operativos",
  group: "3",
  professors: ("Martijn Kuipers",),
  department: "Departamento de Engenharia Informática e Sistemas de Informação",
  glossary-data: yaml("glossary.yaml"),  // Set to none if you don't want a glossary
  glossary-unused: true,      // Show every glossary entry, not just the ones used below
)

// Chapters
#include("chapters/chapter_01.typ")
#include("chapters/chapter_02.typ")
#include("chapters/chapter_03.typ")
#include("chapters/chapter_04.typ")
#include("chapters/chapter_05.typ")


// Aftermatter

#my-bibliography( bibliography("bibliography.yaml"))

#show: appendices.with("Anexos")

#chapter("Anexo com Dados Brutos")

== Tabela de Medições

#lorem(50)
