#import "@preview/pointless-size:0.1.1": zh
// 致谢页
#let acknowledgement(
  // documentclass 传入参数
  anonymous: false,
  twoside: false,
  // 其他参数
  title: "致　　谢",
  outlined: true,
  body,
) = {
  if not anonymous {
    pagebreak(weak: true, to: if twoside { "even" })
    [
      #show heading: it => text(fill:white, size: 0pt, it)
      #heading(level: 1, numbering: none, outlined: outlined, bookmarked: outlined, title) 

      #align(center)[
        #set text(size: zh(-4), font: "SimHei")
        #title
      ]

      #set text(size: zh(5), font: ("Times New Roman", "SimSun"))
      #body
    ]
  }
}