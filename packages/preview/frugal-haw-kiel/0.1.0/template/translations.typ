#let value(en: "", de: "") = {
  context {
    if text.lang == "en" {
      return en
    }

    if text.lang == "de" {
      return de
    }

    panic("Unknown language setting used")
  }
}

#let translations = (
  // Abstract
  title-thesis: value(
    en: "Title of thesis",
    de: "Thema der Arbeit",
  ),
  keywords: value(
    en: "Keywords",
    de: "Stichworte",
  ),
  abstract: value(
    en: "Abstract",
    de: "Kurzzusammenfassung",
  ),

  // Cover
  submission-date-format: date => value(
    en: date.display("[month repr:long] [day], [year]"),
    de: date.display("[day]. [month repr:long] [year]"),
  ),
  bachelor-thesis: value(
    en: "Bachelor thesis",
    de: "Bachelorarbeit",
  ),
  faculty-of: value(
    en: "Faculty of",
    de: "Fachbereich",
  ),
  bachelor-thesis-submitted: value(
    en: "Bachelor thesis submitted for examination in Bachelor's degree",
    de: "Bachelorarbeit eingereicht im Rahmen der Bachelorprüfung",
  ),
  study-course: value(
    en: "in the study course",
    de: "im Studiengang",
  ),
  at-the-faculty-of: value(
    en: "at the Faculty of",
    de: "des Fachbereichs",
  ),
  at-university-of-applied-science-hamburg: value(
    en: "at University of Applied Science Kiel",
    de: "der Hochschule für Angewandte Wissenschaften Kiel",
  ),
  supervising-examiner: value(
    en: "Supervising examiner",
    de: "Betreuende*r Prüfer*in",
  ),
  second-examiner: value(
    en: "Second examiner",
    de: "Zweitgutachter*in",
  ),
  submitted-on: value(
    en: "Submitted on",
    de: "Eingereicht am",
  ),
  list-of-figures: value(
    en: "List of Figures",
    de: "Abbildungsverzeichnis",
  ),
  list-of-tables: value(
    en: "List of Tables",
    de: "Tabellenverzeichnis",
  ),
  listings: value(
    en: "Listings",
    de: "Listings",
  ),
  declaration-of-independent-processing: value(
    en: "Declaration of Independent Processing",
    de: "Erklärung zur selbstständigen Bearbeitung",
  ),
  declaration-of-independent-processing-content: value(
    en: "I hereby certify that I wrote this work independently without any outside help and only used the resources specified. Passages taken literally or figuratively from other works are identified by citing the sources.",
    de: "Hiermit versichere ich, dass ich die vorliegende Arbeit ohne fremde Hilfe selbständig verfasst und nur die angegebenen Hilfsmittel benutzt habe. Wörtlich oder dem Sinn nach aus anderen Werken entnommene Stellen sind unter Angabe der Quellen kenntlich gemacht.",
  ),
  place: value(
    en: "Place",
    de: "Ort",
  ),
  date: value(
    en: "Date",
    de: "Datum",
  ),
  signature: value(
    en: "Original Signature",
    de: "Unterschrift im Original",
  ),

  // Abbreviations & Glossary
  abbreviations: value(
    en: "Abbreviations",
    de: "Abkürzungen",
  ),

  glossary: value(
    en: "Glossary",
    de: "Glossar",
  ),

)
