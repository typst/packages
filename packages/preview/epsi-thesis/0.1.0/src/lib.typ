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
  let degree_type = get(config, "degree_type", "msc")
  let document_type = get(config, "document_type", "Dissertação de Mestrado")
  let degree_name = get(config, "degree_name", "Mestrado em X")
  let school_id = get(config, "school_id", "EP")
  let supervisors = get(config, "supervisors", ())
  let supervisor_gender = get(config, "supervisor_gender", "M")
  let year = get(config, "year", 2026)
  let month = get(config, "month", "fevereiro")
  let language = get(config, "language", "PT")
  let include_acknowledgements = get(config, "include_acknowledgements", false)
  let include_funding = get(config, "include_funding", false)
  let include_abstract_pt = get(config, "include_abstract_pt", false)
  let include_acronyms = get(config, "include_acronyms", false)
  let include_glossary = get(config, "include_glossary", false)
  let include_bibliography = get(config, "include_bibliography", false)
  let bibliography_style = get(config, "bibliography_style", "ieee")
  let copyright_content = get(config, "copyright_content", [])
  let acknowledgements = get(config, "acknowledgements", [])
  let funding = get(config, "funding", [])
  let integrity_content = get(config, "integrity_content", [])
  let ai_tools_content = get(config, "ai_tools_content", [])
  let abstract_pt = get(config, "abstract_pt", [])
  let keywords_pt = get(config, "keywords_pt", ())
  let abstract_en = get(config, "abstract_en", [])
  let keywords_en = get(config, "keywords_en", ())
  let body = get(config, "body", none)
  let appendix = get(config, "appendix", none)
  let bibliography_path = get(config, "bibliography_path", none)
  let acronyms_path = get(config, "acronyms_path", none)
  let glossary_path = get(config, "glossary_path", none)
  
  // Normalizar degree_type para o formato esperado
  let normalized_degree_type = if degree_type == "msc" { "mestrado" } else { "doutoramento" }
  
  // Criar capa
  cover(
    thesis_title: title,
    author: author,
    degree_type: normalized_degree_type,
    document_type: document_type,
    degree_name: degree_name,
    school_id: school_id,
    supervisors: supervisors,
    supervisor_gender: supervisor_gender,
    month: month,
    year
  )
  
  // Páginas frontais
  front-matter(
    language: language,
    include_acknowledgements: include_acknowledgements,
    include_funding: include_funding,
    include_abstract_pt: include_abstract_pt,
    include_acronyms: include_acronyms,
    include_glossary: include_glossary,
    copyright_content: copyright_content,
    acknowledgements: acknowledgements,
    funding: funding,
    integrity_content: integrity_content,
    ai_tools_content: ai_tools_content,
    abstract_pt: abstract_pt,
    keywords_pt: keywords_pt,
    abstract_en: abstract_en,
    keywords_en: keywords_en,
    thesis_title: title,
    acronyms_path: acronyms_path,
    glossary_path: glossary_path,
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
      bibliography_style: bibliography_style,
      bibliography_path: bibliography_path
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
