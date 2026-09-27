// 澄思 · Quiet Mathematics
// No package imports. All visual elements are native Typst.
#import "themes.typ": themes

#let defaults = (
  theme: "teal",
  title: "数学笔记",
  subtitle: "Mathematical Notes",
  author: "你的名字",
  institution: "",
  date: "2026 · 秋",
  edition: "VOL. 01",
  description: [定义 · 直觉 · 证明],
  lang: "zh", // "zh", "en", "bilingual"
  cover: true,
  toc: true,
  toc-depth: 2,
  toc-title: auto,
  chapter-break: true,
  heading-numbering: "1.1",
  // 附录章自成一套编号：默认 A、B、C，小节为 A.1。
  appendix-numbering: "A.1",
  equation-numbering: "(1)",
  theorem-numbering: "1",
  example-numbering: "1",
  paper: "a4",
  margin: (top: 23mm, bottom: 23mm, left: 25mm, right: 23mm),
  font-size: 10.5pt,
  leading: 0.8em,
  paragraph-spacing: 1.2em,
  heading-before: 2em,
  heading-after: 1.2em,
  chapter-label-size: 11pt,
  chapter-title-size: 23pt,
  section-title-size: 13pt,
  subsection-title-size: 11pt,
  // Latin first: Chinese glyphs are selected from the next family.
  font-latin: "Libertinus Serif",
  font-cjk: "Noto Serif SC",
  font-heading: "Noto Sans SC",
  font-math: "New Computer Modern Math",
  font-code: "DejaVu Sans Mono",
  accent: rgb("22645E"),
  ink: rgb("242F32"),
  muted: rgb("6C787B"),
  tint: rgb("F1F6F4"),
  rule: rgb("D5E1DD"),
  cover-paper: rgb("F6F5F0"),
  running-title: auto,
  headers: true,
  page-numbers: true,
  epigraph-width: 72%,
  epigraph-size: 9.5pt,
  epigraph-align: right,
  epigraph-text-align: auto,
  epigraph-color: rgb("505D60"),
  chapter-after: 4mm,
  epigraph-after: 8mm,
  math-scale: 98%,
  equation-spacing: 0.95em,
  environment-title-gap: 3pt,
  // 图片与表格的题注：字号，以及 auto 跟随 muted 的颜色。
  figure-caption-size: 9pt,
  figure-caption-color: auto,
  bibliography-style: "ieee",
  bibliography-title: auto,
  bibliography-new-page: true,
  bibliography-size: 9.5pt,
  bibliography-spacing: 1.1em,
  link-color: auto,
  link-underline: true,
  citation-color: auto,
  code-size: 9pt,
  // 行内代码字号：1em 表示与所在位置的正文同号，可改为 0.9em 等相对值或 9pt 等绝对值。
  code-inline-size: 1em,
  code-leading: 0.55em,
  code-fill: rgb("F4F6F5"),
  code-header: true,
  code-line-numbers: false,
  code-tab-size: 4,
  code-theme: auto,
)

#let resolve(config) = {
  for key in config.keys() {
    assert(key in defaults, message: "未知配置项 / Unknown option: " + key)
  }
  let theme = config.at("theme", default: defaults.theme)
  assert(theme in themes, message: "未知主题 / Unknown theme: " + str(theme) + "; use teal / indigo / sepia")
  // Explicit color overrides always take precedence over the selected palette.
  let c = defaults + themes.at(theme) + config
  assert(c.lang in ("zh", "en", "bilingual"), message: "lang: zh / en / bilingual")
  c
}

#let localized(c, zh, en) = {
  if c.lang == "en" { en }
  else if c.lang == "bilingual" { zh + " / " + en }
  else { zh }
}

// Scoped presentation options avoid applying two raw show rules to the same code.
#let code-options = state("quiet-mathematics-code-options", (title: none, numbers: auto))

// Appendix chapters number themselves with letters and label their chapter
// heading "附录 / APPENDIX". The state lives here because the heading rule in
// notes() and the environments() helper are separate scopes. The index is read
// at the start of an appendix and written back after its body, so a read never
// shares a location with its own write and the page converges in one pass.
#let appendix-state = state("quiet-mathematics-appendix", false)
#let appendix-index = state("quiet-mathematics-appendix-index", 1)

