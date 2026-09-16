# clean-barm

This package contains inofficial templates for documents at the [Berufsakademie Rhein-Main](https://studenten.ba-rm.de/) university, Germany. 

Because of the specificity of this package it is currently only documented in German although translation 

The original templates were created by [GolemT](https://github.com/GolemT/ba-template) while this package contains a unified and reworked versions of those.

This repositor currently contains
- Paper ("Wissenschaftliches Arbeiten")
- TPT
- Exposé
- Bachelor Thesis

## Setup

The assets referenced in the main.typ of the template use [`prequery`](https://typst.app/universe/package/prequery/) to outsource them as their license is not compatible.
You may install and use the CLI via `prequery main.typ` to pull the ressources automatically or download them manually and replace the `prequery.image(...)` with `image(...)` statements.
*This setup means that the logos are missing because prequery will fall back on placeholder assets by default!*
The template contains additional explanations for this.

## Usage

Each template uses a block to define core properties and control properties such as authors or whether a list of figures should be rendered.

This is a full list of available properties:

<details>
  <summary>Thesis</summary>
   
  ```typst
  #show: Thesis.with(
    //language: "de", // default
    title: "Titel der Arbeit",
    author: "Max Mustermann",
    keywords: ("Thesis", "Bachelor", "..."),
    description: "Thesis über xyz",
    degree-program: "Angewandte Informatik",
    bachelor-type: "Science",
    study-group: "AI-WS23_III",
    student-id: "1234567",
    contact-details: (
      "Musterstraße 1",
      "12345 Musterstadt",
      "max.mustermann@email.com",
    ),
    academic-reviewer: "Alice",
    company-reviewer: "Bob",
    submission-date: "10.06.2026",
    university-logo: image("BA_Logo.jpg", width: auto),
    company-logo: image("DB_Logo.png", height: 3fr),
    show-list-of-figures: true,
    show-list-of-tables: true,
    show-list-of-code: true,
    acronyms: (:), // leeres Dictionary
    appendix: none,
    glossary: (:), // leeres Dictionary
    bibliography: none,
    //restriction-notice: "" // has internal default
    //foreword: "",
    //gendering-note: "", // has internal default
  )
  ```
</details>

<details>
  <summary>Exposé</summary>

  ```typst
  #show: Expose.with(
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
    date-of-colloquium: "03.12.2025",
    submission-date: "27.11.2025",
    academic-reviewer: "Alice",
    company-reviewer: "Bob",
    university-logo: logo(width: auto),
    module: [Theorie-Praxis-Anwendung II],
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
      "refs.bib",
    ),
    //restriction-notice: "" // has internal default
    //foreword: "",
    //gendering-note: "", // has internal default
  )
  ```
</details>

<details>
  <summary>TPT</summary>

  ```typst
  #show: TPT.with(
    title: "Titel der Arbeit",
    authors: (
      (name: "Max Mustermann", student-id: "1234567"),
    ),
    study-group: "AI-WS23_III",
    keywords: ("PDF", "Ausarbeitung"),
    description: "",
    date: "01.01.2024",
    university-logo: logo(width: auto),
    modul: [Theorie-Praxis-Anwendung II],
    pre-thesis: false, // only for TPT3
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
      "refs.bib",
    ),
    //restriction-notice: "" // has internal default
    //foreword: "",
    //gendering-note: "", // has internal default
  )
  ```
</details>

<details>
  <summary>Paper</summary>

  ```typst
  #show: Paper.with(
    title: "Titel der Arbeit",
    authors: (
      (name: "Max Mustermann", student-id: "1234567"),
    ),
    study-group: "AI-WS23_III",
    keywords: ("PDF", "Ausarbeitung"),
    description: "",
    date: "01.01.2024",
    university-logo: logo(width: auto),
    modul: [Theorie-Praxis-Anwendung II],
    pre-thesis: false, // only for TPT3
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
      "refs.bib",
    ),
    //restriction-notice: "" // has internal default
    //foreword: "",
    //gendering-note: "", // has internal default
  )
  ```

</details>

The acronyms and glossary may get their own source file in case the list gets too long:

<details>
  <summary>main.typ + acronyms.typ</summary>

  acronyms.typ:

  ```typst
  #let Acronyms = (
    API: "Application Programming Interface",
    HTML: "Hypertext Markup Language",
  )
  ```

  main.typ 

  ```typst 
  #import "acronyms.typ": Acronyms
  #show: thesis.with(
    acronyms: Acronyms,
  )
  ```
</details>
