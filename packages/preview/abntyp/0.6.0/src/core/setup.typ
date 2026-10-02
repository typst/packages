// Configuração unificada ABNT para templates
// Combina página, fonte, espaçamento, listas, headings, indentação e rodapé
// em uma única chamada, eliminando duplicação entre templates.

#import "lists.typ": numeracao-enum

/// Aplica toda a configuração padrão ABNT ao documento.
///
/// Esta função reúne as regras comuns a todos os templates ABNT:
/// - Página A4 com margens 3cm/2cm
/// - Fonte (Times New Roman ou Arial), 12pt, português
/// - Parágrafos com espaçamento 1,5 e recuo de 1,25cm
/// - Listas com recuo de 2em
/// - Headings de 5 níveis conforme NBR 6024:2012
/// - Exclusão de indentação em headings, figuras, código, outline e termos
/// - Notas de rodapé com filete de 5cm
///
/// Parâmetros:
/// - fonte: família da fonte ("Times New Roman" ou "Arial")
/// - headings-numeracao: numeração dos headings (padrão: "1.1")
/// - level-1-pagebreak: se true, headings de nível 1 causam pagebreak (padrão: true)
/// - level-1-pagebreak-impar: se true, o pagebreak de nível 1 vai para página
///   ímpar (impressão frente-verso, NBR 14724)
/// - cor-links: cor dos links externos (URLs). Padrão `none`: texto preto
///   sublinhado (a NBR 14724 pede texto preto); use por exemplo `blue` para colorir
/// - enumeracao: "abnt" (padrão: alíneas a), b), c); subalíneas com travessão) ou
///   "latex" (1., a), i), A.)
/// - suplemento-nivel1: texto usado em referências cruzadas para headings de nível 1
///   (padrão: "Seção" — correto para artigos; use "Capítulo" para TCC, relatórios e livros)
#let with-abnt-setup(
  fonte: "Times New Roman",
  headings-numeracao: "1.1",
  level-1-pagebreak: true,
  level-1-pagebreak-impar: false,
  cor-links: none,
  enumeracao: "abnt",
  suplemento-nivel1: "Seção",
  body,
) = {
  // Página A4 com margens ABNT
  set page(
    paper: "a4",
    margin: (
      top: 3cm,
      bottom: 2cm,
      left: 3cm,
      right: 2cm,
    ),
  )

  // Fonte padrão ABNT — com fallbacks para Mac, Windows, Linux e Typst.app.
  // "New Computer Modern" é embutida no compilador Typst e funciona em qualquer ambiente.
  let font-stack = if fonte == "Times New Roman" {
    ("Times New Roman", "Times", "Linux Libertine", "New Computer Modern")
  } else if fonte == "Arial" {
    ("Arial", "Helvetica", "Liberation Sans", "Linux Biolinum", "Noto Sans")
  } else {
    (fonte,)
  }

  set text(
    font: font-stack,
    size: 12pt,
    lang: "pt",
    region: "BR",
  )

  // Parágrafo com espaçamento 1,5 e recuo de 1,25cm
  set par(
    leading: 1.5em * 0.65,
    justify: true,
    first-line-indent: (amount: 1.25cm, all: true),
  )

  // Listas e termos
  set list(indent: 2em, body-indent: 0.5em)
  // Listas numeradas (NBR 6024): alíneas a), b), c) e subalíneas com travessão
  // ("abnt", padrão) ou 1., a), i), A. ("latex"). Outra numeração:
  // #set enum(numbering: "1.", full: false)
  set enum(indent: 2em, body-indent: 0.5em, full: true, numbering: numeracao-enum(enumeracao))
  set terms(indent: 0em, hanging-indent: 2em, separator: [: ])

  // Headings conforme NBR 6024:2012
  set heading(numbering: headings-numeracao)
  show heading: set heading(supplement: "Seção")
  show heading.where(level: 1): set heading(supplement: suplemento-nivel1)

  // Seção primária (nível 1): MAIÚSCULAS, negrito
  show heading.where(level: 1): it => {
    if level-1-pagebreak {
      if level-1-pagebreak-impar { pagebreak(weak: true, to: "odd") } else { pagebreak(weak: true) }
    }
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

  // Seção secundária (nível 2): MAIÚSCULAS, regular
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

  // Seção terciária (nível 3): Minúsculas, negrito
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

  // Seção quaternária (nível 4): Minúsculas, regular
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

  // Seção quinária (nível 5): Minúsculas, itálico
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

  // Links externos (URLs) visíveis como links: sublinhados, e coloridos se pedido.
  // Referências internas, citações e sumário continuam clicáveis sem estilo.
  show link: it => {
    if type(it.dest) == str {
      if cor-links == none { underline(it) } else { underline(text(fill: cor-links, it)) }
    } else { it }
  }

  // Parte (ver `parte()` em headings.typ): página própria, "Parte N: Título"
  show figure.where(kind: "parte"): it => {
    if level-1-pagebreak-impar { pagebreak(weak: true, to: "odd") } else { pagebreak(weak: true) }
    v(1fr)
    align(center, text(size: 16pt, weight: "bold", upper(it.supplement + [ ] + it.counter.display("1") + [: ] + it.caption.body)))
    v(1fr)
    pagebreak()
  }

  // Legenda (identificação) sempre acima de ilustrações e tabelas (NBR 14724)
  set figure.caption(position: top)

  // Exclusão de indentação em containers que não devem ser indentados
  show heading: set par(first-line-indent: 0pt)
  show figure: set par(first-line-indent: 0pt)
  show raw.where(block: true): set par(first-line-indent: 0pt)
  show outline: set par(first-line-indent: 0pt)
  show terms: set par(first-line-indent: 0pt)

  // Notas de rodapé com filete de 5cm
  set footnote.entry(
    separator: line(length: 5cm, stroke: 0.5pt),
  )

  body
}
