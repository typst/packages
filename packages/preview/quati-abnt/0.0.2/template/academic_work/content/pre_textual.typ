// # Pre-textual elements. Elementos pré-textuais.
// NBR 14724:2024 4.2.1

#import "../data/glossary.typ": abbreviations_entries
#import "../data/glossary.typ": symbols_entries
#import "../data/data.typ": (
  address, advisors, approval_date, area_of_concentration, authors, custom_nature, degree, degree_topic,
  examination_committee, institution, organization, program, subtitle, title, type_of_work, volume_number, year,
)
#import "../packages.typ": (
  quati-abnt.academic_work.pages.include_acknowledgments_page, quati-abnt.academic_work.pages.include_approval_page,
  quati-abnt.academic_work.pages.include_cataloging_in_publication,
  quati-abnt.academic_work.pages.include_custom_cataloging_in_publication,
  quati-abnt.academic_work.pages.include_dedication_page, quati-abnt.academic_work.pages.include_epigraph_page,
  quati-abnt.academic_work.pages.include_errata_page, quati-abnt.academic_work.pages.include_list_of_abbreviations_page,
  quati-abnt.academic_work.pages.include_list_of_figures_page,
  quati-abnt.academic_work.pages.include_list_of_symbols_page,
  quati-abnt.academic_work.pages.include_list_of_tables_page, quati-abnt.academic_work.pages.include_outline_page,
  quati-abnt.academic_work.pages.include_title_page,
)
#import "./abstract.typ": abstract_in_main_language

#let keywords_in_main_language = abstract_in_main_language.keywords


// ====================
// ## Title page. Folha de rosto.
// NBR 14724:2024 4.2.1.1.1

#include_title_page(
  address: address,
  advisors: advisors,
  area_of_concentration: area_of_concentration,
  authors: authors,
  custom_nature: custom_nature,
  degree_topic: degree_topic,
  degree: degree,
  organization: organization,
  program: program,
  subtitle: subtitle,
  title: title,
  type_of_work: type_of_work,
  volume_number: volume_number,
  year: year,
)

// ====================


// ====================
// ## Cataloging-in-publication. Ficha catalográfica.
// NBR 14724:2024 4.2.1.1.2

// This is just an example for the cataloging in publication. When your institution provides you with the final file, you must use the command `include_custom_cataloging_in_publication`, filling it with the command `image` and with the path to the file. Then, remove the command `include_cataloging_in_publication` below.
//
// Este é apenas um exemplo para a ficha catalográfica. Quando sua instituição fornecer o arquivo final, você deve usar o comando `include_custom_cataloging_in_publication`, preenchendo-o com o comando `image` e com caminho para o arquivo. Então, remova o comando `include_cataloging_in_publication` abaixo.

#include_cataloging_in_publication(
  address: address,
  advisors: advisors,
  authors: authors,
  degree: degree,
  institution: institution,
  keywords_in_main_language: keywords_in_main_language,
  organization: organization,
  program: program,
  subtitle: subtitle,
  title: title,
  type_of_work: type_of_work,
  volume_number: volume_number,
  year: year,
)

// If you have a file to import, use the command below.
// Se você tem um arquivo para importar, use o comando abaixo.

// #include_custom_cataloging_in_publication(image("../assets/documents/ficha_catalografica.pdf"))

// ====================


// ====================
// ## Errata. Errata.
// NBR 14724:2024 4.2.1.2

// If there is not anything to correct, you can just remove the following block.
//
// Se não houver alguma correção a fazer, você pode apenas remover o bloco a seguir.

#include_errata_page()[
  #lorem(50)
]

// ====================


// ====================
// ## Approval page. Folha de aprovação.
// NBR 14724:2024 4.2.1.3

#include_approval_page(
  address: address,
  advisors: advisors,
  approval_date: approval_date,
  area_of_concentration: area_of_concentration,
  authors: authors,
  custom_nature: custom_nature,
  degree_topic: degree_topic,
  degree: degree,
  examination_committee: examination_committee,
  organization: organization,
  program: program,
  subtitle: subtitle,
  title: title,
  type_of_work: type_of_work,
  volume_number: volume_number,
  year: year,
)

// ====================


// ====================
// # Dedication. Dedicatória.
// NBR 14724:2024 4.2.1.4, NBR 14724:2024 5.2.4

// If there is not any dedication, you can just remove the following block.
//
// Se não houver alguma dedicatória a fazer, você pode apenas remover o bloco a seguir.

#include_dedication_page()[
  Dedicamos este trabalho àqueles que contribuem com a organização e com o compartilhamento da informação, sobretudo àqueles que o fazem de forma livre e cooperativa.
]

// ====================


// ====================
// # Acknowledgments. Agradecimentos.
// NBR 14724:2024 4.2.1.6

// If there is not any acknowledgments, you can just remove the following block.
//
// Se não houver algum agradecimento a fazer, você pode apenas remover o bloco a seguir.

#include_acknowledgments_page()[
  #lorem(50)
]

// ====================


// ====================
// # Epigraph. Epígrafe.
// NBR 14724:2024 4.2.1.6

// If there is not any epigraph, you can just remove the following block.
//
// Se não houver alguma epígrafe a fazer, você pode apenas remover o bloco a seguir.

#{
  set par(first-line-indent: 0pt)
  include_epigraph_page(
    quote(
      attribution: [@dumont:1918:o_que_eu_vi_o_que_nos_veremos[p. 15].],
      block: true,
    )[

      --- Quero um balão de cem metros cúbicos.

      Grande espanto!
      Creio mesmo que pensaram que eu era doido.
      Alguns meses depois, o "Brasil", com grande espanto de todos os entendidos, atravessava Paris, lindo na sua transparência, como uma grande bola de sabão
    ],
  )
}

// ====================


// ====================

#include "abstract.typ"

// ====================


// ====================
// ## List of figures. Lista de ilustrações.
// NBR 14724:2024 4.2.1.9

#context {
  if counter(figure).final().first() > 0 {
    include_list_of_figures_page()
  }
}

// ====================


// ====================
// ## List of tables. Lista de tabelas.
// NBR 14724:2024 4.2.1.10

#context {
  if counter(table).final().first() > 0 {
    include_list_of_tables_page()
  }
}
// ====================


// ====================
// ## Abbreviations. Lista de abreviaturas e siglas.
// NBR 14724:2024 4.2.1.11

#if (abbreviations_entries.len() > 0) {
  include_list_of_abbreviations_page(
    abbreviations_entries,
  )
}
// ====================


// ====================
// ## List of symbols. Lista de símbolos.
// NBR 14724:2024 4.2.1.12

#if (symbols_entries.len() > 0) {
  include_list_of_symbols_page(
    symbols_entries,
  )
}
// ====================


// ====================
// ## Outline. Sumário.
// NBR 6027:2012, NBR 14724:2024 4.2.1.13

#include_outline_page()

// ====================
