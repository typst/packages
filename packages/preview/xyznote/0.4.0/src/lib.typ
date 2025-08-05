#import "colors.typ": *
#import "color-box.typ": *

#let xyznote(
  title: "",
  author: "",
  abstract: "",
  createtime: "",
  bibliography-style: "ieee",
  lang: "zh",
  preface: none,
  body,
  bibliography-file: none,
  // paper-size: "a4",
) = {
  set text(lang: lang)
  set document(author: author, date: auto, title: title)

  //标题计数器
  let chaptercounter = counter("chapter")
  set heading(numbering: "1.1.1.1.1.")

  // 标题样式
  show heading: it => [
    #set text(font: ("libertinus serif", "SimSun"))
    #set par(first-line-indent: 0em) // 取消标题首行缩进
    #if it.numbering != none {
      text()[#counter(heading).display()]
    }
    #it.body
    #v(0.2em) // 增加标题后的垂直间距
    #if it.level == 1 and it.numbering != none {
      chaptercounter.step()
      counter(math.equation).update(0)
    }
  ]

  //引入 numbly 包
  import "@preview/numbly:0.1.0": numbly
  set heading(
    numbering: numbly(
      "Part {1:1}:",
      "{1}.{2}.",
    ),
  )
  show heading.where(level: 1): set align(center)

  show outline.entry.where(level: 1): set block(above: 1.2em) //一级标题块间距

  show outline: set heading(numbering: none)
  show outline: set par(first-line-indent: 0em)

  show outline.entry.where(level: 1): it => {
    text(font: ("libertinus serif", "SimSun"))[#strong[#it]]
  }
  set par(leading: 9pt) //目录行间距
  show outline.entry: it => {
    text(font: ("libertinus serif", "SimSun"))[#it]
  }

  // 首行缩进
  set par(
    first-line-indent: (
      amount: 2em,
      all: true,
    ),
  )
  set par(spacing: 1.2em) //段落间距

  //封面
  set page(
    margin: (
      top: 7cm,
      bottom: 4cm,
      left: 2cm,
    ),
  )

  polygon(
    fill: rgb("#bb4e4d"),
    (0cm, -7cm),
    (1.8cm, -7cm),
    (1.8cm, -4cm),
    (0.9cm, -4.9cm),
    (0cm, -4cm),
  )

  align(right)[
    #set text(font: ("Times New Roman", "NSimSun"))
    #block(text(weight: 700, 30pt, title))
    #line(length: 100%, stroke: 3pt) //封面横线
    #v(1em, weak: true)
  ]

  align(right)[
    #set text(font: ("Libertinus Serif", "NSimSun"), size: 12pt)
    #abstract
  ]

  align(bottom + center)[
    #set text(size: 15pt)
    *#author*
  ]

  align(bottom + center)[
    #set text(size: 15pt)
    *#createtime*
  ]

  // 添加序（如果提供）
  if preface != none {
      set page(
        margin: (
          top: 1.5cm,
          bottom: 2cm,
          right: 2cm,
          left: 2cm,
        ),
      )
      align(center)[
        #set text(font: ("Times New Roman", "NSimSun"), size: 20pt)
        *#if lang == "en" [Preface] else [序]*
      ]
      [
        #set text(font: ("Times New Roman", "NSimSun"), size: 12pt)
        #preface
      ]
    }

  //表格样式
  set table(
    fill: (_, row) => {
      if row == 0 {
        rgb("#2c3338").lighten(10%) // 表头深色背景
      } else if calc.odd(row) {
        rgb("#ffffff") // 奇数行为白色
      } else {
        rgb("#000000").lighten(85%) // 偶数行为浅灰色
      }
    },
    stroke: 0.1pt + rgb("#000000"),
  )

  // 设置表头字体为浅色且加粗
  show table.cell.where(y: 0): it => {
    set text(fill: white)
    strong(it)
  }

  //引用块
  set quote(block: true)

  //inlinecode
  show raw.where(block: false): it => box(fill: rgb("#d7d7d7"), inset: (x: 2pt), outset: (y: 3pt), radius: 1pt)[#it]

  //链接下划线
  show link: {
    underline.with(stroke: rgb("#0074d9"), offset: 2pt)
  }

  //外部包
  import "@preview/codly:1.2.0": *
  import "@preview/codly-languages:0.1.1": *
  show: codly-init //初始化 codly
  // codly(number-format: none) //不显示行号
  codly(languages: codly-languages) //设置语言图标

  //公式编号
  set math.equation(
    numbering: (..nums) => (
      context {
        set text(size: 9pt)
        numbering("(1.1)", chaptercounter.at(here()).first(), ..nums)
      }
    ),
  )

  // caption 计数器
  set figure(
    numbering: (..nums) => (
      context {
        set text(font: ("Libertinus Serif", "KaiTi"), size: 9pt)
        numbering("1.1", chaptercounter.at(here()).first(), ..nums)
      }
    ),
  )

  //图片表格 caption 字体字号
  show figure.caption: set text(font: ("Libertinus Serif", "KaiTi"), size: 9pt)

  // ------------------------ 以下为正文配置 ---------------------------------- //

  //正文页边距
  set page(
    margin: (
      top: 2cm,
      bottom: 2cm,
      right: 2cm,
      left: 2cm,
    ),
  )

  //正文字体字号
  set text(
    font: ("Libertinus Serif", "microsoft yahei"),
    // size: 11pt,
  )

  pagebreak()

  counter(page).update(0)

  outline()

  pagebreak()

  //页码
  set page(
    header: context {
      set text(font: ("Times New Roman", "kaiti"))
      // 目录页不显示页眉
      if counter(page).at(here()).first() == 0 { return }

      let elems = query(heading.where(level: 1).after(here()))
      let before_elems = query(heading.where(level: 1).before(here()))

      let chapter-title = ""

      if elems != () and elems.first().location().page() == here().page() {
        chapter-title = elems.first().body
      } else if before_elems != () {
        chapter-title = before_elems.last().body
      }

      // 如果没有找到任何标题,返回空字符串
      if chapter-title == "" { return }

      // 使用实际页码判断奇偶
      let page-number = counter(page).at(here()).first()
      if calc.odd(page-number) {
        h(1fr) + emph(chapter-title) // 奇数页靠右
      } else {
        emph(chapter-title) + h(1fr) // 偶数页靠左
      }

      v(-8pt)
      align(center)[#line(length: 105%, stroke: (thickness: 1pt, dash: "solid"))]
    },

    footer: context {
      if counter(page).at(here()).first() == 0 { return }
      let page-number = counter(page).at(here()).first()
      [
        #if calc.odd(page-number) {
          align(right)[#counter(page).display("1 / 1", both: true)] // 奇数页靠右
        } else {
          align(left)[#counter(page).display("1 / 1", both: true)] // 偶数页靠左
        }
      ]
    },
  )

  body

  //参考文献
  if bibliography-file != none {
    set text(font: ("Times New Roman", "KaiTi")) //设置参考文献字体
    pagebreak()
    show bibliography: set text(10.5pt)
    set bibliography(style: bibliography-style)
    bibliography-file
  }
}

#let sectionline = align(center)[#v(2em) * \* #sym.space.quad \* #sym.space.quad \* * #v(2em)]
