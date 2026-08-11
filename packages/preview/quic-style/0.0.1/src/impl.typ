#let make-venue(doc-type) = {
  let top_text = ""
  let bottom_text = ""
  let fill_color = luma(140) // Default color

  if doc-type == "PROGRESS_REPORT" {
    top_text = "PROGRESS"
    bottom_text = "REPORT"
    fill_color = rgb("#ffa500") // 例: オレンジ系の色
  } else if doc-type == "PAPER" {
    top_text = "PAPER"
    bottom_text = "" // PAPER の場合は下のテキストなし
    fill_color = rgb("#4169e1") // 例: 青系の色
  } else if doc-type == "NOTE" {
    top_text = "NOTE"
    bottom_text = "" // NOTE の場合は下のテキストなし
    fill_color = rgb("#3cb371") // 例: 緑系の色
  } else if doc-type == "LOG" {
    top_text = "LOG"
    bottom_text = "" // LOG の場合は下のテキストなし
    fill_color = luma(140)
  }
  // 他のタイプが必要な場合はここに追加

  move(dy: -1.9cm, {
    box(rect(fill: fill_color, inset: 10pt, height: 2.5cm)[
      #set text(font: "Zen Old Mincho", fill: white, weight: 700, size: 20pt)
      #align(bottom)[#top_text] // 変数を使用
    ])
    set text(22pt, font: "Zen Kaku Gothic New")
    // 下のテキストが存在する場合のみ表示
    if bottom_text != "" {
      box(pad(left: 10pt, bottom: 10pt, [#bottom_text])) // 変数を使用
    }
  })
}

#let make-title(
  title,
  authors,
  date,
  abstract,
  keywords,
) = {
  // タイトルでは, 字下げを打ち消し
  set par(justify: true, leading: 1.1em, spacing: 1.9em, first-line-indent: (
    all: false,
    amount: 0pt,
  ))

  set par(spacing: 1em)
  set text(font: "Zen Kaku Gothic New")

  par(justify: false, text(24pt, fill: rgb("004b71"), title, weight: "bold"))

  text(12pt, authors.enumerate().map(((i, author)) => box[#author.name #super[#(i + 1)]]).join(", "))
  parbreak()

  for (i, author) in authors.enumerate() [
    #set text(8pt)
    #super[#(i + 1)]
    #author.institution
    #link("mailto:" + author.mail) \
  ]

  if date != none {
    v(8pt)
    set text(10pt)
    align(right)[#date]
    v(8pt)
  } else {
    v(8pt)
  }
  set text(10pt)
  set par(justify: true)

  [
    #heading(outlined: false, bookmarked: false)[Abstract]
    #text(font: "Zen Old Mincho", abstract)
    #v(3pt)
    *Keywords:* #keywords.join(text(font: "Zen Old Mincho", "; "))
  ]
  v(18pt)
}

#let template(
  title: [],
  authors: (),
  date: [],
  doi: "",
  keywords: (),
  abstract: [],
  doc-type: "NOTE",
  doc_type: none,
  make-venue: make-venue,
  make-title: make-title,
  body,
) = {
  // doc_type が指定されている場合は doc-type より優先
  let actual-doc-type = if doc_type != none { doc_type } else { doc-type }
  set page(
    paper: "a4",
    margin: (top: 1.9cm, bottom: 1in, x: 1.6cm),
    columns: 2,
    numbering: "1", // ページ番号を追加
  )

  // 日本語テキストの可読性向上のための設定
  set par(justify: true, leading: 1.1em, spacing: 1.9em, first-line-indent: (
    all: true,
    amount: 1em,
  ))
  set text(10pt, lang: "ja", font: "Zen Old Mincho")
  set list(indent: 8pt)
  // show link: set text(underline: false)
  show heading: set text(size: 11pt)
  show heading.where(level: 1): set text(font: "Zen Kaku Gothic New", fill: rgb("004b71"), size: 12pt)
  show heading.where(level: 2): set text(font: "Zen Kaku Gothic New", fill: rgb("004b71"), size: 11pt)
  show heading.where(level: 3): set text(font: "Zen Kaku Gothic New", fill: rgb("004b71"), size: 10pt)
  show heading: set block(above: 16pt, below: 8pt)
  show heading.where(level: 1): set block(below: 12pt)
  show heading.where(level: 2): set block(below: 12pt)
  show heading.where(level: 3): set block(below: 12pt)

  place(make-venue(actual-doc-type), top, scope: "parent", float: true)
  place(
    make-title(title, authors, date, abstract, keywords),
    top,
    scope: "parent",
    float: true,
  )


  show figure: align.with(center)
  show figure: set text(8pt)
  show figure.caption: pad.with(x: 10%)

  //表のときにはキャプションを上へ
  show figure.where(kind: table): set figure.caption(position: top)

  // show: columns.with(2)
  body
}
