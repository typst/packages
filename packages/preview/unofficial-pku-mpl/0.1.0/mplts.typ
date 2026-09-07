// unofficial-pku-mpl --- A Typst template for 'Modern Physics Laboratory' in PKU
//
// 本文件是 PKUMpLtX (mpltx.cls, 基于 revtex4-2) 的 Typst 移植.
// 请阅读 `README.md` 与 `template/main.typ` 后使用.
//
// Copyright (C) 2013--2026. Modern Phys. Lab, School of Phys., Peking Univ.
// 基于 PKUMpLtX (Lin Xuchen <linxc@pku.edu.cn> 等) 的工作, 以 CC BY-SA 4.0 许可.

// ========== 字体配置 ==========
// 对应 mpltx.cls 的 `font` 选项. 默认 `macos`, 与源模板的 `font=macos` 一致.
// Roman=宋体类, Sans=黑体类(苹方), Mono=仿宋类; 斜体分别映射到仿宋/楷体.
#let _fontsets = (
  macos: (
    main: ("New Computer Modern", "Songti SC"),
    // Typst 通过同一字体族的 bold 字重选择 Songti SC Bold 字形。
    bold-main: ("New Computer Modern", "Songti SC"),
    sans: ("New Computer Modern", "PingFang SC"),
    mono: ("STFangsong",),
    // 斜体映射 (xeCJK ItalicFont)
    main-italic: ("New Computer Modern", "STFangsong"),
    bold-main-italic: ("New Computer Modern", "STFangsong"),
    sans-italic: ("New Computer Modern", "Kaiti SC"),
    mono-italic: ("Kaiti SC",),
  ),
  noto: (
    main: ("New Computer Modern", "Noto Serif CJK SC"),
    bold-main: ("New Computer Modern", "Noto Serif CJK SC Bold", "Noto Serif CJK SC"),
    sans: ("New Computer Modern", "Noto Sans CJK SC"),
    mono: ("Noto Serif CJK SC",),
    main-italic: ("Noto Serif CJK SC",),
    bold-main-italic: ("Noto Serif CJK SC",),
    sans-italic: ("Noto Sans CJK SC",),
    mono-italic: ("Noto Serif CJK SC",),
  ),
  fandol: (
    main: ("New Computer Modern", "FandolSong"),
    bold-main: ("New Computer Modern", "FandolSong Bold"),
    sans: ("New Computer Modern", "FandolHei"),
    mono: ("FandolFang",),
    main-italic: ("FandolFang",),
    bold-main-italic: ("FandolFang",),
    sans-italic: ("FandolKai",),
    mono-italic: ("FandolKai",),
  ),
  notofandol: (
    main: ("New Computer Modern", "Noto Serif CJK SC"),
    bold-main: ("New Computer Modern", "Noto Serif CJK SC Bold", "Noto Serif CJK SC"),
    sans: ("New Computer Modern", "Noto Sans CJK SC"),
    mono: ("FandolFang",),
    main-italic: ("FandolFang",),
    bold-main-italic: ("FandolFang",),
    sans-italic: ("FandolKai",),
    mono-italic: ("FandolKai",),
  ),
  windows: (
    main: ("New Computer Modern", "SimSun", "STSong"),
    bold-main: ("New Computer Modern", "SimSun", "STSong"),
    sans: ("New Computer Modern", "Microsoft YaHei", "DengXian"),
    mono: ("FangSong", "STFangsong"),
    main-italic: ("FangSong", "STFangsong"),
    bold-main-italic: ("FangSong", "STFangsong"),
    sans-italic: ("KaiTi", "STKaiti"),
    mono-italic: ("KaiTi", "STKaiti"),
  ),
)

#let _pick-font(font) = {
  if font in _fontsets { _fontsets.at(font) }
  else { _fontsets.macos } // 未知字体回退到 macos
}

// 当前文档使用的字体配置，供 sans()/mono() 等快捷函数使用。
#let _active-fonts = state("mplts-fonts", _fontsets.macos)

#let _appendix-mode = state("mplts-appendix", false)

