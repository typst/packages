#import "@preview/tiptoe:0.4.0": line, stealth

#import "./utils.typ": maybe-sans-serif, months-no, t, thesis-type-keys

#let bar-height = 75mm
#let bar-inset = 5mm
#let left-margin = 60mm
#let bar-width = 30mm

#let bar-stroke(bar-color) = bar-color.lighten(40%)

#let ntnu-logo-replacement = [NTNU | Kunnskap for en bedre verden]

#let front-cover(
  title: "Example Title in Primary Language",
  subtitle: "Example Subtitle in Primary Language",
  authors: ("Peter Grey", "Joan Yellow"),
  supervisors: ("Molly Salmon", "Alistair Orange"),
  degree-name: "Example degree name",
  faculty: "Example faculty",
  department: "Example department",
  level: "master",
  date: datetime.today(),
  lang: "en",
  cover-color: rgb("#8DA7CF"),
  logo: none,
  style,
) = {
  set page(margin: (left: left-margin, right: 30mm, top: 40mm, bottom: 25mm))
  set text(font: maybe-sans-serif(style))

  // --- Left Vertical Banner & Affiliation Sidebar ---
  let thesis-type = t(thesis-type-keys.at(level))

  // Colored ribbon at top-left
  place(
    top + left,
    dx: -left-margin,
    rect(
      width: bar-width,
      height: bar-height,
      fill: cover-color,
      inset: bar-inset,
      align(right + bottom, rotate(-90deg, reflow: true)[
        #text(size: 15pt, weight: "bold", fill: rgb("#000000"), thesis-type)
      ]),
    ),
  )

  // Rotated affiliation block below ribbon
  place(
    top + left,
    dx: -left-margin,
    dy: bar-height + bar-inset,
    rect(
      stroke: none,
      width: bar-width,
      align(top + right, rotate(-90deg, reflow: true)[
        #set text(size: 7.5pt)
        *#t("uni-short")* \
        #t("uni-long") \
        #if faculty != none [ #faculty \ ]
        #if department != none [ #department ]
      ]),
    ),
  )

  // Subtle horizontal divider line
  place(
    top + left,
    dx: -left-margin,
    dy: bar-height * 2 + bar-inset * 3,
    line(
      tip: stealth,
      start: (0mm, 0mm),
      end: (left-margin - bar-width / 3, 0mm),
      stroke: 1pt + bar-stroke(cover-color),
    ),
  )

  // --- Main Right Column ---
  // Author, title and subtitle
  let author-text = text(
    size: 15pt,
    authors.join(", "),
  )
  let title-text = text(
    size: 22pt,
    weight: "bold",
    title,
  )
  let subtitle-text = if subtitle != none [
    #text(size: 13pt, fill: rgb("#333333"), subtitle)
    #v(1em)
  ]

  [
    #author-text

    #title-text

    #subtitle-text
  ]

  // Necessary as of 2026-08-24 because datetime.display doesn't automatically translate based on the text language.
  // See: https://github.com/typst/typst/issues/2840
  // And: https://github.com/typst/typst/issues/1537
  let formatted-date = if lang == "en" [
    #date.display("[month repr:long] [year]")
  ] else {
    let translated-month(dt) = months-no.at(dt.month() - 1)
    [#translated-month(date) #date.year()]
  }

  let supervisor-label = if supervisors.len() == 1 {
    t("supervisor")
  } else {
    t("supervisors")
  }

  [
    #set text(size: 11pt)
    #thesis-type #t("in") #degree-name \
    #if supervisors != () and supervisors != none [
      #supervisor-label: #supervisors.join(", ") \
    ]
    #formatted-date
  ]

  // Logo at the bottom of the page
  v(1fr)
  if logo != none {
    logo
  } else {
    ntnu-logo-replacement
  }
}

#let back-cover(
  year: 2026,
  logo: none,
  cover-color: rgb("#8DA7CF"),
  style,
) = {
  // Margins matched to front-cover to ensure accurate physical alignment
  set page(margin: (left: left-margin, right: 30mm, top: 40mm, bottom: 25mm))
  set text(size: 12pt, font: maybe-sans-serif(style))

  let cx = 50mm
  let cy = bar-height - 10mm
  let r = 32mm
  let drop = bar-height * 2 + bar-inset * 3

  // Background banner spanning to the right edge (the spine on the back cover)
  place(
    top + left,
    rect(
      width: 100% + 30mm,
      height: bar-height,
      fill: cover-color,
    ),
  )

  // Decorative circle overlay
  place(
    top + left,
    dx: cx - r,
    dy: cy - r,
    circle(
      radius: r,
      stroke: 1pt + bar-stroke(cover-color),
    ),
  )

  // Vertical drop line from the circle
  place(
    top + left,
    dx: cx,
    dy: cy + r,
    line(
      start: (0mm, 0mm),
      end: (0mm, drop - cy - r),
      stroke: 1pt + bar-stroke(cover-color),
    ),
  )

  // Horizontal line turning and bleeding off the right edge
  place(
    top + left,
    dx: cx,
    dy: drop,
    line(
      start: (0mm, 0mm),
      end: (100% + 30mm - cx, 0mm),
      stroke: 1pt + bar-stroke(cover-color),
    ),
  )

  v(1fr)

  if logo != none {
    logo
  } else {
    ntnu-logo-replacement
  }
}
