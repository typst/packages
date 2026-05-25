#let body-size = 11pt
#let table-header-size = 12pt
#let section-title-size = 17.5pt
#let page-title-size = 20pt

#let table-grey = rgb("#e7e7e7")
#let inner-rule = 0.45pt
#let outer-rule = 2.85pt

#let matrix-low = rgb("#11ff00")
#let matrix-medium = rgb("#ffc61a")
#let matrix-high = rgb("#ff1710")

#let score-low = rgb("#bff6b8")
#let score-medium = rgb("#ffe0b8")
#let score-high = rgb("#f8bcbc")

#let score-fill(score) = if score >= 15 {
  score-high
} else if score >= 9 {
  score-medium
} else {
  score-low
}

#let matrix-fill(score) = if score >= 15 {
  matrix-high
} else if score >= 9 {
  matrix-medium
} else {
  matrix-low
}

#let score-foreground(score) = if score >= 15 {
  white
} else {
  black
}

#let full-width(body) = block(width: 100%)[#body]

#let footer-content(footer-label: none) = context [
  #set text(font: "Arial", size: 8pt)
  #if footer-label != none {
    footer-label
  }
  #h(1fr)
  #counter(page).display()
]

#let header-content(appendix-label: none) = [
  #table(
    columns: (1fr, auto),
    stroke: none,
    inset: 10pt,
    align: (left + top, right + top),
    if appendix-label == none { [] } else { text(size: 8pt)[#appendix-label] },
    image("./assets/bath-wordmark.svg", height: 1.45cm),
  )
]

#let score-cell(score, matrix: false) = table.cell(
  fill: if matrix { matrix-fill(score) } else { score-fill(score) },
  align: center + horizon,
  inset: (x: 2pt, y: 5pt),
)[#text(weight: "bold", fill: score-foreground(score))[#score]]

#let risk-calc(severity, likelihood) = {
  let score = severity * likelihood
  score-cell(score)
}

#let risk-guidance-table() = table(
  columns: (5.8fr, 1.75fr),
  stroke: inner-rule,
  inset: (x: 8pt, y: 5pt),
  align: (left + top, left + top),
  table.header(
    table.cell(fill: table-grey, align: center + horizon)[#text(
      size: table-header-size,
      weight: "bold",
    )[Hazard Severity (a)]],
    table.cell(fill: table-grey, align: center + horizon)[#text(
      size: table-header-size,
      weight: "bold",
    )[Likelihood of Occurrence (b)]],
  ),
  [
    *1 - Trivial* (e.g. discomfort, slight bruising, self-help recovery, no significant harm to health or mental health)\
    *2 - Minor* (e.g. small cut, abrasion, basic first aid need, temporary ill-health leading to discomfort, stress / distress)\
    *3 - Moderate* (e.g. strain, sprain, incapacitation or other injury or diagnosable mental health condition > 7 days absence from work or amended duties)\
    *4 - Serious* (e.g. fracture or hospitalisation for >24 hrs or incapacitation \<7 days or diagnosable mental health condition significantly affecting day to day life; self harm or harm to others)\
    *5 - Catastrophic* (single or multiple fatalities or life changing disabilities or injuries, suicide risk or potential harm to others as a result of severe mental health impacts)
  ],
  [
    *1 - Remote* (almost never)\
    *2 - Unlikely* (occurs rarely)\
    *3 - Possible* (could occur, but uncommon)\
    *4 - Likely* (recurrent but not frequent)\
    *5 - Very likely* (occurs frequently)
  ],
)

#let row-length = 1.1cm

