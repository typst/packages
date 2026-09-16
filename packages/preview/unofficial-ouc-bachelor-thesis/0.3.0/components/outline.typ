#import "@preview/pointless-size:0.1.2": zh

#let outline() = page({
  set std.outline.entry(fill: repeat(sym.dot))
  show std.outline.entry: it => {
    if it.level == 1 {
      set text(size: zh("四号"))
      link(
        it.element.location(),
        strong(it.indented(it.prefix(), if it.element.at("numbering", default: none) != none [#it.element.body] else {
          it.inner()
        })),
      )
    } else {
      set text(size: zh("小四"))
      link(
        it.element.location(),
        it.indented(it.prefix(), it.inner()),
      )
    }
  }
  std.outline(
    title: "目录".clusters().join(h(.5em * 3)),
    indent: 0em,
  )
})
