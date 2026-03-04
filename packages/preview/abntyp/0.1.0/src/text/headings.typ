// Seções e subseções conforme NBR 6024:2012

/// Configuração de títulos de seção conforme ABNT
/// - Seção primária: MAIÚSCULAS, negrito
/// - Seção secundária: MAIÚSCULAS, sem negrito
/// - Seção terciária: Minúsculas, negrito
/// - Seção quaternária: Minúsculas, sem negrito
/// - Seção quinária: Minúsculas, itálico
#let abnt-heading-setup() = {
  // Seção primária (nível 1): MAIÚSCULAS, negrito
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(1.5em)
    text(
      weight: "bold",
      size: 12pt,
      upper(it.body),
    )
    v(1.5em)
  }

  // Seção secundária (nível 2): MAIÚSCULAS, normal
  show heading.where(level: 2): it => {
    v(1.5em)
    text(
      weight: "regular",
      size: 12pt,
      upper(it.body),
    )
    v(1.5em)
  }

  // Seção terciária (nível 3): Minúsculas, negrito
  show heading.where(level: 3): it => {
    v(1.5em)
    text(
      weight: "bold",
      size: 12pt,
      it.body,
    )
    v(1.5em)
  }

  // Seção quaternária (nível 4): Minúsculas, normal
  show heading.where(level: 4): it => {
    v(1.5em)
    text(
      weight: "regular",
      size: 12pt,
      it.body,
    )
    v(1.5em)
  }

  // Seção quinária (nível 5): Minúsculas, itálico
  show heading.where(level: 5): it => {
    v(1.5em)
    text(
      weight: "regular",
      style: "italic",
      size: 12pt,
      it.body,
    )
    v(1.5em)
  }
}

/// Aplica formatação de headings ABNT
#let with-abnt-headings(body) = {
  set heading(numbering: "1.1")

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(1.5em)
    text(weight: "bold", size: 12pt)[
      #if it.numbering != none {
        counter(heading).display()
        h(0.5em)
      }
      #upper(it.body)
    ]
    v(1.5em)
  }

  show heading.where(level: 2): it => {
    v(1.5em)
    text(weight: "regular", size: 12pt)[
      #if it.numbering != none {
        counter(heading).display()
        h(0.5em)
      }
      #upper(it.body)
    ]
    v(1.5em)
  }

  show heading.where(level: 3): it => {
    v(1.5em)
    text(weight: "bold", size: 12pt)[
      #if it.numbering != none {
        counter(heading).display()
        h(0.5em)
      }
      #it.body
    ]
    v(1.5em)
  }

  show heading.where(level: 4): it => {
    v(1.5em)
    text(weight: "regular", size: 12pt)[
      #if it.numbering != none {
        counter(heading).display()
        h(0.5em)
      }
      #it.body
    ]
    v(1.5em)
  }

  show heading.where(level: 5): it => {
    v(1.5em)
    text(weight: "regular", style: "italic", size: 12pt)[
      #if it.numbering != none {
        counter(heading).display()
        h(0.5em)
      }
      #it.body
    ]
    v(1.5em)
  }

  body
}

/// Seção sem numeração (para Introdução, Conclusão, Referências, etc.)
/// Deve aparecer no sumário
#let unnumbered-section(titulo, nivel: 1) = {
  heading(level: nivel, numbering: none, upper(titulo))
}

/// Título de elemento pré-textual (não aparece no sumário)
#let pretextual-title(titulo) = {
  align(center)[
    #text(weight: "bold", size: 12pt, upper(titulo))
  ]
  v(1.5em)
}
