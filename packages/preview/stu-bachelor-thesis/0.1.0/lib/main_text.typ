#import "config.typ": 字体, 字号
#import "thanks_page.typ": *
#let fig = counter("fig") // 图编号计数器
#let tab = counter("tab") // 表编号计数器
// 正文页面设置：包裹正文内容
#let setup-bodytext(body) = [
  #set text(lang: "zh")  // 设置中文语言，使得section等显示为"第X节"而非英文

  /************标题格式设置************/
  #set heading(numbering: "1.1")// 设置章节编号格式为“1.1”，同时这句话会启用章节编号功能
  #set math.equation(numbering: "(1)")
  // 自定义引用显示：章节标签显示为"第X章"格式
  #show ref: it => {
    let el = it.element
    if el != none and el.func() == heading and el.level == 1 {
      let chapterNum = counter(heading).at(el.location()).at(0)
      [第#chapterNum 章]
    } else if el != none and el.func() == figure {
      let chapterNum = counter(heading).at(el.location()).at(0)
      // 区分图片和表格
      if el.kind == table {
        let tabNum = counter("tab").at(el.location()).last()
        [表#chapterNum#h(-0.25em) -#h(-0.25em) #tabNum]
      } else {
        let figNum = counter("fig").at(el.location()).last()
        [图#chapterNum#h(-0.25em) -#h(-0.25em) #figNum]
      }
    } else {
      it
    }
  }

  #show heading.where(
    level: 1,
  ): it => [
    #fig.update(1)// 每个一级标题开始时，图编号重置为0
    #tab.update(1)// 每个一级标题开始时，表编号重置为0
    #set align(center)
    #set text(size: 字号.三号, font: 字体.黑体)
    #set par(first-line-indent: 0em)//设置标题不要缩进
    //一级标题直接分页，避免孤行
    #pagebreak(weak: true)//假设当前页面并没有包含任何内容,pagebreak(weak: true)不会创建新的页面
    #numbering("1. ", ..counter(heading).get())//显示章节编号，格式为“1. ”
    #it.body
  ]

  #show heading.where(
    level: 2,
  ): it => [
    #set align(left)
    #set text(size: 字号.小三, font: 字体.黑体)
    #set par(first-line-indent: 0em)
    /*去除孤行*/
    #block(breakable: false, height: 3em)//设置一个高度为3em的不可分页的空白块，这样标题如果在页底就会被整体移到下一页
    #v(-3em, weak: true) //将光标上移3em，去掉空白块的高度，这样标题就会紧贴上面的内容
    #numbering("1.1 ", ..counter(heading).get())
    #it.body
  ]

  #show heading.where(
    level: 3,
  ): it => [
    #set align(left)
    #set text(size: 字号.四号, font: 字体.黑体)
    #set par(first-line-indent: 0em)
    /*去除孤行*/
    #block(breakable: false, height: 3em)//设置一个高度为3em的不可分页的空白块，这样标题如果在页底就会被整体移到下一页
    #v(-3em, weak: true) //将光标上移3em，去掉空白块的高度，这样标题就会紧贴上面的内容
    #numbering("1.1.1 ", ..counter(heading).get())
    #it.body
  ]

  #show heading.where(
    level: 4,
  ): it => [
    #set align(left)
    #set text(size: 字号.小四, font: 字体.黑体)
    #set par(first-line-indent: 0em)
    /*去除孤行*/
    #block(breakable: false, height: 3em)//设置一个高度为3em的不可分页的空白块，这样标题如果在页底就会被整体移到下一页
    #v(-3em, weak: true) //将光标上移3em，去掉空白块的高度，这样标题就会紧贴上面的内容
    #numbering("1.1.1.1 ", ..counter(heading).get())//counter前面的..的作用是将数组或列表解开成单个元素，作为函数的独立参数传递。
    #it.body
  ]

  #show heading.where(
    level: 5,
  ): it => [
    #set align(left)
    #set text(size: 字号.小四, font: 字体.黑体)
    #set par(first-line-indent: 0em)
    /*去除孤行*/
    #block(breakable: false, height: 3em)//设置一个高度为3em的不可分页的空白块，这样标题如果在页底就会被整体移到下一页
    #v(-3em, weak: true) //将光标上移3em，去掉空白块的高度，这样标题就会紧贴上面的内容
    // 在这里计算下当前剩余空间，如果不足以放下标题和至少一行正文，则插入分页符
    #numbering("A.", counter(heading).get().last())// 显示章节编号，格式为“A.”
    #it.body
  ]

  /************正文格式设置************/
  #set text(size: 字号.小四) // 正文字号设置为小四
  #set text(font: 字体.宋体) // 正文字体设置为宋体
  #set par(
    justify: true,
    first-line-indent: 2em,
    leading: 字号.小四 * 1.25, // 1.25倍行距 = 字号 + 字号*0.25
  ) // 两端对齐，段前缩进2字符

  /************页脚设置************/
  #set page(
    footer: context [
      #set align(center)
      #set text(size: 字号.小五, font: 字体.宋体)
      #counter(page).display("1")
    ],
  )

  /************图片标题格式设置************/
  #show figure.caption: it => [
    // 设置文字为小五号宋体
    #set text(size: 字号.小五, font: 字体.宋体)
    #let chapter = counter(heading).get().at(0)
    图 #chapter #h(-0.25em)- #h(-0.25em) #context fig.display() #h(0.25em) #it.body
    #fig.step()
  ]

  /************表格标题格式设置************/
  #show figure.where(kind: table): it => [
    // 将题注和表格内容包裹在不可分页的块中
    #block(breakable: false)[
      // 设置文字为小五号宋体
      #set text(size: 字号.小五, font: 字体.宋体)
      #let chapter = counter(heading).get().at(0)
      // 显示题注
      #align(center)[
        表 #chapter #h(-0.25em)- #h(-0.25em) #context tab.display() #h(0.25em) #it.caption.body
      ]
      // 显示表格内容
      #it.body
    ]
    #tab.step()
  ]

  /************其他显示内容设置************/
  #counter(page).update(1) // 页码从1开始
  #body
]
