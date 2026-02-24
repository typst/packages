#import "utils.typ": *

// Função create-education(): Cria área de formação complementar
// Argumentos:
// - detalhes: o banco de dados de Lattes (TOML)
// - tipo-lattes: tipo de currículo Lattes
#let create-education(detalhes, tipo-lattes) = {
    let formacao = detalhes.DADOS-GERAIS.FORMACAO-ACADEMICA-TITULACAO

    // criando ordem na formacao
    formacao = formacao.pairs().sorted(
        key: (item) => (item.at(1).at("ANO-DE-INICIO"), item.at(1).at("ANO-DE-CONCLUSAO"))
    )

    if formacao.len() > 0 {
        [= Formação academica/titulação <formacao>]

        // loop pelas keys em dictionary e imprimir todas vagas
        if type(formacao) == dictionary {
            for key in formacao.keys().rev() {
                // criando banco de dados
                let subset = formacao.at(key)
                
                // initialize variables
                let titulo = str
                let orientador = str
                let coorientador = str
                let conhecimento = content
                let tempo_content = []
                let descricao_content = []
                let palavras_chave = ()
                let conhecimento = ()

                // criando curso se tiver
                let curso = ""
                // para ensino medio não tem NOME-CURSO
                if "NOME-CURSO" in subset.keys() {
                    curso = subset.NOME-CURSO
                }

                let universidade = subset.NOME-INSTITUICAO

                // corrigir tipo de formação (em key)
                if key == "GRADUACAO" {
                    key = "Graduação"
                } else if key == "POS_GRADUACAO" { 
                    key = "Pós-Graduação"
                }

                tempo_content = [#subset.ANO-DE-INICIO - #subset.ANO-DE-CONCLUSAO]
                
                // criando título
                if "TITULO-DO-TRABALHO-DE-CONCLUSAO-DE-CURSO" in subset.keys() {
                    titulo = subset.TITULO-DO-TRABALHO-DE-CONCLUSAO-DE-CURSO 
                } else if "TITULO-DA-DISSERTACAO-TESE" in subset.keys() {
                    titulo = subset.TITULO-DA-DISSERTACAO-TESE
                }

                // criando orientadres
                // Caso de ensino medio sem orientadores
                if "NOME-DO-ORIENTADOR" in subset.keys() or "NOME-DO-CO-ORIENTADOR" in subset.keys() {
                    if "NOME-DO-CO-ORIENTADOR" in subset.keys() {
                        if subset.NOME-DO-CO-ORIENTADOR !="" {
                            orientador = subset.NOME-COMPLETO-DO-ORIENTADOR
                            coorientador = subset.NOME-DO-CO-ORIENTADOR
                        } else {
                            orientador = subset.NOME-COMPLETO-DO-ORIENTADOR
                        }
                    } else if "NOME-DO-ORIENTADOR" in subset.keys() {
                        orientador = subset.NOME-DO-ORIENTADOR
                    } else {
                        orientador = subset.NOME-COMPLETO-DO-ORIENTADOR
                    }
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

                    if all_areas.len() != 0 {
                        conhecimento = all_areas.join(", ")
                    }
                }

                // criando content
                let estudo = [#key.slice(0, 1)#lower(key.slice(1)) em #curso, #emph(subset.NOME-INSTITUICAO)]
                // caso tem todas informações
                if orientador != str and coorientador != str {
                    descricao_content = [
                        #estudo#linebreak()
                        Título: #titulo#linebreak()
                        Orientador(a): #orientador#linebreak()
                        Co-orientador(a): #coorientador#linebreak()
                    ]
                // caso não tem co-orientador e áreas de conhecimento
                }  else if orientador != str and coorientador == str {
                    descricao_content = [
                        #estudo#linebreak()
                        Título: #titulo#linebreak()
                        Orientador(a): #orientador#linebreak()
                    ]
                // caso não tem orientador, co-orientador e áreas de conhecimento
                } else if orientador == str and coorientador == str {
                    descricao_content = [
                        #estudo#linebreak()
                        Título: #titulo#linebreak()
                    ]
                }

                // criando conteúdo depende do tipo de lattes
                if tipo-lattes == "completo" {
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

                    descricao_content = [#descricao_content #palavras_content #areas_content]
                } else {
                    descricao_content = [#descricao_content]
                }           

                // publicando content
                create-cols([*#tempo_content*], [#descricao_content], "small")
            }
        } else if type(formacao) == array {
            for entrada in formacao.rev() {
                // criando banco de dados
                let subset = entrada.at(1)
                
                // [#entrada]
                // initialize variables
                let titulo = ""
                let orientador = ""
                let coorientador = ""
                let conhecimento = content
                let tempo_content = []
                let descricao_content = []
                let palavras_chave = ()
                let conhecimento = ()

                // criando curso se tiver
                let curso = ""

                // cri
                // para ensino medio não tem NOME-CURSO
                if "NOME-CURSO" in subset.keys() {
                    curso = subset.NOME-CURSO
                }

                let universidade = subset.NOME-INSTITUICAO

                // corrigir tipo de formação (em key)
                if entrada.at(0) == "GRADUACAO" {
                    entrada.at(0) = "Graduação"
                } else if entrada.at(0) == "POS_GRADUACAO" { 
                    entrada.at(0) = "Pós-Graduação"
                }

                // criando tempo content
                let tempo_content = []
                if subset.ANO-DE-CONCLUSAO == "" {
                    tempo_content = [#subset.ANO-DE-INICIO - atual]
                } else { 
                    tempo_content = [#subset.ANO-DE-INICIO - #subset.ANO-DE-CONCLUSAO]
                }
                
                // criando título
                if "TITULO-DO-TRABALHO-DE-CONCLUSAO-DE-CURSO" in subset.keys() {
                    titulo = subset.TITULO-DO-TRABALHO-DE-CONCLUSAO-DE-CURSO 
                } else if "TITULO-DA-DISSERTACAO-TESE" in subset.keys() {
                    titulo = subset.TITULO-DA-DISSERTACAO-TESE
                }

                // criando orientadres
                // Caso de ensino medio sem orientadores
                if "NOME-DO-ORIENTADOR" in subset.keys() or "NOME-DO-CO-ORIENTADOR" in subset.keys() {
                    if "NOME-DO-CO-ORIENTADOR" in subset.keys() {
                        if subset.NOME-DO-CO-ORIENTADOR !="" {
                            orientador = subset.NOME-COMPLETO-DO-ORIENTADOR
                            coorientador = subset.NOME-DO-CO-ORIENTADOR
                        } else {
                            orientador = subset.NOME-COMPLETO-DO-ORIENTADOR
                        }
                    } else if "NOME-DO-ORIENTADOR" in subset.keys() {
                        orientador = subset.NOME-DO-ORIENTADOR
                    } else {
                        orientador = subset.NOME-COMPLETO-DO-ORIENTADOR
                    }
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

                    if all_areas.len() != 0 {
                        conhecimento = all_areas.join(", ")
                    }
                }

                // criando content
                let estudo = [#entrada.at(0).slice(0, 1)#lower(entrada.at(0).slice(1)) em #curso, #emph(subset.NOME-INSTITUICAO)]
                
                // criando orientacoes
                let orientacao_content = []
                if orientador != "" and coorientador != "" {
                    orientacao_content = [
                        Orientador(a): #orientador#linebreak()
                        Co-orientador(a): #coorientador#linebreak()
                    ]
                // caso não tem co-orientador
                }  else if orientador != "" and coorientador == "" {
                    orientacao_content = [
                        Orientador(a): #orientador#linebreak()
                    ]
                } else {
                    orientacao_content = []
                }

                // criando título
                let titulo_content = []
                if titulo != "" {
                    titulo_content = [Título: #titulo#linebreak()]
                }

                let descricao_content = [#estudo#linebreak()#titulo_content #orientacao_content]
                
                // criando conteúdo depende do tipo de lattes
                if tipo-lattes == "completo" {
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

                    descricao_content = [#descricao_content #palavras_content #areas_content]
                } else {
                    descricao_content = [#descricao_content]
                }           

                // publicando content
                create-cols([*#tempo_content*], [#descricao_content], "small")
            }
        }
        

        linebreak()

        line(length: 100%)
    } 
}

// Função create-advanced-training: Cria área de formação complementar
// Argumento:
// - detalhes: o banco de dados de Lattes (TOML)
#let create-advanced-training(detalhes) = {
    if "DADOS-COMPLEMENTARES" in detalhes {
        if "FORMACAO-COMPLEMENTAR" in detalhes.DADOS-COMPLEMENTARES{
        
            // criando banco de dados
            let complementar = detalhes.DADOS-COMPLEMENTARES.FORMACAO-COMPLEMENTAR

            if complementar.len() > 0 {
                [= Formação complementar <formacao_complementar>]

                for key in complementar.keys() {
                    let subset = complementar.at(key)

                    subset = subset.sorted(key: (item) => (item.ANO-DE-INICIO, item.ANO-DE-CONCLUSAO))
                    
                    for entrada in subset.rev() {
                        let tempo_content = []
                        if entrada.ANO-DE-INICIO == entrada.ANO-DE-CONCLUSAO {
                            tempo_content = [#entrada.ANO-DE-INICIO]
                        } else {
                            tempo_content = [#entrada.ANO-DE-INICIO - #entrada.ANO-DE-CONCLUSAO]
                        }

                        let descricao_content= [
                            #entrada.NOME-CURSO (Carga horária: #entrada.CARGA-HORARIA), #emph(entrada.NOME-INSTITUICAO)
                        ]

                        // publicando content
                        create-cols([*#tempo_content*], [#descricao_content], "small")
                    }
                }
            }
        }
    }    
    linebreak()

    line(length: 100%)
}

