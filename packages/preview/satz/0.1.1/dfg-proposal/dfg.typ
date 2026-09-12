// DFG 53.01 (Sachbeihilfe) — Typst-Vorlage
// Formale Anforderungen:
//   - Arial 11pt, Zeilenabstand mind. 1.2
//   - Sections 1–3: max 17 Seiten, ab Section 4: max 8 Seiten
//   - Publikationsliste: Arial 9pt mindestens
//
// Basiert auf der LaTeX-Vorlage proposal.cls (scrartcl).

/// DFG form 53.01 — Project Description (Sachbeihilfe).
///
/// Title block, running header with page count, Arial 11pt — DFG wants it this way.
/// H1 is numbered "1", h2–h4 are not.
///
/// - applicant (content): your name and institution
/// - project (content): project title
/// - language (str): "german" or "english" — switches the header text
/// - max-pages (int): max pages shown in the header (17 or 8)
/// - doc (content): your proposal text
///
/// ```example
/// #show: dfg-proposal.with(
///   applicant: [Dr. Beispiel \\ Uni Musterstadt],
///   project: [Titel des Vorhabens],
///   language: "german",
/// )
/// = 1. Starting Point
/// ...
/// ```
#let dfg-proposal(
  applicant: [],
  project: [],
  language: "english",
  max-pages: 17,
  doc,
) = {
  // --- Sprachabhängige Strings ---
  let (form-num, form-date, lang-strings) = {
    if language == "german" {
      ("53.01", "09/25",
       (page: "Seite", of-max: "von max.",
        form: "DFG-Vordruck",
        title-line1: "Beschreibung des Vorhabens — Projektanträge",
        title-line2: "Beschreibung des Vorhabens"))
    } else {
      ("53.01", "09/25",
       (page: "page", of-max: "of max.",
        form: "DFG form",
        title-line1: "Project Description — Project Proposals",
        title-line2: "Project Description"))
    }
  }

  // --- Seitenlayout ---
  set page(
    paper: "a4",
    margin: (left: 2.5cm, right: 2cm, top: 2cm, bottom: 2cm),
    header: context {
      let (pg,) = counter(page).get()
      let left = lang-strings.form + " " + form-num + " — " + form-date
      let right = lang-strings.page + " " + str(pg) + " " + lang-strings.of-max + " " + str(max-pages)
      [
        #set text(font: "Inter", size: 8pt, weight: "regular")
        #left
        #h(1fr)
        #right
      ]
    },
    footer: none,
  )

  // --- Typografie ---
  set text(font: "Inter", size: 11pt)
  set par(leading: 0.5em, justify: true)

  // --- Überschriften ---
  set heading(numbering: "1")
  show heading.where(level: 2): set heading(numbering: none)
  show heading.where(level: 3): set heading(numbering: none)
  show heading.where(level: 4): set heading(numbering: none)

  show heading.where(level: 1): set text(size: 11pt, weight: "bold")
  show heading.where(level: 2): set text(size: 11pt, weight: "bold")
  show heading.where(level: 3): set text(size: 11pt, weight: "bold")
  show heading.where(level: 4): set text(size: 11pt, weight: "bold")

  show heading.where(level: 1): set block(above: 1.2em, below: 0.1em)
  show heading.where(level: 2): set block(above: 0.9em, below: 0.1em)
  show heading.where(level: 3): set block(above: 0.7em, below: 0.1em)
  show heading.where(level: 4): set block(above: 0.5em, below: 0.1em)

  set par(first-line-indent: 0pt, spacing: 0.5em)

  // --- Titelblock (wie \settitle) ---
  align(left)[
    #set text(size: 11pt, weight: "bold")
    #lang-strings.title-line1
    #parbreak()
    #applicant
    #parbreak()
    #project
    #parbreak()
    #line(length: 100%, stroke: 0.5pt)
    #parbreak()
    #lang-strings.title-line2
  ]

  v(1em)

  // --- Inhalt ---
  doc
}
