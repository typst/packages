#import "../utils/style.typ": font_family, font_size
#import "../utils/invisible-heading.typ": invisible-heading
#import "../utils/justify-text.typ": justify-text
//! 成果页
//! 1. 标题: 黑体三号，居中无缩进，大纲级别1级，段前48磅，段后24磅，1.5倍行距
//! 2. 内容: 中文字体为宋体，英文和数字为Times New Roman字体，小四号，大纲级别正文文本，居中无缩进，段前0磅，段后0磅，1.5倍行距。
#let decision(
  //? thesis 传入的参数
  info: (:),
  anonymous: false,
  twoside: false,
  fonts: (:),
  //? 其他参数
  comments: (:),
  outlined: true,
  outline-title: ("导师（组）对学位论文的评语", "答辩委员会决议书"),
) = {
  //! 1.  默认参数

  info = (
    (
      title: "基于 Typst 的东北师范大学学位论文模板",
      grade: "20XX",
      student-id: "1234567890",
      author: "张三",
      secret-level: "公开",
      department: "信息科学与技术学院",
      discipline: "计算机科学与技术",
      major: "计算机技术",
      field: "人工智能",
      supervisor: ("李四", "教授"),
      submit-date: datetime.today(),
    )
      + info
  )

  comments = (
    (
      supervisor: "导师的评语",
      committee: "委员会的评语",
    )
      + comments
  )

  fonts = font_family + fonts

  if type(info.title) == str {
    info.title = info.title.split("\n")
  }

  //! 2. 导师（组）对学位论文的评语

  pagebreak(weak: true, to: if twoside { "odd" })

  invisible-heading(level: 1, outlined: outlined, outline-title.at(0))
  set align(center)
  set par(leading: 1.5em, justify: true)
  {
    // FIXME 这里的 -48 磅需要被修复，大概是因为标题的规则被二次应用了
    v(-48pt)
    set text(font: fonts.黑体, size: font_size.三号)
    outline-title.at(0)
  }

  //! 表格渲染

  show grid.cell: it => {
    set text(font: fonts.宋体, size: font_size.小四)
    set par(leading: 1.5em, spacing: 1.5em)
    pad(x: 6pt, y: 12pt, it) // 添加水平和垂直内边距
  }

  grid(
    columns: (6em, 1fr, 6em, 1fr),
    stroke: 1pt + black,
    justify-text("论文题目"),
    grid.cell(colspan: 3)[#info.title.intersperse("\n").sum()],
    justify-text("作者姓名"),
    info.author,
    justify-text("指导教师"),
    info.supervisor.intersperse(" ").sum(),
    grid.cell(colspan: 4)[
      #set par(first-line-indent: 2em, justify: true)
      #set align(start)

      导师（组）对学位论文的评语：

      #comments.supervisor
      #v(40em)
    ],
  )

  pagebreak()

  invisible-heading(level: 1, outlined: outlined, outline-title.at(1))
  {
    // FIXME 这里的 -48 磅需要被修复，大概是因为标题的规则被二次应用了
    v(-48pt)
    set text(font: fonts.黑体, size: font_size.三号)
    outline-title.at(1)
  }

  grid(
    columns: (6em, 1fr, 6em, 1fr),
    stroke: 1pt + black,
    justify-text("论文题目"),
    grid.cell(colspan: 3)[#info.title.intersperse("\n").sum()],
    justify-text("作者姓名"),
    info.author,
    justify-text("指导教师"),
    info.supervisor.intersperse(" ").sum(),
    grid.cell(colspan: 4)[
      #set par(first-line-indent: 2em, justify: true)
      #set align(start)

      答辩委员会对学位论文及答辩情况的评语：

      #comments.committee
      #v(40em)
    ],
  )
}
