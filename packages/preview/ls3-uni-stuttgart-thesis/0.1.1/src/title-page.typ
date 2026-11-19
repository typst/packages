// title-page.typ
//
// Standard university-format title page. Page 2 of the thesis.
// Ports the LaTeX titlepage.tex content. The LaTeX titlepage is purely
// text-based, no logo at the top. The institute and chair appear as text
// near the bottom of the page.

#import "common.typ": fonts

// Localized strings selected by language.
#let _labels(language) = {
  if language == "german" {
    (
      submitted-by: "Eingereicht von",
      matriculation: "Matrikelnummer:",
      examiners: "Prüfer:",
      supervisors: "Betreuer:",
      master-thesis: "Masterarbeit",
      bachelor-thesis: "Bachelorarbeit",
    )
  } else {
    (
      submitted-by: "Submitted by",
      matriculation: "Matriculation Number:",
      examiners: "Examiners:",
      supervisors: "Supervisors:",
      master-thesis: "Master's Thesis",
      bachelor-thesis: "Bachelor's Thesis",
    )
  }
}

// Build the title page. Called by the thesis() show rule.
//
// Parameters.
//   title                content, the main title
//   author               string
//   matriculation-number string
//   degree               "bachelor" or "master"
//   language             "english" or "german"
//   examiners            tuple of strings
//   supervisors          tuple of strings
//   institute            string
//   chair                string
//   date                 string
#let title-page(
  title: [],
  author: "",
  matriculation-number: "",
  degree: "master",
  language: "english",
  examiners: (),
  supervisors: (),
  institute: "",
  chair: "",
  date: "",
  sans-font: fonts.sans,
) = {
  set page(
    paper: "a4",
    margin: (top: 25mm, bottom: 25mm, left: 25mm, right: 25mm),
    header: none,
    footer: none,
  )
  set text(font: sans-font, fill: black)

  let labels = _labels(language)
  let thesis-type = if degree == "bachelor" { labels.bachelor-thesis } else { labels.master-thesis }

  // 5cm vspace at top matches the LaTeX `\vspace*{5cm}`.
  v(5cm)

  // Thesis type line, large (LaTeX `\large`).
  align(center, text(size: 14pt)[#thesis-type])

  // Bigbreak between thesis-type and title.
  v(1.5cm)

  // Title, huge bold (LaTeX `\huge\bfseries`).
  align(center)[
    #set par(leading: 0.6em)
    #text(size: 24pt, weight: "bold")[#title]
  ]

  // First \vfill.
  v(1fr)

  // Submitted-by + author + matriculation number.
  align(center)[
    #labels.submitted-by \
    #v(6mm)
    #text(size: 14pt)[#author] \
    #v(6mm)
    #labels.matriculation #h(2mm) #matriculation-number
  ]

  // Second \vfill.
  v(1fr)

  // Examiners and supervisors as a two-column table.
  align(center)[
    #table(
      columns: 2,
      align: (right, left),
      stroke: none,
      inset: (x: 8pt, y: 4pt),
      [#labels.examiners], examiners.join(linebreak()),
      [], [],
      [#labels.supervisors], supervisors.join(linebreak()),
    )
  ]

  // Third \vfill.
  v(1fr)

  // Institute / chair / Stuttgart date footer.
  align(center)[
    #institute \
    #chair \
    #v(6mm)
    Stuttgart, #date
  ]
}
