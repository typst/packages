#import "@preview/i-figured:0.2.4"
#import "@preview/numbly:0.1.0": numbly
#import "@preview/theorion:0.4.0": *
#import "../utils/numbering.typ": *
#import "../utils/page.typ": *

/// Set up main matter environment
///
/// -> content
#let mainmatter(
  /// Type of thesis
  ///
  /// -> "doctor" | "master" | "bachelor"
  doctype: "doctor",
  /// Language of the thesis
  ///
  /// -> "en" | "zh" | "pt"
  lang: "en",
  /// -> content
  body,
) = {
  set page(numbering: "1")
  counter(page).update(1)
  counter(heading).update(0)
  // Page number at center top, omitted at chapter/bib/appendix pages
  set page(
    header: context {
      if is-chapter-page() { none } else { h(1fr) + counter(page).display() + h(1fr) }
    },
    footer: none,
    numbering: none,
  ) if doctype == "master"
  // Set chapter prefix
  set heading(numbering: numbly(
    pattern-heading-first-level(lang: lang, supplement: [Chapter]) + if doctype == "master" { ":" },
  ))
  // Set chapter supplement for identification in doc.typ
  show heading.where(level: 1): set heading(supplement: [Chapter])

  // i-figured settings
  show heading: i-figured.reset-counters
  show math.equation: i-figured.show-equation

  // Theorem environment setup
  show: show-theorion
  set-inherited-levels(1)
  set-theorion-numbering("1.1")

  body
}
