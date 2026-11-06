// Configuração de espaçamentos conforme NBR 14724:2024

/// Espaçamento entre linhas ABNT
#let abnt-line-spacing = (
  normal: 1.5em,       // Texto principal: 1,5
  single: 1em,         // Espaçamento simples
  double: 2em,         // Espaçamento duplo
)

/// Aplica espaçamento padrão ABNT (1,5 entre linhas)
#let abnt-spacing-setup() = {
  set par(
    leading: 1.5em * 0.65,  // Typst usa leading, não line-height
    justify: true,
    first-line-indent: (amount: 1.25cm, all: true),  // Parágrafo com recuo de 1,25 cm
  )
}

/// Aplica configuração completa de espaçamento ABNT
#let with-abnt-spacing(body) = {
  set par(
    leading: 1.5em * 0.65,
    justify: true,
    first-line-indent: (amount: 1.25cm, all: true),
  )
  body
}

/// Espaçamento simples (para citações longas, notas, referências)
#let single-spacing(body) = {
  set par(leading: 1em * 0.65)
  body
}

/// Espaçamento 1,5 (padrão para texto)
#let one-half-spacing(body) = {
  set par(leading: 1.5em * 0.65)
  body
}

/// Espaçamento duplo
#let double-spacing(body) = {
  set par(leading: 2em * 0.65)
  body
}

/// Bloco sem recuo de primeira linha
#let no-indent(body) = {
  set par(first-line-indent: 0pt)
  body
}

/// Bloco com recuo específico (para citações longas: 4cm da margem esquerda)
#let indented-block(recuo: 4cm, body) = {
  pad(left: recuo)[
    #set par(first-line-indent: 0pt)
    #body
  ]
}

// Espaçamentos específicos ABNT
// - Entre título da seção e texto: 1 espaço de 1,5
// - Entre texto e título da próxima seção: 1 espaço de 1,5
// - Natureza do trabalho: recuo de 8 cm da margem esquerda

/// Espaço vertical padrão entre seções
#let section-spacing = v(1.5em)

/// Bloco para natureza do trabalho (folha de rosto)
/// Recuo de 8 cm da margem esquerda, espaçamento simples
#let nature-block(body) = {
  pad(left: 8cm)[
    #set par(
      leading: 1em * 0.65,
      first-line-indent: 0pt,
      justify: true,
    )
    #set text(size: 10pt)
    #body
  ]
}
