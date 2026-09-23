#import "../utils/style.typ": get-fonts, 字号, 行距
#import "../utils/page-foreground.typ": preface-foreground
#import "../utils/double-underline.typ": double-underline
#import "../utils/invisible-heading.typ": invisible-heading
#import "../utils/supervisor.typ": normalize-supervisors


// 本科生中文摘要页
#let bachelor-abstract(
  // documentclass 传入的参数
  anonymous: false,
  twoside: false,
  fontset: "mac",
  fonts: (:),
  info: (:),
  // 其他参数
  keywords: (),
  outline-title: [摘#h(1em)要],
  outlined: false,
  anonymous-info-keys: ("author", "supervisors"),
  // Typst leading/spacing 是额外间隙：取 1.25 倍行距等值（与研究生页同口径）。
  leading: 行距.正文,
  spacing: 行距.正文,
  body,
) = {
  // 1.  默认参数
  fonts = get-fonts(fontset) + fonts
  info = (
    (
      title: ("基于 Typst 的", "中国科学院大学学位论文"),
      author: "张三",
      department: "某学院",
      major: "某专业",
      supervisors: (
        (name: "李四", title: "教授", affiliation: ""),
      ),
    )
      + info
  )

  // 2.  对参数进行处理
  // 2.1 如果是字符串，则使用换行符将标题分隔为列表
  if type(info.title) == str {
    info.title = info.title.split("\n")
  }
  // 2.2 导师信息归一化为字典列表
  info.supervisors = normalize-supervisors(info.supervisors)

  // 3.  内置辅助函数
  let info-value(key, body) = {
    if (not anonymous or (key not in anonymous-info-keys)) {
      body
    }
  }

  // 4.  正式渲染
  // 起始三件套（P30）：先清样式（填充页干净），再换页，最后重申前言域样式。
  set page(numbering: none, foreground: none)
  pagebreak(weak: true, to: if twoside { "odd" })
  set page(
    numbering: "I",
    footer: none,
    foreground: preface-foreground(info: info, fonts: fonts),
  )

  [
    #set text(font: fonts.楷体, size: 字号.小四)
    #set par(leading: leading, justify: true)
    #set par(spacing: spacing)

    // 标记一个不可见的标题用于目录生成
    #invisible-heading(level: 1, outlined: outlined, outline-title)

    #align(center)[
      #set text(size: 字号.小二, weight: "bold")

      // 关键词与摘要间空一行：一行高度 = 正文基线距 21.6pt
      #v(21.6pt)

      #double-underline[*中国科学院大学本科生毕业论文（设计、作品）中文摘要*]
    ]

    *题目：*#info-value("title", (("",) + info.title).sum())

    *院系：*#info-value("department", info.department)

    *专业：*#info-value("major", info.major)

    *本科生姓名：*#info-value("author", info.author)

    *指导教师（姓名、职称）：*#info-value(
      "supervisors",
      info.supervisors.map(s => {
        (s.at("name", default: ""), s.at("title", default: "")).filter(x => x != "").join(" ")
      }).filter(s => s != "").join("，"),
    )

    *摘要：*

    #[
      #set par(first-line-indent: (amount: 2em, all: true))

      #body
    ]

    #v(1em)

    *关键词：*#(("",) + keywords.intersperse("，")).sum()
  ]

  // 结尾 reset（P30）：覆盖后续自定义组装顺序下可能出现的填充页；
  // 标准顺序下由下一部分起始 reset 覆盖，此处幂等、无副作用。
  set page(numbering: none, foreground: none)
}
