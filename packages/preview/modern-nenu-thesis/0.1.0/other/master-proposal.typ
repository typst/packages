//! This template is written by [@Lingshu Zeng](https://github.com/zeroDtree)
//! Improved by [@Dian Ling](https://github.com/virgiling)

#import "@preview/numbly:0.1.0": numbly
#import "@preview/cuti:0.3.0": *
#import "@preview/i-figured:0.2.4"
#import "@preview/lovelace:0.3.0": *
#import "@preview/cetz:0.3.1"
#import "../utils/style.typ": font-family, font-size
#import "../utils/justify-text.typ": justify-text

// 中文缩进
#let indent = h(2em)

// 选项栏
#let checkbox(checked: false) = {
  if checked {
    box(
      stroke: .05em,
      height: .8em,
      width: .8em,
      {
        box(
          move(
            dy: .48em,
            dx: 0.1em,
            rotate(45deg, reflow: false, line(length: 0.3em, stroke: .1em)),
          ),
        )
        box(
          move(
            dy: .38em,
            dx: -0.05em,
            rotate(-45deg, reflow: false, line(length: 0.48em, stroke: .1em)),
          ),
        )
      },
    )
  } else {
    box(
      stroke: .05em,
      height: .8em,
      width: .8em,
    )
  }
}
#let justify-block(w: auto, body) = block(width: w, justify-text(body))

#let datetime-display-cn-declare(date) = {
  date.display("[year] 年  [month]  月  [day]  日")
}

#let cover(
  title: (school: "东北师范大学", type: "研究生学位论文开题报告"),
  author-info: (:),
) = {
  set align(center)
  set text(size: font-size.二号, font: font-family.黑体)
  v(4em)
  fakebold[#title.school #v(.5em) #title.type]

  set text(size: font-size.三号, font: font-family.楷体)
  v(3.5em)


  grid(
    columns: (.35fr, 1fr),
    row-gutter: 1.3em,
    column-gutter: 0em,
    align: (center, left),
    justify-block("论文题目", w: 7em), [：#author-info.title],
    justify-block("报告人姓名", w: 7em), [：#author-info.name],
    justify-block("研究方向", w: 7em), [：#author-info.direction],
    justify-block("学科专业", w: 7em), [：#author-info.major],
    justify-block("年级", w: 7em), [：#author-info.grade],
    justify-block("学历层次", w: 7em),
    [：博士生 #checkbox(checked: author-info.level == "博士生")
      #h(1em)硕士生 #checkbox(checked: author-info.level == "硕士生")],

    justify-block("学位类型", w: 7em),
    [
      ：学术学位 #checkbox(checked: author-info.type == "学术学位")
      #h(1em)专业学位 #checkbox(checked: author-info.type == "专业学位")
    ],

    justify-block("指导教师", w: 7em), [：#author-info.supervisor],
    justify-block("培养单位", w: 7em), [：#author-info.unit],
  )
  set align(left)
  pagebreak()
}

#let command = {
  set page(margin: (top: 2.54cm, bottom: 2.54cm, left: 3.18cm, right: 3.18cm))
  v(1.5em)

  [
    #set align(center)
    #set text(size: font-size.三号, font: font-family.楷体)
    #set par(leading: 1em)
    #fakebold[撰写说明]
  ]

  v(1em)
  set text(size: font-size.四号)
  set par(leading: 1.5em, first-line-indent: 2em, spacing: 1.5em, justify: true)
  [
    1.文献综述应基于选题领域内具有代表性的文献进行，需满足一定的字数要求。博士生：文科不得少于10000字，理科不得少于6000字。硕士生：文科不得少于5000字，理科不得少于3000字。

    2.参考文献是指在开题报告中实际引用的文献。博士生实际引用文献须不少于 50 篇，硕士生实际引用文献须不少于 30 篇。参考文献格式参照学位论文格式要求，建议文中引用文献以脚注形式标注，并在文末按照字母顺序列出所有引用文献。

    3.博士生论文开题时间与学位论文通讯评阅时间间隔原则上不少于 1.5 年，硕士生论文开题时间与学位论文通讯评阅时间间隔原则上不少于 8 个月。
    开题报告审查小组根据开题报告情况，在相应的 #checkbox() 内打号。合格的开题报告，由学院存档并作为毕业审核材料之一。

    4.开题报告审查小组根据开题报告情况，在相应的 #checkbox() 内打 $checkmark.light$ 号。合格的开题报告，由学院存档并作为毕业审核材料之一。

    5.开题报告中的字体字号均用宋体小四，页边距上下20MM,左右25MM，用A4纸打印，于左侧装订成册。

    6.开题结束后，研究生需针对开题中所提问题与建议进行修改，并向学院提交开题报告修订花脸稿。

  ]
  pagebreak()
}

#let empty-par = par[#box()]
#let fake-par = context empty-par + v(-measure(empty-par + empty-par).height)

#let doc(it) = {
  set page(margin: (top: 2cm, bottom: 2cm, left: 2.5cm, right: 2.5cm))
  set text(size: font-size.小四, font: font-family.宋体, lang: "zh")
  set par(leading: 1em, first-line-indent: 2em, justify: true)
  set heading(
    numbering: numbly(
      "{1:一}、",
      "{1:1}.{2}",
      "{1}.{2}.{3}",
    ),
  )

  let heading-style(it) = {
    let title = it.body.text.split("（").first()
    let content = it.body.text.split("（").last()
    if title == "参考文献" {
      content = none
    }
    // TODO 优化这部分显示
    v(0.5em)
    [
      #fake-par
      #set par(leading: 1em, first-line-indent: 0em)
      #if it.level == 1 {
        text(font: font-family.黑体, size: font-size.三号)[
          #fakebold[#counter(heading).display() #title]
        ]
        if content != none {
          text(font: font-family.楷体, size: font-size.四号)[
            （#content
          ]
        }
      } else {
        text(font: font-family.黑体, size: font-size.小三)[
          #counter(heading).display() #title
        ]
      }
    ]
  }

  show heading.where(level: 1): heading-style
  show heading.where(level: 2): heading-style


  //! 3. 图片&表格设置
  show heading: i-figured.reset-counters
  show figure: i-figured.show-figure


  show figure.where(kind: table): set figure.caption(position: top)
  set figure.caption(separator: " ")
  show figure.caption: fakebold
  show figure.caption: set text(font: font-family.宋体, size: font-size.五号)

  //! 4. 公式编号
  show math.equation.where(block: true): i-figured.show-equation

  show terms: set par(first-line-indent: 0pt)


  it
}

#let nenu-bibliography(
  bibliography: none,
  full: false,
  style: "gb-7714-2005-numeric",
) = {
  [
    = 参考文献
  ]
  assert(bibliography != none, message: "bibliography 函数不能为空")

  set text(lang: "zh", size: font-size.小四, font: font-family.宋体)

  bibliography(
    title: none,
    full: full,
    style: style,
  )
}

// [!FIXME] 增加 dx, dy 偏移量参数，使得签名能够放在恰当的位置上
#let teacher-sign(sign-image: none, date: datetime) = {
  place(right + bottom)[
    指导教师签字：#h(5em) #box(sign-image, height: 1.15em) \
    #datetime-display-cn-declare(date)
    #h(3em)
  ]
}

#let review-conclusion(teachers, sign-image: none, date: datetime) = {
  let teacher-table-rows = ()
  for teacher in teachers {
    teacher-table-rows += (teacher.name, teacher.title, teacher.workplace)
  }
  set table(stroke: (x, y) => {
    if y == 0 {
      (
        top: (
          dash: "dashed",
          thickness: 0.5pt,
        ),
        left: (
          thickness: 0.5pt,
        ),
        right: (
          thickness: 0.5pt,
        ),
      )
    } else {
      (top: 0.5pt, bottom: 0.5pt, left: 0.5pt, right: 0.5pt)
    }
  })

  stack(dir: ttb)[
    #table(
      columns: (1.53fr, 1.2fr, 3.56fr),
      rows: (2.2em,) * 10,
      inset: 10pt,
      align: center,
      table.cell(colspan: 3)[审查小组意见],
      table.cell(colspan: 3)[开题报告审查小组成员名单], [姓 名], [职 称], [工 作 单 位],
      ..teacher-table-rows,
    )
    #set table(stroke: (x, y) => {
      (top: 0.5pt, bottom: 0.5pt, left: 0.5pt, right: 0.5pt)
    })
    #v(-1.2em)
    #table(
      columns: 4fr
    )[
      #v(1em)
      #set text(weight: "bold")
      审查结论
      #v(5em)

      #show table: set align(center)
      #table(
        columns: (auto, auto),
        inset: 10pt,
        stroke: none,
        align: left,
        [合格，修改后可以进入学位论文写作阶段], [#box(width: 10pt, height: 10pt, stroke: 0.5pt)],

        [ 不合格，需再次进行学位论文开题报告], [#box(width: 10pt, height: 10pt, stroke: 0.5pt)],
      )

      #v(15em)

      #place(bottom + right)[
        #grid(
          columns: 2,
          rows: 2,
          gutter: 2em,
          [组长签字：], [#box(sign-image)],
          grid.cell(colspan: 2)[
            单位公章：#h(2em)
            #datetime-display-cn-declare(date)
          ],
        )
        #v(1em)
      ]
    ]
  ]
}



