// Citações conforme NBR 10520:2023

/// Citação direta curta (até 3 linhas)
/// Incorporada ao parágrafo, entre aspas duplas
///
/// Aceita parâmetros posicionais ou nomeados:
///   #citacao-curta("Silva", "2023", "45")[Texto]
///   #citacao-curta(autor: "Silva", ano: "2023")[Texto]
///   #citacao-curta()[Texto]
#let citacao-curta(
  autor: none,
  ano: none,
  pagina: none,
  volume: none,
  localizacao: none,
  grifo: none,
  traducao: none,
  ..args,
) = {
  let pos = args.pos()
  let body = pos.last()
  let rest = pos.slice(0, -1)
  if autor == none and rest.len() >= 1 { autor = rest.at(0) }
  if ano == none and rest.len() >= 2 { ano = rest.at(1) }
  if pagina == none and rest.len() >= 3 { pagina = rest.at(2) }
  [\u{201C}#body\u{201D}]
  let tem-fonte = (
    autor != none or ano != none or pagina != none
      or volume != none or localizacao != none
      or grifo != none or traducao != none
  )
  if tem-fonte {
    // Sobrenome com apenas a inicial maiúscula (NBR 10520:2023);
    // a CAIXA ALTA da chamada era regra da NBR 10520:2002 (revogada).
    [ (]
    if autor != none { autor }
    if ano != none {
      if autor != none { [, ] }
      [#ano]
    }
    if volume != none { [, v. #volume] }
    if pagina != none { [, p. #pagina] }
    if localizacao != none { [, #localizacao] }
    if grifo != none { [, grifo #grifo] }
    if traducao != none { [, tradução #traducao] }
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
#let citacao-longa(
  autor: none,
  ano: none,
  pagina: none,
  volume: none,
  localizacao: none,
  grifo: none,
  traducao: none,
  ..args,
) = {
  let pos = args.pos()
  let body = pos.last()
  let rest = pos.slice(0, -1)
  if autor == none and rest.len() >= 1 { autor = rest.at(0) }
  if ano == none and rest.len() >= 2 { ano = rest.at(1) }
  if pagina == none and rest.len() >= 3 { pagina = rest.at(2) }
  let tem-fonte = (
    autor != none or ano != none or pagina != none
      or volume != none or localizacao != none
      or grifo != none or traducao != none
  )
  v(1em)
  pad(left: 4cm)[
    #set text(size: 10pt)
    #set par(
      leading: 1em * 0.65,
      first-line-indent: 0pt,
      justify: true,
    )
    #body
    #if tem-fonte {
      // Sobrenome com apenas a inicial maiúscula (NBR 10520:2023).
      [ (]
      if autor != none { autor }
      if ano != none {
        if autor != none { [, ] }
        [#ano]
      }
      if volume != none { [, v. #volume] }
      if pagina != none { [, p. #pagina] }
      if localizacao != none { [, #localizacao] }
      if grifo != none { [, grifo #grifo] }
      if traducao != none { [, tradução #traducao] }
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

/// Destaque/ênfase em trecho de citação (aplica itálico ao trecho).
///
/// IMPORTANTE (NBR 10520:2023, 5.1): a INDICAÇÃO "grifo nosso" / "grifo do
/// autor" deve aparecer ao FINAL da citação, dentro dos parênteses, após a
/// página — ex.: (Souto, 1916, p. 46, grifo nosso). Por isso o indicador é
/// passado via o parâmetro `grifo:` da função de citação, e estas funções
/// apenas aplicam o itálico ao trecho destacado:
///   #citacao-curta("Souto", 1916, 46, grifo: "nosso")[A #grifo-nosso[clareza]...]
#let grifo-nosso(texto) = emph(texto)

/// Destaque já existente no original (itálico). Ver `grifo-nosso`;
/// use `grifo: "do autor"` na função de citação para a indicação final.
#let grifo-do-autor(texto) = emph(texto)

// Aliases curtos
#let ccurta = citacao-curta
#let clonga = citacao-longa
#let interp = interpolacao
#let gnosso = grifo-nosso
#let gautor = grifo-do-autor
