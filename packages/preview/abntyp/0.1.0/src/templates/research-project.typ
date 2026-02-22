// Template para Projeto de Pesquisa conforme NBR 15287:2025
//
// Estrutura:
// - Parte Externa: Capa (opcional), Lombada (opcional)
// - Pre-textual: Folha de rosto, Listas, Sumario
// - Textual: Introducao, Desenvolvimento, Metodologia, Cronograma
// - Pos-textual: Referencias, Glossario, Apendices, Anexos, Indice

#import "../core/page.typ": *
#import "../core/fonts.typ": *
#import "../core/spacing.typ": *
#import "../text/headings.typ": *
#import "../elements/cover.typ": *
#import "../elements/title-page.typ": *
#import "../elements/toc.typ": *
#import "../references/bibliography.typ": *

/// Template principal para Projeto de Pesquisa conforme NBR 15287:2025
///
/// Parametros:
/// - titulo: titulo do projeto
/// - subtitulo: subtitulo (opcional)
/// - autor: nome do(s) autor(es) - pode ser string ou array
/// - instituicao: nome da entidade
/// - local: cidade da entidade
/// - ano: ano de entrega
/// - tipo-projeto: tipo de projeto (ex: "Projeto de pesquisa apresentado...")
/// - orientador: nome do orientador (opcional)
/// - coorientador: nome do coorientador (opcional)
/// - coordenador: nome do coordenador (opcional)
/// - volume: numero do volume (se houver mais de um)
/// - fonte: fonte a usar ("Times New Roman" ou "Arial")
/// - arquivo-bibliografia: caminho para arquivo .bib (opcional)
/// - titulo-bibliografia: titulo da secao de referencias
#let projeto-pesquisa(
  titulo: "",
  subtitulo: none,
  autor: "",
  instituicao: "",
  local: "",
  ano: datetime.today().year(),
  tipo-projeto: none,
  orientador: none,
  coorientador: none,
  coordenador: none,
  volume: none,
  fonte: "Times New Roman",
  arquivo-bibliografia: none,
  titulo-bibliografia: "REFERENCIAS",
  body,
) = {
  // Configuracao do documento
  set document(
    title: titulo,
    author: if type(autor) == array { autor.join(", ") } else { autor },
  )

  // Configuracao de pagina conforme NBR 15287
  // Anverso: superior/esquerda 3cm, inferior/direita 2cm
  set page(
    paper: "a4",
    margin: (
      top: 3cm,
      bottom: 2cm,
      left: 3cm,
      right: 2cm,
    ),
  )

  // Configuracao de fonte
  set text(
    font: fonte,
    size: 12pt,
    lang: "pt",
    region: "BR",
  )

  // Configuracao de paragrafo - espacamento 1,5
  set par(
    leading: 1.5em * 0.65,
    justify: true,
    first-line-indent: (amount: 1.25cm, all: true),
  )

  set list(indent: 2em, body-indent: 0.5em)
  set enum(indent: 2em, body-indent: 0.5em)
  set terms(indent: 0em, hanging-indent: 2em, separator: [: ])

  // Configuracao de headings
  set heading(numbering: "1.1")

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(1.5em)
    text(weight: "bold", size: 12pt)[
      #if it.numbering != none {
        counter(heading).display()
        h(0.5em)
      }
      #upper(it.body)
    ]
    v(1.5em)
  }

  show heading.where(level: 2): it => {
    v(1.5em)
    text(weight: "regular", size: 12pt)[
      #if it.numbering != none {
        counter(heading).display()
        h(0.5em)
      }
      #upper(it.body)
    ]
    v(1.5em)
  }

  show heading.where(level: 3): it => {
    v(1.5em)
    text(weight: "bold", size: 12pt)[
      #if it.numbering != none {
        counter(heading).display()
        h(0.5em)
      }
      #it.body
    ]
    v(1.5em)
  }

  show heading.where(level: 4): it => {
    v(1.5em)
    text(weight: "regular", size: 12pt)[
      #if it.numbering != none {
        counter(heading).display()
        h(0.5em)
      }
      #it.body
    ]
    v(1.5em)
  }

  show heading.where(level: 5): it => {
    v(1.5em)
    text(weight: "regular", style: "italic", size: 12pt)[
      #if it.numbering != none {
        counter(heading).display()
        h(0.5em)
      }
      #it.body
    ]
    v(1.5em)
  }

  // Excluir indentacao de containers que nao devem ser indentados
  show heading: set par(first-line-indent: 0pt)
  show figure: set par(first-line-indent: 0pt)
  show raw.where(block: true): set par(first-line-indent: 0pt)
  show outline: set par(first-line-indent: 0pt)
  show terms: set par(first-line-indent: 0pt)

  // Configuracao de notas de rodape
  // Filete de 5cm a partir da margem esquerda
  set footnote.entry(
    separator: line(length: 5cm, stroke: 0.5pt),
  )

  // Conteudo
  body

  // Bibliografia automatica (se arquivo .bib fornecido)
  if arquivo-bibliografia != none {
    abnt-bibliography(arquivo-bibliografia, titulo: titulo-bibliografia)
  }
}

