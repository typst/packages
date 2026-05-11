#import "layout.typ": apply-standard-layout, dict

#let bibliography-page(language: "PT", bibliography_style: "ieee", bibliography_path: none) = {
  if bibliography_path == none {
    return
  }
  
  pagebreak()
  
  let bib_title = dict("bibliography", lang: language)

  // Caminho relativo ao template
  let full_path = if bibliography_path.starts-with("../") { bibliography_path } else { "../template/" + bibliography_path }

  apply-standard-layout(lang: language)[
    #bibliography(full_path, title: bib_title, style: bibliography_style)
  ]
}

