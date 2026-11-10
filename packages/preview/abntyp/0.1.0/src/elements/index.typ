// Indice conforme NBR 6034:2004
//
// Definicoes:
// - Indice: Relacao de palavras/frases ordenadas que localiza e remete para
//   informacoes no texto
// - Cabecalho: Palavra(s) ou simbolo(s) que determina(m) a entrada
// - Entrada: Unidade do indice (cabecalho + indicativo de localizacao)
// - Subcabecalho: Palavra/simbolo que complementa o cabecalho
// - Remissiva: Indicacao que remete a outro cabecalho (ver ou ver tambem)
//
// Tipos de indice:
// - Quanto a ordenacao: alfabetica, sistematica, cronologica, numerica, alfanumerica
// - Quanto ao enfoque: especial (autores, assuntos, titulos, etc.) ou geral

/// Estado para armazenar entradas do indice
#let index-entries = state("abnt-index-entries", ())

/// Registra uma entrada no indice
/// Esta funcao deve ser chamada no local do texto onde o termo aparece
///
/// Parametros:
/// - termo: termo principal (cabecalho)
/// - subtermo: subtermo/subcabecalho (opcional)
/// - exibicao: texto a exibir no documento (se diferente do termo)
///
/// Exemplo:
/// ```typst
/// A #idx("algoritmo") e uma sequencia de instrucoes...
/// #idx("algoritmo", subtermo: "de ordenacao")[Quicksort] e eficiente...
/// ```
#let idx(termo, subtermo: none, exibicao: none) = {
  // Registrar entrada
  context {
    let current-page = counter(page).get().first()
    let entry = (
      term: termo,
      subterm: subtermo,
      page: current-page,
    )
    index-entries.update(entries => entries + (entry,))
  }

  // Exibir texto (se fornecido)
  if exibicao != none {
    exibicao
  }
}

/// Cria uma entrada de indice sem exibir texto
/// Use quando quiser indexar um termo que ja aparece no texto
#let index-entry(termo, subtermo: none) = {
  context {
    let current-page = counter(page).get().first()
    let entry = (
      term: termo,
      subterm: subtermo,
      page: current-page,
    )
    index-entries.update(entries => entries + (entry,))
  }
}

/// Remissiva "ver" - remete de um termo para outro
/// Exemplo: Aviacao ver Aeronautica
#let index-see(from, to) = {
  (type: "see", from: from, to: to)
}

/// Remissiva "ver tambem" - amplia opcoes de consulta
/// Exemplo: Ferias ver tambem Licenca
#let index-see-also(from, to) = {
  (type: "see-also", from: from, to: to)
}