/// Capa para Projeto de Pesquisa conforme NBR 15287:2025
/// Elementos na ordem:
/// 1. Nome da entidade (quando solicitado)
/// 2. Nome(s) do(s) autor(es)
/// 3. Titulo
/// 4. Subtitulo (se houver) - precedido de dois pontos
/// 5. Numero do volume (se houver mais de um)
/// 6. Local (cidade) da entidade
/// 7. Ano de entrega
#let project-cover(
  instituicao: none,
  autor: none,
  titulo: none,
  subtitulo: none,
  volume: none,
  local: none,
  ano: none,
) = {
  set page(numbering: none)
  set align(center)

  // Instituicao (maiusculas, negrito)
  if instituicao != none {
    text(weight: "bold", size: 12pt, upper(instituicao))
  }

  v(1fr)

  // Autor(es)
  if autor != none {
    if type(autor) == array {
      for a in autor {
        text(size: 12pt, upper(a))
        linebreak()
      }
    } else {
      text(size: 12pt, upper(autor))
    }
  }

  v(1fr)

  // Titulo (maiusculas, negrito)
  if titulo != none {
    text(weight: "bold", size: 14pt, upper(titulo))
  }

  // Subtitulo (precedido de dois-pontos)
  if subtitulo != none {
    text(size: 14pt, ": " + subtitulo)
  }

  // Volume
  if volume != none {
    v(0.5em)
    text(size: 12pt, "Volume " + str(volume))
  }

  v(1fr)

  // Local e ano
  if local != none {
    text(size: 12pt, upper(local))
    linebreak()
  }

  if ano != none {
    text(size: 12pt, str(ano))
  }

  pagebreak()
}

/// Folha de rosto para Projeto de Pesquisa conforme NBR 15287:2025
/// Elementos na ordem:
/// 1. Nome(s) do(s) autor(es)
/// 2. Titulo
/// 3. Subtitulo (se houver)
/// 4. Numero do volume (se houver)
/// 5. Tipo de projeto + nome da entidade
/// 6. Nome do orientador/coorientador/coordenador (se houver)
/// 7. Local (cidade)
/// 8. Ano da entrega
#let project-title-page(
  autor: none,
  titulo: none,
  subtitulo: none,
  volume: none,
  tipo-projeto: none,
  instituicao: none,
  orientador: none,
  coorientador: none,
  coordenador: none,
  local: none,
  ano: none,
) = {
  set page(numbering: none)
  set align(center)

  // Autor(es)
  if autor != none {
    if type(autor) == array {
      for a in autor {
        text(size: 12pt, upper(a))
        linebreak()
      }
    } else {
      text(size: 12pt, upper(autor))
    }
  }

  v(1fr)

  // Titulo (maiusculas, negrito)
  if titulo != none {
    text(weight: "bold", size: 14pt, upper(titulo))
  }

  // Subtitulo
  if subtitulo != none {
    text(size: 14pt, ": " + subtitulo)
  }

  // Volume
  if volume != none {
    v(0.5em)
    text(size: 12pt, "Volume " + str(volume))
  }

  v(2cm)

  // Tipo de projeto e orientadores (recuo de 8cm, espaco simples)
  if tipo-projeto != none or orientador != none or coordenador != none {
    set align(right)
    box(width: 8cm)[
      #set align(left)
      #set par(
        leading: 1em * 0.65,
        first-line-indent: 0pt,
        justify: true,
      )
      #set text(size: 10pt)

      #if tipo-projeto != none { tipo-projeto }
      #if instituicao != none { linebreak(); instituicao }

      #if orientador != none {
        linebreak()
        linebreak()
        [Orientador: #orientador]
      }

      #if coorientador != none {
        linebreak()
        [Coorientador: #coorientador]
      }

      #if coordenador != none {
        linebreak()
        [Coordenador: #coordenador]
      }
    ]
  }

  v(1fr)

  // Local e ano
  set align(center)
  if local != none {
    text(size: 12pt, upper(local))
    linebreak()
  }

  if ano != none {
    text(size: 12pt, str(ano))
  }

  pagebreak()
}

