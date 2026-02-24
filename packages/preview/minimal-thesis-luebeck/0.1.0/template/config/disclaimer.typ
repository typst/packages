#let disclaimer(
  title: "",
  degree: "",
  author: "",
  submission-date: datetime,
) = {
  let body-font = "New Computer Modern"
  let sans-font = "New Computer Modern Sans"

  set text(
    font: body-font, 
    size: 12pt
  )
  
  // --- Disclaimer ---  
  v(65%)
  text("Eidesstattliche Erklärung" + parbreak() + "Ich erkläre hiermit an Eides statt, dass ich diese Arbeit selbständig verfasst und keine anderen als die angegebenen Quellen und Hilfsmittel benutzt habe." + parbreak() + emph(author))
}
