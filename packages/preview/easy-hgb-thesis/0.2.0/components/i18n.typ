#let keys-to-lang = (
  "appendix": (
    de: "Anhang",
    en: "Appendix",
  ),
  "chapter-outline": (
    de: "Inhaltsverzeichnis",
    en: "Contents",
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
  "references": (
    de: "Quellenverzeichnis",
    en: "References",
  ),
  "abbreviations": (
    de: "Abkürzungsverzeichnis",
    en: "Abbreviations",
  ),
  "acknowledgement": (
    de: "Danksagung",
    en: "Acknowledgment",
  ),
  "preamble": (
    de: "Vorwort",
    en: "Preamble",
  ),
  "preface": (
    de: "Vorwort",
    en: "Preface",
  ),
  "chapter": (
    de: "Kapitel",
    en: "Chapter",
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
  "fh-bachelor-study-program": (
    de: "Fachhochschul-Bachelorstudiengang",
    en: "Bachelor study programme",
  ),
  "fh-master-study-program": (
    de: "Fachhochschul-Masterstudiengang",
    en: "Master study programme",
  ),
  "degree-goal-declaration": (
    de: "zur Erlangung des akademischen Grades\nBachelor of Science in Engineering",
    en: "to obtain the academic degree of\nBachelor of Science in Engineering",
  ),
  "campus-hagenberg": (
    de: "Campus Hagenberg",
    en: "Campus Hagenberg",
  ),
  "hagenberg-address": (
    de: "A-4232 Hagenberg, Austria",
    en: "A-4232 Hagenberg, Austria",
  ),
  "date": (
    de: "Datum",
    en: "Date",
  ),
  "submitted-by": (
    de: "Eingereicht von",
    en: "Submitted by",
  ),
  "reviewed-by": (
    de: "Begutachtet von",
    en: "Reviewed by",
  ),
  "master-thesis": (
    de: "Masterarbeit",
    en: "Master thesis",
  ),
  "bachelor-thesis": (
    de: "Bachelorarbeit",
    en: "Bachelor thesis",
  ),
  "on-date": (
    de: "am",
    en: "on",
  ),
  "signature": (
    de: "Unterschrift",
    en: "Signature",
  ),
  "declaration": (
    de: "Erklärung",
    en: "Declaration",
  ),
  "declaration-content": (
    de: "Ich erkläre eidesstattlich, dass ich die vorliegende Arbeit selbstständig und ohne fremde Hilfe verfasst, andere als die angegebenen Quellen nicht benutzt und die den benutzten Quellen entnommenen Stellen als solche gekennzeichnet habe. Die Arbeit wurde bisher in gleicher oder ähnlicher Form keiner anderen Prüfungsbehörde vorgelegt.",
    en: "I hereby declare and confirm that this thesis is entirely the result of my own original work. Where other sources of information have been used, they have been indicated as such and properly acknowledged. I further declare that this or similar work has not been submitted for credit elsewhere.",
  ),
)

#let i18n(key) = context {
  let lang = text.lang
  let translations = keys-to-lang.at(key)
  let value = translations.at(lang, default: translations.at("en"))
  value
}

#let i18n-page-counter(current, total, numbering: auto) = context {
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

#let i18n-date-short(date) = context {
  let lang = text.lang
  if lang == "de" [
    #date.display("[day].[month].[year]")
  ] else [
    #date.display("[year]-[month]-[day]")
  ]
}

#let i18n-date-long(date) = context {
  let lang = text.lang
  if lang == "de" [
    #import "@preview/datify:1.3.0": display-date
    #display-date(date, pattern: "d. MMMM yyyy")
  ] else [
    #date.display("[month repr:long] [day], [year]")
  ]
}
