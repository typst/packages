// Fixed strings of the template in English and German.
// The document language (`lang` parameter of the template) selects the set.

#let strings = (
  en: (
    contents: "Contents",
    list-of-figures: "List of Figures",
    list-of-tables: "List of Tables",
    list-of-listings: "List of Listings",
    list-of-algorithms: "List of Algorithms",
    bibliography: "Bibliography",
    abbreviations: "List of Abbreviations",
    glossary: "Glossary",
    abstract: "Abstract",
    acknowledgements: "Acknowledgements",
    declaration: "Declaration",
    appendix: "Appendix",
    part: "Part",
    chapter: "Chapter",
    section: "Section",
    figure: "Figure",
    table: "Table",
    listing: "Listing",
    algorithm: "Algorithm",
    equation: "Equation",
    challenge: "Challenge",
    objective: "Objective",
    definition: "Definition",
    corollary: "Corollary",
    theorem: "Theorem",
    lemma: "Lemma",
    proposition: "Proposition",
    example: "Example",
    remark: "Remark",
    cited-on-page: "cited on page",
    cited-on-pages: "cited on pages",
    supervisor: "Supervisor",
    supervisors: "Supervisors",
    advisor: "Advisor",
    advisors: "Advisors",
    defense: "Day of Defense",
    transparency: "Transparency Statement",
    copyright: "Copyright",
    degree-for: "for the degree of",
    date-format: "[month repr:long] [day padding:none], [year]",
  ),
  de: (
    contents: "Inhaltsverzeichnis",
    list-of-figures: "Abbildungsverzeichnis",
    list-of-tables: "Tabellenverzeichnis",
    list-of-listings: "Listingverzeichnis",
    list-of-algorithms: "Algorithmenverzeichnis",
    bibliography: "Literaturverzeichnis",
    abbreviations: "Abkürzungsverzeichnis",
    glossary: "Glossar",
    abstract: "Zusammenfassung",
    acknowledgements: "Danksagung",
    declaration: "Erklärung",
    appendix: "Anhang",
    part: "Teil",
    chapter: "Kapitel",
    section: "Abschnitt",
    figure: "Abbildung",
    table: "Tabelle",
    listing: "Listing",
    algorithm: "Algorithmus",
    equation: "Gleichung",
    challenge: "Herausforderung",
    objective: "Ziel",
    definition: "Definition",
    corollary: "Korollar",
    theorem: "Satz",
    lemma: "Lemma",
    proposition: "Proposition",
    example: "Beispiel",
    remark: "Bemerkung",
    cited-on-page: "zitiert auf Seite",
    cited-on-pages: "zitiert auf den Seiten",
    supervisor: "Betreuer",
    supervisors: "Betreuer",
    advisor: "Gutachter",
    advisors: "Gutachter",
    defense: "Tag der mündlichen Prüfung",
    transparency: "Transparenzerklärung",
    copyright: "Copyright",
    degree-for: "zur Erlangung des akademischen Grades",
    date-format: "[day padding:none]. [month repr:long] [year]",
  ),
)

// Month names for datetime.display are always English in Typst, so German
// dates are assembled by hand.
#let months-de = (
  "Januar", "Februar", "März", "April", "Mai", "Juni",
  "Juli", "August", "September", "Oktober", "November", "Dezember",
)

// Formats a datetime in the given language (content is passed through).
#let format-date(date, lang) = {
  if type(date) != datetime { return date }
  if lang == "de" {
    [#date.day(). #months-de.at(date.month() - 1) #date.year()]
  } else {
    date.display(strings.en.date-format)
  }
}

// Translated term for the language of the surrounding text (contextual
// content, e.g. for figure supplements).
#let tr(key) = context strings.at(text.lang, default: strings.en).at(key)
