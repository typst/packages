#import "@preview/cuti:0.3.0": show-cn-fakebold
#import "@preview/subpar:0.2.2"

#import "constant.typ": font-size, font-type
#import "utils.typ": heading-numbering, show-heading-number

#let sub-fig = subpar.grid.with(
  supplement: "图",
  numbering: it => {
    let numbers = counter(heading).at(here()).slice(0, 1)
    numbering("1.1", ..numbers, it)
  },
  numbering-sub-ref: (..nums) => {
    let numbers = counter(heading).at(here()).slice(0, 1)
    numbering("1.1a", ..numbers, ..nums)
  },
  show-sub-caption: (num, it) => {
    set text(size: font-size.five)
    set par(leading: 0.8em)

    it
  },
)

#let show-heading(body) = {
  set heading(numbering: heading-numbering, supplement: "节")

  show heading.where(level: 1): it => {
    set text(size: font-size.three, font: font-type.hei, weight: "regular", lang: "cn")
    set align(center)
    set par(leading: 1em, spacing: 1em)

    context {
      let has-number = show-heading-number.at(it.location())

      v(0.5em)
      if has-number {
        numbering(it.numbering, ..counter(heading).at(it.location())) + "  " + it.body
      } else {
        it.body
      }
      v(0.5em)
    }
  }

  show heading.where(level: 2): it => {
    set text(size: font-size.four, font: font-type.hei, weight: "regular", lang: "cn")
    set par(leading: 1em, spacing: 1em, first-line-indent: 0em)

    context {
      let has-number = show-heading-number.at(it.location())

      v(0.5em)
      if has-number {
        numbering(it.numbering, ..counter(heading).at(it.location())) + "  " + it.body
      } else {
        it.body
      }
      v(0.5em)
    }
  }

  show heading.where(level: 3): it => {
    set text(size: font-size.small-four, font: font-type.hei, weight: "regular", lang: "cn")
    set par(leading: 1em, spacing: 1em, first-line-indent: 0em)

    context {
      let has-number = show-heading-number.at(it.location())

      v(0.5em)
      if has-number {
        numbering(it.numbering, ..counter(heading).at(it.location())) + "  " + it.body
      } else {
        it.body
      }
      v(0.5em)
    }
  }

  body
}

#let show-figure(body) = {
  set figure.caption(separator: "  ")

  show figure.where(kind: image): set figure(supplement: "图", numbering: it => {
    let numbers = counter(heading).at(here()).slice(0, 1)
    numbering("1.1", ..numbers, it)
  })

  show figure.where(kind: table): set figure(supplement: "表", numbering: it => {
    let numbers = counter(heading).at(here()).slice(0, 1)
    numbering("1.1", ..numbers, it)
  })

  show figure.where(kind: "algorithm"): set figure(supplement: "算法", numbering: it => {
    let numbers = counter(heading).at(here()).slice(0, 1)
    numbering("1.1", ..numbers, it)
  })

  show heading.where(level: 1): it => {
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: "algorithm")).update(0)

    it
  }

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
    set par(leading: 1em, spacing: 0.5em)

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
    text(font: font-type.sun, numbering("(1.1)", ..numbers, n))
  })

  body
}

#let show-ref(body) = {
  show ref: it => {
    let el = it.element
    if el != none and el.func() == heading {
      let num = numbering(el.numbering, ..counter(heading).at(el.location()))
      link(el.location(), [#el.supplement #num])
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
