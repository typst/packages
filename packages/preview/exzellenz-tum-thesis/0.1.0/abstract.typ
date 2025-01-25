#let abstract(body, lang: "en") = {

  let überschriften = (en: "Abstract", de: "Zusammenfassung")

  set text(
    size: 12pt, 
    lang: lang
  )
  
  set par(leading: 1em)

  
  v(1fr)

  align(center, text(1.2em, weight: 600, überschriften.at(lang)))
  
  align(
    center, 
    text[
      #body
    ]
  )
  
  v(1fr)

  pagebreak()
}