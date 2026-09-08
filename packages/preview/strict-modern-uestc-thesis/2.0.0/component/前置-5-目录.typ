#import "../consts.typ": *
#import "../tools/figure-i.typ": *

#let 目录(info: (:)) = [
  #set align(center)

  #set par(leading: above-leading-space()) // 设置条目行距
  #set outline.entry(fill: repeat(text(top-edge: 0em, bottom-edge: -0.3em)[.], gap: 0.1em))

  #show outline.entry.where(level: 1): it => {
    let prefix = if it.prefix() != none {
      strong(it.prefix())
    } else {
      h(-0.5em)
    }
    it.indented(
      prefix,
      [#strong(it.body())
        #box(width: 1fr, it.fill)
        #it.page()],
      gap: 0.5em,
    )
  }

  #show cite: none

  #heading("目 录")
  #outline(title: none, depth: 4, indent: 2em)

  #set page(header: none, footer: none)
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
