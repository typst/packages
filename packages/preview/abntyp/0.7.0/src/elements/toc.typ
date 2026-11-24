// Sumário conforme NBR 6027:2012

#import "../core/page.typ": abre-anverso
#import "../core/spacing.typ": abnt-leading
#import "../core/sorting.typ": sort-key

// Show rules para formatar entradas do sumário conforme NBR 6027/6024.
// Compartilhado entre abnt-outline() e sumario().
// Indicativos alinhados à esquerda; os títulos (inclusive os sem indicativo, como
// REFERÊNCIAS) começam todos na margem do título do indicativo mais extenso (6027 5.1 e 5.2).
// `profundidade`: só os indicativos até esse nível entram no cálculo da coluna.
#let _abnt-outline-rules(body, profundidade: none) = context {
  let indicativos = query(heading).filter(t => (
    t.numbering != none and (profundidade == none or t.level <= profundidade)
  ))
  let largura = calc.max(0pt, ..indicativos.map(t => measure(text(weight: "bold")[
    #numbering(t.numbering, ..counter(heading).at(t.location()))#h(0.5em)
  ]).width))

  // Entradas em espaço simples (a 6027 não pede 1,5); sumário longo não transborda
  set par(leading: abnt-leading(1), spacing: abnt-leading(1))

  show outline.entry: it => {
    let el = it.element
    if el.func() == figure {
      // Parte: "Parte 1: Título", sem coluna de indicativo
      v(0.5em)
      block(link(el.location())[
        #text(weight: "bold")[#it.prefix():#h(0.5em)#upper(it.body())]
        #box(width: 1fr, it.fill)
        #it.page()
      ])
    } else {
      // Nível 1: MAIÚSCULAS + negrito; 2: MAIÚSCULAS; 3: negrito; 4: regular; 5: itálico
      let n = it.level
      let estilo(x) = text(
        weight: if n in (1, 3) { "bold" } else { "regular" },
        style: if n == 5 { "italic" } else { "normal" },
        x,
      )
      if n == 1 { v(0.5em) }
      block(link(el.location(), grid(
        columns: (largura, 1fr),
        estilo(it.prefix()),
        [
          #estilo(if n in (1, 2) { upper(it.body()) } else { it.body() })
          #box(width: 1fr, it.fill)
          #it.page()
        ],
      )))
    }
  }

  body
}

// Legenda das listas (ilustrações, tabelas, quadros): "Figura 1 – Título ..... página"
// (NBR 14724 5.8: número de ordem, travessão e título).
#let _abnt-lista-rules(body) = {
  show outline.entry: it => it.indented([#it.prefix() –], it.inner())
  body
}

/// Configura sumário conforme ABNT
/// - Título "SUMARIO" centralizado, negrito
/// - Indicativos de seção alinhados à esquerda
/// - Entradas espelham a formatação dos headings (NBR 6027/6024)
/// - Páginas ligadas por linha pontilhada
#let abnt-outline() = {
  abre-anverso()

  // Título
  align(center)[
    #text(weight: "bold", size: 12pt, "SUMÁRIO")
  ]

  v(1.5em)

  show: _abnt-outline-rules

  outline(
    title: none,
    target: selector(heading).or(figure.where(kind: "parte")),
    indent: 0pt,
  )
}

/// Sumário customizado com mais controle
#let sumario(
  titulo: "SUMÁRIO",
  profundidade: 3,
) = {
  abre-anverso()

  align(center)[
    #text(weight: "bold", size: 12pt, titulo)
  ]

  v(1.5em)

  show: _abnt-outline-rules.with(profundidade: profundidade)

  outline(
    title: none,
    target: selector(heading).or(figure.where(kind: "parte")),
    depth: profundidade,
    indent: 0pt,
  )

  pagebreak()
}

/// Lista de ilustrações
/// - tipo: tipo (kind) das ilustrações listadas; padrão `image` (figuras). Aceita o
///   tipo de um `container(tipo: ...)` ou uma lista deles. A NBR 14724 4.2.1.9 pede
///   uma lista própria para cada tipo (gráficos, fotografias, mapas…):
///   `#lista-ilustracoes(tipo: "grafico", titulo: "LISTA DE GRÁFICOS")`
/// - titulo: título da lista
#let lista-ilustracoes(tipo: image, titulo: "LISTA DE ILUSTRAÇÕES") = {
  let tipos = if type(tipo) == array { tipo } else { (tipo,) }
  let alvo = tipos
    .map(k => selector(figure.where(kind: if k == "imagem" { image } else if k == "tabela" { table } else { k })))
    .reduce((a, b) => a.or(b))

  // Lista sem itens não sai (4.2.1.9: a lista é opcional)
  context if query(alvo).len() > 0 {
    abre-anverso()

    align(center)[
      #text(weight: "bold", size: 12pt, titulo)
    ]

    v(1.5em)

    show: _abnt-lista-rules
    outline(
      title: none,
      target: alvo,
    )

    pagebreak()
  }
}

/// Lista de tabelas
#let lista-tabelas() = {
  let alvo = figure.where(kind: table)

  // Lista sem itens não sai
  context if query(alvo).len() > 0 {
    abre-anverso()

    align(center)[
      #text(weight: "bold", size: 12pt, "LISTA DE TABELAS")
    ]

    v(1.5em)

    show: _abnt-lista-rules
    outline(
      title: none,
      target: alvo,
    )

    pagebreak()
  }
}

/// Lista de quadros
#let lista-quadros() = {
  let alvo = figure.where(kind: "quadro")

  // Lista sem itens não sai
  context if query(alvo).len() > 0 {
    abre-anverso()

    align(center)[
      #text(weight: "bold", size: 12pt, "LISTA DE QUADROS")
    ]

    v(1.5em)

    show: _abnt-lista-rules
    outline(
      title: none,
      target: alvo,
    )

    pagebreak()
  }
}

/// Lista de abreviaturas e siglas
/// - itens: dicionário de sigla -> significado (impresso em ordem alfabética, NBR 14724 4.2.1.11);
///   sem itens, a lista não sai
/// - titulo: título da lista. A norma recomenda uma lista própria para cada tipo
///   (NBR 14724 4.2.1.7): `#lista-siglas(titulo: "LISTA DE SIGLAS", (...))` e
///   `#lista-siglas(titulo: "LISTA DE ABREVIATURAS", (...))`
#let lista-siglas(itens, titulo: "LISTA DE ABREVIATURAS E SIGLAS") = {
  if itens.len() == 0 { return }

  abre-anverso()

  align(center)[
    #text(weight: "bold", size: 12pt, titulo)
  ]

  v(1.5em)

  set par(first-line-indent: 0pt)

  for (sigla, significado) in itens.pairs().sorted(key: p => sort-key(p.at(0), ignore-articles: false)) {
    [#sigla #h(1em) #significado \ ]
  }

  pagebreak()
}

/// Lista de símbolos
/// - itens: dicionário de símbolo -> significado
#let lista-simbolos(itens) = {
  if itens.len() == 0 { return }

  abre-anverso()

  align(center)[
    #text(weight: "bold", size: 12pt, "LISTA DE SÍMBOLOS")
  ]

  v(1.5em)

  set par(first-line-indent: 0pt)

  for (simbolo, significado) in itens {
    [#simbolo #h(1em) #significado \ ]
  }

  pagebreak()
}

// Aliases curtos
#let siglas = lista-siglas
#let simbolos = lista-simbolos
