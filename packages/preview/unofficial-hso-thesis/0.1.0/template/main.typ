#import "@preview/unofficial-hso-thesis:0.1.0": company, faculty, styles, supervisor, thesis, thesis-info, thesis-type

// TODO Die folgende Seite muss nach dem Lesen entfernt werden
#include "chapters/README.typ"

// Definition der Metadaten
#let info = thesis-info(
  lang: "de",
  thesis-type: thesis-type.BACHELOR,
  title: "Haupttitel der Bachelorthesis",
  subtitle: "Untertitel",
  author: "Max Mustermann",
  degree: "Informatik",
  faculty: faculty.EMI,
  period: [01.01.2026 -- 30.06.2026],
  supervisors: (
    supervisor(name: "Prof. Dr. Max Mustermann", institution: "Hochschule Offenburg", gender: "m"),
    supervisor(name: "Maxi Musterfrau", institution: "Musterfirma"),
  ),
  companies: (
    company(name: "Musterfirma GmbH", logo: image("img/company_logo.png")),
  ),
  location: "Offenburg", // Wird bei der Unterschrift der Eidesstattlichen Erklärung verwendet
  copyright: true,
  ai-usage: 1, // 1: Erlaubte Nutzung (Liste im Anhang erforderlich), 2: Kennzeichnung im Text, 3: Verbot der Nutzung, none: Deaktiviert
  glossary: yaml("glossary.yaml"),
  bibliography: read("Bibliography.yaml", encoding: none),
  bibliography-style: read("ieee.csl", encoding: none), // Alternativen: "ieee", "apa"
)

// Hauptfunktion der Vorlage
#show: thesis.with(
  info: info,
  style: styles.emi,
  abstract: include "abstract.typ",
  appendix: include "appendix.typ"
)

#include "chapters/01_introduction.typ"
#include "chapters/02_main_chapter.typ"
#include "chapters/03_more_chapters.typ"
#include "chapters/04_summary.typ"
