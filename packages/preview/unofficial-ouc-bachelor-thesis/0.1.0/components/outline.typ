#import "@preview/pointless-size:0.1.2": zh
#import "@preview/cuti:0.4.0": fakebold

#let outline() = page({
  set std.outline.entry(fill: repeat(sym.dot))
  show std.outline.entry: it => {
    if it.level == 1 {
      set text(size: zh("四号"))
      link(
        it.element.location(),
        fakebold(it.indented(it.prefix(), it.inner())),
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
    title: "目录".clusters().join(" " * 3),
    indent: 0em,
  )
})
