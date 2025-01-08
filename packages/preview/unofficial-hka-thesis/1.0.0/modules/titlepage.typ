#let openTitlePage(settings: ()) = {
  set page(
    paper: "a4",
    margin: (left: 30mm, right: 30mm, top: 40mm, bottom: 40mm),
    numbering: "I",
    number-align: center,
    footer: ""
  )

  set text(
    font: settings.font-body, 
    size: settings.font-body-size, 
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
  title-german: "",
  subtitle-german: "",
  author: "",
  matriculation-number: "",
  place-of-work: "",
  supervisor: "",
  advisor: "",
  startDate: none,
  submission-date: none,
) = {

  v(5mm)
  align(center, text(font: settings.fontHeading, 1.9em, weight: 700, "University of Applied Sciences Karlsruhe"))
  
  v(15mm)

  align(center, text(font: settings.fontHeading, 1.5em, weight: 100, degree + "’s Thesis in " + program))
  v(8mm)

  if title-german.len() > 0 {
    if subtitle.len() > 0 or subtitle-german.len() > 0 {
      align(center, text(font: settings.fontHeading, 1.2em, weight: 700, title))
      align(center, text(font: settings.fontHeading, 1.2em, weight: 500, subtitle))
      v(10mm)
      align(center, text(font: settings.fontHeading, 1.2em, weight: 700, title-german))
      align(center, text(font: settings.fontHeading, 1.2em, weight: 500, subtitle-german))  
    } else {
      align(center, text(font: settings.fontHeading, 1.4em, weight: 700, title))
      v(10mm)
      align(center, text(font: settings.fontHeading, 1.4em, weight: 700, title-german))
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
        strong("Matriculation Number: "), matriculation-number,
        strong("Place of Work: "), place-of-work,
        strong("Supervisor: "), supervisor,
        strong("Advisor: "), advisor,
        strong("Start Date: "), startDate,
        strong("Submission Date: "), submission-date,
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
        strong("Matriculation Number: "), matriculation-number,
        strong("Place of Work: "), place-of-work,
        strong("Supervisor: "), supervisor,
        strong("Start Date: "), startDate,
        strong("Submission Date: "), submission-date,
      )
    )
  }

  pagebreak()
}