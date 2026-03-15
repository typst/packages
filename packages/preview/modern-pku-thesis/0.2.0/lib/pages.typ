// lib/pages.typ - 页面生成器
// 封面、版权声明、摘要、致谢、原创性声明等页面

#import "@preview/cuti:0.4.0": show-cn-fakebold
#import "config.typ": back-heading, front-heading, 字体, 字号
#import "utils.typ": chinesenumber, chineseyear, split-text-by-width
#import "styles.typ": sym-box-checked, sym-box-unchecked

// 构建带自动换行的字段 grid
#let build-field-grid(fields, name-width, value-width, row-height) = context {
  let grid-contents = ()

  for (name, value) in fields {
    let value-parts = split-text-by-width(value, value-width)
    for (i, part) in value-parts.enumerate() {
      // 第一行显示字段名，后续行留空
      if i == 0 {
        grid-contents.push([#strong(name)#v(0.5em)])
      } else {
        grid-contents.push([])
      }
      grid-contents.push([
        #set align(center)
        #set text(字号.三号, font: 字体.仿宋)
        #part
        #v(0.5em)
      ])
    }
  }

  grid(
    columns: (name-width, value-width),
    rows: row-height,
    row-gutter: 0.5em,
    stroke: (x, y) => if x == 1 { (bottom: 1pt) } else { none },
    ..grid-contents,
  )
}

// 学位类型选择框
// degree-type: "academic" | "professional"，其他值会触发 panic
#let degree-type-checkbox(degree-type) = {
  assert(
    degree-type == "academic" or degree-type == "professional",
    message: "degree-type 必须是 \"academic\" 或 \"professional\"，当前值: "
      + repr(degree-type),
  )
  let academic-box = if degree-type == "academic" {
    sym-box-checked(12pt)
  } else {
    sym-box-unchecked(12pt)
  }
  let professional-box = if degree-type == "professional" {
    sym-box-checked(12pt)
  } else {
    sym-box-unchecked(12pt)
  }
  set align(center + horizon)
  [#academic-box#h(0.5em)学术学位#h(4 * 0.5em)#professional-box#h(0.5em)专业学位]
}

// 封面页（盲审版）
#let cover-page-blind(
  cheader: none,
  ctitle: none,
  etitle: none,
  cfirstmajor: none,
  cmajor: none,
  blindid: none,
  date: none,
  degree-type: "academic",
) = {
  set align(center + top)
  text(字号.小初, font: 字体.黑体)[
    #show: show-cn-fakebold
    #strong(cheader)
  ]
  linebreak()
  set text(字号.三号, font: 字体.仿宋)
  set par(justify: true, leading: 1em)
  [（匿名评阅论文封面）]
  v(1fr)
  [
    #set align(left)
    #set par(spacing: 1.5em)
    中文题目：#ctitle.split("\n").join()

    英文题目：#etitle.split("\n").join()

    #linebreak()

    一级学科：#cfirstmajor

    二级学科：#cmajor

    论文编号：#blindid
  ]
  v(1fr)
  degree-type-checkbox(degree-type)
  v(3fr)
  [#chineseyear(date.year) 年 #chinesenumber(date.month) 月]
}

// 封面页（正常版）
#let cover-page-normal(
  cthesisname: none,
  ctitle: none,
  cauthor: none,
  studentid: none,
  school: none,
  cmajor: none,
  direction: none,
  csupervisor: none,
  degree-type: "academic",
  date: none,
) = {
  set text(字号.一号)
  box(
    grid(
      columns: (auto, auto),
      gutter: 0.4em,
      image("../pkulogo.svg", height: 2.4em, fit: "contain"),
      image("../pkuword.svg", height: 1.6em, fit: "contain"),
    ),
  )
  linebreak()
  text(字号.小初)[#strong(cthesisname)]
  v(1fr)
  context {
    set text(weight: "bold")
    show: show-cn-fakebold
    let ctitle-parts = split-text-by-width(ctitle, 10.16cm)
    let grid-contents = (
      [
        #set align(center)
        #text(字号.二号, weight: "regular")[题目：]
      ],
    )
    for (i, part) in ctitle-parts.enumerate() {
      grid-contents.push(strong(part))
      if i < ctitle-parts.len() - 1 {
        grid-contents.push([])
      }
    }

    grid(
      columns: (2.75cm, 10.16cm),
      rows: 1.48cm,
      align: center,
      stroke: (x, y) => if x == 1 { (bottom: 1pt) } else { none },
      ..grid-contents,
    )
  }
  v(5fr)
  set text(字号.三号)
  build-field-grid(
    (
      (text("姓") + h(2em) + text("名："), cauthor),
      (text("学") + h(2em) + text("号："), studentid),
      (text("学") + h(2em) + text("院："), school),
      (text("专") + h(2em) + text("业："), cmajor),
      ("研究方向：", direction),
      ("导师姓名：", csupervisor),
    ),
    3.19cm,
    7.63cm,
    1.5em,
  )

  v(2fr)
  text(font: 字体.仿宋)[#degree-type-checkbox(degree-type)]
  v(1fr)
  text(font: 字体.宋体)[
    #chineseyear(date.year) *年* #chinesenumber(date.month) *月*
  ]
}

// 版权声明页
#let copyright-page(linespacing: 10pt) = {
  set align(left + top)
  set text(字号.小四)

  // Word 模板中，版权声明页标题为 2 倍行距，段落前后无额外间距
  // 在黑体三号字情况下，对应行距为 16pt * 1.3 * 2
  front-heading(
    "版权声明",
    pagebreak: false,
    linespacing: 字号.三号 * 1.3 * 2,
    spacing-before: 0pt,
    spacing-after: 0pt,
  )
  linebreak()

  // 版权声明页的首行缩进固定为 2em，Word 行距为 2 倍行距
  // 在宋体小四号字情况下，对应行距 31.2 pt
  set par(
    first-line-indent: 2em,
    leading: 字号.小四 * 1.3,
    spacing: 字号.小四 * 1.3,
  )
  set text(top-edge: 0.8 * 字号.小四 * 1.3, bottom-edge: -0.2 * 字号.小四 * 1.3)
  [
    任何收存和保管本论文各种版本的单位和个人未经本论文作者同意，不得将本论文转借他人，亦不得随意复制、抄录、拍照或以任何方式传播。否则，引起有碍作者著作权之问题，将可能承担法律责任。
  ]
}

// 中文摘要页
#let abstract-page-zh(
  ckeywords: (),
  first-line-indent: 2em,
  cabstract,
) = {
  // Word 模板中默认为 20pt 行距
  // 调整 text(top-edge:, bottom-edge:) 的方式可以更完美地匹配行距
  // 但是会导致列表编号和列表内容无法对齐
  // 这里选择基于经验的配置
  set par(leading: 10.5pt, spacing: 10.5pt, justify: true)
  front-heading("摘要", enter-front: true, header: "摘要")
  set par(first-line-indent: first-line-indent)
  cabstract
  // 如果发现关键词和内容挤到一起，或者关键词在下一页顶部
  // 可以插入 pagebreak() 手动分页
  v(1fr)
  [关键词：]
  ckeywords.join("，")
  v(1em)
}

