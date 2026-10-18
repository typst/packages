#import "layout.typ": apply-standard-layout

#let body-matter(language: "PT", body) = {
  // Reset da numeração de páginas para o corpo do documento
  counter(page).update(1)
  set page(numbering: "1", margin: 2.5cm)

  apply-standard-layout(lang: language)[
    #body
  ]
}

