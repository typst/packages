#let abstract(body, lang: "en") = {


  let überschriften = (en: "Abstract", de: "Zusammenfassung")
  
  align(left, text(1.4em, weight: 600, überschriften.at(lang)))
  body


}