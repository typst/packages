#import "/package/lib.typ": subpar

// 定义计数函数
#let sub-figure-numbering = (super, sub) => numbering("1.1a", counter(heading).get().first(), super, sub)
#let figure-numbering = super => numbering("1.1", counter(heading).get().first(), super)
#let equation-numbering = super => numbering("(1.1)", counter(heading).get().first(), super)
#let algorithm-numbering = super => numbering("1.1", counter(heading).get().first(), super)
#let subpar-grid = subpar.grid.with(
  numbering: figure-numbering,
  numbering-sub-ref: sub-figure-numbering,
)

// 定义子图样式
#let figure-style(doc) = {
  // 设置新章节重新计数
  show heading.where(level: 1): it => {
    counter(math.equation).update(0)
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: raw)).update(0)
    counter(figure.where(kind: "algorithm")).update(0)
    it
  }
  // 设置 figure 计数器
  show figure: set figure(numbering: figure-numbering)
  // 设置 equation 计数器
  show math.equation: set math.equation(numbering: equation-numbering)

  // 设置 figure/table 表格表头
  show figure.where(kind: table): set figure.caption(position: top)
  // 设置 figure/raw 的样式
  show raw.where(block: true): set block(fill: rgb("#f0f0f0"), inset: 1em, radius: .5em, width: 100%)
  // 设置 figure 标题样式
  show figure.caption: c => {
    block(inset: (top: .4em, bottom: .4em))[
      #emph[#c.supplement #context c.counter.display(c.numbering) #h(.3em) #c.body]
    ]
  }
  doc
}
