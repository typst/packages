// 
// 经典中文书籍模版
// 

#import "@preview/outrageous:0.4.0"
#import "@preview/numbly:0.1.0": numbly
#import "@preview/hydra:0.6.1": hydra
#import "@preview/i-figured:0.2.4"
#import "@preview/ornamentalyst:0.1.0": ornament

// 部分参考了 songting-book:0.0.5。

#let _heading-text(body) = {
  if body.func() == text {
    return body.text
  }
  if body.has("children") {
    let parts = body.children
      .map(_heading-text)
      .filter(it => it != none and it != "")
    if parts.len() > 0 {
      return parts.join("")
    }
  }
  return none
}

// 字体配置
#let _fonts = (
  song:   ( (name: "Tinos", covers: "latin-in-cjk"), "Source Han Serif SC"),
  hei:    ( (name: "Ronzino", covers: "latin-in-cjk"), "Source Han Sans SC"),
  fang:   ( (name: "Tinos", covers: "latin-in-cjk"), "Zhuque Fangsong (technical preview)"),
)

// 深度合并

#let deep-merge(a, b) = {
  if type(a) != "dictionary" { return b }
  if type(b) != "dictionary" { return b }
  let result = (:)
  for (k, v) in a {
    result.insert(k, v)
  }
  for (k, v) in b {
    if k in result and type(result.at(k)) == "dictionary" and type(v) == "dictionary" {
      result.insert(k, deep-merge(result.at(k), v))
    } else {
      result.insert(k, v)
    }
  }

  result
}

// A4
#let _base-a4 = (
  paper: "a4",
  margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 3cm),
  size: 10pt,
  display-page-numbers: true,
  use-odd-pagebreak: false,
  lang: "zh",
  force-zh-puct: true,
  hide-list-marker: true,
  enum_num: numbly(
    "{1:一}、",
    "{2:①}、",
    "{3:1}、",
    "{4:I}、",
    "{5:1}、",
  ),
  headingone-adjust-char: "　　",
  outline_depth: 3,
  dedication-size-offset: 6pt,

  // 排版
  
  typography: (
    main-font: _fonts.song,
    title-font: (_fonts.hei),
    fangsong-font: (_fonts.fang),
    header-font: _fonts.fang,
    tracking: 0.08em,
    line-spacing: 0.7em,
    par-spacing: 1em,
    indent: 2em,
    justify: true,
    list-spacing: 1em,
    quote-inset: 2em,
    header-font-size-factor: 0.875,
    display-header: true,
    header-suffix: none,
    header-rule-color: black,
    header-rule-thickness: 0.5pt,
    header-rule-length: 100%,
  ),

  // 标题
  heading: (
    font: (_fonts.hei, _fonts.hei, _fonts.hei, _fonts.hei, _fonts.hei, _fonts.hei),
    size: (16pt, 14pt, 10pt, 10pt, 10pt, 10pt),
    weight: ("bold", "medium", "medium", "regular", "regular", "regular"),
    align: (center, center, left, left, left, left),
    above: (2em, 2em, 2em, 2em, 2em, 2em),
    below: (2em, 2em, 2em, 2em, 2em, 2em),
    pagebreak: (true, false, false, false, false),
    header-numbly: ("第{1:一}章 ", "第{2:一}节 ", ""),
  ),

  // 目录
  toc: (
    title-font: _fonts.song,
    title-size: 14pt,
    title-weight: "bold",
    title-align: center,
    level1-font: _fonts.hei,
    other-font: _fonts.song,
    entry-size: (12pt, 10pt, 10pt),
    vspace: (2em, 1em),
  ),

  // 封面
  cover: (
    title-size: 36pt,
    subtitle-size: 18pt,
    author-size: 12pt,
    publisher-size: 12pt,
    date-size: 12pt,
    edition-size: 14pt,
    ornament-offset: -1.5cm,
    ornament-size: 2cm,
    title-gap: 1.5em,
    subtitle-gap: 4em,
    author-gap: 20em,
    publisher-gap: 1em,
    date-gap: 1em,
    cover-background: rgb("#F4E8D1"),
    cover-foreground: rgb("#2C1810"),
    ornament-collection: "pgfhan",
    ornament-index: 3,
  ),

  // 图表
  caption: (
    separator: "  ",
    font: _fonts.fang,
    numbering: "1 - 1",
    size: 1em,
  ),

  // 脚注
  footnote: (
    font: _fonts.fang,
    size: 1em,
    entry_gap: 0.6em,
    numbering: "①",
  ),
)

// A5

#let _base-a5 = (.._base-a4, paper: "a5", margin: (top: 2.5cm, bottom: 2.5cm, left: 2cm, right: 2cm))

// 暴露给用户

#let concise-history-a4 = _base-a4
#let concise-history-a5 = _base-a5



#let _at(arr, idx) = arr.at(calc.min(idx, arr.len()) - 1)


