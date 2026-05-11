#import "../../layout.typ": dict

#let abstract-page(language: "PT", thesis_title: "", abstract_pt: [], keywords_pt: ()) = {
  pagebreak()

  // Título da Tese
  align(center)[
    #text( weight: "bold")[
      #thesis_title
    ]
  ]

  //Título da Página
  [#heading(outlined: false)[#dict("abstract", lang: language)]]
  
  // Conteúdo do resumo
  abstract_pt
  
  v(2em)
  
  // Palavras-chave
  [
    *#dict("keywords", lang: language):* #keywords_pt.join(", ")
  ]
}

