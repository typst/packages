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
  equation-numbering: "(1)",
  theorem-numbering: "1",
  paper: "a4",
  margin: (top: 23mm, bottom: 23mm, left: 25mm, right: 23mm),
  font-size: 10.5pt,
  leading: 0.8em,
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
  bibliography-style: "ieee",
  bibliography-title: auto,
  bibliography-new-page: true,
  bibliography-size: 9.5pt,
  bibliography-spacing: 1.1em,
  link-color: auto,
  link-underline: true,
  citation-color: auto,
  code-size: 9pt,
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

// Keep the original raw element: highlighting retains multi-line lexer state.
#let render-code(c, it, title: none, numbers: auto) = {
  let numbered = if numbers == auto { c.code-line-numbers } else { numbers }
  let language = if it.lang == none { "text" } else { lower(it.lang) }
  let names = (python: "Python", py: "Python", julia: "Julia", jl: "Julia",
    matlab: "MATLAB", m: "MATLAB", typ: "Typst", typst: "Typst",
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

// A shared figure kind gives all mathematical statements one counter.
// Using native figures preserves labels, hyperlinks, and forward references.
#let environments(config: (:)) = {
  let c = resolve(config)
  let code(body, title: none, numbers: auto) = context {
    let previous = code-options.get()
    code-options.update((title: title, numbers: numbers))
    body
    code-options.update(previous)
  }
  let statement(zh, en, title: none, body) = figure(
    body,
    kind: "math-note",
    supplement: localized(c, zh, en),
    caption: metadata((role: en, title: title)),
    numbering: c.theorem-numbering,
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
  (
    definition: statement.with("定义", "Definition"),
    theorem: statement.with("定理", "Theorem"),
    lemma: statement.with("引理", "Lemma"),
    proposition: statement.with("命题", "Proposition"),
    corollary: statement.with("推论", "Corollary"),
    example: statement.with("例", "Example"),
    exercise: statement.with("练习", "Exercise"),
    proof: proof,
    remark: remark,
    epigraph: epigraph,
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
  set par(justify: true, leading: c.leading, spacing: 0.85em)
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
  show raw.where(block: false): set text(size: 0.85em)
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
  show figure.where(kind: "math-note"): set block(breakable: true)
  show figure.where(kind: "math-note"): it => context {
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
            numbering(it.numbering, ..counter(figure.where(kind: "math-note")).at(it.location()))
          }
          #if info.title != none { [#h(0.65em) #text(weight: "regular")[#info.title]] }
        ]
      ]
      #it.body
    ]
  }
  show heading: it => {
    if it.level == 1 and c.chapter-break { pagebreak(weak: true) }
    block(above: if it.level == 1 { 13mm } else { 1.5em },
      below: if it.level == 1 { c.chapter-after } else { 0.8em }, sticky: true,
    )[
      #if it.level == 1 {
        text(font: sans, size: 8pt, tracking: 1.8pt, fill: c.accent)[
          #localized(c, "章节", "CHAPTER")
          #if it.numbering != none { context counter(heading).display("1") }
        ]
        v(4mm)
      }
      #text(font: if it.level == 1 { (c.font-latin, c.font-cjk) } else { sans }, weight: "bold", fill: c.ink,
        size: if it.level == 1 { 23pt } else if it.level == 2 { 13pt } else { 11pt },
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
