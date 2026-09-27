// LTeX: enabled=false
#import "@preview/dhbw-oderso:2.2.0": caption-with-source, ihk-adapter
#import "glossary.typ": abbreviations, glossary
#import "appendix.typ": appendices

#show: ihk-adapter.with(
  lang: "de",

  // Set to false if you do not need a confidentiality clause
  confidentiality-clause: true,

  title-long: "Writing in Typst about a long, very scientific topic",
  title-short: "Writing in Typst",
  thesis-type: "Abschlussprojekt",
  examination: "Winterprüfung 2026",
  authors: (
    (
      firstname: "John",
      lastname: "Doe",
      examinee-number: "(000)-0000",
      signature: image("assets/placeholder-signature.png"),
    ), // make sure to keep this comma after the first author if there is only one author!
    (
      firstname: "Erika",
      lastname: "Musterfrau",
      examinee-number: "(123)-4567",
    ),
  ),
  signature-city: "Karlsruhe",
  processing-period-weeks: 12,
  company-department: "Human Resources",
  company-supervisor: "Max Mustermann",
  company-logo: image("assets/placeholder-company-logo.svg"),

  // Appendix can be configured in appendix.typ
  // remove property to remove appendices
  appendices: appendices,

  // Bibliography
  library: bibliography("refs.bib"),

  abbreviations: abbreviations,
  glossary: glossary,
)

// You can now start writing :)

#include "chapters/introduction.typ"
#include "chapters/basic_formatting.typ"
#include "chapters/advanced_elements.typ"
#include "chapters/references_citations.typ"
#include "chapters/reference_management.typ"
#include "chapters/conclusion.typ"
