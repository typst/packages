#let keys-to-lang = (
  "appendix": (
    de: "Anhang",
    en: "Appendix",
  ),
  "chapter-outline": (
    de: "Inhaltsverzeichnis",
    en: "Table of contents",
  ),
  "table-outline": (
    de: "Tabellenverzeichnis",
    en: "List of tables",
  ),
  "figure-outline": (
    de: "Abbildungsverzeichnis",
    en: "List of figures",
  ),
  "kurzfassung": (
    de: "Kurzfassung",
    en: "Kurzfassung",
  ),
  "abstract": (
    de: "Abstract",
    en: "Abstract",
  ),
  "bibliography": (
    de: "Literaturverzeichnis",
    en: "Bibliography",
  ),
  "abbreviations": (
    de: "Abkürzungsverzeichnis",
    en: "List of abbreviations",
  ),
  "acknowledgement": (
    de: "Danksagung",
    en: "Acknowledgment",
  ),
  "preamble": (
    de: "Vorwort",
    en: "Preamble",
  ),
  "abbreviation": (
    de: "Abkürzung",
    en: "Abbreviation",
  ),
  "description": (
    de: "Beschreibung",
    en: "Description",
  ),
  "course-of-study": (
    de: "Studiengang",
    en: "Course of study",
  ),
  "schoolyear": (
    de: "Schuljahr",
    en: "School year",
  ),
  "fh-upper-austria": (
    de: "Fachhochschule Oberösterreich",
    en: "University of Applied Sciences Upper Austria",
  ),
  "campus-hagenberg": (
    de: "Campus Hagenberg",
    en: "Campus Hagenberg",
  ),
  "date": (
    de: "Datum",
    en: "Date",
  ),
  "mentor": (
    de: "Betreuer",
    en: "Mentor",
  ),
  "executed-by": (
    de: "Ausgeführt von",
    en: "Executed by",
  ),
  "submission-notes": (
    de: "Abgabevermerk",
    en: "Submission notes",
  ),
  "master-thesis": (
    de: "Masterarbeit",
    en: "Master thesis",
  ),
  "bachelor-thesis": (
    de: "Bachelorarbeit",
    en: "Bachelor thesis",
  ),
  "total-project": (
    de: "Gesamtprojekt",
    en: "Total project",
  ),
  "on-date": (
    de: "am",
    en: "on",
  ),
)

#let i8n(key) = context {
  let lang = text.lang
  let translations = keys-to-lang.at(key)
  let value = translations.at(lang, default: translations.at("en"))
  value
}

#let i8n-declaration-page() = context {
  let lang = text.lang
  if lang == "de" {
    include "declaration_de.typ"
  } else {
    include "declaration_en.typ"
  }
}

#let i8n-page-counter(current, total, numbering: auto) = context {
  let lang = text.lang
  let numbering = page.numbering
  let numbering = if numbering == auto or numbering == none { "1" } else {
    numbering
  }
  if lang == "de" [
    #std.numbering(numbering, current)
  ] else [
    #std.numbering(numbering, current)
  ]
}

#let i8n-date-short(date) = context {
  let lang = text.lang
  if lang == "de" [
    #date.display("[day].[month].[year]")
  ] else [
    #date.display("[year]-[month]-[day]")
  ]
}

#let i8n-date-long(date) = context {
  let lang = text.lang
  if lang == "de" [
    // Currently does not support localization for month repr:long, so we use a fixed format.
    #date.display("[day].[month].[year]")
  ] else [
    #date.display("[month repr:long] [day], [year]")
  ]
}
