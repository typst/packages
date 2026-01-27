#import "@preview/hsmz-thesis:0.1.0": *

#let appendix-content = [
  = Anhang

  Dies ist der Anhang.
]


#show: hsmz-thesis.with(
  thesis-type: "Master's Thesis",
  title: "Typst Template",
  faculty: "Wirtschaft",
  degree-program: "IT-Management",
  submission-date: "01.01.2026",
  confidentiality-period: "01.01.2036",
  ai-declaration-option: 1,
  language: "de",
  acronyms: (
    "IT": "Information Technology",
  ),
  bibliography: bibliography("./literature.bib"),
  appendix: appendix-content,
  author: (
    name: "Max Musterman",
    matriculation-number: "12345",
    address: (street: "Musterstraße 1", zip: "12345", city: "Musterstadt"),
    signature-image: image("./assets/sample-signature.png"),
  ),
  company: "Musterfirma",
  supervisor: "Prof. Dr. Muster",
  citation-style: "apa",
  print-only-used-acronyms: true,
  show-full-bibliography: false,
)



= Einleitung

Eine Thesis zum Thema #acr("IT") and der Hochschule Mainz.

== Forschungsfrage

Forschungsmethodik streng nach der Literatur @wildeForschungsmethodenWirtschaftsinformatikEmpirische2007.

= Theorie

= Praxis

= Diskussion

= Zusammenfassung
