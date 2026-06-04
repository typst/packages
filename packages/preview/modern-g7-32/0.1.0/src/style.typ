#import "component/headings.typ": headings,  structural-heading-titles
#import "component/annexes.typ": is-heading-in-annex

#let gost-style(year: none, city: "", hide-title: false, text-size: 14pt, small-text-size: 10pt, indent: 1.25cm, body) = {
  if small-text-size == none { small-text-size = text-size - 4pt }
  [#metadata(small-text-size) <small-text-size>]

  set page(
    margin: (left: 30mm, right: 15mm, top: 20mm, bottom: 20mm)
  )

  set text(
    size: text-size,
    lang: "ru",
    hyphenate: false
  )

  set par(
    justify: true,
    first-line-indent: (
      amount: indent,
      all: true,
    ),
    spacing: 1.5em
  )

  set outline(indent: indent, depth: 3)
  show outline: set block(below: indent / 2)
  show outline.entry: it => {
    show linebreak: [ ]
    if is-heading-in-annex(it.element) {
      let body = it.element.body
      link(
        it.element.location(),
        it.indented(
          none,
          [Приложение #it.prefix() #it.element.body] + sym.space + box(width: 1fr, it.fill) + sym.space + sym.wj + it.page()
        )
      )
    } else {
      it
    }
  }

  set ref(supplement: none)
  set figure.caption(separator: " — ")

  set math.equation(numbering: "(1)")

  show figure: pad.with(bottom: 0.5em)

  show image: set align(center)
  show figure.where(kind: image): set figure(supplement: [Рисунок])

  show figure.where(
    kind: table
  ): it => {
    set block(breakable: true)
    set figure.caption(position: top)
    it
  }
  show figure.caption.where(kind: table): set align(left)
  show table.cell: set align(left)
  // TODO: Расположить table.header по центру и сделать шрифт жирным

  set list(marker: [–], indent: indent, spacing: 1em)
  set enum(indent: indent, spacing: 1em)
  
  set page(footer: context [
    #let page = here().page()
    #align(center)[#{
      if page == 1 {
        if hide-title {page} else {[#city #year]}
      } 
      else {page}
    }]
  ])

  set bibliography(style: "gost-r-705-2008-numeric", title: structural-heading-titles.references)
  
  show: headings(text-size, indent)
  body
}
