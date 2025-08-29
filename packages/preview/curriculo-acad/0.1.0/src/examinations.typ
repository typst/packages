#import "utils.typ": *

// Função create-examinations(): Cria entradas de bancas
// TODO: Até agora somente bancas de conclusão
// Argumentos:
//  - detalhes: o banco de dados com todas as informações (arquivo TOML)
//  - me: nome para destacar no currículo (string)
#let create-examinations(detalhes, eu) = {
    // criando banco de dados
    let bancas = detalhes.DADOS-COMPLEMENTARES.PARTICIPACAO-EM-BANCA-TRABALHOS-CONCLUSAO

    // criando banco de dados para cada tipo
    let bancas_graduacao = (:)
    let bancas_mestrado = (:)
    let bancas_doutorado = (:)

    // criando banco de dados para cada tipo depende da existência
    // para graduação
    // TODO: Não tenho certeza sobre o key
    if "PARTICIPACAO-EM-BANCA-DE-GRADUACAO" in bancas.keys() {
        bancas_graduacao = bancas.PARTICIPACAO-EM-BANCA-DE-GRADUACAO

        bancas_graduacao = bancas_graduacao.sorted(key: (item) => (item.DADOS-BASICOS-DA-PARTICIPACAO-EM-BANCA-DE-GRADUACAO.ANO))
    } else {
        bancas_graduacao = (:)
    }

    // para mestrado
    if "PARTICIPACAO-EM-BANCA-DE-MESTRADO" in bancas.keys() {
        bancas_mestrado = bancas.PARTICIPACAO-EM-BANCA-DE-MESTRADO

        bancas_mestrado = bancas_mestrado.sorted(key: (item) => (item.DADOS-BASICOS-DA-PARTICIPACAO-EM-BANCA-DE-MESTRADO.ANO))
    } else {
        bancas_mestrado = (:)
    }

    // para doutorado
    // TODO: Não tenho certeza sobre o key
    if "PARTICIPACAO-EM-BANCA-DE-DOUTORADO" in bancas.keys() {
        bancas_doutorado = bancas.PARTICIPACAO-EM-BANCA-DE-DOUTORADO

        bancas_doutorado = bancas_doutorado.sorted(key: (item) => (item.DADOS-BASICOS-DA-PARTICIPACAO-EM-BANCA-DE-MESTRADO.ANO))
    } else {
        bancas_doutorado = (:)
    }

    // criando entrada se ao mínimo um tipo de banca > 0
    if bancas_graduacao.len() > 0 or bancas_mestrado.len() > 0  or bancas_doutorado.len() > 0 [
        = Bancas <bancas>
        == Participação em banca de trabalhos de conclusão <bancas_conclusao>
    ]

    // criando entradas para graduação, se ao mínimo tem uma entrada
    // TODO: Não tenho certeza sobre o key, provavelmente dê erro
    if bancas_graduacao.len() > 0 {
        // criando cabeçalho
        [== Graduação <bancas_conclusao_graduacao>]

        // Para ordem decrescente (vantagem: na primeira entrada você pode ver quantas ações uma pessoa fez)
        let i = bancas_graduacao.len()

        for banca in bancas_graduacao.rev() {
            // criando entradas
            let participantes = ()
            let candidato = banca.DETALHAMENTO-DA-PARTICIPACAO-EM-BANCA-DE-GRADUACAO.NOME-DO-CANDIDATO
            let titulo = banca.DADOS-BASICOS-DA-PARTICIPACAO-EM-BANCA-DE-GRADUACAO.TITULO
            let ano = banca.DADOS-BASICOS-DA-PARTICIPACAO-EM-BANCA-DE-GRADUACAO.ANO
            let programa = banca.DETALHAMENTO-DA-PARTICIPACAO-EM-BANCA-DE-GRADUACAO.NOME-CURSO
            let universidade = banca.DETALHAMENTO-DA-PARTICIPACAO-EM-BANCA-DE-GRADUACAO.NOME-INSTITUICAO
            
            // se somente tem uma entrada, type é dictionary
            // se tem mais de uma entrada, type é array
            // o texto vai ser formato no estilo de ABNT
            if type(banca.PARTICIPANTE-BANCA) == dictionary {
                if "NOME-PARA-CITACAO-DO-PARTICIPANTE-DA-BANCA" in pessoa.keys() {
                    let nome = pessoa.at("NOME-PARA-CITACAO-DO-PARTICIPANTE-DA-BANCA").split(";")
                    participants.push(nome.at(0))
                }
            } else if type(banca.PARTICIPANTE-BANCA) == array {
                let subset = banca.PARTICIPANTE-BANCA
                for participante in subset {
                    let nome = participante.NOME-PARA-CITACAO-DO-PARTICIPANTE-DA-BANCA.split(";")
                    participantes.push(nome.at(0))
                }      
            }

            // criando string de todas pessoas na banca
            participantes = participantes.join("; ")
            
            // destacar o nome que foi indicado
            if not eu == none {
                if type(participantes) != none and participantes != none {
                    let pesquisa = participantes.match(eu)
                    if pesquisa != none {
                        if pesquisa.start == 0 {
                            participantes = [*#participantes.slice(pesquisa.start, pesquisa.end)*#participantes.slice(pesquisa.end)]
                        } else if pesquisa.start != none {
                            participantes = [#participantes.slice(0, pesquisa.start)*#participantes.slice(pesquisa.start, pesquisa.end)*#participantes.slice(pesquisa.end)]
                        }
                    }
                }
            }

            // publicando content
            create-cols([*#i*], [#participantes Participação em banca de #candidato. #emph(titulo), #ano. (#programa), #universidade.], "enum")

            // diminuir o número (enumerar descendo)
            i -= 1
        }
    }

    if bancas_mestrado.len() > 0 {
        // criando cabeçalho
        [== Mestrado <bancas_mestrado_graduacao>]

        // Para ordem decrescente (vantagem: na primeira entrada você pode ver quantas ações uma pessoa fez)
        let i = bancas_mestrado.len()

        for banca in bancas_mestrado.rev() {
            // criando entradas
            let participantes = ()
            let candidato = banca.DETALHAMENTO-DA-PARTICIPACAO-EM-BANCA-DE-MESTRADO.NOME-DO-CANDIDATO
            let titulo = banca.DADOS-BASICOS-DA-PARTICIPACAO-EM-BANCA-DE-MESTRADO.TITULO
            let ano = banca.DADOS-BASICOS-DA-PARTICIPACAO-EM-BANCA-DE-MESTRADO.ANO
            let programa = banca.DETALHAMENTO-DA-PARTICIPACAO-EM-BANCA-DE-MESTRADO.NOME-CURSO
            let universidade = banca.DETALHAMENTO-DA-PARTICIPACAO-EM-BANCA-DE-MESTRADO.NOME-INSTITUICAO

            // se somente tem uma entrada, type é dictionary
            // se tem mais de uma entrada, type é array
            // o texto vai ser formato no estilo de ABNT
            if type(banca.PARTICIPANTE-BANCA) == dictionary {
                if "NOME-PARA-CITACAO-DO-PARTICIPANTE-DA-BANCA" in pessoa.keys() {
                    let nome_partes = pessoa.at("NOME-PARA-CITACAO-DO-PARTICIPANTE-DA-BANCA").split(", ")
                    let nome = nome_partes.at(0).slice(0, 1) + lower(nome_partes.at(0).slice(1)) + ", " + nome_partes.at(1).slice(0, 1) + "."
                    // Array if only one person, therefore, always resonpsable
                    participants.push(nome)
                }
            } else if type(banca.PARTICIPANTE-BANCA) == array {
                let subset = banca.PARTICIPANTE-BANCA
                for participante in subset {
                    let nome_partes = participante.NOME-PARA-CITACAO-DO-PARTICIPANTE-DA-BANCA.split(", ")
                    let nome = upper(nome_partes.at(0)) + ", " + nome_partes.at(1).slice(0, 1) + "."
                    participantes.push(nome)
                }      
            }

            // criando string de todas pessoas na banca
            participantes = participantes.join("; ")

            // destacar o nome que foi indicado
            if not eu == none {
                if type(participantes) != none and participantes != none {
                    let pesquisa = participantes.match(eu)
                    if pesquisa != none {
                        if pesquisa.start == 0 {
                            participants = [*#participantes.slice(pesquisa.start, pesquisa.end)*#participantes.slice(pesquisa.end)]
                        } else if pesquisa.start != none {
                            participantes = [#participantes.slice(0, pesquisa.start)*#participantes.slice(pesquisa.start, pesquisa.end)*#participantes.slice(pesquisa.end)]
                        }
                    }
                }
            }

            // publicando content
            create-cols([*#i*], [#participantes Participação em banca de #candidato. #emph(titulo), #ano. (#programa), #universidade.], "enum")

            // diminuir o número (enumerar descendo)
            i -= 1
        }
    }
    
    // TODO: Não tenho certeza sobre o key! Provavelmente dê erro
    if bancas_doutorado.len() > 0 {
        // criando cabeçalho
        [== Doutorado <bancas_conclusao_doutorado>]

        // Para ordem decrescente (vantagem: na primeira entrada você pode ver quantas ações uma pessoa fez)
        let i = bancas_doutorado.len()

        for banca in bancas_doutorado.rev() {
            // criando entradas
            let participantes = ()
            let candidato = banca.DETALHAMENTO-DA-PARTICIPACAO-EM-BANCA-DE-DOUTORADO.NOME-DO-CANDIDATO
            let titulo = banca.DADOS-BASICOS-DA-PARTICIPACAO-EM-BANCA-DE-DOUTORADO.TITULO
            let ano = banca.DADOS-BASICOS-DA-PARTICIPACAO-EM-BANCA-DE-DOUTORADO.ANO
            let programa = banca.DETALHAMENTO-DA-PARTICIPACAO-EM-BANCA-DE-DOUTORADO.NOME-CURSO
            let universidade = banca.DETALHAMENTO-DA-PARTICIPACAO-EM-BANCA-DE-DOUTORADO.NOME-INSTITUICAO

            // se somente tem uma entrada, type é dictionary
            // se tem mais de uma entrada, type é array
            // o texto vai ser formato no estilo de ABNT
            if type(banca.PARTICIPANTE-BANCA) == dictionary {
                if "NOME-PARA-CITACAO-DO-PARTICIPANTE-DA-BANCA" in pessoa.keys() {
                    let nome_partes = pessoa.at("NOME-PARA-CITACAO-DO-PARTICIPANTE-DA-BANCA").split(", ")
                    let nome = nome_partes.at(0).slice(0, 1) + lower(nome_partes.at(0).slice(1)) + ", " + nome_partes.at(1).slice(0, 1) + "."
                    participantes.push(nome)
                }
            } else if type(banca.PARTICIPANTE-BANCA) == array {
                let subset = banca.PARTICIPANTE-BANCA
                for participante in subset {
                    let nome_parts = participante.NOME-PARA-CITACAO-DO-PARTICIPANTE-DA-BANCA.split(", ")
                    let nome = upper(nome_parts.at(0)) + ", " + nome_parts.at(1).slice(0, 1) + "."
                    participantes.push(nome)
                }      
            }

            // criando string de todas pessoas na banca
            participantes = participantes.join("; ")

            if not eu == none {
                if type(participantes) != none and participantes != none {
                    let pesquisa = participantes.match(eu)
                    if pesquisa != none {
                        if pesquisa.start == 0 {
                            participantes = [*#participantes.slice(pesquisa.start, pesquisa.end)*#participantes.slice(pesquisa.end)]
                        } else if pesquisa.start != none {
                            participantes = [#participantes.slice(0, pesquisa.start)*#participantes.slice(pesquisa.start, pesquisa.end)*#participantes.slice(pesquisa.end)]
                        }
                    }
                }
            }

            // publicando content
            create-cols([*#i*], [#participantes Participação em banca de #candidato. #emph(titulo), #ano. (#programa), #universidade.], "enum")

            // diminuir o número (enumerar descendo)
            i -= 1
        }
    }

    if bancas_graduacao.len() > 0 or bancas_mestrado.len() > 0 or bancas_doutorado.len() > 0 {
        linebreak()

        line(length: 100%)
    }
}
