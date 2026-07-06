#import "@preview/hsmz-thesis-unofficial:0.2.0": *
#import "acronyms.typ": acronyms
#import "appendix.typ": appendix-content

#show: hsmz-thesis-unofficial.with(
  thesis-type: "Master's Thesis",
  title: "Untersuchung der Auswirkungen von [Thema] auf [Bereich] unter besonderer Berücksichtigung von [Aspekt] in [Kontext]",
  faculty: "Wirtschaft",
  degree-program: "IT-Management",
  submission-date: "01.01.2026",
  confidentiality-period: "01.01.2036",
  ai-declaration-option: 1,
  language: "de",
  acronyms: acronyms,
  bibliography: bibliography("./literature.bib"),
  appendix: appendix-content,
  author: (
    name: "Max Mustermann",
    matriculation-number: "12345",
    address: (street: "Musterstraße 1", zip: "12345", city: "Musterstadt"),
    signature-image: image("./assets/sample-signature.png"),
  ),
  company: "Musterfirma",
  supervisor: "Prof. Dr. Muster",
  font: "Calibri",
  citation-style: "apa",
  print-only-used-acronyms: true,
  show-full-bibliography: false,
  show-restriction-notice: true,
)


= Einleitung

Eine Thesis zum Thema #acr("IT") an der Hochschule Mainz.

== Forschungsfrage

Forschungsmethodik streng nach der Literatur @wildeForschungsmethodenWirtschaftsinformatikEmpirische2007.

= Theorie

= Praxis

= Diskussion

= Zusammenfassung
