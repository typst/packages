// Configuração de espaçamentos conforme NBR 14724:2024

/// Espaçamento entre linhas ABNT
#let abnt-line-spacing = (
  normal: 1.5em,       // Texto principal: 1,5
  single: 1em,         // Espaçamento simples
  double: 2em,         // Espaçamento duplo
)

// Entrelinha calibrada pelo Word: passo entre linhas = k × 1,15 × corpo, com k = 1
// (simples), 1,5 e 2; em 12 pt: 13,8 / 20,7 / 27,6 pt, igual em Times New Roman e
// Arial. As bordas da linha são fixas (topo 0,7em, base 0) para o passo não
// depender da fonte: use `set text(top-edge: abnt-top-edge, bottom-edge: abnt-bottom-edge)`
// junto com `set par(leading: abnt-leading(k), spacing: abnt-leading(k))` (o espaço
// entre parágrafos é igual à entrelinha, como nos modelos ABNT do Word, que usam zero).
#let abnt-top-edge = 0.7em
#let abnt-bottom-edge = 0pt
#let abnt-leading(k) = k * 1.15em - (abnt-top-edge - abnt-bottom-edge)

/// Aplica espaçamento padrão ABNT (1,5 entre linhas)
#let abnt-spacing-setup(body) = {
  set text(top-edge: abnt-top-edge, bottom-edge: abnt-bottom-edge)
  set par(
    leading: abnt-leading(1.5),
    spacing: abnt-leading(1.5),
    justify: true,
    first-line-indent: (amount: 1.25cm, all: true),  // Parágrafo com recuo de 1,25 cm
  )
  body
}

/// Aplica configuração completa de espaçamento ABNT
#let with-abnt-spacing(body) = {
  set text(top-edge: abnt-top-edge, bottom-edge: abnt-bottom-edge)
  set par(
    leading: abnt-leading(1.5),
    spacing: abnt-leading(1.5),
    justify: true,
    first-line-indent: (amount: 1.25cm, all: true),
  )
  body
}

/// Espaçamento simples (para citações longas, notas, referências)
#let single-spacing(body) = {
  set text(top-edge: abnt-top-edge, bottom-edge: abnt-bottom-edge)
  set par(leading: abnt-leading(1), spacing: abnt-leading(1))
  body
}

/// Espaçamento 1,5 (padrão para texto)
#let one-half-spacing(body) = {
  set text(top-edge: abnt-top-edge, bottom-edge: abnt-bottom-edge)
  set par(leading: abnt-leading(1.5), spacing: abnt-leading(1.5))
  body
}

/// Espaçamento duplo
#let double-spacing(body) = {
  set text(top-edge: abnt-top-edge, bottom-edge: abnt-bottom-edge)
  set par(leading: abnt-leading(2), spacing: abnt-leading(2))
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
      leading: abnt-leading(1),
      first-line-indent: 0pt,
      justify: true,
    )
    #set text(size: 10pt)
    #body
  ]
}
