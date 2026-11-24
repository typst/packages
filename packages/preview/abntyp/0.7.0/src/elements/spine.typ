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
// - Descendente: titulo impresso longitudinalmente, legivel do alto para o pe (texto girado
//   90 graus no sentido horario)

#import "../core/metadata.typ"

// Converte valor para string (int/float → str, str → str, content → content)
// Versão local para evitar problemas com metadata._str-safe em content blocks
#let _to-str(val) = {
  if type(val) == str { val }
  else if type(val) == int or type(val) == float { str(val) }
  else if val == none { "" }
  else if type(val) == content { val }
  else { str(val) }
}

// Nome(s) do(s) autor(es) em maiusculas, sempre como lista (aceita texto ou lista de textos)
#let _autores(autor) = {
  if autor == none { () }
  else if type(autor) == array { autor.map(a => upper(a)) }
  else { (upper(autor),) }
}

/// Gera uma pagina de lombada para impressao separada
///
/// Parametros:
/// - autor: nome do autor (pode ser abreviado) ou lista de nomes (separados por "; " na
///   descendente; um abaixo do outro na horizontal, NBR 12225 4.1.1)
/// - titulo: titulo do trabalho (pode ser abreviado)
/// - volume: numero do volume (opcional)
/// - fasciculo: numero do fasciculo (opcional; sai como "fasc. 3")
/// - ano: ano (opcional)
/// - instituicao: sigla da instituicao (opcional)
/// - logo: imagem da logomarca (opcional)
/// - orientacao: "descendente" ou "horizontal" (padrao: "descendente")
/// - largura-lombada: largura da lombada (padrao: 2cm)
/// - altura-lombada: altura da lombada (padrao: 29.7cm - A4)
/// - espaco-reservado: espaco reservado na base, deixado em branco para a etiqueta
///   de localizacao (padrao: 30mm); a logomarca fica acima dele
///
/// Nota: Esta funcao gera uma pagina separada com a lombada, em retrato (largura x altura
/// da lombada). Na descendente o texto ja sai girado, legivel do alto para o pe.
/// Para impressao, a lombada deve ser cortada e aplicada ao dorso do trabalho.
#let lombada(
  autor: none,
  titulo: none,
  volume: none,
  fasciculo: none,
  ano: none,
  instituicao: none,
  logo: none,
  orientacao: "descendente",
  largura-lombada: 2cm,
  altura-lombada: 29.7cm,
  espaco-reservado: 30mm,
) = {
  set page(
    width: largura-lombada,
    height: altura-lombada,
    margin: 3mm,
  )

  context {
    let autor = metadata._resolve(autor, "autor")
    let titulo = metadata._resolve(titulo, "titulo")
    let ano = metadata._resolve(ano, "ano")
    let instituicao = metadata._resolve(instituicao, "instituicao")
    let ano-str = if ano != none { _to-str(ano) }
    let vol-str = if volume != none { "v. " + _to-str(volume) }
    let fasc-str = if fasciculo != none { "fasc. " + _to-str(fasciculo) }
    let autores = _autores(autor)

    if orientacao == "descendente" {
      // Lombada descendente - legivel do alto para o pe: o layout e montado na horizontal
      // (autor, titulo, elementos, logo, espaco reservado) e girado 90 graus no sentido
      // horario, de modo que o autor fica no alto e o espaco reservado no pe
      rotate(90deg, reflow: true, box(
        width: altura-lombada - 6mm,
        height: largura-lombada - 6mm,
      )[
        #set text(size: 10pt)

        #grid(
          columns: (auto, 1fr, auto, auto, espaco-reservado),
          gutter: 1em,
          align: horizon,

          // Autor
          if autores.len() > 0 {
            text(weight: "bold", autores.join("; "))
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
            if vol-str != none { elements.push(vol-str) }
            if fasc-str != none { elements.push(fasc-str) }
            if ano-str != none { elements.push(ano-str) }
            if instituicao != none { elements.push(instituicao) }
            elements.join(" ")
          },

          // Logomarca (acima do espaco reservado)
          if logo != none { logo },

          // Espaco reservado (30mm), em branco para a etiqueta de localizacao
          [],
        )
      ])
    } else {
      // Lombada horizontal - para lombadas largas
      set align(center + top)

      box(
        width: 100%,
        height: 100%,
      )[
        #set text(size: 9pt)

        // Autor(es), um abaixo do outro
        #if autores.len() > 0 {
          text(weight: "bold", size: 10pt, autores.join(linebreak()))
          v(0.5em)
        }

        #v(1fr)

        // Titulo
        #if titulo != none {
          text(weight: "bold", upper(titulo))
        }

        #v(1fr)

        // Elementos alfanumericos
        #{
          let linhas = ()
          if vol-str != none { linhas.push(vol-str) }
          if fasc-str != none { linhas.push(fasc-str) }
          if ano-str != none { linhas.push(ano-str) }
          if instituicao != none { linhas.push(instituicao) }
          linhas.join(linebreak())
        }

        #v(0.5em)

        // Logo
        #if logo != none {
          logo
        }

        // Espaco reservado
        #v(espaco-reservado)
      ]
    }
  }
}

