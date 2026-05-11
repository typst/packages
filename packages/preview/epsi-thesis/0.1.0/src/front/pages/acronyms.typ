#import "../../layout.typ": dict
#import "../../yaml_parser.typ": load-and-render-yaml

#let abbreviations-page(language: "PT", acronyms_path: none) = {
  if acronyms_path == none {
    return
  }
  
  pagebreak()
  
  heading(outlined: false)[#dict("acronyms", lang: language)]

  // Caminho relativo ao template
  let full_path = if acronyms_path.starts-with("../") { acronyms_path } else { "../template/" + acronyms_path }
  load-and-render-yaml(full_path)
}

