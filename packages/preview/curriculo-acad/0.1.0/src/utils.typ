// Neste arquivo você encontra funções para criar os vários inputs
// Cada função possui uma descrição preliminar
// As variáveis no nível local estão em português
// Variáveis globais (as que são passadas adiante) estão em inglês
// Funcções também estão em inglês

// imports
#import "@preview/datify:0.1.3": *

// Função _create-cols(): define estilo e tabela
// Argumentos:
// - left: o conteúdo a ser colocado na primeira coluna (Tipo: Qualquer)
// - right: o conteúdo a ser colocado na segunda coluna (Tipo: Qualquer)
// - type: escolha a separação das colunas (tipos: "small", "wide", "enum", "lastpage")
// - ..args: argumentos nomeados adicionais para personalização
#let _create-cols(left, right, type, ..args) = {
  
  // Defina o estilo do bloco sem espaçamento abaixo
  set block(below: 0pt)
  let col_width = (0.85fr, 5fr)
  if type == "small" {
    col_width = (0.87fr, 5fr)
  } else if type == "wide" {
    col_width = (1.1fr, 4fr)
  } else if type == "enum" {
    col_width = (0.4fr, 5fr)
  } else if type == "lastpage" {
    col_width = (5fr, 0.4fr)
  }

  // Crie uma tabela com larguras de coluna especificadas e sem bordas
  table(
    columns: col_width, // Defina as larguras das colunas
    stroke: none, // Sem bordas
    
    // Espalhe quaisquer argumentos nomeados
    ..args.named(),
    
    // Insira o conteúdo da esquerda e da direita na tabela
    left,
    right,
  )
}

// Função create-cols(): Coloca o input na tabela
// Argumentos:
// - left-side: o conteúdo a ser alinhado à esquerda (Tipo: Qualquer)
// - right-side: o conteúdo a ser formatado como um parágrafo com alinhamento justificado (Tipo: Qualquer)
// - type: string que define o tipo: "small", "wide", "enum" ou "lastpage"
#let create-cols(left-side, right-side, type) = {
  
  // Chame o _cv-cols com os parâmetros left-side alinhado à esquerda e right-side justificado
  if type == "lastpage" {
    _create-cols(
        align(right, left-side),
        par(right-side, justify:false),
        type
    )
  } else {
    _create-cols(
        // Alinhe o conteúdo da left-side à direita
        align(right, left-side),
        // Formate o conteúdo da right-side como um parágrafo com alinhamento justificado
        align(left, par(right-side, justify: true)),
        type
        )
  }
}

