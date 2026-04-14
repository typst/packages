#import "config.typ": 字体, 字号

//设置目录样式的函数，参数为目录的深度和标题
#let setup-outline() = [
  #show outline: it => [
    #set page(
      footer: context [
        #set align(center)
        #set text(font: 字体.宋体, size: 字号.小五)
        #counter(page).display("I")
      ],
    )
    #set text(font: 字体.黑体, size: 字号.三号)
    #set align(center)
    #it]

  #show outline.entry.where(level: 2): it => [
    #set text(font: 字体.宋体, size: 字号.小四)
    #set block(above: 1.25em, below: 1.25em)
    //判断对象的文字是否为参考文献，如果是的话，使用不同的格式
    #it.prefix() #it.body()#box(width: 1fr, repeat($dot.op$, gap: 0.15em)) (#it.page())
    #v(1em)
    #v(-1em)
  ]

  #show outline.entry.where(level: 3): it => [
    #set text(font: 字体.宋体, size: 字号.小四)
    #set block(above: 1.25em, below: 1.25em)
    #it.prefix() #it.body()#box(width: 1fr, repeat($dot.op$, gap: 0.15em)) (#it.page())
    #v(1em)
    #v(-1em)
  ]

  #show outline.entry.where(level: 1): it => [
    #set text(font: 字体.宋体, size: 字号.小四)
    #set block(above: 1.25em, below: 1.25em)
    #it.indented(
      numbering("1.", ..counter(outline.entry.where(level: 1)).get()),
      [#it.body() #box(width: 1fr, repeat($dot.op$, gap: 0.15em)) (#it.page())],
    )
    #v(1em)
    #v(-1em)
  ]

  #outline(depth: 3, indent: 0em, title: [目#h(1em)录#v(1em)])
  #pagebreak()
]
