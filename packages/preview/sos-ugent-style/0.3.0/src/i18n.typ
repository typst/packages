#let langSwitch(dict) = context {
  // TODO: maybe use more modern practices? linguify package, or .at() call on dict
  for (k, v) in dict {
    if k == text.lang {
      return v
      break
    }
  }
  panic("i18n: language is set to '" + text.lang
       +"', but did not find a corresponding key in the given dictionary: " + repr(dict)
       +". Maybe contribute a translation?")
}

// https://styleq.ugent.be/basisprincipes/taal-en-terminologie.html
#let ugent = langSwitch(
  ("en" : [Ghent University],
   "nl" : [Universiteit Gent],
   "fr" : [Université de Gand],
   "de" : [Universität Gent],))


// TODO: Dit is een voorbeeld.
#let year = langSwitch(("en" : [year], "nl": [Jaar]))
#let Preface = langSwitch(
  ("en" : [Preface],
   "nl" : [Voorwoord],))
#let Acknowledgements = langSwitch(
  ("en" : [Acknowledgements],
   "nl" : [Dankbetuiging],))
#let Permission-loan = langSwitch(
  ("en" : [Permission of use on loan],
   "nl" : [Toelating tot bruikleen],))
#let Remarks-dissertation = langSwitch(
  ("en" : [Remarks on the master's dissertation],
   "nl" : [Opmerkingen omtrent de masterproef],))

#let table_of_contents = langSwitch(
  ("en" : [Table of contents],
   "nl" : [Inhoudsopgave],))
#let list_figures = langSwitch(
  ("en" : [List of figures],
   "nl" : [Lijst van figuren],))
#let list_tables = langSwitch(
  ("en" : [List of tables],
   "nl" : [Lijst van tabellen],))
#let list_equations = langSwitch(
  ("en" : [List of equations],
   "nl" : [Lijst van formules],))
#let list_listings = langSwitch(
  ("en" : [List of listings],
   "nl" : [Lijst van codefragmenten],))
#let list_abbrev = langSwitch(
  ("en" : [List of abbreviations]/*Acronyms are a type of abbreviation*/,
   "nl" : [Lijst van afkortingen]/*Afkortingenlijst*/,))
#let list_glossary = langSwitch(
  ("en" : [Glossary],
   "nl" : [Verklarende woordenlijst]/*Begrippenlijst*/,))
#let list_todos = langSwitch(
  ("en" : "List of todo's",
   "nl" : "Lijst van Todo's",))

#let Abstract = langSwitch(
  ("en" : [Abstract],
   "nl" : [Abstract],))
#let Keywords = langSwitch(
  ("en" : [Keywords],
   "nl" : [Kernwoorden],))

// Bibliography IS NOT a reference list
#let reference_list = langSwitch(
  ("en" : [Reference list],
   "nl" : [Literatuurlijst]/*Referentielijst*/,))
#let bibliography = langSwitch(
  ("en" : [Bibliography],
   "nl" : [Bibliografie],))

// Needed to implement correct referencing to chapters & sections in both languages.
// Typst 'auto' only uses 'Section' in English and 'Hoofdstuk' in Dutch,
// without regards for the actual level of the heading being referenced,
// nor if the capital is needed.
// Since we cannot correctly capitalize inside a context, use both versions
// (not very convenient)
#let ref-chapter = langSwitch(
  // Starts on a new page
  ("en" : "chapter",
   "nl" : "hoofdstuk",))
#let ref-Chapter = langSwitch(
  ("en" : "Chapter",
   "nl" : "Hoofdstuk",))
// Scoren met je scriptie, Leen Pollefliet, 2022, pg. 149:
// Let op: volgende benamingen zijn verwarrend. Het Engelse woord '_section_' is
// in het Nederlands een 'paragraaf' en het Engelse '_paragraph_' is in het
// Nederlands een 'alinea'.
// Hoofdstukken -> subhoofdstukken -> paragrafen (grote tekstblokken)
// -> alinea's -> zinnen
#let ref-section = langSwitch(
  // Includes sub(sub)sections when referencing
  ("en" : "section",
   "nl" : "paragraaf" /*In dutch, § can be used to refer*/ ,))
#let ref-Section = langSwitch(
  ("en" : "Section",
   "nl" : "Paragraaf",))
#let ref-annex = langSwitch(
  // When referencing a heading inside the appendix
  ("en" : "annex",
   "nl" : "bijlage" /*annex, appendix*/,))
#let ref-Annex = langSwitch(
  ("en" : "Annex",
   "nl" : "Bijlage",))
// TODO: Possible future additions:
// part (-1 in LaTeX)
// "en" : "paragraph", "nl" : "alinea"
// They actually don't have a heading normally...
// <p> in HTML and `par` in Typst

// Page number
// Needed as a function, because the character 'a' has a special meaning
// in a numbering string...
// Already used within context, so skip the langSwitch
#let page-numbering-function = (
   "en" : (pg, total) => [#pg of #total],
   "nl" : (pg, total) => [#pg van #total],)

// Title page
#let word-count = langSwitch(
  ("en" : "Word count",
   "nl" : "Aantal woorden",))
#let student-number = langSwitch(
  ("en" : "Student number",
   "nl" : "Studentennummer",))
#let supervisor = langSwitch(
  ("en" : "Supervisor",
   "nl" : "Promotor",))
#let commissaris = langSwitch(
  ("en-TODO" : "The commissaris (member of assessment committee) has no translation yet",
   "nl" : "Commissaris",))
#let supervisors = langSwitch( // Quick fix for plural. TODO: Can be generalized.
  ("en" : "Supervisors",
   "nl" : "Promotoren",))
#let academic-year = langSwitch(
  ("en" : "Academic year",
   "nl" : "Academiejaar",))
