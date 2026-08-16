#import "utils.typ": *

// Função safe-int(): Cria um número para formações em andamento
// Argumentos:
// - x: input de ano
#let safe-int(x) = if x == "" { 9999 } else { int(x) }

// Função create-education(): Cria área de formação complementar
// Argumentos:
// - detalhes: o banco de dados de Lattes (TOML)
// - tipo-lattes: tipo de currículo Lattes
#let create-education(detalhes, tipo-lattes) = {
  let formacao = detalhes.DADOS-GERAIS.FORMACAO-ACADEMICA-TITULACAO

  let formacao_list = ()

  for (key, value) in formacao.pairs() {
    if type(value) == array {
      for v in value {
        formacao_list.push((key, v))
      }
    } else {
      formacao_list.push((key, value))
    }
  }

  formacao_list = formacao_list.sorted(
    key: item => (
      safe-int(item.at(1).ANO-DE-INICIO),
      safe-int(item.at(1).ANO-DE-CONCLUSAO),
    ),
  )

  // Separating pós-doutorado from Formação academica/titulação
  let formacao_main = ()
  let posdoc_list = ()

  for item in formacao_list {
    let key = item.at(0)

    if key == "POS-DOUTORADO" {
      posdoc_list.push(item)
    } else {
      formacao_main.push(item)
    }
  }

  let formacao_main = ()
  let posdoc_list = ()

  for item in formacao_list {
    let key = item.at(0)

    if key == "POS-DOUTORADO" {
      posdoc_list.push(item)
    } else {
      formacao_main.push(item)
    }
  }

  // criando ordem na formacao
  // formacao = formacao.pairs().sorted(
  //     // key: (item) => (item.at(1).at("ANO-DE-INICIO"), item.at(1).at("ANO-DE-CONCLUSAO"))
  //     key: (item) => (item.at(1).ANO-DE-INICIO, item.at(1).ANO-DE-CONCLUSAO))

  if formacao_main.len() > 0 {
    [= Formação academica/titulação <formacao>]

    // loop pelas keys em dictionary e imprimir todas vagas
    for entrada in formacao_main.rev() {
      let key = entrada.at(0)
      let subset = entrada.at(1)

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

      if subset.ANO-DE-INICIO == subset.ANO-DE-CONCLUSAO {
        tempo_content = [#subset.ANO-DE-INICIO]
      } else if subset.ANO-DE-CONCLUSAO == "" {
        tempo_content = [desde #subset.ANO-DE-INICIO]
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
          if subset.NOME-DO-CO-ORIENTADOR != "" {
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
      } else if orientador != str and coorientador == str {
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
          palavras_content = [#text(rgb("B2B2B2"), size: 0.85em, "Palavras-chave: " + palavras_chave) #linebreak()]
        }

        // criando content para áreas de conhecimento
        let areas_content = []
        if conhecimento.len() > 0 {
          areas_content = [#text(rgb("B2B2B2"), size: 0.85em, "Áreas de conhecimento: " + conhecimento) #linebreak()]
        }

        descricao_content = [#descricao_content #palavras_content #areas_content]
      } else {
        descricao_content = [#descricao_content]
      }

      // publicando content
      create-cols([*#tempo_content*], [#descricao_content], "small")
    }

    linebreak()

    line(length: 100%)
  }
  if posdoc_list.len() > 0 {
    [= Pós-doutorado <posdoc>]

    // loop pelas keys em dictionary e imprimir todas vagas
    for entrada in posdoc_list.rev() {
      let key = entrada.at(0)
      let subset = entrada.at(1)

      // initialize variables
      let titulo = str
      let bolsa = content
      let agencia = str
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

      if subset.ANO-DE-INICIO == subset.ANO-DE-CONCLUSAO {
        tempo_content = [#subset.ANO-DE-INICIO]
      } else if subset.ANO-DE-CONCLUSAO == "" {
        tempo_content = [desde #subset.ANO-DE-INICIO]
      } else {
        tempo_content = [#subset.ANO-DE-INICIO - #subset.ANO-DE-CONCLUSAO]
      }

      // criando título
      if "TITULO-DO-TRABALHO" in subset.keys() {
        titulo = subset.TITULO-DO-TRABALHO
      }

      // criando orientadres
      // Caso de ensino medio sem orientadores
      if "FLAG-BOLSA" in subset.keys() {
        if subset.FLAG-BOLSA == "SIM" {
          if "NOME-AGENCIA" in subset.keys {
            agencia = subset.NOME-AGENCIA
            bolsa = [Bolsa recebida por #agencia]
          } else {
            agencia = ""
            bolsa = [Bolsa recebida]
          }
        } else {
          bolsa = []
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
      let estudo = [#titulo, #emph(subset.NOME-INSTITUICAO)]

      // caso tem todas informações
      if bolsa == [] {
        descricao_content = [
          #estudo#linebreak()
        ]
      } else if bolsa != [] {
        descricao_content = [
          #estudo#linebreak()
          #bolsa#linebreak()
        ]
      }

      // criando conteúdo depende do tipo de lattes
      if tipo-lattes == "completo" {
        // criando content para palavras-chave
        let palavras_content = []
        if palavras_chave.len() > 0 {
          palavras_content = [#text(rgb("B2B2B2"), size: 0.85em, "Palavras-chave: " + palavras_chave) #linebreak()]
        }

        // criando content para áreas de conhecimento
        let areas_content = []
        if conhecimento.len() > 0 {
          areas_content = [#text(rgb("B2B2B2"), size: 0.85em, "Áreas de conhecimento: " + conhecimento) #linebreak()]
        }

        descricao_content = [#descricao_content #palavras_content #areas_content]
      } else {
        descricao_content = [#descricao_content]
      }

      // publicando content
      create-cols([*#tempo_content*], [#descricao_content], "small")
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
    if "FORMACAO-COMPLEMENTAR" in detalhes.DADOS-COMPLEMENTARES {
      // criando banco de dados
      let complementar = detalhes.DADOS-COMPLEMENTARES.FORMACAO-COMPLEMENTAR

      let lista = ()

      if complementar.len() > 0 {
        [= Formação complementar <formacao_complementar>]

        // normalize structure
        for (key, value) in complementar.pairs() {
          if type(value) == array {
            for v in value {
              lista.push(v)
            }
          } else {
            lista.push(value)
          }
        }

        // now sorting works
        lista = lista.sorted(
          key: item => (
            safe-int(item.ANO-DE-INICIO),
            safe-int(item.ANO-DE-CONCLUSAO),
          ),
        )

        // loop
        for entrada in lista.rev() {
          // for key in complementar.keys() {
          //     let subset = complementar.at(key)

          //     subset = subset.sorted(key: (item) => (item.ANO-DE-INICIO, item.ANO-DE-CONCLUSAO))

          // for entrada in subset.rev() {
          let tempo_content = []
          if entrada.ANO-DE-INICIO == entrada.ANO-DE-CONCLUSAO {
            tempo_content = [#entrada.ANO-DE-INICIO]
          } else if entrada.ANO-DE-CONCLUSAO == "" {
            tempo_content = [desde #entrada.ANO-DE-INICIO]
          } else {
            tempo_content = [#entrada.ANO-DE-INICIO - #entrada.ANO-DE-CONCLUSAO]
          }

          let descricao_content = [
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

