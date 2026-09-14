// pages/declaration.typ
// Ehrenwörtliche Erklärung mit 2025 KI-Klausel (Pflicht §3.11)
// CNT-01–05: Pflichtinhalt inkl. KI-Passagen-Kennzeichnung und Verantwortungsübernahme
// STR-10: Immer letztes Element des Dokuments
// declaration-lang: folgt entweder doc-lang oder eigenem Override

#import "@preview/linguify:0.5.0": linguify, linguify-raw
#import "../helper/signatures.typ": render-group-signature-warning, render-signature-fields

/// Render the declaration of authorship page.
///
/// - authors: array of (name, matrikel)
/// - decl-lang: "de" | "en" — language for the declaration text
/// - lang: "de" | "en" — document language (for labels if different)
/// - city: str — city for the place/date field (default "Berlin")
/// - group-signature: bool — true = all authors sign (default), false = only first author signs
#let render-declaration(authors, decl-lang, lang, city: "Berlin", group-signature: true, warnings: true) = {
  // Force declaration language for this page only
  set text(lang: decl-lang)

  heading(level: 1, numbering: none, outlined: true)[#linguify("declaration-title", lang: decl-lang)]

  v(1.5em)

  // Pflichttext §3.11 — aus l10n, mit Pluralisierung für Gruppen
  // linguify-raw returns the FTL string; eval() converts it to Typst content
  let decl-text = context eval(
    "[" + linguify-raw("declaration-text", args: (author-count: authors.len())) + "]"
  )
  set par(justify: true)
  decl-text

  v(3cm)

  render-group-signature-warning(group-signature, authors, warnings: warnings)
  render-signature-fields(authors, city, group-signature)
}
