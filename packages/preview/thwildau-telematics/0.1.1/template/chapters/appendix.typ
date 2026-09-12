= Full `main.typ`

#figure(caption: [Full main.typ])[
  ```typst
#import "@preview/thwildau-telematics:0.1.1": (
  abbreviation, conf, define_abbreviation, define_unit, infocard, tables, th-color, todo, unit,
) // TH-Wildau template

// template configuration
#show: conf.with(
  title: "TH-Wildau Typst Template",
  titlepage: "internship",
  student: (
    name: "Clara Fall",
    matrnr: "12345678",
    subject: "Praxisintegrierender Bachelor Studiengang Telematik",
    seminar_group: "T23",
    semester: "4",
  ),
  supervisor: (
    name: "Frau Dr. Lieschen Müller",
    mail: "mueller@beispielag.de",
  ),
  internship: (
    type: "3. Betriebspraktikum",
    partner: [Beispiel AG \ Straßenweg 1 \ 12345 Musterstadt \ #link("https://beispielag.de")],
    period: "16.06.2025 bis 25.07.2025",
  ),
  bibliography: bibliography("bib.yaml", style: "institute-of-electrical-and-electronics-engineers"),
  language: "de",
  misc_pages: (
    bibliographic-description: (
      de: (
        title-long: "TH-Wildau Telematics Typst Template für Thesis und Praktikumsbericht",
        metadata: " ",
        keywords: "Typst, Thesis, Template, TH-Wildau, Telematik",
        goal: [Erstellung eines neue Typst Projektes mit dem TH-Wildau Telematics Template.],
        abstract: [In dieser Arbeit wird erklärt, wie das darin verwendete TH-Wildau Telematics Typst-Template konfiguriert und angewendet werden kann.],
      ),
      en: (
        title-long: "TH-Wildau Typst template for thesis and intership.",
        metadata: " ",
        keywords: "Typst, Thesis, Template, TH-Wildau, Telematics",
        goal: [Creation of a new typst project with the TH-Wildau Telematics template.],
        abstract: [This thesis aims to explain the process of installing, configuring and applying the TH-Wildau Telematics typst template.],
      ),
    ),
    reading_guides: todo()[Beispiele für Konfiguration aktualisieren],
    authorship_declaration: true,
    company_confirmation: true,
    glossary: (("Telematik", "Die Kombination aus Telekommunikation und Informatik"),),
    appendix: include "chapters/appendix.typ",
  ),
)

// ---------- english ----------
#set text(lang: "en")
#include "chapters/01.typ"

// ---------- german ----------
#set text(lang: "de")
#include "chapters/02.typ"
  ```]


= Vollständige `main.typ` 

#figure(caption: [Vollständigemain.typ])[
  ```typst

#import "@preview/thwildau-telematics:0.1.1": (
  abbreviation, conf, define_abbreviation, define_unit, infocard, tables, th-color, todo, unit,
) // TH-Wildau template

// template configuration
#show: conf.with(
  title: "TH-Wildau Typst Template",
  titlepage: "internship",
  student: (
    name: "Clara Fall",
    matrnr: "12345678",
    subject: "Praxisintegrierender Bachelor Studiengang Telematik",
    seminar_group: "T23",
    semester: "4",
  ),
  supervisor: (
    name: "Frau Dr. Lieschen Müller",
    mail: "mueller@beispielag.de",
  ),
  internship: (
    type: "3. Betriebspraktikum",
    partner: [Beispiel AG \ Straßenweg 1 \ 12345 Musterstadt \ #link("https://beispielag.de")],
    period: "16.06.2025 bis 25.07.2025",
  ),
  bibliography: bibliography("bib.yaml", style: "institute-of-electrical-and-electronics-engineers"),
  language: "de",
  misc_pages: (
    bibliographic-description: (
      de: (
        title-long: "TH-Wildau Telematics Typst Template für Thesis und Praktikumsbericht",
        metadata: " ",
        keywords: "Typst, Thesis, Template, TH-Wildau, Telematik",
        goal: [Erstellung eines neue Typst Projektes mit dem TH-Wildau Telematics Template.],
        abstract: [In dieser Arbeit wird erklärt, wie das darin verwendete TH-Wildau Telematics Typst-Template konfiguriert und angewendet werden kann.],
      ),
      en: (
        title-long: "TH-Wildau Typst template for thesis and intership.",
        metadata: " ",
        keywords: "Typst, Thesis, Template, TH-Wildau, Telematics",
        goal: [Creation of a new typst project with the TH-Wildau Telematics template.],
        abstract: [This thesis aims to explain the process of installing, configuring and applying the TH-Wildau Telematics typst template.],
      ),
    ),
    reading_guides: todo()[Beispiele für Konfiguration aktualisieren],
    authorship_declaration: true,
    company_confirmation: true,
    glossary: (("Telematik", "Die Kombination aus Telekommunikation und Informatik"),),
    appendix: include "chapters/appendix.typ",
  ),
)

// ---------- english ----------
#set text(lang: "en")
#include "chapters/01.typ"

// ---------- german ----------
#set text(lang: "de")
#include "chapters/02.typ"
  ```]

