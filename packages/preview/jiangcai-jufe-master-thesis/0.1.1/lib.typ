#import "@preview/cuti:0.4.0": show-cn-fakebold
#import "@preview/pointless-size:0.1.3": zh
#import "@preview/itemize:0.2.0" as el
#import "@preview/numblex:0.2.0": numblex
#import "@preview/kouhu:0.2.0": kouhu
#import "@preview/rexllent:0.4.1": xlsx-parser

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

//! 双语标题标记：写在标题旁（如 `= 绪论 #en[Introduction]`），
//! 供英文目录自动提取英文标题；正文与中文目录不受影响（不渲染任何内容）
#let en(body) = metadata(("en-title", body))

//! 在 content 树中递归查找第一个 #en[...] 标记。
//! 0.14.2 的 query 不支持在 content 片段内检索，故手动遍历
#let find-en-title(node) = {
  if type(node) != content { return none }
  if node.func() == metadata {
    let v = node.value
    if v.len() == 2 and v.at(0) == "en-title" { return node }
  }
  //! content 容器：sequence 的 children 为数组，样式包装等的 body 为 content
  for field in ("children", "body") {
    if node.has(field) {
      let inner = node.at(field)
      if type(inner) == content {
        let found = find-en-title(inner)
        if found != none { return found }
      } else if type(inner) == array {
        for child in inner {
          let found = find-en-title(child)
          if found != none { return found }
        }
      }
    }
  }
  none
}

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
    //! 第一个一级标题之前（含自身）就一个，所以大于1就分页；
    //! 每个一级标题出现时按章重置图/表/代码/算法与公式计数器（编号"章号.序号"）
    let reset-counters = {
      for k in (image, table, raw, "algorithm") {
        counter(figure.where(kind: k)).update(0)
      }
      counter(math.equation).update(0)
    }
    if query(heading.where(level: 1).before(here())).len() > 1 {
      pagebreak()
      it + reset-counters
    } else {
      it + reset-counters
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

  //! 为每个标题建立英文标题显式关联：扫描标题体内的 #en[...]，
  //! 重新发出携带标题自身 location 的 metadata，供英文目录按 location 精确匹配。
  //! 定义在分级规则之后（更外层）以收到原始标题；分页导致的位置排序反转不影响显式关联
  show heading: it => {
    let marker = find-en-title(it.body)
    if marker == none {
      it
    } else {
      [
        #it
        #metadata(("en-assoc", it.location(), marker.value.at(1)))
      ]
    }
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
    font: ("Times New Roman", "SimSun"),
    size: zh(-4),
    lang: "zh",
    region: "cn",
    top-edge: "ascender",
    bottom-edge: "descender",
  )

  //! 设置figure格式：图/表/代码/算法按 kind 分开计数，编号为"章号.序号"。
  //! 编号在 kind 级 set 规则中全局设置（不能写在 `show figure: it => { set..; it }`
  //! 的函数体内——已构造的 figure 元素不会重读该样式，否则题注/引用/目录会退回"图 1"）。
  //! 保留 Typst 在 supplement 与编号间自动插入的空格，
  //! 使题注、正文引用、图表目录统一显示为"图 2.1"（"图"字与编号间有间隔，与 docx 模板一致）
  let figure-numbering(
    k,
  ) = _ => [#counter(heading.where(level: 1)).display("1").#counter(figure.where(kind: k)).display("1")]
  set figure.caption(separator: "  ")
  show figure.where(kind: image): set figure(numbering: figure-numbering(image), supplement: [图])
  show figure.where(kind: table): set figure(numbering: figure-numbering(table), supplement: [表])
  show figure.where(kind: raw): set figure(numbering: figure-numbering(raw), supplement: [代码])
  show figure.where(kind: "algorithm"): set figure(numbering: figure-numbering("algorithm"), supplement: [算法])

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

  //! 其中插入交叉引用：保留默认"中西文自动间距"，编号末尾数字与后续中文之间
  //! 自然形成小空格（如"如图 2.1 所示"），与 docx 模板一致
  show ref: it => context {
    let el = it.element
    //! 引用主体：图/表/代码/算法用默认渲染；公式用目标位置计数器重建，
    //! 必须 counter.at 而非 .display（后者在引用处求值会少 1）
    if el == none or el.func() != math.equation {
      it
    } else {
      let chap = counter(heading.where(level: 1)).at(el.location()).first()
      let num = counter(math.equation).at(el.location()).first()
      link(el.location(), numbering((c, n) => [式（#c.#n）], chap, num))
    }
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

  //! 其中插入代码格式（用文末的 code() 函数生成代码清单，
  //! 代码左对齐、整体左缩进 2 字符，编号"章号.序号"，caption 在上方，引用时 supplement 为"代码"）
  show figure.where(kind: raw): set figure.caption(position: top)
  show figure.where(kind: raw): it => {
    v(1em)
    it
  }
  //! par 设置只对块级代码生效；行内代码（如 `pd.read_excel`）必须保持行内，
  //! 否则会把所在段落切碎成多行
  show raw.where(block: true): set par(first-line-indent: 0em, justify: false)
  show raw: set text(font: ("Courier New", "SimSun"), size: zh(5))

  //! 其中插入伪代码格式（用文末的 algorithm() 函数生成，
  //! 算法框左对齐、整体左缩进 2 字符，编号"章号.序号"，caption 在上方，引用时 supplement 为"算法"）
  show figure.where(kind: "algorithm"): set figure.caption(position: top)
  show figure.where(kind: "algorithm"): it => {
    v(1em)
    it
  }

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
  //! 正文中文加粗用 cuti 伪粗（包内中文字体仅随 Regular 字重，西文加粗仍由
  //! Times New Roman Bold 承担），与前置部分 typeset-fore 保持一致
  show: show-cn-fakebold
  pn-style.update("arabic")
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
    image("./assets/硕士毕业论文封面logo.png", width: 6.78cm),
  )

  //! 出版信息
  {
    let _underline() = {
      rect(
        width: 3.1cm,
        stroke: (bottom: 0.6pt + black),
      )
    }
    set text(font: ("Times New Roman", "SimHei"), size: zh(5))
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
    text(font: ("Times New Roman", "SimHei"), size: zh(-3))[论文题目],
    text(font: "KaiTi", size: zh(3))[#zh-title1],
    table.hline(stroke: 0.5pt, start: 1),
    text(font: ("Times New Roman", "SimHei"), size: zh(4))[（中文）],
    text(font: "STZhongsong", size: zh(4))[#zh-title2],
    table.hline(stroke: 0.5pt, start: 1),
    text(font: ("Times New Roman", "SimHei"), size: zh(-3))[论文题目],
    text(font: "Times New Roman", size: zh(3))[#en-title1],
    table.hline(stroke: 0.5pt, start: 1),
    text(font: ("Times New Roman", "SimHei"), size: zh(4))[（英文）],
    text(font: "Times New Roman", size: zh(3))[#en-title2],
    table.hline(stroke: 0.5pt, start: 1),
  )

  //? 作者信息
  v(5pt)
  table(
    columns: (2.44cm, 4.88cm, 0.42cm, 2.45cm, 4.26cm),
    rows: 1.06cm,
    align: center + bottom,
    stroke: none,
    text(font: ("Times New Roman", "SimHei"), size: zh(4))[
      #distr(width: 4em, "作者")
    ],
    text(font: "KaiTi", size: zh(-3))[#author],
    none,
    text(font: ("Times New Roman", "SimHei"), size: zh(4))[
      #distr(width: 4em, "导师")
    ],
    text(font: ("Times New Roman", "SimHei"), size: zh(4))[#mentor],
    table.hline(stroke: 0.5pt, start: 1, end: 2),
    table.hline(stroke: 0.5pt, start: 4),
    text(font: ("Times New Roman", "SimHei"), size: zh(4))[
      #distr(width: 4em, "申请学位")
    ],
    text(font: "KaiTi", size: zh(-3))[#degree],
    none,
    text(font: ("Times New Roman", "SimHei"), size: zh(4))[
      #distr(width: 4em, "学院名称")
    ],
    text(font: ("Times New Roman", "SimHei"), size: zh(4))[#academy],
    table.hline(stroke: 0.5pt, start: 1, end: 2),
    table.hline(stroke: 0.5pt, start: 4),
    text(font: ("Times New Roman", "SimHei"), size: zh(4))[
      #distr(width: 4em, "学科专业")
    ],
    text(font: "KaiTi", size: zh(-3))[#subject],
    none,
    text(font: ("Times New Roman", "SimHei"), size: zh(4))[
      #distr(width: 4em, "研究方向")
    ],
    text(font: "KaiTi", size: zh(-3))[#research],
    table.hline(stroke: 0.5pt, start: 1, end: 2),
    table.hline(stroke: 0.5pt, start: 4),
  )

  //? 年月
  v(60pt)
  text(font: ("Times New Roman", "SimHei"), size: zh(-2))[
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
      font: ("Times New Roman", "SimHei"),
      size: zh(2),
      tracking: 4pt,
    )[
      #strong("独创性声明")
    ],
  )

  //! 独创性声明正文
  v(19pt)
  set text(font: ("Times New Roman", "SimSun"), size: zh(-3))
  [本人声明所呈交的论文是我个人在导师指导下进行的研究工作及取得的研究成果。尽我所知，除了文中特别加以标注和致谢的地方外，论文中不包含其他人已经发表或撰写的研究成果，也不包含为获得江西财经大学或其他教育机构的学位或证书所使用过的材料。与我一同工作的同志对本研究所做的任何贡献均已在论文中作了明确的说明并表示了谢意。]

  //! 签名与日期
  v(3 * 17.5pt)
  set text(font: ("Times New Roman", "SimSun"), size: zh(4))
  par(
    justify: true,
    first-line-indent: 6.75cm,
    leading: 15pt,
  )[
    签名：#underline("                  ")日期：#underline("                  ")
  ]

  //! 使用授权标题
  v(2 * 19.5pt)
  align(
    center,
    text(
      font: ("Times New Roman", "SimHei"),
      size: zh(2),
    )[
      #strong("关于论文使用授权的说明")
    ],
  )

  //! 使用授权正文
  v(19pt)
  set text(font: ("Times New Roman", "SimSun"), size: zh(-3))
  [本人完全了解江西财经大学有关保留、使用学位论文的规定，即：学校有权保留送交论文的复印件，允许论文被查阅和借阅；学校可以公布论文的全部或部分内容，可以采用影印、缩印或其他复制手段保存论文。

    *（保密的论文在解密后遵守此规定）*]

  //! 签名、导师签名与日期
  v(3 * 17pt)
  set text(font: ("Times New Roman", "SimSun"), size: zh(4))
  par(
    justify: true,
    first-line-indent: 1.5cm,
    leading: 15pt,
  )[
    签名：#underline("                  ")导师签名：#underline("                  ")日期：#underline("                  ")
  ]
}

#let abstract(
  zh-abstract: [中文摘要],
  zh-keywords: [关键词1，关键词2，关键词3],
  en-abstract: [Abstract],
  en-keywords: [keyword1; keyword2; keyword3],
) = {
  //! bottom-edge 是题注编号文字的 text 参数，只接受 "baseline"/"descender"/"bounds"/长度；
  //! 写 "auto" 在 0.14.2 会报错（abstract 内无列表时不触发，含列表时触发）
  show: el.default-enum-list.with(bottom-edge: "baseline")
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
    = 摘#h(2em)要 #en[Abstract]

    #zh-abstract
    #v(1em)
    #text(font: ("Times New Roman", "SimHei"), size: zh(-4))[关键词：]
    #text(font: ("Times New Roman", "FangSong"), size: zh(-4))[#zh-keywords]

    #heading(outlined: false)[Abstract]
    #en-abstract
    #v(1em)
    *Key Words:* #en-keywords
  ]
}

//! 目录条目：点线引导 + 页码（前置部分 roman / 正文部分 arabic）
#let outline-entry(it) = {
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

//! 英文目录条目：提取标题旁 #en[...] 标注的英文标题，未标注的标题回退显示原文
#let outline-entry-en(it) = {
  context {
    let en-text = none
    //! 匹配标题 show 规则生成的显式关联 metadata（携带标题自身 location，
    //! 避免分页导致标题与体内 #en[...] 的位置排序反转）
    for m in query(metadata) {
      let v = m.value
      if v.len() == 3 and v.at(0) == "en-assoc" and v.at(1) == it.element.location() {
        en-text = v.at(2)
      }
    }
    link(
      it.element.location(),
      it.indented(
        it.prefix(),
        [
          #if en-text != none { en-text } else { it.body() }
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

  //! 中文目录（目录自身标题进入中英文目录：中文目录显示"目录"，英文目录显示"TOC"，
  //! 页码均为中文目录本页；与 docx 模板一致）
  show outline.entry: outline-entry
  [
    #heading(level: 1)[目#h(2em)录 #en[TOC]]
    #outline(
      title: none,
      depth: 3,
    )
  ]

  //! 英文目录：标题仅作本页页名，不进入任何目录（独立插入，不参与中文目录）
  show outline.entry: outline-entry-en
  [
    #heading(level: 1, outlined: false)[TABLE OF CONTENTS]
    #outline(
      title: none,
      depth: 3,
    )
  ]

  //! 图/表/公式目录（标题均进入中英文总目录）
  show outline.entry: outline-entry
  [
    #heading(level: 1)[图目录 #en[List of Figures]]
    #outline(
      title: none,
      depth: 3,
      target: figure.where(kind: image),
    )

    #heading(level: 1)[表目录 #en[List of Tables]]
    #outline(
      title: none,
      depth: 3,
      target: figure.where(kind: table),
    )

    #heading(level: 1)[公式目录 #en[List of Equations]]
    #outline(
      title: none,
      depth: 3,
      target: math.equation,
    )
  ]
}

//! 代码清单环境：代码块左对齐、整体左缩进 2 字符（figure 默认会将内容居中，
//! 故用通栏 block 包裹并左对齐），编号"章号.序号"（计入 raw 类型，不与图表混编）。
//! 用法：
//! #code(
//!   ```python
//!   print("hello")
//!   ```,
//!   caption: [代码名称],
//! ) <code1> 之后用 @code1 引用，自动显示为"代码x.y"
//! supplement/编号由 typeset-fore 中 kind 为 raw 的全局 set 规则提供
#let code(body, caption: [代码标题]) = figure(
  block(
    width: 100%,
    inset: (left: 2em),
  )[
    #set align(left)
    #body
  ],
  kind: raw,
  caption: caption,
)

//! 伪代码环境：三线风格算法框，算法框左对齐、整体左缩进 2 字符，
//! 编号"章号.序号"（计入 algorithm 类型，不与图表混编）。
//! 用法：
//! #algorithm(
//!   caption: [算法名称],
//!   input: [输入说明（可省略）],
//!   output: [输出说明（可省略）],
//!   [算法步骤，用 \ 换行],
//! ) <alg1> 之后用 @alg1 引用
//! supplement/编号由 typeset-fore 中 kind 为 "algorithm" 的全局 set 规则提供
#let algorithm(body, caption: [算法标题], input: none, output: none) = figure(
  kind: "algorithm",
  block(
    width: 100%,
    inset: (left: 2em),
  )[
    #set align(left)
    #table(
      columns: 1,
      stroke: (top: 0.75pt, bottom: 0.75pt, x: none, y: none),
      inset: (x: 1em, y: 0.35em),
      if input != none [*输入：*#input],
      if output != none [*输出：*#output],
      body,
    )
  ],
  caption: caption,
)

//! 设置三线表格式（data 为读取好的文件内容，须在调用处用
//! `read("./tables/xxx.xlsx", encoding: none)` 读取，以保证路径相对使用者文件解析）
#let tlt(data) = {
  xlsx-parser(
    data,
    parse-table-style: false,
    parse-alignment: false,
    parse-stroke: false,
    parse-fill: true,
    parse-font: true,
    parse-header: true,
    parse-formatted-cell: true,
    rows: 1.8em,
    align: horizon,
    prepend-elems: (table.hline()),
    stroke: (_, y) => {
      if y == 0 {
        return (bottom: 0.5pt)
      }
    },
    table.hline(),
  )
}
