#import "utils.typ": *

// Função create-technicals(): Cria área de produções técnicos (usado em create-bibliography)
// TODO: Até agora somente categoria "demais produções técnicos" (relatório de pesquisa, material didático, cursos de curta duração ministrado)
// Argumentos:
//  - dados_tecnicos: subset do banco de dados com só técnios
//  - me: nome para destacar nas entradas
//  - tipo_lattes: tipo de currículo Lattes
#let create-technicals(dados_tecnicos, eu, tipo_lattes) = {
    [== Produção técnica <producao_tecnica>]
    
    [=== Demais produções técnicas <producao_tecnica_demais>]

    // #all
    let i = dados_tecnicos.len()

    // Then i loop into arrays
    for entrada in dados_tecnicos.rev() {
        // criando variáveis
        let autores = ()
        let palavras_chave = ()
        let conhecimento = ()
        let titulo = ""
        let ano = ""
        let tipo = ""
        let doi = ""
        let homepage = ""

        // using for constructing the link
        let url_link = []

        // formatar os autores
        let autores = format-authors(entrada.AUTORES, eu)     
        
        // criando entradas
        // relatório de pesquisa
        if "DADOS-BASICOS-DO-RELATORIO-DE-PESQUISA" in entrada.keys() {
            titulo = entrada.DADOS-BASICOS-DO-RELATORIO-DE-PESQUISA.TITULO
            ano = entrada.DADOS-BASICOS-DO-RELATORIO-DE-PESQUISA.ANO
            tipo = "Relatório de pesquisa"
            doi = entrada.DADOS-BASICOS-DO-RELATORIO-DE-PESQUISA.DOI
            homepage = entrada.DADOS-BASICOS-DO-RELATORIO-DE-PESQUISA.HOME-PAGE-DO-TRABALHO
        // materiais didáticos
        } else if "DADOS-BASICOS-DO-MATERIAL-DIDATICO-OU-INSTRUCIONAL" in entrada.keys() {
            titulo = entrada.DADOS-BASICOS-DO-MATERIAL-DIDATICO-OU-INSTRUCIONAL.TITULO
            ano = entrada.DADOS-BASICOS-DO-MATERIAL-DIDATICO-OU-INSTRUCIONAL.ANO
            tipo = "Desenvolvimento de material didático ou instrucional"
            doi = entrada.DADOS-BASICOS-DO-MATERIAL-DIDATICO-OU-INSTRUCIONAL.DOI
            homepage = entrada.DADOS-BASICOS-DO-MATERIAL-DIDATICO-OU-INSTRUCIONAL.HOME-PAGE-DO-TRABALHO
        // cursos de curta duração ministrado
        } else if "DADOS-BASICOS-DE-CURSOS-CURTA-DURACAO-MINISTRADO" in entrada.keys() {
            titulo = entrada.DADOS-BASICOS-DE-CURSOS-CURTA-DURACAO-MINISTRADO.TITULO
            ano = entrada.DADOS-BASICOS-DE-CURSOS-CURTA-DURACAO-MINISTRADO.ANO
            tipo = "Curso de curta duração ministrado"
            doi = entrada.DADOS-BASICOS-DE-CURSOS-CURTA-DURACAO-MINISTRADO.DOI
            homepage = entrada.DADOS-BASICOS-DE-CURSOS-CURTA-DURACAO-MINISTRADO.HOME-PAGE-DO-TRABALHO
        }

        // criando lista de palavras-chave
        if "PALAVRAS-CHAVE" in entrada.keys() {
            for word in entrada.PALAVRAS-CHAVE.keys() {
                if entrada.PALAVRAS-CHAVE.at(word) != "" {
                    palavras_chave.push(entrada.PALAVRAS-CHAVE.at(word))    
                }
            }
        }

        // criando string de palavras-chave
        if palavras_chave.len() > 0 {
            palavras_chave = palavras_chave.join("; ") + ";"
        }

        // criando áreas de conhecimento
        if "AREAS-DO-CONHECIMENTO" in entrada.keys() {
            let areas = entrada.at("AREAS-DO-CONHECIMENTO")

            let i = 0
            
            for key in areas.keys() {
                let subset = areas.at(key)
                
                if subset.NOME-DA-ESPECIALIDADE == "" {
                    if subset.NOME-DA-SUB-AREA-DO-CONHECIMENTO == ""{
                        if subset.NOME-DA-AREA-DO-CONHECIMENTO == "" {
                            let area = subset.NOME-GRANDE-AREA-DO-CONHECIMENTO
                            let partes = area.split("_")
                            let novas = ()
                            for entry in partes {
                                entry = upper(entry.slice(0, 1)) + lower(entry.slice(1))
                                entry = entry.replace("Ciencia", "Ciência")                                
                                novas.push(entry)
                            }
                            area = novas.join(" ")
                            conhecimento.push(area)
                        } else {
                            conhecimento.push(subset.NOME-DA-AREA-DO-CONHECIMENTO)
                        }
                    } else {
                        conhecimento.push(subset.NOME-DA-SUB-AREA-DO-CONHECIMENTO)
                    }
                } else {
                    conhecimento.push(subset.NOME-DA-ESPECIALIDADE)
                }
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
            areas_content = [#text(rgb("B2B2B2"), size: 0.85em, "Áreas de conhecimento: "+ conhecimento.join(", ")) #linebreak()]
        } 

        // criando link, se tem DOI, somente usar doi e não homepage
        if doi != "" { 
            url_link = [#link("https://doi.org/" + doi)[#doi]]
        } else if homepage != "" {
            url_link = [#link(homepage)[#homepage]]
        }

        // criando o conteúdo
        let descricao_content = []
        if tipo_lattes == "completo" {
            descricao_content = [#autores #titulo. #ano (#emph(tipo)). #url_link#linebreak()#palavras_content #areas_content]
        } else {
            descricao_content = [#autores #titulo. #ano (#tipo). #url_link]
        }
        
        // publicando content
        create-cols([*#i*], [#descricao_content], "enum")
        
        // diminuir número (ordem)
        i -= 1
    }
}

// Função create-presentations: Cria produções bibliograficos: apresentacoes (usado em create-bibliography())
// Argumentos:
//  - dados_apresentacoes: subset do banco de dados com só apresentações
//  - me: nome para destacar nas entradas
#let create-presentations(dados_apresentacoes, eu) = {

    [=== Apresentação de trabalho e palestra <producao_apresentacoes>]

    // criando número para ordem
    let i = dados_apresentacoes.len() + 1
    // loop nas entradas de apresentacoes
    for entrada in dados_apresentacoes.rev() {
        let palavras_chave = ()
        let conhecimento = ()
        let resumo = ""

        let autores = format-authors(entrada.AUTORES, eu)     
        let titulo = entrada.DADOS-BASICOS-DA-APRESENTACAO-DE-TRABALHO.TITULO
        let ano = entrada.DADOS-BASICOS-DA-APRESENTACAO-DE-TRABALHO.ANO
        let tipo = entrada.DADOS-BASICOS-DA-APRESENTACAO-DE-TRABALHO.NATUREZA

        // corrigir camppo de tipo
        if tipo == "CONFERENCIA" { 
            tipo = "Apresentação de Trabalho / Conferência ou Palestra"
        } else if tipo == "SEMINARIO" {
            tipo = "Apresentação de Trabalho / Seminário"
        } else if tipo == "SIMPOSIO" {
            tipo = "Apresentação de Trabalho / Simpósio"
        } else {
        tipo = "Apresentação de Trabalho / " + tipo.slice(0, 1) + lower(tipo.slice(1))
        }
        
        // palavras-chave
        if "PALAVRAS-CHAVE" in entrada.keys() {
            for word in entrada.PALAVRAS-CHAVE.keys() {
                if entrada.PALAVRAS-CHAVE.at(word) != "" {
                    palavras_chave.push(entrada.PALAVRAS-CHAVE.at(word))    
                }
            }
        }

        // criando string de palavras-chave
        if palavras_chave.len() > 0 {
            palavras_chave = palavras_chave.join("; ") + ";"
        }

        // criando areas de conhecimento
        // criando áreas de conhecimento
        if "AREAS-DO-CONHECIMENTO" in entrada.keys() {
            let areas = entrada.at("AREAS-DO-CONHECIMENTO")

            let i = 0
            
            for key in areas.keys() {
                let subset = areas.at(key)
                
                if subset.NOME-DA-ESPECIALIDADE == "" {
                    if subset.NOME-DA-SUB-AREA-DO-CONHECIMENTO == ""{
                        if subset.NOME-DA-AREA-DO-CONHECIMENTO == "" {
                            let area = subset.NOME-GRANDE-AREA-DO-CONHECIMENTO
                            let partes = area.split("_")
                            let novas = ()
                            for entry in partes {
                                entry = upper(entry.slice(0, 1)) + lower(entry.slice(1))
                                entry = entry.replace("Ciencia", "Ciência")                                
                                novas.push(entry)
                            }
                            area = novas.join(" ")
                            conhecimento.push(area)
                        } else {
                            conhecimento.push(subset.NOME-DA-AREA-DO-CONHECIMENTO)
                        }
                    } else {
                        conhecimento.push(subset.NOME-DA-SUB-AREA-DO-CONHECIMENTO)
                    }
                } else {
                    conhecimento.push(subset.NOME-DA-ESPECIALIDADE)
                }
            }
        }
        
        // resumo
        if "INFORMACOES-ADICIONAIS" in entrada.keys() {
            resumo = [#text(rgb("B2B2B2"), size: 0.85em, "Resumo: "+ replace-quotes(entrada.INFORMACOES-ADICIONAIS.DESCRICAO-INFORMACOES-ADICIONAIS))]
        } else {
            resumo = ""
        }
        
        // criando content para palavras_chave
        let palavras_content = []
            if palavras_chave.len() > 0 {
                palavras_content = [#text(rgb("B2B2B2"), size: 0.85em, "Palavras-chave: "+ palavras_chave) #linebreak()]
            } else {
                palavras_content = []
            }
            
        // criando content para areas 
        let areas_content = [] 
        if conhecimento.len() > 0 {
            areas_content = [#text(rgb("B2B2B2"), size: 0.85em, "Áreas de conhecimento: "+ conhecimento.join(", ")) #linebreak()]
        } else {
            areas_content = []
        }

        // criando o conteúdo
        let descricao_content= [#autores #text(titulo, weight: "semibold"). #ano (#tipo)#linebreak()#palavras_content #areas_content #resumo]
        
        // diminuir o númoer
        i -= 1

        // publicando content
        create-cols([*#i*], [#descricao_content], "enum")
    }
}

// Função create-chapters(): Cria produções bibliograficos: capitulos (usado em create-bibliography())
// Argumentos:
//  - dados_capitulos: subset do banco de dados com só capitulos
//  - me: nome para destacar nas entradas
//  - tipo_lattes: tipo de currículo lattes
#let create-chapters(dados_capitulos, eu, tipo_lattes) = {

    [=== Capitulos de livros publicados <publicacao_capitulos>]

    // criando número para ordem
    let i = dados_capitulos.len()


    for entrada in dados_capitulos.rev() {        
        if type(entrada) == array {
            // initialize variables
            let palavras_chave = ()
            let conhecimento = ()
            let editores = ()
            // let subset = entrada
            let subset = entrada.at(0)

            // authors:
            let autores = format-authors(subset.AUTORES, eu)        

            let titulo = subset.DADOS-BASICOS-DO-CAPITULO.TITULO-DO-CAPITULO-DO-LIVRO
            let titulo_livro = subset.DETALHAMENTO-DO-CAPITULO.TITULO-DO-LIVRO
            let edicao = subset.DETALHAMENTO-DO-CAPITULO.NUMERO-DA-EDICAO-REVISAO
            let local = subset.DETALHAMENTO-DO-CAPITULO.CIDADE-DA-EDITORA
            let editora = subset.DETALHAMENTO-DO-CAPITULO.NOME-DA-EDITORA
            let ano = subset.DADOS-BASICOS-DO-CAPITULO.ANO
            let doi = subset.DADOS-BASICOS-DO-CAPITULO.DOI
        
            let pagina = []
            if subset.DETALHAMENTO-DO-CAPITULO.PAGINA-FINAL == "" {
                pagina = subset.DETALHAMENTO-DO-CAPITULO.PAGINA-INICIAL
            } else {
                pagina = [#subset.DETALHAMENTO-DO-CAPITULO.PAGINA-INICIAL - #subset.DETALHAMENTO-DO-CAPITULO.PAGINA-FINAL]
            }

            // criando lista de palavras-chave
            if "PALAVRAS-CHAVE" in subset.keys() {
                for palavra in subset.PALAVRAS-CHAVE.keys() {
                    if subset.PALAVRAS-CHAVE.at(palavra) != "" {
                        palavras_chave.push(subset.PALAVRAS-CHAVE.at(palavra))    
                    }
                }
            }

            // criando string de palavras-chave
            if palavras_chave.len() > 0 {
                palavras_chave = palavras_chave.join("; ") + ";"
            }

            // criando áreas de conhecimento
            if "AREAS-DO-CONHECIMENTO" in subset.keys() {
                let areas = entrada.at("AREAS-DO-CONHECIMENTO")

                let i = 0
                
                for key in areas.keys() {
                    let subset = areas.at(key)
                    
                    if subset.NOME-DA-ESPECIALIDADE == "" {
                        if subset.NOME-DA-SUB-AREA-DO-CONHECIMENTO == ""{
                            if subset.NOME-DA-AREA-DO-CONHECIMENTO == "" {
                                let area = subset.NOME-GRANDE-AREA-DO-CONHECIMENTO
                                let partes = area.split("_")
                                let novas = ()
                                for entry in partes {
                                    entry = upper(entry.slice(0, 1)) + lower(entry.slice(1))
                                    entry = entry.replace("Ciencia", "Ciência")                                
                                    novas.push(entry)
                                }
                                area = novas.join(" ")
                                conhecimento.push(area)
                            } else {
                                conhecimento.push(subset.NOME-DA-AREA-DO-CONHECIMENTO)
                            }
                        } else {
                            conhecimento.push(subset.NOME-DA-SUB-AREA-DO-CONHECIMENTO)
                        }
                    } else {
                        conhecimento.push(subset.NOME-DA-ESPECIALIDADE)
                    }
                }
            }

            // criando string de áreas de conhecimento
            if conhecimento.len() > 0 {
                conhecimento = conhecimento.join(", ")
            }

            //  criando editores
            let editores_string = subset.DETALHAMENTO-DO-CAPITULO.ORGANIZADORES
            if editores_string.find(";") != none {
                // caso mais de um editor (separação nos dados com ;)
                let partes = editores_string.split("; ")
                for parte in partes {
                    let nome_split = parte.split(", ")
                    // caso nome e sobrenome dividido com ","
                    if nome_split.len() > 1 {
                        let nome = upper(nome_split.at(0)) + ", " + nome_split.at(1).first() + "."
                        editores.push(nome)
                    } else {
                        editores.push(parte)
                    }
                    
                }
            } else if editores_string != "" {
                // caso um editor
                let nome_split = editores_string.split(", ")
                let nome = upper(nome_split.at(0)) + ", " + nome_split.at(1).first()  + "."
                editores.push(nome)
            }

            // Criandon editores content
            let editores_content = []
            if editores.len() > 0 {
                editores_content = [#editores.join("; ")]
            }

            // criando o link, prefire DOI 
            let doi_link = []
            if doi.len() > 0 {
                doi_link = [#link("https://doi.org/"+ doi)[DOI: #doi]]
            }

            // criando edicao 
            if edicao != "" {
                edicao = [ed. #edicao: ]
            }
            
            // criando local & editora
            let local_editora_content = []
            if local != "" and editora != "" {
                local_editora_content = [#local: #editora,] 
            } else if local != "" and editora == "" {
                local_editora_content = [#local,]
            } else if local == "" and editora != "" {
                local_editora_content = [#editora,]
            } else {
                local_editora_content = []
            }

            // criando citação
            let citacao = [#autores #text(titulo, weight: "semibold"). In: #editores_content (ed.). #emph(titulo_livro). #local_editora_content #ano. p. #pagina. #doi_link #linebreak()]

            // criando content palavras-chave
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
            let descricao_content = []
            if tipo_lattes == "completo" {
                descricao_content = [#citacao #palavras_content #areas_content]
            } else {
                descricao_content = [#citacao]
            }
            // publicando content
            create-cols([*#i*], [#descricao_content], "enum")

            // diminuir número para ordem
            i -= 1
        }  else if type(entrada) == dictionary {
            // initialize variables
            let palavras_chave = ()
            let conhecimento = ()
            let editores = ()
            // let subset = entrada
            let subset = entrada

            // authors:
            let autores = format-authors(subset.AUTORES, eu)        

            let titulo = subset.DADOS-BASICOS-DO-CAPITULO.TITULO-DO-CAPITULO-DO-LIVRO
            let titulo_livro = subset.DETALHAMENTO-DO-CAPITULO.TITULO-DO-LIVRO
            let edicao = subset.DETALHAMENTO-DO-CAPITULO.NUMERO-DA-EDICAO-REVISAO
            let local = subset.DETALHAMENTO-DO-CAPITULO.CIDADE-DA-EDITORA
            let editora = subset.DETALHAMENTO-DO-CAPITULO.NOME-DA-EDITORA
            let ano = subset.DADOS-BASICOS-DO-CAPITULO.ANO
            let doi = subset.DADOS-BASICOS-DO-CAPITULO.DOI
        
            let pagina = []
            if subset.DETALHAMENTO-DO-CAPITULO.PAGINA-FINAL == "" {
                pagina = subset.DETALHAMENTO-DO-CAPITULO.PAGINA-INICIAL
            } else {
                pagina = [#subset.DETALHAMENTO-DO-CAPITULO.PAGINA-INICIAL - #subset.DETALHAMENTO-DO-CAPITULO.PAGINA-FINAL]
            }

            // criando lista de palavras-chave
            if "PALAVRAS-CHAVE" in subset.keys() {
                for palavra in subset.PALAVRAS-CHAVE.keys() {
                    if subset.PALAVRAS-CHAVE.at(palavra) != "" {
                        palavras_chave.push(subset.PALAVRAS-CHAVE.at(palavra))    
                    }
                }
            }

            // criando string de palavras-chave
            if palavras_chave.len() > 0 {
                palavras_chave = palavras_chave.join("; ") + ";"
            }

            // criando áreas de conhecimento
            if "AREAS-DO-CONHECIMENTO" in subset.keys() {
                let areas = entrada.at("AREAS-DO-CONHECIMENTO")

                let i = 0
                
                for key in areas.keys() {
                    let subset = areas.at(key)
                    
                    if subset.NOME-DA-ESPECIALIDADE == "" {
                        if subset.NOME-DA-SUB-AREA-DO-CONHECIMENTO == ""{
                            if subset.NOME-DA-AREA-DO-CONHECIMENTO == "" {
                                let area = subset.NOME-GRANDE-AREA-DO-CONHECIMENTO
                                let partes = area.split("_")
                                let novas = ()
                                for entry in partes {
                                    entry = upper(entry.slice(0, 1)) + lower(entry.slice(1))
                                    entry = entry.replace("Ciencia", "Ciência")                                
                                    novas.push(entry)
                                }
                                area = novas.join(" ")
                                conhecimento.push(area)
                            } else {
                                conhecimento.push(subset.NOME-DA-AREA-DO-CONHECIMENTO)
                            }
                        } else {
                            conhecimento.push(subset.NOME-DA-SUB-AREA-DO-CONHECIMENTO)
                        }
                    } else {
                        conhecimento.push(subset.NOME-DA-ESPECIALIDADE)
                    }
                }
            }

            // criando string de áreas de conhecimento
            if conhecimento.len() > 0 {
                conhecimento = conhecimento.join(", ")
            }

            //  criando editores
            let editores_string = subset.DETALHAMENTO-DO-CAPITULO.ORGANIZADORES
            if editores_string.find(";") != none {
                // caso mais de um editor (separação nos dados com ;)
                let partes = editores_string.split("; ")
                for parte in partes {
                    let nome_split = parte.split(", ")
                    // caso nome e sobrenome dividido com ","
                    if nome_split.len() > 1 {
                        let nome = upper(nome_split.at(0)) + ", " + nome_split.at(1).first() + "."
                        editores.push(nome)
                    } else {
                        editores.push(parte)
                    }
                    
                }
            } else if editores_string != "" {
                // caso um editor
                let nome_split = editores_string.split(", ")
                let nome = upper(nome_split.at(0)) + ", " + nome_split.at(1).first()  + "."
                editores.push(nome)
            }

            // Criandon editores content
            let editores_content = []
            if editores.len() > 0 {
                editores_content = [#editores.join(";")]
            }

            // criando o link, prefire DOI 
            let doi_link = []
            if doi.len() > 0 {
                doi_link = [#link("https://doi.org/"+ doi)[DOI: #doi]]
            }

            // criando edicao 
            if edicao != "" {
                edicao = [ed. #edicao: ]
            }
            
            // criando local & editora
            let local_editora_content = []
            if local != "" and editora != "" {
                local_editora_content = [#local: #editora,] 
            } else if local != "" and editora == "" {
                local_editora_content = [#local,]
            } else if local == "" and editora != "" {
                local_editora_content = [#editora,]
            } else {
                local_editora_content = []
            }

            // criando citação
            let citacao = [#autores #text(titulo, weight: "semibold"). In: #editores_content (ed.). #emph(titulo_livro). #local_editora_content #ano. p. #pagina. #doi_link #linebreak()]

            // criando content palavras-chave
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
            let descricao_content = []
            if tipo_lattes == "completo" {
                descricao_content = [#citacao #palavras_content #areas_content]
            } else {
                descricao_content = [#citacao]
            }
            // publicando content
            create-cols([*#i*], [#descricao_content], "enum")

            // diminuir número para ordem
            i -= 1
        }
    } 
}

// Função create-books(): cria a área de produções bibliográficas - livros (usado em create-bibliography())
// Argumentos:
//  - dados_livros: subset do banco de dados com só livros
//  - me: nome para destacar nas entradas
//  - tipo_lattes: tipo de currículo lattes
#let create-books(dados_livros, eu, tipo_lattes) = {
    
    // criando cabeçalha
    [=== Livros publicados <publicacao_livros>]
    
    // criando número para ordem
    let i = dados_livros.len()

    for entrada in dados_livros.rev() {
        if type(entrada) == array {
            // criando subset 
            let subset = entrada.at(0)
            // criando variáveis
            let palavras_chave= ()
            let conhecimento = ()

            // autores: 
            let autores = []
            if type(subset.AUTORES) == dictionary {
                autores = format-authors(subset.AUTORES, eu)    
            } else if type(subset.AUTORES) == array {
                autores = format-authors(subset.at("AUTORES"), eu)
            }
            
            
            let titulo = subset.DADOS-BASICOS-DO-LIVRO.TITULO-DO-LIVRO
            let ano = subset.DADOS-BASICOS-DO-LIVRO.ANO
            let doi = subset.DADOS-BASICOS-DO-LIVRO.DOI
            let editora = subset.DETALHAMENTO-DO-LIVRO.NOME-DA-EDITORA
            let local = subset.DETALHAMENTO-DO-LIVRO.CIDADE-DA-EDITORA
            
            let pagina = []
            if subset.DETALHAMENTO-DO-LIVRO.NUMERO-DE-PAGINAS != "" {
                pagina = [#subset.DETALHAMENTO-DO-LIVRO.NUMERO-DE-PAGINAS]
            }

            // Palavras-chave
            if "PALAVRAS-CHAVE" in subset.keys() {
                for palavra in subset.PALAVRAS-CHAVE.keys() {
                    if subset.PALAVRAS-CHAVE.at(palavra) != "" {
                        palavras_chave.push(subset.PALAVRAS-CHAVE.at(palavra))    
                    }
                }
            }

            // criando string de palavras-chave
            if palavras_chave.len() > 0 {
                palavras_chave = palavras_chave.join("; ") + ";"
            }

            // areas de conhecimento
            if "AREAS-DO-CONHECIMENTO" in subset.keys() {
                for entrada in subset.AREAS-DO-CONHECIMENTO.keys() {
                    let subset2 = subset.AREAS-DO-CONHECIMENTO.at(entrada)
                    
                    for valor in subset2.keys() {
                        let area = subset2.at(valor)

                        // Define a function to capitalize the first letter of a substring
                        // let capitalize = (text) => str(text.slice(0, 1) + lower(text.slice(1)))

                        if area != "" {
                            let area_parts = area.split("_")

                            area = area_parts.map(capitalize).join(" ")

                            conhecimento.push(area)
                        }
                    }                
                }
            }

            // criando citação
            // criando link (prefire DOI)
            let doi_link = []
            if doi.len() > 0 {
                doi_link = [#link("https://doi.org/"+ doi)[DOI: #doi]]
            }
            
            // criando local & editora
            let local_editora_content = []
            if local != "" and editora != "" {
                local_editora_content = [#local: #editora,] 
            } else if local != "" and editora == "" {
                local_editora_content = [#local,]
            } else if local == "" and editora != "" {
                local_editora_content = [#editora,]
            } 

            // criando citacao
            let citacao = [#autores #text(titulo, weight: "semibold"). #local_editora_content #ano, p. #pagina. #doi_link #linebreak()]

            // criando content palavras-chave
            let palavras_content = []
            if palavras_chave.len() > 0 {
                palavras_content = [#text(rgb("B2B2B2"), size: 0.85em, "Palavras-chave: "+ palavras_chave) #linebreak()]
            } 

            // criando content para área
            let areas_content = [] 
            if conhecimento.len() > 0 {
                areas_content = [#text(rgb("B2B2B2"), size: 0.85em, "Áreas de conhecimento: "+ conhecimento.join(", "))]
            } 

            // criando descricao
            let descricao_content = []
            if tipo_lattes == "completo" {
                descricao_content = [#citacao #palavras_content #areas_content]
            } else {
                descricao_content = [#citacao]
            }        
            
            // publicando content
            create-cols([*#i*], [#descricao_content], "enum")
            
            // diminuir número
            i -= 1
        } else if type(entrada) == dictionary {
            // criando subset 
            let subset = entrada
            // criando variáveis
            let palavras_chave= ()
            let conhecimento = ()

            // autores: 
            let autores = []
            if type(subset.AUTORES) == dictionary {
                autores = format-authors(subset.AUTORES, eu)    
            } else if type(subset.AUTORES) == array {
                autores = format-authors(subset.at("AUTORES"), eu)
            }
            
            
            let titulo = subset.DADOS-BASICOS-DO-LIVRO.TITULO-DO-LIVRO
            let ano = subset.DADOS-BASICOS-DO-LIVRO.ANO
            let doi = subset.DADOS-BASICOS-DO-LIVRO.DOI
            let editora = subset.DETALHAMENTO-DO-LIVRO.NOME-DA-EDITORA
            let local = subset.DETALHAMENTO-DO-LIVRO.CIDADE-DA-EDITORA
            
            let pagina = []
            if subset.DETALHAMENTO-DO-LIVRO.NUMERO-DE-PAGINAS != "" {
                pagina = [#subset.DETALHAMENTO-DO-LIVRO.NUMERO-DE-PAGINAS]
            }

            // Palavras-chave
            if "PALAVRAS-CHAVE" in subset.keys() {
                for palavra in subset.PALAVRAS-CHAVE.keys() {
                    if subset.PALAVRAS-CHAVE.at(palavra) != "" {
                        palavras_chave.push(subset.PALAVRAS-CHAVE.at(palavra))    
                    }
                }
            }

            // criando string de palavras-chave
            if palavras_chave.len() > 0 {
                palavras_chave = palavras_chave.join("; ") + ";"
            }

            // areas de conhecimento
            if "AREAS-DO-CONHECIMENTO" in subset.keys() {
                for entrada in subset.AREAS-DO-CONHECIMENTO.keys() {
                    let subset2 = subset.AREAS-DO-CONHECIMENTO.at(entrada)
                    
                    for valor in subset2.keys() {
                        let area = subset2.at(valor)

                        // Define a function to capitalize the first letter of a substring
                        // let capitalize = (text) => str(text.slice(0, 1) + lower(text.slice(1)))

                        if area != "" {
                            let area_parts = area.split("_")

                            area = area_parts.map(capitalize).join(" ")

                            conhecimento.push(area)
                        }
                    }                
                }
            }

            // criando citação
            // criando link (prefire DOI)
            let doi_link = []
            if doi.len() > 0 {
                doi_link = [#link("https://doi.org/"+ doi)[DOI: #doi]]
            }
            
            // criando local & editora
            let local_editora_content = []
            if local != "" and editora != "" {
                local_editora_content = [#local: #editora,] 
            } else if local != "" and editora == "" {
                local_editora_content = [#local,]
            } else if local == "" and editora != "" {
                local_editora_content = [#editora,]
            } 

            // criando citacao
            let citacao = [#autores #text(titulo, weight: "semibold"). #local_editora_content #ano, p. #pagina. #doi_link #linebreak()]

            // criando content palavras-chave
            let palavras_content = []
            if palavras_chave.len() > 0 {
                palavras_content = [#text(rgb("B2B2B2"), size: 0.85em, "Palavras-chave: "+ palavras_chave) #linebreak()]
            } 

            // criando content para área
            let areas_content = [] 
            if conhecimento.len() > 0 {
                areas_content = [#text(rgb("B2B2B2"), size: 0.85em, "Áreas de conhecimento: "+ conhecimento.join(", "))]
            } 

            // criando descricao
            let descricao_content = []
            if tipo_lattes == "completo" {
                descricao_content = [#citacao #palavras_content #areas_content]
            } else {
                descricao_content = [#citacao]
            }        
            
            // publicando content
            create-cols([*#i*], [#descricao_content], "enum")
            
            // diminuir número
            i -= 1
        }
        
    }
}

// Função create-articles(): cria a área de produções bibliográficas - artigos (usado em create-bibliography())
// Argumentos:
//  - dados_artigos: subset do banco de dados com só livros
//  - me: nome para destacar nas entradas
//  - tipo_lattes: tipo de currículo Lattes
#let create-articles(dados_artigos, eu, tipo_lattes) = {

    // criando cabeçalho
    [=== Artigos completos publicados em periódicos <publicacao_artigos>]
    
    // criando número para ordem
    let i = dados_artigos.len()

    // criando entrada para cada artigo
    for entrada in dados_artigos.rev() {
        // initialize variables
        let palavras_chave = ()
        let conhecimento = ()
        let subset = entrada

        // authors:
        let autores = format-authors(subset.AUTORES, eu)        
        
        let titulo = subset.DADOS-BASICOS-DO-ARTIGO.TITULO-DO-ARTIGO
        let ano = subset.DADOS-BASICOS-DO-ARTIGO.ANO-DO-ARTIGO
        let doi = subset.DADOS-BASICOS-DO-ARTIGO.DOI
        let periodico = subset.DETALHAMENTO-DO-ARTIGO.TITULO-DO-PERIODICO-OU-REVISTA
        let volume = subset.DETALHAMENTO-DO-ARTIGO.VOLUME
    
        let pagina = []
        if subset.DETALHAMENTO-DO-ARTIGO.PAGINA-FINAL == "" {
            pagina = subset.DETALHAMENTO-DO-ARTIGO.PAGINA-INICIAL
        } else {
            pagina = [#subset.DETALHAMENTO-DO-ARTIGO.PAGINA-INICIAL - #subset.DETALHAMENTO-DO-ARTIGO.PAGINA-FINAL]
        }

        // palavras_chave
        if "PALAVRAS-CHAVE" in subset.keys() {
            for palavra in subset.PALAVRAS-CHAVE.keys() {
                if subset.PALAVRAS-CHAVE.at(palavra) != "" {
                    palavras_chave.push(subset.PALAVRAS-CHAVE.at(palavra))    
                }
            }
        }

        // criando string de palavras_chave
        if palavras_chave.len() > 0 {
            palavras_chave = palavras_chave.join("; ") + ";"
        }

        // criando áreas de conhecimento
        if "AREAS-DO-CONHECIMENTO" in entrada.keys() {
            let areas = entrada.at("AREAS-DO-CONHECIMENTO")

            let i = 0
            
            for key in areas.keys() {
                let subset = areas.at(key)
                
                if subset.NOME-DA-ESPECIALIDADE == "" {
                    if subset.NOME-DA-SUB-AREA-DO-CONHECIMENTO == ""{
                        if subset.NOME-DA-AREA-DO-CONHECIMENTO == "" {
                            let area = subset.NOME-GRANDE-AREA-DO-CONHECIMENTO
                            let partes = area.split("_")
                            let novas = ()
                            for entry in partes {
                                entry = upper(entry.slice(0, 1)) + lower(entry.slice(1))
                                entry = entry.replace("Ciencia", "Ciência")                                
                                novas.push(entry)
                            }
                            area = novas.join(" ")
                            conhecimento.push(area)
                        } else {
                            conhecimento.push(subset.NOME-DA-AREA-DO-CONHECIMENTO)
                        }
                    } else {
                        conhecimento.push(subset.NOME-DA-SUB-AREA-DO-CONHECIMENTO)
                    }
                } else {
                    conhecimento.push(subset.NOME-DA-Especialidade)
                }
            }
        }

        // criando string de áreas de conhecimento
        if conhecimento.len() > 0 {
            conhecimento = conhecimento.join(", ")
        }

        // criando conteúdo
        // criando link: DOI
        let doi_link = []
        if doi.len() > 0 {
            doi_link = [#link("https://doi.org/"+ doi)[DOI: #doi]]
        }

        // criando content citação
        let citacao = [#autores #text(titulo, weight: "semibold"). #emph(periodico). v. #volume. p. #pagina, #ano. #doi_link #linebreak()]
        
        // criando content palavras chave
        let palavras_content = []
        if palavras_chave.len() > 0 {
            palavras_content = [#text(rgb("B2B2B2"), size: 0.85em, "Palavras-chave: "+ palavras_chave) #linebreak()]
        } 
        
        // criando content para áreas de conhecimento
        let areas_content = [] 
        if conhecimento.len() > 0 {
            areas_content = [#text(rgb("B2B2B2"), size: 0.85em, "Áreas de conhecimento: "+ conhecimento)]
        } 

        // criando content para descrição 
        let descricao_content = []
        if tipo_lattes == "completo" {
            descricao_content = [#citacao #palavras_content #areas_content]
        } else {
            descricao_content = [#citacao]
        }
        
        // publicando content
        create-cols([*#i*], [#descricao_content], "enum")
        
        // diminuir número para ordem
        i -= 1
    }   
}

// Função create-abstracts-area(): Cria sub-área de resumos (completos, resumos, expandidos)
// Argumentos:
// - dados: sub-banco de dados com as entradas de tipo
// - eu: nome para destacar
// - tipo_lattes: cabeçalho da área
#let create-abstracts-area(dados, eu, tipo_lattes) = {
    
    let i = dados.len()

    for entrada in dados.rev() {

        // initialize variables
        let palavras_chave = ()
        let conhecimento = ()
        let subset = entrada

        // autores
        let autores = format-authors(subset.AUTORES, eu)        

        // título
        let titulo = subset.DADOS-BASICOS-DO-TRABALHO.TITULO-DO-TRABALHO

        // título de anais ou proceedings
        let titulo_anais = subset.DETALHAMENTO-DO-TRABALHO.TITULO-DOS-ANAIS-OU-PROCEEDINGS
        let local = subset.DETALHAMENTO-DO-TRABALHO.CIDADE-DO-EVENTO
        let editora = subset.DETALHAMENTO-DO-TRABALHO.NOME-DA-EDITORA
        let editora_local = subset.DETALHAMENTO-DO-TRABALHO.CIDADE-DA-EDITORA
        let evento_nome = subset.DETALHAMENTO-DO-TRABALHO.NOME-DO-EVENTO
        // ano
        let ano = subset.DADOS-BASICOS-DO-TRABALHO.ANO-DO-TRABALHO
        
        // doi
        let doi = subset.DADOS-BASICOS-DO-TRABALHO.DOI

        // criando lista de palavras-chave
        if "PALAVRAS-CHAVE" in subset.keys() {
            for palavra in subset.PALAVRAS-CHAVE.keys() {
                if subset.PALAVRAS-CHAVE.at(palavra) != "" {
                    palavras_chave.push(subset.PALAVRAS-CHAVE.at(palavra))    
                }
            }
        }

        // criando string de palavras-chave
        if palavras_chave.len() > 0 {
            palavras_chave = palavras_chave.join("; ") + ";"
        }

        // criando áreas de conhecimento
        if "AREAS-DO-CONHECIMENTO" in entrada.keys() {
            let areas = entrada.at("AREAS-DO-CONHECIMENTO")

            let i = 0
            
            for key in areas.keys() {
                let subset = areas.at(key)
                
                if subset.NOME-DA-ESPECIALIDADE == "" {
                    if subset.NOME-DA-SUB-AREA-DO-CONHECIMENTO == ""{
                        if subset.NOME-DA-AREA-DO-CONHECIMENTO == "" {
                            let area = subset.NOME-GRANDE-AREA-DO-CONHECIMENTO
                            let partes = area.split("_")
                            let novas = ()
                            for entry in partes {
                                entry = upper(entry.slice(0, 1)) + lower(entry.slice(1))
                                entry = entry.replace("Ciencia", "Ciência")                                
                                novas.push(entry)
                            }
                            area = novas.join(" ")
                            conhecimento.push(area)
                        } else {
                            conhecimento.push(subset.NOME-DA-AREA-DO-CONHECIMENTO)
                        }
                    } else {
                        conhecimento.push(subset.NOME-DA-SUB-AREA-DO-CONHECIMENTO)
                    }
                } else {
                    conhecimento.push(subset.NOME-DA-ESPECIALIDADE)
                }
            }
        }

        // criando string de áreas de conhecimento
        if conhecimento.len() > 0 {
            conhecimento = conhecimento.join(", ")
        }

        // criando o link, prefire DOI 
        let doi_link = []
        if doi.len() > 0 {
            doi_link = [#link("https://doi.org/"+ doi)[DOI: #doi]]
        }
        
        // criando local & editora
        let local_editora_content = []
        if local != "" and editora != "" {
            local_editora_content = [, #local: #editora] 
        } else if local != "" and editora == "" {
            local_editora_content = [, #local]
        } else if local == "" and editora != "" {
            if editora_local == "" {
                local_editora_content = [, #editora]
            } else {
                local_editora_content = [, #editora_local: #editora]
            }                
        } else {
            local_editora_content = []
        }

        // criando content titulo anais
        let titulo_anais_content = []
        if titulo_anais != "" {
            titulo_anais_content = [, #emph(titulo_anais)]
        }

        // criando citação
        let citacao = [#autores #text(titulo, weight: "semibold"). In: #evento_nome, #ano#local_editora_content#titulo_anais_content. #doi_link #linebreak()]

        // criando content palavras-chave
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
        let descricao_content = []
        if tipo_lattes == "completo" {
            descricao_content = [#citacao #palavras_content #areas_content]
        } else {
            descricao_content = [#citacao]
        }
        // publicando content
        create-cols([*#i*], [#descricao_content], "enum")

        // diminuir número para ordem
        i -= 1
    }   
}

// Função create-abstracts(): Cria área de produções técnicos (usado em create-bibliography)
// Argumentos:
//  - dados_completos: subset do banco de dados com completos
//  - dados_resumos: subset do banco de dados com resumos simples
//  - dados_expandidos: subset do banco de dados com resumos expandidos
//  - eu: nome para destacar nas entradas
#let create-abstracts(dados_completos, dados_resumos, dados_expandidos, eu, tipo_lattes) = {

    if dados_completos.len() > 0 {
        [=== Trabalhos publicados em anais de eventos (completos)<producao-anais>]

        create-abstracts-area(dados_completos, eu, tipo_lattes)

    }

    if dados_resumos.len() > 0 {
        [=== Trabalhos publicados em anais de eventos (resumo)]

        create-abstracts-area(dados_resumos, eu, tipo_lattes) 
    }

    if dados_expandidos.len() > 0 {
        [=== Trabalhos publicados em anais de eventos (resumo expandido)]

        create-abstracts-area(dados_expandidos, eu, tipo_lattes)
        
    }
}

// Função create-bibliography: Cria área de Produções: Artigos publicados, livros publicados, capítulos publicados e demais técnicos
// Argumentos:
//  - detalhes: o banco de dados com todas as informações (arquivo TOML)
//  - me: nome para destacar nas entradas
//  - tipo_lattes: tipo de currículo Lattes
#let create-bibliography(detalhes, eu, tipo_lattes) = {
    // criando banco de dados

    let artigos = ()
    //  artigos
    // checando que tem ou não tem
    if "ARTIGOS-PUBLICADOS" in detalhes.PRODUCAO-BIBLIOGRAFICA.keys() {
        let helper  = detalhes.PRODUCAO-BIBLIOGRAFICA.ARTIGOS-PUBLICADOS.ARTIGO-PUBLICADO

        if type(helper) == array {
            artigos = helper.sorted(
                key: (item) => (item.DADOS-BASICOS-DO-ARTIGO.ANO-DO-ARTIGO, item.DADOS-BASICOS-DO-ARTIGO.TITULO-DO-ARTIGO)
            )
        } else if type(helper) == dictionary {
            artigos.push(helper)
        }
    }
    
    // livros
    // checando que tem ou não tem
    let livros = ()
    if "LIVROS-PUBLICADOS-OU-ORGANIZADOS" in detalhes.PRODUCAO-BIBLIOGRAFICA.LIVROS-E-CAPITULOS.keys() {
        let helper = detalhes.PRODUCAO-BIBLIOGRAFICA.LIVROS-E-CAPITULOS.LIVROS-PUBLICADOS-OU-ORGANIZADOS

        if type(helper) == array {
            livros = helper.LIVRO-PUBLICADO-OU-ORGANIZADO.sorted(
                key: (item) => (item.DADOS-BASICOS-DO-LIVRO.ANO, item.DADOS-BASICOS-DO-LIVRO.TITULO-DO-LIVRO)
            )
        } else if type(helper) == dictionary {
            livros.push(helper.LIVRO-PUBLICADO-OU-ORGANIZADO)
        }
    }
    
    // capítulos
    // checando que tem ou não tem
    let capitulos = () 
    if "CAPITULOS-DE-LIVROS-PUBLICADOS" in detalhes.PRODUCAO-BIBLIOGRAFICA.LIVROS-E-CAPITULOS.keys() {
        let helper = detalhes.PRODUCAO-BIBLIOGRAFICA.LIVROS-E-CAPITULOS.CAPITULOS-DE-LIVROS-PUBLICADOS
        // caso mais de uma entrada
        if type(helper) == array {
            capitulos = helper.CAPITULO-DE-LIVRO-PUBLICADO.sorted(
                key: (item) => (item.DADOS-BASICOS-DO-CAPITULO.ANO, item.DADOS-BASICOS-DO-CAPITULO.TITULO-DO-CAPITULO-DO-LIVRO)
            )
        // caso somente uma entrada
        } else if type(helper) == dictionary {
            capitulos.push(helper.CAPITULO-DE-LIVRO-PUBLICADO)
        }
    }

    // para apresentações de trabalho e palestra
    // checando que tem ou não tem
    let apresentacoes = ()
    if "APRESENTACAO-DE-TRABALHO" in detalhes.PRODUCAO-TECNICA.DEMAIS-TIPOS-DE-PRODUCAO-TECNICA.keys() {
        let helper  = detalhes.PRODUCAO-TECNICA.DEMAIS-TIPOS-DE-PRODUCAO-TECNICA.APRESENTACAO-DE-TRABALHO

        if type(helper) == array {
            apresentacoes = helper.sorted(
                key: (item) => (item.DADOS-BASICOS-DA-APRESENTACAO-DE-TRABALHO.ANO, item.DADOS-BASICOS-DA-APRESENTACAO-DE-TRABALHO.TITULO)
            )
        } else if type(helper) == dictionary {
            apresentacoes.push(helper)
        }
        
    }

    // para resumos e resumos expandidos
    let completos = ()
    let resumos = ()
    let expandidos = ()

    // checando que tem ou não tem
    if "TRABALHOS-EM-EVENTOS" in detalhes.PRODUCAO-BIBLIOGRAFICA.keys() {
        if "TRABALHO-EM-EVENTOS" in detalhes.PRODUCAO-BIBLIOGRAFICA.TRABALHOS-EM-EVENTOS.keys() {
            let helper = detalhes.PRODUCAO-BIBLIOGRAFICA.TRABALHOS-EM-EVENTOS.TRABALHO-EM-EVENTOS
            if type(helper) == array {
                for entrada in helper {
                                    
                    // caso somente uma entrada
                    if type(entrada) == dictionary {
                        if entrada.DADOS-BASICOS-DO-TRABALHO.NATUREZA == "RESUMO" {
                            resumos.push(entrada)
                        } else if entrada.DADOS-BASICOS-DO-TRABALHO.NATUREZA == "RESUMO_EXPANDIDO" {
                            expandidos.push(entrada)
                        } else if entrada.DADOS-BASICOS-DO-TRABALHO.NATUREZA == "COMPLETO" {
                            completos.push(entrada)
                        }
                    // caso mais de uma entrada
                    } else if type(entrada) == array {
                        if entrada.DADOS-BASICOS-DO-TRABALHO.NATUREZA == "RESUMO" {
                            resumos.push(entrada)
                        } else if entrada.DADOS-BASICOS-DO-TRABALHO.NATUREZA == "RESUMO_EXPANDIDO" {
                            expandidos.push(entrada)
                        } else if entrada.DADOS-BASICOS-DO-TRABALHO.NATUREZA == "COMPLETO" {
                            completos.push(entrada)
                        }
                    }
                }
            } else if type(helper) == dictionary {
                if helper.DADOS-BASICOS-DO-TRABALHO.NATUREZA == "RESUMO" {
                    resumos.push(helper)
                } else if helper.DADOS-BASICOS-DO-TRABALHO.NATUREZA == "RESUMO_EXPANDIDO" {
                    expandidos.push(helper)
                }  else if helper.DADOS-BASICOS-DO-TRABALHO.NATUREZA == "COMPLETO" {
                    completos.push(helper)
                }
            }
        }

        // ordenar
        completos = completos.sorted(
            key: (item) => (item.DADOS-BASICOS-DO-TRABALHO.ANO-DO-TRABALHO, item.DADOS-BASICOS-DO-TRABALHO.TITULO-DO-TRABALHO)
        )

        resumos = resumos.sorted(
            key: (item) => (item.DADOS-BASICOS-DO-TRABALHO.ANO-DO-TRABALHO, item.DADOS-BASICOS-DO-TRABALHO.TITULO-DO-TRABALHO)
        )

        expandidos = expandidos.sorted(
            key: (item) => (item.DADOS-BASICOS-DO-TRABALHO.ANO-DO-TRABALHO, item.DADOS-BASICOS-DO-TRABALHO.TITULO-DO-TRABALHO)
        )
    }
    

    // para demais técnicas
    // checando que tem ou não tem
    let todos = ()

    if "PRODUCAO-TECNICA" in detalhes.keys() {
        if "DEMAIS-TIPOS-DE-PRODUCAO-TECNICA" in detalhes.PRODUCAO-TECNICA.keys() {    
            let subset = detalhes.PRODUCAO-TECNICA.DEMAIS-TIPOS-DE-PRODUCAO-TECNICA

            if "DESENVOLVIMENTO-DE-MATERIAL-DIDATICO-OU-INSTRUCIONAL" in subset.keys() {
                if type(subset.DESENVOLVIMENTO-DE-MATERIAL-DIDATICO-OU-INSTRUCIONAL) == array {
                    let didatico = detalhes.PRODUCAO-TECNICA.DEMAIS-TIPOS-DE-PRODUCAO-TECNICA.DESENVOLVIMENTO-DE-MATERIAL-DIDATICO-OU-INSTRUCIONAL

                    for entrada in didatico {
                        let helper = entrada
                        helper.insert("ORDER1", entrada.DADOS-BASICOS-DO-MATERIAL-DIDATICO-OU-INSTRUCIONAL.ANO)
                        helper.insert("ORDER2", entrada.DADOS-BASICOS-DO-MATERIAL-DIDATICO-OU-INSTRUCIONAL.TITULO)
                        todos.push(helper)
                    }
                    
                } else if type(subset.DESENVOLVIMENTO-DE-MATERIAL-DIDATICO-OU-INSTRUCIONAL) == dictionary {
                    let helper = subset.DESENVOLVIMENTO-DE-MATERIAL-DIDATICO-OU-INSTRUCIONAL
                    helper.insert("ORDER1", subset.DESENVOLVIMENTO-DE-MATERIAL-DIDATICO-OU-INSTRUCIONAL.DADOS-BASICOS-DO-MATERIAL-DIDATICO-OU-INSTRUCIONAL.ANO)
                    helper.insert("ORDER2", subset.DESENVOLVIMENTO-DE-MATERIAL-DIDATICO-OU-INSTRUCIONAL.DADOS-BASICOS-DO-MATERIAL-DIDATICO-OU-INSTRUCIONAL.TITULO)
                    todos.push(helper)

                }
            } 
        
            // Relatórios de pesquisa
            // checando que tem ou não tem
            if "RELATORIO-DE-PESQUISA" in detalhes.PRODUCAO-TECNICA.DEMAIS-TIPOS-DE-PRODUCAO-TECNICA.keys() {
                if type(subset.RELATORIO-DE-PESQUISA) == array {
                    let relatorio = subset.RELATORIO-DE-PESQUISA

                    for entrada in relatorio {
                        let helper = entrada
                        helper.insert("ORDER1", entrada.DADOS-BASICOS-DO-RELATORIO-DE-PESQUISA.ANO)
                        helper.insert("ORDER2", entrada.DADOS-BASICOS-DO-RELATORIO-DE-PESQUISA.TITULO)
                        todos.push(helper)
                    }
                } else if type(subset.RELATORIO-DE-PESQUISA) == dictionary {
                    let helper = subset.RELATORIO-DE-PESQUISA
                    helper.insert("ORDER1", subset.RELATORIO-DE-PESQUISA.DADOS-BASICOS-DO-RELATORIO-DE-PESQUISA.ANO)
                    helper.insert("ORDER2", subset.RELATORIO-DE-PESQUISA.DADOS-BASICOS-DO-RELATORIO-DE-PESQUISA.TITULO)
                    todos.push(helper)
                }
            }
            
            // cursos curtos
            // checando que tem ou não tem            
            if "CURSO-DE-CURTA-DURACAO-MINISTRADO" in detalhes.PRODUCAO-TECNICA.DEMAIS-TIPOS-DE-PRODUCAO-TECNICA.keys() {
                if type(subset.CURSO-DE-CURTA-DURACAO-MINISTRADO) == array {
                    let cursos_curtos = detalhes.PRODUCAO-TECNICA.DEMAIS-TIPOS-DE-PRODUCAO-TECNICA.CURSO-DE-CURTA-DURACAO-MINISTRADO
                    
                    for entrada in cursos_curtos {
                        let helper = entrada
                        helper.insert("ORDER1", entrada.DADOS-BASICOS-DE-CURSOS-CURTA-DURACAO-MINISTRADO.ANO)
                        helper.insert("ORDER2", entrada.DADOS-BASICOS-DE-CURSOS-CURTA-DURACAO-MINISTRADO.TITULO)
                        todos.push(helper)
                    }
                    

                } else if type(subset.CURSO-DE-CURTA-DURACAO-MINISTRADO) == dictionary {
                    let helper = subset.CURSO-DE-CURTA-DURACAO-MINISTRADO
                    helper.insert("ORDER1", subset.CURSO-DE-CURTA-DURACAO-MINISTRADO.DADOS-BASICOS-DE-CURSOS-CURTA-DURACAO-MINISTRADO.ANO)
                    helper.insert("ORDER2", subset.CURSO-DE-CURTA-DURACAO-MINISTRADO.DADOS-BASICOS-DE-CURSOS-CURTA-DURACAO-MINISTRADO.TITULO)
                    todos.push(helper)
                }
            }
                
        }

        todos = todos.sorted(key: (item) => (item.ORDER1, item.ORDER2))
    }

    // criando cabeçalho
    if artigos.len() > 0 or livros.len() > 0 or capitulos.len() > 0 or apresentacoes.len() > 0 or completos.len() > 0 or resumos.len() > 0 or expandidos.len() > 0 or todos.len() > 0 {
        [= Produção <producao>]
    }

    if artigos.len() > 0 or livros.len() > 0 or capitulos.len() > 0 or apresentacoes.len() > 0 or completos.len() > 0 or resumos.len() > 0 or expandidos.len() > 0 {
        [== Produção bibliográfica <producao_bibliografica>]
    }

    // criando área de artigos
    if artigos.len() > 0 {
        create-articles(artigos, eu, tipo_lattes)
    }

    // criando área de livros
    if livros.len() > 0 {
        create-books(livros, eu, tipo_lattes)
    }

    // criando área de capítulos
    if capitulos.len() > 0 {
        create-chapters(capitulos, eu, tipo_lattes)
    }

    // criando área de resumos e resumos expandidos
    if resumos.len() > 0 or expandidos.len() > 0 {
        create-abstracts(completos, resumos, expandidos, eu, tipo_lattes)
    }

    // criando área de apresentações
    if tipo_lattes == "completo" {
        if apresentacoes.len() > 0 {
            create-presentations(apresentacoes, eu)
        }
    }
    
    // criando área de técnicos
    if todos.len() > 0 {
        create-technicals(todos, eu, tipo_lattes)
    }

    linebreak()

    line(length: 100%)
}