/// Cronograma simples do projeto (tabela atividades × períodos)
/// Para um cronograma mais elaborado (Gantt com barras, cores e dependências),
/// use a função `cronograma()` do pacote FerrMat.
///
/// Parametros:
/// - titulo: titulo da secao (padrao: "CRONOGRAMA")
/// - atividades: lista de atividades (strings)
/// - periodos: lista de periodos (ex: ("Jan", "Fev", "Mar", ...))
/// - marcacoes: matriz de booleanos indicando quando cada atividade ocorre
///             marcacoes.at(i).at(j) = true se atividade i ocorre no periodo j
#let cronograma-simples(
  titulo: "CRONOGRAMA",
  atividades: (),
  periodos: (),
  marcacoes: (),
) = {
  heading(level: 1, titulo)

  let num-periods = periodos.len()
  let num-activities = atividades.len()

  // Criar colunas: primeira para atividades, demais para periodos
  let cols = (auto,) + (1fr,) * num-periods

  table(
    columns: cols,
    stroke: 0.5pt,
    inset: 6pt,
    align: (left,) + (center,) * num-periods,

    // Cabecalho
    [*Atividades*],
    ..periodos.map(p => [*#p*]),

    // Linhas de atividades
    ..{
      let cells = ()
      for (i, activity) in atividades.enumerate() {
        cells.push(activity)
        for j in range(num-periods) {
          if marcacoes.len() > i and marcacoes.at(i).len() > j and marcacoes.at(i).at(j) {
            cells.push([X])
          } else {
            cells.push([])
          }
        }
      }
      cells
    }
  )
}

/// Recursos do projeto
/// Cria uma secao listando os recursos necessarios
///
/// Parametros:
/// - titulo: titulo da secao (padrao: "RECURSOS")
/// - itens: lista de tuplas (descricao, valor) ou apenas descricoes
/// - total: valor total (opcional, calculado automaticamente se valores forem numeros)
#let recursos(
  titulo: "RECURSOS",
  itens: (),
  total: none,
) = {
  heading(level: 1, titulo)

  if itens.len() > 0 {
    // Verificar se itens tem valores
    let has-values = if type(itens.at(0)) == array { itens.at(0).len() > 1 } else { false }

    if has-values {
      // Tabela com descricao e valores
      table(
        columns: (1fr, auto),
        stroke: none,
        inset: 6pt,
        align: (left, right),

        table.hline(stroke: 1pt),
        [*Descricao*], [*Valor (R\$)*],
        table.hline(stroke: 0.5pt),

        ..{
          let cells = ()
          for item in itens {
            cells.push(item.at(0))
            cells.push(str(item.at(1)))
          }
          cells
        },

        table.hline(stroke: 0.5pt),

        // Total
        if total != none {
          ([*Total*], [*#str(total)*])
        } else {
          // Calcular total se possivel
          let sum = itens.fold(0, (acc, item) => {
            if type(item.at(1)) == int or type(item.at(1)) == float {
              acc + item.at(1)
            } else {
              acc
            }
          })
          ([*Total*], [*#str(sum)*])
        },

        table.hline(stroke: 1pt),
      )
    } else {
      // Lista simples
      for item in itens {
        [- #item]
        linebreak()
      }
    }
  }
}

/// Glossario para projeto de pesquisa
/// Conforme NBR 15287 - ordem alfabetica
#let glossario-projeto(itens) = {
  heading(level: 1, numbering: none, "GLOSSARIO")

  set par(first-line-indent: 0pt)

  // Ordenar itens alfabeticamente
  let sorted-items = itens.pairs().sorted(key: p => p.at(0))

  for (termo, definicao) in sorted-items {
    [*#termo:* #definicao]
    linebreak()
    v(0.5em)
  }

  pagebreak()
}

/// Apendice para projeto de pesquisa
/// Formato: APENDICE A - TITULO EM MAIUSCULAS
#let apendice(letra, titulo) = {
  pagebreak()
  align(center)[
    #text(weight: "bold", size: 12pt)[APENDICE #letra -- #upper(titulo)]
  ]
  v(1.5em)
}

/// Anexo para projeto de pesquisa
/// Formato: ANEXO A - TITULO EM MAIUSCULAS
#let anexo(letra, titulo) = {
  pagebreak()
  align(center)[
    #text(weight: "bold", size: 12pt)[ANEXO #letra -- #upper(titulo)]
  ]
  v(1.5em)
}
