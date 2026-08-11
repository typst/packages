// Folha de rosto conforme NBR 14724:2024
// Anverso: autor, título, natureza, orientador, local, ano

#import "../core/spacing.typ": nature-block

/// Cria folha de rosto conforme ABNT
#let folha-rosto(
  autor: none,
  titulo: none,
  subtitulo: none,
  natureza: none,        // Natureza do trabalho (dissertação, tese, TCC)
  objetivo: none,        // Objetivo (obtenção de grau)
  instituicao: none,
  area: none,            // Área de concentração
  orientador: none,      // Orientador
  coorientador: none,    // Coorientador
  local: none,
  ano: none,
) = {
  set page(numbering: none)
  set align(center)

  // Autor
  if autor != none {
    text(size: 12pt, upper(autor))
  }

  v(1fr)

  // Título (maiúsculas, negrito)
  if titulo != none {
    if subtitulo != none {
      // Título com dois-pontos no final
      text(weight: "bold", size: 14pt, upper(titulo) + ":")
      linebreak()
      // Subtítulo em linha separada
      text(size: 14pt, subtitulo)
    } else {
      text(weight: "bold", size: 14pt, upper(titulo))
    }
  }

  v(2cm)

  // Natureza do trabalho (recuo de 8cm, espaço simples)
  if natureza != none or objetivo != none or orientador != none {
    set align(right)
    box(width: 8cm)[
      #set align(left)
      #set par(
        leading: 1em * 0.65,
        first-line-indent: 0pt,
        justify: true,
      )
      #set text(size: 10pt)

      #if natureza != none { natureza }
      #if objetivo != none { [ #objetivo] }
      #if instituicao != none { linebreak(); instituicao }
      #if area != none { linebreak(); [Área de concentração: #area] }

      #if orientador != none {
        linebreak()
        linebreak()
        [Orientador: #orientador]
      }

      #if coorientador != none {
        linebreak()
        [Coorientador: #coorientador]
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

/// Verso da folha de rosto (ficha catalográfica)
/// Deve ocupar a parte inferior da página
#let ficha-catalografica(conteudo) = {
  set page(numbering: none)
  v(1fr)

  align(center)[
    #box(
      width: 12.5cm,
      height: 7.5cm,
      stroke: 0.5pt,
      inset: 0.5cm,
    )[
      #set text(size: 10pt)
      #set par(leading: 1em * 0.65)
      #conteudo
    ]
  ]

  pagebreak()
}
