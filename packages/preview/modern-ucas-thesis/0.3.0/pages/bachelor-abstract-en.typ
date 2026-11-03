#import "../utils/style.typ": get-fonts, 字号, 行距
#import "../utils/page-foreground.typ": preface-foreground
#import "../utils/double-underline.typ": double-underline
#import "../utils/invisible-heading.typ": invisible-heading
#import "../utils/supervisor.typ": normalize-supervisors

// 本科生英文摘要页
#let bachelor-abstract-en(
  // documentclass 传入的参数
  anonymous: false,
  twoside: false,
  fontset: "mac",
  fonts: (:),
  info: (:),
  // 其他参数
  keywords: (),
  outline-title: "Abstract",
  outlined: false,
  anonymous-info-keys: ("author-en", "supervisors-en"),
  // Typst leading/spacing 是额外间隙：取 1.25 倍行距等值（与研究生页同口径）。
  leading: 行距.正文,
  spacing: 行距.正文,
  body,
) = {
  // 1.  默认参数
  fonts = get-fonts(fontset) + fonts
  info = (
    (
      title-en: "UCAS Thesis Template for Typst",
      author-en: "Zhang San",
      department-en: "XX Department",
      major-en: "XX Major",
      supervisors-en: (
        (name: "Si Li", title: "Professor", affiliation: ""),
      ),
    )
      + info
  )

  // 2.  对参数进行处理
  // 2.1 如果是字符串，则使用换行符将标题分隔为列表
  if type(info.title-en) == str {
    info.title-en = info.title-en.split("\n")
  }
  // 2.2 导师信息归一化为字典列表
  info.supervisors-en = normalize-supervisors(info.supervisors-en)

  // 3.  内置辅助函数
  let info-value(key, body) = {
    if (not anonymous or (key not in anonymous-info-keys)) {
      body
    }
  }

  // 4.  正式渲染
  [
    // 起始三件套（P30）：先清样式（填充页干净），再换页，最后重申前言域样式。
    #set page(numbering: none, foreground: none)
    #pagebreak(weak: true, to: if twoside { "odd" })
    #set page(
      numbering: "I",
      footer: none,
      foreground: preface-foreground(info: info, fonts: fonts),
    )

    #set text(font: fonts.楷体, size: 字号.小四)
    #set par(leading: leading, justify: true)
    #set par(spacing: spacing)

    // 标记一个不可见的标题用于目录生成
    #invisible-heading(level: 1, outlined: outlined, outline-title)

    #align(center)[
      #set text(size: 字号.小二, weight: "bold")

      // 关键词与摘要间空一行：一行高度 = 正文基线距 21.6pt
      #v(21.6pt)

      #double-underline[*中国科学院大学本科生毕业论文（设计、作品）英文摘要*]
    ]

    #v(2pt)

    THESIS: #info-value("title-en", (("",) + info.title-en).sum())

    DEPARTMENT: #info-value("department-en", info.department-en)

    SPECIALIZATION: #info-value("major-en", info.major-en)

    UNDERGRADUATE: #info-value("author-en", info.author-en)

    MENTOR: #info-value(
      "supervisors-en",
      info.supervisors-en.map(s => {
        // 英文习惯职称在前（如 "Professor Si Li"），与英文封面一致
        (s.at("title", default: ""), s.at("name", default: "")).filter(x => x != "").join(" ")
      }).filter(s => s != "").join(", "),
    )

    ABSTRACT: #body

    #v(1em)

    #strong[Key Words]: #(("",) + keywords.intersperse(", ")).sum()
  ]

  // 结尾 reset（P30）：覆盖后续自定义组装顺序下可能出现的填充页；
  // 标准顺序下由下一部分起始 reset 覆盖，此处幂等、无副作用。
  set page(numbering: none, foreground: none)
}
