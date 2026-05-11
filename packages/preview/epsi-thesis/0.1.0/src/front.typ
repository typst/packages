#import "layout.typ": apply-standard-layout
#import "front/pages/copyright.typ": copyright-page
#import "front/pages/acknowledgements.typ": acknowledgements-page
#import "front/pages/funding.typ": funding-page
#import "front/pages/integrity.typ": integrity-page
#import "front/pages/abstract.typ": abstract-page
#import "front/pages/abstract-en.typ": abstract-en-page
#import "front/pages/index.typ": *
#import "front/pages/acronyms.typ": abbreviations-page
#import "front/pages/glossary.typ": glossary-page

#let front-matter(
  language: "PT",
  include_acknowledgements: false,
  include_funding: false,
  include_abstract_pt: false,
  include_acronyms: false,
  include_glossary: false,
  copyright_content: [],
  acknowledgements: [],
  funding: [],
  integrity_content: [],
  ai_tools_content: [],
  abstract_pt: [],
  keywords_pt: (),
  abstract_en: [],
  keywords_en: (),
  thesis_title: "",
  acronyms_path: none,
  glossary_path: none,
) = {
  counter(page).update(1)

  apply-standard-layout(lang: language)[
    
    // Direitos de Autor
    #copyright-page(language: language, copyright_content: copyright_content)

    // Agradecimentos
    #if include_acknowledgements {
      acknowledgements-page(language: language, acknowledgements: acknowledgements)
    }

    // Financiamento
    #if include_funding {
      funding-page(language: language, funding: funding)
    }

    //Integridade
    #integrity-page(language: language, integrity_content: integrity_content, ai_tools_content: ai_tools_content)

    // Resumo Português
    #if include_abstract_pt {
      abstract-page(
        language: language,
        thesis_title: thesis_title,
        abstract_pt: abstract_pt,
        keywords_pt: keywords_pt
      )
    }
    
    // Resumo Inglês
    #abstract-en-page(
      language: language,
      thesis_title: thesis_title,
      abstract_en: abstract_en,
      keywords_en: keywords_en
    )

    //Índice Geral
    #table-of-contents(language: language)
    
    //Lista de Figuras
    #list-of-figures(language: language)

    //Lista de Tabelas
    #list-of-tables(language: language)

    //Abreviaturas e Siglas
    #if include_acronyms and acronyms_path != none {
      abbreviations-page(language: language, acronyms_path: acronyms_path)
    }

    // Glossário
    #if include_glossary and glossary_path != none {
      glossary-page(language: language, glossary_path: glossary_path)
    }
  ]
}

