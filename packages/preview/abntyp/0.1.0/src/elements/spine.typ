// Lombada conforme NBR 12225:2004
//
// Estrutura da Lombada:
// 1. Nome(s) do(s) autor(es) - quando houver
// 2. Titulo
// 3. Elementos alfanumericos de identificacao (volume, fasciculo, data)
// 4. Logomarca da editora
//
// Recomendacao: Reservar 30mm na borda inferior para elementos de identificacao
//
// Tipos de lombada:
// - Horizontal: titulo impresso horizontalmente quando o documento esta em posicao vertical
// - Descendente: titulo impresso longitudinalmente, legivel do alto para o pe

/// Gera uma pagina de lombada para impressao separada
///
/// Parametros:
/// - autor: nome do autor (pode ser abreviado)
/// - titulo: titulo do trabalho (pode ser abreviado)
/// - volume: numero do volume (opcional)
/// - ano: ano (opcional)
/// - instituicao: sigla da instituicao (opcional)
/// - logo: imagem da logomarca (opcional)
/// - orientacao: "descendente" ou "horizontal" (padrao: "descendente")
/// - largura-lombada: largura da lombada (padrao: 2cm)
/// - altura-lombada: altura da lombada (padrao: 29.7cm - A4)
/// - espaco-reservado: espaco reservado na base (padrao: 30mm)
///
/// Nota: Esta funcao gera uma pagina separada com a lombada.
/// Para impressao, a lombada deve ser cortada e aplicada ao dorso do trabalho.
#let lombada(
  autor: none,
  titulo: none,
  volume: none,
  ano: none,
  instituicao: none,
  logo: none,
  orientacao: "descendente",
  largura-lombada: 2cm,
  altura-lombada: 29.7cm,
  espaco-reservado: 30mm,
) = {
  set page(
    width: altura-lombada,
    height: largura-lombada,
    margin: 3mm,
  )

  if orientacao == "descendente" {
    // Lombada descendente - legivel do alto para o pe
    // O texto e rotacionado 90 graus
    set align(left + horizon)

    box(
      width: 100%,
      height: 100%,
    )[
      #set text(size: 10pt)

      // Layout horizontal (sera rotacionado na impressao)
      #grid(
        columns: (auto, 1fr, auto, auto),
        gutter: 1em,
        align: horizon,

        // Autor
        if autor != none {
          text(weight: "bold", upper(autor))
        },

        // Titulo (centralizado, ocupa espaco restante)
        align(center)[
          #if titulo != none {
            text(weight: "bold", upper(titulo))
          }
        ],

        // Elementos alfanumericos
        {
          let elements = ()
          if volume != none { elements.push("v. " + str(volume)) }
          if ano != none { elements.push(str(ano)) }
          if instituicao != none { elements.push(instituicao) }
          elements.join(" ")
        },

        // Espaco reservado (30mm) + logo
        box(width: espaco-reservado)[
          #if logo != none {
            align(center + horizon, logo)
          }
        ],
      )
    ]
  } else {
    // Lombada horizontal - para lombadas largas
    set align(center + top)

    box(
      width: 100%,
      height: 100%,
    )[
      #set text(size: 9pt)

      // Autor
      if autor != none {
        text(weight: "bold", size: 10pt, upper(autor))
        v(0.5em)
      }

      v(1fr)

      // Titulo
      if titulo != none {
        text(weight: "bold", upper(titulo))
      }

      v(1fr)

      // Elementos alfanumericos
      {
        if volume != none { [v. #volume] }
        if ano != none {
          if volume != none { linebreak() }
          str(ano)
        }
        if instituicao != none {
          linebreak()
          instituicao
        }
      }

      v(0.5em)

      // Logo
      if logo != none {
        logo
      }

      // Espaco reservado
      v(espaco-reservado)
    ]
  }

  pagebreak()
}

/// Gera preview da lombada em uma caixa
/// Util para visualizacao no documento
///
/// Parametros: mesmos da funcao lombada()
/// Retorna: uma caixa com a lombada renderizada verticalmente
#let lombada-preview(
  autor: none,
  titulo: none,
  volume: none,
  ano: none,
  instituicao: none,
  logo: none,
  largura-lombada: 2cm,
  altura-lombada: 20cm,
  espaco-reservado: 30mm,
) = {
  box(
    width: largura-lombada,
    height: altura-lombada,
    stroke: 0.5pt + gray,
    inset: 2mm,
  )[
    #set text(size: 8pt)
    #set align(center)

    // Autor (topo)
    if autor != none {
      rotate(-90deg, reflow: true)[
        #text(weight: "bold", size: 7pt, upper(autor))
      ]
      v(0.3em)
    }

    v(1fr)

    // Titulo (rotacionado)
    if titulo != none {
      rotate(-90deg, reflow: true)[
        #text(weight: "bold", size: 8pt, upper(titulo))
      ]
    }

    v(1fr)

    // Elementos alfanumericos
    rotate(-90deg, reflow: true)[
      #{
        let elements = ()
        if volume != none { elements.push("v. " + str(volume)) }
        if ano != none { elements.push(str(ano)) }
        elements.join(" ")
      }
    ]

    if instituicao != none {
      v(0.3em)
      rotate(-90deg, reflow: true)[
        #text(size: 7pt, instituicao)
      ]
    }

    v(0.5em)

    // Logo
    if logo != none {
      logo
    }

    // Indicador de espaco reservado
    v(0.3em)
    line(length: 100%, stroke: 0.3pt + gray)
    text(size: 5pt, fill: gray)[30mm]
  ]
}

/// Gera texto formatado para lombada descendente
/// Retorna o texto rotacionado para ser usado em outros contextos
#let spine-text-descending(
  autor: none,
  titulo: none,
  volume: none,
  ano: none,
) = {
  let parts = ()

  if autor != none {
    parts.push(text(weight: "bold", upper(autor)))
  }

  if titulo != none {
    parts.push(text(weight: "bold", upper(titulo)))
  }

  let elements = ()
  if volume != none { elements.push("v. " + str(volume)) }
  if ano != none { elements.push(str(ano)) }

  if elements.len() > 0 {
    parts.push(elements.join(" "))
  }

  parts.join(h(2em))
}

/// Titulo de margem de capa
/// Para itens cujas lombadas nao comportam inscricoes
/// Titulo impresso longitudinalmente ao lado da lombada
///
/// Parametros:
/// - titulo: titulo do trabalho
/// - volume: numero do volume (opcional)
/// - largura-margem: largura da margem (padrao: 1.5cm)
#let margem-capa(
  titulo: none,
  volume: none,
  largura-margem: 1.5cm,
) = {
  box(
    width: largura-margem,
    height: 100%,
  )[
    #set align(center + horizon)
    #rotate(-90deg, reflow: true)[
      #set text(size: 10pt)
      #if titulo != none { upper(titulo) }
      #if volume != none { [ - v. #volume] }
    ]
  ]
}
