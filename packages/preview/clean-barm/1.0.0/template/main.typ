#import "@preview/clean-barm:1.0.0": *
#import "@preview/codelst:2.0.2": sourcecode
#import "@preview/prequery:0.2.0"

// Da im Template keine Assets verwendet werden dürfen, die keine offene Lizenz haben,
// ist der Einsatz von prequery nötig. Es setzt Fallbacks für die Bilder ein und ermöglicht
// den Ersatz der Fallbacks durch ihre Originale durch ein zusätzliches CLI.
// Alternativ zur Installation des CLIs können die Bilder auch manuell von den URLs
// heruntergeladen und mittels `image("bild.png")` eingesetzt werden.
#prequery.fallback.update(true) // deaktivieren, um fallbacks zu deaktivieren und mit den eigentlichen assets fortzufahren

// folgende Dokumententypen sind verfügbar: Paper, TPT3, Expose, Thesis
// ggf. auch Importe anpassen

#show: Thesis.with(
  title: "Titel der Arbeit",
  author: "Max Mustermann",
  studyGroup: "AI-WS23_III",
  studentId: "123456",
  contactDetails: (
    "Musterstraße 1",
    "12345 Musterstadt",
    "max.mustermann@email.com",
  ),
  keywords: ("PDF", "Ausarbeitung"),
  description: "",
  submissionDate: "01.01.2024",
  academicReviewer: "Alice",
  companyReviewer: "Bob",
  headerLogo: prequery.image(
    "https://github.com/GolemT/BA-Template/blob/main/Bachelorarbeit/images/BA_Header.png?raw=true",
    "BA_Header.png",
  ),
  companyLogo: prequery.image(
    "https://raw.githubusercontent.com/GolemT/BA-Template/refs/heads/main/Bachelorarbeit/images/DB_Logo.png",
    "DB_Logo.png",
  ),
  degreeProgram: [Angewandte Informatik],
  showListOfFigures: true,
  showListOfTables: true,
  showListOfCode: true,
  acronyms: (
    API: "Application Programming Interface",
    HTML: "Hypertext Markup Language",
  ),
  appendix: include "./anhang.typ",
  glossary: (
    "API": "Application Programming Interface",
    "Typst": "Eine Markup-Sprache für die Dokumentenerstellung",
  ),
  bibliography: bibliography(
    title: none,
    "refs.bib",
  ),
)



// Hier wird die wirkliche Ausarbeitung geschrieben

= Introduction

#include "/texts/subtext.typ"

== Different Objects

#acr("API") ist eine Abkürzung

#gls("API") ist eine Glossarverlinkung

#figure(
  prequery.image(
    "https://github.com/GolemT/BA-Template/blob/main/Wissenschaftliche%20Arbeiten/images/BA_Logo.jpg?raw=true",
    "BA_Logo.jpg",
  ),
  caption: "Logo der Berufsakademie Rhein-Main",
)<Logo> //Hiermit wird ein aufrufbarer Link erstellt

#figure(
  table(columns: 2fr, row-gutter: 1)[Das ist eine Tabelle],
  caption: "Tabellenbeispiel",
)<tabelle> //Hiermit wird ein aufrufbarer Link erstellt

#figure(caption: "Beispiel für Code", sourcecode(
  ```ts
    const ReactComponent = () => {
      return (
        <div>
          <h1>Hello World</h1>
        </div>
      );
    };

    export default ReactComponent;
  ```,
))<code>

=== Contributions <Contribution>

#comment("This is a comment")

#todo("This is a ToDo")

#lorem(40)


= Linking Text

Hier wird nochmal #acr("API") aus dem Abkürzungsverzeichnis erwähnt.

Hier wird nochmal #gls("API") aus dem Glossar erwähnt

@Logo Zeigt das Logo der BA

@tabelle zeigt ein Beispiel einer Tabelle

@code zeigt ein Code Snippet

== Zitate

Hier ist ein Zitat @nissen_softwareagenten_2006.

#cite(<nissen_softwareagenten_2006>, form: "prose")) zitiert etwas im laufenden Text.

Hier ist ein Zitat mit Link auf die Fußnote #footnote()[#cite(<nissen_softwareagenten_2006>)]
