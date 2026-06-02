// HWR Berlin — Typst Template
// Compliant with HWR Richtlinien January 2025 (all cohorts / Wirtschaftsinformatik)
//
// Public API:
//   #show: hwr.with(...)
//
// All parameters: see requirements/api-design.md

#import "@preview/linguify:0.5.0": linguify, linguify-raw, set-database, load-ftl-data
#import "@preview/glossarium:0.5.10": make-glossary, print-glossary, gls, glspl

#import "helper/date.typ": format-date
#import "helper/abbreviations.typ": _abk-dict, setup-abbreviations, abk
#import "pages/confidentiality.typ": render-confidentiality
#import "pages/title_page.typ": render-title-page
#import "pages/abstract.typ": render-abstract
#import "pages/indices.typ": render-indices
#import "pages/declaration.typ": render-declaration
#import "pages/appendix.typ": render-appendix

// ---------------------------------------------------------------------------
// Validation helpers
// ---------------------------------------------------------------------------

#let _assert-not-none(value, name) = {
  assert(value != none, message: name + " ist ein Pflichtfeld und darf nicht none sein.")
}

#let _assert-doc-type(doc-type) = {
  let valid = ("ptb-1", "ptb-2", "ptb-3", "hausarbeit", "studienarbeit", "bachelorarbeit")
  assert(
    doc-type in valid,
    message: "doc-type \"" + doc-type + "\" ist ungültig. Erlaubte Werte: " + valid.join(", "),
  )
}

#let _validate(doc-type, title, authors, supervisor, company, first-examiner, second-examiner) = {
  _assert-doc-type(doc-type)
  _assert-not-none(title, "title")
  assert(authors.len() > 0, message: "authors muss mindestens einen Eintrag enthalten.")

  let needs-supervisor = doc-type in ("ptb-1", "ptb-2", "ptb-3", "hausarbeit", "studienarbeit")
  if needs-supervisor {
    assert(
      supervisor != none,
      message: "supervisor ist Pflicht für doc-type \"" + doc-type + "\".",
    )
    assert(
      company != none,
      message: "company ist Pflicht für doc-type \"" + doc-type + "\".",
    )
  }

  if doc-type == "bachelorarbeit" {
    assert(
      first-examiner != none,
      message: "first-examiner ist Pflicht für bachelorarbeit.",
    )
    assert(
      second-examiner != none,
      message: "second-examiner ist Pflicht für bachelorarbeit.",
    )
  }
}

// ---------------------------------------------------------------------------
// Main template function
// ---------------------------------------------------------------------------

