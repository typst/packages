// Renderização de títulos e sumário.

#import "settings.typ": settings
#import "layout.typ": blank-page, place-node

// Páginas de capítulo ou unidade (nível 1).
#let section-emblem-size = 7cm
#let section-emblem-overhang = 10pt
#let section-emblem-font = 120pt
#let section-emblem-stroke = 3pt
#let section-border = 0.75pt
#let section-title-scale = 3.5
#let section-lead = 3 // em passos da grade
#let section-title-space = 2 // passos em branco abaixo do título

// Espaçamento dos subtítulos, em passos da grade.
#let h2-gap = (above: 4, below: 3)
#let h3-gap = (above: 3, below: 2)

#let outline-rule = 0.25pt

// Texto desenhado duas vezes na cor da página — primeiro contornado, depois
// preenchido — para formar um glifo com borda interna espessa.
#let outlined-text(body, stroke: luma(180), ..args) = context {
  let page = settings.get().theme.page
  box(
    place(text(body, stroke: stroke, fill: page, ..args))
      + text(body, stroke: none, fill: page, ..args),
  )
}

// Página divisória que abre um capítulo.
#let section-page(title, symbol, margin, texts) = context {
  let s = settings.get()
  let step = texts.step
  blank-page(weak: true)

  let emblem = box(
    width: section-emblem-size,
    height: section-emblem-size,
    stroke: section-border + s.theme.line,
    fill: s.theme.page,
    align(
      center + horizon,
      outlined-text(
        font: s.fonts.sans,
        size: section-emblem-font,
        stroke: section-emblem-stroke + s.theme.line,
        [#symbol],
      ),
    ),
  )
  place(
    top + left,
    dx: -margin.e - section-emblem-overhang,
    dy: -margin.t - step - section-emblem-overhang,
    emblem,
  )

  v(step * section-lead * 4)
  set par(leading: step * section-lead, justify: false)
  set block(
    above: step * section-lead,
    below: step * section-title-space,
    breakable: false,
  )
  text(
    size: texts.size * section-title-scale,
    font: s.fonts.sans,
    align(right, title),
  )
  v(step * section-lead)
}

#let contents-icon = "<?xml version=\"1.0\" encoding=\"utf-8\"?><svg width=\"800px\" height=\"800px\" viewBox=\"0 0 24 24\" fill=\"none\" xmlns=\"http://www.w3.org/2000/svg\"><path d=\"M4 6H20M4 12H14M4 18H9\" stroke=\"#eaeaea\" stroke-width=\"2\" stroke-linecap=\"square\"/></svg>"

// Entrada do sumário com título clicável, linha-guia e número da página.
#let outline-entry(it, step) = {
  let location = it.element.location()
  let numbers = counter(heading).at(location)
  let title = {
    show linebreak: ""
    it.element.body
  }
  let label = if it.level == 1 {
    [#numbering("1", ..numbers) #title]
  } else {
    [#numbering("1.1.1", ..numbers) #title]
  }

  let entry = link(location, label)
  if it.fill != none {
    entry += [ ] + box(width: 1fr, it.fill) + [ ]
  } else {
    entry += h(1fr)
  }
  entry += link(location, it.page())

  block(
    if it.level == 1 {
      v(step) + strong(entry)
    } else {
      h(1.5em * (it.level - 2)) + entry
    },
  )
}

// Aplicado por `init` através de `show: heading-rules`.
#let heading-rules(it) = context {
  let (margin, fonts, texts, headings, theme) = settings.get()
  let step = texts.step

  // Os títulos usam fonte sem serifa.
  show heading: it => {
    set text(font: fonts.sans)
    it
  }

  // O nível 1 abre o capítulo em uma página divisória própria.
  show heading.where(level: 1): it => context {
    let number = counter(heading).at(here()).at(0)
    section-page(
      [#text(weight: "light")[Capítulo #number]\ #text(weight: "extrabold", it)],
      number,
      margin,
      texts,
    )
  }

  // Nível 2: marcador na margem, seguido pelo título.
  show heading.where(level: 2): it => {
    set text(size: texts.size * headings.h2.size)
    set block(
      above: step * h2-gap.above,
      below: step * h2-gap.below,
      breakable: false,
    )
    set par(leading: step, justify: false)
    block(breakable: false)[#place-node(
        $#headings.h2.sym$,
        dy: headings.h2.dy,
      ) #h(2pt)#box(it)]
  }

  // Nível 3: mesmo estilo, com espaçamento mais compacto.
  show heading.where(level: 3): it => {
    set text(size: texts.size * headings.h3.size)
    set block(
      above: step * h3-gap.above,
      below: step * h3-gap.below,
      breakable: false,
    )
    set par(leading: step, justify: false)
    block(breakable: false)[#place-node(
        $#headings.h3.sym$,
        dy: headings.h3.dy,
      ) #it]
  }

  // O sumário recebe sua própria página divisória.
  show outline: it => {
    show heading: _ => section-page(
      [Sumário],
      image(bytes(contents-icon), format: "svg", width: 60%),
      margin,
      texts,
    )
    it
  }

  set outline.entry(fill: line(length: 100%, stroke: outline-rule + theme.line))
  show outline.entry: it => outline-entry(it, step)

  it
}
