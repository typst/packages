#import "../utils/style.typ": 字号, 字体

// 本科生声明页
#let bachelor-decl-page(
  anonymous: false,
  twoside: false,
  fonts: (:),
  info: (:),
) = {
  // 0. 如果需要匿名则短路返回
  if anonymous {
    return
  }

  // 1.  默认参数
  fonts = 字体 + fonts
  info = (
    title: ("基于 Typst 的", "南京大学学位论文"),
  ) + info

  // 2.  对参数进行处理
  // 2.1 如果是字符串，则使用换行符将标题分隔为列表
  if type(info.title) == str {
    info.title = info.title.split("\n")
  }


  // 3.  正式渲染
  pagebreak(weak: true, to: if twoside { "odd" })

  v(6pt)

  align(center, image("../assets/vi/nju-emblem-purple.svg", width: 1.95cm))

  v(-12pt)

  align(
    center,
    text(
      font: fonts.黑体,
      size: 字号.小一,
      weight: "bold",
      "南京大学本科毕业论文（设计）\n诚信承诺书",
    ),
  )

  v(48pt)

  block[
    #set text(font: fonts.宋体, size: 字号.小三)
    #set par(justify: true, first-line-indent: (amount: 2em, all: true), leading: 2.42em)

    本人郑重承诺：所呈交的毕业论文（设计）（题目：#info.title.sum()）是在指导教师的指导下严格按照学校和院系有关规定由本人独立完成的。本毕业论文（设计）中引用他人观点及参考资源的内容均已标注引用，如出现侵犯他人知识产权的行为，由本人承担相应法律责任。本人承诺不存在抄袭、伪造、篡改、代写、买卖毕业论文（设计）等违纪行为。
  ]

  v(76pt)

  grid(
    columns: (1fr, 150pt),
    [],
    align(left)[
      #set text(font: fonts.黑体, size: 字号.小三)
      
      作者签名：

      学号：

      日期：
    ]
  )
}