// 生成与 revtex4-2 一致的层级编号。用 counter(...).at(location) 而不是
// 直接 display 完整层级，避免 Typst 默认的“4.1”出现在正文中。
#let _heading-number(it) = context {
  let values = counter(heading).at(it.location())
  let value = values.at(it.level - 1)
  let appendix = _appendix-mode.get()
  let format = if appendix {
    if it.level == 1 { "A" } else { "1" }
  } else if it.level == 1 {
    "I"
  } else if it.level == 2 {
    "A"
  } else {
    "1"
  }
  let weight = if it.level <= 2 { "bold" } else { "regular" }
  let style = if it.level == 3 { "italic" } else { "normal" }
  let suffix = if appendix and it.level == 1 { ":" } else { "." }
  let number = text(font: "New Computer Modern", weight: weight, style: style)[
    #numbering(format, value)#suffix
  ]
  if appendix and it.level == 1 {
    [附录 #number]
  } else {
    [#number]
  }
}

// ========== 文档级 setup (对应 \documentclass{mpltx} 的全局设置) ==========
// 用法: #show: mplts.with(font: "macos")
#let mplts(doc, font: "macos", quanjiao: false) = {
  let fs = _pick-font(font)
  _active-fonts.update(fs)

  // ----- 页面几何 (geometry: hmargin=2.5cm, top=2cm, bottom=1.6cm, includefoot) -----
  set page(
    paper: "a4",
    margin: (left: 2.5cm, right: 2.5cm, top: 2cm, bottom: 1.6cm),
    numbering: "1",
  )

  // ----- 文本与字体 (12pt 正文, 中文宋体, 英文 Latin Modern 系列) -----
  set text(
    size: 12pt,
    font: fs.main,
    weight: 300,
  )
  // 将常规字重直接设在文档默认值上，避免 show 规则覆盖用户在局部
  // `text(font: ...)` 中指定的字体。粗体交给当前字体族的 bold 字形。
  show text.where(weight: "bold"): set text(weight: 700)
  // 斜体: xeCJK ItalicFont
  show text.where(style: "italic"): set text(font: fs.main-italic)
  show text.where(style: "italic", weight: "bold"): set text(font: fs.bold-main-italic)
  // 与 LaTeX 版仅写 `\\hypersetup{colorlinks=true}` 时的 hyperref 默认色保持一致:
  // 内部交叉引用为 red, 文献引用为 green, URL/邮件链接为 magenta.
  show link: set text(fill: rgb("#ff00ff"))
  show ref: set text(fill: rgb("#ff0000"))
  show cite: set text(fill: rgb("#00ff00"))

  // 无衬线/等宽快捷函数 (供 \textsf / \texttt 使用)
  // 通过下面的 sans()/mono() 函数手动调用

  // ----- 段落 (linespread 1.3, 首段缩进 2em, 两端对齐) -----
  set par(
    // Typst 的 leading 是同一段相邻行文字框之间的间距；对应 LaTeX
    // 的 \\linespread{1.3}，按实际 PDF 基线距离取中等 leading。
    leading: 0.8em,
    justify: true,
    first-line-indent: (amount: 2em, all: true),
    // revtex 段落之间的竖直胶水略大于行内的 leading。Typst 的 spacing
    // 是额外的段间距离，须显式设得稍大，不能让相邻段落看成同一段。
    spacing: 0.9em,
  )
  // 按实际字框校准 revtex 的 enumerate：编号相对正文右移约 1em，
  // 其后正文保持紧凑的悬挂缩进，换行时与首行文字对齐。
  set enum(indent: 1.25em, body-indent: 0.55em)
  // 全角句点映射 (quanjiao 选项: 。→ ．)
  if quanjiao {
    show "。": "．"
  }

  // ----- 标题编号与本地化 -----
  // revtex4-2 的 preprint 样式使用 I. / A. / 1. 三种编号，
  // 且三级标题为斜体；附录则使用“附录 A:”与 1. 编号。
  set heading(numbering: "1.1.1")
  // 交叉引用前缀本地化: \sectionautorefname = 小节
  set heading(supplement: "小节")

  // revtex 的 heading 实际上带有首行缩进；编号与正文之间只有一个较窄的
  // 编号栏。下面的尺寸按编译后的 PDF 基线和字框校准，不直接把 LaTeX
  // 的 glue 数值机械换算成 Typst 的 block 参数。
  // LaTeX 的标题前留白大于标题后的留白；后方间距保持原模板节奏。
  let heading-above = 1.3cm
  let heading-below = 1.0cm
  // 2em 是正文首行缩进；标题编号字形自身有左侧字面留白，
  // 因而标题盒子需略微回退，才能和 PDF 中正文首行的可见起点对齐。
  let heading-indent = 1.75em
  let heading-number-width = 1.5em

  show heading.where(level: 1): it => {
    // revtex 的 section 与首行正文同起点，而不是贴页面文字边界。
    block(inset: (left: 1.4em), above: heading-above, below: heading-below, breakable: false)[
      #set text(weight: "bold", size: 11pt)
      #if it.numbering != none {
        context [#_heading-number(it) #h(1em)]
      }
      #it.body
    ]
  }
  show heading.where(level: 2): it => {
    block(inset: (left: heading-indent), above: heading-above, below: heading-below, breakable: false)[
      #set text(weight: "bold", size: 11pt)
      // 无编号小节 (\subsection*) 不保留空的编号栏，否则其标题会被
      // 额外右推一个编号宽度，无法与 LaTeX 的标题起点对齐。
      #if it.numbering != none [
        #box(width: heading-number-width)[#context [#_heading-number(it)]]
      ]
      #it.body
    ]
  }
  show heading.where(level: 3): it => {
    // Typst 三级标题自身还有约 0.25em 的层级偏移，因此补回这部分，
    // 使 A. 与 1. 两级标题的正文起点一致。
    block(inset: (left: heading-indent + 0.25em), above: heading-above, below: heading-below, breakable: false)[
      #set text(style: "italic", size: 11pt)
      #box(width: heading-number-width)[
        #if it.numbering != none { context [#_heading-number(it)] }
      ]
      #it.body
    ]
  }

  // ----- 公式编号 (1), 交叉引用 "式 (1)" -----
  set math.equation(numbering: "(1)", supplement: "式")

  // ----- 图表本地化: 图 1 / 表 1, 表标题在上方, 图标题在下方 -----
  // 图表本地化前缀: 图 / 表
  set figure(supplement: "图")
  show figure.where(kind: table): set figure(supplement: "表")
  // 不全局强制页顶浮动：否则初始化模板中的首个 figure 会跑到标题区之前。
  // Typst 默认按源文档位置排版；需要浮动时，用户可在具体 figure 上指定 placement。
  set figure(gap: 10pt)
  // 表格标题置于上方 (revtex 表标题在上, 图标题在下)
  show figure.where(kind: table): set figure.caption(position: top)
  // 标题格式: "图 1. caption"。图题/表题整体居中，且不继承正文首行缩进。
  show figure.caption: it => {
    let body = if it.kind == table {
      [表 #it.counter.display(it.numbering). #h(0.5em) #it.body]
    } else {
      [图 #it.counter.display(it.numbering). #h(0.5em) #it.body]
    }
    // caption 内容本身是 inline content；用 width:auto 的 box 让它按内容
    // 收缩，再由外层 align 居中。若直接放一个 100% block，外层没有可居中
    // 的剩余空间；若直接 align(text)，多行又会逐行居中。
    align(center)[
      #box(width: auto)[
        #set align(left)
        #text(size: 11pt)[#body]
      ]
    ]
  }

  // ----- 参考文献标题本地化 (由 template 中 #bibliography 给出 title:"参考文献") -----

  doc
}

