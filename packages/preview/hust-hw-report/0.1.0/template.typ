// =====================================================================
// 华中科技大学《硬件综合训练》课程设计报告 Typst 模板
// 依据《硬件综合训练报告模板 2026-8-3 修订版.docx》逐项还原
// 适用于 typst 0.13+
// =====================================================================

// ---------- 字体 ----------
#let f-song = ("Times New Roman", "SimSun")        // 正文：中文宋体、西文 Times
#let f-hei = "SimHei"                              // 标题：黑体
#let f-kai = "KaiTi"                               // 页眉、声明：楷体
#let f-zhongsong = "STZhongsong"                   // 封面大标题：华文中宋
#let f-ar = "Arial"                                // 标题编号数字
#let f-cal = "Calibri"                             // 目录编号
#let f-code = "Consolas"                           // 代码

// ---------- 字号（中文字号制） ----------
#let z-chu = 42pt    // 初号（封面年份）
#let z-san = 16pt    // 三号（章标题、目录题、声明题）
#let z-si = 14pt     // 四号（节标题、封面信息、目录条目、声明正文）
#let z-xiao4 = 12pt  // 小四（正文）
#let z-wu = 10.5pt   // 五号（题注、代码）

// ---------- 颜色 ----------
#let c-green = rgb("9BBB59")     // 封面橄榄绿竖条
#let c-blue = rgb("4F81BD")      // 封面标题蓝底
#let c-red = rgb("FF0000")       // 页眉红字
#let c-codebg = rgb("D9D9D9")    // 代码灰色底纹

// ---------- 内部量 ----------
#let _header-text = "华 中 科 技 大 学 课 程 设 计 报 告"

// 红色页眉（目录、正文各节共用）
#let _red-header() = {
  place(top + center, dy: 1.93cm, text(font: f-kai, size: 16.5pt, weight: "bold", fill: c-red)[#_header-text])
  place(top + center, dy: 2.64cm, line(length: 15.9cm, stroke: 3pt + black))
}

// 页脚页码（跟随当前节页码格式）
#let _num-footer() = {
  place(bottom + center, dy: -1.5cm,
    text(font: "Times New Roman", size: 9pt, context counter(page).display()))
}

// 末节页眉：·指导教师评定意见·
#let _decl-header() = {
  place(top + left, dy: 2.7cm, dx: 0.2cm,
    text(font: f-kai, size: 14pt, weight: "bold")[·指导教师评定意见·])
  place(top + left, dy: 3.15cm, line(length: 100% + 0.1cm, stroke: 3pt + black))
}

// 末节页脚：横线 + 页码
#let _decl-footer() = {
  place(bottom + center, dy: -2.05cm, line(length: 100%, stroke: 3pt + black))
  place(bottom + center, dy: -1.5cm,
    text(font: "Times New Roman", size: 9pt, context counter(page).display()))
}

// 标题编号：1 / 1.1 / 1.1.1 / （1）
#let _h-num(..nums) = {
  let a = nums.pos()
  if a.len() == 1 { numbering("1", a.first()) + h(0.55cm) }
  else if a.len() == 2 { numbering("1.1", ..a) + h(0.33cm) }
  else if a.len() == 3 { numbering("1.1.1", ..a) + h(0.33cm) }
  else { "(" + numbering("1", a.last()) + ")" + h(0.35cm) }
}

// 图注编号：图 N.X（N 章号，X 章内图序，每章重置）
// 在图表所在位置求值；交叉引用由 ref 显示规则在目标位置另行解析
#let _fig-num(..nums) = context {
  let ch = counter(heading).get().first()
  numbering("1.1", ch, nums.pos().last())
}

// 带下划线的封面填写栏
#let _name-line(body) = box(
  width: 100%,
  stroke: (bottom: 0.6pt + black),
  inset: (bottom: 4pt),
  align(center, text(font: f-song, size: z-si)[#body]),
)

// 封面信息表
#let _cover-table(title, major, class, stu-num, name, phone, mail) = {
  let rowh = 1.173cm
  place(top + left, dx: -0.28cm, dy: 11.5cm,
    grid(
      columns: (2.75cm, 7.03cm),
      rows: (rowh,) * 7,
      align: horizon,
      align(right, pad(right: 2pt, text(font: f-hei, size: z-si)[题　　目：])), _name-line(title),
      align(right, pad(right: 2pt, text(font: f-hei, size: z-si)[专　　业：])), _name-line(major),
      align(right, pad(right: 2pt, text(font: f-hei, size: z-si)[班　　级：])), _name-line(class),
      align(right, pad(right: 2pt, text(font: f-hei, size: z-si)[学　　号：])), _name-line(stu-num),
      align(right, pad(right: 2pt, text(font: f-hei, size: z-si)[姓　　名：])), _name-line(name),
      align(right, pad(right: 2pt, text(font: f-hei, size: z-si)[电　　话：])), _name-line(phone),
      align(right, pad(right: 2pt, text(font: f-hei, size: z-si)[邮　　件：])), _name-line(mail),
    )
  )
}

