#let openTitlePage(settings: ()) = {
  set page(
    paper: "a4",
    margin: (left: 30mm, right: 30mm, top: 40mm, bottom: 40mm),
    numbering: "I",
    number-align: center,
    footer: ""
  )

  set text(
    font: settings.fontBody, 
    size: settings.fontBodySize, 
    lang: "en"
  )

  set par(leading: 1em)
}

#let finishTitlePage(
  settings: (),
  degree: "",
  program: "",
  title: "",
  subtitle: "",
  titleGerman: "",
  subtitleGerman: "",
  author: "",
  matriculationNumber: "",
  placeOfWork: "",
  supervisor: "",
  advisor: "",
  startDate: none,
  submissionDate: none,
) = {

  v(5mm)
  align(center, text(font: settings.fontHeading, 1.9em, weight: 700, "University of Applied Sciences Karlsruhe"))
  
  v(15mm)

  align(center, text(font: settings.fontHeading, 1.5em, weight: 100, degree + "’s Thesis in " + program))
  v(8mm)

  if titleGerman.len() > 0 {
    if subtitle.len() > 0 or subtitleGerman.len() > 0 {
      align(center, text(font: settings.fontHeading, 1.2em, weight: 700, title))
      align(center, text(font: settings.fontHeading, 1.2em, weight: 500, subtitle))
      v(10mm)
      align(center, text(font: settings.fontHeading, 1.2em, weight: 700, titleGerman))
      align(center, text(font: settings.fontHeading, 1.2em, weight: 500, subtitleGerman))  
    } else {
      align(center, text(font: settings.fontHeading, 1.4em, weight: 700, title))
      v(10mm)
      align(center, text(font: settings.fontHeading, 1.4em, weight: 700, titleGerman))
    }
  } else {
    if subtitle.len() > 0 {
      align(center, text(font: settings.fontHeading, 1.8em, weight: 700, title))
      v(5mm)
      align(center, text(font: settings.fontHeading, 1.4em, weight: 500, subtitle))
    } else {
      align(center, text(font: settings.fontHeading, 2.0em, weight: 700, title))
    }
    
  }

  if advisor.len() > 0 {
    pad(
      top: 3em,
      right: 10%,
      left: 10%,
      grid(
        columns: (3fr, 3fr),
        gutter: 1em,
        strong("Author: "), author,
        strong("Matriculation Number: "), matriculationNumber,
        strong("Place of Work: "), placeOfWork,
        strong("Supervisor: "), supervisor,
        strong("Advisor: "), advisor,
        strong("Start Date: "), startDate,
        strong("Submission Date: "), submissionDate,
      )
    )
  } else {
    pad(
      top: 3em,
      right: 10%,
      left: 10%,
      grid(
        columns: (3fr, 3fr),
        gutter: 1em,
        strong("Author: "), author,
        strong("Matriculation Number: "), matriculationNumber,
        strong("Place of Work: "), placeOfWork,
        strong("Supervisor: "), supervisor,
        strong("Start Date: "), startDate,
        strong("Submission Date: "), submissionDate,
      )
    )
  }

  pagebreak()
}