// HWR Berlin — Typst Template
// Compliant with HWR Richtlinien January 2025 (all cohorts / Wirtschaftsinformatik)
//
// Public API:
//   #show: hwr.with(...)
//   #abk("KI"), #gls("key"), #glspl("key")
//   #quelle(), #blockquote[...]
// All parameters: see requirements/api-design.md

#import "@preview/linguify:0.5.0": linguify, linguify-raw, set-database, load-ftl-data
#import "@preview/glossarium:0.5.10": make-glossary, register-glossary, print-glossary, gls, glspl

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
  assert(value != none, message: name + " is required and must not be none.")
}

#let _assert-doc-type(doc-type) = {
  let valid = ("ptb-1", "ptb-2", "ptb-3", "hausarbeit", "studienarbeit", "bachelorarbeit")
  assert(
    doc-type in valid,
    message: "doc-type \"" + doc-type + "\" is invalid. Allowed values: " + valid.join(", "),
  )
}

#let _validate(doc-type, title, authors, supervisor, company, first-examiner, second-examiner) = {
  _assert-doc-type(doc-type)
  _assert-not-none(title, "title")

  // Bug 4+7: Type-check authors — must be array of dicts (bare dict is normalized upstream)
  assert(type(authors) == array,
    message: "authors must be a dict or an array of dicts, e.g.: authors: (name: \"...\", matrikel: \"...\") for a single author, or authors: ((name: \"...\", matrikel: \"...\"), (name: \"...\", matrikel: \"...\")) for multiple authors.")
  for a in authors {
    assert(type(a) == dictionary,
      message: "Each entry in authors must be a dictionary with 'name' and 'matrikel' keys, e.g.: (name: \"Max Mustermann\", matrikel: \"12345678\")")
  }
  assert(authors.len() > 0, message: "authors must contain at least one entry.")

  let needs-supervisor = doc-type in ("ptb-1", "ptb-2", "ptb-3", "hausarbeit", "studienarbeit")
  if needs-supervisor {
    assert(
      supervisor != none,
      message: "supervisor is required for doc-type \"" + doc-type + "\".",
    )
    assert(
      company != none,
      message: "company is required for doc-type \"" + doc-type + "\".",
    )
  }

  if doc-type == "bachelorarbeit" {
    assert(
      first-examiner != none,
      message: "first-examiner is required for doc-type \"bachelorarbeit\".",
    )
    assert(
      second-examiner != none,
      message: "second-examiner is required for doc-type \"bachelorarbeit\".",
    )
  }
}

// ---------------------------------------------------------------------------
// Main template function
// ---------------------------------------------------------------------------

// Alias: the parameter `bibliography` shadows the built-in; keep a reference for set rules.
#let _bibliography = bibliography

