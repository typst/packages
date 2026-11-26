// Elementos de layout e acabamento de página que leem o estado resolvido.

#import "settings.typ": settings
#import "@preview/hydra:0.6.3": hydra

// Usa o último título da página como cabeçalho corrente.
#let hydra = hydra.with(use-last: true)

// Avança o cursor pela quantidade indicada de passos da grade de linhas.
#let v-step(count) = context {
  let s = settings.get()
  v(count * (s.texts.step + s.texts.ascender))
}

// Posiciona `it` alinhado à direita na margem externa. `dx` e `dy` deslocam o
// elemento; os demais argumentos são encaminhados à caixa que o envolve.
#let place-side(it, dx: 0pt, dy: 0pt, ..box-args) = context {
  let s = settings.get()
  let half-gutter = s.side.half-gutter
  set par(justify: false)
  place(
    dx: -s.side.width - half-gutter + dx,
    dy: dy,
    box(
      width: s.side.width,
      inset: (left: half-gutter, right: half-gutter),
      outset: (
        top: half-gutter + s.texts.ascender,
        bottom: half-gutter,
      ),
      ..box-args,
      align(right, it),
    ),
  )
}

// Centraliza um símbolo pequeno (por exemplo, um marcador de título) na margem.
#let place-node(sym, dy: 0pt) = context {
  let s = settings.get()
  place-side(sym, dx: s.side.half-gutter + measure(sym).width / 2, dy: dy)
}

// Texto em uma grade de linhas proporcionalmente menor.
#let small(it, scale: 2 / 3, size: 0.75em) = context {
  let s = settings.get()
  set par(leading: s.texts.step * scale)
  text(size, it)
}

// Margens da página: o topo recebe um passo extra para alinhar a primeira linha
// à grade.
#let paper-margin(margin, texts) = (
  top: margin.t + texts.step,
  left: margin.e,
  right: margin.s,
  bottom: margin.f,
)

// Fundo: linha fina entre o texto e as notas laterais, interrompida junto ao
// número da página.
#let page-background(paper, margin, side, fonts, theme) = {
  let rule-dx = margin.e - side.half-gutter
  place(
    top + left,
    dx: rule-dx,
    dy: 0pt,
    line(start: (0%, 0%), end: (0%, 100%), stroke: 0.75pt + theme.line),
  )
  place(
    bottom + center,
    dx: -paper.width / 2 + rule-dx,
    dy: -margin.f * (2 / 3),
    box(
      fill: theme.page,
      outset: (top: side.half-gutter, bottom: side.half-gutter),
      text(font: fonts.sans, fill: theme.line)[#h(2em)],
    ),
  )
}

// Rodapé: número da página sob o texto e título da matéria na borda externa.
#let page-footer(body, margin, side, fonts, theme) = context {
  let dy = -margin.f * (2 / 3)

  let page-number = text(font: fonts.sans, fill: theme.line)[
    #text(fill: theme.strong)[#counter(page).get().at(0)]
  ]
  place(bottom + center, dx: -body.width / 2 - side.half-gutter, dy: dy, page-number)

  let section-title = {
    show linebreak: ""
    text(font: fonts.sans, fill: theme.faint, hydra(1))
  }
  place(bottom + left, dx: -side.half-gutter + 2em, dy: dy, section-title)
}

// Nota lateral na posição atual, dentro da margem externa.
#let sidenote(it, dy: 0pt) = context {
  let s = settings.get()
  let dx = -here().position().x + s.margin.e
  let baseline-offset = s.texts.ascender * (2 / 3)
  sym.wj
  box(place-side(small(it), dx: dx, dy: dy - baseline-offset))
  h(0pt, weak: true)
}

// Página que contém apenas uma nota centralizada e discreta.
#let blank-page(..args) = context {
  let s = settings.get()
  set page(
    background: {
      v(2fr)
      align(
        center,
        text(font: s.fonts.sans, fill: s.theme.muted)[Esta página foi deixada intencionalmente em branco.],
      )
      v(3fr)
    },
    footer: none,
    header: none,
  )
  pagebreak(..args)
}
