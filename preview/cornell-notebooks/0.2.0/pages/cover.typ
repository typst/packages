// cover.typ
// 封面

#let cover(
  title: "",
  author: "",
  abstract: "",
  createtime: "",
  lang: "zh"
) = {
  // 设置页面格式
  set page(
    margin: (
      top: 7cm,
      bottom: 4cm,
      left: 2cm,
    ),
  )

  // 封面左上角的装饰图形
  polygon(
    fill: rgb("#bb4e4d"),
    (0cm, -7cm),
    (1.8cm, -7cm),
    (1.8cm, -4cm),
    (0.9cm, -4.9cm),
    (0cm, -4cm),
  )

  // 封面标题
  align(right)[
    #set text(font: ("Times New Roman", "NSimSun"))
    #block(text(weight: 700, 30pt, title))
    #line(length: 100%, stroke: 3pt) //封面横线
    #v(1em, weak: true)
  ]

  // 封面摘要
  align(right)[
    #set text(font: ("Libertinus Serif", "NSimSun"), size: 12pt)
    #abstract
  ]

  // 封面作者
  align(bottom + center)[
    #set text(size: 15pt)
    *#author*
  ]

  // 封面创建时间
  align(bottom + center)[
    #set text(size: 15pt)
    *#createtime*
  ]
}
