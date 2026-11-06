#import "@preview/i-figured:0.2.4"
#import "@preview/numbly:0.1.0": numbly
#import "@preview/theorion:0.4.0": *
#import "../utils/numbering.typ": *

/// Set up appendix environment.
///
/// *Example:*
///
/// ```example
/// >>> #set heading(outlined: false)
/// #show: appendix
/// = Appendices <appendices>
/// == What do I put in here <section>
/// Material that is related to, but\ not appropriate for, inclusion in\ the text, can be placed in the\ appendices. They must meet the\ formatting requirements described\ in this document.
/// ```
///
/// -> content
#let appendix(
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
  counter(heading).update(0)
  // Set appendix prefix
  set heading(numbering: numbly(
    pattern-heading-first-level(lang: lang, supplement: [Appendix]) + if doctype == "master" { ":" },
    "{1:A}.{2}.",
  ))
  // Set appendix supplement for identification in doc.typ
  show heading.where(level: 1): set heading(supplement: [Appendix])

  // i-figured settings
  show heading: i-figured.reset-counters
  show math.equation: i-figured.show-equation.with(numbering: "(A.1)")

  // Theorem environment setup
  show: show-theorion
  set-inherited-levels(1)
  set-theorion-numbering("A.1")

  body
}
