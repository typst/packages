#import "fonts.typ": *

#let toc-entry-style() = {
  // 自定义目录样式，包含点状填充
  show outline.entry: it => {
    let fill-dots = box(width: 1fr, repeat[.])
    
    if it.level == 1 {
      // 章标题样式（4号宋体）
      text(size: 14pt, font: fonts.song)[
        #it.body
        #fill-dots
        #it.page
      ]
    } else if it.level == 2 {
      // 节标题样式（4号宋体，缩进）
      text(size: 14pt, font: fonts.song)[
        #h(2em)#it.body
        #fill-dots
        #it.page
      ]
    } else if it.level == 3 {
      // 小节标题样式（4号宋体，更多缩进）
      text(size: 14pt, font: fonts.song)[
        #h(4em)#it.body
        #fill-dots
        #it.page
      ]
    } else {
      it
    }
  }
}

#let make-toc() = {
  set page(
    paper: "a4",
    margin: (top: 20mm, bottom: 20mm, left: 30mm, right: 30mm),
    header: context [
      #set text(size: 9pt, font: fonts.song)
      #align(center)[目录]
      #line(length: 100%)
    ],
    footer: context [#align(right)[#text(size: 9pt)[#counter(page).display("I")]]],
    header-ascent: 7mm,
    footer-descent: 18pt,
  )
  
  counter(page).update(3)
  
  [
    // 空2行
    #v(2em)
    
    // 目录标题（3号黑体，居中）
    #align(center)[
      #text(size: 16pt, weight: "bold", font: fonts.hei)[目   录]
    ]
    
    // 目录标题与内容之间的间距
    #v(1.5em)
    
    // 设置行距为18磅
    #set par(leading: 18pt)
    
    #toc-entry-style()
    #outline(
      title: none,
      indent: auto
    )
    
    #pagebreak()
  ]
}