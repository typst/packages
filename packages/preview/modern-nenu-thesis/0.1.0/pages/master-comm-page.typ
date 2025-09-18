// TODO [@Dian Ling](https://github.com/virgiling) 重写这部分内容

#import "../utils/style.typ": font-family, font-size
#import "../utils/justify-text.typ": justify-text

/// 硕博委员会页
/// -> content
#let master-comm-page(
  /// 论文信息，通过 @@thesis() 传入
  /// -> dictionary
  info: (:),
  /// 自定义字体
  /// 在 @@font-size 中我们加入了一些默认值，这里用于添加自定义的字体
  /// 但注意需要满足 @@font-size 的格式:
  ///
  /// `fonts = ( 宋体: ("Times New Romans"), 黑体: ( "Arial"), 楷体: ("KaiTi"), 仿宋: ("FangSong"), 等宽: ("Courier New")`
  /// -> dictionary
  fonts: (:),
  /// 盲审模式
  ///
  /// 隐藏学校/作者/导师等一切信息，满足盲审要求
  /// -> bool
  anonymous: false,
  /// 双面模式
  ///
  /// 会在每一个部分后加入空白页，便于打印
  /// -> bool
  twoside: false,
  //* 其他参数
  /// 前三行的表格的高度
  /// -> length
  long-cell-height: 3em,
  /// 第四行以及之后的表格高度
  ///
  /// -> length
  cell-height: 2.7em,
  /// 标题的字号
  /// -> font-size
  title-size: font-size.三号,
  /// 表格的字号
  /// -> font-size
  cell-size: font-size.小四,
  /// 表格的字体 @@font-family
  /// -> font-family
  cell-font: font-family.宋体,
  /// 粗体的样式
  ///
  /// -> str|int
  weight-style: "bold",
  // 列宽定义
  /// 第一列（如"论文题目"、"论文评阅人"等）的宽度
  /// -> length
  label-col-width: 4em,
  /// 主席/委员 列的宽度, 相对于主席的名字的列的宽度
  /// -> fraction
  role-col-width: 0.2fr,
  /// 主席名字的列的宽度，相对与 主席/委员 列的宽度
  ///
  /// -> fraction
  name-col-width: 0.8fr,
  /// 工作单位列的宽度，
  ///
  /// -> fraction
  workplace-col-width: 1fr,
  /// 评价/职称列的宽度
  ///
  /// -> fraction
  evaluation-col-width: 1fr,
  // 网格样式
  /// 表格边框的样式
  ///
  /// -> none|length|color|gradient|array|stroke|tiling|dictionary|function
  grid-stroke-style: 1pt + black,
  /// 表格内单元格的对齐方式
  ///
  /// -> alignment
  grid-cell-align: center + horizon,
  /// 第一列（如"论文题目"、"论文评阅人"等）的单元格内边距
  ///
  /// -> auto| relative | dictionary
  label-col-grid-cell-inset: (top: 1em, bottom: 1em),
) = {
  info = (
    (
      title: "论文题目",
      author: "作者姓名",
      supervisor: ("李四", "教授"),
      reviewers: (
        (name: "张三", workplace: "工作单位", evaluation: "总体评价"),
        (name: "李四", workplace: "工作单位", evaluation: "总体评价"),
        (name: "王五", workplace: "工作单位", evaluation: "总体评价"),
        (name: "赵六", workplace: "工作单位", evaluation: "总体评价"),
        (name: "孙七", workplace: "工作单位", evaluation: "总体评价"),
      ),
      committee-members: (
        (name: "张三", workplace: "工作单位", title: "职称"),
        (name: "李四", workplace: "工作单位", title: "职称"),
        (name: "王五", workplace: "工作单位", title: "职称"),
        (name: "赵六", workplace: "工作单位", title: "职称"),
        (name: "孙七", workplace: "工作单位", title: "职称"),
      ),
    )
      + info
  )

  if type(info.title) == str {
    info.title = info.title.split("\n")
  }


  if anonymous {
    return
  }

  pagebreak(weak: true, to: if twoside { "odd" })

  fonts = font-family + fonts
  let num-reviewers = info.reviewers.len()
  let num-committee-members = info.committee-members.len()
  let justify-text = justify-text.with(with-tail: false, dir: ttb)
  let get-stroke(sides: ("top", "bottom", "left", "right")) = {
    let result = (top: none, bottom: none, left: none, right: none)
    for side in sides {
      result.insert(side, grid-stroke-style)
    }
    result
  }

  show grid: it => {
    set text(font: fonts.宋体, size: font-size.小四)
    set align(grid-cell-align)
    it
  }

  [
    #set align(center)
    #set text(font: fonts.黑体, size: font-size.三号, weight: "bold")
    #set par(leading: 1.5em)
    #v(48pt)
    学位论文评阅专家及答辩委员会人员信息
    #v(24pt)
  ]


  grid(
    rows: (long-cell-height,) * 3 + (cell-height,) * 14,
    columns: (label-col-width, role-col-width, name-col-width, workplace-col-width, evaluation-col-width),
    stroke: get-stroke(sides: ("top", "left", "right", "bottom")),
    grid.cell(text(weight: weight-style)[论  文 #linebreak() 题 目]),
    grid.cell(colspan: 4, info.title.intersperse("\n").sum()),
    grid.cell(text(weight: weight-style)[作 者 #linebreak() 姓 名]), grid.cell(colspan: 4, info.author),
    grid.cell(text(weight: weight-style)[指导 #linebreak() 教师]),
    grid.cell(colspan: 4, info.supervisor.intersperse(" ").sum()),

    grid.cell(rowspan: 6, inset: label-col-grid-cell-inset)[
      #text(weight: weight-style, justify-text("论文评阅人"))
    ],
    grid.cell(colspan: 2, text(weight: weight-style)[姓 名]),
    grid.cell(text(weight: weight-style)[工作单位/职称]),
    grid.cell(text(weight: weight-style)[总体评价]),
    ..for i in range(0, num-reviewers) {
      (
        grid.cell(colspan: 2, info.reviewers.at(i).name),
        grid.cell(info.reviewers.at(i).workplace),
        grid.cell(info.reviewers.at(i).evaluation),
      )
    },
    grid.cell(rowspan: 8, inset: label-col-grid-cell-inset)[
      #text(weight: weight-style, justify-text("学位论文答辩委员会"))
    ],
    grid.cell(colspan: 2, text(weight: weight-style)[姓 名]),
    grid.cell(text(weight: weight-style)[工作单位]),
    grid.cell(text(weight: weight-style)[职 称]),

    grid.cell(text(weight: weight-style)[主#linebreak()席]),
    grid.cell(info.committee-members.at(0).name),
    grid.cell(info.committee-members.at(0).workplace),
    grid.cell(info.committee-members.at(0).title),
    grid.cell(rowspan: 6, text(weight: weight-style)[委#linebreak() 员]),

    ..for i in range(1, num-committee-members) {
      (
        grid.cell(info.committee-members.at(i).name),
        grid.cell(info.committee-members.at(i).workplace),
        grid.cell(info.committee-members.at(i).title),
      )
    },
  )
}
