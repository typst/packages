// ===========================
// HFUT 课程设计报告模板库
// ===========================

// ===========================
// 第三方库导入
// ===========================
// 导入格式化工具库（包含中文加粗、斜体、下划线等功能）
#import "@preview/zh-format:0.1.1": *
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
  show-cover: true, // 显示封面页
  show-abstract: true, // 显示摘要页
  show-contents: true, // 显示目录页
  show-references: true, // 显示参考文献
  show-appendix: true, // 显示附录 // 页眉配置参数
  header-logo-height: 0.8cm,
  header-title-size: 9pt,
  header-line-stroke: 0.4pt,
  font-text: ("Times New Roman", "SimSun"), // 正文字体（西文 + 中文，换字体改这里）
  font-heading: ("Times New Roman", "SimHei"), // 一级标题与图表标题字体
  font-codeblock: none, // 代码块与行内代码字体；none = 等宽西文 + font-text 的中文
  // equation 计数
  body,
) = {
  // ===========================
  // 全局样式配置
  // ===========================

  // 应用中文格式化（粗体、下划线、斜体）
  show: zh-format

  // 中文排版：正文与摘要每段缩进 2 字符
  let cn-indent = (amount: 2em, all: true)

  // 文档元数据
  set document(author: author, title: title)

  // 页面设置
  set page(
    paper: "a4",
    margin: (top: 2.5cm, bottom: 2.5cm, left: 2.2cm, right: 2.2cm),
  )

  // 正文字体设置：Times New Roman + 宋体
  set text(
    font: font-text,
    lang: "zh",
    size: 12pt,
  )

  // 段落格式设置：两端对齐
  set par(
    justify: true,
    leading: 0.65em,
    first-line-indent: 0em, // 封面、目录、页眉页脚保持顶格
  )

  // 标题间距设置
  show heading: set block(above: 1.4em, below: 1em)

  // 列表缩进两字符，与正文首行缩进一致
  set list(indent: 2em)
  set enum(indent: 2em)

  // 代码块与行内代码：等宽西文 + 正文字体的中文（否则中文会落到未知的兜底字体）
  show raw: set text(font: if font-codeblock == none {
    ("DejaVu Sans Mono",) + font-text.slice(1)
  } else {
    font-codeblock
  })

  // 代码块样式设置
  show raw.where(block: true): block.with(
    fill: luma(246),
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

  // 每个标题时重置图表与公式计数器（figure 的计数器按 kind 分开，需逐个重置）
  show heading: it => {
    for kind in (image, table, raw) {
      counter(figure.where(kind: kind)).update(0)
    }
    counter(math.equation).update(0)
    it
  }

  // 块级公式按章节编号（形如 (1.1)）：行内公式不编号；
  // label 请写成 <eqt:名字>（与图表的 <fig:…>/<tbl:…> 同理），引用写 @eqt:名字
  show math.equation.where(block: true): set math.equation(
    numbering: n => numbering("(1.1)", counter(heading).get().at(0, default: 0), n),
  )

  // 图表标题样式
  show figure.caption: set text(font: font-heading, size: 10pt)

  // 表格样式
  show table: set text(size: 10pt)

  // ===========================
  // 封面页
  // ===========================
  if show-cover {
    set align(center)
    set page(header: none, footer: none, numbering: none)

    v(0.5cm)
    image("template/assets/HFUT_badge_zh&en_Vertical.svg", width: 7cm)
    v(1cm)

    text(22pt, font: font-text)[
      *#underline[#title] 课程设计报告*
    ]

    v(3cm)

    grid(
      columns: (auto, 14em),
      rows: auto,
      gutter: 1em,
      row-gutter: 1.2em,
      align: (right, center),

      text(18pt, font: font-text)[*学　　院：*],
      u(width: 15em, offset: 0.35em)[#text(16pt)[#department]],

      text(18pt, font: font-text)[*专　　业：*],
      u(width: 15em, offset: 0.35em)[#text(16pt)[#major]],

      text(18pt, font: font-text)[*班　　级：*],
      u(width: 15em, offset: 0.35em)[#text(16pt)[#class]],

      text(18pt, font: font-text)[*姓　　名：*],
      u(width: 15em, offset: 0.35em)[#text(16pt)[#author]],

      text(18pt, font: font-text)[*学　　号：*],
      u(width: 15em, offset: 0.35em)[#text(16pt)[#student-id]],

      text(18pt, font: font-text)[*指导教师：*],
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
    context {
      let found = query(metadata).filter(it => {
        type(it.value) == dictionary and "hfut-abstract" in it.value
      })
      if found.len() > 0 {
        let d = found.first().value
        set page(header: none, footer: none, numbering: none)
        set align(center)

        text(18pt, font: font-text)[*摘　要*]
        v(1.5em)

        set align(left)
        set par(first-line-indent: cn-indent)

        d.hfut-abstract
        v(2em)

        if d.hfut-keywords.len() > 0 {
          set par(first-line-indent: 0em)
          text(font: font-text)[*关键词：*] + d.hfut-keywords.join("；")
        }

        pagebreak()
      }
    }
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
          #text(15pt, font: font-text)[*#title*]
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
      #text(18pt, font: font-text)[*目　录*]
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
    set text(font: font-heading, weight: "bold", size: 18pt)
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
    set text(font: font-text, weight: "bold", size: 15pt)
    if it.numbering != none {
      block[#counter(heading).display() #it.body]
    } else {
      block[#it.body]
    }
  }

  show heading.where(level: 3): it => {
    // 三级标题：宋体加粗，保持层次一致性
    set text(font: font-text, weight: "bold", size: 13pt)
    if it.numbering != none {
      block[#counter(heading).display() #it.body]
    } else {
      block[#it.body]
    }
  }

  // ===========================
  // 正文内容
  // ===========================
  set par(first-line-indent: cn-indent)

  state("hfut-show-references", true).update(show-references)
  state("hfut-show-appendix", true).update(show-appendix)

  body
}

// ===========================
// 章节标记函数
// ===========================
// 摘要页（写在正文最前面）#abstract(keywords: ("关键词1", "关键词2"))[ 摘要正文... ]
#let abstract(body, keywords: ()) = metadata((
  hfut-abstract: body,
  hfut-keywords: keywords,
))

// 参考文献（写在正文末尾）#references[ 1. 作者. 文献标题[Z]. 出版地: 出版者, 年份. ]
#let references(body) = context {
  if state("hfut-show-references", true).get() {
    pagebreak()
    // 参考文献不参与章节编号，内部标题同样不编号（目录中仍会列出）
    set heading(numbering: none)
    heading(level: 1)[参考文献]
    body
  }
}

// 附录（写在正文末尾）#appendix[ == 附录 A：数据 == ]
#let appendix(body) = context {
  if state("hfut-show-appendix", true).get() {
    pagebreak()
    // 附录不参与章节编号，内部标题同样不编号（目录中仍会列出）
    set heading(numbering: none)
    heading(level: 1)[附录]
    body
  }
}
