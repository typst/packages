// This is the ulthesis (thesis/dissertation) example.
// Writing a lab/course report instead? See main-report.typ — delete
// whichever of the two you don't need, and remove the unused sample
// chapters (chapters/chapter_0*.typ vs. chapters/showcase.typ).
#import "@preview/mkuipers-ulusofona:0.1.0": *

#show: ulthesis.with(
  title: "Título do Trabalho",
  type: "Trabalho Final de Curso",
  subtype: "1ª Entrega Intercalar",
  subtitle: "A Practical Guide",
  date: "July 2026",
  authors: ((name:"Goro Akechi", number: "p8094", course: "LIG"), (name: "Flavio Barisi", number: "p8095", course: "LIG")),
  supervisors: ("Daniel Silveira", "Martijn Kuipers"),
  external: "João Craveiro",
  lang: "pt",
  toc-depth: 2,
  //department: "Departamento de Engenharia Informática e Sistemas de Informação",
  //list-of-figures: false,
  //list-of-tables: false,
  //list-of-acronyms: false,
  glossary-data: yaml("glossary.yaml"),  // Set to none if you don't want a glossary
  //glossary-unused: true,      // Uncomment if you want all glossaries from the file to appear
  acknowledgements: [
    Para a mãe, o pai e o gato.
  ],
  abstract-pt: [
    Um template para universidade
  ],
  abstract-en: [
    A template for the university
  ]
)

// Chapters
#include("chapters/chapter_01.typ")
#include("chapters/chapter_02.typ")
#include("chapters/chapter_03.typ")
#include("chapters/chapter_04.typ")


// Aftermatter

#my-bibliography( bibliography("bibliography.yaml"))

//#make-index(title: "Index")


#show: appendices.with("Appendices")

#chapter("Appendix Chapter Title")

== Appendix Section Title

#lorem(50)
#chapter("Appendix Chapter Title")

== Appendix Section Title

#lorem(50)
