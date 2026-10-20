// title-page.typ
//
// Title page for the milestone report. White background. Uni Stuttgart logo
// with the institute and chair lines top-left, optional additional logo
// centered in the middle of the page.

#import "common.typ": fonts
#import "logos.typ": default-university-logo
#import "university-block.typ": university-block

// Localized strings.
#let _labels(language) = {
  if language == "german" {
    (
      submitted-by: "Eingereicht von",
      examiners: "Prüfer:",
      supervisor: "Betreuer:",
      co-supervisor: "Mitbetreuer:",
      default-report-type: "Meilensteinbericht",
      presentation-date-label: "Datum des Meilensteinvortrags",
    )
  } else {
    (
      submitted-by: "Submitted by",
      examiners: "Examiners:",
      supervisor: "Supervisor:",
      co-supervisor: "Co-supervisor:",
      default-report-type: "Milestone Report",
      presentation-date-label: "Date of the milestone presentation",
    )
  }
}

// Build the title page.
#let title-page(
  title: [],
  author: "",
  language: "english",
  report-type: auto,
  supervisor: "",
  co-supervisor: none,
  examiners: (),
  institute: "",
  chair: "",
  presentation-date: none,
  university-logo: auto,
  additional-logo: none,
) = {
  let labels = _labels(language)
  let resolved-report-type = if report-type == auto { labels.default-report-type } else { report-type }
  let uni-block = university-block(
    logo: if university-logo == auto { default-university-logo(language) } else { university-logo },
    language: language,
    institute: institute,
    chair: chair,
    sans-font: fonts.sans,
  )

  set page(
    paper: "a4",
    margin: (top: 20mm, bottom: 25mm, left: 25mm, right: 25mm),
    header: none,
    footer: none,
    // University block as the page background so it can sit at the
    // physical page corner with a 10mm offset, ignoring the body margin.
    // Same offset as the thesis cover page.
    background: place(top + left, dx: 10mm, dy: 10mm, uni-block),
  )
  set text(font: fonts.sans, fill: black)

  v(5cm)

  // Report-type label (smaller subtitle).
  align(center, text(size: 14pt)[#resolved-report-type])

  v(1cm)

  // Title.
  align(center)[
    #set par(leading: 0.6em)
    #text(size: 24pt, weight: "bold")[#title]
  ]

  v(1fr)

  // Additional logo, centered. Skipped when none.
  if additional-logo != none {
    align(center, additional-logo)
  }

  v(1fr)

  // Submitted by.
  align(center)[
    #labels.submitted-by \
    #v(6mm)
    #text(size: 14pt)[#author]
  ]

  v(1fr)

  // Supervisor block as a two-column table.
  let rows = (
    ([#labels.supervisor], [#supervisor]),
  )
  let rows = if co-supervisor != none {
    rows + (([#labels.co-supervisor], [#co-supervisor]),)
  } else {
    rows
  }
  let rows = if examiners.len() > 0 {
    rows + (([#labels.examiners], examiners.join(linebreak())),)
  } else {
    rows
  }

  align(center)[
    #table(
      columns: 2,
      align: (right, left),
      stroke: none,
      inset: (x: 8pt, y: 4pt),
      ..rows.flatten()
    )
  ]

  v(1fr)

  // Institute / chair footer. The milestone presentation date renders
  // below the chair line when provided, on its own labelled block.
  align(center)[
    #institute \
    #chair
    #if presentation-date != none {
      v(6mm)
      [#labels.presentation-date-label \ #presentation-date]
    }
  ]
}
