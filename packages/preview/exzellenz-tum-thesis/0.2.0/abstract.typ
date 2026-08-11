#let abstract(body) = {

  set text(
    size: 12pt, 
    lang: "en"
  )
  
  set par(leading: 1em)

  
  v(1fr)

  align(center, text(1.2em, weight: 600, "Abstract"))
  
  align(
    center, 
    text[
      #body
    ]
  )
  
  v(1fr)

  pagebreak()
}