#import "@preview/cuti:0.4.0": show-cn-fakebold
#import "@preview/pointless-size:0.1.2": zh
#import "@preview/itemize:0.2.0" as el
#import "@preview/numblex:0.2.0": numblex
#import "@preview/kouhu:0.2.0": kouhu
#import "utils/three-line-table.typ": *

#let calc-headings(headings) = {
  let max-page-num = calc.max(..headings.map(i => i.location().page()))
  let first-headings = (none,) * max-page-num
  let last-heading = context query(heading.where(level: 1).before(here())).at(-1).body
  let target-headings = (none,) * max-page-num
  //! 该循环排除了一页出现两个一级标题的情况
  for h in headings {
    if first-headings.at(h.location().page() - 1) == none {
      first-headings.at(h.location().page() - 1) = h.body
    }
  }
  for i in range(target-headings.len()) {
    target-headings.at(i) = {
      if i + 1 <= first-headings.len() and first-headings.at(i) != none {
        first-headings.at(i)
      } else {
        last-heading
      }
    }
  }
  target-headings
}
#let paper-title = state("title", "")
#let pn-style = state("pn-style", "roman")

#let typeset-fore(doc) = {
  show: show-cn-fakebold
  show: el.default-enum-list.with(bottom-edge: "baseline")

  //! 设置标题序号
  set heading(
    numbering: numblex(
      "
    {[1   ]:d==1;[1]:d==2;[1]:d==3}
    {[.1   ]:d==2;[.1]:d==3}
    {[.1   ]:d==3;}
    {        （[1]）:d==4}
    {        [①]:d==5}
    ",
    ),
  )

  //! 设置标题格式
  show heading: set text(weight: "regular")
  show heading.where(level: 1): it => {
    set block(
      inset: (top: 0.5em, right: 0em, bottom: 0em, left: 0em),
      // outset: 1em,
      spacing: 1.5em,
    )
    set text(
      font: ("Times New Roman", "SimHei"),
      size: zh(-3),
      // top-edge: 1.4em,
      // bottom-edge: 0.5em,
    )
    //! 第一个一级标题之前（含自身）就一个，所以大于1就分页
    if query(heading.where(level: 1).before(here())).len() > 1 {
      pagebreak()
      it + counter(figure).update(0)
    } else {
      it + counter(figure).update(0)
    }
  }
  show heading.where(level: 2): it => {
    set block(
      inset: (top: 0.5em, right: 0em, bottom: 0em, left: 0em),
      // outset: 1em,
      spacing: 1em,
    )
    set text(
      font: ("Times New Roman", "SimHei"),
      size: zh(4),
      // top-edge: 0.5em,
      // bottom-edge: 1em,
    )
    it
  }
  show heading.where(level: 3): it => {
    set block(
      inset: (top: 0em, right: 0em, bottom: 0em, left: 0em),
      // outset: 1em,
      // spacing: 1em,
    )
    set text(
      font: ("Times New Roman", "SimHei"),
      size: zh(-4),
      // top-edge: 0.8em,
      // bottom-edge: 1em,
    )
    it
  }
  show heading.where(level: 4): it => {
    set block(
      // inset: (top: -1em, right: 0em, bottom: 0em, left: 0em),
      // outset: 1em,
      // spacing: 1em,
    )
    set text(
      font: ("Times New Roman", "SimSun"),
      size: zh(-4),
      top-edge: 0em,
      bottom-edge: 0em,
    )
    it
  }
  show heading.where(level: 5): it => {
    set block(
      // inset: (top: 0em, right: 0em, bottom: 0em, left: 0em),
      // outset: 1em,
      // spacing: 1em,
    )
    set text(
      font: ("Times New Roman", "SimSun"),
      size: zh(-4),
      top-edge: 0em,
      bottom-edge: 0em,
    )
    it
  }

  //! 设置段落格式
  set par(
    justify: true,
    first-line-indent: (amount: 2em, all: true),
    leading: 0.5em,
    spacing: 0.5em,
  )

  //! 设置正文格式
  set text(
    font: (
      "Times New Roman",
      "SimSun",
    ),
    size: zh(-4),
    lang: "zh",
    region: "cn",
    top-edge: "ascender",
    bottom-edge: "descender",
  )

  //! 设置figure格式
  set figure.caption(separator: "  ")
  show figure: set figure(
    numbering: _ => [#counter(heading.where(level: 1)).display("1").#counter(figure).display("1")],
  )

  //! 其中插入图片格式
  show image: it => {
    v(1em)
    it
  }
  show figure.where(kind: image): set figure.caption(position: bottom)

  //! 其中插入表格格式
  show figure.where(kind: table): set figure(gap: 0.2em)
  show figure.where(kind: table): it => {
    set figure.caption(position: top)
    v(1em)
    it
  }
  show table: set text(size: zh(5))

  //! 其中插入公式格式
  show ref: it => {
    let el = it.element
    if el == none or el.func() != math.equation { return it }
    link(el.location(), numbering(
      _ => [式#counter(heading.where(level: 1)).display("1").#counter(math.equation).display("1")],
      ..counter(math.equation).at(el.location()),
    ))
  }
  set math.equation(
    numbering: _ => text(
      font: "Times New Roman",
    )[(#counter(heading.where(level: 1)).display("1").#counter(math.equation).display("1"))],
  )
  show math.equation.where(block: true): it => {
    v(1em)
    it
    v(1em)
  }

  //! 其中插入代码格式

  //! 其中插入伪代码格式

  //! 设置脚注格式
  show footnote.entry: set text(
    font: ("Times New Roman", "SimSun"),
    size: zh(-5),
  )
  set footnote.entry(
    indent: 0em,
    separator: line(
      length: 30%,
      stroke: 0.5pt,
    ),
  )
  set footnote(numbering: "①")

  //! 设置参考文献格式
  show bibliography: it => {
    set text(size: zh(5))
    it
  }
  doc
}
#let typeset-back(doc) = {
  pn-style.update("arabic")
  let offset = context counter(page).get().at(0)
  counter(page).update(1)
  set page(
    margin: (
      top: 3.5cm,
      bottom: 2.5cm,
      left: 2.5cm,
      right: 2.5cm,
    ),
    header-ascent: 0.5cm,
    header: context [
      #set par(spacing: 0.9em)
      #set text(font: ("Times New Roman", "SimSun"), size: zh(5))
      #set align(center + bottom)
      #let is-odd = calc.odd(counter(page).get().at(0))
      #let head-text = if is-odd {
        context paper-title.get()
      } else {
        calc-headings(query(heading.where(level: 1))).at(here().page() - 1)
      }
      #head-text
      #v(-6pt)
      #line(length: 100%, stroke: 0.5pt)
    ],
    footer-descent: 0.5em,
    footer: context [
      #set text(font: "Times New Roman", size: zh(-5))
      #set align(center + top)
      #counter(page).display("1")
    ],
  )
  doc
}

#let cover(
  zh-title1: [中文标题1],
  zh-title2: [中文标题2],
  en-title1: [title1],
  en-title2: [title2],
  author: [作者],
  mentor: [导师],
  degree: [学位],
  academy: [学院],
  subject: [专业],
  research: [研究方向],
  year: datetime.today().display("[year]"),
  month: 4,
) = {
  paper-title.update(zh-title1 + zh-title2)
  set page(margin: (
    top: 3.5cm,
    bottom: 2.5cm,
    left: 2.5cm,
    right: 2.5cm,
  ))
  let distr(width: auto, body) = {
    block(
      width: width,
      stack(
        dir: ltr,
        ..body.clusters().map(x => [#x]).intersperse(1fr),
      ),
    )
  }
  let number_to_chinese(num) = {
    let chinese_digits = (
      "〇",
      "一",
      "二",
      "三",
      "四",
      "五",
      "六",
      "七",
      "八",
      "九",
    )
    let num_str = str(num)
    let result = ""
    for num_digit in num_str {
      let num_digit = int(num_digit)
      result += chinese_digits.at(num_digit)
    }
    return result
  }

  //! 封面logo
  place(
    dx: -0.29cm,
    dy: 0.33cm,
    image("./assets/江西财经大学相关元素/硕士毕业论文封面logo.png", width: 6.78cm),
  )

  //! 出版信息
  {
    let _underline() = {
      rect(
        width: 3.1cm,
        stroke: (bottom: 0.6pt + black),
      )
    }
    set text(font: "SimHei", size: zh(5))
    place(
      dx: 9.35cm,
      dy: 0.87cm,
      grid(
        columns: (4.3em, 1 * 0.25cm),
        rows: 1em,
        gutter: 0.45cm,
        distr(width: 5em, "学校代码"), _underline(),
        distr(width: 5em, "密级"), _underline(),
        distr(width: 5em, "中图分类号"), _underline(),
        distr(width: 5em, "UDC"), _underline(),
      ),
    )
  }

  //! 以下元素全部居中
  set align(center)

  //! 硕士学位论文/MASTER DISSERTATION
  v(183pt)
  {
    set text(font: "Microsoft YaHei", size: 45pt, tracking: 10pt)
    set par(leading: 1em, spacing: 35pt)
    [硕士学位论文]
  }
  {
    set text(font: "STZhongsong", size: zh(1))
    set par(leading: 1em)
    [MASTER DISSERTATION]
  }

  //? 论文题目（中英）
  v(2 * 16.1pt)
  table(
    columns: (2.69cm, 11.49cm),
    rows: 1.1cm,
    align: center + horizon,
    stroke: none,
    text(font: "SimHei", size: zh(-3))[论文题目],
    text(font: "KaiTi", size: zh(3))[#zh-title1],
    table.hline(stroke: 0.5pt, start: 1),
    text(font: "SimHei", size: zh(4))[（中文）],
    text(font: "STZhongsong", size: zh(4))[#zh-title2],
    table.hline(stroke: 0.5pt, start: 1),
    text(font: "SimHei", size: zh(-3))[论文题目],
    text(font: "Times New Roman", size: zh(3))[#en-title1],
    table.hline(stroke: 0.5pt, start: 1),
    text(font: "SimHei", size: zh(4))[（英文）],
    text(font: "STZhongsong", size: zh(3))[#en-title2],
    table.hline(stroke: 0.5pt, start: 1),
  )

  //? 作者信息
  v(5pt)
  table(
    columns: (2.44cm, 4.88cm, 0.42cm, 2.45cm, 4.26cm),
    rows: 1.06cm,
    align: center + bottom,
    stroke: none,
    text(font: "SimHei", size: zh(4))[
      #distr(width: 4em, "作者")
    ],
    text(font: "KaiTi", size: zh(-3))[#author],
    none,
    text(font: "SimHei", size: zh(4))[
      #distr(width: 4em, "导师")
    ],
    text(font: "SimHei", size: zh(4))[#mentor],
    table.hline(stroke: 0.5pt, start: 1, end: 2),
    table.hline(stroke: 0.5pt, start: 4),
    text(font: "SimHei", size: zh(4))[
      #distr(width: 4em, "申请学位")
    ],
    text(font: "KaiTi", size: zh(-3))[#degree],
    none,
    text(font: "SimHei", size: zh(4))[
      #distr(width: 4em, "学院名称")
    ],
    text(font: "SimHei", size: zh(4))[#academy],
    table.hline(stroke: 0.5pt, start: 1, end: 2),
    table.hline(stroke: 0.5pt, start: 4),
    text(font: "SimHei", size: zh(4))[
      #distr(width: 4em, "学科专业")
    ],
    text(font: "KaiTi", size: zh(-3))[#subject],
    none,
    text(font: "SimHei", size: zh(4))[
      #distr(width: 4em, "研究方向")
    ],
    text(font: "KaiTi", size: zh(-3))[#research],
    table.hline(stroke: 0.5pt, start: 1, end: 2),
    table.hline(stroke: 0.5pt, start: 4),
  )

  //? 年月
  v(60pt)
  text(font: "SimHei", size: zh(-2))[
    #number_to_chinese(year)年#number_to_chinese(month)月
  ]
}

#let declaration() = {
  show: show-cn-fakebold
  set page(margin: (
    top: 3.5cm,
    bottom: 2.5cm,
    left: 2.5cm,
    right: 2.5cm,
  ))
  set par(
    justify: true,
    first-line-indent: 1.01cm,
    leading: 17pt,
  )

  //! 独创性声明标题
  v(23pt)
  align(
    center,
    text(
      font: "SimHei",
      size: zh(2),
      tracking: 4pt,
    )[
      #strong("独创性声明")
    ],
  )

  //! 独创性声明正文
  v(19pt)
  set text(font: "SimSun", size: zh(-3))
  [本人声明所呈交的论文是我个人在导师指导下进行的研究工作及取得的研究成果。尽我所知，除了文中特别加以标注和致谢的地方外，论文中不包含其他人已经发表或撰写的研究成果，也不包含为获得江西财经大学或其他教育机构的学位或证书所使用过的材料。与我一同工作的同志对本研究所做的任何贡献均已在论文中作了明确的说明并表示了谢意。]

  //! 签名与日期
  v(3 * 17.5pt)
  set text(font: "SimSun", size: zh(4))
  par(
    justify: true,
    first-line-indent: 6.75cm,
    leading: 15pt,
  )[
    签名：#underline("         ")日期：#underline("         ")
  ]

  //! 使用授权标题
  v(2 * 19.5pt)
  align(
    center,
    text(
      font: "SimHei",
      size: zh(2),
    )[
      #strong("关于论文使用授权的说明")
    ],
  )

  //! 使用授权正文
  v(19pt)
  set text(font: "SimSun", size: zh(-3))
  [本人完全了解江西财经大学有关保留、使用学位论文的规定，即：学校有权保留送交论文的复印件，允许论文被查阅和借阅；学校可以公布论文的全部或部分内容，可以采用影印、缩印或其他复制手段保存论文。

    *（保密的论文在解密后遵守此规定）*]

  //! 签名、导师签名与日期
  v(3 * 17pt)
  set text(font: "SimSun", size: zh(4))
  par(
    justify: true,
    first-line-indent: 1.5cm,
    leading: 15pt,
  )[
    签名：#underline("         ")导师签名：#underline("         ")日期：#underline("         ")
  ]
}

#let abstract(
  zh-abstract: [中文摘要],
  zh-keywords: [关键词1，关键词2，关键词3],
  en-abstract: [Abstract],
  en-keywords: [keyword1; keyword2; keyword3],
) = {
  show: el.default-enum-list.with(bottom-edge: "auto")
  set page(
    margin: (
      top: 3.5cm,
      bottom: 2.5cm,
      left: 2.5cm,
      right: 2.5cm,
    ),
    header-ascent: 0.5cm,
    header: context [
      #set par(spacing: 0.9em)
      #set text(font: ("Times New Roman", "SimSun"), size: zh(5))
      #set align(center + bottom)
      #let is-odd = calc.odd(counter(page).get().at(0))
      #let head-text = if is-odd {
        context paper-title.get()
      } else {
        calc-headings(query(heading.where(level: 1))).at(here().page() - 1)
      }
      #head-text
      #v(-6pt)
      #line(length: 100%, stroke: 0.5pt)
    ],
    footer-descent: 0.5em,
    footer: context [
      #set text(font: "Times New Roman", size: zh(-5))
      #set align(center + top)
      #counter(page).display("I")
    ],
  )
  show heading.where(level: 1): it => {
    set align(center)
    set text(
      font: ("Times New Roman", "SimHei"),
      size: zh(-3),
      //   top-edge: 1.5em,
    )
    it
    v(0.4em)
  }
  set heading(level: 1, numbering: none)
  set par(
    justify: true,
    first-line-indent: (amount: 2em, all: true),
    leading: 0.6em,
    spacing: 1em,
  )
  counter(page).update(1)

  [
    = 摘#h(2em)要

    #zh-abstract
    #v(1em)
    #text(font: "SimHei", size: zh(-4))[关键词：]
    #text(font: ("Times New Roman", "FangSong"), size: zh(-4))[#zh-keywords]

    #heading(outlined: false)[Abstract]
    #en-abstract
    #v(1em)
    *Key Words:* #en-keywords
  ]
}

#let multi-outline() = {
  set page(
    margin: (
      top: 3.5cm,
      bottom: 2.5cm,
      left: 2.5cm,
      right: 2.5cm,
    ),
    header-ascent: 0.5cm,
    header: context [
      #set par(spacing: 0.9em)
      #set text(font: ("Times New Roman", "SimSun"), size: zh(5))
      #set align(center + bottom)
      #let is-odd = calc.odd(counter(page).get().at(0))
      #let head-text = if is-odd {
        context paper-title.get()
      } else {
        calc-headings(query(heading.where(level: 1))).at(here().page() - 1)
      }
      #head-text
      #v(-6pt)
      #line(length: 100%, stroke: 0.5pt)
    ],
    footer-descent: 0.5em,
    footer: context [
      #set text(font: "Times New Roman", size: zh(-5))
      #set align(center + top)
      #counter(page).display("I")
    ],
  )
  show heading.where(level: 1): set align(center)
  set heading(level: 1, numbering: none)
  show outline.entry: it => {
    link(
      it.element.location(),
      it.indented(
        it.prefix(),
        [
          #it.body()
          #box(width: 1fr, repeat([.]))
          #context {
            let loc = it.element.location()
            let style = pn-style.at(loc)
            let num = counter(page).at(loc).first()
            if style == "roman" { numbering("I", num) } else { numbering("1", num) }
          }
        ],
        gap: 0em,
      ),
    )
  }

  [
    = 目#h(2em)录
    #outline(
      title: none,
      depth: 3,
    )

    //todo 或者手动维护？
    = TABLE OF CONTENTS<toc>
    #outline(
      title: none,
      depth: 3,
      target: <toc>,
    )

    = 图目录<toc>
    #outline(
      title: none,
      depth: 3,
      target: figure.where(kind: image),
    )

    = 表目录
    #outline(
      title: none,
      depth: 3,
      target: figure.where(kind: table),
    )

    = 公式目录
    #outline(
      title: none,
      depth: 3,
      target: math.equation,
    )
  ]
}
