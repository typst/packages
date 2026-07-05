#import "@preview/datify:0.1.3": *
#import "import.typ": *

// Função lattes-cv: criar o PDF com os dados de lattes
// Arguments:
// - database: o arquivo de TOML com os dados de Lattes (string)
// - kind: o tipo de currículo Lattes (string)
// - me: o nome para destacar nas citações (string)
// - last-page: resumo de produção no final (boolean)
// - data: a data de currículo (datetime)
// - subtitle: para a página inicial 
#let lattes-cv(
  database,
  kind: "completo", 
  me: str,
  last-page: true,
  date: datetime.today(),
  subtitle: "Curriculum Vitae",
  body,
) = {
    // define details:
    let details = database

    // define author
    let author = details.DADOS-GERAIS.NOME-COMPLETO

    
    // define the document 
    set document(title: "CV Lattes", author: author)

    // set text options (size, font, language)
    set text(
        size: 12pt,
        font: "Source Sans Pro",
        lang: "pt", 
        region: "br"
    )

    // create title page
    set page(
        paper: "a4",
        margin: (top: 2cm, bottom: 2cm, left: 2cm, right: 2cm)
    )
    
    align(horizon + center)[
        #text(20pt, author, weight: "bold", fill: rgb("B2B2B2"))
        
        #text(subtitle, weight: "semibold")
    ]

    align(bottom + center)[
        #text(custom-date-format(date, "Month de YYYY", "pt"))
    ]

    pagebreak()

    // rest of the document
    set page(
        paper: "a4",
        margin: (top: 2cm, bottom: 2cm, left: 2cm, right: 2cm),
        footer: context [
            #set align(right)
            #set text(8pt)
            Página #counter(page).display("1 de 1", both: true)
        ]
    )

    // new numbering beginning from 1
    counter(page).update(1)

    // section on personal information
    align(top + left)[
        #text(20pt, author, weight: "bold", fill: rgb("B2B2B2"))

        #text(subtitle + " (" + kind + ")", weight: "regular")
    ]

    line(length: 100%)

    // Begin Content
    create-identification(details)  
    
    if kind != "resumido" {
        // Área de idiomas
        create-languages(details)
    }    

    // Área de formação
    create-education(details, kind)
    
    // Área de formação complementar
    create-advanced-training(details)

    // Área de atuação
    create-experience(details)
    
    if kind == "completo" {
        create-projects(details, me)
    }    

    // Área de revisor
    create-reviewer(details)

    // Área de conhecimento
    if kind != "resumido" {
        // Áreas de conhecimento
        create-areas-work(details)

        // Área de prêmios e títulos
        create-prices(details)
    }

    // Produção bibliográfica
    create-bibliography(details, me, kind)

    if kind == "completo" {
        // área de bancas
        create-examinations(details, me)

        // área de eventos
        create-events(details, me)
    }

    // Área de orientações e supervisões
    create-supervisions(details)

    // Área de inovação
    if kind == "completo" {
        create-innovations(details, me)

        create-education-ct(details, me)
    }

    // Resumo de produções na última página
    if last-page == true {
        pagebreak()

        create-last-page(details, kind)
    } 
}        