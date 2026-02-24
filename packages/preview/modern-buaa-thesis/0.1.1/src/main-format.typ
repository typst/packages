#import "@preview/cuti:0.3.0": show-cn-fakebold

#import "constant.typ": font-size, font-type, no-numbering-section
#import "utils.typ": heading-numbering

#let show-heading(body) = {
  set heading(numbering: heading-numbering, supplement: "节")

  show heading.where(level: 1): it => {
    set text(size: font-size.three, font: font-type.hei, weight: "regular", lang: "cn")
    set align(center)
    set par(leading: 1em, spacing: 1em)

    if no-numbering-section.contains(it.body) {
      it.body
    } else {
      v(0.5em)
      it
      v(0.5em)
    }
  }

  show heading.where(level: 2): it => {
    set text(size: font-size.four, font: font-type.hei, weight: "regular", lang: "cn")
    set par(leading: 1em, spacing: 1em)

    v(0.5em)
    it
    v(0.5em)
  }

  show heading.where(level: 3): it => {
    set text(size: font-size.small-four, font: font-type.hei, weight: "regular", lang: "cn")
    set par(leading: 1em, spacing: 1em)

    v(0.5em)
    it
    v(0.5em)
  }

  body
}

#let show-figure(body) = {
  set figure.caption(separator: "  ")
  show figure.where(kind: image): set figure(supplement: "图")

  show figure.where(kind: table): set figure(supplement: "表")
  show figure.where(kind: table): set figure.caption(position: top)

  show figure.caption: it => {
    show: show-cn-fakebold

    set text(size: font-size.five, font: font-type.sun, weight: "bold", lang: "cn")
    set par(leading: 1em, spacing: 1em)

    if it.supplement == [图] {
      v(6pt)
      it
      v(12pt)
    } else if it.supplement == [表] {
      v(12pt)
      it
      v(6pt)
    } else {
      it
    }
  }

  show table.cell: it => {
    set text(size: font-size.five, font: font-type.sun, lang: "cn")

    v(1pt)
    it
    v(1pt)
  }

  body
}

#let show-equation(body) = {
  show heading.where(level: 1): it => {
    counter(math.equation).update(0)
    it
  }

  set math.equation(supplement: "公式", numbering: n => {
    let numbers = counter(heading).at(here()).slice(0, 1)
    numbering("(1.1)", ..numbers, n)
  })

  body
}

#let show-ref(body) = {
  show ref: it => {
    let el = it.element
    if el != none and el.func() == heading {
      link(el.location(), [#el.supplement #numbering(el.numbering, ..counter(heading).at(el.location())).trim()])
    } else {
      it
    }
  }

  body
}

#let show-main(body) = {
  show: show-cn-fakebold

  show: show-heading
  show: show-figure

  show: show-equation
  show: show-ref

  set par(first-line-indent: (amount: 2em, all: true))

  body
}