#let risk-matrix-panel() = table(
  columns: (2.5fr, 1.45fr, 1.45fr, 1.85fr, 1.6fr, 2.3fr),
  rows: (row-length, row-length, row-length, row-length, row-length, row-length),
  stroke: (x, y) => (
    top: if y == 1 { outer-rule } else if y == 2 and x > 0 { outer-rule } else { inner-rule },
    bottom: if y == 6 { outer-rule } else { inner-rule },
    left: if x == 0 and y > 0 { outer-rule } else if x == 1 and y > 1 { outer-rule } else { inner-rule },
    right: if x == 5 { outer-rule } else { inner-rule },
  ),
  inset: (x: 4pt, y: 5pt),
  align: center + horizon,
  table.cell(colspan: 6, inset: (x: 6pt, y: 6pt), align: center + horizon)[#text(
    size: 13pt,
    weight: "bold",
  )[Risk Assessment Matrix]],
  [*(A)#sym.arrow.b* *(B)#sym.arrow.r*],
  table.cell(fill: table-grey)[#text(weight: "bold")[Trivial]],
  table.cell(fill: table-grey)[#text(weight: "bold")[Minor]],
  table.cell(fill: table-grey)[#text(weight: "bold")[Moderate]],
  table.cell(fill: table-grey)[#text(weight: "bold")[Serious]],
  table.cell(fill: table-grey)[#text(weight: "bold")[Catastrophic]],

  table.cell(inset: (x: 6pt, y: 4pt), align: left + horizon)[#text(weight: "bold")[Remote]],
  score-cell(1, matrix: true),
  score-cell(2, matrix: true),
  score-cell(3, matrix: true),
  score-cell(4, matrix: true),
  score-cell(5, matrix: true),

  table.cell(inset: (x: 6pt, y: 4pt), align: left + horizon)[#text(weight: "bold")[Unlikely]],
  score-cell(2, matrix: true),
  score-cell(4, matrix: true),
  score-cell(6, matrix: true),
  score-cell(8, matrix: true),
  score-cell(10, matrix: true),

  table.cell(inset: (x: 6pt, y: 4pt), align: left + horizon)[#text(weight: "bold")[Possible]],
  score-cell(3, matrix: true),
  score-cell(6, matrix: true),
  score-cell(9, matrix: true),
  score-cell(12, matrix: true),
  score-cell(15, matrix: true),

  table.cell(inset: (x: 6pt, y: 4pt), align: left + horizon)[#text(weight: "bold")[Likely]],
  score-cell(4, matrix: true),
  score-cell(8, matrix: true),
  score-cell(12, matrix: true),
  score-cell(16, matrix: true),
  score-cell(20, matrix: true),

  table.cell(inset: (x: 6pt, y: 4pt), align: left + horizon)[#text(weight: "bold")[Very likely]],
  score-cell(5, matrix: true),
  score-cell(10, matrix: true),
  score-cell(15, matrix: true),
  score-cell(20, matrix: true),
  score-cell(25, matrix: true),
)

#let rating-band-column(title, range, fill, body) = table.cell(
  fill: fill,
  inset: (x: 7pt, y: 8pt),
  align: center + top,
)[
  #v(1em)
  #text(weight: "bold")[#title]\
  #text(weight: "bold")[#range]\
  #v(2em)
  #body
]

#let rating-band-panel() = table(
  columns: (1fr, 1fr, 1fr),
  rows: (row-length, 6 * row-length),
  stroke: (x, y) => (
    top: if y == 0 { outer-rule } else { inner-rule },
    bottom: if y == 1 { outer-rule } else { inner-rule },
    left: if x == 0 { outer-rule } else { inner-rule },
    right: if x == 2 { outer-rule } else if x == 0 and y == 0 { outer-rule } else { inner-rule },
  ),
  inset: (x: 6pt, y: 5pt),
  align: center + top,
  table.cell(colspan: 3, inset: (x: 6pt, y: 6pt), align: center + horizon)[#text(
    size: 13pt,
    weight: "bold",
  )[Risk Rating Bands (A x B)]],
  rating-band-column(
    [LOW RISK],
    [(1 - 8)],
    matrix-low,
    [Continue, but review periodically to ensure controls remain effective],
  ),
  rating-band-column(
    [MEDIUM RISK],
    [(9 - 12)],
    matrix-medium,
    [Continue, but implement additional reasonably practicable controls where possible and monitor regularly],
  ),
  rating-band-column(
    text(fill: white)[HIGH RISK],
    text(fill: white)[(15 - 25)],
    matrix-high,
    [#text(fill: white, weight: "bold")[STOP THE ACTIVITY]\
      #text(
        fill: white,
      )[Identify new controls. Activity must not proceed until risks are reduced to a low or medium level]],
  ),
)

#let risk-guidance() = [
  #set text(size: body-size)
  #v(5pt)
  #align(center)[#text(size: page-title-size, weight: "bold")[RISK ASSESSMENT TEMPLATE]]
  #v(8pt)
  #text(size: 15pt, weight: "bold")[Risk Matrix and Rating Guidance:]

  The assessor shall assign values for the hazard severity *(a)* and likelihood of occurrence *(b)* (taking into account the frequency and duration of exposure) on a scale of 1 to 5, then multiply them together to give the rating band:
  #v(6pt)
  #risk-guidance-table()
  #v(7pt)
  #grid(
    columns: (1.05fr, 1fr),
    gutter: 10pt,
    risk-matrix-panel(), rating-band-panel(),
  )
]

#let field-box(label, value: [], height: auto, colspan: 1, align: left + top) = table.cell(
  colspan: colspan,
  inset: 0pt,
  align: align,
)[
  #block(width: 100%, height: height, inset: (x: 6pt, y: 6pt))[
    *#label:*#if value != [] [
      \
      #value
    ]
  ]
]

#let risk-record-header(
  title,
  date-produced,
  review-date,
  overview,
  duration,
  location,
  assessment-type,
) = [
  #align(center)[#text(size: section-title-size, weight: "bold")[Risk Assessment Record]]
  #v(7pt)
  #table(
    columns: (2fr, 1fr, 1fr),
    stroke: inner-rule,
    inset: 0pt,
    align: left + top,
    field-box([Risk Assessment Title], value: title),
    field-box([Date Produced], value: date-produced),
    field-box([Review Date], value: review-date),

    field-box([Overview/Description of Activity], value: overview),
    field-box([Duration/Frequency of Activity], value: duration, colspan: 2),
    field-box([Location of Activity], value: location),

    field-box([Generic or Specific Assessment], value: assessment-type, height: 1.15cm, colspan: 2),
  )
  #v(7pt)
]