//! Start with your configuration here

#cover(
  title: (school: "东北师范大学", type: "研究生学位论文开题报告"),
  author-info: (
    title: "这是开题报告的模板",
    name: "张三",
    direction: "深度学习理论",
    major: "计算机科学与技术",
    grade: "2024 级",
    level: "硕士生",
    type: "学术学位",
    supervisor: "李四",
    unit: "信息科学与技术学院",
  ),
)

#command

#show: doc

//! Start writing here

= 研究背景（分析本选题范畴内尚未得到较好解决的学术或实践难题，阐述选题的缘起与依据）

#pagebreak()
= 文献综述（系统梳理本选题相关的具有代表性的文献，分析相关研究的发展脉络与进展，评述已有研究存在的问题与不足）

#pagebreak()
= 研究问题（提出本论文拟回答的核心问题及具体研究问题）

#pagebreak()
= 研究意义（阐述本研究可能的理论贡献与实践价值）

#pagebreak()
= 研究设计（针对研究问题，详细阐述本选题的研究内容、基本思路或总体框架、理论基础、具体研究方案等）


#pagebreak()
= 进度安排（按照时间顺序，就研究的进度做出具体的规划）

#pagebreak()
#nenu-bibliography(bibliography: bibliography.with("references.bib"))


//! 在这里填入自己的签名文件路径
#teacher-sign(
  // image("sign.svg", height: 2em),
  date: datetime.today(),
)

#pagebreak()

#review-conclusion(
  (
    (
      name: "张三",
      title: "讲师",
      workplace: "东北师范大学",
    ),
    (
      name: "李四",
      title: "教授",
      workplace: "北京大学",
    ),
    (
      name: "王五",
      title: "教授",
      workplace: "复旦大学",
    ),
    (
      name: "赵六",
      title: "副教授",
      workplace: "南京大学",
    ),
    (
      name: "孙七",
      title: "讲师",
      workplace: "浙江大学",
    ),
  ),
  // image("sign.svg", height: 2em),
  date: datetime.today(),
)
