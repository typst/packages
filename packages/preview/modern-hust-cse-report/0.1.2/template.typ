#import "@preview/cuti:0.4.0": show-cn-fakebold

// 图片函数，自动添加图注
#let fig(content, caption: "") = {
  figure(
    content,
    caption: text(font: ("Times New Roman", "SimHei"), size: 12pt)[#caption],
    supplement: text(font: "SimHei")[图],
    numbering: (..nums) => {
      let values = nums.pos()
      if values.len() == 1 {
        context {
          let section = counter(heading).get()
          if section.len() >= 2 {
            numbering("1-1-1", section.at(0), section.at(1), values.at(0))
          } else if section.len() == 1 {
            numbering("1-1", section.at(0), values.at(0))
          } else {
            numbering("1", values.at(0))
          }
        }
      }
    }
  )
}

// 表格函数，自动添加表注
#let tbl(content, caption: "") = {
  figure(
    content,
    caption: text(font: ("Times New Roman", "SimHei"), size: 12pt)[#caption],
    supplement: text(font: "SimHei")[表],
    numbering: (..nums) => {
      let values = nums.pos()
      if values.len() == 1 {
        context {
          let section = counter(heading).get()
          if section.len() >= 2 {
            numbering("1-1-1", section.at(0), section.at(1), values.at(0))
          } else if section.len() == 1 {
            numbering("1-1", section.at(0), values.at(0))
          } else {
            numbering("1", values.at(0))
          }
        }
      }
    },
    kind: table,
    placement: auto,
  )
}

#let report(
  name: "",
  class: "",
  id: "U202",
  contact: "(电子邮件)",
  title: "",
  extratitle: none,
  scoretable:[],
  signature: none, // 签名图片路径，如 "signature.png"
  title-size: 26pt, // 标题字号，默认 26pt，可改为 25pt
  body
) = {

  show: show-cn-fakebold
  show heading.where(level: 1): it => {
    if query(heading.where(level: 1)).first() != it {
      pagebreak()
    }
    set text(font: ("Times New Roman", "SimHei"), size: 18pt)
    set align(center)
    set block(below: 1em)
    it
  }

  show heading.where(level: 2): it => {
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(math.equation).update(0)
    set text(font: ("Times New Roman", "SimHei"), size: 14pt)
    set block(above: 1.5em, below: 1.5em)
    it
  }

  show heading.where(level: 3): it => {
    set text(font: ("Times New Roman", "SimHei"), size: 12pt, weight: "bold")
    set block(above: 1.5em, below: 1.5em)
    it
  }

  show heading.where(level: 4): it => {
    set text(font: ("Times New Roman", "SimHei"), size: 12pt, weight: "bold")
    set block(above: 1.5em, below: 1.5em)
    it
  }

  set page(
    paper: "a4",
    margin: (x: 2.5cm, y: 3cm),
    numbering: none,
    header: context {
      if counter(page).get().first() > 1 [
        #align(center)[#text(font: ("SimHei"), size: 10.5pt)[网络空间安全学院#title]]
        #block(line(length: 100%, stroke: 0.5pt), above: 0.6em, below: 1.5em)
      ]
    },
  )

  set text(
    font: ("Times New Roman", "SimSun"),
    size: 12pt,
    lang: "zh",
  )

  set par(
    justify: true,
    leading: 1.5em,
    spacing:1.5em,
    first-line-indent: (amount: 2em, all: true),
  )

  // 设置代码块行距
  show raw.where(block: true): it => {
    set par(leading: 0.5em)
    it
  }

  // 设置列表缩进，与正文保持一致
  set list(indent: 2em)
  set enum(indent: 2em)

  show heading: set block(
    above: 0.7em,
    below: 0.9em,
  )

  // 设置图片和表格居中
  show figure.where(kind: image): set align(center)
  show figure.where(kind: table): set align(center)

  // 设置块级数学公式编号（标号在右侧）
  set math.equation(numbering: (..nums) => {
    let values = nums.pos()
    if values.len() == 1 {
      context {
        let section = counter(heading).get()
        if section.len() >= 2 {
          numbering("(1-1-1)", section.at(0), section.at(1), values.at(0))
        } else if section.len() == 1 {
          numbering("(1-1)", section.at(0), values.at(0))
        } else {
          numbering("(1)", values.at(0))
        }
      }
    }
  })

  set heading(numbering: (..nums) => {
    let values = nums.pos()
    if values.len() == 1 {
      str(values.at(0)) + "、"
    } else if values.len() == 2 {
      str(values.at(0)) + "." + str(values.at(1))
    } else {
      numbering("1.1.1", ..nums)
    }
  })


  // --- 标题页 ---
  align(center)[
    #v(3em)
    #text(font: "SimSun", size: 26pt, weight: "bold")[
      华 中 科 技 大 学
    ]

    #text(font: "SimSun", size: 26pt)[
      *网络空间安全学院*
    ]

    #v(5em)

    #text(font: "FangSong", size: title-size)[
      本科：#title
    ]
  ]

  v(2em)

