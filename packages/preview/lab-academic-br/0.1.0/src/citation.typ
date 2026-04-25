// ============================================================
// src/citation.typ
// Utilitários de citação conforme ABNT NBR 10520 e NBR 6023
// ============================================================

// Substitui autor repetido nas referências bibliográficas
#let idem = "______."

// Citação direta longa: 3+ linhas, recuo 4 cm, tamanho 10, espaço simples
#let citacao-longa(corpo) = {
  v(1em)
  set par(first-line-indent: 0pt, leading: 0.5em, justify: true)
  block(inset: (left: 4cm))[
    #text(size: 10pt)[#corpo]
  ]
  v(1em)
}

// Seção de referências: quebra de página + título + tipografia ABNT
#let referencias(conteudo) = {
  pagebreak()
  align(center)[#text(weight: 700)[REFERÊNCIAS]]
  v(1.5em)
  set par(first-line-indent: 0pt, justify: false, leading: 0.5em, spacing: 1.2em)
  conteudo
}
