#import "@preview/turbocharged-dhbw:0.2.0": report
#show: report.with(
  submission-date: "32. Nozember 2000",
  module: "T4_2000",
  author: "Rudi Regentonne",
  //university-supervisor: "Prof. Dr. Jürgen R.",
  company-supervisor: "Andi Mauer",
  duration: "560 Stunden",
  company-name: "Saftladen GmbH",
  city: "Bielefeld",
  // company-logo: image("assets/company-logo.png"),
  student-id: "123456789",
  // student-id: ("123456789", "987654321"),
  program: "Informatik / Angewandte Informatik",
  title: "Arbeitszeitbetrug",
  course: "TINF2XXBX",
  // course: ("TINF2XXBX", "TINF2XXBY"),
  confidential: false,
  abstract-content: include "content/abstract.typ",
  //document-type: "Projekt-/Studien-/Bachelorarbeit",
  //document-type: "Projektarbeit",
  //document-type: "Studienarbeit",
  //document-type: "Bachelorarbeit",
  document-type: "Praxisbericht",
  acronyms: yaml("abk.yml"),
  ai-tools: yaml("ai.yml"),
  // show-ai-declaration: false,
  bibliography-content: bibliography("bericht.bib"),
  appendix-content: include "content/anhang.typ",
)

// Main content
#pagebreak()
= Einleitung
#include "content/einleitung.typ"
#pagebreak()
= Hauptteil
#include "content/hauptteil.typ"
#pagebreak()
= Schluss
#include "content/schluss.typ"
