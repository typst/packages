// Citações conforme NBR 10520:2023

/// Citação direta curta (até 3 linhas)
/// Incorporada ao parágrafo, entre aspas duplas
///
/// Aceita parâmetros posicionais ou nomeados:
///   #citacao-curta("Silva", "2023", "45")[Texto]
///   #citacao-curta(autor: "Silva", ano: "2023")[Texto]
///   #citacao-curta()[Texto]
#let citacao-curta(autor: none, ano: none, pagina: none, ..args) = {
  let pos = args.pos()
  let body = pos.last()
  let rest = pos.slice(0, -1)
  if autor == none and rest.len() >= 1 { autor = rest.at(0) }
  if ano == none and rest.len() >= 2 { ano = rest.at(1) }
  if pagina == none and rest.len() >= 3 { pagina = rest.at(2) }
  [\u{201C}#body\u{201D}]
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
///
/// Aceita parâmetros posicionais ou nomeados:
///   #citacao-longa("Silva", "2023", "45-46")[Texto longo...]
///   #citacao-longa(autor: "Silva", ano: "2023")[Texto longo...]
///   #citacao-longa()[Texto longo...]
#let citacao-longa(autor: none, ano: none, pagina: none, ..args) = {
  let pos = args.pos()
  let body = pos.last()
  let rest = pos.slice(0, -1)
  if autor == none and rest.len() >= 1 { autor = rest.at(0) }
  if ano == none and rest.len() >= 2 { ano = rest.at(1) }
  if pagina == none and rest.len() >= 3 { pagina = rest.at(2) }
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

// Aliases curtos
#let ccurta = citacao-curta
#let clonga = citacao-longa
#let interp = interpolacao
#let gnosso = grifo-nosso
#let gautor = grifo-do-autor
