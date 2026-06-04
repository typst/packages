#let titlepage(
  title: "",
  subtitle: "",
  type: "",
  professor: "",
  author: "",
  matriculation-number: "",
  submission-date: datetime,
  abstract: "",
  language: "en",
) = {
  set page(
    margin: (left: 2.5cm, right: 2.5cm, top: 2.5cm, bottom: 2.5cm),
    numbering: none,
    number-align: center,
  )

  let body-font = "Libertinus Serif"

  set text(
    font: body-font,
    size: 12pt,
    lang: language,
  )

  set par(leading: 0.5em)


  // --- Title Page ---
  align(center, image("/template/figures/unisg_logo.png", width: 15%))
  let universityName = (en: "University of St. Gallen", de: "Universität St. Gallen")
  align(center, text(font: body-font, 18pt, weight: 500, upper(universityName.at(language))))
  let universityHeader = (
    en: "School of Management, Economics,\n Law, Social Sciences, International Affairs and Computer Science",
    de: "Hochschule für Wirtschafts-, Rechts- und Sozialwissenschaften,\n Internationale Beziehungen und Informatik",
  )
  align(center, text(font: body-font, 11pt, weight: 500, universityHeader.at(language)))

  v(1fr)
  line(length: 100%, stroke: 0.5pt + gray)
  align(center, text(font: body-font, 16pt, weight: 400, type))
  align(center, text(font: body-font, 20pt, weight: 700, title))
  align(center, text(font: body-font, 16pt, weight: 400, subtitle))
  line(length: 100%, stroke: 0.5pt + gray)
  v(1fr)


  let submittedBy = (en: "Submitted by", de: "Eingereicht von")
  let approvedBy = (en: "Approved on Application by:", de: "Genehmigt auf Antrag von:")
  let submission-dateText = (en: "Date of Submission:", de: "Einreichungsdatum:")
  align(
    center,
    text(font: body-font, 12pt, weight: 400, submittedBy.at(language) + ": \n" + author + "\n" + matriculation-number),
  )
  align(center, text(font: body-font, 12pt, weight: 400, approvedBy.at(language) + "\n" + professor))
  v(5mm)
  align(
    center,
    text(
      font: body-font,
      12pt,
      weight: 400,
      submission-dateText.at(language)
        + "\n"
        + submission-date.display("[day padding:zero].[month padding:zero].[year repr:full]"),
    ),
  )
}
