#import "fonts.typ": *

// 修改为接收 bibliography 对象而不是文件路径
#let bibliography-page(bibliography) = {
  // 参考文献另起页码
  pagebreak()
  
  // 设置参考文献页面的页面格式
  set page(
    margin: (top: 20mm, bottom: 20mm, left: 30mm, right: 30mm),
    header: context [
      #set text(size: 9pt, font: fonts.song)
      #align(center)[参考文献]
      #line(length: 100%)
    ],
    header-ascent: 7mm,
    footer-descent: 18pt,
  )
  
  // 空2行（通过v函数实现）
  v(2em)
  
  // 参考文献标题：小3号黑体，居中
  align(center)[
    #text(size: 15pt, weight: "bold", font: fonts.hei)[
      参#h(1em)考#h(1em)文#h(1em)献
    ]
  ]
  
  v(1em)
  
  // 设置参考文献内容格式
  set text(size: 12pt, font: fonts.song)
  set par(leading: 6pt) // 18磅行距
  
  // 自定义参考文献编号格式
  show cite: it => {
    it
  }
  
  // 直接使用传入的 bibliography 对象
  bibliography
}