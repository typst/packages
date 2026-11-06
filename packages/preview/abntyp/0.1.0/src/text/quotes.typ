// Citações conforme NBR 10520:2023

/// Citação direta curta (até 3 linhas)
/// Incorporada ao parágrafo, entre aspas duplas
#let citacao-curta(texto, autor: none, ano: none, pagina: none) = {
  ["#texto"]
  if autor != none or ano != none or pagina != none {
    [ (]
    if autor != none { upper(autor) }
    if ano != none {
      if autor != none { [, ] }
      [#ano]
    }
    if pagina != none {
      [, p. #pagina]
    }
    [)]
  }
}

/// Citação direta longa (mais de 3 linhas)
/// Recuo de 4 cm da margem esquerda, fonte tamanho 10, espaçamento simples
#let citacao-longa(body, autor: none, ano: none, pagina: none) = {
  v(1em)
  pad(left: 4cm)[
    #set text(size: 10pt)
    #set par(
      leading: 1em * 0.65,
      first-line-indent: 0pt,
      justify: true,
    )
    #body
    #if autor != none or ano != none or pagina != none {
      [ (]
      if autor != none { upper(autor) }
      if ano != none {
        if autor != none { [, ] }
        [#ano]
      }
      if pagina != none {
        [, p. #pagina]
      }
      [)]
    }
  ]
  v(1em)
}

/// Supressão de texto [...]
#let supressao = [[...]]

/// Interpolação de texto [texto]
#let interpolacao(texto) = {
  [\[#texto\]]
}

/// Ênfase adicionada pelo autor da citação
#let grifo-nosso(texto) = {
  [#emph(texto), grifo nosso]
}

/// Ênfase do autor original
#let grifo-do-autor(texto) = {
  [#emph(texto), grifo do autor]
}