#let risk-table(..cells) = {
  // 1. Grab all positional arguments passed into the function
  let input-cells = cells.pos()
  let flat-data = ()
  let cell-counter = 0
  let row-number = 1

  // 2. Process cells and auto-inject row numbers
  for cell in input-cells {
    if cell-counter == 0 {
      // Inject the row number string at the start of each new row
      flat-data.push(align(horizon + center, block(height: 1em, str(row-number))))
    }

    flat-data.push(cell)
    cell-counter += 1

    // Your table has 8 columns (1 ID + 7 user content columns).
    // Once 7 user cells are processed, the row is complete.
    if cell-counter == 7 {
      cell-counter = 0
      row-number += 1
    }
  }

  // Calculate how many data rows we actually have.
  // (Adding 1 if there are leftover cells forming a partial row)
  let num-data-rows = row-number - 1 + if cell-counter > 0 { 1 } else { 0 }

  table(
    columns: (auto, 3.5fr, 2.4fr, 5.25fr, auto, auto, auto, 4.5fr),
    stroke: inner-rule,
    inset: (x: 6pt, y: 6pt),
    table.header(
      table.cell(fill: table-grey, align: center + horizon)[#text(size: table-header-size, weight: "bold")[\#]],
      table.cell(fill: table-grey, align: center + horizon)[#text(
        size: table-header-size,
        weight: "bold",
      )[Hazard(s) identified]],
      table.cell(fill: table-grey, align: center + horizon)[#text(
        size: table-header-size,
        weight: "bold",
      )[Who might be affected and how]],
      table.cell(fill: table-grey, align: center + horizon)[#text(
        size: table-header-size,
        weight: "bold",
      )[Existing controls & measures]],
      table.cell(fill: table-grey, align: center + horizon)[#text(
        size: table-header-size,
        weight: "bold",
      )[Severity\ (a)]],
      table.cell(fill: table-grey, align: center + horizon)[#text(
        size: table-header-size,
        weight: "bold",
      )[Likelihood\ (b)]],
      table.cell(fill: table-grey, align: center + horizon)[#text(
        size: table-header-size,
        weight: "bold",
      )[Risk Rating\ (a x b)]],
      table.cell(fill: table-grey, align: center + horizon)[#text(
        size: table-header-size,
        weight: "bold",
      )[Additional control/action required]],
    ),
    ..flat-data,
  )
}

