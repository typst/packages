#import "@preview/cuti:0.3.0": show-cn-fakebold

#import "constant.typ": font-size, font-type, no-numbering-section
#import "utils.typ": distr

#let heading-outline() = {
  show: show-cn-fakebold

  [
    #set text(size: font-size.small-two, font: font-type.hei, weight: "bold", lang: "zh")
    #set par(spacing: 1.25em, leading: 1.25em)
    #set align(center)

    #show par: it => {
      v(2.5pt)
      it
      v(2.5pt)
    }

    #distr("目录", 3em)
  ]

  show outline.entry.where(level: 1): it => {
    set text(size: font-size.small-four, font: font-type.hei)
    set block(spacing: 1.25em)

    v(0.5em)

    if no-numbering-section.contains(it.body()) {
      link(it.element.location(), [
        #it.indented(
          [],
          [#it.body() #box(width: 1fr, repeat([.], gap: 0.1em)) #text(size: font-size.small-four, [#it.page()])],
          gap: 0em,
        )
      ])
    } else {
      link(it.element.location(), [
        #it.indented(
          it.prefix(),
          [#it.body() #box(width: 1fr, repeat([.], gap: 0.1em)) #text(size: font-size.small-four, [#it.page()])],
          gap: 0.2em,
        )
      ])
    }
  }

  show outline.entry.where(level: 2): it => {
    set text(size: font-size.small-four, font: font-type.sun)
    set block(spacing: 1.25em)

    link(it.element.location(), [
      #it.indented(
        it.prefix(),
        [#it.body() #box(width: 1fr, repeat([.], gap: 0.1em)) #text(size: font-size.small-four, [#it.page()])],
        gap: 0.2em,
      )
    ])
  }

  show outline.entry.where(level: 3): it => {
    set text(size: font-size.five, font: font-type.sun)
    set block(spacing: 1.25em)

    link(it.element.location(), [
      #it.indented(
        it.prefix(),
        [#it.body() #box(width: 1fr, repeat([.], gap: 0.1em)) #text(size: font-size.small-four, [#it.page()])],
        gap: 0.2em,
      )
    ])
  }

  outline(title: none, depth: 3, indent: 1em)
}

#let image-outline() = {
  show: show-cn-fakebold

  [
    #set text(size: font-size.three, font: font-type.hei, weight: "bold", lang: "zh")
    #set par(spacing: 1.25em, leading: 1.25em)
    #set align(center)

    #show par: it => {
      v(2.5pt)
      it
      v(2.5pt)
    }

    插图清单
  ]

  show outline.entry.where(level: 1): it => {
    set text(size: font-size.small-four, font: font-type.sun)
    set block(spacing: 1.25em)

    link(it.element.location(), [
      #it.indented(
        it.prefix() + "  ",
        [#it.body() #box(width: 1fr, repeat([.], gap: 0.1em)) #text(size: font-size.small-four, [#it.page()])],
        gap: 0.2em,
      )
    ])
  }

  outline(title: none, target: figure.where(kind: image))
}

#let table-outline() = {
  show: show-cn-fakebold

  [
    #set text(size: font-size.three, font: font-type.hei, weight: "bold", lang: "zh")
    #set par(spacing: 1.25em, leading: 1.25em)
    #set align(center)

    #show par: it => {
      v(2.5pt)
      it
      v(2.5pt)
    }

    附表清单
  ]

  show outline.entry.where(level: 1): it => {
    set text(size: font-size.small-four, font: font-type.sun)
    set block(spacing: 1.25em)

    link(it.element.location(), [
      #it.indented(
        it.prefix() + "  ",
        [#it.body() #box(width: 1fr, repeat([.], gap: 0.1em)) #text(size: font-size.small-four, [#it.page()])],
        gap: 0.2em,
      )
    ])
  }

  outline(title: none, target: figure.where(kind: table))
}
