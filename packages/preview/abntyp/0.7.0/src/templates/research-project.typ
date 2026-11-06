// Template para Projeto de Pesquisa conforme NBR 15287:2025
//
// Estrutura:
// - Parte Externa: Capa (opcional), Lombada (opcional)
// - Pre-textual: Folha de rosto, Listas, Sumario
// - Textual: Introducao, Desenvolvimento, Metodologia, Cronograma
// - Pos-textual: Referencias, Glossario, Apendices, Anexos, Indice

#import "../core/setup.typ": with-abnt-setup
#import "../core/page.typ": *
#import "../core/fonts.typ": *
#import "../core/spacing.typ": *
#import "../core/sorting.typ": sort-key
#import "../text/headings.typ": *
#import "../elements/cover.typ": *
#import "../elements/title-page.typ": *
#import "../elements/toc.typ": *
#import "../references/bibliography.typ": *

// Dados do projeto, gravados por `projeto-pesquisa()`: a capa e a folha de rosto os
// usam quando o parametro nao e informado (como `dados()` + `capa()` no TCC)
#let _proj-meta = state("abnt-projeto", (:))

// Valor explicito ou, na falta, o do projeto (deve ser chamado dentro de `context`)
#let _proj-resolve(explicito, chave) = if explicito != none {
  explicito
} else {
  let valor = _proj-meta.get().at(chave, default: none)
  if valor == "" { none } else { valor }
}

