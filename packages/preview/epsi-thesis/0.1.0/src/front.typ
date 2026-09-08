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
  include-acknowledgements: false,
  include-funding: false,
  include-abstract-pt: false,
  include-acronyms: false,
  include-glossary: false,
  copyright-content: [],
  acknowledgements: [],
  funding: [],
  integrity-content: [],
  ai-tools-content: [],
  abstract-pt: [],
  keywords-pt: (),
  abstract-en: [],
  keywords-en: (),
  thesis-title: "",
  acronyms-path: none,
  glossary-path: none,
) = {
  counter(page).update(1)

  apply-standard-layout(lang: language)[
    
    // Direitos de Autor
    #copyright-page(language: language, copyright-content: copyright-content)

    // Agradecimentos
    #if include-acknowledgements {
      acknowledgements-page(language: language, acknowledgements: acknowledgements)
    }

    // Financiamento
    #if include-funding {
      funding-page(language: language, funding: funding)
    }

    //Integridade
    #integrity-page(language: language, integrity-content: integrity-content, ai-tools-content: ai-tools-content)

    // Resumo Português
    #if include-abstract-pt {
      abstract-page(
        language: language,
        thesis-title: thesis-title,
        abstract-pt: abstract-pt,
        keywords-pt: keywords-pt
      )
    }
    
    // Resumo Inglês
    #abstract-en-page(
      language: language,
      thesis-title: thesis-title,
      abstract-en: abstract-en,
      keywords-en: keywords-en
    )

    //Índice Geral
    #table-of-contents(language: language)
    
    //Lista de Figuras
    #list-of-figures(language: language)

    //Lista de Tabelas
    #list-of-tables(language: language)

    //Abreviaturas e Siglas
    #if include-acronyms and acronyms-path != none {
      abbreviations-page(language: language, acronyms-path: acronyms-path)
    }

    // Glossário
    #if include-glossary and glossary-path != none {
      glossary-page(language: language, glossary-path: glossary-path)
    }
  ]
}

