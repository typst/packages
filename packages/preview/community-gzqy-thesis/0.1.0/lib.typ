// ============================================================
// community-gzqy-thesis — 贵州轻工职业技术学院毕业设计（论文）Typst 模板
// ============================================================

// -------------------- 字体 --------------------
#let heiti = ("Times New Roman", "Noto Sans CJK SC", "SimHei", "Heiti SC", "Source Han Sans SC")
#let songti = ("Times New Roman", "Noto Serif CJK SC", "Source Han Serif SC", "SimSun", "Songti SC")

// -------------------- 字号 --------------------
#let fs = (
  一号: 26pt, 小一: 24pt, 二号: 22pt, 小二: 18pt,
  三号: 16pt, 小三: 15pt, 四号: 14pt, 小四: 12pt,
  五号: 10.5pt, 小五: 9pt,
)

// -------------------- 辅助函数 --------------------

/// 渲染参考文献标题 + bibliography
/// 用法：#thesis-bibliography(bibliography("refs.bib"))
#let thesis-bibliography(bib) = {
  heading(level: 1, numbering: none)[参考文献]
  {
    set text(font: songti, size: fs.五号)
    set par(first-line-indent: 0pt)
    bib
  }
}

/// 渲染致谢标题 + 内容
#let thesis-acknowledgement(body) = {
  heading(level: 1, numbering: none)[致#h(1em)谢]
  body
}

// -------------------- 主函数 --------------------

