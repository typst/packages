// ls3-uni-stuttgart-dissertation
//
// Doctoral dissertation template for LS3 at IWS, University of Stuttgart.
// Follows the Promotionsordnung der Universität Stuttgart of 01.03.2019
// and the Merkblatt über die äußere Form der Dissertationen. Two paper
// modes: "a4" is the manuscript submitted to the faculty (12pt, roughly
// 1.5 line spacing), "a5" is the Mitteilungsheft print layout.
//
// Usage. See template/main.typ.
//
// Parameters of dissertation().
//   title           content, dissertation title, may use \ for line breaks
//   author          string, full name
//   birthplace      string, "aus <birthplace>" on the title page
//   year            string, publication year
//   language        "english" or "german", body language
//   paper           "a4" (manuscript, default) or "a5" (print)
//   status          "submitted" (eingereichte, no exam date on the title
//                   page) or "accepted" (genehmigte, with exam date)
//   faculty         auto (Bau- und Umweltingenieurwissenschaften), or string
//   degree          "dr-ing-male" (default), "dr-ing-female",
//                   "dr-rer-nat-male", or "dr-rer-nat-female", e.g.
//                   "eines Doktor-Ingenieurs" or "einer Doktor-Ingenieurin"
//   degree-phrase   content override for the whole degree wording
//   awarded-by      content override for the whole awarding phrase
//   simtech         bool, default false, adds "und dem Stuttgart Center
//                   for Simulation Science" after the faculty
//   hauptberichter  string
//   mitberichter    tuple of strings, listed below one "Mitberichter:"
//   exam-date       string, Tag der mündlichen Prüfung, shown only when
//                   status is "accepted"
//   institute       auto (IWS) or string, without "der Universität Stuttgart"
//   abstract-en     content, required, English Abstract
//   abstract-de     content, required, German Zusammenfassung
//                   Fakultät 2 asks for two to four pages each. The
//                   English one comes first, as in the IWS Hefte.
//   vlb             none, or dict (series:, heft:, isbn:, printer:,
//                   author-sort:, publisher:) for the VLB/D93 page of the
//                   Mitteilungsheft. Adds two blank pages after the title
//                   page, the second one for the series title page from
//                   the institute's Word template, then the VLB page.
//                   author-sort defaults to "Nachname, Vorname" split at
//                   the last space.
//   danksagung      none, or content
//   declaration     bool, adds the Erklärung page per § 6 (2), default false
//   abbreviations   none, or content
//   notation        none, or content
//   summary         none, or content, optional extended English Summary
//   zusammenfassung none, or content, optional extended German Zusammenfassung
//                   Neither is required, the abstracts cover § 2 (3), and
//                   none of the IWS Hefte 286 to 319 has one.
//                   The summary in the other language goes into the front
//                   matter before the text, the one in the thesis language
//                   follows the last chapter as an unnumbered chapter.
//   appendix        none, or content, lettered chapters after the
//                   bibliography
//   lebenslauf      none, or content, one page max per § 13 (3). Printed
//                   only while status is "submitted". The faculty wants
//                   it with the submitted copies, and none of the
//                   published IWS Hefte 286 to 319 contains one.
//   bib             none, or a pre-constructed bibliography(...) element
//   body-font       "sans" (default) or "serif" (New Computer Modern, as
//                   in most IWS Hefte)
//   heading-rule    false (default), or true for a thin mittelblau rule
//                   below every chapter-level heading

#import "src/style.typ": apply-style, metrics, two-sided-header-footer
#import "src/title-page.typ": title-page, degree-phrases, degree-message
#import "src/vlb.typ": vlb-page
#import "src/front-matter.typ": (
  abstract-de-section, abstract-en-section, danksagung-section,
  erklaerung-section, abbreviations-section, notation-section,
  toc, lof, lot, lol,
)
#import "src/back-matter.typ": (
  summary-section, zusammenfassung-section, appendix-section, lebenslauf-section,
)