// Keep the original raw element: highlighting retains multi-line lexer state.
#let render-code(c, it, title: none, numbers: auto) = {
  let numbered = if numbers == auto { c.code-line-numbers } else { numbers }
  let language = if it.lang == none { "text" } else { lower(it.lang) }
  let names = (python: "Python", py: "Python", julia: "Julia", jl: "Julia",
    matlab: "MATLAB", m: "MATLAB", typ: "Typst", typst: "Typst",
    mathematica: "Mathematica", wolfram: "Wolfram Language", wl: "Wolfram Language",
    bash: "Shell", sh: "Shell", text: "Code")
  let name = names.at(language, default: it.lang)
  block(width: 100%, breakable: true, fill: c.code-fill,
    radius: 3pt, inset: (x: 12pt, y: 10pt), above: 1.15em, below: 1.15em,
  )[
    #set text(font: (c.font-code, c.font-cjk), size: c.code-size, fill: c.ink)
    #set par(justify: false, leading: c.code-leading, spacing: 0pt)
    #if c.code-header or title != none {
      block(width: 100%, above: 0pt, below: 7pt, sticky: true)[
        #set text(font: c.font-heading, size: 8pt, fill: c.muted)
        #grid(columns: (1fr, auto), column-gutter: 12pt,
          text(weight: "bold", fill: c.accent)[#name],
          if title != none { align(right, title) } else { [] },
        )
        #v(4pt)
        #line(length: 100%, stroke: 0.4pt + c.rule)
      ]
    }
    #if numbered {
      show raw.line: line => grid(
        columns: (2.2em, 1fr), column-gutter: 10pt, align: (right, left),
        text(size: 0.85em, fill: c.muted, str(line.number)),
        line.body,
      )
      it
    } else { it }
  ]
}

// Native figures preserve labels, hyperlinks, and forward references.
// Theorem-like statements share one track; examples use their own track.
#let environments(config: (:)) = {
  let c = resolve(config)
  let code(body, title: none, numbers: auto) = context {
    let previous = code-options.get()
    code-options.update((title: title, numbers: numbers))
    body
    code-options.update(previous)
  }
  let statement(zh, en, kind: "math-note", numbering: c.theorem-numbering,
    title: none, body,
  ) = figure(
    body,
    kind: kind,
    supplement: localized(c, zh, en),
    caption: metadata((role: en, title: title)),
    numbering: numbering,
    outlined: false,
  )
  let proof(body, title: auto) = block(
    width: 100%, breakable: true, above: 0.8em, below: 1.2em,
  )[
    #block(above: 0pt, below: 0.5em, inset: (bottom: c.environment-title-gap), sticky: true)[
      #text(font: c.font-heading, size: 9.5pt, weight: "bold", fill: c.accent)[
        #if title == auto { localized(c, "证明", "Proof") } else { title }
      ]
    ]
    #body
    #h(1fr) #box(square(size: 5pt, stroke: 0.7pt + c.accent))
  ]
  let remark(body, title: auto) = block(
    width: 100%, breakable: true,
    inset: (left: 11pt, top: 3pt, bottom: 3pt),
    stroke: (left: 1pt + c.rule),
    above: 1em, below: 1em,
  )[
    #block(above: 0pt, below: 0.45em, inset: (bottom: c.environment-title-gap), sticky: true)[
      #text(font: c.font-heading, weight: "bold", size: 9pt, fill: c.muted)[
        #if title == auto { localized(c, "札记", "Remark") } else { title }
      ]
    ]
    #body
  ]
  // Chapter epigraph: independent from statement counters and the outline.
  let epigraph(body, author: none, source: none, translation: none,
    width: c.epigraph-width, placement: c.epigraph-align, italic: false,
    text-align: c.epigraph-text-align,
  ) = align(placement, block(width: width, breakable: false,
    above: 0pt, below: c.epigraph-after,
    inset: (top: 2pt, bottom: 2pt),
  )[
    #set par(justify: false, leading: 0.65em, spacing: 0.55em)
    #set text(size: c.epigraph-size, fill: c.epigraph-color)
    #layout(size => {
      let quotation = text(style: if italic { "italic" } else { "normal" }, body)
      let single-height = measure([Ag国]).height * 1.6
      let measured = measure(quotation)
      let one-line = measured.width <= size.width and measured.height <= single-height
      let translation-fits = translation == none or (
        measure(translation).width <= size.width and measure(translation).height <= single-height
      )
      let direction = if text-align != auto { text-align }
        else if one-line and translation-fits { right } else { left }
      set align(direction)
      quotation
      if translation != none {
        block(width: 100%, above: 0.4em, below: 0pt)[#translation]
      }
      if author != none or source != none {
        block(width: 100%, above: 0.5em, below: 0pt)[
          #text(size: 0.9em)[
          #if author != none { author }
          #if author != none and source != none { [ · ] }
          #if source != none { source }
          ]
        ]
      }
    })
  ])
  // Appendix chapter: letters instead of the running chapter sequence, and a
  // chapter label reading 附录 / APPENDIX. The numbering function replaces the
  // chapter component with the appendix's own index, so consecutive appendices
  // read A, B, C; the chapter counter is handed back afterwards, which keeps the
  // number of any chapter that follows the appendices untouched.
  let appendix(title, body) = context {
    let index = appendix-index.get()
    let base = counter(heading).get().first()
    appendix-state.update(true)
    set heading(numbering: (..nums) =>
      numbering(c.appendix-numbering, index, ..nums.pos().slice(1)))
    heading(level: 1, title)
    appendix-state.update(false)
    body
    // Read and write never share a location, so the page converges in one pass.
    counter(heading).update(base)
    appendix-index.update(index + 1)
  }
  (
    definition: statement.with("定义", "Definition"),
    theorem: statement.with("定理", "Theorem"),
    lemma: statement.with("引理", "Lemma"),
    proposition: statement.with("命题", "Proposition"),
    corollary: statement.with("推论", "Corollary"),
    example: statement.with(
      "例", "Example", kind: "math-example", numbering: c.example-numbering,
    ),
    exercise: statement.with("练习", "Exercise"),
    proof: proof,
    remark: remark,
    epigraph: epigraph,
    appendix: appendix,
    code: code,
  )
}

