// ============================================================
// src/core.typ
// Configurações globais: página, texto, parágrafo e títulos
// Usar via: #show: configurar.with(...)
// ============================================================

#let configurar(numeracao: "1", pagina-inicial: none, corpo) = {

  set text(font: "Arial", size: 12pt, lang: "pt", region: "BR")

  set page(
    paper: "a4",
    margin: (top: 3cm, left: 3cm, bottom: 2cm, right: 2cm),
    numbering: numeracao,
    number-align: top + right,
  )

  set par(
    leading: 0.8em,
    justify: true,
    first-line-indent: (amount: 1.25cm, all: true),
    spacing: 1.5em,
  )

  if pagina-inicial != none {
    counter(page).update(pagina-inicial)
  }

  set heading(numbering: "1.1")

  show heading: it => {
    // O Typst aplica tamanhos padrão (1.4em, 1.2em...) nos headings
    // independentemente do set text global. Por isso forçamos 12pt aqui.
    let numero = if it.numbering != none {
      counter(heading).display(it.numbering) + h(0.5em)
    } else {
      none
    }

    let conteudo = if it.level == 1 {
      text(font: "Arial", size: 12pt, weight: "bold")[#numero#upper(it.body)]
    } else if it.level == 2 {
      text(font: "Arial", size: 12pt, weight: "bold")[#numero#it.body]
    } else {
      text(font: "Arial", size: 12pt, weight: "regular", style: "italic")[#numero#it.body]
    }

    // Sem recuo no título; 1 linha antes e depois
    v(1em)
    block(width: 100%)[
      #set par(first-line-indent: (amount: 0pt, all: true))
      #conteudo
    ]
    v(1em)
  }

  corpo
}