/// Gera o indice alfabetico
///
/// Parametros:
/// - titulo: titulo do indice (padrao: "INDICE")
/// - rotulo-tipo: tipo do indice para o titulo (ex: "DE ASSUNTOS", "ONOMASTICO")
/// - entradas-ver: lista de remissivas "ver"
/// - entradas-ver-tambem: lista de remissivas "ver tambem"
/// - num-colunas: numero de colunas (padrao: 2)
/// - cabecalhos-letras: se true, mostra letras como cabecalhos de secao
///
/// Exemplo:
/// ```typst
/// #indice(
///   rotulo-tipo: "DE ASSUNTOS",
///   entradas-ver: (
///     index-see("Aviacao", "Aeronautica"),
///   ),
///   entradas-ver-tambem: (
///     index-see-also("Ferias", "Licenca"),
///   ),
/// )
/// ```
#let indice(
  titulo: "INDICE",
  rotulo-tipo: none,
  entradas-ver: (),
  entradas-ver-tambem: (),
  num-colunas: 2,
  cabecalhos-letras: true,
) = {
  // Titulo do indice
  let full-title = if rotulo-tipo != none {
    titulo + " " + rotulo-tipo
  } else {
    titulo
  }

  align(center)[
    #text(weight: "bold", size: 12pt, full-title)
  ]

  v(1.5em)

  context {
    let entries = index-entries.final()

    // Agrupar entradas por termo (convertendo content para string)
    let grouped = (:)
    for entry in entries {
      let term-key = if type(entry.term) == str { entry.term } else { repr(entry.term) }
      if term-key not in grouped {
        grouped.insert(term-key, (term: entry.term, pages: (), subterms: (:)))
      }

      if entry.subterm != none {
        let subterm-key = if type(entry.subterm) == str { entry.subterm } else { repr(entry.subterm) }
        if subterm-key not in grouped.at(term-key).subterms {
          grouped.at(term-key).subterms.insert(subterm-key, (subterm: entry.subterm, pages: ()))
        }
        grouped.at(term-key).subterms.at(subterm-key).pages.push(entry.page)
      } else {
        grouped.at(term-key).pages.push(entry.page)
      }
    }

    // Ordenar termos alfabeticamente
    let sorted-terms = grouped.keys().sorted()

    // Agrupar por letra inicial
    let by-letter = (:)
    for term in sorted-terms {
      let letter = upper(term.first())
      if letter not in by-letter {
        by-letter.insert(letter, ())
      }
      by-letter.at(letter).push(term)
    }

    // Processar remissivas "ver"
    let see-map = (:)
    for entry in entradas-ver {
      if type(entry) == dictionary and entry.type == "see" {
        see-map.insert(entry.from, entry.to)
      }
    }

    // Processar remissivas "ver tambem"
    let see-also-map = (:)
    for entry in entradas-ver-tambem {
      if type(entry) == dictionary and entry.type == "see-also" {
        if entry.from not in see-also-map {
          see-also-map.insert(entry.from, ())
        }
        see-also-map.at(entry.from).push(entry.to)
      }
    }

    // Funcao para formatar paginas
    let format-pages = pages => {
      // Remover duplicatas e ordenar
      let unique = pages.dedup().sorted()

      // Agrupar paginas consecutivas
      if unique.len() == 0 { return "" }

      let result = ()
      let start = unique.at(0)
      let end = start

      for i in range(1, unique.len()) {
        let page = unique.at(i)
        if page == end + 1 {
          end = page
        } else {
          if start == end {
            result.push(str(start))
          } else {
            result.push(str(start) + "-" + str(end))
          }
          start = page
          end = page
        }
      }

      // Adicionar ultimo grupo
      if start == end {
        result.push(str(start))
      } else {
        result.push(str(start) + "-" + str(end))
      }

      result.join(", ")
    }

    // Renderizar indice
    set par(first-line-indent: 0pt)

    columns(num-colunas, gutter: 1em)[
      #for letter in by-letter.keys().sorted() {
        // Cabecalho da letra
        if cabecalhos-letras {
          v(0.5em)
          text(weight: "bold", size: 11pt, letter)
          v(0.3em)
        }

        // Entradas desta letra
        for term-key in by-letter.at(letter) {
          let data = grouped.at(term-key)

          // Verificar se e remissiva "ver"
          if term-key in see-map {
            [#data.term #emph[ver] #see-map.at(term-key)]
            linebreak()
          } else {
            // Entrada normal
            [#data.term]

            // Paginas do termo principal
            if data.pages.len() > 0 {
              [, #format-pages(data.pages)]
            }

            linebreak()

            // Subtermos (com recuo)
            let sorted-subterms = data.subterms.keys().sorted()
            for subterm-key in sorted-subterms {
              let sub-data = data.subterms.at(subterm-key)
              h(1em)
              [#sub-data.subterm, #format-pages(sub-data.pages)]
              linebreak()
            }

            // Remissiva "ver tambem"
            if term-key in see-also-map {
              h(1em)
              [#emph[ver tambem] #see-also-map.at(term-key).join(", ")]
              linebreak()
            }
          }
        }
      }
    ]
  }

  pagebreak()
}

/// Indice de assuntos (wrapper para indice)
#let indice-assuntos(
  entradas-ver: (),
  entradas-ver-tambem: (),
  colunas: 2,
) = {
  indice(
    rotulo-tipo: "DE ASSUNTOS",
    entradas-ver: entradas-ver,
    entradas-ver-tambem: entradas-ver-tambem,
    num-colunas: colunas,
  )
}

/// Indice onomastico (de nomes/autores)
#let indice-onomastico(
  entradas-ver: (),
  entradas-ver-tambem: (),
  colunas: 2,
) = {
  indice(
    rotulo-tipo: "ONOMASTICO",
    entradas-ver: entradas-ver,
    entradas-ver-tambem: entradas-ver-tambem,
    num-colunas: colunas,
  )
}

/// Indice de autores
#let indice-autores(
  entradas-ver: (),
  colunas: 2,
) = {
  indice(
    rotulo-tipo: "DE AUTORES",
    entradas-ver: entradas-ver,
    num-colunas: colunas,
  )
}

/// Indice geral (combina categorias)
#let indice-geral(
  entradas-ver: (),
  entradas-ver-tambem: (),
  colunas: 2,
) = {
  indice(
    rotulo-tipo: none,
    entradas-ver: entradas-ver,
    entradas-ver-tambem: entradas-ver-tambem,
    num-colunas: colunas,
  )
}

/// Entrada de indice manual (para casos especiais)
/// Use quando precisar de controle total sobre a entrada
///
/// Parametros:
/// - termo: termo principal
/// - qualificador: qualificador entre parenteses (opcional)
/// - paginas: paginas (string ou lista)
/// - subentradas: lista de subentradas
///
/// Exemplo:
/// ```typst
/// #manual-index-entry(
///   termo: "Pedro II",
///   qualificador: "Imperador do Brasil",
///   paginas: "15-18, 45",
/// )
/// ```
#let manual-index-entry(
  termo: none,
  qualificador: none,
  paginas: none,
  subentradas: (),
) = {
  set par(first-line-indent: 0pt)

  // Termo principal
  termo

  // Qualificador
  if qualificador != none {
    [ (#qualificador)]
  }

  // Paginas
  if paginas != none {
    [, #paginas]
  }

  linebreak()

  // Subentradas
  for sub in subentradas {
    h(1em)
    if type(sub) == dictionary {
      sub.termo
      if "paginas" in sub and sub.paginas != none {
        [, #sub.paginas]
      }
    } else {
      sub
    }
    linebreak()
  }
}
