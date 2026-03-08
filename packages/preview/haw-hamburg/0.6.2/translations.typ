#let value(en: "", de: "") = {
  context {
    if text.lang == "en" {
      return en
    }

    if text.lang == "de" {
      return de
    }

    return "Unknown language"
  }
}

#let translations = (
  submission-date-format: date => value(
    en: date.display("[month repr:long] [day], [year]"),
    de: date.display("[day]. [month repr:long] [year]"),
  ),
  bachelor-thesis: value(
    en: "Bachelor thesis",
    de: "Bachelorarbeit",
  ),
  master-thesis: value(
    en: "Master thesis",
    de: "Masterarbeit",
  ),
  faculty-of: value(
    en: "Faculty of",
    de: "Fakultät",
  ),
  department-of: value(
    en: "Department of",
    de: "Department",
  ),
  bachelor-thesis-submitted-for-examination-in-bachelors-degree: value(
    en: "Bachelor thesis submitted for examination in Bachelor's degree",
    de: "Bachelorarbeit eingereicht im Rahmen der Bachelorprüfung",
  ),
  master-thesis-submitted-for-examination-in-masters-degree: value(
    en: "Master thesis submitted for examination in Master's degree",
    de: "Masterarbeit eingereicht im Rahmen der Masterprüfung",
  ),
  in-the-study-course: value(
    en: "in the study course",
    de: "im Studiengang",
  ),
  at-the-department: value(
    en: "at the Department",
    de: "am Department",
  ),
  at-the-faculty-of: value(
    en: "at the Faculty of",
    de: "der Fakultät",
  ),
  at-university-of-applied-science-hamburg: value(
    en: "at University of Applied Science Hamburg",
    de: "der Hochschule für Angewandte Wissenschaften Hamburg",
  ),
  supervising-examiner: value(
    en: "Supervising examiner",
    de: "Betreuender Prüfer",
  ),
  second-examiner: value(
    en: "Second examiner",
    de: "Zweitgutachter",
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
    de: "Hiermit versichere ich, dass ich die vorliegende Arbeit ohne fremde Hilfe selbständig verfasst und nur die angegebenen Hilfsmittel benutzt habe. Wörtlich oder dem Sinn
nach aus anderen Werken entnommene Stellen sind unter Angabe der Quellen kenntlich gemacht.",
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
)
