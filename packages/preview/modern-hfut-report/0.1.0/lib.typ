// ===========================
// HFUT 课程设计报告模板库
// ===========================

// ===========================
// 第三方库导入
// ===========================
// 导入i-figured库用于公式和图表编号管理
#import "@preview/i-figured:0.2.4"
// 导入格式化工具库（包含中文加粗、斜体、下划线等功能）
#import "@preview/zh-format:0.1.0": *

// ===========================
// 主函数：报告模板配置
// ===========================
#let hfut-report(
  // 基本信息（默认为空）
  title: "",
  department: "",
  major: "",
  class: "",
  author: "",
  student-id: "",
  supervisor: "",
  date: "",
  // 摘要和关键词
  abstract: [摘要内容...],
  keywords: ("关键词1", "关键词2"),
  // 摘要页开关（true：显示摘要页，false：不显示摘要页）
  show-abstract: true,
  // 目录页开关（true：显示目录页，false：不显示目录页）
  show-contents: true,
  // 页眉配置参数
  header-logo-height: 0.8cm,
  header-title-size: 9pt,
  header-line-stroke: 0.4pt,
  // 段落首行缩进配置
  first-line-indent: 0em,
  // equation 计数
  show-equation: i-figured.show-equation,
  body,
) = {
  // ===========================
  // 全局样式配置
  // ===========================

  // 应用中文格式化（粗体、下划线、斜体）
  show: zh-format

  // 文档元数据
  set document(author: author, title: title)

  // 页面设置
  set page(
    paper: "a4",
    margin: (top: 2.5cm, bottom: 2.5cm, left: 2.2cm, right: 2.2cm),
  )

  // 正文字体设置：Times New Roman + 宋体
  set text(
    font: ("Times New Roman", "SimSun"),
    lang: "zh",
    size: 12pt,
  )

  // 段落格式设置：两端对齐
  set par(
    justify: true,
    leading: 0.65em,
    first-line-indent: 0em, // 默认不缩进
  )

  // 标题间距设置
  show heading: set block(above: 1.4em, below: 1em)

  // 代码块样式设置
  show raw.where(block: true): block.with(
    fill: luma(240),
    inset: 10pt,
    radius: 4pt,
    width: 100%,
    stroke: 0.5pt + luma(200),
  )

  // 行内代码样式
  show raw.where(block: false): box.with(
    fill: luma(240),
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt,
  )

  // 脚注格式设置：[1] [2] 格式的蓝色上标
  show footnote: set text(blue)
  set footnote(numbering: "[1]")

  // 每个标题时重置计数器
  show heading: i-figured.reset-counters

  // 设置 equation 的编号（只对块级公式编号，<-> 标签取消编号）
  show math.equation.where(block: true): show-equation.with(
    only-labeled: false,
    unnumbered-label: "-",
  )

  // 图表标题样式
  show figure.caption: set text(font: ("Times New Roman", "SimHei"), size: 10pt)

  // 表格样式
  show table: set text(size: 10pt)

  // ===========================
  // 封面页
  // ===========================
  {
    set align(center)
    set page(header: none, footer: none, numbering: none)

    v(0.5cm)
    image("template/assets/HFUT_badge_zh&en_Vertical.svg", width: 7cm)
    v(1cm)

    text(22pt, font: ("Times New Roman", "SimSun"))[
      *#underline[#title] 课程设计报告*
    ]

    v(3cm)

    grid(
      columns: (auto, 14em),
      rows: auto,
      gutter: 1em,
      row-gutter: 1.2em,
      align: (right, center),

      text(18pt, font: ("Times New Roman", "SimSun"))[*学　　院：*],
      u(width: 15em, offset: 0.35em)[#text(16pt)[#department]],

      text(18pt, font: ("Times New Roman", "SimSun"))[*专　　业：*],
      u(width: 15em, offset: 0.35em)[#text(16pt)[#major]],

      text(18pt, font: ("Times New Roman", "SimSun"))[*班　　级：*],
      u(width: 15em, offset: 0.35em)[#text(16pt)[#class]],

      text(18pt, font: ("Times New Roman", "SimSun"))[*姓　　名：*],
      u(width: 15em, offset: 0.35em)[#text(16pt)[#author]],

      text(18pt, font: ("Times New Roman", "SimSun"))[*学　　号：*],
      u(width: 15em, offset: 0.35em)[#text(16pt)[#student-id]],

      text(18pt, font: ("Times New Roman", "SimSun"))[*指导教师：*],
      u(width: 15em, offset: 0.35em)[#text(16pt)[#supervisor]],
    )

    v(2cm)
    text(16pt)[#if date == "today" { datetime.today().display("[year]年[month]月[day]日") } else { date }]

    pagebreak()
  }

  // ===========================
  // 摘要页
  // ===========================
  if show-abstract {
    set page(header: none, footer: none, numbering: none)
    set align(center)

    text(18pt, font: ("Times New Roman", "SimSun"))[*摘　要*]
    v(1.5em)

    set align(left)
    set par(first-line-indent: 0em)

    abstract
    v(2em)

    set par(first-line-indent: 0em)
    text(font: ("Times New Roman", "SimSun"))[*关键词：*] + keywords.join("；")

    pagebreak()
  }

  // ===========================
  // 正文页眉页脚设置
  // ===========================
  set page(
    header: [
      #grid(
        columns: (auto, 1fr),
        align: (left + top, right + top),
        gutter: 0.5em,
        image("template/assets/HFUT_badge_zh_Horizontal.svg", height: header-logo-height),
        [
          #v(0.8em)
          #text(15pt, font: ("Times New Roman", "SimSun"))[*#title*]
        ],
      )
      #v(-1.0em)
      #line(length: 100%, stroke: header-line-stroke)
    ],
    footer: context align(center)[
      #text(10pt)[合肥工业大学 - 第 #counter(page).display("1") 页]
    ],
    numbering: "1",
  )

  counter(page).update(1)

  // ===========================
  // 目录页
  // ===========================
  if show-contents {
    // 居中显示目录标题
    align(center)[
      #text(18pt, font: ("Times New Roman", "SimSun"))[*目　录*]
    ]

    v(1.5em)

    outline(
      title: none,
      depth: 3,
      indent: auto,
    )

    pagebreak()
  }

  // ===========================
  // 标题样式配置
  // ===========================
  // 设置标题自动编号
  set heading(numbering: "1.1.1")

  show heading.where(level: 1): it => {
    // 一级标题：黑体加粗，视觉突出
    set text(font: ("Times New Roman", "SimHei"), weight: "bold", size: 18pt)
    set align(center)

    v(0.5em)
    if it.numbering != none {
      block[#counter(heading).display() #it.body]
    } else {
      block[#it.body]
    }
    v(0.5em)
  }

  show heading.where(level: 2): it => {
    // 二级标题：宋体加粗，避免与一级标题冲突
    set text(font: ("Times New Roman", "SimSun"), weight: "bold", size: 15pt)
    if it.numbering != none {
      block[#counter(heading).display() #it.body]
    } else {
      block[#it.body]
    }
  }

  show heading.where(level: 3): it => {
    // 三级标题：宋体加粗，保持层次一致性
    set text(font: ("Times New Roman", "SimSun"), weight: "bold", size: 13pt)
    if it.numbering != none {
      block[#counter(heading).display() #it.body]
    } else {
      block[#it.body]
    }
  }

  // ===========================
  // 正文内容
  // ===========================
  body
}