// Public dissertation() show rule.
#let dissertation(
  title: [],
  author: "",
  birthplace: "",
  year: "",
  language: "english",
  paper: "a4",
  status: "submitted",
  faculty: auto,
  degree: "dr-ing-male",
  degree-phrase: auto,
  awarded-by: auto,
  simtech: false,
  hauptberichter: "",
  mitberichter: (),
  exam-date: "",
  institute: auto,
  abstract-de: none,
  abstract-en: none,
  vlb: none,
  danksagung: none,
  declaration: false,
  abbreviations: none,
  notation: none,
  summary: none,
  zusammenfassung: none,
  appendix: none,
  lebenslauf: none,
  bib: none,
  body-font: "sans",
  heading-rule: false,
  body,
) = {
  assert(language == "english" or language == "german", message: "language must be 'english' or 'german'")
  assert(paper == "a4" or paper == "a5", message: "paper must be 'a4' or 'a5'")
  assert(status == "submitted" or status == "accepted", message: "status must be 'submitted' or 'accepted'")
  assert(body-font == "sans" or body-font == "serif", message: "body-font must be 'sans' or 'serif'")
  assert(type(heading-rule) == bool, message: "heading-rule must be true or false")
  assert(
    degree-phrase != auto or degree in degree-phrases,
    message: degree-message,
  )
  assert(
    abstract-de != none and abstract-en != none,
    message: "Promotionsordnung § 2 (3): both abstract-en (Abstract) and abstract-de (Zusammenfassung) are required",
  )
  assert(type(simtech) == bool, message: "simtech must be true or false"
  )

  let resolved-institute = if institute == auto {
    "Institut für Wasser- und Umweltsystemmodellierung"
  } else {
    institute
  }

  let resolved-faculty = if faculty == auto { "Bau- und Umweltingenieurwissenschaften" } else { faculty }

  set document(title: if type(title) == str { title } else { "" }, author: author)
  set text(lang: if language == "german" { "de" } else { "en" })

  // Page 1. Title page per Anlage 1. Counted but unnumbered; the page
  // count runs continuously from here, as the Merkblatt requires.
  title-page(
    title: title,
    author: author,
    birthplace: birthplace,
    status: status,
    faculty: resolved-faculty,
    degree: degree,
    degree-phrase: degree-phrase,
    awarded-by: awarded-by,
    simtech: simtech,
    hauptberichter: hauptberichter,
    mitberichter: mitberichter,
    exam-date: exam-date,
    institute: resolved-institute,
    year: year,
    paper: paper,
  )

  // Pages 2 to 4, print publication only. Blank verso, blank recto for
  // the series title page, VLB/D93 page on the verso behind it.
  if vlb != none {
    vlb-page(
      title: title,
      author: author,
      institute: resolved-institute,
      year: year,
      paper: paper,
      ..vlb,
    )
  }

  // Apply body styles from here on.
  show: apply-style.with(paper: paper, body-font: body-font, heading-rule: heading-rule)

  // Front matter. Roman numerals continue the absolute page count, no
  // counter reset: the title page is page i, so the first front-matter
  // page shows its true roman position. Order as in the recent IWS
  // Hefte: contents, lists of figures, tables, and listings,
  // abbreviations, notation, English abstract, German Zusammenfassung,
  // then the optional extended summary in the other language.
  [
    #set page(numbering: "I")
    #if danksagung != none { danksagung-section(danksagung, language: language) }
    #if declaration { erklaerung-section() }
    #toc(language: language)
    #lof(language: language)
    #lot(language: language)
    #lol(language: language)
    #if abbreviations != none { abbreviations-section(abbreviations, language: language) }
    #if notation != none { notation-section(notation, language: language) }
    #abstract-en-section(abstract-en)
    #abstract-de-section(abstract-de)
    #if language == "german" {
      if summary != none { summary-section(summary) }
    } else {
      if zusammenfassung != none { zusammenfassung-section(zusammenfassung) }
    }
  ]

  // Main matter. Arabic numbering restarting at 1. The marker tells the
  // header that a blank page before chapter 1 is blank.
  [#metadata(none) <ls3-chapter-end>]
  pagebreak(to: "odd")
  [
    #set page(numbering: "1")
    #counter(page).update(1)
    #body
    #if language == "german" {
      if zusammenfassung != none { zusammenfassung-section(zusammenfassung) }
    } else {
      if summary != none { summary-section(summary) }
    }
    #if bib != none { bib }
    #if appendix != none { appendix-section(appendix) }
    // Lebenslauf only in the submitted version, never in the print.
    #if lebenslauf != none and status == "submitted" {
      lebenslauf-section(lebenslauf, language: language)
    }
  ]
}
