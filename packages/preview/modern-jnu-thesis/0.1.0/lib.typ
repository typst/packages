#let jnu-serif = (
  "Times New Roman",
  "Liberation Serif",
  "SimSun",
  "Songti SC",
  "Noto Serif CJK SC",
  "Source Han Serif SC",
)
#let jnu-sans = (
  "SimHei",
  "Heiti SC",
  "Noto Sans CJK SC",
  "Source Han Sans CN",
)
#let jnu-kai = (
  "KaiTi",
  "STKaiti",
  "LXGW WenKai",
  "Noto Serif CJK SC",
)

#let jnu-body-size = 14pt        // 四号
#let jnu-heading-size = 15pt     // 小三
#let jnu-caption-size = 10.5pt   // 五号
#let jnu-note-size = 9pt         // 小五
#let jnu-leading = 0.83em        // 约等于 1.5 倍行距

#let jnu-margin = (
  left: 3cm,
  right: 2cm,
  top: 2.5cm,
  bottom: 2.5cm,
)

#let jnu-chapter-drop = 0.9cm

// auto 的项会自动跟随正文字号
#let jnu-default-sizes = (
  body: jnu-body-size,          // 正文
  heading: jnu-heading-size,    // 各级标题
  caption: jnu-caption-size,    // 图、表标题
  note: jnu-note-size,          // 脚注
  code: 10.5pt,                 // 代码块
  cover-title: 36pt,            // 封面“暨南大学 / 本科生毕业论文”
  cover-info: auto,             // 封面信息栏与日期
  statement-title: 22pt,        // 诚信声明标题
  statement-body: auto,         // 诚信声明正文
  abstract-title: 18pt,         // 中英文摘要标题（论文题目）
  abstract-body: auto,          // 中英文摘要正文
  reference: auto,              // 参考文献条目（默认跟随 caption）
  toc-title: 24pt,              // “目 录”标题
  toc-entry: auto,              // 目录条目
  header: 10.5pt,               // 页眉
  footer: 10.5pt,               // 页码
)

#let _resolve-sizes(sizes) = {
  let s = jnu-default-sizes + sizes
  let pick(value) = if value == auto { s.body } else { value }
  s + (
    cover-info: pick(s.cover-info),
    statement-body: pick(s.statement-body),
    abstract-body: pick(s.abstract-body),
    reference: if s.reference == auto { s.caption } else { s.reference },
    toc-entry: pick(s.toc-entry),
  )
}

// 封面信息栏的下划线输入框。
#let _field-box(value, width: 154pt) = box(
  width: width,
  stroke: (bottom: 0.5pt),
  inset: (bottom: 4pt),
  align(center, value),
)

// 页眉：论文题目居中，下方一条 0.5pt 细线。
#let _running-header(title, size: 10.5pt) = {
  set text(font: jnu-serif, size: size)
  align(center, title)
  v(1.5pt)
  line(length: 100%, stroke: 0.5pt)
}

// 页脚：居中页码。
#let _page-footer(size: 10.5pt) = context {
  set text(font: jnu-serif, size: size)
  align(center, counter(page).display())
}

// 居中标题（用于摘要页、目录页等非正文标题）。
#let _display-title(body, size: 18pt, font: jnu-sans, tracking: 0em) = align(
  center,
  text(size: size, font: font, tracking: tracking, body),
)

// 关键词拼接。
#let _keywords(items, sep: "；") = items.join(sep)

// 允许封面字段传字符串或字符串数组：数组用于指定封面换行。
#let _as-lines(value) = if type(value) == array { value } else { (value,) }
#let _as-text(value) = if type(value) == array { value.join("") } else { value }

