#import "../../layout.typ": dict
#import "../../yaml_parser.typ": load-and-render-yaml

#let glossary-page(language: "PT", glossary_path: none) = {
  if glossary_path == none {
    return
  }
  
  pagebreak()
  
  heading(outlined: false)[#dict("glossary", lang: language)]

  // Caminho relativo ao template
  let full_path = if glossary_path.starts-with("../") { glossary_path } else { "../template/" + glossary_path }
  load-and-render-yaml(full_path)
}

