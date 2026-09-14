#import "utils.typ": * 

// Função create-participation-events(): Cria entradas eventos
// Argumento:
//  - dados-participation: sub-banco de dados para participação nos eventos
#let create-participation-events(dados-participation, eu) = {

    // criando variáveis
    let descricao_content = []

    if dados-participation.len() > 0 {

        [= Eventos <eventos>]

        let helper_array = ()
        let participacoes = ()


        // tirando todos eventos de sub-arrays
        for tipo in dados-participation {
            let subset = tipo.at(1)
            for event in subset {
                helper_array.push(event)
            }
        }

        // criando ORDER para ordenar
        // duplicar DADOS BASICOS porque nome é sempre diferente
        for entry in helper_array {
            if "DADOS-BASICOS-DA-PARTICIPACAO-EM-CONGRESSO" in entry.keys() {
                entry.insert("DADOS-BASICOS", entry.DADOS-BASICOS-DA-PARTICIPACAO-EM-CONGRESSO)
                entry.insert("NOME-DO-EVENTO", entry.DETALHAMENTO-DA-PARTICIPACAO-EM-CONGRESSO.NOME-DO-EVENTO)
            }
            if "DADOS-BASICOS-DA-PARTICIPACAO-EM-SIMPOSIO" in entry.keys() {
                entry.insert("DADOS-BASICOS", entry.DADOS-BASICOS-DA-PARTICIPACAO-EM-SIMPOSIO)
                entry.insert("NOME-DO-EVENTO", entry.DETALHAMENTO-DA-PARTICIPACAO-EM-SIMPOSIO.NOME-DO-EVENTO)
            }
            if "DADOS-BASICOS-DA-PARTICIPACAO-EM-ENCONTRO" in entry.keys() {
                entry.insert("DADOS-BASICOS", entry.DADOS-BASICOS-DA-PARTICIPACAO-EM-ENCONTRO)
                entry.insert("NOME-DO-EVENTO", entry.DETALHAMENTO-DA-PARTICIPACAO-EM-ENCONTRO.NOME-DO-EVENTO)
            }
            if "DADOS-BASICOS-DE-OUTRAS-PARTICIPACOES-EM-EVENTOS-CONGRESSOS" in entry.keys() {
                entry.insert("DADOS-BASICOS", entry.DADOS-BASICOS-DE-OUTRAS-PARTICIPACOES-EM-EVENTOS-CONGRESSOS)
                entry.insert("NOME-DO-EVENTO", entry.DETALHAMENTO-DE-OUTRAS-PARTICIPACOES-EM-EVENTOS-CONGRESSOS.NOME-DO-EVENTO)
            }
            participacoes.push(entry)
        }

        // ordenar
        participacoes = participacoes.sorted(
            key: (item) => (item.DADOS-BASICOS.ANO, item.DADOS-BASICOS.TITULO)
        )

        // TODO: eu acho que não é necessário porque organização de evento fica na produção técnica
        [=== Participação em eventos <eventos_participacao>]
        
        // criando número para ordem decrescente (vantagem: você pode ler diretamente em quantos eventos a pessoa participou)
        let i = participacoes.len()

        // loop pelas entradas
        for entrada in participacoes.rev() {
            // criando entradas
            let evento = entrada.NOME-DO-EVENTO
            let subset = entrada.DADOS-BASICOS
            let tipo = subset.TIPO-PARTICIPACAO
            let ano = subset.ANO
            let natureza = subset.NATUREZA
            let titulo = subset.TITULO
            
            // se tipo é vázio, tenta forma-participacao
            if tipo == "" {
                tipo = subset.FORMA-PARTICIPACAO
            }
            // criando texto
            let tipo_content = []
            if tipo != "" {
                tipo_content = [#tipo em]
            }

            descricao_content = [#tipo_content #text(evento, weight: "semibold"), #ano (#natureza). #emph(titulo)]

            // publicando content
            create-cols([*#i.*], [#descricao_content], "enum")

            // diminuir número (ordem descendo)
            i -= 1
        }
    }    
}

// Função create-organization-events(): Cria entradas eventos
// Argumento:
//  - dados-organizacao: sub-banco de dados para organização nos eventos
#let create-organization-events(dados-organizacao, eu) = {
    // criando cabeçalho
    [=== Organização de evento<organizacao_eventos>]


    let i = dados-organizacao.len()
    
    for entry in dados-organizacao {
        let autores = format-authors(entry.AUTORES, eu)
        
        let titulo = entry.DADOS-BASICOS-DA-ORGANIZACAO-DE-EVENTO.TITULO
        let ano = entry.DADOS-BASICOS-DA-ORGANIZACAO-DE-EVENTO.ANO

        let doi = entry.DADOS-BASICOS-DA-ORGANIZACAO-DE-EVENTO.DOI
        let tipo = upper(entry.DADOS-BASICOS-DA-ORGANIZACAO-DE-EVENTO.TIPO.slice(0, 1)) + lower(entry.DADOS-BASICOS-DA-ORGANIZACAO-DE-EVENTO.TIPO.slice(1))
        
        let natureza = upper(entry.DADOS-BASICOS-DA-ORGANIZACAO-DE-EVENTO.NATUREZA.at(0)) + lower(entry.DADOS-BASICOS-DA-ORGANIZACAO-DE-EVENTO.NATUREZA.slice(1))
        // corrigindo natureza
        if natureza == "Organizacao" { 
            natureza = "Organização" 
        }

        // criando content
        let descricao_content = [#autores #titulo, #ano. (#tipo, #natureza)]
        
        create-cols([*#i.*], [#descricao_content], "enum")
        // diminuindo ordem
        i -= 1
    }
}

// Função create-events(): Cria entradas eventos
// Argumento:
//  - detalhes: o banco de dados com todas as informações (arquivo TOML)
#let create-events(detalhes, eu) = {

    // Participação
    if "PARTICIPACAO-EM-EVENTOS-CONGRESSOS" in detalhes.DADOS-COMPLEMENTARES.keys() {
        // criando banco de dados
        let eventos = detalhes.DADOS-COMPLEMENTARES.PARTICIPACAO-EM-EVENTOS-CONGRESSOS
        
        create-participation-events(eventos, eu)
    }
    
    if "ORGANIZACAO-DE-EVENTO" in detalhes.PRODUCAO-TECNICA.DEMAIS-TIPOS-DE-PRODUCAO-TECNICA.keys() {
        let subset = detalhes.PRODUCAO-TECNICA.DEMAIS-TIPOS-DE-PRODUCAO-TECNICA.ORGANIZACAO-DE-EVENTO
        subset = subset.sorted(key: (item) => (item.DADOS-BASICOS-DA-ORGANIZACAO-DE-EVENTO.ANO, item.DADOS-BASICOS-DA-ORGANIZACAO-DE-EVENTO.TITULO ))

        create-organization-events(subset, eu)    
    }

    if "PARTICIPACAO-EM-EVENTOS-CONGRESSOS" in detalhes.DADOS-COMPLEMENTARES.keys() or "ORGANIZACAO-DE-EVENTO" in detalhes.PRODUCAO-TECNICA.DEMAIS-TIPOS-DE-PRODUCAO-TECNICA.keys() {
        linebreak()

        line(length: 100%)
    }
}