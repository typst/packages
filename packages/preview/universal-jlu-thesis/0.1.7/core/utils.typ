// 清除到偶数页
#let clear-double-page() = {
  pagebreak(to: "odd")
}

// 致谢页面
#let acknowledgements(content) = {
  page[
    #set par(leading: 1.2em)
    
    #align(center)[
      #text(size: 16pt, weight: "bold")[致#h(1em)谢]
    ]
    
    #v(0.5cm)
    
    #text(size: 12pt)[#content]
  ]
}