// Titulo e subtitulo da capa e da folha de rosto: 12 pt (14724 5.1), sem justificar
// nem hifenizar; subtitulo na mesma linha, depois de dois-pontos colados ao titulo
#let _proj-titulo(titulo, subtitulo) = {
  set par(justify: false)
  set text(hyphenate: false)
  if titulo != none {
    text(weight: "bold", size: 12pt, upper(titulo) + if subtitulo != none { ":" } else { "" })
  }
  if subtitulo != none {
    text(size: 12pt, [ #subtitulo])
  }
}

/// Template principal para Projeto de Pesquisa conforme NBR 15287:2025
///
/// Os dados do projeto (titulo, subtitulo, autor, instituicao, local, ano,
/// tipo-projeto, orientador, coorientador, coordenador, volume) valem como padrao de
/// `project-cover()` e `project-title-page()`: informe-os so aqui. A numeracao de
/// pagina (arabica, canto superior direito, 2 cm da borda) comeca na primeira secao
/// primaria numerada; a contagem comeca na folha de rosto (NBR 15287 5.3).
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
/// - frente-verso: impressao frente-verso (padrao: false). Se true: margens espelhadas
///   (interna 3 cm, externa 2 cm), numero no canto superior direito das paginas
///   impares e esquerdo das pares, e folha de rosto, sumario, listas e secoes
///   primarias iniciando em pagina impar (NBR 15287 5.1 e 5.2.2)
/// - fonte: fonte a usar ("Times New Roman" ou "Arial")
/// - arquivo-bibliografia: conteudo do arquivo .bib, lido com `read("referencias.bib")` (opcional)
/// - titulo-bibliografia: titulo da secao de referencias
/// - enumeracao: "abnt" (padrão: alíneas a), b), c); subalíneas com travessão) ou
///   "latex" (1., a), i), A.)
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
  frente-verso: false,
  fonte: "Times New Roman",
  arquivo-bibliografia: none,
  titulo-bibliografia: "REFERÊNCIAS",
  enumeracao: "abnt",
  body,
) = {
  // Configuracao do documento
  set document(
    title: titulo,
    author: if type(autor) == array { autor.join(", ") } else { autor },
  )

  show: with-abnt-setup.with(
    fonte: fonte,
    level-1-pagebreak-impar: frente-verso,
    enumeracao: enumeracao,
  )

  // Frente-verso: margens espelhadas (interna 3 cm, externa 2 cm)
  set page(margin: abnt-margens(frente-verso))

  // Numero de pagina a partir da primeira secao primaria numerada (15287 5.3)
  set page(header: abnt-numero-pagina(paginacao: "auto", frente-verso: frente-verso))

  // Frente-verso: os elementos pre-textuais consultam este estado (abre-anverso)
  abnt-frente-verso.update(frente-verso)

  _proj-meta.update((
    titulo: titulo, subtitulo: subtitulo, autor: autor, instituicao: instituicao,
    local: local, ano: ano, tipo-projeto: tipo-projeto, orientador: orientador,
    coorientador: coorientador, coordenador: coordenador, volume: volume,
  ))

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
///
/// Os parametros que ficarem `none` valem o que foi dado a `projeto-pesquisa()`.
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

  context {
    let instituicao = _proj-resolve(instituicao, "instituicao")
    let autor = _proj-resolve(autor, "autor")
    let titulo = _proj-resolve(titulo, "titulo")
    let subtitulo = _proj-resolve(subtitulo, "subtitulo")
    let volume = _proj-resolve(volume, "volume")
    let local = _proj-resolve(local, "local")
    let ano = _proj-resolve(ano, "ano")

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

    // Titulo (maiusculas, negrito) e subtitulo (precedido de dois-pontos)
    _proj-titulo(titulo, subtitulo)

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
///
/// Os parametros que ficarem `none` valem o que foi dado a `projeto-pesquisa()`.
/// E daqui que a contagem de paginas comeca (a capa nao conta).
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
  abre-anverso()
  set page(numbering: none)
  marcar-folha-rosto()
  set align(center)

  context {
    let autor = _proj-resolve(autor, "autor")
    let titulo = _proj-resolve(titulo, "titulo")
    let subtitulo = _proj-resolve(subtitulo, "subtitulo")
    let volume = _proj-resolve(volume, "volume")
    let tipo-projeto = _proj-resolve(tipo-projeto, "tipo-projeto")
    let instituicao = _proj-resolve(instituicao, "instituicao")
    let orientador = _proj-resolve(orientador, "orientador")
    let coorientador = _proj-resolve(coorientador, "coorientador")
    let coordenador = _proj-resolve(coordenador, "coordenador")
    let local = _proj-resolve(local, "local")
    let ano = _proj-resolve(ano, "ano")

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

    // Titulo (maiusculas, negrito) e subtitulo
    _proj-titulo(titulo, subtitulo)

    // Volume
    if volume != none {
      v(0.5em)
      text(size: 12pt, "Volume " + str(volume))
    }

    v(2cm)

    // Tipo de projeto e orientadores (recuo de 8cm, espaco simples, corpo 12)
    if tipo-projeto != none or orientador != none or coordenador != none {
      set align(right)
      box(width: 8cm)[
        #set align(left)
        #set par(
          leading: abnt-leading(1),
          spacing: abnt-leading(1),
          first-line-indent: 0pt,
          justify: true,
        )

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

  // Com muitos periodos de rotulo longo (ex.: 12 meses por extenso) cada coluna fica
  // estreita e o rotulo se parte em silabas; nesse caso o cabecalho vai na vertical.
  let longo = num-periods > 6 and periodos.any(p => str(p).len() > 4)
  let cab-periodo(p) = if longo {
    align(center + bottom, rotate(-90deg, reflow: true, [*#p*]))
  } else { [*#p*] }

  table(
    columns: cols,
    stroke: 0.5pt,
    inset: 6pt,
    align: (left,) + (center,) * num-periods,

    // Cabecalho
    [*Atividades*],
    ..periodos.map(cab-periodo),

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
        [*Descrição*], [*Valor (R\$)*],
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
        ..if total != none {
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
  heading(level: 1, numbering: none, "GLOSSÁRIO")

  set par(first-line-indent: 0pt)

  // Ordenar itens alfabeticamente
  let sorted-items = itens.pairs().sorted(key: p => sort-key(p.at(0)))

  for (termo, definicao) in sorted-items {
    [*#termo:* #definicao]
    linebreak()
    v(0.5em)
  }

  pagebreak(weak: true)
}

// apendice() e anexo() são definidos em src/text/headings.typ (funções globais do pacote)
