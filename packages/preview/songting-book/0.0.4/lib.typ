#import "@preview/outrageous:0.4.0"
#import "@preview/numbly:0.1.0": numbly
#import "@preview/hydra:0.6.1": hydra
#import "@preview/i-figured:0.2.4"
#import "@preview/modern-nju-thesis:0.4.0": 字号



// a variant of  modern-nju-thesis fonts(prefer SimSun as main font)
#let 字体 = (
  // 宋体，属于「有衬线字体」，一般可以等同于英文中的 Serif Font
  // 这一行分别是「新罗马体（有衬线英文字体）」、「宋体（Windows）」、「思源宋体（简体）」、「思源宋体」、「宋体（MacOS）」
  宋体: (
    (name: "Times New Roman", covers: "latin-in-cjk"),
    "SimSun",
    "Source Han Serif SC",
    "Source Han Serif",
    "Noto Serif CJK SC",
    "Songti SC",
    "STSongti",
  ),
  // 黑体，属于「无衬线字体」，一般可以等同于英文中的 Sans Serif Font
  // 这一行分别是「Arial（无衬线英文字体）」、「思源黑体（简体）」、「思源黑体」、「黑体（Windows）」、「黑体（MacOS）」
  // 优先选用字重配置更多的思源黑体
  黑体: (
    (name: "Arial", covers: "latin-in-cjk"),
    "Source Han Sans SC",
    "Source Han Sans",
    "Noto Sans CJK SC",
    "SimHei",
    "Heiti SC",
    "STHeiti",
  ),
  // 楷体
  楷体: ((name: "Times New Roman", covers: "latin-in-cjk"), "KaiTi", "Kaiti SC", "STKaiti", "FZKai-Z03S"),
  // 仿宋
  仿宋: ((name: "Times New Roman", covers: "latin-in-cjk"), "FangSong", "FangSong SC", "STFangSong", "FZFangSong-Z02S"),
  // 等宽字体，用于代码块环境，一般可以等同于英文中的 Monospaced Font
  // 这一行分别是「Courier New（Windows 等宽英文字体）」、「思源等宽黑体（简体）」、「思源等宽黑体」、「黑体（Windows）」、「黑体（MacOS）」
  等宽: (
    (name: "Courier New", covers: "latin-in-cjk"),
    (name: "Menlo", covers: "latin-in-cjk"),
    (name: "IBM Plex Mono", covers: "latin-in-cjk"),
    "Source Han Sans HW SC",
    "Source Han Sans HW",
    "Noto Sans Mono CJK SC",
    "SimHei",
    "Heiti SC",
    "STHeiti",
  ),
)

// Paper-specific configurations
#let songting-a4 = (
  paper: "a4",
  margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 3cm),
  size: 12pt,
  display-page-numbers: true,
  use-odd-pagebreak: false,
  cover-title-size: 36pt,
  cover-subtitle-size: 24pt,
  cover-author-size: 18pt,
  cover-publisher-size: 16pt,
  cover-date-size: 14pt,
  cover-edition-size: 14pt,
  dedication-size-offset: 2pt,
  toc-title-font: 字体.宋体,
  toc-title-size: 16pt,
  toc-title-weight: "bold",
  toc-title-align: center,
  toc-level1-font: 字体.黑体,
  toc-other-font: 字体.宋体,
  toc-entry-size: (14pt, 12pt, 12pt),
  toc-vspace: (2em, 1em),
  heading: (
    //font: ("SimHei", "SimHei", "SimHei", "SimHei", "SimHei"),
    font: (字体.黑体, 字体.黑体, 字体.黑体, 字体.黑体, 字体.黑体, 字体.黑体),
    size: (22pt, 18pt, 16pt, 14pt, 14pt, 14pt),
    weight: ("bold", "medium", "medium", "regular", "regular", "regular"),
    align: (center, center, left, left, left, left),
    above: (2em, 2em, 2em, 2em, 2em, 2em),
    below: (2em, 2em, 2em, 2em, 2em, 2em),
    pagebreak: (true, false, false, false, false),
    header-numbly: ("第{1:一}章 ", "第{2:一}节 ", "{3:一} ", "（{4:一}）", "{5:1}", "（{6:1}）"),
  ),
  caption: (
    separator: "  ",
    font: 字体.楷体,
    numbering: "1 - 1",
    size: 1em,
  ),
  footnote: (font: 字体.楷体, size: 0.8em, entry_gap: 1em, numbering: "[1]"),
  // Base configuration properties
  main-font: 字体.宋体,
  title-font: (字体.黑体),
  kai-font: (字体.楷体),
  lang: "zh",
  header-suffix: none,
  tracking: 0.1em,
  line-spacing: 1.5em,
  par-spacing: 2em,
  indent: 2em,
  justify: true,
  header-rule: true,
  display-header: true,
  header-spacing: 0.25em,
  header-font-size-factor: 0.875,
  header-font: 字体.楷体,
  outline_depth: 3,
  headingone-adjust-char: "　　",
  enum_num: numbly(
    "{1:一}、",
    "{2:①}、",
    "{3:1}、",
    "{4:I}、",
    "{5:1}、",
  ),
  force-zh-puct: true,
  hide-list-marker: true,
  list-spacing: 1em
)

