#import "constant.typ": font-size, font-type
#import "utils.typ": heading-numbering

#let leading-footer() = {
  set align(center)
  set text(size: font-size.five, font: font-type.sun, lang: "cn")
  set par(leading: 1em, spacing: 1em)

  context [
    #numbering("I", counter(page).get().at(0))
  ]
}

#let show-header(it) = {
  set text(size: font-size.five, font: font-type.sun, lang: "cn")
  set align(center)
  set par(leading: 1em, spacing: 1em)

  it
}

#let heading-header(show-numbering: true) = context {
  let page-number = here().page()

  let number = counter(heading.where(level: 1)).get()

  let after-ele = query(heading.where(level: 1).after(here()))
  if after-ele.len() != 0 and after-ele.first().location().page() == page-number {
    return [
      #show: show-header

      #if show-numbering {
        heading-numbering((number.at(0) + 1))
      }
      #after-ele.first().body
      #line(length: 100%, stroke: 0.5pt)
    ]
  }

  let before-ele = query(heading.where(level: 1).before(here())).last()
  [
    #show: show-header

    #if show-numbering {
      heading-numbering(..number)
    }
    #before-ele.body
    #line(length: 100%, stroke: 0.5pt)
  ]
}

#let main-header() = context {
  let page-number = here().page()

  if calc.odd(page-number) {
    return [
      #show: show-header

      北京航空航天大学博士学位论文
      #line(length: 100%, stroke: 0.5pt)
    ]
  }

  heading-header()
}

#let append-header() = {
  heading-header(show-numbering: false)
}

#let main-footer() = {
  set align(center)
  set text(size: font-size.five, font: font-type.sun, lang: "cn")
  set par(leading: 1em, spacing: 1em)

  context [
    #numbering("1", counter(page).get().at(0))
  ]
}