/// Source attribution for figures/tables (HWR requirement).
///
/// Three syntaxes:
///   caption: [Vergleich.  #quelle()]                              → "Quelle: Eigene Darstellung"
///   caption: [Tabelle.    #quelle(<mustermann2024>)]              → "Quelle: Mustermann (2024)" (clickable!)
///   caption: [Tabelle.    #quelle(<mustermann2024>, "S. 42")]     → "Quelle: Mustermann (2024), S. 42" (clickable!)
///   caption: [Übersicht.  #quelle("Mustermann", 2024)]            → "Quelle: Mustermann (2024)" (plain text)
///   caption: [Daten.      #quelle("Mustermann", 2024, "S. 42")]   → "Quelle: Mustermann (2024), S. 42"
///   caption: [Gleich oben. #quelle(author: "Mustermann", year: 2024, s: "S. 42")]
#let quelle(..args) = {
  let pos = args.pos()
  let named = args.named()

  if pos.len() == 0 and named.len() == 0 {
    // No args → "Quelle: Eigene Darstellung"
    context linguify("source-own")
  } else if pos.len() >= 1 and type(pos.at(0)) == label {
    // Label → clickable cite() link, optional page locator as 2nd positional arg or s:
    let key = pos.at(0)
    let s   = if pos.len() >= 2 { pos.at(1) } else { named.at("s", default: none) }
    if s != none {
      [Quelle: #cite(key, supplement: s)]
    } else {
      [Quelle: #cite(key)]
    }
  } else {
    // Plain author/year string (backward-compatible)
    // Resolve from positional or keyword args.
    // Positional order: quelle(author, year) or quelle(author, year, s)
    let author = if pos.len() >= 1 { pos.at(0) } else { named.at("author", default: none) }
    let year   = if pos.len() >= 2 { pos.at(1) } else { named.at("year",   default: none) }
    let s      = if pos.len() >= 3 { pos.at(2) } else { named.at("s",      default: none) }

    assert(year != none,
      message: "quelle(): year is required when author is set. " +
               "Usage: quelle(\"Mustermann\", 2024) or quelle(author: \"Mustermann\", year: 2024)")
    let base = "Quelle: " + str(author) + " (" + str(year) + ")"
    if s != none { base + ", " + str(s) } else { base }
  }
}

/// HWR-compliant blockquote for long verbatim quotes (CIT-35, FMT-07).
///
/// Renders the content indented and single-spaced, as required for longer
/// direct quotations (>40 words / >3 lines).
///
/// Usage:
///   #blockquote[
///     „Dies ist ein längeres wörtliches Zitat aus einer Quelle,
///     das über mehrere Zeilen geht und daher eingerückt und
///     einzeilig formatiert werden muss." @mustermann2024[S. 42]
///   ]
#let blockquote(body) = {
  pad(left: 1cm)[
    #set par(leading: 0.65em, justify: true)  // single-spaced (leading ≈ 1.0 line spacing for 12pt)
    #body
  ]
}

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

  // Single-author shorthand: name/matrikel/signature as top-level fields.
  // Use instead of authors: for a single person without the dict syntax.
  // Cannot be combined with authors: — set one or the other.
  name: none,
  matrikel: none,
  signature: none,

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
  citation-style: "auto",

  heading-depth: 4,
  declaration-lang: auto,
  city: "Berlin",
  group-signature: auto,

  // === GESTALTUNG (Pretty Mode) ===
  // Top-level Shorthand: "compliant" (default) oder "pretty"
  //   "compliant" = HWR-richtlinienkonform (kein Logo, keine dekorativen Elemente)
  //   "pretty"    = dekoratives Deckblatt mit Logos und Zierlinien
  // HINWEIS: "pretty" ist NICHT in den HWR-Richtlinien vorgesehen.
  //          Bitte vor Verwendung mit dem/der Betreuer/in absprechen.
  style: "compliant",

  // Granulare Overrides (haben Vorrang vor style: wenn gesetzt):
  school-logo: none,    // Logo links im Seitenkopf, z.B. image("images/hwr-logo.png")
                        // Größe wird automatisch gesetzt (Header: 0.8cm, Deckblatt: 1.5cm)
  company-logo: none,   // Logo rechts im Seitenkopf, z.B. image("images/firma-logo.png")
  pretty-title: none,   // true = dekoratives Deckblatt (Zierlinien, größerer Titel, Logos)

  // === ENTWURFSMODUS ===
  draft: false,          // true = "ENTWURF"/"DRAFT" Wasserzeichen auf jeder Seite

  // === HINWEISE IM PDF ===
  warnings: true,        // false = gelbe Hinweisboxen unterdrücken (z.B. nach Absprache mit Prüfer)

  // show-rule body (passed automatically by #show: hwr.with(...))
  body,
) = {

  // --- Normalize authors ---
  // Priority 1: top-level name/matrikel/signature shorthand (single-author convenience)
  // Normalize authors from the three supported input forms:
  //   1. top-level name:/matrikel:/signature: — single-author shorthand
  //   2. authors: as bare dict — single-author without array syntax
  //   3. authors: as array of dicts — multi-author, standard form
  // If both name: and authors: are set, authors: wins — but we error so the user
  // notices and cleans up (ambiguous intent).
  let authors = if name != none and (authors != () and authors != (:)) {
    assert(false,
      message: "Conflict: both top-level name:/matrikel: and authors: are set. " +
               "Use one or the other — remove name:/matrikel: for multi-author mode, " +
               "or remove authors: to keep the shorthand.")
  } else if name != none {
    let entry = (name: name, matrikel: matrikel)
    let entry = if signature != none { entry + (signature: signature) } else { entry }
    (entry,)
  } else if type(authors) == dictionary {
    (authors,)
  } else {
    authors
  }

  // --- Validate style parameter ---
  assert(
    style in ("compliant", "pretty"),
    message: "style must be \"compliant\" or \"pretty\", got: \"" + str(style) + "\"",
  )

  // --- Validate lang ---
  assert(
    lang in ("de", "en"),
    message: "lang must be \"de\" or \"en\", got: \"" + str(lang) + "\"",
  )

  // --- Validate heading-depth ---
  assert(
    type(heading-depth) == int and heading-depth >= 1 and heading-depth <= 4,
    message: "heading-depth must be an integer between 1 and 4, got: " + str(heading-depth),
  )

  // --- Normalize style (same pattern as author normalization) ---
  // style: sets defaults; granular params override when explicitly set (not none).
  let is-pretty = style == "pretty"
  let resolved-school-logo = if school-logo != none { school-logo } else { none }
  let resolved-company-logo = if company-logo != none { company-logo } else { none }
  let resolved-pretty-title = if pretty-title != none { pretty-title } else { is-pretty }

  // --- Validation ---
  _validate(doc-type, title, authors, supervisor, company, first-examiner, second-examiner)

  // Validate signature fields: must be content (image()), not string paths.
  // String paths resolve relative to the package, not the user's project.
  for a in authors {
    let sig = a.at("signature", default: none)
    if sig != none and type(sig) == str {
      panic("signature must be image content, not a string path. Use: signature: image(\"" + sig + "\") instead of: signature: \"" + sig + "\"")
    }
  }

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
    background: if draft {
      place(center + horizon,
        rotate(45deg,
          text(size: 80pt, fill: rgb(200, 200, 200, 80), weight: "bold",
            tracking: 6pt)[#linguify("draft-watermark")]
        )
      )
    },
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
  // glossarium 0.5.10 requires both make-glossary (show rule) and register-glossary (entries).
  // make-glossary sets up the tracking; register-glossary makes entries findable by gls()/glspl().
  if glossary.len() > 0 {
    show: make-glossary
    register-glossary(glossary)
  }

  // --- abbreviations setup ---
  // Register central abbreviation dict so abk() can look up full forms
  setup-abbreviations(abbreviations)

  // ---------------------------------------------------------------------------
  // Document structure
  // ---------------------------------------------------------------------------

  // 1. Sperrvermerk (vor Deckblatt, keine Seitennummer, nicht in Zählung — CNT-20, STR-01)
  if confidential != none {
    // Validate: Sperrvermerk requires company name for the confidentiality text
    assert(company != none,
      message: "confidential requires company: — the Sperrvermerk text references the company name. " +
               "Set company: \"Firma GmbH\" or remove confidential:.")

    // Empty chapters list → treat as full confidentiality (Bug 12)
    let resolved-conf = if type(confidential) == dictionary {
      let chs = confidential.at("chapters", default: ())
      if chs.len() == 0 { true } else { confidential }
    } else {
      confidential
    }
    render-confidentiality(resolved-conf, company, title, authors, resolved-date, lang, city: city, group-signature: resolved-group-sig, warnings: warnings)
  }

  // 2. Deckblatt: Seitenzähler startet bei I (röm.), aber Nummer nicht sichtbar (STR-02)
  counter(page).update(1)
  set page(numbering: none)
  render-title-page(
    doc-type, title, authors,
    supervisor, company, first-examiner, second-examiner,
    field-of-study, cohort, semester, resolved-date, lang,
    school-logo: resolved-school-logo,
    company-logo: resolved-company-logo,
    pretty-title: resolved-pretty-title,
  )

  // Pretty-mode warning: show visual notice when non-compliant styling is active
  if warnings and (is-pretty or resolved-school-logo != none or resolved-company-logo != none or (pretty-title != none and pretty-title == true)) {
    block(
      fill: rgb("#fff3cd"),
      stroke: 0.5pt + rgb("#856404"),
      radius: 3pt,
      inset: 8pt,
      width: 100%,
    )[
      #set text(size: 10pt)
      #linguify("pretty-warning")
    ]
  }

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
  // Header mit Logos (nur im Haupttext, nur wenn Logos gesetzt)
  // HINWEIS: Header mit Logos ist NICHT in den HWR-Richtlinien vorgesehen.
  // Layout: [Logo links] [Seitennummer mittig] [Logo rechts] + hellgraue Trennlinie
  // Logos werden im Header auf 0.8cm Höhe skaliert (Deckblatt: 1.5cm).
  let _has-logo-header = resolved-school-logo != none or resolved-company-logo != none
  // Wenn Logo-Header aktiv: custom header mit Logos und Seitennummer mittig;
  // numbering: none unterdrückt die Standard-Seitennummer (wird im Header-Grid gerendert).
  // Ohne Logos: header: auto bewahrt die automatische number-align-Seitennummer.
  // WICHTIG: header: none (oder fehlender else-Zweig → none) würde die automatische
  // number-align-Seitennummer unterdrücken — daher explizit auto setzen.
  let _page-header = if _has-logo-header {
    context {
      set image(height: 0.8cm)
      grid(
        columns: (1fr, auto, 1fr),
        align: (left + horizon, center + horizon, right + horizon),
        if resolved-school-logo != none { resolved-school-logo } else { [] },
        text(size: 10pt)[#counter(page).display()],
        if resolved-company-logo != none { resolved-company-logo } else { [] },
      )
      v(2pt)
      line(length: 100%, stroke: 0.5pt + luma(180))
    }
  } else {
    auto
  }
  set page(
    numbering: if _has-logo-header { none } else { "1" },
    header: _page-header,
  )

  // chapters: array of included content (api-design §11)
  // User passes: chapters: (include("kapitel/01.typ"), include("kapitel/02.typ"), ...)
  // The include() calls are evaluated in main.typ (relative to main.typ), so paths work correctly.
  // pagebreak(weak: true): new page before each chapter; weak prevents double-break if chapter
  // itself starts with #pagebreak().
  for ch in chapters {
    if type(ch) == str {
      panic("chapters entries must use include(), not string paths. Use: chapters: (include(\"" + ch + "\"),) instead of: chapters: (\"" + ch + "\",)")
    }
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
  // Title is forced via l10n (DE: "Literaturverzeichnis", EN: "References") — Bug 8
  if bibliography != none {
    pagebreak(weak: true)
    // citation-style: "auto" → APA for DE, Harvard (Anglia Ruskin) for EN (HWR §6).
    // "harvard-anglia-ruskin-university" → bundled CSL; custom CSL via read("file.csl") → XML string.
    let effective-style = if citation-style == "auto" {
      if lang == "en" { "harvard-anglia-ruskin-university" } else { "apa" }
    } else {
      citation-style
    }
    let resolved-style = if effective-style == "harvard-anglia-ruskin-university" {
      bytes(read("styles/harvard-anglia-ruskin-university.csl"))
    } else if type(effective-style) == str and effective-style.starts-with("<") {
      bytes(effective-style)
    } else {
      effective-style
    }
    heading(level: 1, numbering: none, outlined: true)[#linguify("bibliography-title")]
    {
      // Suppress the bibliography's auto-generated heading visually.
      // The heading still registers in the outline — that duplicate is filtered out
      // by the show outline.entry rule above (see "TOC depth follows heading-depth").
      show heading: none
      set _bibliography(style: resolved-style)
      bibliography
    }
  }

  // 7. Anhang: user-Einträge + KI-Verzeichnis automatisch als letztes Item (STR-09, STR-12)
  if appendix.len() > 0 or ai-tools.len() > 0 {
    pagebreak(weak: true)
    render-appendix(appendix, ai-tools, lang, show-toc: show-appendix-toc)
  }

  // 8. Ehrenwörtliche Erklärung (immer zuletzt — STR-10)
  render-declaration(authors, decl-lang, lang, city: city, group-signature: resolved-group-sig, warnings: warnings)
}

// ---------------------------------------------------------------------------
// Re-exports for use in chapter files
// ---------------------------------------------------------------------------
// Users import these from lib.typ in their kapitel/ files:
//   #import "@preview/easy-wi-hwr:0.1.2": abk, gls, glspl
//   #import "@preview/easy-wi-hwr:0.1.2": quelle, blockquote

