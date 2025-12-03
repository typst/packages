#import "@preview/cuti:0.4.0": show-cn-fakebold
#import "@preview/pointless-size:0.1.2": zh

#import "/src/fonts.typ": *
#import "/src/utils.typ": three-line-table


#let body-style(body) = {
  show table: three-line-table

  counter(page).update(1)
  set page(numbering: "第1页")
  // typst 与 word 定义行距方式并不相同，这里靠目押:(
  set par(leading: 1.02em, spacing: 1.02em)

  set text(font: songti, size: zh(4.5))

  show emph: set text(font: kaiti)
  show raw: set text(font: code, size: zh(5))
  show raw.where(block: true): set block(
    width: 100%,
    fill: luma(245),
    inset: 10pt,
    radius: 4pt,
    stroke: luma(200) + 0.5pt,
  )

  set heading(numbering: "1.1")
  show heading: set block(above: 1.7em, below: 1.7em) // 接近word的一倍行距
  show heading: set text(font: heiti)
  show heading: it => block({
    if it.numbering != none {
      counter(heading).display(it.numbering)
      h(1em) // 在word上空1格默认0.5字符，所以2格对应1个字符（2个字符似乎不太美观?）
    }
    it.body
  })
  show heading.where(level: 1): set align(center)
  show heading.where(level: 1): set text(size: zh(3))
  show heading.where(level: 2): set text(size: zh(4))
  show heading.where(level: 3): set text(size: zh(4.5))
  show heading.where(level: 4): set text(size: zh(5))
  show heading.where(level: 5): set text(size: zh(5))

  // 有序列表设置编号的方式比较 tricky
  // ref: https://forum.typst.app/t/how-to-customize-numbering-for-nested-enum-items/3881/3
  set enum(
    indent: 2em,
    full: true,
    numbering: (..n) => {
      n = n.pos()
      let level = n.len()
      let number = ("(1)", "①").at(level - 1, default: "1.")
      numbering(number, ..n.slice(level - 1))
    },
  )
  // typst嵌套会继承父类的缩进，所以无需再缩进
  show enum: it => {
    set list(indent: 0em)
    set enum(indent: 0em)
    it
  }
  set list(indent: 2em, marker: ([●], [○], [■]))
  show list: it => {
    set list(indent: 0em)
    set enum(indent: 0em)
    it
  }

  show figure.where(kind: table): set figure.caption(position: top)
  set table(inset: (y: 0.5em))

  set math.equation(numbering: "(1)")
  show math.equation.where(block: true): set block(breakable: true)
  // 只有带标签的才会编号，带编号的会顶格
  // ref: https://forum.typst.app/t/how-to-conditionally-enable-equation-numbering-for-labeled-equations/977/14
  show math.equation.where(block: true): it => {
    if not it.has("label") [
      #counter(math.equation).update(v => v - 1)
      #math.equation(it.body, block: true, numbering: none)#label("_")
    ] else if it.numbering != none {
      set align(left)
      it
    } else {
      it
    }
  }

  set footnote(numbering: "①")
  show footnote.entry: set text(font: songti, size: zh(5.5))

  // 当标题在一页的开始时，word和typst都会去掉标题上方的space
  // 但是word不会去掉第一页的space，所以这里加上
  v(0.8em)
  body
}
