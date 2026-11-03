#import "../../layout.typ": dict

// Índice Geral
#let table-of-contents(language: "PT") = {
  pagebreak()
  
  heading(outlined: false)[#dict("toc", lang: language)]

  outline(
    title: none,
    depth: 2,
    indent: auto
  )
}

// Lista de Figuras
#let list-of-figures(language: "PT") = context {
  let figs = query(figure.where(kind: image))
  if figs.len() > 0 {
    pagebreak()
    
    heading(outlined: false)[#dict("lof", lang: language)]
    
    outline(
      title: none,
      target: figure.where(kind: image)
    )
  }
}

// Lista de Tabelas
#let list-of-tables(language: "PT") = context {
  let tabs = query(figure.where(kind: table))
  if tabs.len() > 0 {
    pagebreak()
    
    heading(outlined: false)[#dict("lot", lang: language)]
    
    outline(
      title: none,
      target: figure.where(kind: table)
    )
  }
}