/// Gera preview da lombada em uma caixa
/// Util para visualizacao no documento
///
/// Parametros: mesmos da funcao lombada()
/// Retorna: uma caixa com a lombada renderizada verticalmente (texto do alto para o pe)
#let lombada-preview(
  autor: none,
  titulo: none,
  volume: none,
  fasciculo: none,
  ano: none,
  instituicao: none,
  logo: none,
  largura-lombada: 2cm,
  altura-lombada: 20cm,
  espaco-reservado: 30mm,
) = {
  context {
    let autor = metadata._resolve(autor, "autor")
    let titulo = metadata._resolve(titulo, "titulo")
    let ano = metadata._resolve(ano, "ano")
    let instituicao = metadata._resolve(instituicao, "instituicao")
    let ano-str = if ano != none { _to-str(ano) }
    let vol-str = if volume != none { "v. " + _to-str(volume) }
    let fasc-str = if fasciculo != none { "fasc. " + _to-str(fasciculo) }
    let autores = _autores(autor)

    box(
      width: largura-lombada,
      height: altura-lombada,
      stroke: 0.5pt + gray,
      inset: 2mm,
    )[
      #set text(size: 8pt)
      #set align(center)

      // Autor (topo)
      #if autores.len() > 0 {
        rotate(90deg, reflow: true)[
          #text(weight: "bold", size: 7pt, autores.join("; "))
        ]
        v(0.3em)
      }

      #v(1fr)

      // Titulo (rotacionado)
      #if titulo != none {
        rotate(90deg, reflow: true)[
          #text(weight: "bold", size: 8pt, upper(titulo))
        ]
      }

      #v(1fr)

      // Elementos alfanumericos
      #rotate(90deg, reflow: true)[
        #{
          let elements = ()
          if vol-str != none { elements.push(vol-str) }
          if fasc-str != none { elements.push(fasc-str) }
          if ano-str != none { elements.push(ano-str) }
          elements.join(" ")
        }
      ]

      #if instituicao != none {
        v(0.3em)
        rotate(90deg, reflow: true)[
          #text(size: 7pt, instituicao)
        ]
      }

      #v(0.5em)

      // Logo
      #if logo != none {
        logo
      }

      // Indicador de espaco reservado
      #v(0.3em)
      #line(length: 100%, stroke: 0.3pt + gray)
      #text(size: 5pt, fill: gray)[30mm]
    ]
  }
}

/// Gera texto formatado para lombada descendente
/// Retorna o texto rotacionado 90 graus (legivel do alto para o pe) para ser usado em
/// outros contextos
#let spine-text-descending(
  autor: none,
  titulo: none,
  volume: none,
  fasciculo: none,
  ano: none,
) = {
  context {
    let autor = metadata._resolve(autor, "autor")
    let titulo = metadata._resolve(titulo, "titulo")
    let ano = metadata._resolve(ano, "ano")
    let ano-str = if ano != none { _to-str(ano) }
    let vol-str = if volume != none { "v. " + _to-str(volume) }
    let fasc-str = if fasciculo != none { "fasc. " + _to-str(fasciculo) }
    let autores = _autores(autor)

    let parts = ()

    if autores.len() > 0 {
      parts.push(text(weight: "bold", autores.join("; ")))
    }

    if titulo != none {
      parts.push(text(weight: "bold", upper(titulo)))
    }

    let elements = ()
    if vol-str != none { elements.push(vol-str) }
    if fasc-str != none { elements.push(fasc-str) }
    if ano-str != none { elements.push(ano-str) }

    if elements.len() > 0 {
      parts.push(elements.join(" "))
    }

    rotate(90deg, reflow: true, parts.join(h(2em)))
  }
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
  context {
    let titulo = metadata._resolve(titulo, "titulo")

    box(
      width: largura-margem,
      height: 100%,
    )[
      #set align(center + horizon)
      #rotate(90deg, reflow: true)[
        #set text(size: 10pt)
        #if titulo != none { upper(titulo) }
        #if volume != none { [ \- v. #volume] }
      ]
    ]
  }
}
