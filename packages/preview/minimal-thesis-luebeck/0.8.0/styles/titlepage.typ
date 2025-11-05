#let titlepage(
  top-left-img: none,
  top-right-img: none,
  title-english: none,
  title-german: none,
  degree: none,
  institute: none,
  program: none,
  university: none,
  company: none,
  author: none,
  supervisor: none,
  advisor: none,
  place: none,
  submission-date: none,
  slogan-img: none,
  dark-color: black,
  light-color: gray,
  sans-font: none
) = {
  set page(
    margin: (left: 20mm, right: 20mm, top: 20mm, bottom: 30mm),
    footer: none
  )
  set text(
    font: sans-font, 
    size: 11pt
  )
  set par(leading: 0.5em)

  // --- Title Page ---
  grid(
    columns: (4cm, 4cm),
    gutter: 1fr,
    top-left-img,
    top-right-img
  )
  v(10mm)

  context {
    let lang = text.lang
    if lang == "de" {
      align(left, text(16pt, strong(title-german), fill: dark-color))
      align(left, text(16pt, title-english, fill: dark-color))
      align(left, text(weight: "bold", degree + "arbeit"))
    } else {
      align(left, text(16pt, strong(title-english), fill: dark-color))
      align(left, text(16pt, title-german, fill: dark-color))
      align(left, text(weight: "bold", degree + "’s Thesis"))
    }

  }

  align(left, "verfasst am\n" + strong(institute))

  align(left, "im Rahmen des Studiengangs\n" + strong(program) + "\nder " + university)

  if company != none {
    align(left, "im Rahmen einer Tätigkeit bei der Firma\n" + strong(company))
  }

  align(left, "vorgelegt von\n" + strong(author))

  align(left, "ausgegeben und betreut von\n" + strong(supervisor))

  align(left, "mit Unterstützung von\n" + strong(advisor))

  align(bottom,
    grid(
      columns: (5cm, 3.5cm),
      gutter: 1fr,
      place + ", den " + submission-date.display("[day].[month].[year]"),
      slogan-img
    )
  )
}