// Função format-authors(): formata os nomes de autores/membros etc. no estilo de ABNT
// Argumentos:
//  - autores: array de autores
//  - eu: indicaco de nome para destacar
#let format-authors(autores, eu) = {
    // criando array para pegar os nomes
    let formatted_authors = ()

    if type(autores) == array { 
        // criando formato de ABNT para cada autor
        for autor in autores {
        // caso so uma pessoa
            if type(autor) == dictionary {
                // tirando a entrada de citação (poderia ser de mais um nome separado com ";")
                let nomes = autor.NOME-PARA-CITACAO.split(";")
                // tirando primeira entrada
                let primeira = nomes.at(0) 
                
                let sobrenome = ""
                let nome = ""
                // caso: formato é  SOBRENOME, NOME 
                if primeira.find(", ") != none {
                    let helper = primeira.split(", ")
                    // destaca o sobrenome em estilo de ABNT
                    sobrenome = upper(helper.at(0))
                    // checando que tem mais de um nome
                    let helper2 = helper.at(1).split(" ")
                    // caso mais de uma entrada 
                    if helper2.len() > 1 {
                        for entry in helper2 {
                            let helper3 = entry.first() + "."
                            // adicionando um espaco se não é o último
                            if entry != helper2.last() {
                                nome = nome + helper3 + " "
                            } else {
                                nome = nome + helper3    
                            }
                        }
                    // caso somente uma entrada
                    } else if helper2.len() == 1 {
                        nome = helper2.at(0).first() + "."
                    }

                // caso: formato é NOME SOBRENOME
                } else {
                    let helper = primeira.split(" ")
                    sobrenome = upper(helper.last())
                    
                }

                let nome_completo = sobrenome + ", " + nome

                formatted_authors.push(nome_completo)
            // caso de mais de uma pessoa
            } else if type(autor) == array {
                if autor.at(0) == "NOME-PARA-CITACAO" {
                    let nomes = autores.NOME-PARA-CITACAO.split(";")
                    
                    // tirando primeira entrada
                    let primeira = nomes.at(0) 
                    
                    let sobrenome = ""
                    let nome = ""

                    // caso: formato é  SOBRENOME, NOME 
                    if primeira.find(", ") != none {
                        let helper = primeira.split(", ")
                        // destaca o sobrenome em estilo de ABNT
                        sobrenome = upper(helper.at(0))
                        // checando que tem mais de um nome
                        let helper2 = helper.at(1).split(" ")
                        // caso mais de uma entrada 
                        if helper2.len() > 1 {
                            for entry in helper2 {
                                let helper3 = entry.first() + "."
                                // adicionando um espaco se não é o último
                                if entry != helper2.last() {
                                    nome = nome + helper3 + " "
                                } else {
                                    nome = nome + helper3    
                                }
                            }
                        // caso somente uma entrada
                        } else if helper2.len() == 1 {
                            nome = helper2.at(0).first() + "."
                        }

                    // caso: formato é NOME SOBRENOME
                    } else {
                        let helper = primeira.split(" ")
                        sobrenome = upper(helper.last())
                        
                    }

                    let nome_completo = sobrenome + ", " + nome

                    formatted_authors.push(nome_completo)
                }
            } 
        }

        // criando string para destacar o nome
        formatted_authors = formatted_authors.join("; ")

        // destacar o nome
        if not eu == none {
            if type(formatted_authors) != none and formatted_authors != none {
                let pesquisa = formatted_authors.match(eu)
                if pesquisa != none {
                    if pesquisa.start == 0 {
                        formatted_authors = [*#formatted_authors.slice(pesquisa.start, pesquisa.end)*#formatted_authors.slice(pesquisa.end)]
                    } else if pesquisa.start != none {
                        formatted_authors = [#formatted_authors.slice(0, pesquisa.start)*#formatted_authors.slice(pesquisa.start, pesquisa.end)*#formatted_authors.slice(pesquisa.end)]
                    }
                }
            }
        }

        // retornar o novo formato com destacar o nome
        return [#formatted_authors]  
    } else if type(autores) == dictionary {
        let nomes = autores.NOME-PARA-CITACAO.split(";")
                    
        // tirando primeira entrada
        let primeira = nomes.at(0) 
        
        let sobrenome = ""
        let nome = ""

        // caso: formato é  SOBRENOME, NOME 
        if primeira.find(", ") != none {
            let helper = primeira.split(", ")
            // destaca o sobrenome em estilo de ABNT
            sobrenome = upper(helper.at(0))
            // checando que tem mais de um nome
            let helper2 = helper.at(1).split(" ")
            // caso mais de uma entrada 
            if helper2.len() > 1 {
                for entry in helper2 {
                    let helper3 = entry.first() + "."
                    // adicionando um espaco se não é o último
                    if entry != helper2.last() {
                        nome = nome + helper3 + " "
                    } else {
                        nome = nome + helper3    
                    }
                }
            // caso somente uma entrada
            } else if helper2.len() == 1 {
                nome = helper2.at(0).first() + "."
            }

        // caso: formato é NOME SOBRENOME
        } else {
            let helper = primeira.split(" ")
            sobrenome = upper(helper.last())
            
        }

        let nome_completo = sobrenome + ", " + nome

        formatted_authors.push(nome_completo)
        
        formatted_authors = formatted_authors.join("; ")

        // destacar o nome
        if not eu == none {
            if type(formatted_authors) != none and formatted_authors != none {
                let pesquisa = formatted_authors.match(eu)
                if pesquisa != none {
                    if pesquisa.start == 0 {
                        formatted_authors = [*#formatted_authors.slice(pesquisa.start, pesquisa.end)*#formatted_authors.slice(pesquisa.end)]
                    } else if pesquisa.start != none {
                        formatted_authors = [#formatted_authors.slice(0, pesquisa.start)*#formatted_authors.slice(pesquisa.start, pesquisa.end)*#formatted_authors.slice(pesquisa.end)]
                    }
                }
            }
        }

        // retornar o novo formato com destacar o nome
        return [#formatted_authors]  
    }
}

// Função format-participants(): formata os nomes de integrantes/membros etc. no estilo de ABNT
// Argumentos:
//  - integrantes: array de integrantes
//  - eu: indicaco de nome para destacar
#let format-participants(integrantes, eu) = {
    // criando array para pegar os nomes
    let formatted_participants = ()

    if type(integrantes) == array { 
        // criando formato de ABNT para cada autor
        for integrante in integrantes {
        // caso so uma pessoa
            if type(integrante) == dictionary {
                // tirando a entrada de citação (poderia ser de mais um nome separado com ";")
                let nomes = integrante.NOME-PARA-CITACAO.split(";")
                // tirando primeira entrada
                let primeira = nomes.at(0) 
                
                let sobrenome = ""
                let nome = ""
                // caso: formato é  SOBRENOME, NOME 
                if primeira.find(", ") != none {
                    let helper = primeira.split(", ")
                    // destaca o sobrenome em estilo de ABNT
                    sobrenome = upper(helper.at(0))
                    // checando que tem mais de um nome
                    let helper2 = helper.at(1).split(" ")
                    // caso mais de uma entrada 
                    if helper2.len() > 1 {
                        for entry in helper2 {
                            let helper3 = entry.first() + "."
                            // adicionando um espaco se não é o último
                            if entry != helper2.last() {
                                nome = nome + helper3 + " "
                            } else {
                                nome = nome + helper3    
                            }
                        }
                    // caso somente uma entrada
                    } else if helper2.len() == 1 {
                        nome = helper2.at(0).first() + "."
                    }

                // caso: formato é NOME SOBRENOME
                } else {
                    let helper = primeira.split(" ")
                    sobrenome = upper(helper.last())
                    
                }

                let nome_completo = sobrenome + ", " + nome

                if integrante.FLAG-RESPONSAVEL == "SIM" { 
                    nome_completo = nome_completo + " (responsável)"
                } 
                formatted_participants.push(nome_completo)
            // caso de mais de uma pessoa
            } else if type(integrante) == array {
                if integrante.at(0) == "NOME-PARA-CITACAO" {
                    let nomes = integrantes.NOME-PARA-CITACAO.split(";")
                    
                    // tirando primeira entrada
                    let primeira = nomes.at(0) 
                    
                    let sobrenome = ""
                    let nome = ""

                    // caso: formato é  SOBRENOME, NOME 
                    if primeira.find(", ") != none {
                        let helper = primeira.split(", ")
                        // destaca o sobrenome em estilo de ABNT
                        sobrenome = upper(helper.at(0))
                        // checando que tem mais de um nome
                        let helper2 = helper.at(1).split(" ")
                        // caso mais de uma entrada 
                        if helper2.len() > 1 {
                            for entry in helper2 {
                                let helper3 = entry.first() + "."
                                // adicionando um espaco se não é o último
                                if entry != helper2.last() {
                                    nome = nome + helper3 + " "
                                } else {
                                    nome = nome + helper3    
                                }
                            }
                        // caso somente uma entrada
                        } else if helper2.len() == 1 {
                            nome = helper2.at(0).first() + "."
                        }

                    // caso: formato é NOME SOBRENOME
                    } else {
                        let helper = primeira.split(" ")
                        sobrenome = upper(helper.last())
                        
                    }

                    let nome_completo = sobrenome + ", " + nome

                    formatted_participants.push(nome_completo)
                }
            } 
        }

        // criando string para destacar o nome
        formatted_participants = formatted_participants.join("; ")

        // destacar o nome
        if not eu == none {
            if type(formatted_participants) != none and formatted_participants != none {
                let pesquisa = formatted_participants.match(eu)
                if pesquisa != none {
                    if pesquisa.start == 0 {
                        formatted_participants = [*#formatted_participants.slice(pesquisa.start, pesquisa.end)*#formatted_participants.slice(pesquisa.end)]
                    } else if pesquisa.start != none {
                        formatted_participants = [#formatted_participants.slice(0, pesquisa.start)*#formatted_participants.slice(pesquisa.start, pesquisa.end)*#formatted_participants.slice(pesquisa.end)]
                    }
                }
            }
        }

        // retornar o novo formato com destacar o nome
        return [#formatted_participants]  
    } else if type(integrantes) == dictionary {
        let nomes = integrantes.NOME-PARA-CITACAO.split(";")
                    
        // tirando primeira entrada
        let primeira = nomes.at(0) 
        
        let sobrenome = ""
        let nome = ""

        // caso: formato é  SOBRENOME, NOME 
        if primeira.find(", ") != none {
            let helper = primeira.split(", ")
            // destaca o sobrenome em estilo de ABNT
            sobrenome = upper(helper.at(0))
            // checando que tem mais de um nome
            let helper2 = helper.at(1).split(" ")
            // caso mais de uma entrada 
            if helper2.len() > 1 {
                for entry in helper2 {
                    let helper3 = entry.first() + "."
                    // adicionando um espaco se não é o último
                    if entry != helper2.last() {
                        nome = nome + helper3 + " "
                    } else {
                        nome = nome + helper3    
                    }
                }
            // caso somente uma entrada
            } else if helper2.len() == 1 {
                nome = helper2.at(0).first() + "."
            }

        // caso: formato é NOME SOBRENOME
        } else {
            let helper = primeira.split(" ")
            sobrenome = upper(helper.last())
            
        }

        let nome_completo = sobrenome + ", " + nome

        formatted_participants.push(nome_completo)
        
        formatted_participants = formatted_participants.join("; ")

        // destacar o nome
        if not eu == none {
            if type(formatted_participants) != none and formatted_participants != none {
                let pesquisa = formatted_participants.match(eu)
                if pesquisa != none {
                    if pesquisa.start == 0 {
                        formatted_participants = [*#formatted_participants.slice(pesquisa.start, pesquisa.end)*#formatted_participants.slice(pesquisa.end)]
                    } else if pesquisa.start != none {
                        formatted_participants = [#formatted_participants.slice(0, pesquisa.start)*#formatted_participants.slice(pesquisa.start, pesquisa.end)*#formatted_participants.slice(pesquisa.end)]
                    }
                }
            }
        }

        // retornar o novo formato com destacar o nome
        return [#formatted_participants]  
    }
}

// Função replace-quotes(): substitui o código HTML &quot; com "
// Argumento:
// - texto: string para ver
#let replace-quotes(texto) = {
    let novo_texto = str
    if type(texto) != str {
        panic("O input precisa ser string!")
    } else {
        novo_texto = texto.replace("&quot;", "\"")
    }

    return novo_texto
}

// Função capitalize(): criar área ou descrição com minusculos
// Argumento
// - texto: string para ver
#let capitalize(text) = {
   return [#text.slice(0, 1)#lower(text.slice(1))]
}