// ========== 首页标题区 (对应 \title ... \maketitle 与 abstract/keywords) ==========
#let frontmatter(
  title: "",
  author: "",
  affiliation: "",
  abstract: none,
  keywords: "",
  email: none,
  phone: none,
  date: none,
) = {
  set par(first-line-indent: 0em)
  align(center)[
    #block(inset: 0pt)[
      #text(size: 14pt, weight: "bold", title)
    ]
    #v(0.6em)
    #if email != none {
      // emailphone: 作为作者脚注, 内容为 "<email>; <phone>", email 为 mailto 链接
      let body = author
      if phone != none {
        body = [#author#footnote(numbering: "*")[#link("mailto:" + email)[#email]; #phone]]
      } else {
        body = [#author#footnote(numbering: "*")[#link("mailto:" + email)[#email]]]
      }
      text(size: 12pt, body)
    } else {
      text(size: 12pt, author)
    }
    #v(0.2em)
    #text(size: 11pt, style: "italic", affiliation)
    #if date != none [
      #v(0.2em)
      #text(size: 11pt, style: "italic", date)
    ]
  ]
  // 摘要: 收窄到 400pt, 首行空两格, 两端对齐
  // 与 LaTeX 的 5.5pt preabstract space 对齐；Typst block 的字体盒高度与
  // TeX minipage 不同，视觉基线需要少量补偿。
  v(3pt)
  // 页面正文宽度为 16cm，左右各留约 26.77pt 后得到 LaTeX 的 400pt 摘要宽度。
  // 这里不使用外层 align(center)，避免摘要文字继承居中对齐。
  block(width: 100%)[
    #pad(left: 26.77pt, right: 26.77pt)[
      #block(width: 400pt)[
        #set align(left)
        #set text(size: 11pt)
        // mpltx.cls 将摘要设为 11pt/13pt，并通过 \linespread{1.3} 得到约 16.9pt
        // 的实际基线间距；这里直接设置等效 leading，而不是沿用正文行距。
        #set par(justify: true, first-line-indent: 0em, leading: 0.85em, spacing: 0pt)
        #h(2em)
        #abstract
      ]
    ]
  ]
  // 关键词: 加粗 "关键词:"
  // 与 LaTeX 的 6.5pt postabstract space 对齐。
  v(4.5pt)
  align(center)[
    #block(width: 400pt)[
      #align(left)[
        #set par(first-line-indent: 0em)
        #text(size: 11pt)[*关键词:* #keywords]
      ]
    ]
  ]
  // revtex 的 frontmatter@finalspace 为 18pt.
  v(18pt)
  set par(first-line-indent: 2em)
}

