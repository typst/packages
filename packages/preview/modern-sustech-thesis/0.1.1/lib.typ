// Construct the sections as aranged.
#import "./configs/cover.typ": cover
#import "./configs/commitment.typ": commitment
#import "./configs/abstract.typ": abstract
#import "./configs/outline.typ": toc
#let std-bibliography = bibliography

#let sustech-thesis(
  isCN: true,
  information: (
    title: (
      [第一行],
      [第二行],
    ),
    subtitle: [subtitle],
    abstract-body: (
      [#lorem(40)],
      [#lorem(40)],
    ),
    keywords: (
      [Keyword1],
      [关键词2],
      [啦啦啦],
      [你好]
    ),
    author: [慕青QAQ],
    department: [数学系],
    major: [数学],
    advisor: [木木],
  ),
  toc-title: [目录],
  bibliography: none,
  body,
) = {
  // 中英文封面页 Cover
  cover(
    isCN: isCN,
    title: information.title,
    subtitle: information.subtitle,
    author: information.author,
    department: information.department,
    major: information.major,
    advisor: information.advisor,
  )

  // 承诺书 Commitment
  commitment(
    isCN: isCN,
  )

  // 设定目录编号格式
  set heading(numbering: "1.1.1.")
  // 设定非正文部分页码
  set page(numbering: "I")
  counter(page).update(1)

  // 插入摘要页
  abstract(
    isCN: isCN,
    information: information,
    body: information.abstract-body,
  )
  // 插入目录页
  toc(
    isCN: isCN,
    toc-title: toc-title,
  )

  // 设定正文部分页码
  set page(numbering: "1")
  counter(page).update(1)

  // 定理环境
  import "@preview/ctheorems:1.1.2": *
  show: thmrules
  let indent = h(2em)
  let theorem = thmbox(
    "theorem",
    "定理",
  )

  let define = thmbox(
    "definition",
    "定义",
  )

  let prop = thmbox(
    "property",
    "性质",
  )

  let notation = thmbox(
    "notation",
    "符号",
  )

  let mapsto = $|->$

  // body style
  import "./configs/font.typ" as fonts
  // headings
  show heading.where(level: 1): it =>{
    set text(
      font: fonts.HeiTi,
      size: fonts.No3,
      weight: "regular",
    )
    align(center)[
      // #it
      #strong(it)
    ]
    text()[#v(1em)]
  }

  show heading.where(level: 2): it =>{
    set text(
      font: fonts.HeiTi,
      size: fonts.No4,
      weight: "regular"
      )
    it
    text()[#v(1em)]
  }

  show heading.where(level: 3): it =>{
    set text(
      font: fonts.HeiTi,
      size: fonts.No4-Small,
      weight: "regular"
      )
    it
    text()[#v(1em)] 
  }

  // paragraph
  set block(spacing: 1.5em)
  set par(
    justify: true,
    first-line-indent: 2em,
    leading: 1.5em)

  set text(
      font: fonts.SongTi,
      size: fonts.No4-Small,
  )

  body
  
  // Display bibliography.
  if bibliography != none {
    show std-bibliography: it => {
      pagebreak()
      show heading: title => {
        align(center)[
          #strong()[
            #text(
              font: fonts.HeiTi,
              size: fonts.No3,
          )[#title]
          ]
        ]
      }
      v(1em)
      set text(
        font: fonts.SongTi,
        size: fonts.No5,
      )
      it
    }
    bibliography
  }
}
