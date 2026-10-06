#import "@preview/numbly:0.1.0": numbly

// 粗体手动描粗
#let setup-bold(body) = {
  show text.where(weight: "bold").or(strong): it => {
    show regex("[\p{script=Han}！-･〇-〰—]+"): cn => {
      set text(weight: "regular")
      context {
        set text(stroke: 0.02857em + text.fill)
        cn
      }
    }
    it
  }
  body
}

// 定义字号
#let 字号=(
  初号: 42pt,
  小初: 36pt,
  一号: 26pt,
  小一: 24pt,
  二号: 22pt,
  小二: 18pt,
  三号: 16pt,
  小三: 15pt,
  四号: 14pt,
  中四: 13pt,
  小四: 12pt,
  五号: 10.5pt,
  小五: 9pt,
  六号: 7.5pt,
  小六: 6.5pt,
  七号: 5.5pt,
  小七: 5pt,
)

// 定义字体
#let 字体=(
  仿宋: ("Times New Roman", "FangSong"),
  宋体: ("Times New Roman", "SimSun"),
  黑体: ("Times New Roman", "SimHei"),
  楷体: ("Times New Roman", "KaiTi"),
  代码: ("Consolas", "Times New Roman", "SimSun"),
)

#show strong: it => text(font: 字体.黑体, weight: "semibold", it.body)//设置加粗字体
#show emph: it => text(font: 字体.楷体, style: "italic", it.body)//设置倾斜字体

/*定义图样式*/
#let img(img, caption: "")={
  figure( 
    img, //图片
    caption: caption, //图名
    supplement: [图], //标签
    numbering: "1", //编号
    kind: "image", //类型
  )
}

/*定义表格样式*/
#let tbl(tbl, caption: "")={
  figure(
    tbl, //表格
    caption: caption, //标题
    supplement: [表], //标签
    numbering: "1", //编号样式
    kind: "table", //类型
  )
}

/*定义代码块*/
#let code(code, caption: "", desc: "")={
  if desc == "" {
    desc = caption;
  }
  figure(
    table(columns: 90%, align: left + horizon, 
    stroke: none, 
    table.hline(stroke: 1.5pt), 
    table.header([
      #set text(fill: green)
      \// *#desc*
    ]), table.hline(stroke: 0.8pt), block(code), table.hline(stroke: 1.5pt)),
    caption: caption, //标题
    supplement: [代码], //标签
    numbering: "1.", //编号样式
    kind: "code", //类型
  )
}

/*定义附录代码样式*/
#let codeAppendix(code,caption:"")={
  figure(
    code,
    caption: caption,
    supplement: [附录],
    numbering: "1:",
    kind: "codeAppendix"
  )
}

/*定义公式样式*/
#let equation(equation)={
  figure(
    equation, //公式
    supplement: [式], //标签
    //numbering: equation_num,//编号样式
    numbering: "(1)", //编号样式
    kind: "equation", //类型
  )
}