#let notes(config: (:), body) = {
  let c = resolve(config)
  let sans = c.font-heading
  let running = if c.running-title == auto { c.title } else { c.running-title }
  set document(title: c.title, author: c.author)
  set text(
    font: (c.font-latin, c.font-cjk),
    size: c.font-size, fill: c.ink,
    lang: if c.lang == "en" { "en" } else { "zh" },
    region: if c.lang == "en" { "US" } else { "CN" },
  )
  set par(justify: true, leading: c.leading, spacing: c.paragraph-spacing)
  set page(paper: c.paper, margin: c.margin)
  set heading(numbering: c.heading-numbering)
  set math.equation(numbering: c.equation-numbering,
    supplement: localized(c, "式", "Eq."))
  show math.equation: set text(font: c.font-math, size: c.math-scale * 1em)
  show math.equation.where(block: true): set block(
    above: c.equation-spacing, below: c.equation-spacing,
  )
  set raw(tab-size: c.code-tab-size, theme: if c.code-theme == auto {
    let theme-file = if c.theme == "teal" { "quiet" } else { c.theme }
    read("styles/" + theme-file + ".tmTheme", encoding: none)
  } else { c.code-theme })
  show raw: set text(font: (c.font-code, c.font-cjk), ligatures: false)
  show raw.where(block: false): set text(size: c.code-inline-size)
  show raw.where(block: true): set text(size: c.code-size)
  show raw.where(block: false): it => box(
    fill: c.code-fill, radius: 2pt, inset: (x: 3pt, y: 0pt), outset: (y: 1.5pt), it,
  )
  show raw.where(block: true): it => context {
    let options = code-options.get()
    render-code(c, it, title: options.title, numbers: options.numbers)
  }
  let link-color = if c.link-color == auto { c.accent } else { c.link-color }
  let citation-color = if c.citation-color == auto { c.accent } else { c.citation-color }
  show link: set text(fill: link-color)
  show link: it => {
    if type(it.dest) == str and c.link-underline {
      underline(stroke: 0.35pt + link-color.lighten(35%), offset: 2pt, it)
    } else { it }
  }
  show cite: it => {
    show link: set text(fill: citation-color)
    text(fill: citation-color, it)
  }
  show ref: set text(fill: c.accent)
  set bibliography(
    style: c.bibliography-style,
    title: if c.bibliography-title == auto {
      localized(c, "参考文献", "References")
    } else { c.bibliography-title },
  )
  show bibliography: it => {
    if c.bibliography-new-page { pagebreak(weak: true) }
    set text(size: c.bibliography-size)
    set par(justify: false, leading: 0.65em, spacing: c.bibliography-spacing)
    // The native heading remains locatable, unnumbered, and present in the TOC.
    show heading.where(level: 1): h => block(
      above: 13mm, below: 8mm, sticky: true,
    )[
      #text(font: sans, size: 8pt, tracking: 1.8pt, fill: c.accent)[REFERENCES]
      #v(4mm)
      #text(font: (c.font-latin, c.font-cjk), size: 23pt, weight: "bold", fill: c.ink)[#h.body]
      #v(3mm)
      #line(length: 100%, stroke: 0.4pt + c.rule)
    ]
    it
  }
  set list(indent: 1em, body-indent: 0.6em)
  set enum(indent: 1em, body-indent: 0.6em)
  set table(stroke: 0.4pt + c.rule, inset: 8pt)
  show table.cell.where(y: 0): set text(weight: "bold", fill: c.accent)
  // Figures carrying an image or a table keep the figure's own body centered and
  // the caption in the same voice as environment titles: bold accent label, small
  // muted text, one unbreakable block so body and caption never split.
  show figure.where(kind: image): set figure(supplement: localized(c, "图", "Figure"))
  show figure.where(kind: table): set figure(supplement: localized(c, "表", "Table"))
  let render-figure(it) = {
    // The caption is rebuilt from its body so that the label can carry the accent
    // color; it stays below the body, which is the default position for Typst.
    let caption = if it.caption == none { none } else { it.caption.body }
    let caption-block = if caption == none { none } else { block(width: 100%)[
      #set par(justify: false, leading: 0.7em)
      #set align(center)
      #set text(font: sans, size: c.figure-caption-size,
        fill: if c.figure-caption-color == auto { c.muted } else { c.figure-caption-color })
      #text(weight: "bold", fill: c.accent)[
        #it.supplement
        #if it.numbering != none {
          [#h(0.35em) #context numbering(
            it.numbering, ..counter(figure.where(kind: it.kind)).at(it.location()),
          )]
        }
        #h(0.55em)
      ]
      #caption
    ] }
    block(width: 100%, breakable: false, above: 1.3em, below: 1.3em)[
      #align(center, it.body)
      #if caption != none { v(0.6em); caption-block }
    ]
  }
  show figure.where(kind: image): render-figure
  show figure.where(kind: table): render-figure
  let show-statement(it) = context {
    set align(left)
    let info = it.caption.body.value
    let major = info.role == "Theorem"
    let supporting = info.role in ("Lemma", "Proposition", "Corollary")
    let heading-color = if info.role in ("Example", "Exercise") { c.ink } else { c.accent }
    block(width: 100%, breakable: true,
      fill: if major { c.tint } else { none },
      stroke: if major { (left: 1.3pt + c.accent) }
        else if supporting { (left: 0.6pt + c.rule) } else { none },
      inset: if major { (x: 12pt, y: 10pt) }
        else if supporting { (left: 10pt, y: 3pt) } else { (y: 2pt) },
      above: 1.2em, below: 1.1em,
    )[
      #block(above: 0pt, below: 0.65em, inset: (bottom: c.environment-title-gap), sticky: true)[
        #text(font: sans, weight: "bold", size: 9.5pt, fill: heading-color)[
          #it.supplement
          #if it.numbering != none {
            numbering(
              it.numbering,
              ..counter(figure.where(kind: it.kind)).at(it.location()),
            )
          }
          #if info.title != none { [#h(0.65em) #text(weight: "regular")[#info.title]] }
        ]
      ]
      #it.body
    ]
  }
  show figure.where(kind: "math-note"): set block(breakable: true)
  show figure.where(kind: "math-note"): show-statement
  show figure.where(kind: "math-example"): set block(breakable: true)
  show figure.where(kind: "math-example"): show-statement
  // The chapter label follows the heading's own numbering format, so appendices
  // read 附录 / APPENDIX A instead of a number from the running sequence.
  let chapter-label(it) = context {
    let is-appendix = appendix-state.get()
    text(font: sans, size: c.chapter-label-size, tracking: 1.8pt, fill: c.accent)[
      #if is-appendix { localized(c, "附录", "APPENDIX") } else { localized(c, "章节", "CHAPTER") }
      #if it.numbering != none { counter(heading).display(it.numbering) }
    ]
  }
  show heading: it => {
    if it.level == 1 and c.chapter-break { pagebreak(weak: true) }
    block(above: if it.level == 1 { 13mm } else { c.heading-before },
      below: if it.level == 1 { c.chapter-after } else { c.heading-after }, sticky: true,
    )[
      #if it.level == 1 {
        chapter-label(it)
        v(4mm)
      }
      #text(font: if it.level == 1 { (c.font-latin, c.font-cjk) } else { sans }, weight: "bold", fill: c.ink,
        size: if it.level == 1 { c.chapter-title-size }
          else if it.level == 2 { c.section-title-size } else { c.subsection-title-size },
      )[
        #if it.level > 1 and it.numbering != none {
          context counter(heading).display(it.numbering)
          h(0.6em)
        }
        #it.body
      ]
      #if it.level == 1 { v(3mm); line(length: 100%, stroke: 0.4pt + c.rule) }
    ]
  }

  if c.cover {
    page(header: none, footer: none, fill: c.cover-paper)[
      #set par(justify: false)
      #v(8mm)
      #text(font: sans, size: 8pt, tracking: 2pt, fill: c.accent)[QUIET MATHEMATICS]
      #h(1fr)
      #text(font: sans, size: 8pt, fill: c.muted)[#c.edition]
      #v(25mm)
      #line(length: 17mm, stroke: 2pt + c.accent)
      #v(8mm)
      #text(font: (c.font-latin, c.font-cjk), size: 36pt, weight: "bold")[#c.title]
      #v(5mm)
      #text(font: c.font-latin, size: 20pt, fill: c.accent)[#c.subtitle]
      #v(8mm)
      #text(size: 10pt, fill: c.muted)[#c.description]
      #v(1fr)
      #align(right)[
        #box(width: 69mm, height: 64mm)[
          #place(center + horizon, circle(radius: 29mm, stroke: 0.6pt + c.rule))
          #place(center + horizon, circle(radius: 21mm, stroke: 0.7pt + c.accent))
          #place(center + horizon, circle(radius: 11mm, stroke: 0.6pt + c.rule))
          #place(center + horizon, line(length: 68mm, stroke: 0.5pt + c.rule))
          #place(center + horizon, rotate(-45deg, line(length: 68mm, stroke: 0.5pt + c.rule)))
          #place(center + horizon, circle(radius: 1.4mm, fill: c.accent, stroke: none))
        ]
      ]
      #v(1fr)
      #line(length: 100%, stroke: 0.6pt + c.rule)
      #v(5mm)
      #grid(columns: (1fr, 1fr), align: (left, right),
        [#text(font: sans, size: 10pt)[#c.author]
          #if c.institution != "" { [\ #text(size: 9pt, fill: c.muted)[#c.institution]] }],
        text(font: sans, size: 9pt, fill: c.muted)[#c.date],
      )
    ]
  }

  if c.toc {
    counter(page).update(1)
    page(header: none, footer: if c.page-numbers {
      align(center, text(font: sans, size: 8pt, fill: c.muted, context counter(page).display("i")))
    })[
      #v(12mm)
      #text(font: sans, size: 8pt, tracking: 1.8pt, fill: c.accent)[CONTENTS]
      #v(5mm)
      #text(font: sans, weight: "bold", size: 25pt)[
        #if c.toc-title == auto { localized(c, "目录", "Contents") } else { c.toc-title }
      ]
      #v(5mm)
      #line(length: 100%, stroke: 0.6pt + c.rule)
      #v(10mm)
      #set par(justify: false, leading: 0.7em)
      #set outline.entry(fill: none)
      #show outline.entry: it => {
        let chapter = it.level == 1
        block(above: if chapter { 6mm } else { 1.5mm },
          below: if chapter { 2mm } else { 1.5mm }, sticky: chapter,
          inset: (y: if chapter { 1mm } else { 0.8mm }),
        )[
          #set text(size: if chapter { 12pt } else { 9.5pt },
            fill: if chapter { c.ink } else { c.muted },
            weight: if chapter { "bold" } else { "regular" })
          #show link: set text(fill: if chapter { c.ink } else { c.muted })
          #link(it.element.location(), it.indented(
            text(fill: if chapter { c.accent } else { c.muted }, it.prefix()), it.inner(),
          ))
        ]
      }
      #outline(title: none, depth: c.toc-depth, indent: 1.5em)
    ]
  }

  set page(
    header: if c.headers {
      context {
        let this-page = here().page()
        let previous = query(heading.where(level: 1)).filter(h => h.location().page() <= this-page)
        let chapter = if previous.len() > 0 { previous.last().body } else { [] }
        set text(font: sans, size: 8pt, fill: c.muted)
        set par(justify: false)
        grid(columns: (1fr, 1fr), align: (left, right), [#running], [#chapter])
        v(2mm)
        line(length: 100%, stroke: 0.5pt + c.rule)
      }
    },
    footer: if c.page-numbers {
      align(center, text(font: sans, size: 9pt, fill: c.muted, context counter(page).display("1")))
    },
  )
  counter(page).update(1)
  body
}
