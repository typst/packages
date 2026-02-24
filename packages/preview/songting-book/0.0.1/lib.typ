#import "@preview/outrageous:0.4.0"
#import "@preview/numbly:0.1.0": numbly
#import "@preview/hydra:0.6.1": hydra
#import "@preview/modern-nju-thesis:0.4.0": 字体, 字号

// Public constants for default configurations
#let default-songting-cfg = (
  paper: "a4",
  margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 3cm),
  main-font: ("SimSun", "Times New Roman"),
  title-font: ("SimHei",),
  kai-font: ("KaiTi", "KaiTi_GB2312"),
  lang: "zh",
  size: 12pt,
  tracking: 0.1em,
  line-spacing: 1.5em,
  par-spacing: 1.5em,
  indent: 2em,
  justify: true,
  chapter-label: "第{1:一}章",
  section-label: "第{2:一}节",
  header-rule: true,
  display-header: true,
  display-page-numbers: true,
  use-odd-pagebreak: false,
  header-spacing: 0.25em,
  header-font-size-factor: 0.875,
  header-font: "KaiTi",
  outline_depth: 3,
  headingone-adjust-char: "　　",
  enum_num: numbly(
    "{1:一}、",
    "{2:①}、",
    "{3:1}、",
    "{4:I}、",
    "{5:1}、",
  )
)

#let default-paper-cfg = (
  a4: (
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
    toc-title-font: "SimSun",
    toc-title-size: 16pt,
    toc-title-weight: "bold",
    toc-title-align: center,
    toc-level1-font: "SimHei",
    toc-other-font: "SimSun",
    toc-entry-size: (14pt, 12pt, 12pt),
    toc-vspace: (2em, 1em),
    heading: (
      font: ("SimHei", "SimHei", "SimHei", "SimHei", "SimHei"),
      size: (22pt, 16pt, 15pt, 14pt, 14pt),
      weight: ("bold", "regular", "regular", "regular", "regular"),
      align: (center, left, left, left, left),
      above: (2em, 2em, 1.5em, 1.2em, 1em),
      below: (2em, 1.5em, 1.2em, 1em, 0.8em),
      pagebreak: (true, false, false, false, false),
    ),
    caption-font: "SimSun",
    caption-size: 10.5pt,
    footnote-font: "SimSun",
    footnote-size: 10.5pt,
  ),
  iso-b6: (
    margin: (top: 1cm, bottom: 1cm, left: 0.6cm, right: 0.6cm),
    size: 字号.三号,
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
    heading: (
      font: auto,
      size: (字号.三号 + 4pt, 字号.三号 + 1pt, 字号.三号 + 1pt, 字号.三号 + 1pt, 字号.三号),
      weight: ("bold", "bold", "bold", "bold", "bold"),
      align: (center, left, left, left, left),
      above: (2em, 1.2em, 1.2em, 1.2em, 1em),
      below: (1.5em, 1.2em, 1.2em, 1.2em, 1em),
      pagebreak: (true, false, false, false, false),
    ),
  )
)

// Helper function to compute final configuration
#let compute-config(paper-cfg-override: (:), cfg-override: (:)) = {
  let paper-cfg = default-paper-cfg + paper-cfg-override
  let cfg = default-songting-cfg + cfg-override
  let paper-type = cfg.paper

  // Apply paper-specific config
  let paper-settings = if paper-type != none and paper-cfg.at(paper-type, default:none) != none {
    paper-cfg.at(paper-type)
  } else {
    paper-cfg.at("a4")
  }
  (paper-settings + cfg , paper-settings.heading)
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
  front-matter-headings: ("前言", "目录", "序言", "跋", "自序"),
  back-matter-headings: ("附录", "后记", "参考文献", "索引", "本书引用书目"),
  heading-cfg: (:),
  paper-cfg: (:),
  cfg: (:),
  body,
) = {
  // Compute final configuration
  let (cfg, default-heading) = compute-config(paper-cfg-override: paper-cfg, cfg-override: cfg)
  let heading-cfg = default-heading + heading-cfg

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

  // Start front matter with roman numerals (if page numbers are displayed)
  counter(page).update(1)
  set page(numbering: "i") if cfg.display-page-numbers

  // Define the heading structure and formatting
  show heading: it => {
    let level = it.level

    // Apply appropriate spacing
    set block(
      above: array-at(heading-cfg.above, level),
      below: array-at(heading-cfg.below, level),
    )

    // Check if we need a pagebreak for this heading level
    if array-at(heading-cfg.pagebreak, level) {
      pagebreak(weak: true, to: if cfg.use-odd-pagebreak { "odd" } )
    }

    // Apply text formatting for this heading level
    let heading-content = {
      set text(
        font: array-at(heading-cfg.font, level),
        size: array-at(heading-cfg.size, level),
        weight: array-at(heading-cfg.weight, level),
      )

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
      font: ("SimHei", "SimSun"),
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
          text(size: cfg.toc-entry-size.at(2), prefix)
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
  set heading(
    numbering: numbly(
      cfg.chapter-label,
      cfg.section-label,
      "{3:一}、",
      "{4:1}、",
      "{5:I}、",
    ),
  )

  // Header for main content pages
  set page(
    header: context {
      align(center)[#text(font: cfg.kai-font, size: cfg.size * cfg.header-font-size-factor)[#hydra(1)]]
      line(length: 100%)
    },
  ) if cfg.display-header

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