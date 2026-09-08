#import "../../layout.typ": dict

#let abstract-en-page(language: "PT", thesis-title: "", abstract-en: [], keywords-en: ()) = {
  pagebreak()

  // Título da tese
  align(center)[
    #text(weight: "bold")[
      #thesis-title
    ]
  ]

  // Título da página
  [#heading(outlined: false)[Abstract]]
  
  
  // Conteúdo do resumo
  abstract-en
  
  v(2em)
  
  // Palavras-chave
  [
    *Keywords:* #keywords-en.join(", ")
  ]
}