//  封面
#let _cover(
  title: "",
  college: "",
  major: "",
  author: "",
  student-id: "",
  supervisor: "",
  date: "",
  logo: "res/jnulogo.png",
  title-size: 36pt,
  info-size: 14pt,
) = {
  set page(
    header: none,
    footer: none,
    numbering: none,
    margin: (left: 2.5cm, right: 2.5cm, top: 2.5cm, bottom: 2.5cm),
  )
  set text(font: jnu-serif, size: info-size)
  set par(first-line-indent: 0pt, justify: false, spacing: 0pt)

  align(center, block(image(logo, width: 4cm)))
  v(1.53cm)
  align(center, block[
    #set par(leading: 0.83 * title-size)
    #text(font: jnu-sans, size: title-size, tracking: 0.30em)[暨南大学]#linebreak()
    #text(font: jnu-sans, size: title-size, tracking: 0.30em)[本科生毕业论文]
  ])

  v(4.44cm)

  grid(
    columns: (70pt, 349.2pt),
    align: (left + horizon, center + horizon),
    [论文题目：],
    _field-box(title, width: 349.2pt),
  )

  v(4.40cm)

  align(
    center,
    grid(
      columns: (70pt, 154pt),
      row-gutter: 16pt,
      align: (left + horizon, center + horizon),
      [学　　院：],
      _field-box(college),
      [专　　业：],
      _field-box(major),
      [姓　　名：],
      _field-box(author),
      [学　　号：],
      _field-box(student-id),
      [指导教师：],
      _field-box(supervisor),
    ),
  )

  v(1.82cm)
  align(center, text(size: info-size, date))
}

// 调研报告封面的多行下划线字段：数组用于指定换行，每个值行单独带下划线。
#let _cover-lines(label, value) = {
  let lines = _as-lines(value)
  let cells = ()
  for (i, line) in lines.enumerate() {
    cells.push(if i == 0 { strong(label) } else { [] })
    cells.push(box(
      width: 100%,
      height: 1.25em,
      stroke: (bottom: 0.5pt),
      inset: (bottom: 3pt),
      align(left + horizon, line),
    ))
  }
  cells
}

// 调研报告封面。
#let _cover-report(
  title: "",
  course: "",
  class-name: "",
  supervisor: "",
  score: "",
  date: "",
  logo: "res/jnulogo.png",
  title-size: 36pt,
  info-size: 14pt,
) = {
  set page(
    header: none,
    footer: none,
    numbering: none,
    margin: (left: 2.5cm, right: 2.5cm, top: 2.5cm, bottom: 2.5cm),
  )
  set text(font: jnu-serif, size: info-size)
  set par(first-line-indent: 0pt, justify: false, spacing: 0pt)

  align(center, block(image(logo, width: 3.5cm)))
  v(0.9cm)
  align(center, text(
    font: jnu-sans,
    size: title-size,
    weight: "bold",
    tracking: 0.30em,
  )[学生实践调查报告])

  v(1.8cm)

  align(center, block(width: 430pt, grid(
    columns: (5em, 1fr),
    row-gutter: 12pt,
    align: (left + horizon, left + horizon),
    .._cover-lines("课程名称：", course),
    .._cover-lines("调查题目：", title),
    .._cover-lines("专业班级：", class-name),
    .._cover-lines("指导老师：", supervisor),
    .._cover-lines("成绩评分：", score),
  )))

  v(9.8cm)
  align(center, text(size: info-size, date))
}

