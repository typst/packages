#import "@preview/clean-barm:1.0.1": *
#import "@preview/codelst:2.0.2": sourcecode
#import "@preview/prequery:0.2.0"

// Da im Template keine Assets verwendet werden dürfen, die keine offene Lizenz haben,
// ist der Einsatz von prequery nötig. Es setzt Fallbacks für die Bilder ein und ermöglicht
// den Ersatz der Fallbacks durch ihre Originale durch ein zusätzliches CLI.
// Alternativ zur Installation des CLIs können die Bilder auch manuell von den URLs
// heruntergeladen und mittels `image("bild.png")` eingesetzt werden.
#prequery.fallback.update(true) // deaktivieren, um fallbacks zu deaktivieren und mit den eigentlichen assets fortzufahren

// folgende Dokumententypen sind verfügbar: paper, TPT3, expose, thesis
// ggf. auch Importe anpassen

#show: thesis.with(
  title: "Titel der Arbeit",
  author: "Max Mustermann",
  study-group: "AI-WS23_III",
  student-id: "123456",
  contact-details: (
    "Musterstraße 1",
    "12345 Musterstadt",
    "max.mustermann@email.com",
  ),
  keywords: ("PDF", "Ausarbeitung"),
  description: "",
  submission-date: "01.01.2024",
  academic-reviewer: "Alice",
  company-reviewer: "Bob",
  header-logo: prequery.image(
    "https://raw.githubusercontent.com/GolemT/BA-Template/4af5df877426ca06ec087129b9684637c4cc49b1/Bachelorarbeit/images/BA_Header.png",
    "BA_Header.png",
  ),
  company-logo: prequery.image(
    "https://raw.githubusercontent.com/GolemT/BA-Template/4af5df877426ca06ec087129b9684637c4cc49b1/Bachelorarbeit/images/DB_Logo.png",
    "DB_Logo.png",
  ),
  degree-program: [Angewandte Informatik],
  show-list-of-figures: true,
  show-list-of-tables: true,
  show-list-of-code: true,
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
    style: "apa-ba-remix.csl",
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
    "https://raw.githubusercontent.com/GolemT/BA-Template/4af5df877426ca06ec087129b9684637c4cc49b1/Wissenschaftliche_Arbeiten/images/BA_Logo.jpg",
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