/// Main entry point for the HWR Berlin Typst template.
///
/// Usage:
///   #show: hwr.with(
///     doc-type: "ptb-1",
///     title: "Mein Titel",
///     authors: ((name: "Max Mustermann", matrikel: "12345678"),),
///     supervisor: "Prof. Dr. Muster",
///     company: "Muster GmbH",
///   )
///
/// See requirements/api-design.md for the full parameter reference.
#let hwr(
  // === PFLICHTFELDER ===
  doc-type: none,
  title: none,
  authors: (),

  // === BEDINGT PFLICHT (je nach doc-type) ===
  supervisor: none,
  company: none,
  first-examiner: none,
  second-examiner: none,

  // === OPTIONALE FELDER ===
  lang: "de",
  field-of-study: "Wirtschaftsinformatik",
  cohort: none,
  semester: none,
  date: auto,

  abstract: none,
  confidential: none,

  abbreviations: (:),
  glossary: (),
  ai-tools: (),

  chapters: (),
  appendix: (),
  show-appendix-toc: false,

  bibliography: none,
  citation-style: "apa",

  heading-depth: 4,
  declaration-lang: auto,
  city: "Berlin",
  group-signature: auto,

  // show-rule body (passed automatically by #show: hwr.with(...))
  body,
) = {

  // --- Validation ---
  _validate(doc-type, title, authors, supervisor, company, first-examiner, second-examiner)

  // --- Resolve date ---
  let resolved-date = format-date(date, lang: lang)

  // --- Resolve declaration language ---
  let decl-lang = if declaration-lang == auto { lang } else { declaration-lang }

  // --- Resolve group-signature ---
  // auto = all authors sign (true); explicit bool overrides
  let resolved-group-sig = if group-signature == auto { true } else { group-signature }

  // --- linguify: configure l10n database ---
  // load-ftl-data returns a Typst script string; eval() executes it to produce the dict.
  // set-database() registers the dict as a global state update (not a show rule).
  set-database(eval(load-ftl-data("./l10n", ("de", "en"))))

  // --- Global page setup ---
  // FMT-20–23: Margins.
  // FMT-34: Page number at top-right (HWR specifies "oben").
  //         Typst places numbering via number-align; top + right puts it in the header area.
  set page(
    paper: "a4",
    margin: (top: 30mm, right: 35mm, bottom: 20mm, left: 21mm),
    numbering: none,
    number-align: top + right,
  )

  // --- Global text & paragraph setup ---
  set text(font: "Times New Roman", size: 12pt, lang: lang)

  // 1.5-line spacing (FMT-05):
  // leading = space between baselines beyond font size.
  // For 12pt at 1.5×: target baseline-to-baseline = 18pt.
  // Typst leading is extra space; set to 0.65em ≈ 7.8pt → total ≈ 19.8pt (close to 18pt).
  // block spacing = one full line between paragraphs (matches Word "1.5 line" paragraph spacing).
  set par(justify: true, leading: 0.65em)
  set block(spacing: 1.5em)

  // FMT-06: Footnotes single-spaced (exception to 1.5× rule)
  show footnote.entry: set par(leading: 0.4em)
  show footnote.entry: set text(size: 10pt)

  // FMT-03/04: Captions 10pt
  show figure.caption: set text(size: 10pt)

  // FMT-41 reinterpretation: The HWR guideline says tables must have "Überschriften" (header rows),
  // meaning table.header() — not figure caption position. Captions go below like figures (FMT-42).
  // FMT-42: Figure captions appear below ("Unterschrift" = below, per guideline wording).
  // FMT-40: Figures and tables centered
  set figure(placement: none)
  show figure.where(kind: image): set figure.caption(position: bottom)
  show figure.where(kind: table): set figure.caption(position: bottom)

  // FMT-46: Tables fully stroked
  set table(stroke: 0.5pt)

  // FMT-11: No first-line indent after headings; typographic spacing above/below.
  // More space before a heading (signals start of new section) than after.
  // H1: most prominent; H2: moderate; H3+: subtle.
  // below is generous (>= 1 line) so text does not feel cramped under a heading.
  show heading.where(level: 1): it => {
    v(1.8em, weak: true)
    it
    v(0.8em, weak: true)
    set par(first-line-indent: 0pt)
  }
  show heading.where(level: 2): it => {
    v(1.2em, weak: true)
    it
    v(0.6em, weak: true)
    set par(first-line-indent: 0pt)
  }
  show heading: it => {
    v(1.0em, weak: true)
    it
    v(0.5em, weak: true)
    set par(first-line-indent: 0pt)
  }

  // Heading numbering: decimal system "1.1.1" up to heading-depth (STR-20, STR-21)
  // Headings deeper than heading-depth remain unnumbered.
  set heading(numbering: (..nums) => {
    let n = nums.pos()
    if n.len() <= heading-depth {
      n.map(str).join(".") + "  "
    }
  })

  // TOC depth follows heading-depth
  set outline(depth: heading-depth, indent: 1em)

  // --- glossarium setup (must be before body) ---
  if glossary.len() > 0 {
    show: make-glossary
  }

  // --- abbreviations setup ---
  // Register central abbreviation dict so abk() can look up full forms
  setup-abbreviations(abbreviations)

  // ---------------------------------------------------------------------------
  // Document structure
  // ---------------------------------------------------------------------------

  // 1. Sperrvermerk (vor Deckblatt, keine Seitennummer, nicht in Zählung — CNT-20, STR-01)
  if confidential != none {
    render-confidentiality(confidential, company, title, authors, resolved-date, lang, city: city, group-signature: resolved-group-sig)
  }

  // 2. Deckblatt: Seitenzähler startet bei I (röm.), aber Nummer nicht sichtbar (STR-02)
  counter(page).update(1)
  set page(numbering: none)
  render-title-page(
    doc-type, title, authors,
    supervisor, company, first-examiner, second-examiner,
    field-of-study, cohort, semester, resolved-date, lang,
  )

  // 3. Vorspann: Römische Seitennummerierung sichtbar (STR-03 ff.)
  set page(numbering: "I")

  // 3a. Abstract (optional, eigene Seite, kein TOC-Eintrag — api-design §8b)
  if abstract != none {
    render-abstract(abstract, lang)
  }

  // 3b. Verzeichnisse: TOC, Abkürzungen, Abb.-/Tab.-Verzeichnis (STR-03–STR-06)
  render-indices(abbreviations, lang)

  // 4. Haupttext: Arabische Seitennummerierung ab 1 (STR-07)
  counter(page).update(1)
  set page(numbering: "1")

  // chapters: array of included content (api-design §11)
  // User passes: chapters: (include("kapitel/01.typ"), include("kapitel/02.typ"), ...)
  // The include() calls are evaluated in main.typ (relative to main.typ), so paths work correctly.
  // pagebreak(weak: true): new page before each chapter; weak prevents double-break if chapter
  // itself starts with #pagebreak().
  for ch in chapters {
    pagebreak(weak: true)
    ch
  }

  body

  // 5. Glossar (nach Haupttext, vor Literaturverzeichnis — STR-11)
  if glossary.len() > 0 {
    pagebreak(weak: true)
    heading(level: 1, numbering: none, outlined: true)[#linguify("glossary-title")]
    print-glossary(glossary)
    pagebreak()
  }

  // 6. Literaturverzeichnis (STR-08)
  if bibliography != none {
    pagebreak(weak: true)
    bibliography
  }

  // 7. Anhang: user-Einträge + KI-Verzeichnis automatisch als letztes Item (STR-09, STR-12)
  if appendix.len() > 0 or ai-tools.len() > 0 {
    pagebreak(weak: true)
    render-appendix(appendix, ai-tools, lang, show-toc: show-appendix-toc)
  }

  // 8. Ehrenwörtliche Erklärung (immer zuletzt — STR-10)
  render-declaration(authors, decl-lang, lang, city: city, group-signature: resolved-group-sig)
}

// ---------------------------------------------------------------------------
// Re-exports for use in chapter files
// ---------------------------------------------------------------------------
// Users import these from lib.typ in their kapitel/ files:
//   #import "@preview/wi-hwr-berlin:0.1.0": abk, gls, glspl