//  诚信声明
#let _statement(
  title-size: 22pt,
  body-size: 14pt,
  leading: jnu-leading,
  report: false,
) = {
  set text(font: jnu-serif, size: body-size)
  set par(
    first-line-indent: (amount: 2em, all: true),
    leading: leading,
    spacing: leading,
    justify: true,
  )

  let doc-name = if report { "调查报告" } else { "毕业论文" }
  let doc-short = if report { "报告" } else { "论文" }
  let declarant = if report { "本人及小组成员" } else { "本人" }

  align(center, text(font: jnu-kai, size: title-size, tracking: 0.45em)[诚信声明])

  v(2.40cm)

  [我声明，所呈交的#(doc-name)是#(declarant)在老师指导下进行的研究工作及取得的研究成果。据我查证，除了文中特别加以标注和致谢的地方外，#(doc-short)中不包含其他人已经发表或撰写过的研究成果，也不包含为获得其他教育机构的学位或证书而使用过的材料。我承诺，#(doc-short)中的所有内容均真实、可信。]

  v(6.55cm)

  grid(
    columns: (1fr, auto),
    align: (left + horizon, right + horizon),
    [#(doc-name)作者签名：],
    [签名日期：#h(1.8em)年#h(1.8em)月#h(1.8em)日],
  )
}

//  调研报告分工表
#let _division-table(
  team: (),
  title-size: 18pt,
  size: 14pt,
) = {
  set page(header: none, footer: none, numbering: none)
  set text(font: jnu-serif, size: size)
  set par(first-line-indent: 0pt, justify: false, spacing: 0pt)

  align(center, text(font: jnu-sans, size: title-size, weight: "bold")[分工表])
  v(1.5cm)

  let members = if team.len() == 0 {
    (("", "", ""), ("", "", ""), ("", "", ""), ("", "", ""))
  } else {
    team.map(member => (
      member.at("name", default: ""),
      member.at("student-id", default: ""),
      member.at("work", default: ""),
    ))
  }

  let cells = ()
  for (i, member) in members.enumerate() {
    cells += member
    // 空白行之间加细线，方便打印后手写填写。
    if team.len() == 0 and i < members.len() - 1 {
      cells.push(table.hline(stroke: 0.3pt))
    }
  }

  table(
    columns: (1.2fr, 1.6fr, 3.2fr),
    align: (center + horizon, center + horizon, left + horizon),
    inset: (x: 8pt, y: 9pt),
    stroke: none,
    table.hline(stroke: 1pt),
    [*姓名*], [*学号*], [*分工*],
    table.hline(stroke: 0.5pt),
    ..cells,
    table.hline(stroke: 1pt),
  )
}

//  中文摘要
#let _abstract-cn(
  title: "",
  abstract: [],
  keywords: (),
  size: 14pt,
  title-size: 18pt,
  leading: jnu-leading,
) = {
  set text(font: jnu-serif, size: size)
  set par(
    first-line-indent: (amount: 2em, all: true),
    leading: leading,
    spacing: leading,
    justify: true,
  )

  _display-title(title, size: title-size, font: jnu-sans)

  v(1.1cm)

  grid(
    columns: (4em, 1fr),
    align: (left + top, left + top),
    strong("[摘要]"),
    {
      set par(first-line-indent: 0pt)
      abstract
    },
  )

  v(1.2cm)

  grid(
    columns: (5em, 1fr),
    align: (left + top, left + top),
    strong("[关键词]"),
    {
      set par(first-line-indent: 0pt)
      _keywords(keywords)
    },
  )
}

//  英文摘要
#let _abstract-en(
  title: "",
  abstract: [],
  keywords: (),
  size: 14pt,
  title-size: 18pt,
  leading: jnu-leading,
) = {
  set text(font: jnu-serif, size: size, lang: "en")
  set par(
    first-line-indent: (amount: 2em, all: true),
    leading: leading,
    spacing: leading,
    justify: false,
  )

  _display-title(title, size: title-size, font: jnu-sans)

  v(1.1cm)

  grid(
    columns: (5em, 1fr),
    align: (left + top, left + top),
    strong[Abstract],
    {
      set par(first-line-indent: 0pt)
      abstract
    },
  )

  v(1.2cm)

  grid(
    columns: (5em, 1fr),
    align: (left + top, left + top),
    strong[Keywords],
    {
      set par(first-line-indent: 0pt)
      _keywords(keywords, sep: "; ")
    },
  )
}

//  目录
#let _toc(entry-size: 14pt, title-size: 24pt) = {
  set text(font: jnu-serif, size: entry-size)
  set par(first-line-indent: 0pt, leading: 0.9em, justify: false)

  v(2.9cm)
  _display-title([目　录], size: title-size, font: jnu-sans)
  v(1.8cm)

  show outline.entry: set outline.entry(fill: repeat[·])
  show outline.entry: it => block(above: 0.42em, below: 0.42em, it)

  outline(title: none, depth: 4, indent: it => it * 1em)
}

