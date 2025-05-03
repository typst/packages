#import "utils.typ": *

// Função create-ct-area(): Cria subárea de área Educação e Popularização C&T
// Argumento:
//  - dados: o banco de dados com apresentações
//  - eu:  nome para destacaar
//  - cabecalho: cabeçalho para área
#let create-ct-area(dados, eu, cabecalho) = {
    [=== #cabecalho <ct_apresentacoes>]
            
    // criando números para oddem
    let i = dados.len()

    for entrada in dados.rev() {

        // criando sub-banco de dados para cada entrada
        let subset = entrada.DADOS-BASICOS-DA-APRESENTACAO-DE-TRABALHO
        
        // criando variáveis
        let evento = entrada.DETALHAMENTO-DA-APRESENTACAO-DE-TRABALHO.NOME-DO-EVENTO
        let ano = subset.ANO
        let titulo = subset.TITULO
        let palavras_chave = ()
        let conhecimento = () 

        // formatando os autores
        let autores = format-authors(entrada.AUTORES, eu)     

        // 
        let natureza = str(subset.NATUREZA.slice(0, 1) + lower(subset.NATUREZA.slice(1)))

        // corrigindo natureza
        if natureza == "Conferencia" {
            natureza = "Conferência ou Palestra"
        } else if natureza == "Seminario" {
            natureza = "Seminário"
        }
        
        // criando lista de palavras-chave
        if "PALAVRAS-CHAVE" in subset.keys() {
            for word in subset.PALAVRAS-CHAVE.keys() {
                if subset.PALAVRAS-CHAVE.at(word) != "" {
                    palavras_chave.push(subset.PALAVRAS-CHAVE.at(word))    
                }
            }
        }

        // criando string de palavras-chave
        if palavras_chave.len() > 0 {
            palavras_chave = palavras_chave.join("; ") + ";"
        }

        // criando áreas de conhecimento
        if "AREAS-DO-CONHECIMENTO" in subset.keys() {
            let areas = subset.at("AREAS-DO-CONHECIMENTO")

            let all_areas = ()

            let i = 0
            
            for key in areas.keys() {
                let subset2 = areas.at(key)

                // first check lowest unit, then go up
                if subset2.NOME-DA-ESPECIALIDADE != "" {
                    all_areas.push(subset2.NOME-DA-ESPECIALIDADE)
                } else if subset2.NOME-DA-SUB-AREA-DO-CONHECIMENTO != "" {
                    all_areas.push(subset2.NOME-DA-SUB-AREA-DO-CONHECIMENTO)
                } else if subset2.NOME-DA-AREA-DO-CONHECIMENTO != "" {
                    all_areas.push(subset2.NOME-DA-AREA-DO-CONHECIMENTO)
                } else if subset2.NOME-GRANDE-AREA-DO-CONHECIMENTO != "" {
                    all_areas.push(subset2.NOME-GRANDE-AREA-DO-CONHECIMENTO)
                }
            }

            if all_areas.len() == 0 {} else {
                conhecimento = [Áreas de conhecimento: #all_areas.join(", ")]
            }
        }

        // criando content para palavras-chave
        let palavras_content = []
        if palavras_chave.len() > 0 {
            palavras_content = [#text(rgb("B2B2B2"), size: 0.85em, "Palavras-chave: "+ palavras_chave) #linebreak()]
        } 
            
        // criando content para áreas de conhecimento 
        let areas_content = [] 
        if conhecimento.len() > 0 {
            areas_content = [#text(rgb("B2B2B2"), size: 0.85em, "Áreas de conhecimento: "+ conhecimento) #linebreak()]
        } 

        // criando conteúdo 
        let descricao_content = [#autores #titulo, #emph(evento), #ano (#natureza). #linebreak() #palavras_content #areas_content]

        // publicando content
        create-cols([*#i.*], [#descricao_content], "enum")

        // diminuir número (para ordem)
        i -= 1
    }
}


// Função create-education-ct(): Cria área Educação e Popularização 
// TODO: até agora somente apresentação de trabalho e palestra
// Argumento:
//  - detalhes: banco de dados de Lattes (em formato de TOML)
#let create-education-ct(detalhes, eu) = {

    // Dados de congressos não são vinculados com a atuação
    // criando banco de dados
    // educacao e popularizacao de C&T
    let eventos = detalhes.PRODUCAO-TECNICA.DEMAIS-TIPOS-DE-PRODUCAO-TECNICA

    // criando banco de dados de apresentações
    let congressos = eventos.APRESENTACAO-DE-TRABALHO

    // ordenar por ano 
    congressos = congressos.sorted(key: (item) => (item.DADOS-BASICOS-DA-APRESENTACAO-DE-TRABALHO.ANO, item.DADOS-BASICOS-DA-APRESENTACAO-DE-TRABALHO.TITULO))

    // filtrar para eles com inovação
    congressos = congressos.filter(
        entry => entry.DADOS-BASICOS-DA-APRESENTACAO-DE-TRABALHO.FLAG-DIVULGACAO-CIENTIFICA == "SIM"
    )
    
    // somente criar se tiver uma entrada ao mínimo
    if congressos.len() > 0 {
        // criando cabeçalho 
        // TODO: até agora somente essa categoria, com mais categorias precisa mudar com conector or 
        [== Educação e Popularização de C&T <ct>]
    }

    // entradas de apresentações
    if congressos.len() > 0 {
        create-ct-area(congressos, eu, "Apresentação de trabalho e palestra")
    }

 }