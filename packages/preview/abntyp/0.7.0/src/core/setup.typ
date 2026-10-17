// Configuração unificada ABNT para templates
// Combina página, fonte, espaçamento, listas, headings, indentação e rodapé
// em uma única chamada, eliminando duplicação entre templates.

#import "lists.typ": numeracao-enum
#import "spacing.typ": abnt-leading, abnt-top-edge, abnt-bottom-edge

// Indicativo + título; da 2ª linha em diante o título fica sob a primeira letra do
// título (NBR 6024 4.1 j; NBR 14724 5.2.2). Sem indicativo, só o título. Parágrafo com
// recuo deslocado (e não grid) para manter o vão vertical entre título e texto.
#let _abnt-titulo(it, caixa-alta: false) = {
  let corpo = if caixa-alta { upper(it.body) } else { it.body }
  if it.numbering != none {
    context {
      let indicativo = counter(heading).display()
      let largura = measure(indicativo + h(0.5em)).width
      par(hanging-indent: largura)[#indicativo#h(0.5em)#corpo]
    }
  } else { corpo }
}

// O `heading` nativo é `sticky` (não fica sozinho no pé da página), mas as regras abaixo o
// substituem; este bloco devolve a propriedade. `above`/`below` = espaço entre parágrafos,
// que é o que o título (um parágrafo, em 12 pt) tinha antes de virar bloco: sem isso valeria
// 1,2em, e o `em` do espaço de parágrafo é o do corpo de 12 pt, não o do nível do título.
#let _titulo-sticky(body) = text(size: 12pt, context block(sticky: true, above: par.spacing, below: par.spacing, body))

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
///   (padrão: "Seção" — correto para TCC e artigos (NBR 14724 4.2.2 não admite
///   capítulos); use "Capítulo" para relatórios e livros)
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
    ("Times New Roman", "Times", "Libertinus Serif", "New Computer Modern")
  } else if fonte == "Arial" {
    ("Arial", "Helvetica", "Liberation Sans", "New Computer Modern")
  } else {
    (fonte,)
  }

  set text(
    font: font-stack,
    size: 12pt,
    lang: "pt",
    region: "BR",
    top-edge: abnt-top-edge,
    bottom-edge: abnt-bottom-edge,
  )

  // Parágrafo com espaçamento 1,5 e recuo de 1,25cm
  set par(
    leading: abnt-leading(1.5),
    spacing: abnt-leading(1.5),
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
    // Fraco: some no topo da página (14724 5.2.2). O espaço fraco absorve o espaço
    // entre parágrafos; somá-lo mantém o vão maior que o das seções secundárias.
    context v(1.5em + par.spacing, weak: true)
    // Sem indicativo numérico (referências, apêndices, anexos…): centralizado (14724 5.2.3)
    let titulo = text(weight: "bold", size: 12pt, _abnt-titulo(it, caixa-alta: true))
    _titulo-sticky(if it.numbering == none { align(center, titulo) } else { titulo })
    v(1.5em)
  }

  // Seção secundária (nível 2): MAIÚSCULAS, regular
  show heading.where(level: 2): it => {
    v(1.5em)
    _titulo-sticky(text(weight: "regular", size: 12pt, _abnt-titulo(it, caixa-alta: true)))
    v(1.5em)
  }

  // Seção terciária (nível 3): Minúsculas, negrito
  show heading.where(level: 3): it => {
    v(1.5em)
    _titulo-sticky(text(weight: "bold", size: 12pt, _abnt-titulo(it, caixa-alta: false)))
    v(1.5em)
  }

  // Seção quaternária (nível 4): Minúsculas, regular
  show heading.where(level: 4): it => {
    v(1.5em)
    _titulo-sticky(text(weight: "regular", size: 12pt, _abnt-titulo(it, caixa-alta: false)))
    v(1.5em)
  }

  // Seção quinária (nível 5): Minúsculas, itálico
  show heading.where(level: 5): it => {
    v(1.5em)
    _titulo-sticky(text(weight: "regular", style: "italic", size: 12pt, _abnt-titulo(it, caixa-alta: false)))
    v(1.5em)
  }

  // Links externos (URLs) visíveis como links: sublinhados, e coloridos se pedido.
  // Referências internas, citações e sumário continuam clicáveis sem estilo.
  show link: it => {
    if type(it.dest) == str {
      if cor-links == none { underline(it) } else { underline(text(fill: cor-links, it)) }
    } else { it }
  }

  // @rótulo para título sem numeração (apendice, anexo, titulo-sem-num): o Typst recusa
  // a referência padrão; vira link com o suplemento ("Apêndice A") ou, sem ele, o título.
  show ref: it => {
    let el = it.element
    if el != none and el.func() == heading and el.numbering == none {
      let texto = if it.supplement != auto { it.supplement }
        else if el.supplement not in (auto, none) { el.supplement }
        else { el.body }
      link(el.location(), texto)
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
  set figure.caption(position: top, separator: [ – ])

  // Tabela maior que a página continua na seguinte (IBGE 8.3); o figure não quebra por padrão
  show figure.where(kind: table): set block(breakable: true)

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
  // Da 2ª linha em diante a nota fica sob a primeira letra, destacando o expoente
  // (14724 5.2.1; 10520 cap. 8)
  show footnote.entry: it => context {
    let numero = numbering(it.note.numbering, ..counter(footnote).at(it.note.location()))
    grid(
      columns: (auto, 1fr),
      column-gutter: 0.05em,
      link(it.note.location(), super(numero)),
      it.note.body,
    )
  }

  body
}
