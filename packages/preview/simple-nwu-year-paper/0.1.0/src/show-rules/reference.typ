
#let show-ref = it => context {
  let el = it.element
  if el == none { return it }

  let eq = math.equation
  let hl = heading

  if el.func() == eq {
    // 1. 数学公式引用：格式 "(2.1)"
    if el.numbering != none {
      let current-count = counter(eq).at(el.location())
      link(
        el.location(),
        numbering(el.numbering, ..current-count),
      )
    } else { it }
  } else if el.func() == hl {
    // 2. 标题章节引用
    if el.numbering != none {
      let current-count = counter(heading).at(el.location())

      if el.level == 1 {
        link(
          el.location(),
          [第 ] + numbering(el.numbering, ..current-count) + [ 章],
        )
      } else {
        link(
          el.location(),
          [第 ] + numbering(el.numbering, ..current-count) + [ 节],
        )
      }
    } else { it }
  } else if el.func() == figure {
    // 3. 图表引用
    if el.numbering != none {
      let current-count = counter(figure).at(el.location())
      if el.kind == image {
        link(el.location(), [图 ] + numbering(el.numbering, ..current-count))
      } else if el.kind == table {
        link(el.location(), [表 ] + numbering(el.numbering, ..current-count))
      } else { it }
    } else { it }
  } else {
    it
  }
}