#let _compute-cfg(override) = {
  let paper-type = override.at("paper", default: "a4")
  let base = if paper-type == "a5" { _base-a5 } else { _base-a4 }
  deep-merge(base, override)
}


#let concise-history-book(
  title: "",
  subtitle: none,
  author: "",
  publisher: none,
  date: datetime.today(),
  edition: none,
  cover: auto,
  dedication: none,
  toc: true,
  front-matter-headings: ("前言", "目录", "序言", "跋", "自序", "内容简介", "内容提要", "本册引言", "电子化排版说明"),// “电子化排版说明”是根据我个人的排版需要加的。
  back-matter-headings: ("附录", "后记", "参考文献", "索引", "本书引用书目"),
  cfg: (:),
  body,
) = {
  let cfg = _compute-cfg(cfg)
  let h = cfg.heading
  let cover-cfg = cfg.cover
  let typo = cfg.typography
  let toc-cfg = cfg.toc

  set document(title: title, author: author, date: date)
  set enum(full: true, numbering: cfg.enum_num, number-align: start)
  set page(paper: cfg.paper, margin: cfg.margin)

  set text(
    font: typo.main-font,
    size: cfg.size,
    lang: cfg.lang,
    tracking: typo.tracking,
  )

  show strong: set text(font: _fonts.hei, weight: "light")
  show "——": set text(font: "Source Han Serif SC")

  let _punct-map = (
    ",": "，", ";": "；", ":": "：",
    "?": "？", "!": "！", "(": "（", ")": "）",
  )
  show "……": set text(tracking: 0em)
  show regex("[.,;:?!()\[\]]"): it => {
    if cfg.force-zh-puct {
      _punct-map.at(it.text, default: it.text)
    } else { it }
  }

  set par(
    spacing: typo.par-spacing,
    leading: typo.line-spacing,
    first-line-indent: (amount: typo.indent, all: true),
    justify: typo.justify,
  )

  if cover == auto {
  page(header: none, footer: none, numbering: none, fill: cover-cfg.cover-background)[
    #set text(fill: cover-cfg.cover-foreground)
    // 实现封面四角花纹
    #let orn-sz = cover-cfg.ornament-size
    #let orn-off = cover-cfg.ornament-offset
    #let orn-collection = cover-cfg.ornament-collection
    #let orn-index = cover-cfg.ornament-index
    #place(top + left,   dx: +orn-off, dy: +orn-off, ornament(orn-index, collection: orn-collection, height: orn-sz))
    #place(top + right,  dx: -orn-off, dy: +orn-off, ornament(orn-index, collection: orn-collection, height: orn-sz, symmetry: "v"))
    #place(bottom + left, dx: +orn-off, dy: -orn-off, ornament(orn-index, collection: orn-collection, height: orn-sz, symmetry: "h"))
    #place(bottom + right,dx: -orn-off, dy: -orn-off, rotate(180deg, ornament(orn-index, collection: orn-collection, height: orn-sz))) // ornamentalyst 应该有缺陷。我用 symmetry: "c" 实现不了中心对称效果。
    #align(center + horizon)[
      #text(size: cover-cfg.title-size, font: typo.fangsong-font, weight: "bold")[#title]
      #if subtitle != none {
        v(cover-cfg.title-gap)
        text(size: cover-cfg.subtitle-size, font: typo.fangsong-font)[#subtitle]
      }
      #v(cover-cfg.subtitle-gap)
      #let author-text = if type(author) == "array" {
        author.join("、")
      } else { author }
      #text(size: cover-cfg.author-size, font: typo.title-font)[#author-text]
      #if publisher != none {
        v(cover-cfg.author-gap)
        text(size: cover-cfg.publisher-size, font: typo.title-font)[#publisher]
      }
      #if date != none {
        v(cover-cfg.publisher-gap)
        text(size: cover-cfg.date-size)[#date.display("[year]年[month]月")]
      }
      #if edition != none {
        v(cover-cfg.date-gap)
        text(size: cover-cfg.edition-size)[第 #edition 版]
      }
    ]
  ]
} else if type(cover) == content {
    cover
  }

  if dedication != none {
    page(header: none, footer: none, numbering: none)[
      #align(center + horizon)[
        #text(size: cfg.size + cfg.dedication-size-offset)[#dedication]
      ]
    ]
  }

  show list.item: it => {
    set par(leading: typo.list-spacing, spacing: typo.list-spacing, first-line-indent: (amount: typo.indent, all: true))
    if cfg.hide-list-marker { it.body } else { it }
  }
  set list(marker: [], indent: 0em, body-indent: 0em, spacing: typo.list-spacing) if cfg.hide-list-marker

  counter(page).update(1)
  set page(numbering: "i") if cfg.display-page-numbers

  show heading: it => {
    let level = it.level
    set block(above: _at(h.above, level), below: _at(h.below, level))
    if _at(h.pagebreak, level) {
      pagebreak(weak: true, to: if cfg.use-odd-pagebreak { "odd" })
    }
    let plain-title = _heading-text(it.body)
    let content = {
      set text(
        font: _at(h.font, level),
        size: _at(h.size, level),
        weight: _at(h.weight, level),
      )
      // 对特定两个字的“前言/附录”类标题插入调整字符
      if (
        cfg.headingone-adjust-char != none
        and level == 1
        and (front-matter-headings.contains(plain-title) or back-matter-headings.contains(plain-title))
      ) {
        if plain-title != none and plain-title.codepoints().len() == 2 {
          let chars = plain-title.codepoints()
          plain-title = chars.at(0) + cfg.headingone-adjust-char + chars.at(1)
        }
        plain-title
      } else { it }
    }
    let align-val = _at(h.align, level)
    let result = if align-val != none { align(align-val, content) } else { content }
    if level == 3 { box(result) } else { result }
  }

  show quote: it => {
    block(
      inset: typo.quote-inset,
      set text(font: typo.fangsong-font, size: cfg.size),
      if it.quotes == true { quotes(it.body) } else { it.body },
      if it.attribution != none {
        align(end, [--- #it.attribution])
      }
    )
  }

  show footnote.entry: set text(font: cfg.footnote.font, size: cfg.footnote.size)
  set footnote.entry(gap: cfg.footnote.entry_gap)
  set footnote(numbering: cfg.footnote.numbering)

  let parts = body.children
  let sections = (front: (), main: (), back: ())
  let current = "front"
  for child in parts {
    if child.func() == heading and child.depth == 1 {
      let text = _heading-text(child.body)
      if text != none {
        if front-matter-headings.contains(text) {
          current = "front"
        } else if back-matter-headings.contains(text) {
          current = "back"
        } else {
          current = "main"
        }
      } else {
        current = "main"
      }
    }
    sections.at(current).push(child)
  }

  for item in sections.front { item }

  if toc {
    pagebreak(weak: true)
    set par(leading: 0.5em)
    set text(size: _at(toc-cfg.entry-size, 3))
    set outline(indent: level => (0pt, 18pt, 28pt).slice(0, calc.min(level + 1, 3)).sum())
    show outline.entry: outrageous.show-entry.with(
      ..outrageous.presets.typst,
      font: (toc-cfg.level1-font, toc-cfg.other-font),
      vspace: toc-cfg.vspace,
      fill: (align(right, repeat(gap: 0.15em)[.]), align(right, repeat(gap: 0.15em)[.])),
      body-transform: (level, prefix, body) => {
        let idx = calc.min(level, 3) - 1
        text(size: toc-cfg.entry-size.at(idx), body)
      },
      prefix-transform: (level, prefix) => {
        if prefix == none { return none }
        let idx = calc.min(level, 3) - 1
        text(size: toc-cfg.entry-size.at(idx), prefix.text.replace("§", ""))
      },
    )
    outline(title: "目录", depth: cfg.outline_depth)
  }


  pagebreak(weak: true, to: if cfg.use-odd-pagebreak { "odd" })
  counter(page).update(1)
  set page(numbering: "1") if cfg.display-page-numbers
  set heading(numbering: numbly(..h.header-numbly))

// 实现了奇书页页眉显示章名、偶数页显示节名的效果。

  set page(header: context {
    counter(footnote).update(0)
    let page-num = counter(page).get().first()
    let heading-text = if calc.rem(page-num, 2) == 1 {
      let h1 = hydra(1)
      if h1 == "" { hydra(1, fallback: "章") } else { h1 }
      } else {
      let h2 = hydra(2)
      if h2 == "" { hydra(2, fallback: "节") } else { h2 }
      }
    grid(
      rows: (1fr, auto),
      gutter: 10pt,
      align(center)[
        #text(font: typo.header-font, size: cfg.size * typo.header-font-size-factor)[
          #heading-text #if typo.header-suffix != none { typo.header-suffix }
        ]
      ],
      line(length: typo.header-rule-length,
     stroke: (paint: typo.header-rule-color, thickness: typo.header-rule-thickness)),
    )
  }) if typo.display-header

  // 图表题注
  set figure.caption(separator: cfg.caption.separator)
  show heading: i-figured.reset-counters
  show figure: it => i-figured.show-figure(it, numbering: "1 - 1")
  show figure.caption: set text(font: cfg.caption.font, size: cfg.caption.size)

  // 输出主体
  for item in sections.main { item }

  // 附录，应取消编号
  set heading(numbering: none)
  for item in sections.back { item }
}

// 我找不到在Typst中实现着重号效果的包。自己写了个凑合用。
// 在本模板使用的行间距下效果良好。

#let 着重号(body) = {
  show regex("\p{sc=Han}"): it => {
    box(
      grid(
        columns: 1,
        rows: (auto, -0.05em),
        row-gutter: 0.04em,
        align(center, it),
        align(center, text("・", size: 0.8em, weight: "extrabold")),
      )
    )
  }
  body
}