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

/// Título sem numeração — para Referências, Glossário, Apêndices etc.
/// Aparece no sumário. Nível padrão: 1 (seção primária).
/// Exemplo: #titulo-sem-num[REFERÊNCIAS]  ou  #titulo-sem-num("REFERÊNCIAS")
/// O suplemento é fixado em "Seção" para que @label produza "Seção X"
/// e não "Capítulo X" mesmo em templates que usam suplemento-nivel1: "Capítulo".
#let titulo-sem-num(titulo, nivel: 1) = {
  show heading: set heading(supplement: "Seção")
  heading(level: nivel, numbering: none, upper(titulo))
}

// Alias de retrocompatibilidade
#let secao = titulo-sem-num

/// Apêndice ABNT — material elaborado pelo próprio autor.
/// Cria heading nível 1 sem numeração automática; a letra é fornecida pelo autor (A, B, C...).
/// Aparece no sumário. @label produz "Apêndice A".
/// Exemplo: #apendice("A", "Questionário aplicado") <apendice-a>
#let apendice(letra, titulo) = {
  show heading: set heading(supplement: "Apêndice " + upper(letra))
  heading(level: 1, numbering: none)[APÊNDICE #upper(letra) -- #upper(titulo)]
}

/// Anexo ABNT — material NÃO elaborado pelo autor.
/// Cria heading nível 1 sem numeração automática; a letra é fornecida pelo autor (A, B, C...).
/// Aparece no sumário. @label produz "Anexo A".
/// Exemplo: #anexo("A", "Norma NBR 14724") <anexo-a>
#let anexo(letra, titulo) = {
  show heading: set heading(supplement: "Anexo " + upper(letra))
  heading(level: 1, numbering: none)[ANEXO #upper(letra) -- #upper(titulo)]
}

/// Título de elemento pré-textual (não aparece no sumário)
#let pretextual-title(titulo) = {
  align(center)[
    #text(weight: "bold", size: 12pt, upper(titulo))
  ]
  v(1.5em)
}