#let template(
  body,
  zh_abstract: [中文摘要],
  zh_title: "中文论文题目",
  zh_keywords: ([key1], [key2], [key3]),
  en_abstract: [English abstract],
  en_title: "English title",
  en_keywords: ([key1], [key2], [key3]),
  college: [学院],
  class: [班级],
  author: [姓名],
  number: [学号],
  instructor: [指导教师姓名],
  post: [职称],
  year: [2026],
  month: [10],
) = {
  //设置页面
  set page(
    paper: "a4",
    margin: (x: 2.5cm, y: 2.5cm),
    numbering: numbly("{1}","{1}"),
  )
   
  //设置文本样式
  set text(
    font: 字体.宋体,
    size: 字号.小四, //正文字体大小
    fill: black,
    lang: "zh",
  )
   
  //创建假段落样式，解决自动缩进
  let fake-par = context {
    let b = par[#box()]
    let t = measure(b + b)
    b
    v(-t.height)
  }
   
  //设置标题样式
  set heading(
    numbering: numbly(
      "{1:1  }",
      "{1:1}. {2} ",
      "{1:1}. {2:1}. {3:1} "
    )
  )

  set outline.entry(fill: repeat([·]))
   
  show heading.where(level: 1):it=>{ //单独设置一级标题
    pagebreak()
    set align(center)
    set text(font: 字体.黑体, size: 字号.小二, weight: "regular")
    v(1.5em)
    [#it]
    v(0.5em)
  }

  show outline.entry.where(level: 1):it=>{
    set text(font: 字体.黑体, size: 字号.四号)
    it
  }

  show heading.where(level: 2):it=>{ //单独设置二级标题
    set align(left)
    set text(font: 字体.宋体, size: 字号.四号)
    v(0.5em)
    setup-bold(it)
    v(0.5em)
  }

  show outline.entry.where(level: 2):it=>{
    set text(font: 字体.宋体, size: 字号.小四)
    setup-bold(it)
  }
  
  show heading.where(level: 3):it=>{ //单独设置三级标题
    set align(left)
    set text(font: 字体.宋体, size: 字号.小四, weight: "bold")
    v(0.5em)
    setup-bold(it)
    v(1em)
  }

  show outline.entry.where(level: 3):it=>{
    set text(font: 字体.宋体, size: 字号.小四)
    it
  }
   
  // show heading:it =>{
  //   it
  //   fake-par
  // }
  
  // 单独判定特殊格式标题
  show heading:it => {
    if it.level != 1 {
      return it
    }
    
    let body-text = it.body.text

    if body-text == "致谢"{
      body-text = [致#h(2em)谢]

      pagebreak()
      set align(center)
      set text(font: 字体.黑体, size: 字号.小二, weight: "regular")
      v(2em)
      [#body-text]
      v(0.75em)
    }
    else if body-text == "附录"{
      body-text = [附#h(2em)录]

      pagebreak()
      set align(center)
      set text(font: 字体.黑体, size: 字号.小二, weight: "regular")
      v(2em)
      [#body-text]
      v(0.75em)
    }
    else if body-text == "参考文献"{
      body-text = [参考文献]

      pagebreak()
      set align(center)
      set text(font: 字体.黑体, size: 字号.小二, weight: "regular")
      v(2em)
      [#body-text]
      v(0.75em)
    }
    else {
      it
    }
  }

  //设置有序列表格式
  set enum(
    numbering:  " 1.a.",
    indent: 1em,
  )
  //设置无序列表格式
  set list(
    marker: ([#sym.triangle.filled.r],[•]),
    indent: 1.5em,
  )
  
  //设置术语表格式
  set terms(
    separator: [：],
    hanging-indent: 2em,
    )

  //设置段落
  set par(
    justify: true, //两端对齐
    first-line-indent: (
      amount: 2em,
      all: true
    ), //首段缩进
    leading: 1.5em, //行距
  )
  //设置图、表、代码样式
  show figure: it =>[
    #set align(center);//设置居中
    #set block(breakable: true)//允许表格换行
    #if it.kind == "image" { //图
      it.body
      //设置标题样式
      set text(font: 字体.黑体, size: 字号.五号)
      it.caption
    } else if it.kind == "table" { //表
      //表标题
      set text(font: 字体.黑体, size: 字号.五号)
      it.caption
      //设置表字体
      set text(font: 字体.宋体, size: 字号.五号)
      it.body
    } else if it.kind == "code" { //代码
      //设置标题样式
      set text(font: 字体.黑体, size: 字号.小五)
      it.caption
      //设置代码字体
      set text(font: 字体.代码, size: 字号.五号)
      it.body
    } else if it.kind == "equation" { //公式
      //通过大比例来达到中间靠右的排布
      grid(
        columns: (20fr, 1fr), //两列
        it.body, //显示公式
        align(center + horizon, it.counter.display(it.numbering)), //显示编号
      )
    } else if it.kind=="codeAppendix"{//附录代码
    table(
      columns: 100%,
      fill: (x,y)=>{if(x==0 and y==0){gray}},
      table.header(align(left)[*#it.caption*], repeat: false),
      [
        #set par(leading: 0.45em)
        #align(left)[
          #set text(font: 字体.代码, size: 字号.五号)
          #it.body]
      ]
    )}else {
      it
    }
  ]
  // 封面页
  [
    #set text(size: 字号.小四)
    #set par(
      justify: true, //两端对齐
      leading: 1.5em, //行距
    )
    #set page(
      numbering: none,
      margin: (
        top: 2.54cm,
        bottom: 2.54cm,
        left: 2.22cm,
        right: 1.95cm)
    )

    // logo 显示
    #v(2.5em)
    #table(
      columns: (1fr,4fr),
      stroke: none,
      table.cell(rowspan: 2, align: center+bottom)[
        #image("sources/logo.png",width: 110%)
      ],
      table.cell(align: center+bottom)[
        #image("sources/jsu.png",width: 100%)
      ],
      table.cell()[
        #set text(font: "Times New Roman", size: 字号.小一)
        #underline(
          stroke: 3pt,
          evade: true
        )[*J I A N G S U\u{3000}U N I V E R S I T Y*]
      ]
    )

    #show: setup-bold
    #align(center)[
      #text(font: 字体.宋体, size: 字号.二号)[
        *本#h(1em)科#h(1em)毕#h(1em)业#h(1em)设#h(1em)计（论#h(1em)文）*
      ]
    ]

    #set text(size: 字号.二号)
    #v(3.4em)

    // 论文题目显示
    #align(center)[
      #text(font: 字体.黑体, size: 字号.二号)[#zh_title]
    ]
    #align(center)[
      #text(font: "Times New Roman", size: 字号.三号, weight: "bold")[#en_title]
    ]
    #set text(font: 字体.宋体, size: 字号.小四)
    #v(5.5em)

    // 信息部分显示
    #set text(font: 字体.宋体, size: 字号.四号)
    #figure(
      table(
        columns: (4cm,8.5cm),
        rows: (1.1cm),
        align: center+horizon,
        stroke: none,
        [学#h(1fr)院#h(1fr)名#h(1fr)称#h(1fr)：],
        table.hline(start: 1 ,stroke: 0.5pt),
        [#college],
        [专#h(1fr)业#h(1fr)班#h(1fr)级#h(1fr)：],
        table.hline(start: 1 ,stroke: 0.5pt),
        [#class],
        [学#h(1fr)生#h(1fr)姓#h(1fr)名#h(1fr)：],
        table.hline(start: 1 ,stroke: 0.5pt),
        [#author],
        [学#h(1fr)生#h(1fr)学#h(1fr)号#h(1fr)：],
        table.hline(start: 1 ,stroke: 0.5pt),
        [#number],
        [指#h(1fr)导#h(1fr)教#h(1fr)师#h(1fr)姓#h(1fr)名#h(1fr)：],
        table.hline(start: 1 ,stroke: 0.5pt),
        [#instructor],
        [指#h(1fr)导#h(1fr)教#h(1fr)师#h(1fr)职#h(1fr)称#h(1fr)：],
        table.hline(start: 1 ,stroke: 0.5pt),
        [#post],
      )
    )

    #v(1.5em)
    #align(center)[#text(font: 字体.宋体, size: 字号.小四)[#year 年#month 月]]
  ]

  pagebreak()
  // 原创性声明
  [
    #counter(page).update(1)
    #set par(
      justify: true, //两端对齐
      leading: 1.5em, //行距
    )
    #set page(
      margin: (
        top: 2.54cm,
        bottom: 2.54cm,
        left: 2.22cm,
        right: 1.95cm
      ),
      header: [
        #table(
          columns: (1fr),
          align: center+bottom,
          stroke: none,
          [
            #text(font: 字体.宋体, size: 字号.小五)[原创性声明#h(1fr)江苏大学本科毕业设计（论文）]
          ],
          table.hline(stroke: 0.7pt)
        )
      ],
      header-ascent: 0.6cm,
      footer: context [
        #set align(center)
        #set text(font: "Times New Roman", size: 字号.小五)
        #counter(page).display(
          "I",
        )
      ],
      footer-descent: 0.1cm
    )

    #set text(font: 字体.黑体, size: 字号.三号)
    #v(4.5em)
    #align(center)[毕业设计（论文）原创性声明]
    #v(2em)
    #set text(font: 字体.宋体, size: 字号.四号)
    #par[
      本人郑重声明：所提交的毕业设计（论文），是本人在导师指导下，独立进行研究工作所取得的成果。\ 
      #h(2em)除文中已注明引用的内容外，本毕业设计（论文）不包含任何其他个人或集体已经发表或撰写过的作品成果。对本研究做出过重要贡献的个人和集体，均已在文中以明确方式标明并表示了谢意。
    ]
    
    #set text(font: 字体.宋体, size: 字号.小四)
    #v(5em)
    
    #set text(font: 字体.宋体, size: 字号.四号)
    #table(
      columns: (1fr,185pt),
      rows: 2.35em,
      align: left+horizon,
      stroke: none,
      [],[论文作者签名：],
      [],[日期：#h(2em)年#h(1em)月#h(1em)日]
    )
  ]

  pagebreak()
  // 中文摘要
  [
    #set page(
      margin: (
        top: 2.54cm,
        bottom: 2.54cm,
        left: 2.22cm,
        right: 1.95cm
      ),
      header: [
        #table(
          columns: (1fr),
          align: center+bottom,
          stroke: none,
          [
            #text(font: 字体.宋体, size: 字号.小五)[摘要#h(1fr)江苏大学本科毕业设计（论文）]
          ],
          table.hline(stroke: 0.7pt)
        )
      ],
      header-ascent: 0.6cm,
      footer: context [
        #set align(center)
        #set text(font: "Times New Roman", size: 字号.小五)
        #counter(page).display(
          "I",
        )
      ],
      footer-descent: 0.1cm
    )
    #set par(
      justify: true, //两端对齐
      leading: 1.4em, //行距
    )
    #[//题目
      #v(2.2em)  
      #set text(font: 字体.黑体, size: 字号.三号)
      #align(center)[#zh_title]
    ]
    #[//基本信息
      #set text(font: 字体.宋体, size: 字号.小四)
      #figure(
        table(
          columns: (2.5cm,3.4cm,2.5cm,2.1cm),
          rows: 0.9cm,
          align: center+horizon,
          stroke: none,
          [专业班级：],[#class],[学生姓名：],[#author],
          [指导教师：],[#instructor],[职#h(2em)称：],[#post]
        )
      )
    ]
    #[//摘要
      #v(0.5em)
      #text(font: 字体.黑体, size: 字号.四号)[摘要：]
      #zh_abstract
    ]
    #v(2.5em)
    #[//关键词
      #h(-2em)
      #text(font: 字体.黑体, size: 字号.四号)[关键词：]
      #text(font: 字体.宋体, size: 字号.小四)[#zh_keywords.map(it => it).join([；])]
    ]
  ]
  
  pagebreak()

  // 英文摘要
  [
    #set page(
      margin: (
        top: 2.54cm,
        bottom: 2.54cm,
        left: 2.22cm,
        right: 1.95cm
      ),
      header: [
        #table(
          columns: (1fr),
          align: center+bottom,
          stroke: none,
          [
            #text(font: 字体.宋体, size: 字号.小五)[摘要#h(1fr)江苏大学本科毕业设计（论文）]
          ],
          table.hline(stroke: 0.7pt)
        )
      ],
      header-ascent: 0.6cm,
      footer: context [
        #set align(center)
        #set text(font: "Times New Roman", size: 字号.小五)
        #counter(page).display(
          "I",
        )
      ],
      footer-descent: 0.1cm
    )
    #set par(
      justify: true, //两端对齐
      leading: 1.4em, //行距
      first-line-indent: (
        amount: 1em,
      ), //首段缩进
    )
    
    #[//题目
      #v(1.7em)  
      #set text(font: "Times New Roman", size: 字号.四号, weight: "bold")
      #align(center)[#en_title]
    ]
    #[//摘要
      #v(1.2em)
      #text(font: "Times New Roman", size: 字号.小四, weight: "bold")[ABSTRACT]
      #en_abstract
    ]
    #v(1.5em)
    #[//关键词
      #h(-1em)
      #text(font: 字体.黑体, size: 字号.小四, weight: "bold")[KEY WORDS:]
      #text(font: 字体.宋体, size: 字号.小四)[#en_keywords.map(it => it).join([;])]
    ]

    /*目录*/
    //#contents()
  ]

  pagebreak()
  // 目录
  [
    #set page(
      margin: (
        top: 2.54cm,
        bottom: 2.54cm,
        left: 2.22cm,
        right: 1.95cm
      ),
      header: [
        #table(
          columns: (1fr),
          align: center+bottom,
          stroke: none,
          [
            #text(font: 字体.宋体, size: 字号.小五)[目录#h(1fr)江苏大学本科毕业设计（论文）]
          ],
          table.hline(stroke: 0.7pt)
        )
      ],
      header-ascent: 0.6cm,
      footer: context [
        #set align(center)
        #set text(font: "Times New Roman", size: 字号.小五)
        #counter(page).display(
          "I",
        )
      ],
      footer-descent: 0.1cm
    )
    #set par(
      justify: true, //两端对齐
      leading: 1.4em, //行距
    )
    
    #align(center)[
      #set text(font: 字体.黑体, size: 字号.二号)
      #v(1em)
      目#h(2em)录
      #v(0.35em)
    ]
    #parbreak()//换行
    #show outline:it=>{
      set text(font: 字体.黑体,size: 字号.小四)
      it
      parbreak()
    }

    #outline(
      title: none,
      indent: auto,
      depth: 3
    )
  ]
  
  //正文
  [
    #set page(
      margin: (
        top: 2.54cm,
        bottom: 2.54cm,
        left: 2.22cm,
        right: 1.95cm
      ),
      header: [
        #table(
          columns: (1fr),
          align: center+bottom,
          stroke: none,
          [
            #text(font: 字体.宋体, size: 字号.小五)[#h(1fr)江苏大学本科毕业设计（论文）]
          ],
          table.hline(stroke: 0.7pt)
        )
      ],
      header-ascent: 0.6cm,
      footer: context [
        #set align(center)
        #set text(font: "Times New Roman", size: 字号.小五)
        #counter(page).display(
          "1",
        )
      ],
      footer-descent: 0.1cm
    )
    #set par(
      justify: true, //两端对齐
      leading: 1.5em, //行距
    )
    
    #set text(font: 字体.宋体, size: 字号.小四)
    #counter(page).update(1)

    #show: setup-bold
    #body 
  ]
}