// 封面背景：右侧橄榄绿竖条 + 条纹边线（通栏，页面坐标）
#let _cover-bands() = {
  // 校名书法字（置于最底层，使条纹边线压住其白底边缘，与 Word 层级一致）
  place(top + left, dx: 3.19cm, dy: 4.92cm,
    image("assets/hust-name.png", width: 9.55cm))
  place(top + left, dx: 12.97cm, dy: 0cm,
    rect(width: 8.03cm, height: 29.7cm, fill: c-green, stroke: none))
  place(top + left, dx: 12.62cm, dy: 0cm,
    image("assets/band-edge.png", width: 0.35cm, height: 29.7cm))
}

// 封面前景元素（坐标相对版心，允许负偏移）
#let _cover(year, course, doc-type, title, major, class, stu-num, name, phone, mail) = {
  // 年份（绿条上的白字）
  place(top + left, dx: 13.0cm, dy: 2.2cm,
    text(font: ("Cambria", "Times New Roman", "SimSun"), size: z-chu, weight: "bold", fill: white)[#year])
  // 蓝底白字标题条
  place(top + left, dx: -0.34cm, dy: 4.94cm,
    rect(width: 17.01cm, height: 1.97cm, fill: c-blue, stroke: none,
      align(left + horizon, pad(left: 0.45cm,
        text(font: f-zhongsong, size: 30pt, weight: "bold", fill: white)[#course#h(1.55cm)#doc-type]))))
  // 信息表
  _cover-table(title, major, class, stu-num, name, phone, mail)
}

// 目录页
#let _toc-page() = {
  counter(page).update(1)
  v(0.8cm)
  align(center, text(font: f-hei, size: z-san)[目　　录])
  v(0.5cm)
  outline(title: none, depth: 2)
}

// 末页：指导教师评定意见 + 原创性声明
#let _declaration-page(name, signature) = {
  pagebreak()
  set page(header: _decl-header(), footer: _decl-footer())
  {
    set text(font: f-kai, size: z-si)
    set par(justify: true, leading: 1.2em, spacing: 1.2em,
      first-line-indent: (amount: 2em, all: true))
    v(0.95cm)
    align(left, text(size: z-san)[一、原创性声明])
    v(0.45cm)
    [本人郑重声明本报告内容，是由作者本人独立完成的。有关观点、方法、数据和文献等的引用已在文中指出。除文中已注明引用的内容外，本报告不包含任何其他个人或集体已经公开发表的作品成果，不存在剽窃、抄袭行为。]
    v(0.55cm)
    [特此声明！]
    v(1.1cm)
    place(right, dx: -4.1cm, {
      text()[作者签字：#name]
      if signature != none { box(baseline: 0.15cm, signature) }
    })
  }
}

// =====================================================================
// 主模板函数
// =====================================================================
#let report(
  title: "",
  major: "",
  class: "",
  stu-num: "",
  name: "",
  phone: "",
  mail: "",
  year: "2026",
  course: "硬件综合训练",
  doc-type: "课程设计报告",
  declaration: true,
  signature: none,
  body,
) = {
  set document(title: title, author: name)
  set page(
    paper: "a4",
    margin: (top: 2.54cm, bottom: 2.54cm, left: 3.17cm, right: 2.5cm),
    header: none, footer: none, numbering: none,
    background: _cover-bands(),
  )

  // ---- 目录条目样式（需在 outline 渲染前生效）----
  set outline(indent: 0.43cm)
  show outline.entry.where(level: 1): it => {
    set text(font: (f-cal, "SimSun"), size: z-si)
    strong(it)
    v(6pt)
  }
  show outline.entry.where(level: 2): it => {
    set text(font: (f-cal, "SimSun"), size: z-si)
    it
  }

  // ---- 封面：无页眉页脚页码 ----
  _cover(year, course, doc-type, title, major, class, stu-num, name, phone, mail)
  pagebreak()

  // ---- 目录：罗马页码 ----
  set page(
    margin: (top: 3.25cm, bottom: 2.8cm, left: 2.7cm, right: 2.7cm),
    header: _red-header(), footer: _num-footer(), numbering: "I",
    background: none,
  )
  _toc-page()
  pagebreak()

  // ---- 正文：阿拉伯页码接续 ----
  set page(
    margin: (top: 3cm, bottom: 2.5cm, left: 2.7cm, right: 2.75cm),
    numbering: "1",
  )
  set text(font: f-song, size: z-xiao4, lang: "zh", region: "cn")
  set par(justify: true, leading: 1.26em, spacing: 1.26em,
    first-line-indent: (amount: 2em, all: true))
  set heading(numbering: _h-num)
  set figure(gap: 8pt)
  set table(stroke: 0.5pt + black, inset: (x: 5pt, y: 4pt))
  set enum(numbering: "（1）", indent: 0.85cm, spacing: 1.26em, tight: false)
  set list(indent: 0.85cm, spacing: 1.26em, tight: false)

  // 图：居中，图注在下方（黑体五号）
  show figure.where(kind: image): it => block(width: 100%, breakable: false, {
    align(center, it.body)
    it.caption
  })
  // 表：表注在上方；题注与表格主体不锁死为整体，表格可自然跨页
  show figure.where(kind: table): it => {
    block(width: 100%, above: 10pt, below: 4pt, breakable: false, it.caption)
    block(width: 100%, breakable: true, align(center, it.body))
  }
  // 交叉引用：图引用（@fig-xx）在目标位置解析编号；
  // 表引用（@tbl-xx）通过 tbl() 写入的 metadata 标记定位目标后解析编号
  show ref: it => {
    let name = str(it.target)
    if name.starts-with("tbl-") {
      context {
        let marks = query(metadata).filter(m => m.value == name)
        let loc = marks.last().location()
        let ch = counter(heading).at(loc).first()
        let seq = counter(figure.where(kind: table)).at(loc).first()
        [表#h(0.1em)#numbering("1.1", ch, seq)]
      }
    } else {
      let el = it.element
      if el != none and el.func() == figure {
        let sup = if el.kind == image { [图] } else if el.kind == table { [表] } else { it }
        context {
          let loc = el.location()
          let ch = counter(heading).at(loc).first()
          let seq = counter(figure.where(kind: el.kind)).at(loc).first()
          [#sup#h(0.1em)#numbering("1.1", ch, seq)]
        }
      } else {
        it
      }
    }
  }
  set figure.caption(separator: h(0.55em))
  show figure.caption: it => align(center, {
    set text(font: f-hei, size: z-wu)
    pad(top: 3pt, bottom: 3pt, it)
  })
  // 代码块：灰色底纹
  show raw: set text(font: (f-code, "SimSun"), size: z-wu)
  show raw.where(block: true): it => block(width: 100%, fill: c-codebg,
    inset: (x: 10pt, y: 7pt), it)

  // 章标题（黑体三号居中，每章新起一页；重置图表计数器）
  show heading.where(level: 1): it => {
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    pagebreak(weak: true)
    v(24pt, weak: false)
    block(width: 100%, above: 0pt, below: 24pt, align(center, {
      set text(font: (f-ar, f-hei), size: z-san, weight: "regular")
      if it.numbering != none { counter(heading).display(it.numbering) }
      it.body
    }))
  }
  // 节标题（黑体四号左对齐）
  show heading.where(level: 2): it => block(width: 100%, above: 12pt, below: 12pt, {
    set text(font: (f-ar, f-hei), size: z-si, weight: "regular")
    counter(heading).display(it.numbering)
    it.body
  })
  // 小节标题（黑体小四左对齐）
  show heading.where(level: 3): it => block(width: 100%, above: 11pt, below: 11pt, {
    set text(font: (f-ar, f-hei), size: z-xiao4, weight: "regular")
    counter(heading).display(it.numbering)
    it.body
  })
  // 条目标题（宋体小四加粗：（1）（2）…）
  show heading.where(level: 4): it => block(width: 100%, above: 8pt, below: 8pt, {
    set text(font: f-song, size: z-xiao4, weight: "bold")
    pad(left: 2em, counter(heading).display(it.numbering) + it.body)
  })

  body

  // ---- 末页：指导教师评定意见 + 原创性声明 ----
  if declaration {
    _declaration-page(name, signature)
  }
}

// =====================================================================
// 供用户调用的辅助函数
// =====================================================================

// 插图：#fig("assets/xx.png", caption: "总体结构图")<fig-xx>
// 正文引用：如 @fig-xx 所示
#let fig(path, caption: "", width: 80%) = figure(
  image(path, width: width),
  caption: caption,
  kind: image,
  supplement: [图],
  numbering: _fig-num,
)

// 插表：#tbl(table(...), caption: "指令表", label: "tbl-xx")
// 引用：#tref("tbl-xx") 或 @tbl-xx，显示"表 N.X"
// 表格主体可自然跨页（figure 元素本身不可跨页，故题注锚点与表格主体分离）
#let tbl(body, caption: "", label: none) = {
  figure([], caption: caption, kind: table, supplement: [表], numbering: _fig-num)
  if label != none { metadata(label) }
  body
}

// 表格引用：#tref("tbl-xx")，等价于 @tbl-xx，显示"表 N.X"
#let tref(name) = context {
  let marks = query(metadata).filter(m => m.value == name)
  let loc = marks.last().location()
  let ch = counter(heading).at(loc).first()
  let seq = counter(figure.where(kind: table)).at(loc).first()
  [表#h(0.1em)#numbering("1.1", ch, seq)]
}

// 参考文献条目：#refs[条目一][条目二]…  自动编号 [1] [2] …
#let refs(..entries) = {
  set par(first-line-indent: (amount: 0em, all: false), spacing: 0pt, leading: 1.2em)
  set enum(numbering: "[1]", indent: 0pt, spacing: 1em, tight: false)
  enum(..entries)
}
