// pages/title_page.typ
// Deckblatt für alle doc-types: ptb-1/2/3, hausarbeit, studienarbeit, bachelorarbeit
// Basiert auf PTB-Referenztemplate (deckblatt.typ) + HWR-Richtlinien §3.2
// STR-02: Deckblatt erhält röm. Seitennummer I, aber nicht sichtbar (in lib.typ gesetzt)

#import "@preview/linguify:0.5.0": linguify

// Human-readable doc-type labels
#let _doc-type-labels = (
  "ptb-1":         ("de": "Praxistransferbericht I",   "en": "Transfer Report I"),
  "ptb-2":         ("de": "Praxistransferbericht II",  "en": "Transfer Report II"),
  "ptb-3":         ("de": "Praxistransferbericht III", "en": "Transfer Report III"),
  "hausarbeit":    ("de": "Hausarbeit",                "en": "Coursework"),
  "studienarbeit": ("de": "Studienarbeit",             "en": "Study Paper"),
  "bachelorarbeit":("de": "Bachelorarbeit",            "en": "Bachelor Thesis"),
)

/// Render the title page.
///
/// Parameters match the hwr() top-level params exactly.
#let render-title-page(
  doc-type, title, authors,
  supervisor, company, first-examiner, second-examiner,
  field-of-study, cohort, semester, date, lang,
  school-logo: none,
  company-logo: none,
  pretty-title: false,
) = {
  let doc-label = _doc-type-labels.at(doc-type).at(lang)
  let is-bachelor = doc-type == "bachelorarbeit"

  if pretty-title {
    // ── Pretty-Modus: dekoratives Deckblatt ─────────────────────────────
    // HINWEIS: Nicht in den HWR-Richtlinien vorgesehen — bitte mit Betreuer/in absprechen.
    let equal-spacing = 0.25fr

    align(center)[
      #v(equal-spacing)

      // Logo-Zeile (Deckblatt: 1.5cm Höhe, größer als im Header)
      #set image(height: 1.5cm)
      #if school-logo != none and company-logo != none {
        grid(
          columns: (1fr, 1fr),
          align: (center + horizon, center + horizon),
          school-logo, company-logo,
        )
      } else if school-logo != none {
        school-logo
      } else if company-logo != none {
        company-logo
      }

      #v(equal-spacing)

      // Dokumenttyp über der Zierlinie
      #text(size: 1em, weight: 700, baseline: -13.5pt)[#doc-label]
      #line(length: 90%)
      // Titel — größer und prominenter
      #text(size: 2em, weight: 700)[#title]
      #line(length: 90%)

      #v(1.5cm)

      // Autoren
      #text(size: 1.3em, weight: "bold")[
        #authors.map(a => a.name).join(", ")
      ]

      #v(1cm)

      #if lang == "de" [vorgelegt am] else [submitted on] #date
      #v(0.6em, weak: true)
      $circle.filled.small$
      #v(0.6em, weak: true)
      #field-of-study
      #v(0.6em, weak: true)
      #if lang == "de" [
        Hochschule für Wirtschaft und Recht Berlin \
        Fachbereich Duales Studium
      ] else [
        Berlin School of Economics and Law (HWR Berlin) \
        Department of Cooperative Studies
      ]
    ]

    v(equal-spacing)

    // Metadata-Tabelle
    {
      let entries = ()
      for (i, a) in authors.enumerate() {
        entries += (
          if lang == "de" [Matrikelnummer:] else [Student ID:],
          [#a.name — #a.matrikel],
        )
      }
      if cohort != none {
        entries += (
          if lang == "de" [Studienjahrgang:] else [Cohort:],
          [#cohort],
        )
      }
      if semester != none {
        entries += (
          if lang == "de" [Studienhalbjahr:] else [Semester:],
          [#semester],
        )
      }
      if not is-bachelor and company != none {
        entries += (
          if lang == "de" [Ausbildungsbetrieb:] else [Partner Company:],
          [#company],
        )
      }
      if is-bachelor {
        entries += (
          if lang == "de" [Erstgutachterin oder \ Erstgutachter:] else [First Examiner:],
          [#first-examiner],
        )
        entries += (
          if lang == "de" [Zweitgutachterin oder \ Zweitgutachter:] else [Second Examiner:],
          [#second-examiner],
        )
      } else if supervisor != none {
        entries += (
          if lang == "de" [Betreuende Prüferin oder \ Betreuender Prüfer:] else [Supervising Examiner:],
          [#supervisor],
        )
      }

      show table.cell.where(x: 0): strong
      table(
        columns: 2,
        stroke: none,
        align: left,
        column-gutter: 5%,
        ..entries,
      )
    }

    v(equal-spacing)
  } else {
    // ── Compliant-Modus: Standard-Deckblatt (HWR-Richtlinien) ──────────
  align(center)[
    #v(2cm)

    // HWR-Logo Platzhalter — optional, kann in Phase 5 ergänzt werden
    // image("../assets/hwr-logo.svg", width: 5cm)
    // v(1cm)

    #text(size: 16pt, weight: "bold")[#title]

    #v(2cm)

    #text(size: 14pt)[#doc-label]

    #v(1.5cm)

    #if lang == "de" [vorgelegt am] else [submitted on] #date

    #v(1.5cm)

    #if lang == "de" [
      an der \
      Hochschule für Wirtschaft und Recht Berlin \
      Fachbereich Duales Studium
    ] else [
      at \
      Berlin School of Economics and Law (HWR Berlin) \
      Department of Cooperative Studies
    ]
  ]

  v(2.5cm)

  // ── Untere Hälfte: linksbündig, Grid ──────────────────────────────────
  align(left)[
    #let label-col = 160pt

    // Autoren-Block
    #grid(
      columns: (label-col, 1fr),
      row-gutter: 12pt,
      ..{
        let rows = ()
        // "von" / "by" label only before first author
        for (i, a) in authors.enumerate() {
          if i == 0 {
            rows += (
              if lang == "de" [von] else [by],
              [#a.name],
            )
          } else {
            rows += ([], [#a.name])
          }
          rows += (
            if lang == "de" [Matrikelnummer:] else [Student ID:],
            [#a.matrikel],
          )
        }
        rows
      }
    )

    #v(0.8cm)

    // Studiengang-Block
    #grid(
      columns: (label-col, 1fr),
      row-gutter: 12pt,
      ..{
        let rows = ()
        if field-of-study != none {
          rows += (
            if lang == "de" [Fachrichtung:] else [Field of Study:],
            [#field-of-study],
          )
        }
        if cohort != none {
          rows += (
            if lang == "de" [Studienjahrgang:] else [Cohort:],
            [#cohort],
          )
        }
        if semester != none {
          rows += (
            if lang == "de" [Studienhalbjahr:] else [Semester:],
            [#semester],
          )
        }
        // Unternehmen (nur für PTB/HA/SA)
        if not is-bachelor and company != none {
          rows += (
            if lang == "de" [Ausbildungsbetrieb:] else [Partner Company:],
            [#company],
          )
        }
        rows
      }
    )

    #v(1.5cm)

    // Betreuer / Gutachter-Block
    #if is-bachelor [
      #grid(
        columns: (label-col, 1fr),
        row-gutter: 12pt,
        if lang == "de" [Erstgutachterin oder \ Erstgutachter:] else [First Examiner:],
        [#first-examiner],
        if lang == "de" [Zweitgutachterin oder \ Zweitgutachter:] else [Second Examiner:],
        [#second-examiner],
      )
    ] else [
      #grid(
        columns: (label-col, 1fr),
        row-gutter: 12pt,
        if lang == "de" [Betreuende Prüferin oder \ Betreuender Prüfer:] else [Supervising Examiner:],
        [#supervisor],
      )
    ]
  ]
  }

  pagebreak()
}
