
#import "@preview/rubber-article:0.5.0": *
#import "@preview/covered-cs-thesis:0.1.5": *

// === Settings ===

// Language of your thesis (either "de" or "en").
// This switches in what language your cover is displayed.
#let language = "en"
// #let language = "de"

// Title of your thesis
#let title = "What are ducks?"
// #let title = "Was sind Enten?"


// LaTeX like article style
#show: article.with(
  cols: none,
  eq-chapterwise: true,
  eq-numbering: "(1.1)",
  header-display: true,
  header-title: title,
  lang: language,
  page-margins: 1.75in,
  page-paper: "a4",
)

// Cover of your thesis (English)
#cs-thesis-cover(
  // see above
  title: title,
  language: language,

  /// Your name [string]
  author: "Max Mustermann",
  /// Your matriculation number (Matrikelnummer) [string]
  matriculation-number: "12345678",
  /// What your thesis is (bachelor/master) [string]
  thesis-type: "Bachelor's Thesis",
  /// Your university [string]
  university: "Heidelberg University",
  /// Your institute [string]
  institute: "Institut für Informatik",
  /// The working group that supervises your thesis [string]
  working-group: "Duck Feather Laboratory",
  /// Your supervisor [string]
  supervisor: "Professor Einstein",
  /// The date of your submission [anything]
  date-submission: [#datetime.today().display()],
)

// Cover of your thesis (German)
//
// #cs-thesis-cover(
//   title: title,
//   language: language,

//   author: "Max Mustermann",
//   matriculation-number: "12345678",
//   thesis-type: "Bachelor-Arbeit",
//   university: "Universität Heidelberg",
//   institute: "Institut für Informatik",
//   working-group: "Enten Labor",
//   supervisor: "Professor Einstein",
//   date-submission: [#datetime.today().display("[day].[month].[year]")],
// )


// === Abstracts in german and english ===
// Your need a summary in german and english, each one page.

#heading(numbering: none, outlined: false)[Zusammenfassung]

#lorem(300)

#pagebreak()

#heading(numbering: none, outlined: false)[Abstract]

#lorem(300)

#pagebreak()


// === Outline ===

// Page numbering is disabled by cs-thesis-cover and needs to be reenabled.
#set page(numbering: "1")

#outline()

#pagebreak()

// === Content ===

= Chapters of the thesis

#lorem(23)

== Example Subchapter

#quote(attribution: <test>)[Ducks are very sweet.]

#pagebreak()

// === Bibliography ===

#bibliography("bibliography.yaml", full: true)
