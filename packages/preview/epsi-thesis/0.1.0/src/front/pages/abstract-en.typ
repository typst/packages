#import "../../layout.typ": dict

#let abstract-en-page(language: "PT", thesis_title: "", abstract_en: [], keywords_en: ()) = {
  pagebreak()

  // Título da tese
  align(center)[
    #text(weight: "bold")[
      #thesis_title
    ]
  ]

  // Título da página
  [#heading(outlined: false)[Abstract]]
  
  
  // Conteúdo do resumo
  abstract_en
  
  v(2em)
  
  // Palavras-chave
  [
    *Keywords:* #keywords_en.join(", ")
  ]
}

