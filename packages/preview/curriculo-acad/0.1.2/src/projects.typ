#import "utils.typ": *

// Função create-projects-area(): Cria lista de área projetos de ensino (só "completo")
// Argumento:
//  - dados: sub-banco somente de área
//  - eu: nome para destacar
//  - cabecalho: string para cabeçalho
#let create-projects-area(dados, eu, cabecalho) = {
    // criando área de outros projetos
    if dados.len() > 0 {
        [== #cabecalho]

        for project in dados.rev() {
            // criando variáveis
            let membros = ()
            let tempo_content = ()
            
            let subset = project.at("PROJETO-DE-PESQUISA")
            
            if subset.SITUACAO == "CONCLUIDO" {
                if subset.ANO-INICIO == subset.ANO-FIM {
                    tempo_content = [#subset.ANO-INICIO]
                } else {
                    tempo_content = [#subset.ANO-INICIO - #subset.ANO-FIM]
                }
            } else {
                tempo_content = [#subset.ANO-INICIO - atual]
            }
            
            // criando membros de projeto
            if "EQUIPE-DO-PROJETO" in subset.keys() {
                // create array of persons involved
                let integrantes = subset.EQUIPE-DO-PROJETO.at("INTEGRANTES-DO-PROJETO")
                membros = format-participants(integrantes, eu)
            }

            // enumerar producoes no projeto
            let producoes = 0

            if "PRODUCOES-CT-DO-PROJETO" in subset.keys() {
                producoes = subset.PRODUCOES-CT-DO-PROJETO.PRODUCAO-CT-DO-PROJETO.len()
            }

            // criando outras informações
            let informacao = subset.DESCRICAO-DO-PROJETO
            informacao = replace-quotes(informacao)
            
            // criando content
            let descricao_content = [
                #subset.NOME-DO-PROJETO
                #linebreak()
                #text(rgb("B2B2B2"), size: 0.85em, "Integrantes: " + membros + ";")
                #linebreak()
                #text(rgb("B2B2B2"), size: 0.85em, "Número de produções C,T & A: " + str(producoes))
                #linebreak()
                #text(rgb("B2B2B2"), size: 0.85em, "Descrição: " + informacao)
            ]

            // publicando content
            create-cols([*#tempo_content*], [#descricao_content], "small")
        }
    }
}

// Função create-projects(): Cria lista de projetos de pesquisa e ensino (só "completo")
// Argumento:
//  - detalhes: o banco de dados de Lattes (TOML File)
//  - eu: nome para destacar
#let create-projects(detalhes, eu) = {
    // criando bancos básicos
    let atuacao = detalhes.DADOS-GERAIS.ATUACOES-PROFISSIONAIS.ATUACAO-PROFISSIONAL

    let projetos_ensino = array
    let projetos_pesquisa = array
    let projetos_desenvolvimento = array
    let projetos_extensao = array
    let projetos_outros = array

    // criando banco de dados para pesquisa e para ensino
    for entry in atuacao {
        // filtrar outras atividades
        if "ATIVIDADES-DE-PARTICIPACAO-EM-PROJETO" in entry.keys() {

            let projetos = entry.ATIVIDADES-DE-PARTICIPACAO-EM-PROJETO.at("PARTICIPACAO-EM-PROJETO")
            
            // ordem os projetos
            let projetos = projetos.sorted(key: (item) => (item.ANO-INICIO, item.ANO-FIM, item.MES-FIM, item.MES-INICIO))

            // criando array para pesquisa
            projetos_pesquisa = projetos.filter(
                entry => entry.at("PROJETO-DE-PESQUISA").NATUREZA == "PESQUISA"
            )

            // criando array para ensino
            projetos_ensino = projetos.filter(
                entry => entry.at("PROJETO-DE-PESQUISA").NATUREZA == "ENSINO"
            )

            // TODO: não tenho certeza sobre o key
            // criando array para desenvolvimento
            projetos_desenvolvimento = projetos.filter(
                entry => entry.at("PROJETO-DE-PESQUISA").NATUREZA == "DESENVOLVIMENTO_TECNOLOGICA"
            )

            // criando array para extensão
            projetos_extensao = projetos.filter(
                entry => entry.at("PROJETO-DE-PESQUISA").NATUREZA == "EXTENSAO"
            )

            // TODO: não tenho certeza sobre o key
            // criando array para outros tipos de projetos
            projetos_outros = projetos.filter(
                entry => entry.at("PROJETO-DE-PESQUISA").NATUREZA == "OUTROS_PROJETOS"
            )
        }
    }

    if projetos_pesquisa.len() > 0 or projetos_ensino.len() > 0 or projetos_desenvolvimento.len() > 0 or projetos_extensao.len() > 0 or projetos_outros.len() > 0 {
        [= Projetos <projetos_atuacao>]

        create-projects-area(projetos_pesquisa, eu, "Projetos de pesquisa")

        create-projects-area(projetos_desenvolvimento, eu, "Projetos de desenvolvimento tecnologica")

        create-projects-area(projetos_extensao, eu, "Projetos de extensão")
        
        create-projects-area(projetos_ensino, eu, "Projetos de ensino")
        
        create-projects-area(projetos_outros, eu, "Outros tipos de projetos")

        linebreak()
    
        line(length: 100%)
    }
}