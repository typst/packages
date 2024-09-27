#import "lib.typ": *

#import "abstract.typ": abstract
#import "abbreviations.typ": abbreviations
#import "literature_and_bibliography.typ": literature-and-bibliography
#import "attachements.typ": attachements

// Kapitel
#import "chapters/introduction.typ": introduction
#import "chapters/summary.typ": summary
// Füge hier weitere Kapitel hinzu


#show: project.with(
  lang: "de",
  authors: (
    (
      name: "Max Mustermann",
      id: "12 34 567",
      email: "mustermann@email.com"
    ),
  ),
  title: "Keine Panik!",
  subtitle: "Mit Typst durchs Studium",
  //date: "29.07.2024",
  version: none,          // Hier kann die Versionsnummer des Dokumentes eingetragen werden
  thesis-compliant: true, // Setze es auf false, wenn es nur für Dokumentationen genutzt wird

  // Format
  side-margins: (
    left: 3.5cm,
    right: 3.5cm,
    top: 3.5cm,
    bottom: 3.5cm
  ),
  h1-spacing: 0.5em,
  line-spacing: 0.65em,
  font: "Roboto",
  font-size: 11pt,
  hyphenate: false,

  // Color settings
  primary-color: dark-blue,
  secondary-color: blue,
  text-color: dark-grey,
  background-color: light-blue,

  // Cover sheet
  custom-cover-sheet: none,
  cover-sheet: (
    university: (
      name: "University of Applied Typst Sciences",
      street: "Musterstraße 1",
      city: "D-12345 Musterstadt",
      logo: none
    ), 
    employer: (
      name: "Arbeitgeber xy",
      street: "Musterstraße 2",
      city: "D-12345 Musterstadt",
      logo: none
    ),
    cover-image: none,
    description: [
      Bachelorarbeit zur Erlangung des akademischen Grades Bachelor of Science
    ],
    faculty: "Ingenieurwissenschaften",
    programme: "Typst Sciences",
    semester: "SoSe2024",
    course: "Templates with Typst",
    examiner: "Prof. Dr.-Ing Mustermann",
    submission-date: "30.07.2024",
  ),

  // Declaration
  custom-declaration: none,
  declaration-on-the-final-thesis: (
    legal-reference: none,
    thesis-name: none,
    consent-to-publication-in-the-library: none,
    genitive-of-university: none
  ),

  // Abstract
  abstract: abstract(), // Setze es auf none, wenn es nicht angezeigt werden soll

  // Outlines
  depth-toc: 4,
  outlines-indent: 1em,
  show-list-of-figures: false,      // Wird immer angezeigt, wenn `thesis-compliant` true ist
  show-list-of-abbreviations: true, // Nur sichtbar, wenn tatsächlich mit `gls` oder `glspl` Abkürzungen im Text aufgerufen werden
  list-of-abbreviations: abbreviations(),
  show-list-of-formulas: true, // Setze es auf false, wenn es nicht angezeigt werden soll
  custom-outlines: ( // none
    (
      title: none,   // required
      custom: none   // required
    ),
  ),
  show-list-of-tables: true,   // Setze es auf false, wenn es nicht angezeigt werden soll
  show-list-of-todos: true,    // Setze es auf false, wenn es nicht angezeigt werden soll
  literature-and-bibliography: literature-and-bibliography(),
  list-of-attachements: attachements()
)

= Einleitung<einleitung>

#introduction()

= Hauptteil

// Hier sollten die einzelnen Kapitel aufgerufen werden, welche zuvor unter `chapters` angelegt wurden

== Beispiele

// Aufruf einer Abkürzung
#gls("repo-vorlage")

// Referenz zu einer anderen Überschrift
@einleitung

// TODO anlegen
#todo[Das ist ein Beispiel]

= Schluss/Zusammenfassung/Fazit<zusammenfassung>

#summary()