//  正文样式
#let _body-style(
  body,
  size: 14pt,
  heading-size: 15pt,
  caption-size: 10.5pt,
  note-size: 9pt,
  code-size: 10.5pt,
  reference-size: 10.5pt,
  chapter-pagebreak: false,
  leading: jnu-leading,
) = {
  set text(font: jnu-serif, size: size, lang: "zh")
  set par(
    first-line-indent: (amount: 2em, all: true),
    leading: leading,
    spacing: leading,
    justify: true,
    justification-limits: (
      tracking: (min: -0.012em, max: 0.012em),
      spacing: (min: 75%, max: 120%),
    ),
  )

  // ---- 标题 ----
  set heading(numbering: "1.1.1.1")
  show heading: set text(
    font: jnu-serif,
    size: heading-size,
    weight: "bold",
  )
  show heading: set block(above: 1.0em, below: 0.55em)
  show heading.where(level: 1): set block(above: 0em, below: 1.4em)
  show heading.where(level: 2): set block(above: 1.4em, below: 0.6em)

  // 编号章节是否另起一页由 chapter-pagebreak 控制；
  // 结论、致谢、附录、参考文献等无编号标题始终另起一页。
  // 同时清零图、表、公式计数器，实现按章编号。
  show heading.where(level: 1): it => {
    if chapter-pagebreak or it.numbering == none {
      pagebreak(weak: true)
    }
    v(jnu-chapter-drop)
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(math.equation).update(0)
    it
  }

  // ---- 图、表 ----
  set figure(supplement: [图])
  set figure(numbering: n => numbering(
    "1-1",
    counter(heading).get().first(),
    n,
  ))
  set figure.caption(separator: [　])
  show figure.caption: set text(size: caption-size)
  show figure.caption: set par(
    first-line-indent: 0pt,
    justify: false,
    leading: 0.8em,
  )
  show figure.where(kind: table): set figure(supplement: [表])
  show figure.where(kind: table): set figure.caption(position: top)

  // ---- 公式 ----
  set math.equation(numbering: n => numbering(
    "(1-1)",
    counter(heading).get().first(),
    n,
  ))

  // ---- 列表 ----
  set list(indent: 2em, body-indent: 0.6em, spacing: 0.45em)
  set enum(indent: 2em, body-indent: 0.6em, spacing: 0.45em)

  // ---- 表格：默认无线，示例中使用三线表 ----
  set table(
    stroke: none,
    inset: (x: 8pt, y: 5pt),
    align: center + horizon,
  )

  // ---- 代码块 ----
  show raw: set text(size: code-size)
  show raw.where(block: true): set par(leading: 0.55em, justify: false)

  // ---- 脚注 ----
  show footnote.entry: set text(size: note-size)
  show footnote.entry: set par(
    first-line-indent: 0pt,
    leading: 0.6em,
    justify: false,
  )

  // ---- 引用与链接 ----
  show cite: it => super(text(font: jnu-serif, size: 0.85em, it))
  show link: set text(fill: black)

  // ---- 参考文献 ----
  show bibliography: set text(size: reference-size)
  show bibliography: set par(
    first-line-indent: 0pt,
    leading: 0.75em,
    justify: false,
  )

  body
}

