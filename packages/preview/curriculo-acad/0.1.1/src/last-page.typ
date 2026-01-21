#import "utils.typ": *

// Função create-lp-bibliography(): Calcular e criar números de sub-área
// Argumentos:
//  - detalhes: o banco de dados com todas as informações (arquivo TOML)
//  - tipo-lattes: tipo de currículo Lattes
#let create-lp-bibliography(detalhes, tipo-lattes) = {
    // Producao bibliografica
    // criando variáveis
    let num_artigos = 0
    let num_livros = 0
    let num_capitulos = 0
    let num_resumos = 0
    
    // verificar bancos de dados
    if "ARTIGOS-PUBLICADOS" in detalhes.PRODUCAO-BIBLIOGRAFICA.keys() {
        if "ARTIGO-PUBLICADO" in detalhes.PRODUCAO-BIBLIOGRAFICA.ARTIGOS-PUBLICADOS.keys() {
            let artigos = detalhes.PRODUCAO-BIBLIOGRAFICA.ARTIGOS-PUBLICADOS.ARTIGO-PUBLICADO

            // criando um array para enumerar se somente tem uma entrada
            if type(artigos) == dictionary {
                num_artigos = 1
            } else if type(artigos) == array {
                num_artigos = artigos.len()
            }
        }
    }
    
    if "LIVROS-E-CAPITULOS" in detalhes.PRODUCAO-BIBLIOGRAFICA.keys(){
        if "LIVROS-PUBLICADOS-OU-ORGANIZADOS" in detalhes.PRODUCAO-BIBLIOGRAFICA.LIVROS-E-CAPITULOS.keys() {
            let livros = detalhes.PRODUCAO-BIBLIOGRAFICA.LIVROS-E-CAPITULOS.LIVROS-PUBLICADOS-OU-ORGANIZADOS.LIVRO-PUBLICADO-OU-ORGANIZADO

            // criando um array para enumerar se somente tem uma entrada
            if type(livros) == dictionary {
                num_livros = 1
            } else if type(livros) == array {
                num_livros = livros.len()
            }
        }
    }

    if "CAPITULOS-DE-LIVROS-PUBLICADOS" in detalhes.PRODUCAO-BIBLIOGRAFICA.LIVROS-E-CAPITULOS.keys() {
        if "CAPITULO-DE-LIVRO-PUBLICADO" in detalhes.PRODUCAO-BIBLIOGRAFICA.LIVROS-E-CAPITULOS.CAPITULOS-DE-LIVROS-PUBLICADOS.keys() {
            let capitulos = detalhes.PRODUCAO-BIBLIOGRAFICA.LIVROS-E-CAPITULOS.CAPITULOS-DE-LIVROS-PUBLICADOS.CAPITULO-DE-LIVRO-PUBLICADO

            // criando um array para enumerar se somente tem uma entrada
            if type(capitulos) == dictionary {
                num_capitulos = 1
            } else if type(capitulos) == array {
                num_capitulos = capitulos.len()
            }
        }
    }

    // Resumos e resumo expandidos
    if "TRABALHOS-EM-EVENTOS" in detalhes.PRODUCAO-BIBLIOGRAFICA.keys() {
        if "TRABALHO-EM-EVENTOS" in detalhes.PRODUCAO-BIBLIOGRAFICA.TRABALHOS-EM-EVENTOS.keys() {
            let helper = detalhes.PRODUCAO-BIBLIOGRAFICA.TRABALHOS-EM-EVENTOS.TRABALHO-EM-EVENTOS
            let resumos = ()
            if type(helper) == array {
                for entrada in helper {            
                    if type(entrada) == array {
                        if entrada.DADOS-BASICOS-DO-TRABALHO.NATUREZA == "RESUMO" {
                            resumos.push(entrada)
                        } else if entrada.DADOS-BASICOS-DO-TRABALHO.NATUREZA == "RESUMO_EXPANDIDO" {
                            resumos.push(entrada)
                        } else if entrada.DADOS-BASICOS-DO-TRABALHO.NATUREZA == "COMPLETO" {
                            resumos.push(entrada)
                        }
                    }
                }
            } else if type(helper) == dictionary {
                if helper.DADOS-BASICOS-DO-TRABALHO.NATUREZA == "RESUMO" {
                    resumos.push(helper)
                } else if helper.DADOS-BASICOS-DO-TRABALHO.NATUREZA == "RESUMO_EXPANDIDO" {
                    resumos.push(helper)
                }  else if helper.DADOS-BASICOS-DO-TRABALHO.NATUREZA == "COMPLETO" {
                    resumos.push(helper)
                }
            }
            
            
            
            let resumos = detalhes.PRODUCAO-BIBLIOGRAFICA.TRABALHOS-EM-EVENTOS.TRABALHO-EM-EVENTOS

            if type(resumos) == dictionary {
                if resumos.DADOS-BASICOS-DO-TRABALHO == "RESUMO" or resumos.DADOS-BASICOS-DO-TRABALHO == "RESUMO_EXPANDIDO" {
                    num_resumos = 1
                }
            } else if type(resumos) == array {               
                num_resumos = resumos.len()
            }
        }
    }
    
    // Apresentações
    // criando sub-categórias para apresentações
    let num_apresentacoes = 0
    let num_conferencias = 0
    let num_congressos = 0
    let num_seminarios = 0
    let num_simposios = 0
    let num_outras = 0
    
    if "APRESENTACAO-DE-TRABALHO" in detalhes.PRODUCAO-TECNICA.DEMAIS-TIPOS-DE-PRODUCAO-TECNICA.keys() {
        let apresentacoes = detalhes.PRODUCAO-TECNICA.DEMAIS-TIPOS-DE-PRODUCAO-TECNICA.APRESENTACAO-DE-TRABALHO

        if type(apresentacoes) == dictionary {
            if apresentacoes.DADOS-BASICOS-DA-APRESENTACAO-DE-TRABALHO.NATUREZA == "CONFERENCIA" {
                num_conferencias = 1
            } else if apresentacoes.DADOS-BASICOS-DA-APRESENTACAO-DE-TRABALHO.NATUREZA == "CONGRESSO" {
                num_congressos = 1
            } else if apresentacoes.DADOS-BASICOS-DA-APRESENTACAO-DE-TRABALHO.NATUREZA == "SEMINARIO" {
                num_seminarios = 1
            } else if apresentacoes.DADOS-BASICOS-DA-APRESENTACAO-DE-TRABALHO.NATUREZA == "SIMPOSIO" {
                num_simposios = 1
            } else if apresentacoes.DADOS-BASICOS-DA-APRESENTACAO-DE-TRABALHO.NATUREZA == "OUTRAS" {
                num_outras = 1
            }
        } else if type(apresentacoes) == array {
            // sub-área conferencia
            let conferencias = apresentacoes.filter(
                entry => entry.DADOS-BASICOS-DA-APRESENTACAO-DE-TRABALHO.NATUREZA == "CONFERENCIA"
            )        
            num_conferencias = conferencias.len()

            let congressos = apresentacoes.filter(
                entry => entry.DADOS-BASICOS-DA-APRESENTACAO-DE-TRABALHO.NATUREZA == "CONGRESSO"
            )
            num_congressos = congressos.len()

            let seminarios = apresentacoes.filter(
                entry => entry.DADOS-BASICOS-DA-APRESENTACAO-DE-TRABALHO.NATUREZA == "SEMINARIO"
            )
            num_seminarios = seminarios.len()

            let simposios = apresentacoes.filter(
                entry => entry.DADOS-BASICOS-DA-APRESENTACAO-DE-TRABALHO.NATUREZA == "SIMPOSIO"
            )
            num_simposios = simposios.len()


            let outras = apresentacoes.filter(
                entry => entry.DADOS-BASICOS-DA-APRESENTACAO-DE-TRABALHO.NATUREZA == "OUTRA"
            )
            num_outras = outras.len()


        }
    }

    // Se pelo menos uma entrada em um desses, obtemos o cabeçalho
    if num_artigos > 0 or num_livros > 0 or num_capitulos > 0 or conferencias.len() > 0 or congressos.len() > 0  or seminarios.len() > 0 {
        [#link(<producao_bibliografica>)[== Produção bibliográfica]]
    }

    // criando a soma de artigos
    if num_artigos > 0 {
        create-cols([#link(<publicacao_artigos>)[Artigos completos] #box(width: 1fr, repeat[.])], [#num_artigos], "lastpage")
    }
    
    // criando a soma de livros
    if num_livros > 0 {
        create-cols([#link(<publicacao_livros>)[Livros publicados #box(width: 1fr, repeat[.])]], [#num_livros], "lastpage")
    }
    
    // criando a soma de capítulos
    if num_capitulos > 0 {
        create-cols([#link(<publicacao_capitulos>)[Capítulos de livros publicados #box(width: 1fr, repeat[.])]], [#num_capitulos], "lastpage")
    }
    

    // criando trabalho em anais
    if num_resumos > 0 {
        create-cols([#link(<producao-anais>)[Trabalhos publicados em anais de eventos #box(width: 1fr, repeat[.])]], [#num_resumos], "lastpage")
    }


    // criando a soma de apresentações: Conferências
    if tipo-lattes == "completo" {
        if num_conferencias > 0 {
            create-cols([#link(<producao_apresentacoes>)[Apresentações de trabalhos (Conferência ou palestra) #box(width: 1fr, repeat[.])]], [#num_conferencias], "lastpage")
        }  

        // criando a soma de apresentações: Congressos
        if num_congressos > 0 {
            create-cols([#link(<producao_apresentacoes>)[Apresentações de trabalhos (Congresso) #box(width: 1fr, repeat[.])]], [#num_congressos], "lastpage")
        }
        
        // criando a soma de apresentações: Seminários
        if num_seminarios > 0 {
            create-cols([#link(<producao_apresentacoes>)[Apresentações de trabalhos (Seminário) #box(width: 1fr, repeat[.])]], [#num_seminarios], "lastpage")
        }

        // criando a soma de apresentações: Simpósios
        if num_simposios > 0 {
            create-cols([#link(<producao_apresentacoes>)[Apresentações de trabalhos (Simpósio) #box(width: 1fr, repeat[.])]], [#num_simposios], "lastpage")
        }

        // criando a soma de apresentações: Seminários
        if num_outras > 0 {
            create-cols([#link(<producao_apresentacoes>)[Apresentações de trabalhos (Outras) #box(width: 1fr, repeat[.])]], [#num_outras], "lastpage")
        }
    }     
}

// Função create-lp-tecnicos(): Calcular e criar números de sub-área
// Argumentos:
//  - detalhes: o banco de dados com todas as informações (arquivo TOML)
//  - tipo-lattes: tipo de currículo Lattes
#let create-lp-tecnicos(detalhes, tipo-lattes) = {
    // Producao tecnica
    // criando bancos de dados
    let num_cursos_curtos = 0
    let num_didaticos = 0
    let num_relatorios = 0

    // criando didaticos
    if "DEMAIS-TIPOS-DE-PRODUCAO-TECNICA" in detalhes.PRODUCAO-TECNICA.keys() {
        //  criando cursos de curta duração ministrado
        if "CURSO-DE-CURTA-DURACAO-MINISTRADO" in detalhes.PRODUCAO-TECNICA.DEMAIS-TIPOS-DE-PRODUCAO-TECNICA.keys() {
            let cursos_curtos = detalhes.PRODUCAO-TECNICA.DEMAIS-TIPOS-DE-PRODUCAO-TECNICA.CURSO-DE-CURTA-DURACAO-MINISTRADO

            // criando um array para enumerar se somente tem uma entrada
            if type(cursos_curtos) == dictionary {
                num_cursos_curtos = 1
            } else if type(cursos_curtos) == array {
                num_cursos_curtos = cursos_curtos.len()
            }
        }

        if "DESENVOLVIMENTO-DE-MATERIAL-DIDATICO-OU-INSTRUCIONAL" in detalhes.PRODUCAO-TECNICA.DEMAIS-TIPOS-DE-PRODUCAO-TECNICA.keys() {

            // Cursos de curta duração ministrado
            let cursos_curtos = detalhes.PRODUCAO-TECNICA.DEMAIS-TIPOS-DE-PRODUCAO-TECNICA.CURSO-DE-CURTA-DURACAO-MINISTRADO

            // criando um array para enumerar se somente tem uma entrada
            if type(cursos_curtos) == dictionary {
                num_cursos_curtos = 1
            } else if type(cursos_curtos) == array {
                num_cursos_curtos = cursos_curtos.len()
            }

            // Desenvolvimento de material didático
            let didaticos = detalhes.PRODUCAO-TECNICA.DEMAIS-TIPOS-DE-PRODUCAO-TECNICA.DESENVOLVIMENTO-DE-MATERIAL-DIDATICO-OU-INSTRUCIONAL
            
            // criando um array para enumerar se somente tem uma entrada
            if type(didaticos) == dictionary {
                num_didaticos = 1
            } else if type(didaticos) == array {
                num_didaticos = didaticos.len()
            }
        
        }
    
        // criando relatórios de pesquisa
        if "RELATORIO-DE-PESQUISA" in detalhes.PRODUCAO-TECNICA.DEMAIS-TIPOS-DE-PRODUCAO-TECNICA.keys() {
            let relatorios = detalhes.PRODUCAO-TECNICA.DEMAIS-TIPOS-DE-PRODUCAO-TECNICA.RELATORIO-DE-PESQUISA

            // criando um array para enumerar se somente tem uma entrada
            if type(relatorios) == dictionary {
                num_relatorios = 1
            } else if type(relatorios) == array {
                num_relatorios = relatorios.len()
            }
        }

        // criando cabeçalho
        if num_cursos_curtos > 0 or num_didaticos > 0 or num_relatorios > 0 {
            [#link(<producao_tecnica>)[== Produção técnica]]

            // criando soma de cursos curtos
            if num_cursos_curtos > 0 {
                create-cols([#link(<producao_tecnica_demais>)[Curso de curta duração ministrado #box(width: 1fr, repeat[.])]], [#num_cursos_curtos], "lastpage")
            }
            
            // criando soma de materiais didáticos
            if num_didaticos > 0 {
                create-cols([#link(<producao_tecnica_demais>)[Desenvolvimento de material didático ou instrucional #box(width: 1fr, repeat[.])]], [#num_didaticos], "lastpage")
            }
            
            // criando soma de relatórios
            if num_relatorios > 0 {
                create-cols([#link(<producao_tecnica_demais>)[Relátorio de pesquisa #box(width: 1fr, repeat[.])]], [#num_relatorios], "lastpage")
            }
        }    
    }    
}

// Função create-lp-orientacoes(): Calcular e criar números de sub-área
// Argumentos:
//  - detalhes: o banco de dados com todas as informações (arquivo TOML)
//  - tipo-lattes: tipo de currículo Lattes
#let create-lp-orientacoes(detalhes, tipo-lattes) = {
    // Orientacoes
    // criando banca de dados
    let orientacoes = detalhes.OUTRA-PRODUCAO
    
    // criando cabeçalho
    if "ORIENTACOES-EM-ANDAMENTO" in orientacoes.keys() {
        [#link(<orientacao>)[== Orientações]]
    } else if "ORIENTACOES-CONCLUIDAS" in orientacoes.keys() {
        [#link(<orientacao>)[== Orientações]]
    }

    // criando bancos de dados para supervisões em andamento
    // TODO: não tenho certeza sobre a chave, não a encontrei no meu banco de dados
    // criando banco de dados total e entradas
    if "ORIENTACOES-EM-ANDAMENTO" in orientacoes.keys() {
        let andamentos = orientacoes.ORIENTACOES-EM-ANDAMENTO

        // para graduação
        let graduacao_andamento = 0
        
        // TODO: não tenho certeza sobre a chave, nos outros bancos sempre foi OUTRAS-ORIENTACOES para graduação
        // Defina o número de orientações para o comprimento do array
        if "OUTRAS-ORIENTACOES-EM-ANDAMENTO" in andamentos.keys() {
            graduacao_andamento = andamentos.OUTRAS-ORIENTACOES-EM-ANDAMENTO.len()
        }

        // para mestrado
        let mestrado_andamento_orientador = 0
        let mestrado_andamento_coorientador = 0
        
        // Defina o número de orientações para o comprimento do array dependede do tipo de orientação (orientador ou co-orientador)
        if "ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO" in andamentos.keys() {
            for orientacao in andamentos.ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO {
                if orientacao.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.TIPO-DE-ORIENTACAO == "ORIENTADOR" {
                    mestrado_andamento_orientador += 1
                } else if orientacao.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.TIPO-DE-ORIENTACAO == "CO_ORIENTADOR" {
                    mestrado_andamento_coorientador += 1 
                }
            }
        }

        // para doutorado
        // TODO: ainda não sei a chave correta, provavelmente precisarei corrigir quando tiver uma entrada
        let doutorado_andamento_orientador = 0
        let doutorado_andamento_coorientador = 0
        
        // Defina o número de orientações para o comprimento do array dependede do tipo de orientação (orientador ou co-orientador)
        if "ORIENTACOES-EM-ANDAMENTO-PARA-DOUTORADO" in andamentos.keys() {
            for orientacao in andamentos.ORIENTACOES-EM-ANDAMENTO-PARA-DOUTORADO {
                if orientacao.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-DOUTORADO.TIPO-DE-ORIENTACAO == "ORIENTADOR" {
                    doutorado_andamento_orientador += 1
                } else if orientacao.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-DOUTORADO.TIPO-DE-ORIENTACAO == "CO_ORIENTADOR" {
                    doutorado_andamento_coorientador += 1 
                }
            }
        }

        // TODO: ainda não sei a chave correta, provavelmente precisarei corrigir quando tiver uma entrada
        // criando campo se o comprimento for maior que 0 (orientador doutorado)
        if doutorado_andamento_orientador > 0 {
            create-cols([#link(<orientacao_andamento_doutorado_orientador>)[Orientação em andamento (tese de doutorado - orientador)] #box(width: 1fr, repeat[.])], [#doutorado_andamento_orientador], "lastpage")
        }

        // criando campo se o comprimento for maior que 0 (co-orientador doutorado)
        if doutorado_andamento_coorientador > 0 {
            create-cols([#link(<orientacao_andamento_doutorado_coorientador>)[Orientação em andamento (tese de doutorado - co-orientador) #box(width: 1fr, repeat[.])]], [#mestrado_andamento_coorientador], "lastpage")
        }

        // criando campo se o comprimento for maior que 0 (orientador mestrado)
        if mestrado_andamento_orientador > 0 {
            create-cols([#link(<orientacao_andamento_mestrado_orientador>)[Orientação em andamento (dissertação de mestrado - orientador) #box(width: 1fr, repeat[.])]], [#mestrado_andamento_orientador], "lastpage")
        }
        
        // criando campo se o comprimento for maior que 0 (co-orientador doutorado)
        if mestrado_andamento_coorientador > 0 {
            create-cols([#link(<orientacao_andamento_mestrado_coorientador>)[Orientação em andamento (dissertação de mestrado - co-orientador) #box(width: 1fr, repeat[.])]], [#mestrado_andamento_coorientador], "lastpage")
        }

        // criando campo se o comprimento for maior que 0 (graduacao)
        if graduacao_andamento > 0 { 
            create-cols([#link(<orientacao_andamento_graduacao>)[Orientação em andamento (trabalho de conclusão de curso de graduação) #box(width: 1fr, repeat[.])]], [#graduacao_andamento], "lastpage")
        }
    }

    // Orientações concluídas
    // criando banco de dados total e entradas
    if "ORIENTACOES-CONCLUIDAS" in orientacoes.keys() {
        let concluidas = orientacoes.ORIENTACOES-CONCLUIDAS

        // para graduação
        let graduacao_concluidas = 0
        
        if "OUTRAS-ORIENTACOES-CONCLUIDAS" in concluidas.keys() {
            graduacao_concluidas = concluidas.OUTRAS-ORIENTACOES-CONCLUIDAS.len()
        }

        // criando bancos de dados
        let mestrado_concluidas_orientador = 0
        let mestrado_concluidas_coorientador = 0
        
        // Defina o número de orientações para o comprimento do array dependede do tipo de orientação (orientador ou co-orientador)
        if "ORIENTACOES-CONCLUIDAS-PARA-MESTRADO" in concluidas.keys() {
            for orientacao in concluidas.ORIENTACOES-CONCLUIDAS-PARA-MESTRADO {
                if orientacao.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.TIPO-DE-ORIENTACAO == "ORIENTADOR" {
                    mestrado_concluidas_orientador += 1
                } else if orientacao.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.TIPO-DE-ORIENTACAO == "CO_ORIENTADOR" {
                    mestrado_concluidas_coorientador += 1 
                }
            }
        }

        // para doutorado
        // TODO: ainda não sei a chave correta, provavelmente precisarei corrigir quando tiver uma entrada
        let doutorado_concluidas_orientador = 0
        let doutorado_concluidas_coorientador = 0
        
        // Defina o número de orientações para o comprimento do array dependede do tipo de orientação (orientador ou co-orientador)
        if "ORIENTACOES-CONCLUIDAS-PARA-DOUTORADO" in concluidas.keys() {
            for orientacao in concluidas.ORIENTACOES-CONCLUIDAS-PARA-DOUTORADO {
                if orientacao.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-DOUTORADO.TIPO-DE-ORIENTACAO == "ORIENTADOR" {
                    doutorado_concluidas_orientador += 1
                } else if orientacao.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-DOUTORADO.TIPO-DE-ORIENTACAO == "CO_ORIENTADOR" {
                    doutorado_concluidas_coorientador += 1 
                }
            }
        }

        // TODO: não tenho certeza sobre a chave acima, provavelmente há um erro aqui e preciso corrigir a chave acima
        // criando campo se o comprimento for maior que 0 (orientador doutorado)
        if doutorado_concluidas_orientador > 0 {
            create-cols([#link(<orientacao_concluida_doutorado_orientador>)[Orientação concluída (tese de doutorado - orientador) #box(width: 1fr, repeat[.])]], [#doutorado_concluidas_orientador], "lastpage")
        }

        // criando campo se o comprimento for maior que 0 (co-orientador doutorado)
        if doutorado_concluidas_coorientador > 0 {
            create-cols([#link(<orientacao_concluida_doutorado_coorientador>)[Orientação concluída (tese de doutorado - co-orientador) #box(width: 1fr, repeat[.])]], [#mestrado_concluidas_coorientador], "lastpage")
        }

        // criando campo se o comprimento for maior que 0 (orientador mestrado)
        if mestrado_concluidas_orientador > 0 {
            create-cols([#link(<orientacao_concluida_mestrado_orientador>)[Orientação concluída (dissertação de mestrado - orientador) #box(width: 1fr, repeat[.])]], [#mestrado_concluidas_orientador], "lastpage")
        }

        // criando campo se o comprimento for maior que 0 (co-orientador mestrado)
        if mestrado_concluidas_coorientador > 0 {
            create-cols([#link(<orientacao_concluida_mestrado_coorientador>)[Orientação concluída (dissertação de mestrado - co-orientador) #box(width: 1fr, repeat[.])]], [#mestrado_concluidas_coorientador], "lastpage")
        }

        // criando campo se o comprimento for maior que 0 (graduação)
        if graduacao_concluidas > 0 { 
            create-cols([#link(<orientacao_concluida_graduacao>)[Orientação concluída (trabalho de conclusão de curso de graduação) #box(width: 1fr, repeat[.])]], [#graduacao_concluidas], "lastpage")
        }
    }
}

// Função create-lp-eventos(): Calcular e criar números de sub-área
// Argumentos:
//  - detalhes: o banco de dados com todas as informações (arquivo TOML)
//  - tipo-lattes: tipo de currículo Lattes
#let create-lp-events(detalhes, tipo-lattes) = {
    // Eventos
    // criando cabeçalho se um dos dois estiver pelo menos nos dados
    // se tem entradas, vai seguir para criar as entradas
    if tipo-lattes == "completo" {

        let marker1 = false
        if "PARTICIPACAO-EM-EVENTOS-CONGRESSOS" in detalhes.DADOS-COMPLEMENTARES.keys() {
            marker1 = true
        }

        let marker2 = false
        if "DEMAIS-TIPOS-DE-PRODUCAO-TECNICA" in detalhes.PRODUCAO-TECNICA.keys() {
            if "ORGANIZACAO-DE-EVENTO" in detalhes.PRODUCAO-TECNICA.DEMAIS-TIPOS-DE-PRODUCAO-TECNICA.keys() {
                marker2 = true
            }
        }

        let marker3 = false
        if "PARTICIPACAO-EM-BANCA-TRABALHOS-CONCLUSAO" in detalhes.DADOS-COMPLEMENTARES.keys() {
            marker3 = true
        }

        // checando para cabeçalho
        if marker1 == true or marker2 == true or marker3 == true {
            [#link(<eventos>)[== Eventos]]
        }


        if marker1 == true{            
            // criando banco de dados
            let eventos = detalhes.DADOS-COMPLEMENTARES.PARTICIPACAO-EM-EVENTOS-CONGRESSOS

            // criando variável para soma para cada tipo
            let num_congressos = 0
            let num_seminarios = 0
            let num_simposios = 0
            let num_encontros = 0
            let num_outras = 0

            // Loop através dos eventos
            // Os eventos são um array no qual cada evento é armazenado, portanto, podemos pegar o comprimento aqui
            for event in eventos.keys() {
                let subset = eventos.at(event)
                if type(subset) == array {
                    if event == "PARTICIPACAO-EM-CONGRESSO" { 
                        num_congressos = subset.len()
                    } else if event == "PARTICIPACAO-EM-SEMINARIO" {
                        num_seminarios = subset.len()
                    } else if event == "PARTICIPACAO-EM-SIMPOSIO" {
                        num_simposios = subset.len()
                    } else if event == "PARTICIPACAO-EM-ENCONTRO" {
                        num_encontros = subset.len()
                    } else if event == "OUTRAS-PARTICIPACOES-EM-EVENTOS-CONGRESSOS" { 
                        num_outras = subset.len()
                    }
                } else if type(subset) == dictionary {
                    if event.at(1).NATUREZA == "Congresso" { 
                        num_congressos = 1
                    } else if event.at(1).NATUREZA == "Seminário" { 
                        num_seminarios = 1
                    } else if event.at(1).NATUREZA == "Simpósio" {
                        num_simposios = 1
                    } else if event.at(1).NATUREZA == "Encontro" { 
                        num_encontros = 1
                    } else if event.at(1).NATUREZA == "Outra" {
                        num_outras = 1
                    }
                } 
            }

            // somente se estiver "completo"
            // criando campo se o comprimento for maior que 0 (congressos)
            if num_congressos > 0 { 
                create-cols([#link(<eventos_participacao>)[Participações em eventos (Congresso) #box(width: 1fr, repeat[.])]], [#num_congressos], "lastpage")
            }

            // criando campo se o comprimento for maior que 0 (seminarios)
            if num_seminarios > 0 { 
                create-cols([#link(<eventos_participacao>)[Participações em eventos (Seminários) #box(width: 1fr, repeat[.])]], [#num_seminarios], "lastpage")
            }

            // criando campo se o comprimento for maior que 0 (simposios)
            if num_simposios > 0 { 
                create-cols([#link(<eventos_participacao>)[Participações em eventos (Simpósios) #box(width: 1fr, repeat[.])]], [#num_simposios], "lastpage")
            }

            // criando campo se o comprimento for maior que 0 (encontros)
            if num_encontros > 0 { 
                create-cols([#link(<eventos_participacao>)[Participações em eventos (Encontros) #box(width: 1fr, repeat[.])]], [#num_encontros], "lastpage")
            }

            // criando campo se o comprimento for maior que 0 (outras)
            if num_outras > 0 { 
                create-cols([#link(<eventos_participacao>)[Participações em eventos (Outras) #box(width: 1fr, repeat[.])]], [#num_outras], "lastpage")
            }
        }

        // area de organização de eventos
        if marker2 == true {
            let organizacoes = detalhes.PRODUCAO-TECNICA.DEMAIS-TIPOS-DE-PRODUCAO-TECNICA.ORGANIZACAO-DE-EVENTO

            // criando variável para soma para cada tipo
            let num_congressos = 0
            let num_seminarios = 0
            let num_simposios = 0
            let num_encontros = 0
            let num_feiras = 0
            let num_outras = 0

            for event in organizacoes {
            if type(organizacoes) == array {
                if event.DADOS-BASICOS-DA-ORGANIZACAO-DE-EVENTO.TIPO == "CONGRESSO" {
                    num_congressos += 1
                } else if event.DADOS-BASICOS-DA-ORGANIZACAO-DE-EVENTO.TIPO == "SEMINARIO" {
                    num_seminarios += 1
                } else if event.DADOS-BASICOS-DA-ORGANIZACAO-DE-EVENTO.TIPO == "SIMPOSIO" {
                    num_simposios += 1
                } else if event.DADOS-BASICOS-DA-ORGANIZACAO-DE-EVENTO.TIPO == "ENCONTRO" {
                    num_encontros += 1 
                } else if event.DADOS-BASICOS-DA-ORGANIZACAO-DE-EVENTO.TIPO == "FEIRA" {
                    num_feiras += 1
                } else {
                    num_outras += 1
                }
            }
        }

            // somente se estiver "completo"
            // criando campo se o comprimento for maior que 0 (congressos)
            if num_congressos > 0 { 
                create-cols([#link(<organizacao_eventos>)[Organização de evento (Congresso) #box(width: 1fr, repeat[.])]], [#num_congressos], "lastpage")
            }

            // criando campo se o comprimento for maior que 0 (seminarios)
            if num_seminarios > 0 { 
                create-cols([#link(<organizacao_eventos>)[Organização de evento (Seminários) #box(width: 1fr, repeat[.])]], [#num_seminarios], "lastpage")
            }

            // criando campo se o comprimento for maior que 0 (simposios)
            if num_simposios > 0 { 
                create-cols([#link(<organizacao_eventos>)[Organização de evento (Simpósios) #box(width: 1fr, repeat[.])]], [#num_simposios], "lastpage")
            }

            // criando campo se o comprimento for maior que 0 (encontros)
            if num_encontros > 0 { 
                create-cols([#link(<organizacao_eventos>)[Organização de evento (Encontros) #box(width: 1fr, repeat[.])]], [#num_encontros], "lastpage")
            }

            // criando campo se o comprimento for maior que 0 (encontros)
            if num_feiras > 0 { 
                create-cols([#link(<organizacao_eventos>)[Organização de evento (Feiras) #box(width: 1fr, repeat[.])]], [#num_feiras], "lastpage")
            }

            // criando campo se o comprimento for maior que 0 (outras)
            if num_outras > 0 { 
                create-cols([#link(<organizacao_eventos>)[Organização de evento (Outras) #box(width: 1fr, repeat[.])]], [#num_outras], "lastpage")
            }
        }

        // trabalhos em bancas de conclusão
        // se tiver entradas em participação em bancas
        if marker3 == true {
            // criando bancos
            let bancas = detalhes.DADOS-COMPLEMENTARES.PARTICIPACAO-EM-BANCA-TRABALHOS-CONCLUSAO

            // para graduação
            let bancas_graduacao = 0 

            // criando soma de bancas de graduação
            if "PARTICIPACAO-EM-BANCA-DE-GRADUACAO" in bancas.keys() {
                if type(bancas.PARTICIPACAO-EM-BANCA-DE-GRADUACAO) == array {
                    bancas_graduacao = bancas.PARTICIPACAO-EM-BANCA-DE-GRADUACAO.len()
                } else if type(bancas.PARTICIPACAO-EM-BANCA-DE-GRADUACAO) == dictionary {
                    bancas_graduacao = 1
                }
                
            }

            // para mestrado
            let bancas_mestrado = 0 

            // criando soma de bancas de mestrado
            if "PARTICIPACAO-EM-BANCA-DE-MESTRADO" in bancas.keys() {
                if type(bancas.PARTICIPACAO-EM-BANCA-DE-MESTRADO) == array {
                    bancas_mestrado = bancas.PARTICIPACAO-EM-BANCA-DE-MESTRADO.len()
                } else if type(bancas.PARTICIPACAO-EM-BANCA-DE-MESTRADO) == dictionary {
                    bancas_mestrado = 1
                }
                
            }

            // para doutorado
            // TODO: não tenho certeza sobre a chave
            let bancas_doutorado = 0 
            // criando soma de bancas de doutorado
            if "PARTICIPACAO-EM-BANCA-DE-DOUTORADO" in bancas.keys() {
                if type(bancas.PARTICIPACAO-EM-BANCA-DE-DOUTORADO) {
                    bancas_doutorado = bancas.PARTICIPACAO-EM-BANCA-DE-DOUTORADO.len()
                } else if type(bancas.PARTICIPACAO-EM-BANCA-DE-DOUTORADO) == dictionary {
                    bancas_doutorado = 1
                }
            }

            // criando entradas
            // criando entrado para doutorado (se não estiver 0)

            if bancas_doutorado > 0 { 
                create-cols([#link(<bancas>)[Participação em banca de trabalhos de conclusão (doutorado) #box(width: 1fr, repeat[.])]], [#bancas_doutorado], "lastpage")
            }

            // criando entrado para mestrado (se não estiver 0)
            if bancas_mestrado > 0 { 
                create-cols([#link(<bancas>)[Participação em banca de trabalhos de conclusão (mestrado) #box(width: 1fr, repeat[.])]], [#bancas_mestrado], "lastpage")
            }

            // criando entrado para graduação (se não estiver 0)
            if bancas_graduacao > 0 { 
                create-cols([#link(<bancas>)[Participação em banca de trabalhos de conclusão (graduação) #box(width: 1fr, repeat[.])]], [#bancas_graduacao], "lastpage")
            }
        }
    }
}

// Função create-last-page(): Cria resumo de produções na última página
// Argumentos:
//  - detalhes: o banco de dados com todas as informações (arquivo TOML)
//  - tipo-lattes: tipo de currículo Lattes
#let create-last-page(detalhes, tipo-lattes) = {
  
    [= Totais de produção]
    
    create-lp-bibliography(detalhes, tipo-lattes)
    
    create-lp-tecnicos(detalhes, tipo-lattes)
    
    create-lp-orientacoes(detalhes, tipo-lattes)
    
    create-lp-events(detalhes, tipo-lattes)
}