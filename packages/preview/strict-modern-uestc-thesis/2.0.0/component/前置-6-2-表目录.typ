// https://github.com/typst/typst/discussions/4515
#import "../consts.typ": *
#import "../tools/figure-i.typ": *

#let 表目录(info: (:)) = [
  #set outline.entry(fill: repeat(text(top-edge: 0em, bottom-edge: -0.3em)[.], gap: 0.1em))

  #show outline.entry: it => {
    // 定义空隙宽度，方便统一调整
    // let gap = 1.5em

    let min-box(min-width: 0pt, body) = context {
      let size = measure(body)
      let size_abs = measure(h(min-width))
      let final-width = calc.max(size_abs.width, size.width)
      box(width: final-width, body)
    }
    let num-total = counter(it.element.kind + "total").get().first()
    counter(it.element.kind + "total").step()
    let head-num = counter(heading).at(it.element.location()).first()
    let element-num = counter(it.element.kind + str(head-num)).at(it.element.location()).first()
    if num-total != 0 and element-num == 0 {
      v(12pt)
    }

    link(it.element.location())[
      #grid(
        // columns: (auto, 1fr, gap),
        columns: (auto, 1fr),
        // stroke: 0.5pt,
        gutter: 0pt,
        // 关键：左右栏必须紧贴，物理间隙为0
        min-box(min-width: 3.5em)[#it.prefix()],
        [#set par(justify: true)
          #it.body()
          #box(width: 1fr)[
            #set text(top-edge: 0em, bottom-edge: -0.25em)
            #it.fill
          ]
          #it.page()
        ],
      )
    ]
  }
  #show cite: none
  #outline(
    title: "表格清单",
    target: figure.where(kind: figure-kind-tbl),
    indent: 2em,
  )
  #pagebreak(weak: true)
  #set page(header: none, footer: none)
  #if info.at(info-keys.论文模式) == 论文模式.打印模式 {
    context {
      let current-page = here().page()
      if calc.even(current-page) {
        counter(page).update(n => n - 1)
      }
    }
    pagebreak(weak: true, to: "odd")
  }
]
