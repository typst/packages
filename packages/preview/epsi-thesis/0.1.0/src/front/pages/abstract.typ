#import "../../layout.typ": dict

#let abstract-page(language: "PT", thesis-title: "", abstract-pt: [], keywords-pt: ()) = {
  pagebreak()

  // Título da Tese
  align(center)[
    #text( weight: "bold")[
      #thesis-title
    ]
  ]

  //Título da Página
  [#heading(outlined: false)[#dict("abstract", lang: language)]]
  
  // Conteúdo do resumo
  abstract-pt
  
  v(2em)
  
  // Palavras-chave
  [
    *#dict("keywords", lang: language):* #keywords-pt.join(", ")
  ]
}

