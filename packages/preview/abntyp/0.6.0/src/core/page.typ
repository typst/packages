// Configuração de página conforme NBR 14724:2024
// Formato A4 (21 cm x 29,7 cm)
// Margens: superior e esquerda 3 cm, inferior e direita 2 cm

/// Configuração padrão de página ABNT
/// - papel: formato do papel (default: "a4")
/// - margem-superior: margem superior (default: 3cm)
/// - margem-inferior: margem inferior (default: 2cm)
/// - margem-esquerda: margem esquerda (default: 3cm)
/// - margem-direita: margem direita (default: 2cm)
#let abnt-page-setup(
  papel: "a4",
  margem-superior: 3cm,
  margem-inferior: 2cm,
  margem-esquerda: 3cm,
  margem-direita: 2cm,
) = {
  set page(
    paper: papel,
    margin: (
      top: margem-superior,
      bottom: margem-inferior,
      left: margem-esquerda,
      right: margem-direita,
    ),
  )
}

/// Aplica configuração de página ABNT ao documento
#let with-abnt-page(body) = {
  set page(
    paper: "a4",
    margin: (
      top: 3cm,
      bottom: 2cm,
      left: 3cm,
      right: 2cm,
    ),
  )
  body
}

// Paginação
// - Elementos pré-textuais: contados mas não numerados (ou algarismos romanos minúsculos)
// - Elementos textuais e pós-textuais: algarismos arábicos, canto superior direito

/// Inicia paginação em algarismos arábicos
/// Usar no início da seção textual (Introdução)
#let start-arabic-numbering() = {
  counter(page).update(1)
  set page(numbering: "1")
}

/// Configura paginação no canto superior direito (padrão ABNT)
#let abnt-page-numbering() = {
  set page(
    numbering: "1",
    number-align: top + right,
  )
}

/// Paginação pré-textual (romanos minúsculos, opcional)
#let pretextual-numbering() = {
  set page(numbering: "i")
}

/// Remove numeração de página (para capa, folha de rosto)
#let no-page-numbering() = {
  set page(numbering: none)
}

/// Margens ABNT para impressão frente-verso (interna 3 cm, externa 2 cm) ou
/// somente anverso (esquerda 3 cm, direita 2 cm).
#let abnt-margens(frente-verso) = if frente-verso {
  (top: 3cm, bottom: 2cm, inside: 3cm, outside: 2cm)
} else {
  (top: 3cm, bottom: 2cm, left: 3cm, right: 2cm)
}

/// Número de página automático (NBR 14724 / NBR 10719).
/// Retorna conteúdo para usar em `header:` ou `footer:`.
/// - paginacao: "auto" (visível a partir da primeira seção primária numerada),
///   "todas" (desde a folha de rosto) ou "nenhuma"
/// - frente-verso: número alterna direita/esquerda (ímpar/par)
/// - centro: número centralizado (em vez de direita/esquerda)
///
/// A contagem começa na folha de rosto, marcada com o label <abnt-folha-rosto>
/// (ver `marcar-folha-rosto`); sem ela, começa na página 1.
/// - apos-sumario: (livro, NBR 6029) número visível só após o sumário,
///   marcado com <abnt-fim-sumario>, incluindo prefácio sem indicativo de seção
#let abnt-numero-pagina(paginacao: "auto", frente-verso: false, centro: false, apos-sumario: false) = {
  if paginacao == "nenhuma" { return auto }
  context {
    let atual = here().position().page
    let rosto = query(<abnt-folha-rosto>)
    let inicio = if rosto.len() > 0 { rosto.first().location().position().page } else { 1 }
    let textuais = query(heading.where(level: 1)).filter(h => h.numbering != none)
    let fim-sumario = query(<abnt-fim-sumario>)
    let primeira = if paginacao == "todas" { inicio } else if apos-sumario and fim-sumario.len() > 0 {
      fim-sumario.last().location().position().page + 1
    } else if textuais.len() > 0 {
      textuais.first().location().position().page
    } else { none }
    if primeira != none and atual >= primeira and atual >= inicio {
      let lado = if centro { center } else if frente-verso and calc.even(atual) { left } else { right }
      align(lado, text(size: 10pt, str(counter(page).get().first())))
    }
  }
}

/// Marca a folha de rosto: a contagem de páginas passa a valer 1 aqui.
/// Com `primeiro: true` (livro: falsa folha de rosto e folha de rosto), só a
/// primeira chamada do documento reinicia a contagem.
#let marcar-folha-rosto(primeiro: false) = [
  #box(width: 0pt, height: 0pt) <abnt-folha-rosto>
  #if primeiro {
    context {
      let marcas = query(<abnt-folha-rosto>)
      if marcas.first().location().position().page == here().position().page {
        counter(page).update(1)
      }
    }
  } else {
    counter(page).update(1)
  }
]

/// Quebra de página (equivale a `pagebreak()`, com `para` em português).
/// - fraco: se true, só quebra se a página atual não estiver vazia
/// - para: "impar" ou "par" para avançar até a próxima página ímpar/par
///   (útil na impressão frente-verso)
#let quebra-pagina(fraco: false, para: none) = {
  if para == none {
    pagebreak(weak: fraco)
  } else {
    assert(
      para in ("impar", "par"),
      message: "quebra-pagina: 'para' deve ser \"impar\" ou \"par\"",
    )
    pagebreak(weak: fraco, to: if para == "impar" { "odd" } else { "even" })
  }
}
