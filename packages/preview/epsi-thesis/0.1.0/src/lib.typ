#import "cover.typ": cover
#import "front.typ": front-matter
#import "body.typ": body-matter
#import "appendix.typ": appendix-matter
#import "bibliography.typ": bibliography-page


#let get(dict, key, default) = {
  if key in dict { dict.at(key) } else { default }
}


#let project(config) = {
  // Configuração global de texto
  set text(
    font: ("NewsGotT", "Times New Roman", "Liberation Serif"),
    size: 12pt,
    lang: if get(config, "language", "PT") == "EN" { "en" } else { "pt" }
  )

  // Extrair valores com defaults
  let title = get(config, "title", "")
  let author = get(config, "author", "")
  let degree_type = get(config, "degree-type", "msc")
  let document_type = get(config, "document-type", "Dissertação de Mestrado")
  let degree_name = get(config, "degree-name", "Mestrado em X")
  let school_id = get(config, "school-id", "EP")
  let supervisors = get(config, "supervisors", ())
  let supervisor_gender = get(config, "supervisor-gender", "M")
  let year = get(config, "year", 2026)
  let month = get(config, "month", "fevereiro")
  let language = get(config, "language", "PT")
  let include_acknowledgements = get(config, "include-acknowledgements", false)
  let include_funding = get(config, "include-funding", false)
  let include_abstract_pt = get(config, "include-abstract-pt", false)
  let include_acronyms = get(config, "include-acronyms", false)
  let include_glossary = get(config, "include-glossary", false)
  let include_bibliography = get(config, "include-bibliography", false)
  let bibliography_style = get(config, "bibliography-style", "ieee")
  let copyright_content = get(config, "copyright-content", [])
  let acknowledgements = get(config, "acknowledgements", [])
  let funding = get(config, "funding", [])
  let integrity_content = get(config, "integrity-content", [])
  let ai_tools_content = get(config, "ai-tools-content", [])
  let abstract_pt = get(config, "abstract-pt", [])
  let keywords_pt = get(config, "keywords-pt", ())
  let abstract_en = get(config, "abstract-en", [])
  let keywords_en = get(config, "keywords-en", ())
  let body = get(config, "body", none)
  let appendix = get(config, "appendix", none)
  let bibliography_path = get(config, "bibliography-path", none)
  let acronyms_path = get(config, "acronyms-path", none)
  let glossary_path = get(config, "glossary-path", none)
  
  // Normalizar degree_type para o formato esperado
  let normalized_degree_type = if degree_type == "msc" { "mestrado" } else { "doutoramento" }
  
  // Criar capa
  cover(
    thesis-title: title,
    author: author,
    degree-type: normalized_degree_type,
    document-type: document_type,
    degree-name: degree_name,
    school-id: school_id,
    supervisors: supervisors,
    supervisor-gender: supervisor_gender,
    month: month,
    year
  )
  
  // Páginas frontais
  front-matter(
    language: language,
    include-acknowledgements: include_acknowledgements,
    include-funding: include_funding,
    include-abstract-pt: include_abstract_pt,
    include-acronyms: include_acronyms,
    include-glossary: include_glossary,
    copyright-content: copyright_content,
    acknowledgements: acknowledgements,
    funding: funding,
    integrity-content: integrity_content,
    ai-tools-content: ai_tools_content,
    abstract-pt: abstract_pt,
    keywords-pt: keywords_pt,
    abstract-en: abstract_en,
    keywords-en: keywords_en,
    thesis-title: title,
    acronyms-path: acronyms_path,
    glossary-path: glossary_path,
  )
  
  // Corpo do documento
  if body != none {
    body-matter(
      language: language,
      body
    )
  }
  
  // Bibliografia
  if include_bibliography and bibliography_path != none {
    bibliography-page(
      language: language,
      bibliography-style: bibliography_style,
      bibliography-path: bibliography_path
    )
  }
  
  // Apêndices
  if appendix != none {
    appendix-matter(
      language: language,
      appendix
    )
  }
}