#let community-gzqy-thesis(
  title: "论文题目",
  major: "专业名称",
  advisor: "指导教师",
  student-id: "学号",
  student-name: "姓名",
  year: "2026",
  month: "6",
  abstract-zh: [],
  keywords-zh: (),
  abstract-en: [],
  keywords-en: (),
  body,
) = {
  // ========== 封面 ==========
  page(
    paper: "a4",
    margin: (top: 2.5cm, bottom: 2cm, left: 3cm, right: 2.5cm),
    header: none,
    footer: none,
  )[
    #set align(center)
    #v(2fr)

    #text(font: heiti, size: fs.小三)[贵州轻工职业技术学院]
    #v(0.5em)
    #text(font: heiti, size: fs.小三)[#year 届毕业设计]

    #v(3em)

    #text(font: heiti, size: fs.一号, weight: "bold")[#title]

    #v(5em)

    #{
      set text(font: heiti, size: fs.三号)
      let field(body) = box(
        width: 12em,
        stroke: (bottom: 0.8pt + black),
        inset: (bottom: 4pt),
        align(center, body),
      )
      grid(
        columns: 1,
        row-gutter: 1.2em,
        [学科专业：#field[#major]],
        [指导老师：#field[#advisor]],
        [学生学号：#field[#student-id]],
        [学生姓名：#field[#student-name]],
      )
    }

    #v(3fr)

    #text(font: heiti, size: fs.四号)[中国﹒贵州﹒贵阳]
    #v(0.3em)
    #text(font: heiti, size: fs.四号)[#year 年 #month 月]

    #v(1fr)
  ]

  // ========== 全局页面与文本设置 ==========
  let show-page-number = state("show-page-number", false)

  set page(
    paper: "a4",
    margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 2.5cm),
    footer: context {
      if show-page-number.get() {
        align(center, text(font: songti, size: fs.五号, counter(page).display("1")))
      }
    },
  )
  set text(font: songti, size: fs.小四, lang: "zh", region: "cn")
  set par(leading: 8pt, first-line-indent: 2em, justify: true)

  // -------------------- 标题编号格式 --------------------
  set heading(numbering: (..nums) => {
    let n = nums.pos()
    if n.len() == 1 { "第" + str(n.first()) + "章" }
    else { n.map(str).join(".") }
  })

  // -------------------- 标题样式 --------------------
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    set text(font: heiti, size: fs.小三, weight: "bold")
    set par(first-line-indent: 0pt)
    v(0.5em)
    if it.numbering != none {
      align(center)[#counter(heading).display(it.numbering) #it.body]
    } else {
      align(center, it.body)
    }
    v(0.5em)
  }

  show heading.where(level: 2): it => {
    set text(font: heiti, size: fs.四号, weight: "bold")
    set par(first-line-indent: 0pt)
    v(0.3em)
    if it.numbering != none {
      [#counter(heading).display(it.numbering) #it.body]
    } else { it.body }
    v(0.2em)
  }

  show heading.where(level: 3): it => {
    set text(font: heiti, size: fs.小四, weight: "bold")
    set par(first-line-indent: 0pt)
    v(0.2em)
    if it.numbering != none {
      [#counter(heading).display(it.numbering) #it.body]
    } else { it.body }
    v(0.1em)
  }

  // -------------------- 目录条目样式 --------------------
  show outline.entry.where(level: 1): set text(font: songti, size: fs.四号)
  show outline.entry.where(level: 2): set text(font: songti, size: fs.小四)
  show outline.entry.where(level: 3): set text(font: songti, size: fs.五号)

  // ========== 中文摘要 ==========
  align(center)[
    #text(font: heiti, size: fs.四号, weight: "bold")[摘#h(1em)要]
  ]
  v(0.5em)
  abstract-zh
  v(1em)
  par(first-line-indent: 0pt)[
    #text(font: heiti, size: fs.小四, weight: "bold")[关键词]#text(font: songti, size: fs.小四)[：#keywords-zh.join("；")]
  ]
  pagebreak()

  // ========== 英文摘要 ==========
  align(center)[
    #text(font: heiti, size: fs.四号, weight: "bold")[Abstract]
  ]
  v(0.5em)
  abstract-en
  v(1em)
  par(first-line-indent: 0pt)[
    *Keywords*: #keywords-en.join("; ")
  ]
  pagebreak()

  // ========== 目录 ==========
  align(center)[
    #text(font: heiti, size: fs.小三, weight: "bold")[目#h(1em)录]
  ]
  v(1em)
  outline(title: none, depth: 3, indent: 2em)
  pagebreak()

  // ========== 正文 ==========
  show-page-number.update(true)
  counter(page).update(1)

  body

  // ========== 原创性声明 ==========
  pagebreak()
  show-page-number.update(false)

  {
    set text(font: songti, size: fs.四号)
    set par(first-line-indent: 2em)

    align(center)[
      #text(font: heiti, size: fs.三号, weight: "bold")[原 创 性 声 明]
    ]

    v(1em)

    [本人郑重声明：所呈交的毕业设计（论文），是本人在指导教师的指导下，独立进行研究所取得的成果。除文中已经注明引用的内容外，本论文不包含任何其他个人或集体已经发表或撰写过的科研成果。对本文的研究在做出重要贡献的个人和集体，均已在文中以明确方式标明。本人在导师指导下所完成的毕业设计（论文）及相关作品，知识产权归属贵州轻工职业技术学院。本人完全意识到本声明的法律责任由本人承担。]

    let field(width) = box(
      width: width,
      stroke: (bottom: 0.8pt + black),
      inset: (bottom: 4pt),
    )[]

    v(3em)
    set par(first-line-indent: 0pt)
    align(right)[
      作者签名：#field(8em)
      #h(2em)
      日期：#field(3em)年#field(2em)月#field(2em)日
      #h(1em)
    ]

    v(4em)

    align(center)[
      #text(font: heiti, size: fs.三号, weight: "bold")[关于毕业设计（论文）使用授权的声明]
    ]

    v(1em)
    set par(first-line-indent: 2em)

    [本人完全了解贵州轻工职业技术学院有关保留、使用毕业设计（论文）的规定，同意学校保留或向国家有关部门或机构送交毕业设计（论文）的复印件和电子版，允许毕业设计（论文）被查阅和借阅；本人授权贵州轻工职业技术学院可以将本论文的全部或部分内容编入有关数据库进行检索，可以采用影印、缩印或其他复制手段保存毕业设计（论文）和汇编本论文。]

    v(1em)
    set par(first-line-indent: 0pt)

    [本毕业设计（论文）属于：]
    v(0.5em)
    [#h(2em)保#h(1em)密（#h(2em)），在#field(2.5em)年解密后适用授权。]
    v(0.2em)
    [#h(2em)不保密（#h(2em)）]
    v(0.3em)
    text()[(请在以上相应方框内打"√")]
    v(3em)

    grid(
      columns: (1fr, 1fr),
      row-gutter: 1.5em,
      [作者签名：#field(6em)],
      [导师签名：#field(6em)],
      [],
      [日#h(1em)期：#field(3em)年#field(2em)月#field(2em)日],
    )
  }
}