#let songting-a4-legacy = (
  ..songting-a4,
  display-header: false,
  display-page-numbers: false,
  heading : songting-a4.heading + (
    header-numbly: ("第{1:一}章 ", "第{2:一}节 ", "{3:I} ", "{4:一}", "({5:一})", "（{6:1}）"),
  ),
)

#let songting-a5 = (
  ..songting-a4,
  paper: "a5",
  margin: (top: 2.5cm, bottom: 2.5cm, left: 2cm, right: 2cm),
)

#let songting-b6 = (
  ..songting-a4,
  paper: "iso-b6",
  margin: (top: 1cm, bottom: 1cm, left: 0.6cm, right: 0.6cm),
  size: 字号.小二 + 2pt,
  display-page-numbers: false,
  use-odd-pagebreak: false,
  display-header: false,
  cover-title-size: 30pt,
  cover-subtitle-size: 22pt,
  cover-author-size: 20pt,
  toc-vspace: (1em, 0.5em),
  cover-publisher-size: 20pt,
  cover-date-size: 10pt,
  cover-edition-size: 10pt,
  dedication-size-offset: 1pt,
  toc-entry-size: (字号.小四 + 2pt, 字号.小四 + 1pt, 字号.小四),
  line-spacing: 1.5em,
  par-spacing: 2em,

  heading: songting-a4.heading
    + (
      size: (1em + 4pt, 1em + 1pt, 1em + 1pt, 1em + 1pt, 1em, 1em),
      weight: ("bold", "bold", "bold", "regular", "regular", "regular"),
      pagebreak: (true, false, false, false, false),
    ),
)

// Helper function to compute final configuration
#let compute-config(cfg-override: (:)) = {
  // Available paper configurations
  let songting-paper-configs = (
    a4: songting-a4,
    a5: songting-a5,
    b6: songting-b6,
  )

  // Default to a4 if no paper type specified
  let paper-type = cfg-override.at("paper", default: "a4")

  // Get base configuration for the specified paper type
  let base-cfg = songting-paper-configs.at(paper-type, default: songting-a4)

  // Merge with user overrides
  let final-cfg = base-cfg + cfg-override

  return (final-cfg, final-cfg.heading)
}