if extratitle != none [#align(center)[#text(font:"SimSun",size:22pt)[
  题目：#extratitle
]]] else {v(4em)}

  v(6em)
 
align(center)[#text(font:"FangSong",size:16pt)[
  #set par(spacing: 1.5em)
  #context {
    let info_width = calc.max(
      measure[#name].width,
      measure[#class].width,
      measure[#id].width,
      measure[#contact].width
    ) + 1em
    [姓#h(2em)名 #box(width: info_width, align(center)[#name])

    班#h(2em)级 #box(width: info_width, align(center)[#class])

    学#h(2em)号 #box(width: info_width, align(center)[#id])

    联系方式 #box(width: info_width, align(center)[#contact])

    分#h(2em)数 #box(width: info_width, align(center)[#line(length: info_width)])

    评#h(0.5em)分#h(0.5em)人 #box(width: info_width, align(center)[#line(length: info_width)])]
  }
]]

  v(3em)
  align(center)[#text(font:"SimSun", size:14pt)[
    #datetime.today().display("[year] 年 [month] 月 [day] 日")
  ]]

    pagebreak()
    v(3em)
    align(center)[#text(size:18pt,weight:"bold")[
        课程设计报告要求
        #v(1em)
    ]]
    text(size:14pt,weight:"bold")[
      #set par(spacing:2em,leading:2em)
    \1. 报告不可以抄袭，发现雷同者记为0分。
      
     \2. 报告中不可以只粘贴大段代码，应是文字与图、表结合的，需要 

    说明流程的时候，也应该用流程图或者伪代码来说明；如果发现有

    大段代码粘贴者，报告打回重写。

      \3. 报告格式要求规范。
    ]

  pagebreak()
  scoretable
  pagebreak()
  // --- 目录 ---
  {
    show outline.entry.where(level: 1): it => {
      set text(weight: "bold")
      it
    }
    show outline: it => {
      show heading: set align(center)
      show heading: set text(font: "SimHei")
      it
    }
    outline(
      title: [目#h(2em) 录],
      indent: auto,
    )
  }

  counter(page).update(1) // 目录后的第一个正文页记为1
  set page(numbering: "1")

  // --- 正文 ---
  body

  pagebreak()

  // --- 原创性声明 ---
  align(center)[
    #text(font:"FangSong",size: 18pt)[
      原创性声明
    ]
  ]

  v(1em)

  text(font:"FangSong")[
    本人郑重声明本报告内容，是由作者本人独立完成的。有关观点、方法、数据和文献等的引用已在文中指出。除文中已注明引用的内容外，本报告不包含任何其他个人或集体已经公开发表的作品成果，不存在剽窃、抄袭行为。

    已阅读并同意以下内容。

    判定为不合格的一些情形：

    (1)请人代做或冒名顶替者；

    (2) 替人做且不听劝告者；

    (3) 实验报告内容抄袭或雷同者；

    (4) 实验报告内容与实际实验内容不一致者；

    (5) 实验代码抄袭者。

    #v(2em)

    #grid(
      columns: (auto, 1fr),
      gutter: 1em,
      text(fill: red,font:"FangSong")[*作者签名：*],
      if signature != none [
        #align(left)[#image(signature, width: 3cm)]
      ]
    )
  ]
}
