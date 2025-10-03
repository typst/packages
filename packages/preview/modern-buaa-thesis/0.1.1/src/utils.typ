#import "@preview/subpar:0.2.2"
#import "constant.typ": font-size

#let distr(s, w) = {
  box(width: w, stack(dir: ltr, ..s.clusters().map(x => [#x]).intersperse(1fr)))
}

#let reset-page() = {
  counter(page).update(1)
}

#let heading-numbering(..num) = {
  if num.pos().len() == 1 {
    return "第" + numbering("一", ..num) + "章  "
  }

  if num.pos().len() == 2 {
    return numbering("1.1", ..num) + "  "
  }

  if num.pos().len() == 3 {
    return numbering("1.1.1", ..num) + "  "
  }
}

#let sub-fig = subpar.grid.with(supplement: "图", show-sub-caption: (num, it) => {
  set text(size: font-size.five)
  set par(leading: 0.8em)

  it
})