#let risk-assessment(
  title: [],
  date-produced: datetime.today().display("[day] [month repr:long] [year]"),
  review-date: [],
  overview: [],
  duration: [],
  location: [],
  assessment-type: [Specific],
  footer-label: none,
  appendix-label: none,
  body,
) = [
  #set page(
    paper: "a4",
    flipped: true,
    margin: (top: 2.15cm, bottom: 0.9cm, x: 0.9cm),
    header: header-content(appendix-label: appendix-label),
    footer: footer-content(footer-label: footer-label),
  )
  #set text(font: "Arial", size: body-size)
  #set par(justify: false, leading: 0.6em)
  #set heading(numbering: none, outlined: false)
  #show heading.where(level: 1): it => [
    #align(center)[#text(size: section-title-size, weight: "bold")[#it.body]]
    #v(8pt)
  ]

  #risk-guidance()
  #pagebreak()
  #risk-record-header(title, date-produced, review-date, overview, duration, location, assessment-type)
  #body
]

#let action-plan-table(..cells) = {
  // 1. Grab all positional arguments passed into the function
  let input-cells = cells.pos()
  let flat-data = ()
  let cell-counter = 0
  let row-number = 1

  // 2. Process cells
  for cell in input-cells {
    if cell-counter == 0 {
      // Inject the row number string at the start of each new row
      flat-data.push(align(center + horizon, block(height: 1em, cell)))
    } else {
      flat-data.push(cell)
    }
    cell-counter += 1

    // Your table has 8 columns (1 ID + 7 user content columns).
    // Once 7 user cells are processed, the row is complete.
    if cell-counter == 6 {
      cell-counter = 0
      row-number += 1
    }
  }
  table(
    columns: (auto, 2.65fr, auto, auto, auto, 3.5fr),
    stroke: inner-rule,
    inset: (x: 6pt, y: 6pt),
    table.header(
      table.cell(fill: table-grey, align: center + horizon)[#text(
        size: table-header-size,
        weight: "bold",
      )[Hazard\ No.]],
      table.cell(fill: table-grey, align: center + horizon)[#text(
        size: table-header-size,
        weight: "bold",
      )[Action to be taken]],
      table.cell(fill: table-grey, align: center + horizon)[#text(size: table-header-size, weight: "bold")[By whom]],
      table.cell(fill: table-grey, align: center + horizon)[#text(
        size: table-header-size,
        weight: "bold",
      )[Target date]],
      table.cell(fill: table-grey, align: center + horizon)[#text(
        size: table-header-size,
        weight: "bold",
      )[Review date]],
      table.cell(fill: table-grey, align: center + horizon)[#text(
        size: table-header-size,
        weight: "bold",
      )[Outcome at review date]],
    ),
    ..flat-data,
  )
}

#let sign-on-table(..cells) = {
  [Sign on Sheet to acknowledge understanding of Risk Assessment:]
  v(5pt)
  let input-cells = cells.pos()
  let flat-data = ()
  let cell-counter = 0

  for cell in input-cells {
    if cell-counter == 0 {
      // Places the 2em invisible strut and your text side-by-side, 
      // perfectly aligned at the top.
      flat-data.push(align(left + horizon, grid(
        columns: 2,
        box(height: 2em, width: 0pt), 
        cell
      )))
    } else {
      flat-data.push(cell)
    }

    cell-counter += 1
    
    // Reset the counter after 7 columns (since the ID column is removed)
    if cell-counter == 3 {
      cell-counter = 0
    }
  }

  table(
    columns: (1fr, 1fr, 0.7fr),
    stroke: inner-rule,
    inset: (x: 8pt, y: 6pt),
    table.header(
      table.cell(colspan: 3, inset: (x: 8pt, y: 8pt))[
        #text(size: 12pt, weight: "bold")[Names and Signatures of other workers/researchers/PG/UG students]\
        #emph[All others undertaking the process described must signify that they understand the hazards and risks.]
      ],
      table.cell(fill: table-grey, align: left + horizon)[#text(
        size: table-header-size,
        weight: "bold",
      )[Print name:]],
      table.cell(fill: table-grey, align: left + horizon)[#text(size: table-header-size, weight: "bold")[Signature:]],
      table.cell(fill: table-grey, align: left + horizon)[#text(size: table-header-size, weight: "bold")[Date:]],
    ),
    ..flat-data,
  )
}

#let signature-box(title) = [
  #v(1em)
  *#title:* #box(width: 1fr, stroke: (bottom: 0.5pt)) #h(1cm)
  *Print name:* #box(width: 1.5fr, stroke: (bottom: 0.5pt)) #h(1cm)
  *Date:* #box(width: 5cm, stroke: (bottom: 0.5pt))
  #v(1em)
]
