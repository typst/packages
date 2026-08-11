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
