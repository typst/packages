#import "utils.typ": *

// Função create-supervisions(): Cria entradas para orientações/supervisões 
// Argumento:
//  - detalhes: o banco de dados com todas as informações (arquivo TOML)
#let create-supervisions(detalhes) = {
    // criando bancos de dados
    let orientacao = detalhes.OUTRA-PRODUCAO

    // criando variáveis
    let descricao_content = []

    // criando seção só se tiver entradas em orientações
    // TODO: Não tenho certeza sobre o key "ORIENTACOES-EM-ANDAMENTO
    if "ORIENTACOES-CONCLUIDAS" in orientacao.keys() {
        // criando cabeçalho
        [= Orientações e Supervisões <orientacao>]

        // Orientations em andamento
        // TODO: Não tenho certeza sobre o key, provavelmente dê erro
        if "ORIENTACOES-EM-ANDAMENTO" in orientacao.keys() {
            // criando banco de dados
            let andamento = orientacao.ORIENTACOES-EM-ANDAMENTO

            // criando cabeçalho
            [== Orientações e supervisões em andamento <orientacao_andamento>]

            // para doutorado
            // TODO: não tenho certeza sobre o key, provavelmente dê erro
            if "OUTRAS-ORIENTACOES-EM-ANDAMENTO-PARA-DOUTORADO" in andamento.keys() {

                // criando bancos de dados
                let doutorado = andamento.ORIENTACOES-EM-ANDAMENTO-PARA-DOUTORADO
                
                // ordenar por ano (descendo)
                let doutorado_ordem = doutorado.sorted(key: (item) => (item.DADOS-BASICOS-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.ANO))

                // criando Orientador
                // filtrar para funcção (aqui: orientador)
                let doutorado_filtro = doutorado_ordem.filter(
                    entry => entry.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.TIPO-DE-ORIENTACAO == "ORIENTADOR"
                )

                // criando conteúdo somente se tiver uma entrada
                if doutorado_filtro.len() > 0 {
                    // criando cabeçålho
                    [=== Tese de doutorado: orientador <orientacao_andamento_doutorado_orientador>]
                    
                    // criando número para ordenar
                    let i = doutorado_filtro.len()
                    for entrada in doutorado_filtro.rev() {
                        // criando varíaveis
                        let orientando = entrada.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.NOME-DO-ORIENTADO
                        let titulo = entrada.DADOS-BASICOS-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.TITULO
                        let ano = entrada.DADOS-BASICOS-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.ANO
                        let tipo = entrada.DADOS-BASICOS-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.NATUREZA
                        let programa = entrada.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.NOME-DO-CURSO
                        let universidade = entrada.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.NOME-DA-INSTITUICAO

                        // criando entrada final
                        descricao_content = [#orientando. #text(weight: "semibold", titulo). #ano. #tipo (#programa) - #universidade]

                        // publicando content
                        create-cols([*#i.*], [#descricao_content], "enum")

                        i -= 1
                    }
                }

                // criando co-orientador
                // filtrar para funcção (aqui: orientador)
                let doutorado_filtro = doutorado_ordem.filter(
                    entry => entry.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.TIPO-DE-ORIENTACAO == "CO_ORIENTADOR"
                )

                // criando conteúdo somente se tiver uma entrada
                if doutorado_filtro.len() > 0 {
                    // criando cabeçålho
                    [=== Tese de doutorado: co-orientador <orientacao_andamento_doutorado_coorientador>]
                    
                    // criando número para ordenar
                    let i = doutorado_filtro.len()
                    for entrada in doutorado_filtro.rev() {
                        // criando varíaveis
                        let orientando = entrada.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.NOME-DO-ORIENTADO
                        let titulo = entrada.DADOS-BASICOS-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.TITULO
                        let ano = entrada.DADOS-BASICOS-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.ANO
                        let tipo = entrada.DADOS-BASICOS-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.NATUREZA
                        let programa = entrada.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.NOME-DO-CURSO
                        let universidade = entrada.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.NOME-DA-INSTITUICAO

                        // criando entrada final
                        descricao_content = [#orientando. #text(weight: "semibold", titulo). #ano. #tipo (#programa) - #universidade]

                        // publicando content
                        create-cols([*#i.*], [#descricao_content], "enum")

                        i -= 1
                    }
                }
            }
            
            // para mestrado
            if "ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO" in andamento.keys() {
                // criando banco de dados
                let mestrado = andamento.ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO
                
                // ordenar as entradas
                let mestrado_ordem = mestrado.sorted(key: (item) => (item.DADOS-BASICOS-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.ANO))

                // criando orientador
                // filtrar para "orientador"
                let mestrado_filtro = mestrado_ordem.filter(
                    entry => entry.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.TIPO-DE-ORIENTACAO == "ORIENTADOR"
                )
                
                // criando conteúdo somente se tiver uma entrada
                if mestrado_filtro.len() > 0 {
                    // criando cabeçalho
                    [=== Dissertações de mestrado: orientador <orientacao_andamento_mestrado_orientador>] 

                    // criando número para enumerar
                    let i = mestrado_filtro.len()
                
                    for entrada in mestrado_filtro.rev() {
                        // criando variáveis
                        let orientando = entrada.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.NOME-DO-ORIENTADO
                        let titulo = entrada.DADOS-BASICOS-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.TITULO
                        let ano = entrada.DADOS-BASICOS-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.ANO
                        let tipo = entrada.DADOS-BASICOS-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.NATUREZA
                        let programa = entrada.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.NOME-DO-CURSO
                        let universidade = entrada.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.NOME-DA-INSTITUICAO

                        // publicando content
                        descricao_content = [#orientando. #text(weight: "semibold", titulo). #ano. #tipo (#programa) - #universidade]

                        // publicando content
                        create-cols([*#i.*], [#descricao_content], "enum")

                        i -= 1
                    }
                }

                // criando co-orientador
                // filtrar para "co-orientador"
                let mestrado_filtro = mestrado_ordem.filter(
                    entry => entry.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.TIPO-DE-ORIENTACAO == "CO_ORIENTADOR"
                )
                
                // criando conteúdo somente se tiver uma entrada
                if mestrado_filtro.len() > 0 {
                    // criando cabeçalho
                    [=== Dissertações de mestrado: co-orientador <orientacao_andamento_mestrado_coorientador>] 

                    // criando número para enumerar
                    let i = mestrado_filtro.len()
                
                    for entrada in mestrado_filtro.rev() {
                        // criando variáveis
                        let orientando = entrada.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.NOME-DO-ORIENTADO
                        let titulo = entrada.DADOS-BASICOS-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.TITULO
                        let ano = entrada.DADOS-BASICOS-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.ANO
                        let tipo = entrada.DADOS-BASICOS-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.NATUREZA
                        let programa = entrada.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.NOME-DO-CURSO
                        let universidade = entrada.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.NOME-DA-INSTITUICAO

                        // publicando content
                        descricao_content = [#orientando. #text(weight: "semibold", titulo). #ano. #tipo (#programa) - #universidade]

                        // publicando content
                        create-cols([*#i.*], [#descricao_content], "enum")

                        i -= 1
                    }
                }
            } 
            
            // para TCC (graduação, sem separação entre orientador ou co-orientador)
            // TODO: Não tenho certeza sobre o key
            if "OUTRAS-ORIENTACOES-EM-ANDAMENTO" in andamento.keys() {
                // criando banco de dados
                let outras = andamento.OUTRAS-ORIENTACOES-EM-ANDAMENTO

                // ordenar dados (descendo)
                let outras_ordem = outras.sorted(key: (item) => (item.DADOS-BASICOS-DE-OUTRAS-ORIENTACOES-EM-ANDAMENTO.ANO))

                // criando conteúdo se tiver ao mínimo uma entrada
                if outras_ordem.len() > 0 {
                    // criando cabeçalho
                    [=== Trabalhos de conclusão de curso de graduação <orientacao_andamento_graduacao>]

                    // criando número de entradas (para ordem)
                    let i = outras_ordem.len()
                    // criando conteúdo para cada entrada
                    for entrada in outras_ordem.rev() {
                        // criando variáveis
                        let orientando = entrada.DETALHAMENTO-DE-OUTRAS-ORIENTACOES-EM-ANDAMENTO.NOME-DO-ORIENTADO
                        let titulo = entrada.DADOS-BASICOS-DE-OUTRAS-ORIENTACOES-EM-ANDAMENTO.TITULO
                        let ano = entrada.DADOS-BASICOS-DE-OUTRAS-ORIENTACOES-EM-ANDAMENTO.ANO
                        let programa = entrada.DETALHAMENTO-DE-OUTRAS-ORIENTACOES-EM-ANDAMENTO.NOME-DO-CURSO
                        let universidade = entrada.DETALHAMENTO-DE-OUTRAS-ORIENTACOES-EM-ANDAMENTO.NOME-DA-INSTITUICAO

                        // A NATUREZA está em maiúsculas e com sublinhado
                        // Manipular NATUREZA
                        let tipo = entrada.DADOS-BASICOS-DE-OUTRAS-ORIENTACOES-EM-ANDAMENTO.NATUREZA
                        
                        // Defina uma função para capitalizar a primeira letra de um substring
                        // let capitalize = (text) => [#text.slice(0, 1)#lower(text.slice(1))]

                        // Divida a string em partes com base nos espaços
                        let tipo_parts = tipo.split("_")

                        // Capitalize cada parte e junte-as novamente com espaços
                        tipo = tipo_parts.map(capitalize).join(" ")
                        
                        // criando conteúdo junto
                        descricao_content = [#orientando. #text(weight: "semibold", titulo). #ano. #tipo (#programa) - #universidade]

                        // publicando content
                        create-cols([*#i.*], [#descricao_content], "enum")

                        i -= 1
                    }
                }
            }            
        }

        // Orientations concluidas
        if "ORIENTACOES-CONCLUIDAS" in orientacao.keys() {
            // criando cabeçalho
            [== Orientações e supervisões concluídas <orientacao_concluida>]
            
            // criando banco de dados
            let concluidos = orientacao.ORIENTACOES-CONCLUIDAS
            
            // TODO: não tenho certeza sobre o key
            // para doutorado
            if "OUTRAS-ORIENTACOES-CONCLUIDAS-PARA-DOUTORADO" in concluidos.keys() {
                // criando banco de dados para tipo
                let doutorado = concluidos.ORIENTACOES-CONCLUIDAS-PARA-DOUTORADO
                
                let doutorado_ordem = doutorado.sorted(key: (item) => (item.DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.ANO))

                // Caso doutorado: Orientador
                let doutorado_filtro = doutorado_ordem.filter(
                    entry => entry.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.TIPO-DE-ORIENTACAO == "ORIENTADOR"
                )
                
                if doutorado_filtro.len() > 0 {
                    // criando cabeçalho
                    [=== Tese de doutorado: orientador <orientacao_concluida_doutorado_orientador>]

                    let i = doutorado_filtro.len()
                    for entrada in doutorado_filtro.rev() {
                        let orientando = entrada.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.NOME-DO-ORIENTADO
                        let titulo = entrada.DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.TITULO
                        let ano = entrada.DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.ANO
                        let tipo = entrada.DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.NATUREZA
                        let programa = entrada.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.NOME-DO-CURSO
                        let universidade = entrada.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.NOME-DA-INSTITUICAO

                        // criando conteúdo
                        descricao_content = [#orientando. #text(weight: "semibold", titulo). #ano. #tipo (#programa) - #universidade]

                        // publicando content
                        create-cols([*#i.*], [#descricao_content], "enum")

                        // diminuir número para ordem
                        i -= 1
                    }
                }

                // Caso doutorado: Co-orientador
                let doutorado_filtro = doutorado_ordem.filter(
                    entry => entry.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.TIPO-DE-ORIENTACAO == "CO_ORIENTADOR"
                )
                
                if doutorado_filtro.len() > 0 {
                    // criando cabeçalho
                    [=== Tese de doutorado: co-orientador <orientacao_concluida_doutorado_coorientador>]

                    let i = doutorado_filtro.len()
                    for entrada in doutorado_filtro.rev() {
                        let orientando = entrada.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.NOME-DO-ORIENTADO
                        let titulo = entrada.DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.TITULO
                        let ano = entrada.DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.ANO
                        let tipo = entrada.DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.NATUREZA
                        let programa = entrada.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.NOME-DO-CURSO
                        let universidade = entrada.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.NOME-DA-INSTITUICAO

                        // criando conteúdo
                        descricao_content = [#orientando. #text(weight: "semibold", titulo). #ano. #tipo (#programa) - #universidade]

                        // publicando content
                        create-cols([*#i.*], [#descricao_content], "enum")

                        // diminuir número para ordem
                        i -= 1
                    }
                }
            }
            
            // para Mestrado
            if "ORIENTACOES-CONCLUIDAS-PARA-MESTRADO" in concluidos.keys() {
                // criando banco de dados
                let mestrado = concluidos.ORIENTACOES-CONCLUIDAS-PARA-MESTRADO
                
                let mestrado_ordem = mestrado.sorted(key: (item) => (item.DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.ANO))
                
                // Caso: Orientador
                let mestrado_filtro = mestrado_ordem.filter(
                    entry => entry.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.TIPO-DE-ORIENTACAO == "ORIENTADOR"
                )
                
                // criando conteúdo se tiver ao mínimo uma entrada
                if mestrado_filtro.len() > 0 {
                    // criando cabeçalho
                    [=== Dissertações de mestrado: orientador <orientacao_concluida_mestrado_orientador>] 

                    // criando número para ordem (descendo)
                    let i = mestrado_filtro.len()
                
                    for entrada in mestrado_filtro.rev() {
                        // criando variáveis
                        let orientando = entrada.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.NOME-DO-ORIENTADO
                        let titulo = entrada.DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.TITULO
                        let ano = entrada.DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.ANO
                        let tipo = entrada.DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.NATUREZA
                        let programa = entrada.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.NOME-DO-CURSO
                        let universidade = entrada.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.NOME-DA-INSTITUICAO

                        // criando content
                        descricao_content = [#orientando. #text(weight: "semibold", titulo). #ano. #tipo (#programa) - #universidade]

                        // publicando content
                        create-cols([*#i.*], [#descricao_content], "enum")

                        // diminuir número (para ordem)
                        i -= 1
                    }
                }

                // Caso: Co-orientador
                let mestrado_filtro = mestrado_ordem.filter(
                    entry => entry.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.TIPO-DE-ORIENTACAO == "CO_ORIENTADOR"
                )
                
                // criando conteúdo se tiver ao mínimo uma entrada
                if mestrado_filtro.len() > 0 {
                    // criando cabeçalho
                    [=== Dissertações de mestrado: co-orientador <orientacao_concluida_mestrado_coorientador>] 

                    // criando número para ordem (descendo)
                    let i = mestrado_filtro.len()
                
                    for entrada in mestrado_filtro.rev() {
                        // criando variáveis
                        let orientando = entrada.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.NOME-DO-ORIENTADO
                        let titulo = entrada.DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.TITULO
                        let ano = entrada.DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.ANO
                        let tipo = entrada.DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.NATUREZA
                        let programa = entrada.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.NOME-DO-CURSO
                        let universidade = entrada.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.NOME-DA-INSTITUICAO

                        // criando content
                        descricao_content = [#orientando. #text(weight: "semibold", titulo). #ano. #tipo (#programa) - #universidade]

                        // publicando content
                        create-cols([*#i.*], [#descricao_content], "enum")

                        // diminuir número (para ordem)
                        i -= 1
                    }
                }
            } 

            // para TCC / Graduação (sem separação de Co-orientador/orientador)
            // TODO: Não tenho certeza sobre o keys
            if "OUTRAS-ORIENTACOES-CONCLUIDAS" in concluidos.keys() {
                // criando banco de dados
                let outras = concluidos.OUTRAS-ORIENTACOES-CONCLUIDAS

                let outras_ordem = outras.sorted(key: (item) => (item.DADOS-BASICOS-DE-OUTRAS-ORIENTACOES-CONCLUIDAS.ANO))

                // ao mínimo precisa uma entrada
                if outras_ordem.len() > 0 {
                    // criando cabeçalho
                    [=== Trabalhos de conclusão de curso de graduação <orientacao_concluida_graduacao>]

                    // criando número para ordem (descendo)
                    let i = outras_ordem.len()

                    // criando conteúdo para cada entrada
                    for entrada in outras_ordem.rev() {
                        // criando variáveis
                        let orientando = entrada.DETALHAMENTO-DE-OUTRAS-ORIENTACOES-CONCLUIDAS.NOME-DO-ORIENTADO
                        let titulo = entrada.DADOS-BASICOS-DE-OUTRAS-ORIENTACOES-CONCLUIDAS.TITULO
                        let ano = entrada.DADOS-BASICOS-DE-OUTRAS-ORIENTACOES-CONCLUIDAS.ANO
                        let programa = entrada.DETALHAMENTO-DE-OUTRAS-ORIENTACOES-CONCLUIDAS.NOME-DO-CURSO
                        let universidade = entrada.DETALHAMENTO-DE-OUTRAS-ORIENTACOES-CONCLUIDAS.NOME-DA-INSTITUICAO

                        // A NATUREZA está em maiúsculas e com sublinhado
                        let tipo = entrada.DADOS-BASICOS-DE-OUTRAS-ORIENTACOES-CONCLUIDAS.NATUREZA
                        
                        // Defina uma função para capitalizar a primeira letra de um substring
                        // let capitalize = (text) => [#text.slice(0, 1)#lower(text.slice(1))]

                        // Divida a string em partes com base nos espaços
                        let tipo_parts = tipo.split("_")

                        // Capitalize cada parte e junte-as novamente com espaços
                        tipo = tipo_parts.map(capitalize).join(" ")
                        
                        // criando content
                        descricao_content = [#orientando. #text(weight: "semibold", titulo). #ano. #tipo (#programa) - #universidade]

                        // publicando content
                        create-cols([*#i.*], [#descricao_content], "enum")
                        
                        // diminuir número (para ordem)
                        i -= 1
                    }
                }
            }
        }
    
    linebreak()
    
    line(length: 100%)
    
    }
}