// ========== 工具函数 (对应模板新定义的命令) ==========

// \note: 灰色注释
#let note(it) = {
  // note 是行内说明，不应因为函数体中的 set/show 规则被提升成独立块。
  // 用 inline text 容器保持它与前后正文处在同一段；display equation
  // 仍单独设为灰色，以对应 LaTeX 的 {\\color{gray}...}。
  show math.equation: text.with(fill: gray)
  text(fill: gray)[#it]
}

// \ii, \ee, \jj: 数学模式下正体 i, e, j
#let ii = math.upright("i")
#let ee = math.upright("e")
#let jj = math.upright("j")
// \uppi: 正体圆周率
#let uppi = math.upright("π")

// sans / mono 文本快捷函数 (对应 \textsf / \texttt)
#let sans(it) = context text(font: _active-fonts.get().sans, it)
#let mono(it) = context text(font: _active-fonts.get().mono, it)

// \mc: multicolumn 简写 (Typst 表格中无需, 提供为兼容别名, 直接返回内容)
#let mc(it) = it

// 双横线 (ruledtabular 首尾双横线): 两条平行细线, 间距 2.5pt
#let _double-rule = block(width: 100%, spacing: 0pt)[
  #stack(
    dir: ttb,
    spacing: 2.5pt,
    line(length: 100%, stroke: 0.5pt),
    line(length: 100%, stroke: 0.5pt),
  )
]

// ruled-table: 包裹一个标准 Typst table, 生成首尾双横线 (对应 ruledtabular 环境).
// 用法见 template/main.typ. 表内中部横线请在 table 中用 table.hline(stroke: 0.4pt) 给出.
#let ruled-table(it) = block(width: 100%, spacing: 0pt)[
  #_double-rule
  #v(3pt)
  #set text(size: 11pt)
  #set table(stroke: none)
  #it
  #v(3pt)
  #_double-rule
]

// 致谢环境 (对应 acknowledgments 环境)
#let acknowledgments(body) = {
  // 使用块级节前间距：接在正文后时与 revtex 的 section* 间距一致，
  // 若致谢恰好另起一页，页面顶部会自动折叠这段间距。
  block(above: 1.3cm)[
    // 标题本身也与正文首行保持 2em 的首行缩进。
    #h(2em)
    #text(weight: "bold", size: 11pt)[致谢]
  ]
  // 保持标题到正文的原有距离，仅增加标题前的节间距。
  v(0.5cm)
  block(width: 100%)[
    #set text(size: 12pt, style: "normal")
    // 与 LaTeX 一样，只有首行缩进 2em，续行回到正文左端。
    #set par(first-line-indent: 0em)
    #h(2em)
    #body
  ]
}

// 参考文献标题在 revtex4-2 中居中，条目由 Typst 的 bibliography 负责排版。
// 使用方法: #bibliography-title[参考文献] 后接 bibliography(..., title: none).
#let bibliography-title(body) = {
  v(0.8cm)
  align(center, text(weight: "bold", size: 11pt)[#body])
  v(0.5cm)
}

// 附录起始 (对应 \appendix: 章节编号改为字母)
#let start-appendix() = {
  _appendix-mode.update(true)
  counter(heading).update(0)
}