// 英文摘要页
#let abstract-page-en(
  etitle: none,
  eauthor: none,
  emajor: none,
  esupervisor: none,
  ekeywords: (),
  blind: false,
  eabstract,
) = {
  // 英文摘要标题，页眉为 ABSTRACT
  heading(
    numbering: none,
    outlined: false,
    supplement: [#metadata((
      pagebreak: true,
      show-header: true,
      header: "ABSTRACT",
      spacing-before: 24pt,
      spacing-after: 8pt,
      linespacing: 2em,
      font: (size: 字号.小二, font: "Arial", weight: "regular"),
    ))],
  )[#upper(etitle)]

  // Word 模板中正文仍然是 20pt 行距
  // 对于纯英文字体，测试下来 12.5pt 的匹配效果较好
  set par(spacing: 12.5pt, leading: 12.5pt, justify: true)
  if not blind {
    [
      #set align(center)
      #eauthor \(#emajor\) \
      Supervised by #esupervisor
    ]
  }
  // Word 模板中英文摘要的首行缩进固定为 0.74cm
  set par(first-line-indent: 0.74cm, justify: true)
  v(8pt)
  align(center)[#text(font: "Arial", weight: "bold")[ABSTRACT]]
  v(6pt)
  eabstract
  v(1fr)
  let keyword-prefix = if ekeywords.len() == 1 {
    "KEY WORD: "
  } else {
    "KEY WORDS: "
  }
  [#keyword-prefix]
  ekeywords.join(", ")
  v(1em)
}

// 致谢页
#let acknowledgements-page(first-line-indent: 2em, acknowledgements) = {
  back-heading("致谢")
  set par(
    first-line-indent: first-line-indent,
    leading: 10.5pt,
    spacing: 10.5pt,
  )
  acknowledgements
}

// 原创性声明和授权说明页
#let declaration-page(cleandeclaration: false) = {
  // Word 模板中首行缩进固定为 2em
  set par(first-line-indent: 2em)
  back-heading(
    "北京大学学位论文原创性声明和使用授权说明",
    pagebreak: true,
    // Word 模板中原创性声明页有页眉，如果不想要，可以在这里手动关闭
    show-header: not cleandeclaration,
  )

  // 放置一个占位元素，用于清除页码
  if cleandeclaration {
    [#[]<__clean_declaration__>]
  }

  align(center)[#text(
    字号.四号,
    weight: "bold",
    show-cn-fakebold[原创性声明],
  )]
  v(1fr)
  [
    #set par(leading: 0.95em, spacing: 0.95em)
    本人郑重声明：所呈交的学位论文，是本人在导师的指导下，独立进行研究工作所取得的成果。除文中已经注明引用的内容外，本论文不含任何其他个人或集体已经发表或撰写过的作品或成果。对本文的研究做出重要贡献的个人和集体，均已在文中以明确方式标明。本声明的法律结果由本人承担。

    #v(1fr)

    #align(right)[
      论文作者签名
      #h(5em)
      日期：
      #h(2em)
      年
      #h(2em)
      月
      #h(2em)
      日
    ]

    #v(1fr)
    #align(center)[#text(
      字号.四号,
      weight: "bold",
      show-cn-fakebold[学位论文使用授权说明],
    )]
    #align(center)[#text(字号.五号)[（必须装订在提交学校图书馆的印刷本）]]
    #v(1fr)

    #set par(leading: 0.95em, spacing: 0.95em)
    本人完全了解北京大学关于收集、保存、使用学位论文的规定，即：
    #[
      #set list(
        marker: [#grid(
          columns: (auto, 1em),
          circle(radius: 0.3em, fill: black, stroke: none), [],
        )],
        indent: 1.5em,
      )
      - 按照学校要求提交学位论文的印刷本和电子版本；
      - 学校有权保存学位论文的印刷本和电子版，并提供目录检索与阅览服务，在校园网上提供服务；
      - 学校可以采用影印、缩印、数字化或其它复制手段保存论文；
      - 因某种特殊原因须要延迟发布学位论文电子版，授权学校#box(width: 12pt, align(center, square(size: 9pt)))一年/#box(width: 12pt, align(center, square(size: 9pt)))两年/#box(width: 12pt, align(center, square(size: 9pt)))三年以后，在校园网上全文发布。
    ]
    #v(1fr)
    #align(center)[（保密论文在解密后遵守此规定）]
    #v(2fr)
    #align(center)[
      论文作者签名：
      #h(5em)
      导师签名：
      #h(5em)
      #v(1em)
      日期：
      #h(2em)
      年
      #h(2em)
      月
      #h(2em)
      日
    ]
  ]
}
