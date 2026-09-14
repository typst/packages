#import "../../layout.typ": dict
#import "../../yaml_parser.typ": load-and-render-yaml

#let glossary-page(language: "PT", glossary-path: none) = {
  if glossary-path == none {
    return
  }
  
  pagebreak()
  
  heading(outlined: false)[#dict("glossary", lang: language)]

  // Caminho relativo ao template
  let full_path = if glossary-path.starts-with("../") { glossary-path } else { "../template/" + glossary-path }
  load-and-render-yaml(full_path)
}