// Main book template function
#let songting-book(
  title: "",
  subtitle: none,
  author: "",
  publisher: none,
  date: datetime.today(),
  edition: none,
  cover: auto,
  dedication: none,
  toc: true,
  front-matter-headings: ("前言", "目录", "序言", "跋", "自序", "内容简介"),
  back-matter-headings: ("附录", "后记", "参考文献", "索引", "本书引用书目"),
  cfg: (:),
  body,
) = {
  // Compute final configuration
  let (cfg, default-heading) = compute-config(cfg-override: cfg)
  let heading-cfg = default-heading

  // Handle auto heading font
  if heading-cfg.font == auto {
    heading-cfg.font = (cfg.title-font, cfg.title-font, cfg.title-font, cfg.title-font, cfg.title-font)
  }

  // Helper function for safely accessing arrays
  let array-at(arr, pos) = {
    if arr == none { return none }
    arr.at(calc.min(pos - 1, arr.len() - 1))
  }

  // Document setup
  set document(title: title, author: author, date: date)

  // Enumeration settings
  set enum(
    full: true,
    numbering: cfg.enum_num,
    number-align: start,
  )

  // Page settings
  set page(
    paper: cfg.paper,
    margin: cfg.margin,
  )

  // Text settings
  set text(
    font: cfg.main-font,
    size: cfg.size,
    lang: cfg.lang,
    tracking: cfg.tracking,
  )


  show "——": {
    set text(font: "Source Han Serif SC")
    "——"
  }

  // 英文 → 中文标点转换函数（支持智能引号匹配）
  let trans_puct_cn(ch) = {
    // 基础标点映射
    let base-replacements = (
      //(".", "。"),  // 句号
      ",": "，", // 逗号
      ";": "；", // 分号
      ":": "：", // 冒号
      "?": "？", // 问号
      "!": "！", // 感叹号
      "(": "（", // 左圆括号
      ")": "）", // 右圆括号
      //"[": "【", // 左方括号
      //"]": "】", // 右方括号
    )

    base-replacements.at(ch.text, default: ch.text)
  }

  show "……": set text(tracking: 0em)

  show regex("[.,;:?!()\[\]]"): it => if cfg.force-zh-puct {
    trans_puct_cn(it)
  } else {
    it
  }

  // Paragraph settings
  set par(
    spacing: cfg.par-spacing,
    leading: cfg.line-spacing,
    first-line-indent: (amount: cfg.indent, all: true),
    justify: cfg.justify,
  )

  // Cover page
  if cover == auto {
    page(
      header: none,
      footer: none,
      numbering: none,
    )[
      #align(center + horizon)[
        #text(size: cfg.cover-title-size, font: cfg.title-font, weight: "bold")[#title]

        #if subtitle != none {
          v(1.5em)
          text(size: cfg.cover-subtitle-size, font: cfg.title-font)[#subtitle]
        }

        #v(3em)

        #text(size: cfg.cover-author-size, font: cfg.title-font)[#author]

        #if publisher != none {
          v(3em)
          text(size: cfg.cover-publisher-size, font: cfg.title-font)[#publisher]
        }
        #if date != none {
          v(1em)
          text(size: cfg.cover-date-size)[#date.display("[year]年[month]月[day]日")]
        }

        #if edition != none {
          v(1em)
          text(size: cfg.cover-edition-size)[第#edition版]
        }
      ]
    ]
  } else if type(cover) == content {
    cover
  }

  // Dedication page
  if dedication != none {
    page(
      header: none,
      footer: none,
      numbering: none,
    )[
      #align(center + horizon)[
        #text(size: cfg.size + cfg.dedication-size-offset)[#dedication]
      ]
    ]
  }

  set list(marker: [], indent: 2em, body-indent: 0em, spacing: cfg.list-spacing) if cfg.hide-list-marker

  // Start front matter with roman numerals (if page numbers are displayed)
  counter(page).update(1)
  set page(numbering: "i") if cfg.display-page-numbers

  // Define the heading structure and formatting
  show heading: it => {
    let level = it.level

    // Apply appropriate spacing
    set block(above: array-at(heading-cfg.above, level), below: array-at(heading-cfg.below, level))

    // Check if we need a pagebreak for this heading level
    if array-at(heading-cfg.pagebreak, level) {
      pagebreak(weak: true, to: if cfg.use-odd-pagebreak { "odd" })
    }

    // Apply text formatting for this heading level
    let heading-content = {
      set text(font: array-at(heading-cfg.font, level), size: array-at(heading-cfg.size, level), weight: array-at(
        heading-cfg.weight,
        level,
      ))
      // Special handling for front matter headings
      if (
        cfg.headingone-adjust-char != none
          and level == 1
          and (front-matter-headings.contains(it.body.text) or back-matter-headings.contains(it.body.text))
      ) {
        // Handle two-character headings with extra spacing
        let text = it.body.text
        if text.codepoints().len() == 2 {
          let chars = text.codepoints()
          text = chars.at(0) + cfg.headingone-adjust-char + chars.at(1)
        }
        text
      } else {
        it
      }
    }

    // Apply alignment for this heading level
    let align-value = array-at(heading-cfg.align, level)
    if align-value != none {
      align(align-value, heading-content)
    } else {
      heading-content
    }
  }

  // Style for quotes (use KaiTi font)
  show quote: it => {
    let content = it.body
    let is-poem = it.attribution == [poem]
    if is-poem {
      set par(justify: true)
      align(center, text(font: cfg.kai-font)[#content])
    } else {
      text(font: cfg.kai-font)["#content"]
    }
  }

  // Process body into content sections
  let content-parts = body.children
  let content-map = (
    "front": (),
    "main": (),
    "back": (),
  )

  let current-section = "front" // Start assuming front matter

  for child in content-parts {
    if child.func() == heading and child.depth == 1 {
      if front-matter-headings.contains(child.body.text) {
        current-section = "front"
      } else if back-matter-headings.contains(child.body.text) {
        current-section = "back"
      } else {
        current-section = "main"
      }
    }

    content-map.at(current-section).push(child)
  }

  show footnote.entry: set text(font: cfg.footnote.font, size: cfg.footnote.size)
  set footnote.entry(gap: cfg.footnote.entry_gap)
  set footnote(numbering: cfg.footnote.numbering)
  // Output front matter
  for item in content-map.at("front") {
    item
  }

  // Table of contents
  if toc {
    pagebreak(weak: true)
    set par(leading: 0.5em)
    set text(size: cfg.toc-entry-size.last())

    // Define outline styles with appropriate spacing for Chinese
    set outline(indent: level => (0pt, 18pt, 28pt).slice(0, calc.min(level + 1, 3)).sum())
    show outline.entry: outrageous.show-entry.with(
      ..outrageous.presets.typst,
      font: (字体.黑体, 字体.宋体),
      vspace: cfg.toc-vspace,
      fill: (align(right, repeat(gap: 0.15em)[.]), align(right, repeat(gap: 0.15em)[.])),
      body-transform: (level, prefix, body) => {
        if level == 1 {
          text(size: cfg.toc-entry-size.at(0), body)
        } else if level == 2 {
          text(size: cfg.toc-entry-size.at(1), body)
        } else {
          text(size: cfg.toc-entry-size.at(2), body)
        }
      },
      prefix-transform: (level, prefix) => {
        if prefix == none {
          return none
        }
        if level == 1 {
          text(size: cfg.toc-entry-size.at(0), prefix)
        } else if level == 2 {
          text(size: cfg.toc-entry-size.at(1), prefix)
        } else {
          text(size: cfg.toc-entry-size.at(2), prefix.text.replace("§", ""))
        }
      },
    )

    outline(
      title: "目录",
      depth: cfg.outline_depth,
    )
  }

  // Start main content with Arabic numerals (if page numbers are displayed)
  pagebreak(weak: true, to: if cfg.use-odd-pagebreak { "odd" })

  counter(page).update(1)
  set page(numbering: "1") if cfg.display-page-numbers

  // Set up heading numbering for main content
  set heading(numbering: numbly(
    ..cfg.heading.header-numbly,
  ))

  // Header for main content pages
  set page(header: context {
    grid(
      rows: (1fr, auto),
      gutter: 20pt,
      // Space between rows
      align(center)[#text(font: cfg.kai-font, size: cfg.size * cfg.header-font-size-factor)[#hydra(1) #if (
            cfg.header-suffix != none
          ) { cfg.header-suffix } else { "" }]],
      line(length: 100%),
    )
  }) if cfg.display-header
  // caption
  set figure.caption(separator: cfg.caption.separator)
  show heading: i-figured.reset-counters
  show figure: it => {
    i-figured.show-figure(it, numbering: "1 - 1")
  }
  show figure.caption: set text(font: cfg.caption.font, size: cfg.caption.size)

  // Output main content
  for item in content-map.at("main") {
    item
  }

  set heading(numbering: none)

  // Output back matter
  for item in content-map.at("back") {
    item
  }
}
