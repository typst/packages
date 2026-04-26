

#let abstract(body, lang: "en") = {


  let überschriften = (en: "Abstract", de: "Zusammenfassung")
  



  
  v(1fr)

  align(center, text(1.4em, weight: 600, überschriften.at(lang)))
  body
  
  v(1fr)

  pagebreak()
}