/// Parameters
///
/// - `paper-type`：`"thesis"`（默认）或 `"report"`
/// - `title` / `title-en`：中英文论文题目；报告模式下 `title` 可传字符串数组以指定封面换行
/// - `short-title`：页眉中的短标题，缺省使用 `title`
/// - `course` / `class-name` / `score`：调研报告封面的课程名称、专业班级、成绩评分
///   （`course` 与 `title` 一样可传数组，用于指定封面换行）
/// - `team`：调研报告分工表，元素形如 `(name: "张三", student-id: "...", work: "资料收集")`；
///   为空时生成 4 行空白行
/// - `include-statement` / `include-abstract-en`：`auto` 时论文显示、报告隐藏，也可显式传布尔值
/// - `abstract` / `abstract-en`：摘要正文（content）
/// - `keywords` / `keywords-en`：关键词数组
/// - `bib`：`bibliography(...)` 返回的内容，或 `.bib` 路径字符串；设为 `none` 则不自动生成参考文献页。
///   `main.typ` 中传入 `bibliography("res/refs.bib", style: "gb-7714-2015-numeric", title: none)`，
/// - `sizes`：字号覆盖，例如 `(body: 12pt, heading: 14pt)`
/// - `chapter-pagebreak`：编号章节是否另起一页，默认 `false`
/// - `leading`：行距，默认 `0.83em`（约 1.5 倍）
#let jnu-thesis(
  title: "",
  title-en: "",
  short-title: none,
  paper-type: "thesis",
  course: "",
  class-name: "",
  score: "",
  team: (),
  include-statement: auto,
  include-abstract-en: auto,
  college: "",
  major: "",
  author: "",
  student-id: "",
  supervisor: "",
  date: "",
  abstract: [],
  abstract-en: [],
  keywords: (),
  keywords-en: (),
  bib: none,
  logo: "res/jnulogo.png",
  sizes: (:),
  chapter-pagebreak: false,
  leading: jnu-leading,
  body,
) = {
  assert(
    paper-type in ("thesis", "report"),
    message: "paper-type 必须是 \"thesis\" 或 \"report\"",
  )

  let is-report = paper-type == "report"
  let title-text = _as-text(title)
  let running-title = if short-title == none { title-text } else { short-title }
  let show-statement = if include-statement == auto {
    not is-report
  } else {
    include-statement
  }
  let show-abstract-en = if include-abstract-en == auto {
    not is-report
  } else {
    include-abstract-en
  }
  let sz = _resolve-sizes(sizes)

  set document(
    title: title-text,
    author: author,
    keywords: _keywords(keywords),
  )

  set page(
    paper: "a4",
    margin: jnu-margin,
    header-ascent: 18.9pt,
    numbering: none,
  )

  set text(font: jnu-serif, size: sz.body, lang: "zh")
  set par(
    first-line-indent: (amount: 2em, all: true),
    leading: leading,
    spacing: leading,
    justify: true,
  )

  // 封面：无页眉页脚、无页码。
  if is-report {
    _cover-report(
      title: title,
      course: course,
      class-name: class-name,
      supervisor: supervisor,
      score: score,
      date: date,
      logo: logo,
      title-size: sz.cover-title,
      info-size: sz.cover-info,
    )
  } else {
    _cover(
      title: title-text,
      college: college,
      major: major,
      author: author,
      student-id: student-id,
      supervisor: supervisor,
      date: date,
      logo: logo,
      title-size: sz.cover-title,
      info-size: sz.cover-info,
    )
  }

  pagebreak()

  // 调研报告：分工表紧接封面，单独一页，无页眉页码。
  if is-report {
    _division-table(team: team, title-size: sz.abstract-title, size: sz.body)
    pagebreak()
  }

  // 从诚信声明/摘要开始加页眉；前置部分不编页码。
  set page(
    header: _running-header(running-title, size: sz.header),
    footer: none,
    numbering: none,
  )
  if show-statement {
    _statement(
      title-size: sz.statement-title,
      body-size: sz.statement-body,
      leading: leading,
      report: is-report,
    )
    pagebreak()
  }

  _abstract-cn(
    title: title-text,
    abstract: abstract,
    keywords: keywords,
    size: sz.abstract-body,
    title-size: sz.abstract-title,
    leading: leading,
  )

  pagebreak()
  if show-abstract-en {
    _abstract-en(
      title: title-en,
      abstract: abstract-en,
      keywords: keywords-en,
      size: sz.abstract-body,
      title-size: sz.abstract-title,
      leading: leading,
    )
    pagebreak()
  }

  _toc(entry-size: sz.toc-entry, title-size: sz.toc-title)

  pagebreak()

  // 正文：页码从 1 开始。
  set page(
    header: _running-header(running-title, size: sz.header),
    footer: _page-footer(size: sz.footer),
    numbering: "1",
  )
  counter(page).update(1)

  // `bib` 可以是路径（模板与库文件在同一项目时可用），也可以是
  // `bibliography(...)` 返回的内容。包用户应传入后者，因为字符串路径
  // 会相对 lib.typ 所在的包目录解析。
  let bib-content = if bib == none {
    none
  } else if type(bib) == str {
    bibliography(bib, style: "gb-7714-2015-numeric", title: none)
  } else {
    bib
  }

  _body-style(
    {
      body
      // 参考文献放在最后（与 jnuthesis.pdf 的顺序一致）。
      if bib-content != none {
        heading(numbering: none, outlined: true)[参考文献]
        bib-content
      }
    },
    size: sz.body,
    heading-size: sz.heading,
    caption-size: sz.caption,
    note-size: sz.note,
    code-size: sz.code,
    reference-size: sz.reference,
    chapter-pagebreak: chapter-pagebreak,
    leading: leading,
  )
}
