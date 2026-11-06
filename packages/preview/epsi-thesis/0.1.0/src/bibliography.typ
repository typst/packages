#import "layout.typ": apply-standard-layout, dict

#let bibliography-page(language: "PT", bibliography-style: "ieee", bibliography-path: none) = {
  if bibliography-path == none {
    return
  }
  
  pagebreak()
  
  let bib_title = dict("bibliography", lang: language)

  // Caminho relativo ao template
  let full_path = if bibliography-path.starts-with("../") { bibliography-path } else { "../template/" + bibliography-path }

  apply-standard-layout(lang: language)[
    #bibliography(full_path, title: bib_title, style: bibliography-style)
  ]
}

