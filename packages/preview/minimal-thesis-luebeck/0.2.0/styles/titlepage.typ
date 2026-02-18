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
  sans-font: none
) = {
  set page(
    margin: (left: 20mm, right: 20mm, top: 20mm, bottom: 30mm),
    numbering: none,
    number-align: center,
  )
  set text(
    font: sans-font, 
    size: 12pt, 
    lang: "en"
  )
  set par(leading: 0.5em)

  // --- Title Page ---
  grid(
    columns: (4cm, 4cm),
    gutter: 1fr,
    top-left-img,
    top-right-img
  )
  v(5mm)

  align(center, text(2em, strong(title-english)))

  align(center, text(2em, title-german))
  v(15mm)

  align(left, text(weight: "bold",
  degree + "’s Thesis"
  ))

  align(left, "verfasst am\n" + strong(institute))

  align(left, "im Rahmen des Studiengangs\n" + strong(program) + "\nder " + university)

  if company != none {
    align(left, "im Rahmen einer Tätitgkeit bei der Firma\n" + strong(company))
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