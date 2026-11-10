// Labels in English and Danish.

#let _labels = (
  en: (
    university: "University of Copenhagen",
    contents: "Contents",
    list-of-figures: "List of figures",
    list-of-tables: "List of tables",
    abstract: "Abstract",
    preface: "Preface",
    references: "References",
    appendix: "Appendix",
    chapter: "Chapter",
    section: "Section",
    faculty: "Faculty",
    department: "Department",
    author: "Author",
    authors: "Authors",
    title: "Title",
    subtitle: "Subtitle",
    description: "Description",
    advisor: "Advisor",
    advisors: "Advisors",
    submitted: "Submitted",
    characters: "Characters (incl. spaces)",
    normal-pages: "normal pages",
    info-heading: "Thesis information",
    months: ("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"),
  ),
  da: (
    university: "Københavns Universitet",
    contents: "Indhold",
    list-of-figures: "Figurer",
    list-of-tables: "Tabeller",
    abstract: "Resumé",
    preface: "Forord",
    references: "Litteratur",
    appendix: "Appendiks",
    chapter: "Kapitel",
    section: "Afsnit",
    faculty: "Fakultet",
    department: "Institut",
    author: "Forfatter",
    authors: "Forfattere",
    title: "Titel",
    subtitle: "Undertitel",
    description: "Beskrivelse",
    advisor: "Vejleder",
    advisors: "Vejledere",
    submitted: "Afleveret",
    characters: "Anslag (inkl. mellemrum)",
    normal-pages: "normalsider",
    info-heading: "Oplysninger",
    months: ("januar", "februar", "marts", "april", "maj", "juni", "juli", "august", "september", "oktober", "november", "december"),
  ),
)

#let languages = _labels.keys()

/// Look up a label. Unknown languages fall back to English.
#let t(lang, key) = _labels.at(lang, default: _labels.en).at(key)

/// Format a date the way each language writes it:
/// "15 October 2026" / "15. oktober 2026".
/// Content and strings are passed through unchanged.
#let format-date(lang, date) = {
  if type(date) != datetime { return date }
  let month = t(lang, "months").at(date.month() - 1)
  if lang == "da" {
    str(date.day()) + ". " + month + " " + str(date.year())
  } else {
    str(date.day()) + " " + month + " " + str(date.year())
  }
}
