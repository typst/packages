// TODO [@Dian Ling](https://github.com/virgiling) 重写这部分内容

#import "../utils/style.typ": font_family, font_size
#import "../utils/justify-text.typ": justify-text

#let master-comm-page(
  //* 传入参数
  info: (:),
  fonts: (:),
  anonymous: false,
  twoside: false,
  //* 其他参数
  long_cell_height: 3em,
  cell_height: 2.7em,
  title_size: font_size.三号,
  cell_size: font_size.小四,
  weight_style: "bold",
  // 列宽定义
  label_col_width: 4em, // 标签列宽度（如"论文题目"、"论文评阅人"等）
  role_col_width: 0.2fr, // 角色列宽度（主席、委员）
  name_col_width: 0.8fr, // 姓名列宽度
  workplace_col_width: 1fr, // 工作单位列宽度
  evaluation_col_width: 1fr, // 评价/职称列宽度
  // 网格样式
  grid_stroke_style: 1pt + black,
  grid_cell_align: center + horizon,
  label_col_grid_cell_inset: (top: 1em, bottom: 1em),
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

  fonts = font_family + fonts
  let num_reviewers = info.reviewers.len()
  let num_committee_members = info.committee-members.len()
  let justify-text = justify-text.with(with-tail: false, dir: ttb)
  let get_stroke(sides: ("top", "bottom", "left", "right")) = {
    let result = (top: none, bottom: none, left: none, right: none)
    for side in sides {
      result.insert(side, grid_stroke_style)
    }
    result
  }

  show grid: it => {
    set text(font: fonts.宋体, size: font_size.小四)
    set align(grid_cell_align)
    it
  }

  [
    #set align(center)
    #set text(font: fonts.黑体, size: font_size.三号, weight: "bold")
    #set par(leading: 1.5em)
    #v(48pt)
    学位论文评阅专家及答辩委员会人员信息
    #v(24pt)
  ]


  grid(
    rows: (long_cell_height,) * 3 + (cell_height,) * 14,
    columns: (label_col_width, role_col_width, name_col_width, workplace_col_width, evaluation_col_width),
    stroke: get_stroke(sides: ("top", "left", "right", "bottom")),
    grid.cell()[#text(weight: weight_style)[论  文 #linebreak() 题 目]],
    grid.cell(colspan: 4)[#info.title.intersperse("\n").sum()],
    grid.cell()[#text(weight: weight_style)[作 者 #linebreak() 姓 名]], grid.cell(colspan: 4)[#info.author],
    grid.cell()[#text(weight: weight_style)[指导 #linebreak() 教师]],
    grid.cell(colspan: 4)[#info.supervisor.intersperse(" ").sum()],

    grid.cell(rowspan: 6, inset: label_col_grid_cell_inset)[
      #set text(weight: weight_style)
      #justify-text("论文评阅人")
    ],
    grid.cell(colspan: 2)[#text(weight: weight_style)[姓 名]],
    grid.cell()[#text(weight: weight_style)[工作单位/职称]],
    grid.cell()[#text(weight: weight_style)[总体评价]],
    ..for i in range(0, num_reviewers) {
      (
        grid.cell(colspan: 2)[#info.reviewers.at(i).name],
        grid.cell()[#info.reviewers.at(i).workplace],
        grid.cell()[#info.reviewers.at(i).evaluation],
      )
    },
    grid.cell(rowspan: 8, inset: label_col_grid_cell_inset)[
      #set text(weight: weight_style)
      #justify-text("学位论文答辩委员会")
    ],
    grid.cell(colspan: 2)[#text(weight: weight_style)[姓 名]],
    grid.cell()[#text(weight: weight_style)[工作单位]],
    grid.cell()[#text(weight: weight_style)[职 称]],

    grid.cell()[#text(weight: weight_style)[主#linebreak()席]],
    grid.cell()[#info.committee-members.at(0).name],
    grid.cell()[#info.committee-members.at(0).workplace],
    grid.cell()[#info.committee-members.at(0).title],
    grid.cell(rowspan: 6)[#text(weight: weight_style)[委#linebreak() 员]],

    ..for i in range(1, num_committee_members) {
      (
        grid.cell()[#info.committee-members.at(i).name],
        grid.cell()[#info.committee-members.at(i).workplace],
        grid.cell()[#info.committee-members.at(i).title],
      )
    },
  )
}
