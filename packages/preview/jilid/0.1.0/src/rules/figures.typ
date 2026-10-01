#import "@preview/zebraw:0.6.3": zebraw
#import "../state.typ": section, sections

// the number of the `n`-th item at `loc`.
// "2.3" in a chapter, "3" in front matter.
// `render-appendices` numbers appendix items.
#let figure-number(loc, n) = {
  let chapter = counter(heading).at(loc).first()
  if section.at(loc) == sections.main [#chapter.#n] else [#n]
}

// figures, captions, equations and code blocks.
#let figure-rules(cfg, body) = {
  set figure(gap: cfg.typography.caption-gap, placement: none)

  let default-caption(it) = [*#it.supplement #it.number:* #it.body]
  let render-caption = if cfg.typography.caption == auto {
    default-caption
  } else { cfg.typography.caption }
  show figure.caption: it => text(
    size: cfg.typography.caption-size,
    render-caption((
      supplement: it.supplement,
      number: context it.counter.display(it.numbering),
      body: it.body,
      kind: it.kind,
    )),
  )

  let number(n) = context figure-number(here(), n)

  set figure(numbering: number)

  set math.equation(
    numbering: n => [(#number(n))],
    supplement: cfg.t.equation,
    block: true,
  )
  show math.equation.where(block: true): set block(above: 1.5em, below: 2.5em)

  show figure.where(kind: image): set figure(supplement: cfg.t.figure)
  show figure.where(kind: table): set figure(supplement: cfg.t.table)
  show figure.where(kind: raw): set figure(supplement: cfg.t.code)

  show figure.where(kind: table): it => {
    set figure.caption(position: top)
    set align(center)
    it
  }
  show figure.where(kind: raw): it => {
    set figure.caption(position: top)
    set align(left)
    it
  }
  show figure.where(kind: image): it => {
    set align(center)
    it
  }

  let z = cfg.code.zebraw
  show: it => if z == false {
    show raw.where(block: true): r => block(
      fill: cfg.code.fill,
      inset: 8pt,
      radius: 3pt,
      width: 100%,
      r,
    )
    it
  } else {
    let options = if type(z) == dictionary { z } else { (:) }
    zebraw(background-color: cfg.code.fill, ..options, it)
  }
  let code-font = if cfg.code.font == auto { (:) } else {
    (font: cfg.code.font)
  }
  show raw: set text(..code-font, size: cfg.code.size)

  body
}
