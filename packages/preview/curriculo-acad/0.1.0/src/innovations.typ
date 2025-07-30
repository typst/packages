#import "utils.typ": *

// Função create-projects-area(): Cria projetos de CT (dentro de inovação, usado em create-projects-ino()) da área específica
// Argumentos:
//  - dados: o banco de dados da área
//  - eu: nome para destacar
//  - cabecalho: cabecalho da área
#let create-projects-area(dados, eu, cabecalho) = {
    // para ensino
    if dados.len() > 0 {

        [=== #cabecalho]

        let i = dados.len() + 1

        for projeto in dados.rev() {
            // criando banco de dados para projeto
            let subset = projeto.at("PROJETO-DE-PESQUISA")
            
            // criando variáveis
            let ano = ""
            let situacao = ""
            let tipo = ""
            let membros = ()
            let subvencoes = ()
            let cta = 0
            let titulo = subset.NOME-DO-PROJETO
            let informacao = subset.DESCRICAO-DO-PROJETO

            // corrigindo quotes em código HTML
            informacao = replace-quotes(informacao)


            if subset.SITUACAO != "CONCLUIDO" {
                ano = [#subset.ANO-INICIO - atual]
                situacao = subset.SITUACAO.slice(0,1) + lower(subset.SITUACAO.slice(1))
            } else {
                ano = [#subset.ANO-INICIO - #subset.ANO-FIM]
                situacao = subset.SITUACAO.slice(0,1) + lower(subset.SITUACAO.slice(1))
            }
            
            // criando membros do projeto
            if "EQUIPE-DO-PROJETO" in subset.keys() {
                // criando array de pessoas
                let pessoas = subset.EQUIPE-DO-PROJETO.at("INTEGRANTES-DO-PROJETO")

                membros = format-participants(pessoas, eu)
            }

            // criando financidores
            if "FINANCIADORES-DO-PROJETO" in subset.keys() {
                // criando array de financiadores
                let pessoas = subset.FINANCIADORES-DO-PROJETO.at("FINANCIADOR-DO-PROJETO")

                // loop pelas entradas de financiadores
                for pessoa in pessoas {
                    if type(pessoa) == dictionary {
                        subvencoes.push(pessoa.NOME-INSTITUICAO)
                    } else if type(pessoa) == array {
                        if pessoa.at(0) == "NOME-INSTITUICAO" {
                            subvencoes.push(pessoa.at(1))
                        }
                    }
                }
            }

            // calcular publicacoes de cta      
            if "PRODUCOES-CT-DO-PROJETO" in subset.keys() {
                for publicacao in subset.PRODUCOES-CT-DO-PROJETO {
                    if type(publicacao.at(1)) == array {
                        cta = publicacao.at(1).len()
                    } else if type(publicacao.at(1)) == dictionary {
                        cta = 1
                    }
                }
            }               

            // criando content                
            let descricao = [#text(rgb("B2B2B2"), size: 0.85em, "Descrição: "+ informacao)#linebreak()]

            // criando string para membros
            let membros_string = []
            if membros != "" {
                membros_string = [#text(rgb("B2B2B2"), size: 0.85em, "Integrante(s): " + membros + ";")#linebreak()]
            } else {
                membros_string = []
            }
                
            // criando string para subvencoes
            let subvencoes_string = []
            if subvencoes.len() > 0 {
                subvencoes_string = [#text(rgb("B2B2B2"), size: 0.85em, "Financiador(es): " + subvencoes.join("; "))#linebreak()]
            } else {
                subvencoes_string = []
            }
            
            // criando string para cta
            let cta_string = []
            if cta > 0 {
                cta_string = [#text(rgb("B2B2B2"), size: 0.85em, "Número de produções C, T & A: "+ str(cta))]
            } else {
                cta_string = []
            }

            // criando content
            let descricao_content = [#titulo #linebreak() #descricao #membros_string #subvencoes_string #cta_string]

            // publicando content
            create-cols([*#ano*], [#descricao_content], "wide")
        }
    }
}

// Função create-innovations(): Cria Inovações 
// Argumento:
//  - detalhes: o banco de dados com todas as informações (arquivo TOML)
#let create-innovations(detalhes, eu) = {
    // criando banco de dados geral
    let atuacao = detalhes.DADOS-GERAIS.ATUACOES-PROFISSIONAIS.ATUACAO-PROFISSIONAL

    // criando variáveis
    let projetos = ()
    let proj_pesquisa = ()
    let proj_tecnico = ()
    let proj_extensao = ()
    let proj_ensino = ()
    let eventos = () 
    let congressos = () 
    let marker = true

    // criando a soma de
    // criando um loop para cada atuação para recolher todos os projetos
    for entrada in atuacao {
        // set to empty
        projetos = ()
        proj_pesquisa = ()
        proj_tecnico = ()
        proj_extensao = ()
        proj_ensino = ()
        
        // criando o banco de dados
        if "ATIVIDADES-DE-PARTICIPACAO-EM-PROJETO" in entrada.keys() {
            projetos = entrada.ATIVIDADES-DE-PARTICIPACAO-EM-PROJETO.at("PARTICIPACAO-EM-PROJETO")
        }
        
        if projetos.len() > 0 { 
            // ordenar por ano
            let projetos_sorted = projetos.sorted(key: (item) => (item.ANO-INICIO, item.ANO-FIM, item.MES-FIM, item.MES-INICIO))


            // filtrar pesquisa
            proj_pesquisa = projetos_sorted.filter(
                entry => entry.at("PROJETO-DE-PESQUISA").NATUREZA == "PESQUISA" and entry.at("PROJETO-DE-PESQUISA").FLAG-POTENCIAL-INOVACAO == "SIM"
            )

            // filtrar desenvolvimento técnico
            proj_tecnico = projetos_sorted.filter(
                entry => entry.at("PROJETO-DE-PESQUISA").NATUREZA == "DESENVOLVIMENTO_TECNICO" and entry.at("PROJETO-DE-PESQUISA").FLAG-POTENCIAL-INOVACAO == "SIM"
            )

            // filtrar extensão
            proj_extensao = projetos_sorted.filter(
                entry => entry.at("PROJETO-DE-PESQUISA").NATUREZA == "EXTENSAO" and entry.at("PROJETO-DE-PESQUISA").FLAG-POTENCIAL-INOVACAO == "SIM"
            )

            // filtrar ensino
            proj_ensino = projetos_sorted.filter(
                entry => entry.at("PROJETO-DE-PESQUISA").NATUREZA == "ENSINO" and entry.at("PROJETO-DE-PESQUISA").FLAG-POTENCIAL-INOVACAO == "SIM"
            )
        }

        // Projetos primeiro
        if proj_pesquisa.len() > 0 or proj_tecnico.len() > 0 or proj_extensao.len() > 0 or proj_ensino.len() > 0 {
            [= Inovação]
            [== Projetos <projetos_inovacao>] 

            create-projects-area(proj_pesquisa, eu, "Projeto de pesquisa")
            
            create-projects-area(proj_tecnico, eu, "Projeto de desenvolvimento tecnológico")
            
            create-projects-area(proj_extensao, eu, "Projeto de extensão")
            
            create-projects-area(proj_ensino, eu, "Projeto de ensino")
            
            linebreak()

            line(length: 100%)  
        }   
    }
}