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
  "degree-goal-prefix": (
    de: "zur Erlangung des akademischen Grades",
    en: "to obtain the academic degree of",
  ),
  "degree-bachelor": (
    de: "Bachelor of Science in Engineering",
    en: "Bachelor of Science in Engineering",
  ),
  "degree-master": (
    de: "Master of Science in Engineering",
    en: "Master of Science in Engineering",
  ),
  "license-cc": (
    de: [Diese Arbeit wird unter den Bedingungen der Creative Commons Lizenz _Attribution-NonCommercial-NoDerivatives 4.0 International_ (CC BY-NC-ND 4.0) veröffentlicht -- siehe #link("https://creativecommons.org/licenses/by-nc-nd/4.0/")[https://creativecommons.org/licenses/by-nc-nd/4.0/].],
    en: [This work is published under the conditions of the Creative Commons License _Attribution-NonCommercial-NoDerivatives 4.0 International_ (CC BY-NC-ND 4.0) -- see #link("https://creativecommons.org/licenses/by-nc-nd/4.0/")[https://creativecommons.org/licenses/by-nc-nd/4.0/].],
  ),
  "license-strict": (
    de: [Alle Rechte vorbehalten.],
    en: [All rights reserved.],
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
    de: "Ich erkläre eidesstattlich, dass ich die vorliegende Arbeit selbstständig und ohne fremde Hilfe verfasst, andere als die angegebenen Quellen nicht benutzt und die den benutzten Quellen entnommenen Stellen als solche gekennzeichnet habe. Die Arbeit wurde bisher in gleicher oder ähnlicher Form keiner anderen Prüfungsbehörde vorgelegt. Die vorliegende, gedruckte Arbeit ist mit dem elektronisch übermittelten Textdokument identisch.",
    en: "I hereby declare and confirm that this thesis is entirely the result of my own original work. Where other sources of information have been used, they have been indicated as such and properly acknowledged. I further declare that this or similar work has not been submitted for credit elsewhere. This printed copy is identical to the submitted electronic version.",
  ),
  "figure": (
    de: "Abbildung",
    en: "Figure",
  ),
  "table": (
    de: "Tabelle",
    en: "Table",
  ),
  "raw": (
    de: "Programm",
    en: "Program",
  ),
  "equation": (
    de: "Gleichung",
    en: "Equation",
  ),
  "ref-figure": (
    de: "Abb.",
    en: "Fig.",
  ),
  "ref-table": (
    de: "Tab.",
    en: "Tab.",
  ),
  "ref-raw": (
    de: "Prog.",
    en: "Prog.",
  ),
  "ref-equation": (
    de: "Gl.",
    en: "Eq.",
  ),
  "ref-section": (
    de: "Abschn.",
    en: "Sec.",
  ),
  "abbreviations-table-caption": (
    de: "Abkürzungsverzeichnis",
    en: "List of abbreviations",
  ),
)

#let i18n-translation(key, lang) = {
  let translations = keys-to-lang.at(key)
  let value = translations.at(lang, default: translations.at("en"))
  value
}

#let i18n(key) = context {
  let lang = text.lang
  let value = i18n-translation(key, lang)
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

#let _austrian-months = (
  "Jänner",
  "Februar",
  "März",
  "April",
  "Mai",
  "Juni",
  "Juli",
  "August",
  "September",
  "Oktober",
  "November",
  "Dezember",
)

#let i18n-date-short(date) = context {
  let lang = text.lang
  if lang == "de" [
    #date.display("[day].[month].[year]")
  ] else [
    #date.display("[year]-[month]-[day]")
  ]
}

#let i18n-date-month-year(date) = context {
  let lang = text.lang
  if lang == "de" [
    #_austrian-months.at(date.month() - 1) #date.year()
  ] else [
    #date.display("[month repr:long] [year]")
  ]
}

#let i18n-date-long(date) = context {
  let lang = text.lang
  if lang == "de" [
    #date.day(). #_austrian-months.at(date.month() - 1) #date.year()
  ] else [
    #date.display("[month repr:long] [day], [year]")
  ]
}
