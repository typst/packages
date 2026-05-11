#import "../../layout.typ": dict
#import "../../yaml_parser.typ": load-and-render-yaml

#let abbreviations-page(language: "PT", acronyms-path: none) = {
  if acronyms-path == none {
    return
  }
  
  pagebreak()
  
  heading(outlined: false)[#dict("acronyms", lang: language)]

  // Caminho relativo ao template
  let full_path = if acronyms-path.starts-with("../") { acronyms-path } else { "../template/" + acronyms-path }
  load-and-render-yaml(full_path)
}

